#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════╗
║  Générateur SQL — Schéma PostgreSQL/PostGIS GraceTHD v3.1          ║
║                                                                      ║
║  Lit la matrice de conformité (Excel An_1b) et produit un script     ║
║  SQL complet pour créer la base de données GraceTHD v3.1.            ║
║                                                                      ║
║  Auteur : Script généré avec Claude (Anthropic)                      ║
║  Version : 1.0                                                       ║
║  Date : 2026-03-24                                                   ║
╚══════════════════════════════════════════════════════════════════════╝

UTILISATION :
    python generate_gracethd_sql.py An_1b_-_grilles_de_remplissage.xlsx

SORTIE :
    Fichier SQL : gracethd_v31_schema.sql

CE QUE LE SCRIPT GÉNÈRE :
    1. Création du schéma + activation PostGIS
    2. Tables de listes de valeurs (l_*) avec données
    3. Tables métier (t_*) avec types PostgreSQL
    4. Colonnes géométriques PostGIS (SRID 2154 - Lambert 93)
    5. Contraintes : NOT NULL, PRIMARY KEY, UNIQUE
    6. Clés étrangères (vers listes et entre tables)
    7. Index spatiaux (GiST) et index sur clés étrangères
    8. Commentaires SQL sur chaque table et colonne (documentation)

PRINCIPES :
    - Le SQL est lisible et exécutable section par section
    - Les FK sont ajoutées en fin de script (après toutes les tables)
    - Les index sont créés après les FK
    - Tout est documenté avec COMMENT ON
"""

import sys
import re
from datetime import datetime
from typing import Dict, List, Tuple, Optional

import pandas as pd


# =============================================================================
# CONFIGURATION
# =============================================================================

SCHEMA = "gracethd3_1_raw"
SRID = 2154  # Lambert 93

# Ordre de création des tables (résout les dépendances de FK)
# Les tables référencées par d'autres doivent être créées en premier.
TABLE_CREATION_ORDER = [
    # 1. Tables sans dépendance vers d'autres tables métier
    "t_organisme",
    "t_noeud",
    "t_reference",
    # 2. Tables dépendant de t_noeud / t_organisme
    "t_site",
    "t_ptech",
    "t_local",
    "t_ebp",
    "t_baie",
    "t_cassette",
    "t_tiroir",
    "t_position",
    "t_love",
    # 3. Tables réseau linéaire
    "t_cheminement",
    "t_cableline",
    "t_cable",
    "t_cab_chem",
    "t_fibre",
    "t_tranchee",
    # 4. Tables de zonage
    "t_znro",
    "t_zsro",
    "t_zpbo",
    "t_zdep",
    # 5. Tables finales (dépendent de beaucoup d'autres)
    "t_adresse",
    "t_pointaccueil",
    "t_point_leve",
]


# =============================================================================
# MAPPING DES TYPES SQL → PostgreSQL
# =============================================================================

def map_type_to_pg(type_sql: str) -> str:
    """
    Convertit un type SQL de la matrice GraceTHD vers un type PostgreSQL natif.

    Exemples :
        VARCHAR(254)                  → VARCHAR(254)
        INTEGER                       → INTEGER
        BIGINT                        → BIGINT
        NUMERIC(5,2)                  → NUMERIC(5,2)
        NUMERIC                       → NUMERIC
        TIMESTAMP                     → TIMESTAMP
        DATE                          → DATE
        Geometry(Point,2154)          → (géré séparément via AddGeometryColumn)
        geometry(MultiPolygon,2154)   → (géré séparément)
    """
    if pd.isna(type_sql):
        return "TEXT"

    t = str(type_sql).strip()

    # Les géométries sont gérées séparément (PostGIS)
    if "eometry" in t.lower():
        return None  # Signal : ne pas créer cette colonne ici

    # Types directs (déjà compatibles PostgreSQL)
    if t.startswith("VARCHAR"):
        return t
    if t in ("INTEGER", "BIGINT", "NUMERIC", "DATE", "TIMESTAMP"):
        return t
    if t.startswith("NUMERIC("):
        return t

    # Fallback
    return "TEXT"


def parse_geometry_type(type_sql: str) -> Optional[Tuple[str, int]]:
    """
    Extrait le type de géométrie et le SRID depuis le type SQL.

    Retourne (geom_type, srid) ou None si ce n'est pas une géométrie.

    Exemples :
        'Geometry(Point,2154)'          → ('POINT', 2154)
        'Geometry(Linestring,2154)'     → ('LINESTRING', 2154)
        'geometry(MultiPolygon,2154)'   → ('MULTIPOLYGON', 2154)
    """
    if pd.isna(type_sql):
        return None

    match = re.match(
        r'[Gg]eometry\(\s*(\w+)\s*,\s*(\d+)\s*\)',
        str(type_sql).strip()
    )
    if match:
        return (match.group(1).upper(), int(match.group(2)))
    return None


# =============================================================================
# UTILITAIRES D'ÉCHAPPEMENT SQL
# =============================================================================

def sql_escape(text: str) -> str:
    """Échappe les apostrophes pour les chaînes SQL."""
    if pd.isna(text):
        return ""
    return str(text).replace("'", "''")


def sql_comment_text(text: str) -> str:
    """Nettoie un texte de définition pour l'utiliser dans un COMMENT ON."""
    if pd.isna(text):
        return ""
    # Retirer les retours à la ligne et espaces multiples
    clean = re.sub(r'\s+', ' ', str(text).strip())
    return sql_escape(clean)


