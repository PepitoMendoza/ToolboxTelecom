-- ============================================================================
-- Routes optiques GraceTHD v3.1 — Calcul et stockage
-- ============================================================================
--
-- Contenu de ce fichier :
--   1. Table de résultats  : gracethd3_1_raw.t_route_optique
--   2. Index sur la table  : pour les requêtes courantes
--   3. Fonction            : gracethd3_1_raw.calculer_routes_optiques()
--
-- Principe du calcul (repris du script Python GRACE v2/v3) :
--   - On part de chaque position attachée à un tiroir (ps_ti_code IS NOT NULL)
--   - Chaque position de départ génère un identifiant de route (UUID)
--   - On suit ensuite la chaîne ps_1 → ps_2 de position en position
--   - Chaque saut est stocké en une ligne avec son rang (iteration)
--   - La boucle s'arrête quand ps_2 est NULL ou qu'on atteint p_max_iterations
--
-- Schéma ciblé : gracethd3_1_raw
-- Prérequis    : extension pgcrypto (pour gen_random_uuid())
--
-- Usage :
--   SELECT gracethd3_1_raw.calculer_routes_optiques();
--   SELECT gracethd3_1_raw.calculer_routes_optiques(p_max_iterations => 20);
--   SELECT gracethd3_1_raw.calculer_routes_optiques(p_truncate => FALSE);
-- ============================================================================


-- Extension nécessaire pour gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ============================================================================
-- 1. TABLE DE RÉSULTATS
-- ============================================================================

-- Suppression si elle existe déjà (pour re-déploiement propre)
DROP TABLE IF EXISTS gracethd3_1_raw.t_route_optique;