# =============================================================================
# CHARGEMENT DES DONNÉES DEPUIS L'EXCEL
# =============================================================================

def load_excel(path: str) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Charge les 3 onglets de la matrice de conformité.

    Retourne : (df_classes, df_attributs_v31, df_valeurs)
    """
    print(f"[INFO] Chargement de la matrice : {path}")

    # --- MCD_Classes (tables) ---
    df_classes = pd.read_excel(path, sheet_name='MCD_Classes', header=0)
    df_classes.columns = [
        c.replace('\xa0', ' ').replace('\n', ' ').strip()
        for c in df_classes.columns
    ]
    print(f"  → {len(df_classes)} tables chargées")

    # --- MCD_Attributs ---
    df_attr = pd.read_excel(path, sheet_name='MCD_Attributs', header=0)
    df_attr.columns = [
        'table_name', 'attr_name', 'attr_v2', 'type_sql', 'type_gpkg',
        'contraintes', 'relation', 'definition',
        'c1', 'c2', 'c3', 'c4',
        'condition', 'regle_gestion', 'commentaire',
        'comparaison_v3', 'test_c3c4', 'desc_changements'
    ]
    df_attr['table_name'] = df_attr['table_name'].astype(str).str.strip()
    df_attr['attr_name'] = df_attr['attr_name'].astype(str).str.strip()

    # Filtre v3.1 : attributs actifs (test=1) + attributs modifiés non testés (t_zdep, etc.)
    v31 = df_attr[
        (df_attr['test_c3c4'] == 1) |
        ((df_attr['test_c3c4'] == 0) & (df_attr['comparaison_v3'] == 'Modifié'))
    ].copy()
    print(f"  → {len(v31)} attributs actifs v3.1")

    # --- MCD_Valeurs ---
    df_val = pd.read_excel(path, sheet_name='MCD_Valeurs', header=0)
    print(f"  → {len(df_val)} valeurs de listes")

    return df_classes, v31, df_val


# =============================================================================
# GÉNÉRATEURS SQL
# =============================================================================

def generate_header(schema: str) -> str:
    """En-tête du script SQL avec création du schéma et activation PostGIS."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    return f"""-- ============================================================================
-- Script de création du schéma PostgreSQL/PostGIS GraceTHD v3.1
-- ============================================================================
--
-- Schéma    : {schema}
-- SRID      : {SRID} (Lambert 93)
-- Généré le : {now}
-- Source    : Matrice de conformité An_1b — Grilles de remplissage v3.1
--
-- Ce script crée la structure complète du modèle GraceTHD v3.1 :
--   1. Schéma et extension PostGIS
--   2. Tables de listes de valeurs (domaines l_*)
--   3. Tables métier (t_*)
--   4. Contraintes : PK, UNIQUE, NOT NULL
--   5. Clés étrangères
--   6. Index spatiaux et classiques
--   7. Commentaires de documentation
--
-- IMPORTANT : Exécuter ce script avec un rôle ayant les droits CREATE SCHEMA
--             et CREATE EXTENSION (superuser ou équivalent).
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. SCHÉMA ET EXTENSIONS
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS {schema};

-- PostGIS pour les types géométriques et les fonctions spatiales
CREATE EXTENSION IF NOT EXISTS postgis;

-- Permettre l'utilisation du schéma par défaut dans les requêtes
SET search_path TO {schema}, public;

"""


def generate_lookup_tables(df_val: pd.DataFrame, df_attrs: pd.DataFrame,
                           schema: str) -> str:
    """
    Génère les CREATE TABLE + INSERT pour toutes les tables de listes (l_*).

    Deux catégories :
    - Listes avec valeurs dans MCD_Valeurs → CREATE + INSERT
    - Listes référencées en FK mais absentes de MCD_Valeurs → CREATE vide
    """
    lines = []
    lines.append("-- ============================================================================")
    lines.append("-- 2. TABLES DE LISTES DE VALEURS (domaines l_*)")
    lines.append("-- ============================================================================")
    lines.append("-- Chaque liste contient un code (clé primaire) et un libellé.")
    lines.append("-- Ces tables servent de domaines de valeurs pour les clés étrangères.")
    lines.append("")

    # --- A. Listes présentes dans MCD_Valeurs ---
    col_table = df_val.columns[0]   # TABLE
    col_code = df_val.columns[1]    # code
    col_lib = df_val.columns[2]     # libelle
    col_def = df_val.columns[3]     # definition

    listes_avec_valeurs = sorted(df_val[col_table].dropna().unique())

    for liste_name in listes_avec_valeurs:
        rows = df_val[df_val[col_table] == liste_name]

        # Déterminer la longueur max du code pour dimensionner le VARCHAR
        max_code_len = max(rows[col_code].astype(str).str.len().max(), 3)
        code_size = max(max_code_len + 2, 5)  # Marge de sécurité

        lines.append(f"-- Liste : {liste_name}")
        lines.append(f"CREATE TABLE {schema}.{liste_name} (")
        lines.append(f"    code    VARCHAR({code_size}) PRIMARY KEY,")
        lines.append(f"    libelle VARCHAR(254) NOT NULL")
        lines.append(f");")
        lines.append("")

        # Insertion des valeurs
        for _, row in rows.iterrows():
            code = sql_escape(str(row[col_code]).strip())
            libelle = sql_escape(str(row[col_lib]).strip())
            lines.append(
                f"INSERT INTO {schema}.{liste_name} (code, libelle) "
                f"VALUES ('{code}', '{libelle}');"
            )
        lines.append("")

    # --- B. Listes référencées mais absentes de MCD_Valeurs ---
    # Extraire toutes les listes référencées dans les FK
    ref_lists = set()
    for rel in df_attrs['relation'].dropna().unique():
        match = re.match(r'REFERENCES\s+(l_\w+)\s*\(', rel.strip())
        if match:
            ref_lists.add(match.group(1))

    # Normaliser l_geoloc_class → l_geoloc_classe (coquille dans la matrice)
    if 'l_geoloc_class' in ref_lists:
        ref_lists.discard('l_geoloc_class')
        ref_lists.add('l_geoloc_classe')

    listes_manquantes = sorted(ref_lists - set(listes_avec_valeurs))

    if listes_manquantes:
        lines.append("-- Listes référencées en FK mais sans valeurs dans la matrice.")
        lines.append("-- Structure créée vide — à peupler manuellement ou via import.")
        lines.append("")
        for liste_name in listes_manquantes:
            lines.append(f"CREATE TABLE {schema}.{liste_name} (")
            lines.append(f"    code    VARCHAR(10) PRIMARY KEY,")
            lines.append(f"    libelle VARCHAR(254)")
            lines.append(f");")
            lines.append("")

    # Ajouter aussi l_adresse_etat, l_doc_type, l_organisme_type
    # qui sont dans MCD_Valeurs mais pas référencées — déjà créées ci-dessus

    return "\n".join(lines)


def _find_primary_key(table_name: str, obligatoire_unique_cols: List[str]) -> Optional[str]:
    """
    Identifie la colonne PK parmi les colonnes "Obligatoire UNIQUE" d'une table.

    Convention GraceTHD : chaque table t_XXX a un code principal XX_code
    qui sert de clé primaire. Les autres colonnes "Obligatoire UNIQUE"
    (comme XX_codeext, XX_nd_code, etc.) sont des contraintes UNIQUE séparées.

    Règles de sélection (par priorité) :
      1. Colonne nommée exactement {prefix}_code (ex: cb_code pour t_cable)
      2. Colonne se terminant par _code et contenant le préfixe de la table
      3. Première colonne "Obligatoire UNIQUE" en dernier recours

    Retourne le nom de la colonne PK, ou None si aucune n'est trouvée.
    """
    if not obligatoire_unique_cols:
        return None

    # S'il n'y en a qu'une, c'est forcément la PK
    if len(obligatoire_unique_cols) == 1:
        return obligatoire_unique_cols[0]

    # Extraire le préfixe de la table : t_cable → cb, t_adresse → ad, t_cableline → cl
    # On cherche la colonne XX_code où XX est le préfixe le plus court des colonnes
    prefixes = set()
    for col in obligatoire_unique_cols:
        parts = col.split('_')
        if len(parts) >= 2:
            prefixes.add(parts[0])

    # Chercher XX_code (exactement 2 parties : préfixe + "code")
    for col in obligatoire_unique_cols:
        parts = col.split('_')
        if len(parts) == 2 and parts[1] == 'code':
            return col

    # Fallback : première colonne
    return obligatoire_unique_cols[0]


def generate_table_sql(table_name: str, attrs: pd.DataFrame,
                       df_classes: pd.DataFrame, schema: str) -> str:
    """
    Génère le CREATE TABLE pour une table métier (t_*).

    Les colonnes géométriques sont ajoutées via AddGeometryColumn (PostGIS)
    plutôt que directement dans le CREATE TABLE, pour garantir
    l'enregistrement dans geometry_columns.

    Retourne le bloc SQL complet pour cette table.
    """
    lines = []

    # Récupérer la définition de la table depuis MCD_Classes
    classe_row = df_classes[
        df_classes['Nom de la table'].str.strip() == table_name
    ]
    table_def = ""
    if not classe_row.empty:
        table_def = sql_comment_text(classe_row.iloc[0].get('Définition', ''))

    lines.append(f"-- Table : {table_name}")
    if table_def:
        lines.append(f"-- {table_def[:100]}...")
    lines.append(f"CREATE TABLE {schema}.{table_name} (")

    # Séparer les colonnes normales et les colonnes géométriques
    col_defs = []       # Définitions de colonnes SQL
    geom_cols = []      # Colonnes géométriques (traitées à part)
    obligatoire_unique_cols = []  # Colonnes "Obligatoire UNIQUE" (PK + UNIQUE à trier)
    unique_cols = []    # Colonnes UNIQUE simples (hors PK)

    for _, attr in attrs.iterrows():
        attr_name = attr['attr_name']
        type_sql = attr['type_sql']
        contraintes = str(attr['contraintes']).strip().upper() if pd.notna(attr['contraintes']) else ""

        # Géométrie → traitement séparé via PostGIS
        geom_info = parse_geometry_type(type_sql)
        if geom_info:
            geom_cols.append((attr_name, geom_info[0], geom_info[1]))
            continue

        # Type PostgreSQL
        pg_type = map_type_to_pg(type_sql)
        if pg_type is None:
            continue

        # Construire la définition de colonne
        col_line = f"    {attr_name:<20} {pg_type}"

        # Contraintes NOT NULL
        if "OBLIGATOIRE" in contraintes:
            col_line += " NOT NULL"

        col_defs.append(col_line)

        # Identifier PK et UNIQUE
        # Convention GraceTHD : la PK est toujours XX_code (préfixe de la table)
        # Les autres colonnes "Obligatoire UNIQUE" sont des UNIQUE séparés
        if "OBLIGATOIRE" in contraintes and "UNIQUE" in contraintes:
            obligatoire_unique_cols.append(attr_name)
        elif "UNIQUE" in contraintes:
            unique_cols.append(attr_name)

    # Déterminer la PK : chercher la colonne XX_code principale
    # Ex : t_cable → cb_code, t_adresse → ad_code, t_zpbo → zp_code
    pk_col = _find_primary_key(table_name, obligatoire_unique_cols)

    # Les autres "Obligatoire UNIQUE" deviennent des UNIQUE séparés
    for col in obligatoire_unique_cols:
        if col != pk_col:
            unique_cols.append(col)

    # Assembler colonnes + contraintes en une seule liste séparée par des virgules
    all_parts = list(col_defs)

    # Clé primaire simple
    if pk_col:
        all_parts.append(f"    CONSTRAINT pk_{table_name} PRIMARY KEY ({pk_col})")

    # Contraintes UNIQUE
    for uc in unique_cols:
        all_parts.append(f"    CONSTRAINT uq_{table_name}_{uc} UNIQUE ({uc})")

    lines.append(",\n".join(all_parts))
    lines.append(");")
    lines.append("")

    # Ajout des colonnes géométriques via PostGIS
    for geom_name, geom_type, srid in geom_cols:
        lines.append(
            f"SELECT AddGeometryColumn('{schema}', '{table_name}', "
            f"'{geom_name}', {srid}, '{geom_type}', 2);"
        )
        # Contrainte NOT NULL sur la géométrie si marquée Obligatoire
        geom_attr = attrs[attrs['attr_name'] == geom_name].iloc[0]
        geom_contrainte = str(geom_attr['contraintes']).strip().upper() if pd.notna(geom_attr['contraintes']) else ""
        if "OBLIGATOIRE" in geom_contrainte:
            lines.append(
                f"ALTER TABLE {schema}.{table_name} "
                f"ALTER COLUMN {geom_name} SET NOT NULL;"
            )
    if geom_cols:
        lines.append("")

    return "\n".join(lines)


def generate_all_tables(v31: pd.DataFrame, df_classes: pd.DataFrame,
                        schema: str) -> str:
    """Génère les CREATE TABLE pour toutes les tables métier, dans le bon ordre."""
    lines = []
    lines.append("-- ============================================================================")
    lines.append("-- 3. TABLES MÉTIER (t_*)")
    lines.append("-- ============================================================================")
    lines.append("-- Les tables sont créées dans un ordre qui respecte les dépendances.")
    lines.append("-- Les colonnes géométriques sont ajoutées via PostGIS (AddGeometryColumn).")
    lines.append("")

    # Vérifier que toutes les tables sont dans l'ordre de création
    all_tables = sorted(v31['table_name'].unique())
    ordered = [t for t in TABLE_CREATION_ORDER if t in all_tables]
    missing = [t for t in all_tables if t not in ordered]
    if missing:
        ordered.extend(missing)  # Ajouter les tables inconnues à la fin

    for table_name in ordered:
        attrs = v31[v31['table_name'] == table_name].copy()
        if attrs.empty:
            continue
        lines.append(generate_table_sql(table_name, attrs, df_classes, schema))

    return "\n".join(lines)


def generate_foreign_keys(v31: pd.DataFrame, schema: str) -> str:
    """
    Génère toutes les clés étrangères (ALTER TABLE ... ADD CONSTRAINT FK).

    Les FK sont ajoutées après la création de toutes les tables pour éviter
    les problèmes de dépendances circulaires.
    """
    lines = []
    lines.append("-- ============================================================================")
    lines.append("-- 4. CLÉS ÉTRANGÈRES")
    lines.append("-- ============================================================================")
    lines.append("-- Ajoutées après toutes les tables pour éviter les dépendances circulaires.")
    lines.append("")

    fk_count = 0

    for _, attr in v31.iterrows():
        rel = attr['relation']
        if pd.isna(rel) or not str(rel).strip().startswith('REFERENCES'):
            continue

        table_name = attr['table_name']
        attr_name = attr['attr_name']
        rel_clean = str(rel).strip()

        # Parser : REFERENCES target_table(target_col)
        # Gérer les espaces : "REFERENCES t_noeud (nd_code)" ou "REFERENCES t_noeud(nd_code)"
        match = re.match(
            r'REFERENCES\s+([\w]+)\s*\(?\s*(\w+)\s*\)?',
            rel_clean
        )
        if not match:
            lines.append(f"-- ⚠️ Relation non parsée : {table_name}.{attr_name} → {rel_clean}")
            continue

        ref_table = match.group(1).strip()
        ref_col = match.group(2).strip()

        # Corriger la coquille l_geoloc_class → l_geoloc_classe
        if ref_table == 'l_geoloc_class':
            ref_table = 'l_geoloc_classe'

        fk_name = f"fk_{table_name}_{attr_name}"
        lines.append(
            f"ALTER TABLE {schema}.{table_name} "
            f"ADD CONSTRAINT {fk_name} "
            f"FOREIGN KEY ({attr_name}) "
            f"REFERENCES {schema}.{ref_table}({ref_col});"
        )
        fk_count += 1

    lines.append("")
    lines.append(f"-- Total : {fk_count} clés étrangères créées")
    lines.append("")

    return "\n".join(lines)


def generate_indexes(v31: pd.DataFrame, schema: str) -> str:
    """
    Génère les index :
    - Index spatiaux GiST sur toutes les colonnes géométriques
    - Index B-tree sur les colonnes de clés étrangères (performance des JOIN)
    """
    lines = []
    lines.append("-- ============================================================================")
    lines.append("-- 5. INDEX")
    lines.append("-- ============================================================================")
    lines.append("")

    # --- Index spatiaux ---
    lines.append("-- 5a. Index spatiaux (GiST) sur les colonnes géométriques")
    lines.append("")

    for _, attr in v31.iterrows():
        geom_info = parse_geometry_type(attr['type_sql'])
        if geom_info:
            tbl = attr['table_name']
            col = attr['attr_name']
            lines.append(
                f"CREATE INDEX idx_{tbl}_{col}_gist "
                f"ON {schema}.{tbl} USING GIST ({col});"
            )

    lines.append("")

    # --- Index sur les clés étrangères ---
    lines.append("-- 5b. Index B-tree sur les colonnes FK (performance des jointures)")
    lines.append("")

    for _, attr in v31.iterrows():
        rel = attr['relation']
        if pd.isna(rel) or not str(rel).strip().startswith('REFERENCES'):
            continue

        tbl = attr['table_name']
        col = attr['attr_name']

        # Ne pas créer d'index si la colonne est déjà PK ou UNIQUE
        contraintes = str(attr['contraintes']).strip().upper() if pd.notna(attr['contraintes']) else ""
        if "UNIQUE" in contraintes:
            continue

        lines.append(
            f"CREATE INDEX idx_{tbl}_{col} "
            f"ON {schema}.{tbl} ({col});"
        )

    lines.append("")

    return "\n".join(lines)


def generate_comments(v31: pd.DataFrame, df_classes: pd.DataFrame,
                      schema: str) -> str:
    """
    Génère les COMMENT ON pour documenter chaque table et chaque colonne.

    Cette documentation est accessible via \\dt+ et \\d+ dans psql,
    ou via les outils d'administration (pgAdmin, DBeaver, etc.).
    """
    lines = []
    lines.append("-- ============================================================================")
    lines.append("-- 6. COMMENTAIRES DE DOCUMENTATION")
    lines.append("-- ============================================================================")
    lines.append("-- Chaque table et colonne est documentée avec sa définition officielle.")
    lines.append("-- Visible via \\dt+ et \\d+ dans psql ou dans pgAdmin/DBeaver.")
    lines.append("")

    # --- Commentaires sur les tables ---
    lines.append("-- 6a. Commentaires sur les tables")
    lines.append("")

    for _, row in df_classes.iterrows():
        tbl = str(row['Nom de la table']).strip()
        definition = sql_comment_text(row.get('Définition', ''))
        spatial = str(row.get('Spatiale ?', '')).strip()
        classe = str(row.get('Nom de la classe', '')).strip()

        if definition:
            comment = f"{classe} — {definition}"
            if spatial:
                comment += f" [Spatial: {spatial}]"
            lines.append(
                f"COMMENT ON TABLE {schema}.{tbl} IS "
                f"'{sql_escape(comment)}';"
            )

    lines.append("")

    # --- Commentaires sur les colonnes ---
    lines.append("-- 6b. Commentaires sur les colonnes")
    lines.append("")

    for _, attr in v31.iterrows():
        tbl = attr['table_name']
        col = attr['attr_name']
        definition = sql_comment_text(attr.get('definition', ''))

        if definition:
            lines.append(
                f"COMMENT ON COLUMN {schema}.{tbl}.{col} IS "
                f"'{definition}';"
            )

    lines.append("")

    return "\n".join(lines)


def generate_footer() -> str:
    """Pied du script SQL : COMMIT de la transaction."""
    return """