CREATE TABLE gracethd3_1_raw.t_route_optique (

    -- Clé technique auto-incrémentée
    ro_id        BIGSERIAL PRIMARY KEY,

    -- Identifiant de la route complète (même UUID pour tous les sauts d'une fibre)
    -- Permet de reconstituer la chaîne SRO → terminaison
    route_id     UUID        NOT NULL,

    -- Local technique de départ (SRO, SROL ou NRO)
    sro_code     VARCHAR,
    sro_etiquet  VARCHAR,

    -- Tiroir de départ de la route
    tiroir_code  VARCHAR,

    -- Type de câble / segment (DI = distribution, TR = transport, etc.)
    -- Récupéré depuis cb_typelog ; peut changer au fil des sauts
    segment      VARCHAR,

    -- Rang du saut dans la route (0 = saut depuis le tiroir de départ)
    iteration    INTEGER     NOT NULL,

    -- Position courante
    ps_code      VARCHAR,
    ps_fonct     VARCHAR,    -- fonction : CO, EP, AT, PA, PI, MA…
    ps_1         VARCHAR,    -- fibre entrante (NULL au saut 0)
    ps_2         VARCHAR,    -- fibre sortante (NULL = fin de chaîne)

    -- Boîtier de passage ou tiroir présent sur cette position (si applicable)
    bp_code      VARCHAR,
    ti_code      VARCHAR,

    -- Câble associé à la fibre ps_2
    cb_code      VARCHAR,
    cb_lgreel    NUMERIC,    -- longueur réelle du câble (mètres)

    -- Identification de la fibre dans le câble
    fo_numtub    INTEGER,    -- numéro de tube
    fo_nintub    INTEGER,    -- numéro de fibre dans le tube

    -- Horodatage du calcul (utile pour tracer les recalculs)
    calcul_date  TIMESTAMP   NOT NULL DEFAULT NOW()

);

COMMENT ON TABLE gracethd3_1_raw.t_route_optique IS
    'Routes optiques calculées : une ligne par saut de position. '
    'Regrouper par route_id pour reconstituer une route complète. '
    'Généré par la fonction calculer_routes_optiques().';

COMMENT ON COLUMN gracethd3_1_raw.t_route_optique.route_id IS
    'UUID partagé par tous les sauts d''une même route (fibre suivie depuis son tiroir).';
COMMENT ON COLUMN gracethd3_1_raw.t_route_optique.iteration IS
    'Rang du saut : 0 = position au tiroir de départ, 1 = premier saut, etc.';
COMMENT ON COLUMN gracethd3_1_raw.t_route_optique.segment IS
    'Type logique de câble (cb_typelog) : DI = distribution, TR = transport.';
COMMENT ON COLUMN gracethd3_1_raw.t_route_optique.ps_1 IS
    'Code de la fibre entrante dans cette position (NULL pour le saut 0).';
COMMENT ON COLUMN gracethd3_1_raw.t_route_optique.ps_2 IS
    'Code de la fibre sortante. NULL indique la fin de la route.';


-- ============================================================================
-- 2. INDEX SUR LA TABLE DE RÉSULTATS
-- ============================================================================

-- Index principal : reconstituer une route par son UUID
CREATE INDEX idx_ro_route_id
    ON gracethd3_1_raw.t_route_optique (route_id);

-- Index pour filtrer par SRO de départ (usage fréquent)
CREATE INDEX idx_ro_sro_code
    ON gracethd3_1_raw.t_route_optique (sro_code);

-- Index pour filtrer par segment (DI / TR)
CREATE INDEX idx_ro_segment
    ON gracethd3_1_raw.t_route_optique (segment);

-- Index pour retrouver un saut par son code position
CREATE INDEX idx_ro_ps_code
    ON gracethd3_1_raw.t_route_optique (ps_code);


-- ============================================================================
-- 3. FONCTION DE CALCUL
-- ============================================================================

CREATE OR REPLACE FUNCTION gracethd3_1_raw.calculer_routes_optiques(
    p_max_iterations INTEGER DEFAULT 15,
    -- Nombre maximal de sauts par route. Protège contre les cycles éventuels
    -- et les données corrompues. Valeur recommandée : 15 (réseau standard).

    p_truncate       BOOLEAN DEFAULT TRUE
    -- Si TRUE (défaut), vide la table avant le calcul (recalcul complet).
    -- Si FALSE, ajoute les nouvelles routes sans supprimer l'existant.
    -- Attention : mettre FALSE sans filtrage peut créer des doublons.
)
RETURNS INTEGER
-- Retourne le nombre total de routes calculées (= nombre de positions de départ).
LANGUAGE plpgsql
AS $$
DECLARE
    -- Compteur de routes créées (valeur de retour)
    v_nb_routes   INTEGER := 0;

    -- UUID de la route en cours de traitement
    v_route_id    UUID;

    -- Rang du saut courant dans la boucle d'itération
    v_iteration   INTEGER;

    -- ps_2 de la position courante (point d'entrée du prochain saut)
    v_ps2_courant VARCHAR;

    -- Enregistrement du saut suivant, récupéré par la requête de suivi
    v_saut_suivant RECORD;

    -- Enregistrement de départ (positions attachées à un tiroir)
    r_depart      RECORD;

BEGIN
    -- ------------------------------------------------------------------
    -- Optionnellement, vider la table de résultats avant le calcul
    -- ------------------------------------------------------------------
    IF p_truncate THEN
        TRUNCATE gracethd3_1_raw.t_route_optique;
        RAISE NOTICE 'Table t_route_optique vidée avant recalcul.';
    END IF;

    -- ------------------------------------------------------------------
    -- Boucle principale : une itération = une route (= une fibre de départ)
    --
    -- On sélectionne toutes les positions attachées à un tiroir.
    -- C'est le point de départ de chaque route, conformément à la logique
    -- du script Python (iteration 0 = positions attenantes aux tiroirs).
    -- ------------------------------------------------------------------
    FOR r_depart IN
        SELECT
            -- Informations sur le local technique (SRO/NRO) de départ
            lc.lc_code      AS sro_code,
            lc.lc_etiquet   AS sro_etiquet,

            -- Tiroir de départ
            ti.ti_code      AS ti_code,

            -- Position de départ
            ps.ps_code      AS ps_code,
            ps.ps_fonct     AS ps_fonct,
            ps.ps_1         AS ps_1,
            ps.ps_2         AS ps_2,
            ps.ps_numero    AS ps_numero,

            -- Cassette (si présente)
            cs.cs_num       AS cs_num,

            -- Câble associé à la fibre ps_2
            cb.cb_code      AS cb_code,
            cb.cb_typelog   AS cb_typelog,
            cb.cb_lgreel    AS cb_lgreel,

            -- Fibre
            fo.fo_numtub    AS fo_numtub,
            fo.fo_nintub    AS fo_nintub

        FROM gracethd3_1_raw.t_position ps

        -- Jointure obligatoire : on ne garde que les positions avec tiroir
        JOIN gracethd3_1_raw.t_tiroir ti
            ON ti.ti_code = ps.ps_ti_code

        -- Remontée vers le local technique via baie
        LEFT JOIN gracethd3_1_raw.t_baie ba
            ON ba.ba_code = ti.ti_ba_code
        LEFT JOIN gracethd3_1_raw.t_local lc
            ON lc.lc_code = ba.ba_lc_code

        -- Cassette optionnelle (présente sur certains tiroirs, ex : CG57)
        LEFT JOIN gracethd3_1_raw.t_cassette cs
            ON cs.cs_code = ps.ps_cs_code

        -- Fibre et câble associés à la sortie ps_2
        LEFT JOIN gracethd3_1_raw.t_fibre fo
            ON fo.fo_code = ps.ps_2
        LEFT JOIN gracethd3_1_raw.t_cable cb
            ON cb.cb_code = fo.fo_cb_code

        -- Tri identique au script Python : tiroir, cassette, numéro de position
        ORDER BY ti.ti_code ASC, cs.cs_num ASC, ps.ps_numero ASC

    LOOP
        -- Génère un UUID unique pour identifier cette route
        v_route_id    := gen_random_uuid();
        v_iteration   := 0;
        v_ps2_courant := r_depart.ps_2;

        -- ---------------------------------------------------------------
        -- Insertion du saut 0 : la position de départ au niveau du tiroir
        -- ---------------------------------------------------------------
        INSERT INTO gracethd3_1_raw.t_route_optique (
            route_id,
            sro_code, sro_etiquet,
            tiroir_code,
            segment,
            iteration,
            ps_code, ps_fonct, ps_1, ps_2,
            ti_code,
            cb_code, cb_lgreel,
            fo_numtub, fo_nintub
        ) VALUES (
            v_route_id,
            r_depart.sro_code, r_depart.sro_etiquet,
            r_depart.ti_code,
            r_depart.cb_typelog,    -- segment = type logique du câble de départ
            0,
            r_depart.ps_code, r_depart.ps_fonct, r_depart.ps_1, r_depart.ps_2,
            r_depart.ti_code,       -- le tiroir est sur la position de départ
            r_depart.cb_code, r_depart.cb_lgreel,
            r_depart.fo_numtub, r_depart.fo_nintub
        );

        v_nb_routes := v_nb_routes + 1;
        v_iteration := 1;

        -- ---------------------------------------------------------------
        -- Boucle de suivi : on remonte la chaîne ps_1 → ps_2
        --
        -- Condition d'arrêt :
        --   - ps_2 de la position courante est NULL (fin de route)
        --   - On a atteint p_max_iterations (protection anti-boucle infinie)
        -- ---------------------------------------------------------------
        WHILE v_ps2_courant IS NOT NULL AND v_iteration <= p_max_iterations LOOP

            -- Chercher la position suivante dont ps_1 = ps_2 courant
            SELECT
                ps.ps_code      AS ps_code,
                ps.ps_fonct     AS ps_fonct,
                ps.ps_1         AS ps_1,
                ps.ps_2         AS ps_2,

                -- Boîtier de passage (via cassette) ou tiroir sur ce saut
                cs.cs_bp_code   AS bp_code,
                ti2.ti_code     AS ti_code,

                -- Câble et fibre de sortie
                cb.cb_code      AS cb_code,
                cb.cb_typelog   AS cb_typelog,
                cb.cb_lgreel    AS cb_lgreel,
                fo.fo_numtub    AS fo_numtub,
                fo.fo_nintub    AS fo_nintub

            INTO v_saut_suivant

            FROM gracethd3_1_raw.t_position ps

            -- La jointure clé : ps_1 du saut suivant = ps_2 du saut courant
            -- C'est le mécanisme de chaînage de la route optique

            LEFT JOIN gracethd3_1_raw.t_cassette cs
                ON cs.cs_code = ps.ps_cs_code
            LEFT JOIN gracethd3_1_raw.t_ebp ebp
                ON ebp.bp_code = cs.cs_bp_code
            LEFT JOIN gracethd3_1_raw.t_tiroir ti2
                ON ti2.ti_code = ps.ps_ti_code
            LEFT JOIN gracethd3_1_raw.t_fibre fo
                ON fo.fo_code = ps.ps_2
            LEFT JOIN gracethd3_1_raw.t_cable cb
                ON cb.cb_code = fo.fo_cb_code

            WHERE ps.ps_1 = v_ps2_courant;

            -- Si aucune position suivante : fin de la route
            EXIT WHEN NOT FOUND;

            -- Insertion du saut courant
            INSERT INTO gracethd3_1_raw.t_route_optique (
                route_id,
                sro_code, sro_etiquet,
                tiroir_code,
                segment,
                iteration,
                ps_code, ps_fonct, ps_1, ps_2,
                bp_code, ti_code,
                cb_code, cb_lgreel,
                fo_numtub, fo_nintub
            ) VALUES (
                v_route_id,
                r_depart.sro_code, r_depart.sro_etiquet,    -- hérités du départ
                r_depart.ti_code,                            -- tiroir d'origine inchangé
                COALESCE(v_saut_suivant.cb_typelog, r_depart.cb_typelog),
                -- On hérite du segment de départ si le câble courant n'en a pas
                v_iteration,
                v_saut_suivant.ps_code, v_saut_suivant.ps_fonct,
                v_saut_suivant.ps_1, v_saut_suivant.ps_2,
                v_saut_suivant.bp_code, v_saut_suivant.ti_code,
                v_saut_suivant.cb_code, v_saut_suivant.cb_lgreel,
                v_saut_suivant.fo_numtub, v_saut_suivant.fo_nintub
            );

            -- Avancer dans la chaîne
            v_ps2_courant := v_saut_suivant.ps_2;
            v_iteration   := v_iteration + 1;

        END LOOP;

        -- Avertissement si on a atteint la limite de sécurité
        IF v_iteration > p_max_iterations THEN
            RAISE WARNING
                'Route % (départ tiroir %) : limite de % sauts atteinte. '
                'La route est peut-être incomplète ou les données contiennent un cycle.',
                v_route_id, r_depart.ti_code, p_max_iterations;
        END IF;

    END LOOP;

    RAISE NOTICE 'Calcul terminé : % routes insérées dans t_route_optique.', v_nb_routes;
    RETURN v_nb_routes;

END;
$$;

COMMENT ON FUNCTION gracethd3_1_raw.calculer_routes_optiques(INTEGER, BOOLEAN) IS
    'Calcule les routes optiques depuis les tiroirs et les stocke dans t_route_optique. '
    'Une ligne = un saut de position. Toute la chaîne d''une même fibre partage le même route_id. '
    'p_max_iterations : nombre maximal de sauts (défaut 15, protection anti-boucle). '
    'p_truncate : si TRUE (défaut), vide la table avant le calcul.';


-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Recalcul complet (défaut)
-- SELECT gracethd3_1_raw.calculer_routes_optiques();

-- Recalcul avec une limite de 20 sauts
-- SELECT gracethd3_1_raw.calculer_routes_optiques(p_max_iterations => 20);

-- Ajouter sans vider (par exemple après import partiel de données)
-- SELECT gracethd3_1_raw.calculer_routes_optiques(p_truncate => FALSE);

-- Consulter une route complète reconstituée
-- SELECT * FROM gracethd3_1_raw.t_route_optique
-- WHERE route_id = '<uuid>'
-- ORDER BY iteration;

-- Résumé par SRO : nombre de routes et profondeur max
-- SELECT sro_code, COUNT(DISTINCT route_id) AS nb_routes, MAX(iteration) AS max_sauts
-- FROM gracethd3_1_raw.t_route_optique
-- GROUP BY sro_code
-- ORDER BY sro_code;