-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================

COMMIT;

-- Pour vérifier l'installation :
--   SELECT table_name FROM information_schema.tables
--   WHERE table_schema = '""" + SCHEMA + """' ORDER BY table_name;
--
--   SELECT f_table_name, f_geometry_column, type, srid
--   FROM geometry_columns
--   WHERE f_table_schema = '""" + SCHEMA + """';
"""


# =============================================================================
# POINT D'ENTRÉE
# =============================================================================

def main():
    """
    Point d'entrée principal.
    Lit l'Excel, génère le SQL et l'écrit dans un fichier.
    """
    # Chemin vers l'Excel (argument ou valeur par défaut)
    if len(sys.argv) > 1:
        excel_path = sys.argv[1]
    else:
        excel_path = "An_1b_-_grilles_de_remplissage.xlsx"

    # Chemin de sortie SQL
    output_path = "gracethd_v31_schema.sql"

    # Charger les données
    df_classes, v31, df_val = load_excel(excel_path)

    # Générer chaque section
    print("[INFO] Génération du SQL...")
    sections = [
        generate_header(SCHEMA),
        generate_lookup_tables(df_val, v31, SCHEMA),
        generate_all_tables(v31, df_classes, SCHEMA),
        generate_foreign_keys(v31, SCHEMA),
        generate_indexes(v31, SCHEMA),
        generate_comments(v31, df_classes, SCHEMA),
        generate_footer(),
    ]

    # Écrire le fichier SQL
    full_sql = "\n".join(sections)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(full_sql)

    # Statistiques
    nb_tables_metier = len(v31['table_name'].unique())
    nb_listes = len(df_val[df_val.columns[0]].dropna().unique())
    nb_fk = sum(1 for _, a in v31.iterrows()
                if pd.notna(a['relation']) and str(a['relation']).strip().startswith('REFERENCES'))
    nb_geom = sum(1 for _, a in v31.iterrows()
                  if parse_geometry_type(a['type_sql']) is not None)

    print(f"[OK] Fichier généré : {output_path}")
    print(f"     → {nb_tables_metier} tables métier")
    print(f"     → {nb_listes} tables de listes (avec valeurs)")
    print(f"     → {len(v31)} colonnes")
    print(f"     → {nb_geom} colonnes géométriques (SRID {SRID})")
    print(f"     → {nb_fk} clés étrangères")


if __name__ == "__main__":
    main()
