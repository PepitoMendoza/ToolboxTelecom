-- ============================================================================
-- Script de création du schéma PostgreSQL/PostGIS GraceTHD v3.1
-- ============================================================================
--
-- Schéma    : gracethd3_1_raw
-- SRID      : 2154 (Lambert 93)
-- Généré le : 2026-03-24 17:28
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

CREATE SCHEMA IF NOT EXISTS gracethd3_1_raw;

-- PostGIS pour les types géométriques et les fonctions spatiales
CREATE EXTENSION IF NOT EXISTS postgis;

-- Permettre l'utilisation du schéma par défaut dans les requêtes
SET search_path TO gracethd3_1_raw, public;


-- ============================================================================
-- 2. TABLES DE LISTES DE VALEURS (domaines l_*)
-- ============================================================================
-- Chaque liste contient un code (clé primaire) et un libellé.
-- Ces tables servent de domaines de valeurs pour les clés étrangères.

-- Liste : l_adresse_etat
CREATE TABLE gracethd3_1_raw.l_adresse_etat (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('CI', 'CIBLE');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('RD', 'RACCORDABLE DEMANDE');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('RC', 'RAD EN COURS DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('SI', 'SIGNE');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('EC', 'EN COURS DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('DE', 'DEPLOYE');
INSERT INTO gracethd3_1_raw.l_adresse_etat (code, libelle) VALUES ('AB', 'ABANDONNE');

-- Liste : l_avancement
CREATE TABLE gracethd3_1_raw.l_avancement (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('E', 'EXISTANT');
INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('C', 'A CREER');
INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('T', 'TRAVAUX');
INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('S', 'EN SERVICE');
INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('H', 'HORS SERVICE');
INSERT INTO gracethd3_1_raw.l_avancement (code, libelle) VALUES ('A', 'ABANDONNE');

-- Liste : l_baie_type
CREATE TABLE gracethd3_1_raw.l_baie_type (
    code    VARCHAR(7) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_baie_type (code, libelle) VALUES ('BAIE', 'BAIE');
INSERT INTO gracethd3_1_raw.l_baie_type (code, libelle) VALUES ('FERME', 'FERME');

-- Liste : l_bool
CREATE TABLE gracethd3_1_raw.l_bool (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_bool (code, libelle) VALUES ('0', 'FAUX');
INSERT INTO gracethd3_1_raw.l_bool (code, libelle) VALUES ('1', 'VRAI');

-- Liste : l_bp_type_log
CREATE TABLE gracethd3_1_raw.l_bp_type_log (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_bp_type_log (code, libelle) VALUES ('BPE', 'BOITIER PROTECTION EPISSURE');
INSERT INTO gracethd3_1_raw.l_bp_type_log (code, libelle) VALUES ('BPI', 'BOITIER PIED IMMEUBLE');
INSERT INTO gracethd3_1_raw.l_bp_type_log (code, libelle) VALUES ('PTO', 'POINT DE TERMINAISON OPTIQUE');
INSERT INTO gracethd3_1_raw.l_bp_type_log (code, libelle) VALUES ('PBO', 'POINT DE BRANCHEMENT OPTIQUE');
INSERT INTO gracethd3_1_raw.l_bp_type_log (code, libelle) VALUES ('DTI', 'DISPOSITIF DE TERMINAISON INTERIEUR OPTIQUE');

-- Liste : l_bp_type_phy
CREATE TABLE gracethd3_1_raw.l_bp_type_phy (
    code    VARCHAR(6) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B006', 'BPE 6FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B012', 'BPE 12FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B024', 'BPE 24FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B036', 'BPE 36FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B048', 'BPE 48FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B072', 'BPE 72FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B096', 'BPE 96FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B144', 'BPE 144FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B288', 'BPE 288FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B336', 'BPE 366FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B432', 'BPE 432FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B576', 'BPE 576FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B720', 'BPE 720FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('B864', 'BPE 864FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('COF', 'COFFRET');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('DTI1', 'DTIO 1FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('DTI2', 'DTIO 2FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('DTI4', 'DTIO 4FO');
INSERT INTO gracethd3_1_raw.l_bp_type_phy (code, libelle) VALUES ('AUTR', 'AUTRE');

-- Liste : l_cable_chem_type_log
CREATE TABLE gracethd3_1_raw.l_cable_chem_type_log (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('CX', 'COLLECTE TRANSPORT DISTRIBUTION');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('CO', 'COLLECTE');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('CT', 'COLLECTE TRANSPORT');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('CD', 'COLLECTE DISTRIBUTION');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('TD', 'TRANSPORT DISTRIBUTION');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('TR', 'TRANSPORT');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('DI', 'DISTRIBUTION');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('RA', 'RACCORDEMENT FINAL');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('BM', 'BOUCLE METROPOLITAINE');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('LH', 'LONGUE DISTANCE (LONG HAUL)');
INSERT INTO gracethd3_1_raw.l_cable_chem_type_log (code, libelle) VALUES ('NC', 'NON COMMUNIQUE');

-- Liste : l_cable_type
CREATE TABLE gracethd3_1_raw.l_cable_type (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_cable_type (code, libelle) VALUES ('C', 'CABLE');
INSERT INTO gracethd3_1_raw.l_cable_type (code, libelle) VALUES ('B', 'BREAKOUT');
INSERT INTO gracethd3_1_raw.l_cable_type (code, libelle) VALUES ('J', 'JARRETIERE');

-- Liste : l_cassette_type
CREATE TABLE gracethd3_1_raw.l_cassette_type (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_cassette_type (code, libelle) VALUES ('P', 'PLATEAU DE LOVAGE BPE');
INSERT INTO gracethd3_1_raw.l_cassette_type (code, libelle) VALUES ('E', 'EPISSURE');
INSERT INTO gracethd3_1_raw.l_cassette_type (code, libelle) VALUES ('S', 'SPLITTER');
INSERT INTO gracethd3_1_raw.l_cassette_type (code, libelle) VALUES ('C', 'CONNECTEUR');

-- Liste : l_doc_type
CREATE TABLE gracethd3_1_raw.l_doc_type (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DIG', 'DOSSIER D INGENIERIE : REGLES D INGENIERIE UTILISEES');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('ETU', 'RAPPORT D ETUDE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('PSI', 'PLAN DE SITUATION, SYNOPTIQUE GEOGRAPHIQUE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('PPH', 'PLAN DE PHASAGE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('PCB', 'PLAN DE CABLAGE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('PMQ', 'PLAN DE MASQUE OU FICHE FOA');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DPO', 'DOSSIER APPUIS AERIENS');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('FOT', 'PHOTO');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('PGC', 'PLAN DE GENIE CIVIL');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DLV', 'DOSSIER DE LEVE OU D INVESTIGATIONS COMPLEMENTAIRES');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('SGC', 'DETAIL OU SCHEMA DE GENIE CIVIL');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DPI', 'DOSSIER DE PIQUETAGE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DBL', 'DOSSIER DE RELEVE BOITES AUX LETTRES');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('KRV', 'REGLEMENT DE VOIRIE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CPV', 'PERMISSION OU AUTORISATION DE VOIRIE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DTT', 'DT EMISES DANS LE CADRE DU PROJET DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DIT', 'DICT EMISES DANS LE CADRE DU PROJET DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DAM', 'DIAGNOSTIC AMIANTE ENROBE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CIN', 'CONTRAT OU CONVENTION DE LOCATION/CESSION/ACHAT/OCCUPATION D INFRASTRUCTURE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CMU', 'CONTRAT OU CONVENTION DE CO-CONSTRUCTION OU MUTUALISATION DE TRAVAUX');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DIP', 'DOSSIER D IMPLANTATION (SRO, NRO, BPI…)');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('SOP', 'SYNOPTIQUE OPTIQUE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('SBP', 'PLAN DE BOITE, OU AUTRE ELEMENT DE BRANCHEMENT PASSIF');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('SRA', 'SCHEMA DE RACCORDEMENT (BAIE, ARMOIRE, REPARTITEUR…)');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('KEQ', 'DOCUMENTATION TECHNIQUE D EQUIPEMENT');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CIM', 'CONVENTION THD IMMEUBLE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CIS', 'CONVENTION CADRE BAILLEUR SOCIAL');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('CDS', 'REGLEMENT DE SERVICE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('COC', 'AUTRE CONVENTION D OCCUPATION EMPRISE PRIVEE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('MRF', 'MESURE DE REFLECTOMETRIE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('MFX', 'TEST D ETANCHEITE DE FOURREAUX ET/OU TESTS DE MANDRINAGE, AIGUILLAGE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('RGC', 'PV DE RECEPTION GENIE CIVIL');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DIF', 'DOSSIER INFRASTRUCTURE D ACCUEIL');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DCB', 'DOSSIER DE CABLAGE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DOP', 'DOSSIER OPTIQUE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DPR', 'DOSSIER DE PROJET');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DLG', 'DOSSIER DE LIVRABLES GRACETHD');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DCI', 'DOSSIER DE COMMANDE POUR LOCATION/OCCUPATION D INFRASTRUCTURE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DCS', 'DOSSIER DE CREATION DE SITE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DRS', 'DOSSIER DE RACCORDEMENT DE SITE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('KPL', 'PLAN LOCAL D URBANISME');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('RFR', 'FICHE DE RECETTE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('RVR', 'PV DE RECEPTION DE VOIRIE');
INSERT INTO gracethd3_1_raw.l_doc_type (code, libelle) VALUES ('DTA', 'DIAGNOSTIC TECHNIQUE AMIANTE POUR UN IMMEUBLE');

-- Liste : l_etat
CREATE TABLE gracethd3_1_raw.l_etat (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_etat (code, libelle) VALUES ('HS', 'A CHANGER');
INSERT INTO gracethd3_1_raw.l_etat (code, libelle) VALUES ('ME', 'MAUVAIS ETAT');
INSERT INTO gracethd3_1_raw.l_etat (code, libelle) VALUES ('OK', 'BON ETAT');
INSERT INTO gracethd3_1_raw.l_etat (code, libelle) VALUES ('NC', 'NON CONCERNE');

-- Liste : l_fo_color
CREATE TABLE gracethd3_1_raw.l_fo_color (
    code    VARCHAR(6) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1', 'ROUGE (R)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('2', 'BLEU (BL)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('3', 'VERT (VE)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('4', 'JAUNE (J)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('5', 'VIOLET (V)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('6', 'BLANC (B)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('7', 'ORANGE (OR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('8', 'GRIS (GR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('9', 'MARRON (BR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('10', 'NOIR (N)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('11', 'TURQUOISE (TU)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('12', 'ROSE (RS)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.1', 'BLEU (BL)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.2', 'ORANGE (OR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.3', 'VERT (VE)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.4', 'MARRON (BR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.5', 'GRIS (GR)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.6', 'BLANC (B)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.7', 'ROUGE (R)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.8', 'NOIR (N)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.9', 'VIOLET (V)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.10', 'JAUNE (J)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.11', 'ROSE (RS)');
INSERT INTO gracethd3_1_raw.l_fo_color (code, libelle) VALUES ('1.12', 'TURQUOISE (TU)');

-- Liste : l_fo_type
CREATE TABLE gracethd3_1_raw.l_fo_type (
    code    VARCHAR(8) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G651', 'G651');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G652', 'G652');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G652A', 'G652A');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G652B', 'G652B');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G652C', 'G652C');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G652D', 'G652D');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G653', 'G653');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G654', 'G654');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G655', 'G655');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G656', 'G656');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657', 'G657');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657A', 'G657A');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657A1', 'G657A1');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657A2', 'G657A2');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657A3', 'G657A3');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657B', 'G657B');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657B1', 'G657B1');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657B2', 'G657B2');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('G657B3', 'G657B3');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OM1', 'OM1');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OM2', 'OM2');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OM3', 'OM3');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OM4', 'OM4');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OS1', 'OS1');
INSERT INTO gracethd3_1_raw.l_fo_type (code, libelle) VALUES ('OS2', 'OS2');

-- Liste : l_geoloc_classe
CREATE TABLE gracethd3_1_raw.l_geoloc_classe (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_geoloc_classe (code, libelle) VALUES ('A', 'CLASSE DE PRECISION A');
INSERT INTO gracethd3_1_raw.l_geoloc_classe (code, libelle) VALUES ('AP', 'CLASSE DE PRECISION A, EN PLANIMETRIE UNIQUEMENT');
INSERT INTO gracethd3_1_raw.l_geoloc_classe (code, libelle) VALUES ('B', 'CLASSE DE PRECISION B');
INSERT INTO gracethd3_1_raw.l_geoloc_classe (code, libelle) VALUES ('C', 'CLASSE DE PRECISION C');

-- Liste : l_implantation
CREATE TABLE gracethd3_1_raw.l_implantation (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('0', 'AERIEN TELECOM');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('1', 'AERIEN ENERGIE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('2', 'FACADE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('3', 'IMMEUBLE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('4', 'PLEINE TERRE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('5', 'CANIVEAU');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('6', 'GALERIE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('7', 'CONDUITE');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('8', 'EGOUT');
INSERT INTO gracethd3_1_raw.l_implantation (code, libelle) VALUES ('9', 'SPECIFIQUE');

-- Liste : l_local_type_log
CREATE TABLE gracethd3_1_raw.l_local_type_log (
    code    VARCHAR(6) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('RES', 'RESIDENTIEL');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('TEC', 'TECHNIQUE');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('PRO', 'PROFESSIONNEL');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('ENT', 'ENTREPRISE');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('PUB', 'LOCAUX PUBLICS');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('OPE', 'OPERATEUR');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('OBJ', 'OBJET CONNECTE A LA FIBRE');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('NRO', 'NŒUD RACCORDEMENT OPTIQUE');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('SRO', 'SOUS-REPARTITEUR OPTIQUE');
INSERT INTO gracethd3_1_raw.l_local_type_log (code, libelle) VALUES ('FTTH', 'RESIDENTIEL OU PROFESSIONNEL');

-- Liste : l_nro_etat
CREATE TABLE gracethd3_1_raw.l_nro_etat (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_nro_etat (code, libelle) VALUES ('PL', 'PLANIFIE');
INSERT INTO gracethd3_1_raw.l_nro_etat (code, libelle) VALUES ('EC', 'EN COURS DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_nro_etat (code, libelle) VALUES ('DP', 'DEPLOYE');
INSERT INTO gracethd3_1_raw.l_nro_etat (code, libelle) VALUES ('AB', 'ABANDONNE');

-- Liste : l_organisme_type
CREATE TABLE gracethd3_1_raw.l_organisme_type (
    code    VARCHAR(6) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('BAP', 'BAILLEUR PRIVE');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('BAPU', 'BAILLEUR PUBLIC');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('CAS', 'CABINET SYNDIC');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('SCI', 'SCI');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('SBE', 'SYNDIC BENEVOLE');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('UPR', 'UNIPROPRIETAIRE');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('ASL', 'ASSO SYNDIC LIBRE');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('PRM', 'PROMOTEUR');
INSERT INTO gracethd3_1_raw.l_organisme_type (code, libelle) VALUES ('ASP', 'AUTRE SYNDIC PRIVE');

-- Liste : l_pointaccueil_nature
CREATE TABLE gracethd3_1_raw.l_pointaccueil_nature (
    code    VARCHAR(7) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A1', 'CHAMBRE A1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A2', 'CHAMBRE A2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A3', 'CHAMBRE A3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A4', 'CHAMBRE A4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A10', 'CHAMBRE A10');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A11', 'CHAMBRE A11');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A12', 'CHAMBRE A12');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A13', 'CHAMBRE A13');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A14', 'CHAMBRE A14');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A15', 'CHAMBRE A15');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A16', 'CHAMBRE A16');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A17', 'CHAMBRE A17');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('A18', 'CHAMBRE A18');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('B1', 'CHAMBRE B1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('B2', 'CHAMBRE B2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('B3', 'CHAMBRE B3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('B4', 'CHAMBRE B4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('C1', 'CHAMBRE C1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('C2', 'CHAMBRE C2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('C3', 'CHAMBRE C3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('C4', 'CHAMBRE C4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D1', 'CHAMBRE D1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D1C', 'CHAMBRE D1C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D1T', 'CHAMBRE D1T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D2', 'CHAMBRE D2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D2C', 'CHAMBRE D2C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D2T', 'CHAMBRE D2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D3', 'CHAMBRE D3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D3C', 'CHAMBRE D3C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D3T', 'CHAMBRE D3T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D4', 'CHAMBRE D4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D4C', 'CHAMBRE D4C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D4T', 'CHAMBRE D4T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D5', 'CHAMBRE D5');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D5C', 'CHAMBRE D5C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D6', 'CHAMBRE D6');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D6C', 'CHAMBRE D6C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D11', 'CHAMBRE D11');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D12', 'CHAMBRE D12');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D13', 'CHAMBRE D13');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('D14', 'CHAMBRE D14');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('E1', 'CHAMBRE E1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('E2', 'CHAMBRE E2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('E3', 'CHAMBRE E3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('E4', 'CHAMBRE E4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('J2C', 'CHAMBRE J2C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('J2CR', 'CHAMBRE J2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K1C', 'CHAMBRE K1C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K1CR', 'CHAMBRE K1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K1T', 'CHAMBRE K1T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K2C', 'CHAMBRE K2C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K2CR', 'CHAMBRE K2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K2T', 'CHAMBRE K2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K3C', 'CHAMBRE K3C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K3CR', 'CHAMBRE K3C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('K3T', 'CHAMBRE K3T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L0T', 'CHAMBRE L0T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L0TR', 'CHAMBRE L0T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L1C', 'CHAMBRE L1C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L1T', 'CHAMBRE L1T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L1TR', 'CHAMBRE L1T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L2C', 'CHAMBRE L2C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L2T', 'CHAMBRE L2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L2TR', 'CHAMBRE L2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L3C', 'CHAMBRE L3C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L3T', 'CHAMBRE L3T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L3TR', 'CHAMBRE L3T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L4C', 'CHAMBRE L4C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L4T', 'CHAMBRE L4T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L4TR', 'CHAMBRE L4T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L5C', 'CHAMBRE L5C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L5T', 'CHAMBRE L5T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L5TR', 'CHAMBRE L5T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L6T', 'CHAMBRE L6T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('L6TR', 'CHAMBRE L6T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M1C', 'CHAMBRE M1C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M1CR', 'CHAMBRE M1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M2T', 'CHAMBRE M2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M2TR', 'CHAMBRE M2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M3C', 'CHAMBRE M3C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('M3CR', 'CHAMBRE M3C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P1C', 'CHAMBRE P1C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P1CR', 'CHAMBRE P1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P1T', 'CHAMBRE P1T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P1TR', 'CHAMBRE P1T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P2C', 'CHAMBRE P2C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P2CR', 'CHAMBRE P2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P2T', 'CHAMBRE P2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P2TR', 'CHAMBRE P2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P3C', 'CHAMBRE P3C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P3T', 'CHAMBRE P3T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P4C', 'CHAMBRE P4C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P4T', 'CHAMBRE P4T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P5C', 'CHAMBRE P5C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P5T', 'CHAMBRE P5T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P6C', 'CHAMBRE P6C');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('P6T', 'CHAMBRE P6T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('R1T', 'CHAMBRE R1T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('R2T', 'CHAMBRE R2T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('R3T', 'CHAMBRE R3T');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S1', 'CHAMBRE S1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S2', 'CHAMBRE S2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S3', 'CHAMBRE S3');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S4', 'CHAMBRE S4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S5', 'CHAMBRE S5');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S6', 'CHAMBRE S6');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S6bis', 'CHAMBRE S6bis');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('S7', 'CHAMBRE S7');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU1', 'CHAMBRE TU1');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU2', 'CHAMBRE TU2');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU4', 'CHAMBRE TU4');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU6', 'CHAMBRE TU6');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU8', 'CHAMBRE TU8');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TU10', 'CHAMBRE TU10');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('OHN', 'OUVRAGE HORS NORMES');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('PBOI', 'POTEAU BOIS');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('PBET', 'POTEAU BETON');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('PCMP', 'POTEAU COMPOSITE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('PMET', 'POTEAU METAL');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('PIND', 'POTEAU INDETERMINE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('POTL', 'POTELET');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('BOU', 'BOUCHON');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('REG', 'REGARD 30X30');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('R40', 'REGARD 40X40');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('BAL', 'BALCON');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('CRO', 'CROCHET');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('FAI', 'FAITIERE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('STR', 'SOUTERRAIN');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('SSO', 'SOUS-SOL');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('TRA', 'TRAVERSE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('Y', 'SITE MANCHONNAGE Y');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('SITE', 'SITE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_nature (code, libelle) VALUES ('IND', 'INDETERMINE');

-- Liste : l_pointaccueil_type_phy
CREATE TABLE gracethd3_1_raw.l_pointaccueil_type_phy (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('APP', 'APPUI');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('CHB', 'CHAMBRE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('FCD', 'ANCRAGE FACADE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('IMM', 'IMMEUBLE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('ZZZ', 'AUTRE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('ADR', 'ARMOIRE DE RUE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('BAT', 'BATIMENT');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('CHV', 'CHAMBRE VISITABLE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('COF', 'COFFRET');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('SHE', 'SHELTER');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('LOG', 'LOGETTE ELECTRIQUE');
INSERT INTO gracethd3_1_raw.l_pointaccueil_type_phy (code, libelle) VALUES ('STR', 'CONSTRUCTION SOUTERRAINE');

-- Liste : l_position_fonction
CREATE TABLE gracethd3_1_raw.l_position_fonction (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('CO', 'CONNECTEUR');
INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('EP', 'EPISSURE');
INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('PI', 'PIGTAIL');
INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('AT', 'ATTENTE');
INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('PA', 'PASSAGE');
INSERT INTO gracethd3_1_raw.l_position_fonction (code, libelle) VALUES ('MA', 'MANŒUVRE');

-- Liste : l_position_type
CREATE TABLE gracethd3_1_raw.l_position_type (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CEA', 'CONNECTEUR E2000-APC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CEU', 'CONNECTEUR E2000-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CEP', 'CONNECTEUR E2000-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CFA', 'CONNECTEUR FC-APC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CFU', 'CONNECTEUR FC-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CFP', 'CONNECTEUR FC-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CLA', 'CONNECTEUR LC-APC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CLU', 'CONNECTEUR LC-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CLP', 'CONNECTEUR LC-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CMA', 'CONNECTEUR MU-APC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CMU', 'CONNECTEUR MU-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CMP', 'CONNECTEUR MU-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CSA', 'CONNECTEUR SC-APC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CSU', 'CONNECTEUR SC-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CSP', 'CONNECTEUR SC-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CTU', 'CONNECTEUR ST-UPC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CTP', 'CONNECTEUR ST-PC');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('CPO', 'CONNECTEUR MT MPO');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('SFU', 'SOUDURE FUSION');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('SME', 'SOUDURE MECANIQUE');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('LC', 'LOVE CASSETTE');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('LB', 'LOVE EN FOND DE BOITE');
INSERT INTO gracethd3_1_raw.l_position_type (code, libelle) VALUES ('TS', 'TIROIR DE STOCKAGE');

-- Liste : l_propriete
CREATE TABLE gracethd3_1_raw.l_propriete (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('CST', 'CONSTRUCTION');
INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('RAC', 'RACHAT');
INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('CES', 'CESSION');
INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('IRU', 'IRU');
INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('LOC', 'LOCATION');
INSERT INTO gracethd3_1_raw.l_propriete (code, libelle) VALUES ('OCC', 'OCCUPATION');

-- Liste : l_ptech_nature
CREATE TABLE gracethd3_1_raw.l_ptech_nature (
    code    VARCHAR(7) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A1', 'CHAMBRE A1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A2', 'CHAMBRE A2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A3', 'CHAMBRE A3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A4', 'CHAMBRE A4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A10', 'CHAMBRE A10');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A11', 'CHAMBRE A11');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A12', 'CHAMBRE A12');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A13', 'CHAMBRE A13');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A14', 'CHAMBRE A14');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A15', 'CHAMBRE A15');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A16', 'CHAMBRE A16');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A17', 'CHAMBRE A17');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('A18', 'CHAMBRE A18');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('B1', 'CHAMBRE B1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('B2', 'CHAMBRE B2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('B3', 'CHAMBRE B3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('B4', 'CHAMBRE B4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('C1', 'CHAMBRE C1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('C2', 'CHAMBRE C2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('C3', 'CHAMBRE C3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('C4', 'CHAMBRE C4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D1', 'CHAMBRE D1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D1C', 'CHAMBRE D1C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D1T', 'CHAMBRE D1T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D2', 'CHAMBRE D2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D2C', 'CHAMBRE D2C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D2T', 'CHAMBRE D2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D3', 'CHAMBRE D3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D3C', 'CHAMBRE D3C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D3T', 'CHAMBRE D3T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D4', 'CHAMBRE D4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D4C', 'CHAMBRE D4C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D4T', 'CHAMBRE D4T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D5', 'CHAMBRE D5');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D5C', 'CHAMBRE D5C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D6', 'CHAMBRE D6');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D6C', 'CHAMBRE D6C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D11', 'CHAMBRE D11');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D12', 'CHAMBRE D12');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D13', 'CHAMBRE D13');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('D14', 'CHAMBRE D14');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('E1', 'CHAMBRE E1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('E2', 'CHAMBRE E2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('E3', 'CHAMBRE E3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('E4', 'CHAMBRE E4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('J2C', 'CHAMBRE J2C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('J2CR', 'CHAMBRE J2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K1C', 'CHAMBRE K1C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K1CR', 'CHAMBRE K1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K1T', 'CHAMBRE K1T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K2C', 'CHAMBRE K2C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K2CR', 'CHAMBRE K2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K2T', 'CHAMBRE K2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K3C', 'CHAMBRE K3C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K3CR', 'CHAMBRE K3C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('K3T', 'CHAMBRE K3T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L0T', 'CHAMBRE L0T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L0TR', 'CHAMBRE L0T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L1C', 'CHAMBRE L1C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L1T', 'CHAMBRE L1T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L1TR', 'CHAMBRE L1T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L2C', 'CHAMBRE L2C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L2T', 'CHAMBRE L2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L2TR', 'CHAMBRE L2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L3C', 'CHAMBRE L3C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L3T', 'CHAMBRE L3T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L3TR', 'CHAMBRE L3T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L4C', 'CHAMBRE L4C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L4T', 'CHAMBRE L4T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L4TR', 'CHAMBRE L4T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L5C', 'CHAMBRE L5C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L5T', 'CHAMBRE L5T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L5TR', 'CHAMBRE L5T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L6T', 'CHAMBRE L6T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('L6TR', 'CHAMBRE L6T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M1C', 'CHAMBRE M1C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M1CR', 'CHAMBRE M1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M2T', 'CHAMBRE M2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M2TR', 'CHAMBRE M2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M3C', 'CHAMBRE M3C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('M3CR', 'CHAMBRE M3C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P1C', 'CHAMBRE P1C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P1CR', 'CHAMBRE P1C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P1T', 'CHAMBRE P1T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P1TR', 'CHAMBRE P1T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P2C', 'CHAMBRE P2C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P2CR', 'CHAMBRE P2C REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P2T', 'CHAMBRE P2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P2TR', 'CHAMBRE P2T REHAUSSEE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P3C', 'CHAMBRE P3C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P3T', 'CHAMBRE P3T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P4C', 'CHAMBRE P4C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P4T', 'CHAMBRE P4T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P5C', 'CHAMBRE P5C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P5T', 'CHAMBRE P5T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P6C', 'CHAMBRE P6C');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('P6T', 'CHAMBRE P6T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('R1T', 'CHAMBRE R1T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('R2T', 'CHAMBRE R2T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('R3T', 'CHAMBRE R3T');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S1', 'CHAMBRE S1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S2', 'CHAMBRE S2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S3', 'CHAMBRE S3');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S4', 'CHAMBRE S4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S5', 'CHAMBRE S5');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S6', 'CHAMBRE S6');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S6bis', 'CHAMBRE S6bis');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('S7', 'CHAMBRE S7');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU1', 'CHAMBRE TU1');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU2', 'CHAMBRE TU2');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU4', 'CHAMBRE TU4');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU6', 'CHAMBRE TU6');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU8', 'CHAMBRE TU8');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TU10', 'CHAMBRE TU10');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('OHN', 'OUVRAGE HORS NORMES');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('PBOI', 'POTEAU BOIS');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('PBET', 'POTEAU BETON');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('PCMP', 'POTEAU COMPOSITE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('PMET', 'POTEAU METAL');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('PIND', 'POTEAU INDETERMINE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('POTL', 'POTELET');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('BOU', 'BOUCHON');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('REG', 'REGARD 30X30');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('R40', 'REGARD 40X40');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('BAL', 'BALCON');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('CRO', 'CROCHET');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('FAI', 'FAITIERE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('STR', 'SOUTERRAIN');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('SSO', 'SOUS-SOL');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('TRA', 'TRAVERSE');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('Y', 'SITE MANCHONNAGE Y');
INSERT INTO gracethd3_1_raw.l_ptech_nature (code, libelle) VALUES ('IND', 'INDETERMINE');

-- Liste : l_ptech_type_phy
CREATE TABLE gracethd3_1_raw.l_ptech_type_phy (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_ptech_type_phy (code, libelle) VALUES ('A', 'APPUI');
INSERT INTO gracethd3_1_raw.l_ptech_type_phy (code, libelle) VALUES ('C', 'CHAMBRE');
INSERT INTO gracethd3_1_raw.l_ptech_type_phy (code, libelle) VALUES ('F', 'ANCRAGE FACADE');
INSERT INTO gracethd3_1_raw.l_ptech_type_phy (code, libelle) VALUES ('I', 'IMMEUBLE');
INSERT INTO gracethd3_1_raw.l_ptech_type_phy (code, libelle) VALUES ('Z', 'AUTRE');

-- Liste : l_reference_type
CREATE TABLE gracethd3_1_raw.l_reference_type (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('BA', 'BAIE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('BP', 'ELEMENT DE BRANCHEMENT PASSIF');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('CA', 'CABLE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('CS', 'CASSETTE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('CT', 'COUPE TYPE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('EQ', 'EQUIPEMENT');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('PT', 'POINT TECHNIQUE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('ST', 'SITE');
INSERT INTO gracethd3_1_raw.l_reference_type (code, libelle) VALUES ('TI', 'TIROIR');

-- Liste : l_site_type_log
CREATE TABLE gracethd3_1_raw.l_site_type_log (
    code    VARCHAR(8) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_site_type_log (code, libelle) VALUES ('CLIENT', 'SITES HEBERGEANT DES UTILISATEURS');
INSERT INTO gracethd3_1_raw.l_site_type_log (code, libelle) VALUES ('RESEAU', 'SITE UTILISE UNIQUEMENT POUR HEBERGER UN/DES EQUIPEMENTS(S) PASSIF(S) ET/OU ACTIF(S)');

-- Liste : l_site_type_phy
CREATE TABLE gracethd3_1_raw.l_site_type_phy (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('ADR', 'ARMOIRE DE RUE');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('BAT', 'BATIMENT');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('CHV', 'CHAMBRE VISITABLE');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('COF', 'COFFRET');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('POH', 'POINT HAUT');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('SHE', 'SHELTER');
INSERT INTO gracethd3_1_raw.l_site_type_phy (code, libelle) VALUES ('STR', 'CONSTRUCTION SOUTERRAINE');

-- Liste : l_sro_etat
CREATE TABLE gracethd3_1_raw.l_sro_etat (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_sro_etat (code, libelle) VALUES ('PL', 'PLANIFIE');
INSERT INTO gracethd3_1_raw.l_sro_etat (code, libelle) VALUES ('EC', 'EN COURS DE DEPLOIEMENT');
INSERT INTO gracethd3_1_raw.l_sro_etat (code, libelle) VALUES ('DP', 'DEPLOYE');
INSERT INTO gracethd3_1_raw.l_sro_etat (code, libelle) VALUES ('AB', 'ABANDONNE');

-- Liste : l_statut
CREATE TABLE gracethd3_1_raw.l_statut (
    code    VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('PRE', 'ETUDE PRELIMINAIRE');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('DIA', 'ETUDE DE DIAGNOSTIC');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('AVP', 'AVANT-PROJET');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('PRO', 'PROJET');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('ACT', 'PASSATION DES MARCHES DE TRAVAUX');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('EXE', 'ETUDE D EXECUTION');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('TVX', 'TRAVAUX');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('REC', 'RECOLEMENT');
INSERT INTO gracethd3_1_raw.l_statut (code, libelle) VALUES ('MCO', 'MAINTIENT EN CONDITIONS OPERATIONNELLES');

-- Liste : l_tiroir_type
CREATE TABLE gracethd3_1_raw.l_tiroir_type (
    code    VARCHAR(8) PRIMARY KEY,
    libelle VARCHAR(254) NOT NULL
);

INSERT INTO gracethd3_1_raw.l_tiroir_type (code, libelle) VALUES ('TIROIR', 'TIROIR');
INSERT INTO gracethd3_1_raw.l_tiroir_type (code, libelle) VALUES ('TETE', 'TETE DE CABLE');

-- Listes référencées en FK mais sans valeurs dans la matrice.
-- Structure créée vide — à peupler manuellement ou via import.

CREATE TABLE gracethd3_1_raw.l_bp_racco (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_clim (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_geoloc_mode (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_immeuble (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_nro_type (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_occupation (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_ptech_type_log (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_sro_emplacement (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_technologie (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_tube (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

CREATE TABLE gracethd3_1_raw.l_zone_densite (
    code    VARCHAR(10) PRIMARY KEY,
    libelle VARCHAR(254)
);

-- ============================================================================
-- 3. TABLES MÉTIER (t_*)
-- ============================================================================
-- Les tables sont créées dans un ordre qui respecte les dépendances.
-- Les colonnes géométriques sont ajoutées via PostGIS (AddGeometryColumn).

-- Table : t_organisme
-- Coordonnées et identification d''organismes publics et privés...
CREATE TABLE gracethd3_1_raw.t_organisme (
    or_code              VARCHAR(20) NOT NULL,
    or_commune           VARCHAR(254),
    or_local             VARCHAR(254),
    or_nom               VARCHAR(254),
    or_nomvoie           VARCHAR(254),
    or_numero            INTEGER,
    or_postal            VARCHAR(20),
    or_rep               VARCHAR(20),
    or_siret             VARCHAR(14),
    or_type              VARCHAR(254),
    or_abddate           TIMESTAMP,
    or_abdsrc            VARCHAR(254),
    or_activ             VARCHAR(254),
    or_ad_code           VARCHAR(254),
    or_comment           VARCHAR(254),
    or_creadat           TIMESTAMP,
    or_l331              VARCHAR(254),
    or_mail              VARCHAR(254),
    or_majdate           TIMESTAMP,
    or_majsrc            VARCHAR(254),
    or_nometab           VARCHAR(254),
    or_siren             VARCHAR(9),
    or_telfixe           VARCHAR(20),
    CONSTRAINT pk_t_organisme PRIMARY KEY (or_code)
);

-- Table : t_noeud
-- Classe abstraite portant la géométrie d''un site ou d''un point technique. Classe mère de <PointTech...
CREATE TABLE gracethd3_1_raw.t_noeud (
    nd_code              VARCHAR(254) NOT NULL,
    nd_abddate           TIMESTAMP,
    nd_abdsrc            VARCHAR(254),
    nd_comment           VARCHAR(254),
    nd_creadat           TIMESTAMP,
    nd_majdate           TIMESTAMP,
    nd_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_noeud PRIMARY KEY (nd_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_noeud', 'geom', 2154, 'POINT', 2);
ALTER TABLE gracethd3_1_raw.t_noeud ALTER COLUMN geom SET NOT NULL;

-- Table : t_reference
-- Référence de matériel ou de coupe type....
CREATE TABLE gracethd3_1_raw.t_reference (
    rf_code              VARCHAR(254) NOT NULL,
    rf_design            VARCHAR(254),
    rf_type              VARCHAR(2),
    rf_abddate           TIMESTAMP,
    rf_abdsrc            VARCHAR(254),
    rf_comment           VARCHAR(254),
    rf_creadat           TIMESTAMP,
    rf_etat              VARCHAR(1),
    rf_fabric            VARCHAR(20),
    rf_majdate           TIMESTAMP,
    rf_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_reference PRIMARY KEY (rf_code)
);

-- Table : t_site
-- Regroupe les sites techniques et les sites d''habitation. (Pavillons, immeubles, shelters, armoires ...
CREATE TABLE gracethd3_1_raw.t_site (
    st_abandon           VARCHAR(1),
    st_ad_code           VARCHAR(254),
    st_avct              VARCHAR(1),
    st_code              VARCHAR(254) NOT NULL,
    st_codeext           VARCHAR(254),
    st_commune           VARCHAR(254),
    st_design            VARCHAR(254),
    st_gest              VARCHAR(20),
    st_insee             VARCHAR(20),
    st_nd_code           VARCHAR(254) NOT NULL,
    st_nombat            VARCHAR(254),
    st_nomvoie           VARCHAR(254),
    st_nra               VARCHAR(1),
    st_perirec           VARCHAR(254),
    st_postal            VARCHAR(254),
    st_prop              VARCHAR(20),
    st_proptyp           VARCHAR(3),
    st_rep               VARCHAR(20),
    st_statut            VARCHAR(3),
    st_typelog           VARCHAR(10),
    st_typephy           VARCHAR(3),
    st_dateins           DATE,
    st_numero            INTEGER,
    st_abddate           TIMESTAMP,
    st_abdsrc            VARCHAR(254),
    st_ban_id            VARCHAR(24),
    st_comment           VARCHAR(254),
    st_creadat           TIMESTAMP,
    st_datemes           TIMESTAMP,
    st_etat              VARCHAR(3),
    st_hexacle           VARCHAR(254),
    st_idpar             VARCHAR(20),
    st_majdate           TIMESTAMP,
    st_majsrc            VARCHAR(254),
    st_nblines           INTEGER,
    st_nom               VARCHAR(254),
    st_section           VARCHAR(5),
    st_user              VARCHAR(20),
    CONSTRAINT pk_t_site PRIMARY KEY (st_code),
    CONSTRAINT uq_t_site_st_codeext UNIQUE (st_codeext),
    CONSTRAINT uq_t_site_st_nd_code UNIQUE (st_nd_code)
);

-- Table : t_ptech
-- Liste des Points Techniques faisant partie de l''Infrastructure de Génie Civil souterraine et aérien...
CREATE TABLE gracethd3_1_raw.t_ptech (
    pt_a_haut            NUMERIC(5,2),
    pt_a_struc           VARCHAR(100),
    pt_abandon           VARCHAR(1),
    pt_avct              VARCHAR(1),
    pt_code              VARCHAR(254) NOT NULL,
    pt_codeext           VARCHAR(254) NOT NULL,
    pt_commune           VARCHAR(254),
    pt_etiquet           VARCHAR(254),
    pt_gest              VARCHAR(20),
    pt_insee             VARCHAR(20),
    pt_nature            VARCHAR(20),
    pt_nd_code           VARCHAR(254) NOT NULL,
    pt_nomvoie           VARCHAR(254),
    pt_numero            INTEGER,
    pt_perirec           VARCHAR(254),
    pt_prop              VARCHAR(20),
    pt_proptyp           VARCHAR(3),
    pt_rep               VARCHAR(20),
    pt_secu              VARCHAR(1),
    pt_statut            VARCHAR(3),
    pt_typephy           VARCHAR(1),
    pt_a_dan             NUMERIC(18,6),
    pt_a_dtetu           DATE,
    pt_a_passa           VARCHAR(1),
    pt_a_strat           VARCHAR(1),
    pt_abddate           TIMESTAMP,
    pt_abdsrc            VARCHAR(254),
    pt_ad_code           VARCHAR(254),
    pt_comment           VARCHAR(254),
    pt_creadat           TIMESTAMP,
    pt_datemes           TIMESTAMP,
    pt_detec             VARCHAR(1),
    pt_etat              VARCHAR(3),
    pt_gest_do           VARCHAR(20),
    pt_idpar             VARCHAR(20),
    pt_local             VARCHAR(254),
    pt_majdate           TIMESTAMP,
    pt_majsrc            VARCHAR(254),
    pt_occp              VARCHAR(10),
    pt_postal            VARCHAR(20),
    pt_prop_do           VARCHAR(20),
    pt_rf_code           VARCHAR(254),
    pt_section           VARCHAR(5),
    pt_typelog           VARCHAR(1),
    pt_user              VARCHAR(20),
    CONSTRAINT pk_t_ptech PRIMARY KEY (pt_code),
    CONSTRAINT uq_t_ptech_pt_codeext UNIQUE (pt_codeext),
    CONSTRAINT uq_t_ptech_pt_nd_code UNIQUE (pt_nd_code)
);

-- Table : t_local
-- Un local est un sous ensemble d''un site (logement, local entreprise, local technique…etc.)....
CREATE TABLE gracethd3_1_raw.t_local (
    lc_abandon           VARCHAR(1),
    lc_avct              VARCHAR(1),
    lc_bat               VARCHAR(100),
    lc_bp_codf           VARCHAR(254),
    lc_bp_codp           VARCHAR(254),
    lc_code              VARCHAR(254) NOT NULL,
    lc_codeext           VARCHAR(254),
    lc_elec              VARCHAR(1),
    lc_escal             VARCHAR(20),
    lc_etage             VARCHAR(20),
    lc_etiquet           VARCHAR(20),
    lc_gest              VARCHAR(20),
    lc_perirec           VARCHAR(254),
    lc_prop              VARCHAR(20),
    lc_proptyp           VARCHAR(3),
    lc_st_code           VARCHAR(254) NOT NULL,
    lc_statut            VARCHAR(3),
    lc_typelog           VARCHAR(10),
    lc_dateins           DATE,
    lc_abddate           TIMESTAMP,
    lc_abdsrc            VARCHAR(254),
    lc_clim              VARCHAR(6),
    lc_comment           VARCHAR(254),
    lc_creadat           TIMESTAMP,
    lc_datemes           TIMESTAMP,
    lc_etat              VARCHAR(3),
    lc_idmajic           VARCHAR(254),
    lc_local             VARCHAR(254),
    lc_majdate           TIMESTAMP,
    lc_majsrc            VARCHAR(254),
    lc_occp              VARCHAR(10),
    lc_user              VARCHAR(20),
    CONSTRAINT pk_t_local PRIMARY KEY (lc_code),
    CONSTRAINT uq_t_local_lc_codeext UNIQUE (lc_codeext)
);

-- Table : t_ebp
-- Regroupement des éléments du réseau ayant un rôle passif dans le branchement optique (ex :PBO, BPE, ...
CREATE TABLE gracethd3_1_raw.t_ebp (
    bp_abandon           VARCHAR(1),
    bp_avct              VARCHAR(1),
    bp_code              VARCHAR(254) NOT NULL,
    bp_codeext           VARCHAR(254) NOT NULL,
    bp_etiquet           VARCHAR(254),
    bp_gest              VARCHAR(20),
    bp_lc_code           VARCHAR(254),
    bp_perirec           VARCHAR(254),
    bp_prop              VARCHAR(20),
    bp_proptyp           VARCHAR(3),
    bp_pt_code           VARCHAR(254),
    bp_rf_code           VARCHAR(254),
    bp_statut            VARCHAR(3),
    bp_typelog           VARCHAR(3),
    bp_typephy           VARCHAR(5),
    bp_dateins           DATE,
    bp_abddate           TIMESTAMP,
    bp_abdsrc            VARCHAR(254),
    bp_ca_nb             INTEGER,
    bp_comment           VARCHAR(254),
    bp_creadat           TIMESTAMP,
    bp_datemes           TIMESTAMP,
    bp_entrees           INTEGER,
    bp_etat              VARCHAR(3),
    bp_linecod           VARCHAR(12),
    bp_majdate           TIMESTAMP,
    bp_majsrc            VARCHAR(254),
    bp_nb_pas            INTEGER,
    bp_oc_code           VARCHAR(50),
    bp_occp              VARCHAR(10),
    bp_racco             VARCHAR(6),
    bp_ref_kit           VARCHAR(30),
    bp_user              VARCHAR(20),
    CONSTRAINT pk_t_ebp PRIMARY KEY (bp_code),
    CONSTRAINT uq_t_ebp_bp_codeext UNIQUE (bp_codeext)
);

-- Table : t_baie
-- Regroupe la liste des baies et des fermes contenus dans les locaux techniques. (1 enregistrement par...
CREATE TABLE gracethd3_1_raw.t_baie (
    ba_abandon           VARCHAR(1),
    ba_code              VARCHAR(254) NOT NULL,
    ba_codeext           VARCHAR(254),
    ba_etiquet           VARCHAR(254),
    ba_gest              VARCHAR(20),
    ba_lc_code           VARCHAR(254) NOT NULL,
    ba_nb_u              NUMERIC(5,2),
    ba_perirec           VARCHAR(254),
    ba_prop              VARCHAR(20),
    ba_proptyp           VARCHAR(3),
    ba_rf_code           VARCHAR(254),
    ba_statut            VARCHAR(3),
    ba_type              VARCHAR(10),
    ba_abddate           TIMESTAMP,
    ba_abdsrc            VARCHAR(254),
    ba_comment           VARCHAR(254),
    ba_creadat           TIMESTAMP,
    ba_etat              VARCHAR(3),
    ba_haut              NUMERIC(8,2),
    ba_larg              NUMERIC(8,2),
    ba_majdate           TIMESTAMP,
    ba_majsrc            VARCHAR(254),
    ba_prof              NUMERIC(8,2),
    ba_user              VARCHAR(20),
    CONSTRAINT pk_t_baie PRIMARY KEY (ba_code),
    CONSTRAINT uq_t_baie_ba_codeext UNIQUE (ba_codeext)
);

-- Table : t_cassette
-- Cassettes contenues dans les éléments de branchements passifs du réseau (voir définition classe <Ele...
CREATE TABLE gracethd3_1_raw.t_cassette (
    cs_bp_code           VARCHAR(254),
    cs_code              VARCHAR(254) NOT NULL,
    cs_face              VARCHAR(20),
    cs_num               INTEGER,
    cs_rf_code           VARCHAR(254),
    cs_type              VARCHAR(1),
    cs_abddate           TIMESTAMP,
    cs_abdsrc            VARCHAR(254),
    cs_comment           VARCHAR(254),
    cs_creadat           TIMESTAMP,
    cs_majdate           TIMESTAMP,
    cs_majsrc            VARCHAR(254),
    cs_nb_pas            INTEGER,
    CONSTRAINT pk_t_cassette PRIMARY KEY (cs_code)
);

-- Table : t_tiroir
-- Regroupe la liste des tiroirs (donc positionnés en baie), et des têtes de câble optiques (positionné...
CREATE TABLE gracethd3_1_raw.t_tiroir (
    ti_abandon           VARCHAR(1),
    ti_ba_code           VARCHAR(254) NOT NULL,
    ti_code              VARCHAR(254) NOT NULL,
    ti_codeext           VARCHAR(254),
    ti_etiquet           VARCHAR(254),
    ti_perirec           VARCHAR(254),
    ti_placemt           NUMERIC(5,2),
    ti_prop              VARCHAR(20),
    ti_rf_code           VARCHAR(254),
    ti_taille            NUMERIC(5,2),
    ti_type              VARCHAR(10),
    ti_abddate           TIMESTAMP,
    ti_abdsrc            VARCHAR(254),
    ti_comment           VARCHAR(254),
    ti_creadat           TIMESTAMP,
    ti_etat              VARCHAR(3),
    ti_localis           VARCHAR(254),
    ti_majdate           TIMESTAMP,
    ti_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_tiroir PRIMARY KEY (ti_code),
    CONSTRAINT uq_t_tiroir_ti_codeext UNIQUE (ti_codeext)
);

-- Table : t_position
-- Smoove lorsque la position appartient à une cassette, corps de traversée lorsque la position apparti...
CREATE TABLE gracethd3_1_raw.t_position (
    ps_1                 VARCHAR(254),
    ps_2                 VARCHAR(254),
    ps_code              VARCHAR(254) NOT NULL,
    ps_cs_code           VARCHAR(254) NOT NULL,
    ps_fonct             VARCHAR(2),
    ps_numero            INTEGER,
    ps_ti_code           VARCHAR(254),
    ps_type              VARCHAR(10),
    ps_abddate           TIMESTAMP,
    ps_abdsrc            VARCHAR(254),
    ps_comment           VARCHAR(254),
    ps_creadat           TIMESTAMP,
    ps_etat              VARCHAR(3),
    ps_majdate           TIMESTAMP,
    ps_majsrc            VARCHAR(254),
    ps_usetype           VARCHAR(2),
    CONSTRAINT pk_t_position PRIMARY KEY (ps_code)
);

-- Table : t_love
-- Permet de localiser les loves de câble. Chaque enregistrement associe un câble à un Nœud Physique, a...
CREATE TABLE gracethd3_1_raw.t_love (
    lv_cb_code           VARCHAR(254),
    lv_id                BIGINT NOT NULL,
    lv_long              INTEGER,
    lv_nd_code           VARCHAR(254) NOT NULL,
    lv_abddate           TIMESTAMP,
    lv_abdsrc            VARCHAR(254),
    lv_creadat           TIMESTAMP,
    lv_majdate           TIMESTAMP,
    lv_majsrc            VARCHAR(254)
);

-- Table : t_cheminement
-- Un cheminement représente, entre deux points techniques/sites : - Un parcours physique approchant po...
CREATE TABLE gracethd3_1_raw.t_cheminement (
    cm_avct              VARCHAR(1),
    cm_code              VARCHAR(254) NOT NULL,
    cm_compo             VARCHAR(254),
    cm_gest              VARCHAR(20),
    cm_ndcode1           VARCHAR(254) NOT NULL,
    cm_ndcode2           VARCHAR(254) NOT NULL,
    cm_perirec           VARCHAR(254),
    cm_prop              VARCHAR(20),
    cm_statut            VARCHAR(3),
    cm_typ_imp           VARCHAR(2),
    cm_typelog           VARCHAR(2),
    cm_abddate           TIMESTAMP,
    cm_abdsrc            VARCHAR(254),
    cm_codeext           VARCHAR(254),
    cm_comment           VARCHAR(254),
    cm_creadat           TIMESTAMP,
    cm_majdate           TIMESTAMP,
    cm_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_cheminement PRIMARY KEY (cm_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_cheminement', 'geom', 2154, 'LINESTRING', 2);
ALTER TABLE gracethd3_1_raw.t_cheminement ALTER COLUMN geom SET NOT NULL;

-- Table : t_cableline
-- Les câbles nécessitant une géométrie (globalement les câbles cheminant en extrasite) peuvent être mo...
CREATE TABLE gracethd3_1_raw.t_cableline (
    cl_cb_code           VARCHAR(254) NOT NULL,
    cl_code              VARCHAR(254) NOT NULL,
    cl_abddate           TIMESTAMP,
    cl_abdsrc            VARCHAR(254),
    cl_comment           VARCHAR(254),
    cl_creadat           TIMESTAMP,
    cl_dtclass           VARCHAR(2),
    cl_geolmod           VARCHAR(4),
    cl_geolqlt           NUMERIC(6,2),
    cl_geolsrc           VARCHAR(254),
    cl_long              NUMERIC(7,2),
    cl_majdate           TIMESTAMP,
    cl_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_cableline PRIMARY KEY (cl_code),
    CONSTRAINT uq_t_cableline_cl_cb_code UNIQUE (cl_cb_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_cableline', 'geom', 2154, 'LINESTRING', 2);
ALTER TABLE gracethd3_1_raw.t_cableline ALTER COLUMN geom SET NOT NULL;

-- Table : t_cable
-- Tronçon de câble du réseau de fibre optique....
CREATE TABLE gracethd3_1_raw.t_cable (
    cb_abandon           VARCHAR(1),
    cb_avct              VARCHAR(1),
    cb_ba1               VARCHAR(254),
    cb_ba2               VARCHAR(254),
    cb_bp1               VARCHAR(254),
    cb_bp2               VARCHAR(254),
    cb_cabphy            VARCHAR(254),
    cb_capafo            INTEGER,
    cb_code              VARCHAR(254) NOT NULL,
    cb_codeext           VARCHAR(254) NOT NULL,
    cb_etiquet           VARCHAR(254),
    cb_fo_disp           INTEGER,
    cb_fo_type           VARCHAR(20),
    cb_fo_util           INTEGER,
    cb_gest              VARCHAR(20),
    cb_modulo            INTEGER,
    cb_nd1               VARCHAR(254),
    cb_nd2               VARCHAR(254),
    cb_perirec           VARCHAR(254),
    cb_prop              VARCHAR(20),
    cb_proptyp           VARCHAR(3),
    cb_r1_code           VARCHAR(100),
    cb_r2_code           VARCHAR(100),
    cb_r3_code           VARCHAR(100),
    cb_rf_code           VARCHAR(254),
    cb_statut            VARCHAR(3),
    cb_typelog           VARCHAR(2),
    cb_typephy           VARCHAR(1),
    cb_dateins           DATE,
    cb_lgreel            NUMERIC(7,2),
    cb_abddate           TIMESTAMP,
    cb_abdsrc            VARCHAR(254),
    cb_color             VARCHAR(254),
    cb_comment           VARCHAR(254),
    cb_creadat           TIMESTAMP,
    cb_datemes           TIMESTAMP,
    cb_diam              NUMERIC(6,2),
    cb_etat              VARCHAR(3),
    cb_localis           VARCHAR(254),
    cb_majdate           TIMESTAMP,
    cb_majsrc            VARCHAR(254),
    cb_r4_code           VARCHAR(100),
    cb_tech              VARCHAR(3),
    cb_user              VARCHAR(20),
    CONSTRAINT pk_t_cable PRIMARY KEY (cb_code),
    CONSTRAINT uq_t_cable_cb_codeext UNIQUE (cb_codeext)
);

-- Table : t_cab_chem
-- Relations entre les câbles et les cheminement en remplacement de la table t_conduite, t_cond_chem et...
CREATE TABLE gracethd3_1_raw.t_cab_chem (
    cc_cb_code           VARCHAR(254) NOT NULL,
    cc_cm_code           VARCHAR(254) NOT NULL,
    cc_abddate           TIMESTAMP,
    cc_abdsrc            VARCHAR(254),
    cc_creadat           TIMESTAMP,
    cc_majdate           TIMESTAMP,
    cc_majsrc            VARCHAR(254)
);

-- Table : t_fibre
-- Fibres optiques constituant les câbles....
CREATE TABLE gracethd3_1_raw.t_fibre (
    fo_cb_code           VARCHAR(254) NOT NULL,
    fo_code              VARCHAR(254) NOT NULL,
    fo_etat              VARCHAR(3),
    fo_nincab            INTEGER,
    fo_nintub            INTEGER,
    fo_numtub            INTEGER,
    fo_abddate           TIMESTAMP,
    fo_abdsrc            VARCHAR(254),
    fo_code_ext          VARCHAR(254),
    fo_color             VARCHAR(10),
    fo_comment           VARCHAR(254),
    fo_creadat           TIMESTAMP,
    fo_majdate           TIMESTAMP,
    fo_majsrc            VARCHAR(254),
    fo_proptyp           VARCHAR(3),
    fo_reper             VARCHAR(5),
    CONSTRAINT pk_t_fibre PRIMARY KEY (fo_code)
);

-- Table : t_tranchee
-- Element linéaire de Génie Civil créé lors du déploiement du réseau de fibre optique....
CREATE TABLE gracethd3_1_raw.t_tranchee (
    tr_code              VARCHAR(254) NOT NULL,
    tr_compo             VARCHAR(254),
    tr_couptyp           VARCHAR(254),
    tr_dtclass           VARCHAR(2),
    tr_lgreel            NUMERIC(8,2),
    tr_pa1               VARCHAR(254),
    tr_pa2               VARCHAR(254),
    tr_perirec           VARCHAR(254),
    tr_abddate           TIMESTAMP,
    tr_abdsrc            VARCHAR(254),
    tr_comment           VARCHAR(254),
    tr_creadat           TIMESTAMP,
    tr_majdate           TIMESTAMP,
    tr_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_tranchee PRIMARY KEY (tr_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_tranchee', 'geom', 2154, 'LINESTRING', 2);
ALTER TABLE gracethd3_1_raw.t_tranchee ALTER COLUMN geom SET NOT NULL;

-- Table : t_znro
-- Zone arrière d''un Noeud de Raccordement Optique (NRO)....
CREATE TABLE gracethd3_1_raw.t_znro (
    zn_code              VARCHAR(254) NOT NULL,
    zn_etat              VARCHAR(2),
    zn_lc_code           VARCHAR(254) NOT NULL,
    zn_nd_code           VARCHAR(254),
    zn_nroref            VARCHAR(15),
    zn_r1_code           VARCHAR(100),
    zn_r2_code           VARCHAR(100),
    zn_nom               VARCHAR(30),
    zn_abddate           TIMESTAMP,
    zn_abdsrc            VARCHAR(254),
    zn_comment           VARCHAR(254),
    zn_creadat           TIMESTAMP,
    zn_datelpm           TIMESTAMP,
    zn_etatlpm           VARCHAR(2),
    zn_geolsrc           VARCHAR(254),
    zn_majdate           TIMESTAMP,
    zn_majsrc            VARCHAR(254),
    zn_nrotype           VARCHAR(7),
    zn_r3_code           VARCHAR(100),
    zn_r4_code           VARCHAR(100),
    CONSTRAINT pk_t_znro PRIMARY KEY (zn_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_znro', 'geom', 2154, 'MULTIPOLYGON', 2);
ALTER TABLE gracethd3_1_raw.t_znro ALTER COLUMN geom SET NOT NULL;

-- Table : t_zsro
-- Zone Arrière d''un Sous-Répartiteur Optique (SRO)....
CREATE TABLE gracethd3_1_raw.t_zsro (
    zs_actif             VARCHAR(1),
    zs_capamax           INTEGER,
    zs_code              VARCHAR(254) NOT NULL,
    zs_etatpm            VARCHAR(2),
    zs_lc_code           VARCHAR(254) NOT NULL,
    zs_lgmaxln           NUMERIC(5,2),
    zs_nblogmt           INTEGER,
    zs_r1_code           VARCHAR(100),
    zs_r2_code           VARCHAR(100),
    zs_r3_code           VARCHAR(100),
    zs_refpm             VARCHAR(20),
    zs_zn_code           VARCHAR(254) NOT NULL,
    zs_znllong           NUMERIC(5,2),
    zs_nom               VARCHAR(30),
    zs_abddate           TIMESTAMP,
    zs_abdsrc            VARCHAR(254),
    zs_accgest           VARCHAR(1),
    zs_ad_code           VARCHAR(254),
    zs_brassoi           VARCHAR(1),
    zs_comment           VARCHAR(254),
    zs_creadat           TIMESTAMP,
    zs_datcomr           TIMESTAMP,
    zs_dateins           TIMESTAMP,
    zs_datemad           TIMESTAMP,
    zs_geolsrc           VARCHAR(254),
    zs_majdate           TIMESTAMP,
    zs_majsrc            VARCHAR(254),
    zs_nbcolmt           INTEGER,
    zs_r4_code           VARCHAR(100),
    zs_typeemp           VARCHAR(3),
    zs_typeing           VARCHAR(254),
    CONSTRAINT pk_t_zsro PRIMARY KEY (zs_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_zsro', 'geom', 2154, 'MULTIPOLYGON', 2);
ALTER TABLE gracethd3_1_raw.t_zsro ALTER COLUMN geom SET NOT NULL;

-- Table : t_zpbo
CREATE TABLE gracethd3_1_raw.t_zpbo (
    zp_abddate           TIMESTAMP,
    zp_abdsrc            VARCHAR(254),
    zp_bp_code           VARCHAR(254) NOT NULL,
    zp_capamax           INTEGER,
    zp_code              VARCHAR(254) NOT NULL,
    zp_comment           VARCHAR(254),
    zp_creadat           TIMESTAMP,
    zp_geolsrc           VARCHAR(254),
    zp_majdate           TIMESTAMP,
    zp_majsrc            VARCHAR(254),
    zp_nd_code           VARCHAR(254),
    zp_r1_code           VARCHAR(100),
    zp_r2_code           VARCHAR(100),
    zp_r3_code           VARCHAR(100),
    zp_r4_code           VARCHAR(100),
    zp_zs_code           VARCHAR(254) NOT NULL,
    CONSTRAINT pk_t_zpbo PRIMARY KEY (zp_code),
    CONSTRAINT uq_t_zpbo_zp_bp_code UNIQUE (zp_bp_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_zpbo', 'geom', 2154, 'MULTIPOLYGON', 2);
ALTER TABLE gracethd3_1_raw.t_zpbo ALTER COLUMN geom SET NOT NULL;

-- Table : t_zdep
-- Zone de déploiement. Pour définir des zones correspondant à des phases de déploiement....
CREATE TABLE gracethd3_1_raw.t_zdep (
    zd_code              VARCHAR(254) NOT NULL,
    zd_nd_code           VARCHAR(254),
    zd_r1_code           VARCHAR(100),
    zd_r2_code           VARCHAR(100),
    zd_r3_code           VARCHAR(100),
    zd_r4_code           VARCHAR(100),
    zd_statut            VARCHAR(3),
    zd_zs_code           VARCHAR(254),
    zd_abddate           TIMESTAMP,
    zd_abdsrc            VARCHAR(254),
    zd_comment           VARCHAR(254),
    zd_creadat           TIMESTAMP,
    zd_geolsrc           VARCHAR(254),
    zd_gest              VARCHAR(20),
    zd_majdate           TIMESTAMP,
    zd_majsrc            VARCHAR(254),
    zd_prop              VARCHAR(20),
    CONSTRAINT pk_t_zdep PRIMARY KEY (zd_code),
    CONSTRAINT uq_t_zdep_zd_nd_code UNIQUE (zd_nd_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_zdep', 'geom', 2154, 'MULTIPOLYGON', 2);
ALTER TABLE gracethd3_1_raw.t_zdep ALTER COLUMN geom SET NOT NULL;

-- Table : t_adresse
-- Adresses telles qu''identifiées par les opérateurs. Cette classe d''objets participe à la génération...
CREATE TABLE gracethd3_1_raw.t_adresse (
    ad_abddate           TIMESTAMP,
    ad_abdsrc            VARCHAR(254),
    ad_alias             VARCHAR(254),
    ad_ban_id            VARCHAR(24),
    ad_batcode           VARCHAR(100),
    ad_code              VARCHAR(254) NOT NULL,
    ad_codtemp           VARCHAR(254),
    ad_comment           VARCHAR(254),
    ad_commune           VARCHAR(254),
    ad_creadat           TIMESTAMP,
    ad_datmodi           DATE,
    ad_distinf           NUMERIC(6,2),
    ad_dta               VARCHAR(1),
    ad_fantoir           VARCHAR(10),
    ad_geolmod           VARCHAR(4),
    ad_geolqlt           NUMERIC(6,2),
    ad_geolsrc           VARCHAR(254),
    ad_gest              VARCHAR(254),
    ad_hexacle           VARCHAR(254),
    ad_hexaclv           VARCHAR(254),
    ad_iaccgst           VARCHAR(1),
    ad_idatcab           DATE,
    ad_idatcom           DATE,
    ad_idatimn           DATE,
    ad_idatsgn           DATE,
    ad_idpar             VARCHAR(20),
    ad_ietat             VARCHAR(2),
    ad_imneuf            VARCHAR(1),
    ad_insee             VARCHAR(6),
    ad_isole             VARCHAR(1),
    ad_itypeim           VARCHAR(1),
    ad_majdate           TIMESTAMP,
    ad_majsrc            VARCHAR(254),
    ad_nat               VARCHAR(1),
    ad_nbfofon           INTEGER,
    ad_nbfogfu           INTEGER,
    ad_nbfotte           INTEGER,
    ad_nbfotth           INTEGER,
    ad_nbfotto           INTEGER,
    ad_nblent            INTEGER,
    ad_nblobj            INTEGER,
    ad_nblope            INTEGER,
    ad_nblpro            INTEGER,
    ad_nblpub            INTEGER,
    ad_nblres            INTEGER,
    ad_nom_ld            VARCHAR(254),
    ad_nombat            VARCHAR(254),
    ad_nomvoie           VARCHAR(254),
    ad_numero            INTEGER,
    ad_postal            VARCHAR(20),
    ad_prio              VARCHAR(1),
    ad_prop              VARCHAR(254),
    ad_racc              VARCHAR(2),
    ad_raclong           VARCHAR(1),
    ad_rep               VARCHAR(20),
    ad_rivoli            VARCHAR(254),
    ad_section           VARCHAR(5),
    ad_sracdem           VARCHAR(1),
    ad_typzone           VARCHAR(1),
    ad_x_ban             NUMERIC,
    ad_x_parc            NUMERIC,
    ad_y_ban             NUMERIC,
    ad_y_parc            NUMERIC,
    CONSTRAINT pk_t_adresse PRIMARY KEY (ad_code),
    CONSTRAINT uq_t_adresse_ad_batcode UNIQUE (ad_batcode),
    CONSTRAINT uq_t_adresse_ad_codtemp UNIQUE (ad_codtemp)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_adresse', 'geom', 2154, 'POINT', 2);
ALTER TABLE gracethd3_1_raw.t_adresse ALTER COLUMN geom SET NOT NULL;

-- Table : t_pointaccueil
-- Cette classe regroupe: ​ - Les sites et les points techniques du Génie Civil créé lors du déploiemen...
CREATE TABLE gracethd3_1_raw.t_pointaccueil (
    pa_a_haut            NUMERIC(5,2),
    pa_a_struc           VARCHAR(100),
    pa_code              VARCHAR(254) NOT NULL,
    pa_codeext           VARCHAR(254),
    pa_codtemp           VARCHAR(254),
    pa_dtclass           VARCHAR(2),
    pa_gest              VARCHAR(20),
    pa_nature            VARCHAR(20),
    pa_perirec           VARCHAR(254),
    pa_prop              VARCHAR(20),
    pa_rotatio           NUMERIC(5,2),
    pa_secu              VARCHAR(1),
    pa_typephy           VARCHAR(3),
    pa_datecon           DATE,
    pa_abddate           TIMESTAMP,
    pa_abdsrc            VARCHAR(254),
    pa_comment           VARCHAR(254),
    pa_creadat           TIMESTAMP,
    pa_majdate           TIMESTAMP,
    pa_majsrc            VARCHAR(254),
    CONSTRAINT pk_t_pointaccueil PRIMARY KEY (pa_code),
    CONSTRAINT uq_t_pointaccueil_pa_codeext UNIQUE (pa_codeext),
    CONSTRAINT uq_t_pointaccueil_pa_codtemp UNIQUE (pa_codtemp)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_pointaccueil', 'geom', 2154, 'POINT', 2);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ALTER COLUMN geom SET NOT NULL;

-- Table : t_point_leve
-- Cette classe décrit les points levés spécifiques au réseau et permet d’indiquer la profondeur ou l’a...
CREATE TABLE gracethd3_1_raw.t_point_leve (
    pl_charge            NUMERIC(6,2),
    pl_code              VARCHAR(254) NOT NULL,
    pl_x                 NUMERIC,
    pl_y                 NUMERIC,
    pl_z                 NUMERIC,
    CONSTRAINT pk_t_point_leve PRIMARY KEY (pl_code)
);

SELECT AddGeometryColumn('gracethd3_1_raw', 't_point_leve', 'geom', 2154, 'POINT', 2);
ALTER TABLE gracethd3_1_raw.t_point_leve ALTER COLUMN geom SET NOT NULL;

-- ============================================================================
-- 4. CLÉS ÉTRANGÈRES
-- ============================================================================
-- Ajoutées après toutes les tables pour éviter les dépendances circulaires.

ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_dta FOREIGN KEY (ad_dta) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_geolmod FOREIGN KEY (ad_geolmod) REFERENCES gracethd3_1_raw.l_geoloc_mode(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_gest FOREIGN KEY (ad_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_iaccgst FOREIGN KEY (ad_iaccgst) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_abandon FOREIGN KEY (ba_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_gest FOREIGN KEY (ba_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_lc_code FOREIGN KEY (ba_lc_code) REFERENCES gracethd3_1_raw.t_local(lc_code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_prop FOREIGN KEY (ba_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_proptyp FOREIGN KEY (ba_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_rf_code FOREIGN KEY (ba_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_statut FOREIGN KEY (ba_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_type FOREIGN KEY (ba_type) REFERENCES gracethd3_1_raw.l_baie_type(code);
ALTER TABLE gracethd3_1_raw.t_cab_chem ADD CONSTRAINT fk_t_cab_chem_cc_cb_code FOREIGN KEY (cc_cb_code) REFERENCES gracethd3_1_raw.t_cable(cb_code);
ALTER TABLE gracethd3_1_raw.t_cab_chem ADD CONSTRAINT fk_t_cab_chem_cc_cm_code FOREIGN KEY (cc_cm_code) REFERENCES gracethd3_1_raw.t_cheminement(cm_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_abandon FOREIGN KEY (cb_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_avct FOREIGN KEY (cb_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_ba1 FOREIGN KEY (cb_ba1) REFERENCES gracethd3_1_raw.t_baie(ba_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_ba2 FOREIGN KEY (cb_ba2) REFERENCES gracethd3_1_raw.t_baie(ba_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_bp1 FOREIGN KEY (cb_bp1) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_bp2 FOREIGN KEY (cb_bp2) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_fo_type FOREIGN KEY (cb_fo_type) REFERENCES gracethd3_1_raw.l_fo_type(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_gest FOREIGN KEY (cb_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_nd1 FOREIGN KEY (cb_nd1) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_nd2 FOREIGN KEY (cb_nd2) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_prop FOREIGN KEY (cb_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_proptyp FOREIGN KEY (cb_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_rf_code FOREIGN KEY (cb_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_statut FOREIGN KEY (cb_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_typelog FOREIGN KEY (cb_typelog) REFERENCES gracethd3_1_raw.l_cable_chem_type_log(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_typephy FOREIGN KEY (cb_typephy) REFERENCES gracethd3_1_raw.l_cable_type(code);
ALTER TABLE gracethd3_1_raw.t_cableline ADD CONSTRAINT fk_t_cableline_cl_cb_code FOREIGN KEY (cl_cb_code) REFERENCES gracethd3_1_raw.t_cable(cb_code);
ALTER TABLE gracethd3_1_raw.t_cassette ADD CONSTRAINT fk_t_cassette_cs_bp_code FOREIGN KEY (cs_bp_code) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_cassette ADD CONSTRAINT fk_t_cassette_cs_rf_code FOREIGN KEY (cs_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_cassette ADD CONSTRAINT fk_t_cassette_cs_type FOREIGN KEY (cs_type) REFERENCES gracethd3_1_raw.l_cassette_type(code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_avct FOREIGN KEY (cm_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_gest FOREIGN KEY (cm_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_ndcode1 FOREIGN KEY (cm_ndcode1) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_ndcode2 FOREIGN KEY (cm_ndcode2) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_prop FOREIGN KEY (cm_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_statut FOREIGN KEY (cm_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_typ_imp FOREIGN KEY (cm_typ_imp) REFERENCES gracethd3_1_raw.l_implantation(code);
ALTER TABLE gracethd3_1_raw.t_cheminement ADD CONSTRAINT fk_t_cheminement_cm_typelog FOREIGN KEY (cm_typelog) REFERENCES gracethd3_1_raw.l_cable_chem_type_log(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_abandon FOREIGN KEY (bp_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_avct FOREIGN KEY (bp_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_gest FOREIGN KEY (bp_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_lc_code FOREIGN KEY (bp_lc_code) REFERENCES gracethd3_1_raw.t_local(lc_code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_prop FOREIGN KEY (bp_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_proptyp FOREIGN KEY (bp_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_pt_code FOREIGN KEY (bp_pt_code) REFERENCES gracethd3_1_raw.t_ptech(pt_code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_rf_code FOREIGN KEY (bp_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_statut FOREIGN KEY (bp_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_typelog FOREIGN KEY (bp_typelog) REFERENCES gracethd3_1_raw.l_bp_type_log(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_typephy FOREIGN KEY (bp_typephy) REFERENCES gracethd3_1_raw.l_bp_type_phy(code);
ALTER TABLE gracethd3_1_raw.t_fibre ADD CONSTRAINT fk_t_fibre_fo_cb_code FOREIGN KEY (fo_cb_code) REFERENCES gracethd3_1_raw.t_cable(cb_code);
ALTER TABLE gracethd3_1_raw.t_fibre ADD CONSTRAINT fk_t_fibre_fo_etat FOREIGN KEY (fo_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_abandon FOREIGN KEY (lc_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_avct FOREIGN KEY (lc_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_bp_codf FOREIGN KEY (lc_bp_codf) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_bp_codp FOREIGN KEY (lc_bp_codp) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_elec FOREIGN KEY (lc_elec) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_gest FOREIGN KEY (lc_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_prop FOREIGN KEY (lc_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_proptyp FOREIGN KEY (lc_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_st_code FOREIGN KEY (lc_st_code) REFERENCES gracethd3_1_raw.t_site(st_code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_statut FOREIGN KEY (lc_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_typelog FOREIGN KEY (lc_typelog) REFERENCES gracethd3_1_raw.l_local_type_log(code);
ALTER TABLE gracethd3_1_raw.t_love ADD CONSTRAINT fk_t_love_lv_cb_code FOREIGN KEY (lv_cb_code) REFERENCES gracethd3_1_raw.t_cable(cb_code);
ALTER TABLE gracethd3_1_raw.t_love ADD CONSTRAINT fk_t_love_lv_nd_code FOREIGN KEY (lv_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_dtclass FOREIGN KEY (pa_dtclass) REFERENCES gracethd3_1_raw.l_geoloc_classe(code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_gest FOREIGN KEY (pa_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_nature FOREIGN KEY (pa_nature) REFERENCES gracethd3_1_raw.l_pointaccueil_nature(code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_prop FOREIGN KEY (pa_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_secu FOREIGN KEY (pa_secu) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_pointaccueil ADD CONSTRAINT fk_t_pointaccueil_pa_typephy FOREIGN KEY (pa_typephy) REFERENCES gracethd3_1_raw.l_pointaccueil_type_phy(code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_1 FOREIGN KEY (ps_1) REFERENCES gracethd3_1_raw.t_fibre(fo_code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_2 FOREIGN KEY (ps_2) REFERENCES gracethd3_1_raw.t_fibre(fo_code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_cs_code FOREIGN KEY (ps_cs_code) REFERENCES gracethd3_1_raw.t_cassette(cs_code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_fonct FOREIGN KEY (ps_fonct) REFERENCES gracethd3_1_raw.l_position_fonction(code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_ti_code FOREIGN KEY (ps_ti_code) REFERENCES gracethd3_1_raw.t_tiroir(ti_code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_type FOREIGN KEY (ps_type) REFERENCES gracethd3_1_raw.l_position_type(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_abandon FOREIGN KEY (pt_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_avct FOREIGN KEY (pt_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_gest FOREIGN KEY (pt_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_nature FOREIGN KEY (pt_nature) REFERENCES gracethd3_1_raw.l_ptech_nature(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_nd_code FOREIGN KEY (pt_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_prop FOREIGN KEY (pt_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_proptyp FOREIGN KEY (pt_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_secu FOREIGN KEY (pt_secu) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_statut FOREIGN KEY (pt_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_typephy FOREIGN KEY (pt_typephy) REFERENCES gracethd3_1_raw.l_ptech_type_phy(code);
ALTER TABLE gracethd3_1_raw.t_reference ADD CONSTRAINT fk_t_reference_rf_type FOREIGN KEY (rf_type) REFERENCES gracethd3_1_raw.l_reference_type(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_abandon FOREIGN KEY (st_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_ad_code FOREIGN KEY (st_ad_code) REFERENCES gracethd3_1_raw.t_adresse(ad_code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_avct FOREIGN KEY (st_avct) REFERENCES gracethd3_1_raw.l_avancement(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_gest FOREIGN KEY (st_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_nd_code FOREIGN KEY (st_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_nra FOREIGN KEY (st_nra) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_prop FOREIGN KEY (st_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_proptyp FOREIGN KEY (st_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_statut FOREIGN KEY (st_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_typelog FOREIGN KEY (st_typelog) REFERENCES gracethd3_1_raw.l_site_type_log(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_typephy FOREIGN KEY (st_typephy) REFERENCES gracethd3_1_raw.l_site_type_phy(code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_abandon FOREIGN KEY (ti_abandon) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_ba_code FOREIGN KEY (ti_ba_code) REFERENCES gracethd3_1_raw.t_baie(ba_code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_prop FOREIGN KEY (ti_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_rf_code FOREIGN KEY (ti_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_type FOREIGN KEY (ti_type) REFERENCES gracethd3_1_raw.l_tiroir_type(code);
ALTER TABLE gracethd3_1_raw.t_tranchee ADD CONSTRAINT fk_t_tranchee_tr_couptyp FOREIGN KEY (tr_couptyp) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_tranchee ADD CONSTRAINT fk_t_tranchee_tr_dtclass FOREIGN KEY (tr_dtclass) REFERENCES gracethd3_1_raw.l_geoloc_classe(code);
ALTER TABLE gracethd3_1_raw.t_tranchee ADD CONSTRAINT fk_t_tranchee_tr_pa1 FOREIGN KEY (tr_pa1) REFERENCES gracethd3_1_raw.t_pointaccueil(pa_code);
ALTER TABLE gracethd3_1_raw.t_tranchee ADD CONSTRAINT fk_t_tranchee_tr_pa2 FOREIGN KEY (tr_pa2) REFERENCES gracethd3_1_raw.t_pointaccueil(pa_code);
ALTER TABLE gracethd3_1_raw.t_zdep ADD CONSTRAINT fk_t_zdep_zd_nd_code FOREIGN KEY (zd_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_zdep ADD CONSTRAINT fk_t_zdep_zd_statut FOREIGN KEY (zd_statut) REFERENCES gracethd3_1_raw.l_statut(code);
ALTER TABLE gracethd3_1_raw.t_zdep ADD CONSTRAINT fk_t_zdep_zd_zs_code FOREIGN KEY (zd_zs_code) REFERENCES gracethd3_1_raw.t_zsro(zs_code);
ALTER TABLE gracethd3_1_raw.t_znro ADD CONSTRAINT fk_t_znro_zn_etat FOREIGN KEY (zn_etat) REFERENCES gracethd3_1_raw.l_nro_etat(code);
ALTER TABLE gracethd3_1_raw.t_znro ADD CONSTRAINT fk_t_znro_zn_lc_code FOREIGN KEY (zn_lc_code) REFERENCES gracethd3_1_raw.t_local(lc_code);
ALTER TABLE gracethd3_1_raw.t_znro ADD CONSTRAINT fk_t_znro_zn_nd_code FOREIGN KEY (zn_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_actif FOREIGN KEY (zs_actif) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_etatpm FOREIGN KEY (zs_etatpm) REFERENCES gracethd3_1_raw.l_sro_etat(code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_lc_code FOREIGN KEY (zs_lc_code) REFERENCES gracethd3_1_raw.t_local(lc_code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_zn_code FOREIGN KEY (zs_zn_code) REFERENCES gracethd3_1_raw.t_znro(zn_code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_ietat FOREIGN KEY (ad_ietat) REFERENCES gracethd3_1_raw.l_adresse_etat(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_imneuf FOREIGN KEY (ad_imneuf) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_isole FOREIGN KEY (ad_isole) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_itypeim FOREIGN KEY (ad_itypeim) REFERENCES gracethd3_1_raw.l_immeuble(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_nat FOREIGN KEY (ad_nat) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_prio FOREIGN KEY (ad_prio) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_prop FOREIGN KEY (ad_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_racc FOREIGN KEY (ad_racc) REFERENCES gracethd3_1_raw.l_implantation(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_raclong FOREIGN KEY (ad_raclong) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_adresse ADD CONSTRAINT fk_t_adresse_ad_typzone FOREIGN KEY (ad_typzone) REFERENCES gracethd3_1_raw.l_zone_densite(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_etat FOREIGN KEY (ba_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_baie ADD CONSTRAINT fk_t_baie_ba_user FOREIGN KEY (ba_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_etat FOREIGN KEY (cb_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_tech FOREIGN KEY (cb_tech) REFERENCES gracethd3_1_raw.l_technologie(code);
ALTER TABLE gracethd3_1_raw.t_cable ADD CONSTRAINT fk_t_cable_cb_user FOREIGN KEY (cb_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_cableline ADD CONSTRAINT fk_t_cableline_cl_dtclass FOREIGN KEY (cl_dtclass) REFERENCES gracethd3_1_raw.l_geoloc_mode(code);
ALTER TABLE gracethd3_1_raw.t_cableline ADD CONSTRAINT fk_t_cableline_cl_geolmod FOREIGN KEY (cl_geolmod) REFERENCES gracethd3_1_raw.l_geoloc_classe(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_etat FOREIGN KEY (bp_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_occp FOREIGN KEY (bp_occp) REFERENCES gracethd3_1_raw.l_occupation(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_racco FOREIGN KEY (bp_racco) REFERENCES gracethd3_1_raw.l_bp_racco(code);
ALTER TABLE gracethd3_1_raw.t_ebp ADD CONSTRAINT fk_t_ebp_bp_user FOREIGN KEY (bp_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_fibre ADD CONSTRAINT fk_t_fibre_fo_color FOREIGN KEY (fo_color) REFERENCES gracethd3_1_raw.l_fo_color(code);
ALTER TABLE gracethd3_1_raw.t_fibre ADD CONSTRAINT fk_t_fibre_fo_proptyp FOREIGN KEY (fo_proptyp) REFERENCES gracethd3_1_raw.l_propriete(code);
ALTER TABLE gracethd3_1_raw.t_fibre ADD CONSTRAINT fk_t_fibre_fo_reper FOREIGN KEY (fo_reper) REFERENCES gracethd3_1_raw.l_tube(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_clim FOREIGN KEY (lc_clim) REFERENCES gracethd3_1_raw.l_clim(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_etat FOREIGN KEY (lc_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_occp FOREIGN KEY (lc_occp) REFERENCES gracethd3_1_raw.l_occupation(code);
ALTER TABLE gracethd3_1_raw.t_local ADD CONSTRAINT fk_t_local_lc_user FOREIGN KEY (lc_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_organisme ADD CONSTRAINT fk_t_organisme_or_ad_code FOREIGN KEY (or_ad_code) REFERENCES gracethd3_1_raw.t_adresse(ad_code);
ALTER TABLE gracethd3_1_raw.t_position ADD CONSTRAINT fk_t_position_ps_etat FOREIGN KEY (ps_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_a_passa FOREIGN KEY (pt_a_passa) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_a_strat FOREIGN KEY (pt_a_strat) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_ad_code FOREIGN KEY (pt_ad_code) REFERENCES gracethd3_1_raw.t_adresse(ad_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_detec FOREIGN KEY (pt_detec) REFERENCES gracethd3_1_raw.l_bool(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_etat FOREIGN KEY (pt_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_gest_do FOREIGN KEY (pt_gest_do) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_occp FOREIGN KEY (pt_occp) REFERENCES gracethd3_1_raw.l_occupation(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_prop_do FOREIGN KEY (pt_prop_do) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_rf_code FOREIGN KEY (pt_rf_code) REFERENCES gracethd3_1_raw.t_reference(rf_code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_typelog FOREIGN KEY (pt_typelog) REFERENCES gracethd3_1_raw.l_ptech_type_log(code);
ALTER TABLE gracethd3_1_raw.t_ptech ADD CONSTRAINT fk_t_ptech_pt_user FOREIGN KEY (pt_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_reference ADD CONSTRAINT fk_t_reference_rf_etat FOREIGN KEY (rf_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_reference ADD CONSTRAINT fk_t_reference_rf_fabric FOREIGN KEY (rf_fabric) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_etat FOREIGN KEY (st_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_site ADD CONSTRAINT fk_t_site_st_user FOREIGN KEY (st_user) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_tiroir ADD CONSTRAINT fk_t_tiroir_ti_etat FOREIGN KEY (ti_etat) REFERENCES gracethd3_1_raw.l_etat(code);
ALTER TABLE gracethd3_1_raw.t_zdep ADD CONSTRAINT fk_t_zdep_zd_gest FOREIGN KEY (zd_gest) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_zdep ADD CONSTRAINT fk_t_zdep_zd_prop FOREIGN KEY (zd_prop) REFERENCES gracethd3_1_raw.t_organisme(or_code);
ALTER TABLE gracethd3_1_raw.t_znro ADD CONSTRAINT fk_t_znro_zn_nrotype FOREIGN KEY (zn_nrotype) REFERENCES gracethd3_1_raw.l_nro_type(code);
ALTER TABLE gracethd3_1_raw.t_zpbo ADD CONSTRAINT fk_t_zpbo_zp_bp_code FOREIGN KEY (zp_bp_code) REFERENCES gracethd3_1_raw.t_ebp(bp_code);
ALTER TABLE gracethd3_1_raw.t_zpbo ADD CONSTRAINT fk_t_zpbo_zp_nd_code FOREIGN KEY (zp_nd_code) REFERENCES gracethd3_1_raw.t_noeud(nd_code);
ALTER TABLE gracethd3_1_raw.t_zpbo ADD CONSTRAINT fk_t_zpbo_zp_zs_code FOREIGN KEY (zp_zs_code) REFERENCES gracethd3_1_raw.t_zsro(zs_code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_ad_code FOREIGN KEY (zs_ad_code) REFERENCES gracethd3_1_raw.t_adresse(ad_code);
ALTER TABLE gracethd3_1_raw.t_zsro ADD CONSTRAINT fk_t_zsro_zs_typeemp FOREIGN KEY (zs_typeemp) REFERENCES gracethd3_1_raw.l_sro_emplacement(code);

-- Total : 175 clés étrangères créées

-- ============================================================================
-- 5. INDEX
-- ============================================================================

-- 5a. Index spatiaux (GiST) sur les colonnes géométriques

CREATE INDEX idx_t_cableline_geom_gist ON gracethd3_1_raw.t_cableline USING GIST (geom);
CREATE INDEX idx_t_cheminement_geom_gist ON gracethd3_1_raw.t_cheminement USING GIST (geom);
CREATE INDEX idx_t_noeud_geom_gist ON gracethd3_1_raw.t_noeud USING GIST (geom);
CREATE INDEX idx_t_point_leve_geom_gist ON gracethd3_1_raw.t_point_leve USING GIST (geom);
CREATE INDEX idx_t_pointaccueil_geom_gist ON gracethd3_1_raw.t_pointaccueil USING GIST (geom);
CREATE INDEX idx_t_tranchee_geom_gist ON gracethd3_1_raw.t_tranchee USING GIST (geom);
CREATE INDEX idx_t_zdep_geom_gist ON gracethd3_1_raw.t_zdep USING GIST (geom);
CREATE INDEX idx_t_znro_geom_gist ON gracethd3_1_raw.t_znro USING GIST (geom);
CREATE INDEX idx_t_zsro_geom_gist ON gracethd3_1_raw.t_zsro USING GIST (geom);
CREATE INDEX idx_t_adresse_geom_gist ON gracethd3_1_raw.t_adresse USING GIST (geom);
CREATE INDEX idx_t_zpbo_geom_gist ON gracethd3_1_raw.t_zpbo USING GIST (geom);

-- 5b. Index B-tree sur les colonnes FK (performance des jointures)

CREATE INDEX idx_t_adresse_ad_dta ON gracethd3_1_raw.t_adresse (ad_dta);
CREATE INDEX idx_t_adresse_ad_geolmod ON gracethd3_1_raw.t_adresse (ad_geolmod);
CREATE INDEX idx_t_adresse_ad_gest ON gracethd3_1_raw.t_adresse (ad_gest);
CREATE INDEX idx_t_adresse_ad_iaccgst ON gracethd3_1_raw.t_adresse (ad_iaccgst);
CREATE INDEX idx_t_baie_ba_abandon ON gracethd3_1_raw.t_baie (ba_abandon);
CREATE INDEX idx_t_baie_ba_gest ON gracethd3_1_raw.t_baie (ba_gest);
CREATE INDEX idx_t_baie_ba_lc_code ON gracethd3_1_raw.t_baie (ba_lc_code);
CREATE INDEX idx_t_baie_ba_prop ON gracethd3_1_raw.t_baie (ba_prop);
CREATE INDEX idx_t_baie_ba_proptyp ON gracethd3_1_raw.t_baie (ba_proptyp);
CREATE INDEX idx_t_baie_ba_rf_code ON gracethd3_1_raw.t_baie (ba_rf_code);
CREATE INDEX idx_t_baie_ba_statut ON gracethd3_1_raw.t_baie (ba_statut);
CREATE INDEX idx_t_baie_ba_type ON gracethd3_1_raw.t_baie (ba_type);
CREATE INDEX idx_t_cab_chem_cc_cb_code ON gracethd3_1_raw.t_cab_chem (cc_cb_code);
CREATE INDEX idx_t_cab_chem_cc_cm_code ON gracethd3_1_raw.t_cab_chem (cc_cm_code);
CREATE INDEX idx_t_cable_cb_abandon ON gracethd3_1_raw.t_cable (cb_abandon);
CREATE INDEX idx_t_cable_cb_avct ON gracethd3_1_raw.t_cable (cb_avct);
CREATE INDEX idx_t_cable_cb_ba1 ON gracethd3_1_raw.t_cable (cb_ba1);
CREATE INDEX idx_t_cable_cb_ba2 ON gracethd3_1_raw.t_cable (cb_ba2);
CREATE INDEX idx_t_cable_cb_bp1 ON gracethd3_1_raw.t_cable (cb_bp1);
CREATE INDEX idx_t_cable_cb_bp2 ON gracethd3_1_raw.t_cable (cb_bp2);
CREATE INDEX idx_t_cable_cb_fo_type ON gracethd3_1_raw.t_cable (cb_fo_type);
CREATE INDEX idx_t_cable_cb_gest ON gracethd3_1_raw.t_cable (cb_gest);
CREATE INDEX idx_t_cable_cb_nd1 ON gracethd3_1_raw.t_cable (cb_nd1);
CREATE INDEX idx_t_cable_cb_nd2 ON gracethd3_1_raw.t_cable (cb_nd2);
CREATE INDEX idx_t_cable_cb_prop ON gracethd3_1_raw.t_cable (cb_prop);
CREATE INDEX idx_t_cable_cb_proptyp ON gracethd3_1_raw.t_cable (cb_proptyp);
CREATE INDEX idx_t_cable_cb_rf_code ON gracethd3_1_raw.t_cable (cb_rf_code);
CREATE INDEX idx_t_cable_cb_statut ON gracethd3_1_raw.t_cable (cb_statut);
CREATE INDEX idx_t_cable_cb_typelog ON gracethd3_1_raw.t_cable (cb_typelog);
CREATE INDEX idx_t_cable_cb_typephy ON gracethd3_1_raw.t_cable (cb_typephy);
CREATE INDEX idx_t_cassette_cs_bp_code ON gracethd3_1_raw.t_cassette (cs_bp_code);
CREATE INDEX idx_t_cassette_cs_rf_code ON gracethd3_1_raw.t_cassette (cs_rf_code);
CREATE INDEX idx_t_cassette_cs_type ON gracethd3_1_raw.t_cassette (cs_type);
CREATE INDEX idx_t_cheminement_cm_avct ON gracethd3_1_raw.t_cheminement (cm_avct);
CREATE INDEX idx_t_cheminement_cm_gest ON gracethd3_1_raw.t_cheminement (cm_gest);
CREATE INDEX idx_t_cheminement_cm_ndcode1 ON gracethd3_1_raw.t_cheminement (cm_ndcode1);
CREATE INDEX idx_t_cheminement_cm_ndcode2 ON gracethd3_1_raw.t_cheminement (cm_ndcode2);
CREATE INDEX idx_t_cheminement_cm_prop ON gracethd3_1_raw.t_cheminement (cm_prop);
CREATE INDEX idx_t_cheminement_cm_statut ON gracethd3_1_raw.t_cheminement (cm_statut);
CREATE INDEX idx_t_cheminement_cm_typ_imp ON gracethd3_1_raw.t_cheminement (cm_typ_imp);
CREATE INDEX idx_t_cheminement_cm_typelog ON gracethd3_1_raw.t_cheminement (cm_typelog);
CREATE INDEX idx_t_ebp_bp_abandon ON gracethd3_1_raw.t_ebp (bp_abandon);
CREATE INDEX idx_t_ebp_bp_avct ON gracethd3_1_raw.t_ebp (bp_avct);
CREATE INDEX idx_t_ebp_bp_gest ON gracethd3_1_raw.t_ebp (bp_gest);
CREATE INDEX idx_t_ebp_bp_lc_code ON gracethd3_1_raw.t_ebp (bp_lc_code);
CREATE INDEX idx_t_ebp_bp_prop ON gracethd3_1_raw.t_ebp (bp_prop);
CREATE INDEX idx_t_ebp_bp_proptyp ON gracethd3_1_raw.t_ebp (bp_proptyp);
CREATE INDEX idx_t_ebp_bp_pt_code ON gracethd3_1_raw.t_ebp (bp_pt_code);
CREATE INDEX idx_t_ebp_bp_rf_code ON gracethd3_1_raw.t_ebp (bp_rf_code);
CREATE INDEX idx_t_ebp_bp_statut ON gracethd3_1_raw.t_ebp (bp_statut);
CREATE INDEX idx_t_ebp_bp_typelog ON gracethd3_1_raw.t_ebp (bp_typelog);
CREATE INDEX idx_t_ebp_bp_typephy ON gracethd3_1_raw.t_ebp (bp_typephy);
CREATE INDEX idx_t_fibre_fo_cb_code ON gracethd3_1_raw.t_fibre (fo_cb_code);
CREATE INDEX idx_t_fibre_fo_etat ON gracethd3_1_raw.t_fibre (fo_etat);
CREATE INDEX idx_t_local_lc_abandon ON gracethd3_1_raw.t_local (lc_abandon);
CREATE INDEX idx_t_local_lc_avct ON gracethd3_1_raw.t_local (lc_avct);
CREATE INDEX idx_t_local_lc_bp_codf ON gracethd3_1_raw.t_local (lc_bp_codf);
CREATE INDEX idx_t_local_lc_bp_codp ON gracethd3_1_raw.t_local (lc_bp_codp);
CREATE INDEX idx_t_local_lc_elec ON gracethd3_1_raw.t_local (lc_elec);
CREATE INDEX idx_t_local_lc_gest ON gracethd3_1_raw.t_local (lc_gest);
CREATE INDEX idx_t_local_lc_prop ON gracethd3_1_raw.t_local (lc_prop);
CREATE INDEX idx_t_local_lc_proptyp ON gracethd3_1_raw.t_local (lc_proptyp);
CREATE INDEX idx_t_local_lc_st_code ON gracethd3_1_raw.t_local (lc_st_code);
CREATE INDEX idx_t_local_lc_statut ON gracethd3_1_raw.t_local (lc_statut);
CREATE INDEX idx_t_local_lc_typelog ON gracethd3_1_raw.t_local (lc_typelog);
CREATE INDEX idx_t_love_lv_cb_code ON gracethd3_1_raw.t_love (lv_cb_code);
CREATE INDEX idx_t_love_lv_nd_code ON gracethd3_1_raw.t_love (lv_nd_code);
CREATE INDEX idx_t_pointaccueil_pa_dtclass ON gracethd3_1_raw.t_pointaccueil (pa_dtclass);
CREATE INDEX idx_t_pointaccueil_pa_gest ON gracethd3_1_raw.t_pointaccueil (pa_gest);
CREATE INDEX idx_t_pointaccueil_pa_nature ON gracethd3_1_raw.t_pointaccueil (pa_nature);
CREATE INDEX idx_t_pointaccueil_pa_prop ON gracethd3_1_raw.t_pointaccueil (pa_prop);
CREATE INDEX idx_t_pointaccueil_pa_secu ON gracethd3_1_raw.t_pointaccueil (pa_secu);
CREATE INDEX idx_t_pointaccueil_pa_typephy ON gracethd3_1_raw.t_pointaccueil (pa_typephy);
CREATE INDEX idx_t_position_ps_1 ON gracethd3_1_raw.t_position (ps_1);
CREATE INDEX idx_t_position_ps_2 ON gracethd3_1_raw.t_position (ps_2);
CREATE INDEX idx_t_position_ps_cs_code ON gracethd3_1_raw.t_position (ps_cs_code);
CREATE INDEX idx_t_position_ps_fonct ON gracethd3_1_raw.t_position (ps_fonct);
CREATE INDEX idx_t_position_ps_ti_code ON gracethd3_1_raw.t_position (ps_ti_code);
CREATE INDEX idx_t_position_ps_type ON gracethd3_1_raw.t_position (ps_type);
CREATE INDEX idx_t_ptech_pt_abandon ON gracethd3_1_raw.t_ptech (pt_abandon);
CREATE INDEX idx_t_ptech_pt_avct ON gracethd3_1_raw.t_ptech (pt_avct);
CREATE INDEX idx_t_ptech_pt_gest ON gracethd3_1_raw.t_ptech (pt_gest);
CREATE INDEX idx_t_ptech_pt_nature ON gracethd3_1_raw.t_ptech (pt_nature);
CREATE INDEX idx_t_ptech_pt_prop ON gracethd3_1_raw.t_ptech (pt_prop);
CREATE INDEX idx_t_ptech_pt_proptyp ON gracethd3_1_raw.t_ptech (pt_proptyp);
CREATE INDEX idx_t_ptech_pt_secu ON gracethd3_1_raw.t_ptech (pt_secu);
CREATE INDEX idx_t_ptech_pt_statut ON gracethd3_1_raw.t_ptech (pt_statut);
CREATE INDEX idx_t_ptech_pt_typephy ON gracethd3_1_raw.t_ptech (pt_typephy);
CREATE INDEX idx_t_reference_rf_type ON gracethd3_1_raw.t_reference (rf_type);
CREATE INDEX idx_t_site_st_abandon ON gracethd3_1_raw.t_site (st_abandon);
CREATE INDEX idx_t_site_st_ad_code ON gracethd3_1_raw.t_site (st_ad_code);
CREATE INDEX idx_t_site_st_avct ON gracethd3_1_raw.t_site (st_avct);
CREATE INDEX idx_t_site_st_gest ON gracethd3_1_raw.t_site (st_gest);
CREATE INDEX idx_t_site_st_nra ON gracethd3_1_raw.t_site (st_nra);
CREATE INDEX idx_t_site_st_prop ON gracethd3_1_raw.t_site (st_prop);
CREATE INDEX idx_t_site_st_proptyp ON gracethd3_1_raw.t_site (st_proptyp);
CREATE INDEX idx_t_site_st_statut ON gracethd3_1_raw.t_site (st_statut);
CREATE INDEX idx_t_site_st_typelog ON gracethd3_1_raw.t_site (st_typelog);
CREATE INDEX idx_t_site_st_typephy ON gracethd3_1_raw.t_site (st_typephy);
CREATE INDEX idx_t_tiroir_ti_abandon ON gracethd3_1_raw.t_tiroir (ti_abandon);
CREATE INDEX idx_t_tiroir_ti_ba_code ON gracethd3_1_raw.t_tiroir (ti_ba_code);
CREATE INDEX idx_t_tiroir_ti_prop ON gracethd3_1_raw.t_tiroir (ti_prop);
CREATE INDEX idx_t_tiroir_ti_rf_code ON gracethd3_1_raw.t_tiroir (ti_rf_code);
CREATE INDEX idx_t_tiroir_ti_type ON gracethd3_1_raw.t_tiroir (ti_type);
CREATE INDEX idx_t_tranchee_tr_couptyp ON gracethd3_1_raw.t_tranchee (tr_couptyp);
CREATE INDEX idx_t_tranchee_tr_dtclass ON gracethd3_1_raw.t_tranchee (tr_dtclass);
CREATE INDEX idx_t_tranchee_tr_pa1 ON gracethd3_1_raw.t_tranchee (tr_pa1);
CREATE INDEX idx_t_tranchee_tr_pa2 ON gracethd3_1_raw.t_tranchee (tr_pa2);
CREATE INDEX idx_t_zdep_zd_statut ON gracethd3_1_raw.t_zdep (zd_statut);
CREATE INDEX idx_t_zdep_zd_zs_code ON gracethd3_1_raw.t_zdep (zd_zs_code);
CREATE INDEX idx_t_znro_zn_etat ON gracethd3_1_raw.t_znro (zn_etat);
CREATE INDEX idx_t_znro_zn_lc_code ON gracethd3_1_raw.t_znro (zn_lc_code);
CREATE INDEX idx_t_znro_zn_nd_code ON gracethd3_1_raw.t_znro (zn_nd_code);
CREATE INDEX idx_t_zsro_zs_actif ON gracethd3_1_raw.t_zsro (zs_actif);
CREATE INDEX idx_t_zsro_zs_etatpm ON gracethd3_1_raw.t_zsro (zs_etatpm);
CREATE INDEX idx_t_zsro_zs_lc_code ON gracethd3_1_raw.t_zsro (zs_lc_code);
CREATE INDEX idx_t_zsro_zs_zn_code ON gracethd3_1_raw.t_zsro (zs_zn_code);
CREATE INDEX idx_t_adresse_ad_ietat ON gracethd3_1_raw.t_adresse (ad_ietat);
CREATE INDEX idx_t_adresse_ad_imneuf ON gracethd3_1_raw.t_adresse (ad_imneuf);
CREATE INDEX idx_t_adresse_ad_isole ON gracethd3_1_raw.t_adresse (ad_isole);
CREATE INDEX idx_t_adresse_ad_itypeim ON gracethd3_1_raw.t_adresse (ad_itypeim);
CREATE INDEX idx_t_adresse_ad_nat ON gracethd3_1_raw.t_adresse (ad_nat);
CREATE INDEX idx_t_adresse_ad_prio ON gracethd3_1_raw.t_adresse (ad_prio);
CREATE INDEX idx_t_adresse_ad_prop ON gracethd3_1_raw.t_adresse (ad_prop);
CREATE INDEX idx_t_adresse_ad_racc ON gracethd3_1_raw.t_adresse (ad_racc);
CREATE INDEX idx_t_adresse_ad_raclong ON gracethd3_1_raw.t_adresse (ad_raclong);
CREATE INDEX idx_t_adresse_ad_typzone ON gracethd3_1_raw.t_adresse (ad_typzone);
CREATE INDEX idx_t_baie_ba_etat ON gracethd3_1_raw.t_baie (ba_etat);
CREATE INDEX idx_t_baie_ba_user ON gracethd3_1_raw.t_baie (ba_user);
CREATE INDEX idx_t_cable_cb_etat ON gracethd3_1_raw.t_cable (cb_etat);
CREATE INDEX idx_t_cable_cb_tech ON gracethd3_1_raw.t_cable (cb_tech);
CREATE INDEX idx_t_cable_cb_user ON gracethd3_1_raw.t_cable (cb_user);
CREATE INDEX idx_t_cableline_cl_dtclass ON gracethd3_1_raw.t_cableline (cl_dtclass);
CREATE INDEX idx_t_cableline_cl_geolmod ON gracethd3_1_raw.t_cableline (cl_geolmod);
CREATE INDEX idx_t_ebp_bp_etat ON gracethd3_1_raw.t_ebp (bp_etat);
CREATE INDEX idx_t_ebp_bp_occp ON gracethd3_1_raw.t_ebp (bp_occp);
CREATE INDEX idx_t_ebp_bp_racco ON gracethd3_1_raw.t_ebp (bp_racco);
CREATE INDEX idx_t_ebp_bp_user ON gracethd3_1_raw.t_ebp (bp_user);
CREATE INDEX idx_t_fibre_fo_color ON gracethd3_1_raw.t_fibre (fo_color);
CREATE INDEX idx_t_fibre_fo_proptyp ON gracethd3_1_raw.t_fibre (fo_proptyp);
CREATE INDEX idx_t_fibre_fo_reper ON gracethd3_1_raw.t_fibre (fo_reper);
CREATE INDEX idx_t_local_lc_clim ON gracethd3_1_raw.t_local (lc_clim);
CREATE INDEX idx_t_local_lc_etat ON gracethd3_1_raw.t_local (lc_etat);
CREATE INDEX idx_t_local_lc_occp ON gracethd3_1_raw.t_local (lc_occp);
CREATE INDEX idx_t_local_lc_user ON gracethd3_1_raw.t_local (lc_user);
CREATE INDEX idx_t_organisme_or_ad_code ON gracethd3_1_raw.t_organisme (or_ad_code);
CREATE INDEX idx_t_position_ps_etat ON gracethd3_1_raw.t_position (ps_etat);
CREATE INDEX idx_t_ptech_pt_a_passa ON gracethd3_1_raw.t_ptech (pt_a_passa);
CREATE INDEX idx_t_ptech_pt_a_strat ON gracethd3_1_raw.t_ptech (pt_a_strat);
CREATE INDEX idx_t_ptech_pt_ad_code ON gracethd3_1_raw.t_ptech (pt_ad_code);
CREATE INDEX idx_t_ptech_pt_detec ON gracethd3_1_raw.t_ptech (pt_detec);
CREATE INDEX idx_t_ptech_pt_etat ON gracethd3_1_raw.t_ptech (pt_etat);
CREATE INDEX idx_t_ptech_pt_gest_do ON gracethd3_1_raw.t_ptech (pt_gest_do);
CREATE INDEX idx_t_ptech_pt_occp ON gracethd3_1_raw.t_ptech (pt_occp);
CREATE INDEX idx_t_ptech_pt_prop_do ON gracethd3_1_raw.t_ptech (pt_prop_do);
CREATE INDEX idx_t_ptech_pt_rf_code ON gracethd3_1_raw.t_ptech (pt_rf_code);
CREATE INDEX idx_t_ptech_pt_typelog ON gracethd3_1_raw.t_ptech (pt_typelog);
CREATE INDEX idx_t_ptech_pt_user ON gracethd3_1_raw.t_ptech (pt_user);
CREATE INDEX idx_t_reference_rf_etat ON gracethd3_1_raw.t_reference (rf_etat);
CREATE INDEX idx_t_reference_rf_fabric ON gracethd3_1_raw.t_reference (rf_fabric);
CREATE INDEX idx_t_site_st_etat ON gracethd3_1_raw.t_site (st_etat);
CREATE INDEX idx_t_site_st_user ON gracethd3_1_raw.t_site (st_user);
CREATE INDEX idx_t_tiroir_ti_etat ON gracethd3_1_raw.t_tiroir (ti_etat);
CREATE INDEX idx_t_zdep_zd_gest ON gracethd3_1_raw.t_zdep (zd_gest);
CREATE INDEX idx_t_zdep_zd_prop ON gracethd3_1_raw.t_zdep (zd_prop);
CREATE INDEX idx_t_znro_zn_nrotype ON gracethd3_1_raw.t_znro (zn_nrotype);
CREATE INDEX idx_t_zpbo_zp_nd_code ON gracethd3_1_raw.t_zpbo (zp_nd_code);
CREATE INDEX idx_t_zpbo_zp_zs_code ON gracethd3_1_raw.t_zpbo (zp_zs_code);
CREATE INDEX idx_t_zsro_zs_ad_code ON gracethd3_1_raw.t_zsro (zs_ad_code);
CREATE INDEX idx_t_zsro_zs_typeemp ON gracethd3_1_raw.t_zsro (zs_typeemp);

-- ============================================================================
-- 6. COMMENTAIRES DE DOCUMENTATION
-- ============================================================================
-- Chaque table et colonne est documentée avec sa définition officielle.
-- Visible via \dt+ et \d+ dans psql ou dans pgAdmin/DBeaver.

-- 6a. Commentaires sur les tables

COMMENT ON TABLE gracethd3_1_raw.t_adresse IS 'Adresse — Adresses telles qu''''identifiées par les opérateurs. Cette classe d''''objets participe à la génération de Fichiers d''''Informations Préalable (IPE), pour l''''activation des services opérateurs auprès des abonnés. Peut identifier une plaque adresse ou un bâtiment. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_baie IS 'Baie — Regroupe la liste des baies et des fermes contenus dans les locaux techniques. (1 enregistrement par item). [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_cab_chem IS 'Lié à l''implémentation — Relations entre les câbles et les cheminement en remplacement de la table t_conduite, t_cond_chem et t_cab_cond, modélisant les passages de câbles. [Spatial: Non]';
COMMENT ON TABLE gracethd3_1_raw.t_cable IS 'Cable — Tronçon de câble du réseau de fibre optique. [Spatial: Héritage CableLine]';
COMMENT ON TABLE gracethd3_1_raw.t_cableline IS 'Lié à l''implémentation — Les câbles nécessitant une géométrie (globalement les câbles cheminant en extrasite) peuvent être modélisés dans cette table. Les câbles ne nécessitant pas de géométrie (globalement les câbles intrasites comme les jarretières, breakouts, etc.) n''''ont ainsi pas besoin d''''être modélisés géométriquement. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_cassette IS 'Cassette — Cassettes contenues dans les éléments de branchements passifs du réseau (voir définition classe <ElementBranchementPassif>) et modules contenus dans les tiroirs. [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_cheminement IS 'Cheminement — Un cheminement représente, entre deux points techniques/sites : - Un parcours physique approchant pour l’infrastructure GC créé. Le cheminement exact est livré dans la table t_tranchee. - Un parcours physique à partir des données de l’exploitant pour les infrastructures existantes. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_ebp IS 'ElementBranchementPassif — Regroupement des éléments du réseau ayant un rôle passif dans le branchement optique (ex :PBO, BPE, PTO …etc.). [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_fibre IS 'Fibre — Fibres optiques constituant les câbles. [Spatial: Héritage CableLine]';
COMMENT ON TABLE gracethd3_1_raw.t_local IS 'Local — Un local est un sous ensemble d''''un site (logement, local entreprise, local technique…etc.). [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_love IS 'Lié à l''implémentation — Permet de localiser les loves de câble. Chaque enregistrement associe un câble à un Nœud Physique, ainsi qu''''une longueur de love. [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_noeud IS 'Nœud — Classe abstraite portant la géométrie d''''un site ou d''''un point technique. Classe mère de <PointTechnique> et <Site>. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_organisme IS 'Organisme — Coordonnées et identification d''''organismes publics et privés [Spatial: Non]';
COMMENT ON TABLE gracethd3_1_raw.t_point_leve IS 'PointLevé — Cette classe décrit les points levés spécifiques au réseau et permet d’indiquer la profondeur ou l’altimétrie connue en certains points des tranchées. L’indication de la charge à la génératrice a pour objet de répondre à l’obligation de mentionner les points de l’ouvrage qui ne satisferaient pas à l’éventuelle règle de profondeur minimale réglementaire à la date de pose de l’ouvrage. Cette information est intrinsèquement moins fiable que les indications d’altitude de l’ouvrage, le terrain naturel ayant pu évoluer depuis la pose. Elle est donc à limiter à cet usage. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_pointaccueil IS 'PointAccueil — Cette classe regroupe: ​ - Les sites et les points techniques du Génie Civil créé lors du déploiement du réseau de fibre optique. ​ - Les sites ou points techniques d''''extrémité d''''un linéaire de Génie Civil créé lors du déploiement du réseau de fibre optique. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_position IS 'Position — Smoove lorsque la position appartient à une cassette, corps de traversée lorsque la position appartient à un tiroir ou une tête optique. [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_ptech IS 'PointTechnique — Liste des Points Techniques faisant partie de l''''Infrastructure de Génie Civil souterraine et aérienne. Il pourra donc s''''agir de ponctuel de type chambre, poteau, traverse, crochet de façade, fixation d''''encorbellement, … etc. [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_reference IS 'Reference — Référence de matériel ou de coupe type. [Spatial: Non]';
COMMENT ON TABLE gracethd3_1_raw.t_site IS 'Site — Regroupe les sites techniques et les sites d''''habitation. (Pavillons, immeubles, shelters, armoires de rue…etc.). [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_tiroir IS 'Tiroir — Regroupe la liste des tiroirs (donc positionnés en baie), et des têtes de câble optiques (positionnées sur des fermes). (1 enregistrement par item). [Spatial: Héritage noeud]';
COMMENT ON TABLE gracethd3_1_raw.t_tranchee IS 'Tranchée — Element linéaire de Génie Civil créé lors du déploiement du réseau de fibre optique. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_zdep IS 'ZoneDeploiement — Zone de déploiement. Pour définir des zones correspondant à des phases de déploiement. [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_znro IS 'ZoneArriereNRO — Zone arrière d''''un Noeud de Raccordement Optique (NRO). [Spatial: Oui]';
COMMENT ON TABLE gracethd3_1_raw.t_zsro IS 'ZoneArriereSRO — Zone Arrière d''''un Sous-Répartiteur Optique (SRO). [Spatial: Oui]';

-- 6b. Commentaires sur les colonnes

COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_alias IS 'Eventuellement le nom en langue régionale ou une autre appellation différente de l’appellation officielle';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_ban_id IS 'Identifiant Base Adresse Nationale';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_batcode IS 'Identifiant du bâtiment dans une base de données externe.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_code IS 'Code unique de l''adresse.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_codtemp IS 'Code temporaire avant création de l''ad_batcode';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_commune IS 'Nom officiel de la commune';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_datmodi IS 'Date de dernière mise à jour de l''adresse (changement d''un attribut, de la géométrie, modification liée à l''adresse ex : changement de liaison adresse/EBP)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_distinf IS 'Distance en mètres de raccordement selon définition dans le marché.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_dta IS '1 si un Diagnostic Technique Amiante (DTA) est obligatoire, 0 si ce n’est pas le cas.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_fantoir IS 'Identifiant FANTOIR contenu dans le fichier des propriétés bâtis de la DGFiP';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_geolmod IS 'Mode d''implantation de l''objet.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_geolqlt IS 'Précision du positionnement de l''objet, estimée en mètres. La précision doit être déduite du mode d''implantation et du support d''implantation, en tenant compte selon les cas du cumul des imprécisions : des levés ou du fond de plan (utiliser dans ce cas la classe de précision planimétrique au sens de l''arrêté du 16 septembre 2003), de l''outil de détection, des cotations, de l''éventuel report ''à main levée'', etc.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_gest IS 'Gestionnaire d''immeuble (entreprise ou personne) dans le référentiel des gestionnaires (Conditionnel IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_hexacle IS 'Code HEXACLE';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_hexaclv IS 'Code HEXACLE Voie. Correspond au 0 de la voie. Est différent de l''Hexavia. La bonne pratique est de le renseigner s''il existe et particulierement en l''absence d''hexaclé';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_iaccgst IS 'Permet de savoir si un accord du gestionnaire d''immeuble (copropriété, syndic, etc.) est nécessaire (1) ou non (0) pour aller raccorder l''adresse. (Obligatoire IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_idatcab IS 'Date prévisionnelle ou effective du câblage de l''adresse c''est à dire de déploiement de l''adresse. Cette date correspond à la date à laquelle EtatImmeuble passera à l''état déployé et l''adresse sera raccordable. (obligatoire IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_idatcom IS 'Ce champ correspond à la date à laquelle le raccordement effectif d''un client final à cet immeuble est possible du point de vue de la réglementation. Il correspond à la date d''ouverture à la commercialisation d''une ligne. (Facultatif IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_idatimn IS 'Ce champ est utilisé dans le cadre des immeubles neufs et facultatif. Il permet à l''opérateur d''immeuble d''indiquer la date prévisionnelle de livraison de l''immeuble indiquée par le constructeur de l''immeuble. Cette date constitue une tendance sans garantie de mise à jour par l''opérateur d''immeuble. (Facultatif IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_idatsgn IS 'Date de la signature de la convention avec le gestionnaire de l''immeuble. (Conditionnel IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_idpar IS 'Identifiant de la parcelle de référence. Notion base MAJIC.';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_code IS 'Code baie ou ferme';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_etiquet IS 'Etiquette sur le terrain';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_gest IS 'Gestionnaire de la baie/ferme';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_lc_code IS 'Code du local dans lequel se trouve la baie/ferme';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_nb_u IS 'Taille de la baie en nombre de U';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_prop IS 'Propriétaire de la baie/ferme';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_rf_code IS 'Identifiant de la référence de la baie/ferme dans la table référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_type IS 'Type du contenant selon qu''il s''agisse d''une BAIE ou d''une FERME.';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_cb_code IS 'Code câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_cm_code IS 'Code du cheminement par lequel passe le câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_ba1 IS 'Code de la baie à l''extrémité amont (sens NRO vers PTO) du câble. En cas d’éclatement sur plusieurs baies, saisir la baie principale.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_ba2 IS 'Code de la baie à l''extrémité aval (Sens NRO vers PTO) du câble. En cas d’éclatement sur plusieurs baies, saisir la baie principale.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_bp1 IS 'Code de l’élément de branchement passif à l''extrémité amont (sens NRO vers PTO) du câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_bp2 IS 'Code de l’élément de branchement passif à l''extrémité aval (Sens NRO vers PTO) du câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_cabphy IS 'Identifiant unique qui permet de reconstituer le câble physique (identifiant commun à tous les tronçons constituant le câble). Un câble physique est découpé en tronçon à chaque passage d''ebp.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_capafo IS 'Capacité du câble (Nombre total de fibres présentes).';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_code IS 'Code câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_etiquet IS 'Etiquette sur le terrain';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_fo_disp IS 'Nombre de fibres présentes dans le câble et encore disponibles (différence entre le nombre total de fibres et le nombre de fibres utilisées)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_fo_type IS 'Type de fibre (G652, G655, G657, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_fo_util IS 'Nombre de fibres utiles sur le segment d''infrastructure pour desservir les locaux clients situés en aval (incluant les besoins de l''infrastructure d''imbrication), corrigé en fonction de la localisation et du dénombrement des locaux clients après relevé terrain.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_gest IS 'Gestionnaire du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_modulo IS 'Nombre de fibres par tube (6, 12)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_nd1 IS 'Code du nœud à l''extrémité amont (sens NRO vers PTO) du câble. Pour un cable intrasite (jarretière, etc.) cb_nd1 et cb_nd2 seront identiques.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_nd2 IS 'Code du nœud à l''extrémité aval (sens NRO vers PTO) du câble. Pour un cable intrasite (jarretière, etc.) cb_nd1 et cb_nd2 seront identiques.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_prop IS 'Propriétaire du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_r1_code IS 'Code d''un référencement du réseau 1 (plaque, dsp, BM, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_r2_code IS 'Code d''un référencement du réseau 2 (poche, tronçon, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_r3_code IS 'Code d''un référencement du réseau 3 (secteur, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_rf_code IS 'Identifiant de la référence du câble dans la table référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_typelog IS 'Type logique du câble (collecte, transport, distribution, etc.).';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_typephy IS 'Type physique du câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_cb_code IS 'Code unique du câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_code IS 'Code unique permettant d''identifier une géométrie modélisant un câble.';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.geom IS 'Ligne';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_bp_code IS 'Identifiant unique de l''EBP auquel appartient la cassette';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_code IS 'Code unique de la cassette (ou du module dans un tiroir).';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_face IS 'Face du BPE sur laquelle est enfichée la cassette/le module dans un tiroir';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_num IS 'Numéro de la cassette (ou du module dans un tiroir) dans l''organiseur du BPE.';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_rf_code IS 'Identifiant unique dans la table référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_type IS 'Type de cassette (ou du module dans un tiroir) dans un tiroir (SOUDURE, LOVAGE, SPLITTER, CONNECTEUR, …etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_code IS 'Code du cheminement.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_compo IS 'Attribut d''aggrégation décrivant la composition du multitubulaire.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_gest IS 'Gestionnaire de la conduite du cheminement';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_ndcode1 IS 'Code du Noeud à une extrémité du cheminement.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_ndcode2 IS 'Code du Noeud à l''autre extrémité du cheminement.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_prop IS 'Propriétaire de la conduite du cheminement';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_typ_imp IS 'Type d''implantation';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_typelog IS 'Type logique de l''infrastructure';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.geom IS 'Ligne';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_code IS 'Code de la BPE, etc.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_etiquet IS 'Etiquette sur le terrain';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_gest IS 'Gestionnaire de l''élément';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_lc_code IS 'Identifiant unique du local dans lequel est installé l''ebp.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_prop IS 'Propriétaire de l''élément';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_pt_code IS 'Code point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_rf_code IS 'Référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_typelog IS 'Type de l''élément';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_typephy IS 'Type physique d''élément de branchement passif. Capacité de soudure.';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_cb_code IS 'Identifiant unique du câble auquel la fibre appartient';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_code IS 'Identifiant unique de la fibre';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_etat IS 'Etat de fonctionnement de la fibre.';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_nincab IS 'Numéro de fibre dans le câble';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_nintub IS 'Numéro de la fibre dans le tube (1 à 12, …)';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_numtub IS 'Numéro du tube auquel appartient la fibre';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_bat IS 'Nom du bâtiment';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_bp_codf IS 'Code du PBO pré-identifié pour alimenter le local en FTTH.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_bp_codp IS 'Code du PBO FTTE ou BPE pré-identifié pour alimenter le local sur les usages point à point de type FTTE, FTTO, GFU, FON';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_code IS 'Code du local';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_elec IS 'Présence d''une alimentation électrique';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_escal IS 'Nom ou numéro d’escalier du local';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_etage IS 'Numéro d’étage du local.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_etiquet IS 'Nom du local tel qu''étiqueté sur le terrain (selon règles et plages de nommage)';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_gest IS 'Gestionnaire du local.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_prop IS 'Propriétaire du local.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_st_code IS 'Identifiant unique contenu dans la classe SITE';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_typelog IS 'Type logique du local';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_cb_code IS 'Code du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_id IS 'Identifiant unique pouvant être auto-incrémenté (selon plages d''identitifiants)';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_long IS 'longueur du love du câble dans le nœud en mètre';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_nd_code IS 'Code du nœud dans lequel est positionné ce love';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.geom IS 'Point abstrait';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_code IS 'Code noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_code IS 'Code de l''organisme';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_commune IS 'Nom officiel de la commune';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_local IS 'Complément d''adresse pour identifier le local-';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_nom IS 'Nom de l''opérateur, de la collectivité, de l''entreprise, etc-';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_nomvoie IS 'Nom de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_numero IS 'Numéro éventuel de l’adresse dans la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_postal IS 'Code postal du bureau de distribution de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_rep IS 'Indice de répétition associé au numéro (par exemple Bis, A, 1…)';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_siret IS 'Numéro SIRET dans le cas d''un établissement (sens INSEE, base SIRENE)';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_type IS 'Classification juridique- Littéral ou nomenclature INSEE-';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.geom IS 'Géométrie du point levé';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.pl_charge IS 'Charge (profondeur) de la génératrice supérieure du réseau (=0 pour les affleurants) en cm';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.pl_code IS 'Code du point levé';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.pl_x IS 'X en lambert 93';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.pl_y IS 'Y en lambert 93';
COMMENT ON COLUMN gracethd3_1_raw.t_point_leve.pl_z IS 'Z de la génératrice supérieure de réseau en IGN69';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.geom IS 'Point';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_a_haut IS 'Hauteur en mètre entre le sol et la base de l''infrastructure (réseau en façade ou aérien)';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_a_struc IS 'Simple, Moisé, Haubané, Couple, …';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_code IS 'Code du ponctuel';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_codtemp IS 'Code temporaire avant création du codeext.';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_dtclass IS 'Classe de précision du point d''accueil au sens du décret DT/DICT';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_gest IS 'Gestionnaire du point d''accueil';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_nature IS 'Nature du point technique/site .';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_prop IS 'Propriétaire';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_rotatio IS 'Angle du grand axe du point technique en degrés dans le sens retrograde (sens des aiguilles d''une montre) à partir du Nord.';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_secu IS 'Point technique/site équipé d''un système de verrouillage, ou tout autre système permettant d''en sécuriser l''accès.';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_typephy IS 'Type de point technique/site .';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_1 IS 'Code unique de la fibre en entrée de la cassette.(pour continuité route optique)';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_2 IS 'Code unique de la fibre en sortie de la cassette.(pour continuité route optique)';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_code IS 'Code unique.';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_cs_code IS 'Identifiant unique de la CASSETTE à laquelle appartient la position. (le cas échéant)';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_fonct IS 'Type de connectorisation (Connecteur, epissure, pigtail, ….)';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_numero IS 'Position (numéro de compartiment) du smoove ou du connecteur';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_ti_code IS 'Identifiant unique du TIROIR / de la TCOP à laquelle appartient la position. (cas échéant)';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_type IS 'Type de connecteur / soudure.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_haut IS 'Hauteur en mètre entre le sol et la base de l''infrastructure (réseau en façade ou aérien)';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_struc IS 'Simple, Moisé, Haubané, Couple, …';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_code IS 'Code du point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_commune IS 'Nom officiel de la commune';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_etiquet IS 'Etiquette sur le terrain';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_gest IS 'Gestionnaire du point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_insee IS 'Code INSEE de la commune';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_nature IS 'Nature du point technique.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_nd_code IS 'Code noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_nomvoie IS 'Nom de la voie d’accès la plus proche.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_numero IS 'Si le point technique possède ou est à proximité d’une adresse postale, possibilité de saisir le numéro de plaque adresse.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_prop IS 'Propriétaire';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_rep IS 'Indice de répétition associé au numéro (par exemple Bis, A, 1…)';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_secu IS 'Point technique équipé d''un système de verrouillage, ou tout autre système permettant d''en sécuriser l''accès.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_typephy IS 'Type de point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_code IS 'Code permettant d''identifier la référence d''un matériel dans la base.';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_design IS 'Design';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_type IS 'Type de matériel';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_ad_code IS 'Identifiant unique contenu dans la table ADRESSE';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_avct IS 'Attribut synthétisant l''avancement. Utile pour distinguer en phase d''étude ce qui est existant et à créer.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_code IS 'Code du site';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_commune IS 'Nom officiel de la commune.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_design IS 'Concaténation "codecouleur" + separateur espace +"type de revétement"';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_gest IS 'Identifiant du gestionnaire du site.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_insee IS 'Code INSEE de la commune.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nd_code IS 'Identifiant unique contenu dans la table Noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nombat IS 'Nom du bâtiment.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nomvoie IS 'Nom de la voie.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nra IS 'Site NRA (1) ou non (0).';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_postal IS 'Code postal du bureau de distribution de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_prop IS 'Identifiant du propriétaire du site.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_rep IS 'Indice de répétition associé au numéro (par exemple Bis, A, 1…).';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_typelog IS 'Type logique du site (Réseau ou Client)';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_typephy IS 'Type physique du site (shelter, armoire de rue, bâti…etc.).';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_abandon IS 'Défini si l''entité est abandonnée ou non dans un SI';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_ba_code IS 'Identifiant unique contenu dans la table t_baie';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_code IS 'Code du tiroir optique';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_etiquet IS 'Etiquette sur le terrain';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_perirec IS 'Identifiant de perimetre récolé à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_placemt IS 'Position du tiroir en "nombre de U"';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_prop IS 'Propriétaire du tiroir';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_rf_code IS 'Identifiant de la référence du tiroir dans la table référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_taille IS 'Taille du tiroir en nombre de U';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_type IS 'Type du contenant selon qu''il s''agisse d''un TIROIR ou d''une TETE DE CABLE.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.geom IS 'Ligne';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_code IS 'Code de la tranchée.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_compo IS 'Attribut d''aggrégation décrivant la composition du multitubulaire.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_couptyp IS 'Référence à une coupe type';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_dtclass IS 'Classe de précision au sens du décret DT-DICT.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_lgreel IS 'Longueur en mètres mesurée sur le terrain ou estimée.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_pa1 IS 'Référence au point d''accueil d’une extrémité de l''ensemble de tranchées - constituant un cheminement - dont la tranchée fait partie.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_pa2 IS 'Référence au point d''accueil de l''autre extrémité de l''ensemble de tranchées - constituant un cheminement - dont la tranchée fait partie.';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_perirec IS 'Identifiant du périmètre récolé livré à un instant t';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.geom IS 'Surface de couverture';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_code IS 'Code de zone de déploiement d''infrastructure.';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_nd_code IS 'Code interne hérité du Noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_r1_code IS 'Code d''un référencement du réseau 1 (plaque, dsp, BM, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_r2_code IS 'Code d''un référencement du réseau 2 (poche, tronçon, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_r3_code IS 'Code d''un référencement du réseau 3 (secteur, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_r4_code IS 'Code d''un référencement du réseau 4';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_statut IS 'Statut de déploiement.';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_zs_code IS 'Code de la Zone arrière de SRO parente s''il s''agit d''une subdivision.';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.geom IS 'Surface de couverture';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_code IS 'Code la zone arrière de NRO';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_etat IS 'Etat d''avancement du NRO (Interop CPN)';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_lc_code IS 'Local (fonctionnel) ayant la fonction de NRO.';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_nd_code IS 'Code interne hérité du Noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_nroref IS 'Référence du NRO (Interop CPN)';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_r1_code IS 'Code d''un référencement du réseau 1 (plaque, dsp, BM, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_r2_code IS 'Code d''un référencement du réseau 2 (poche, tronçon, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.geom IS 'Surface de couverture';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_actif IS 'IPE: Indique s''il y a de l''electricité au SRO pour permettre à un opérateur commercial d''y disposer des équipements actifs.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_capamax IS 'IPE : Capacité maximum théorique du SRO .';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_code IS 'Code la zone arrière de SRO';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_etatpm IS 'IPE : Doit être renseigné dès lors que le SRO apparait dans l''IPE.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_lc_code IS 'Local (fonctionnel) ayant la fonction de SRO .';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_lgmaxln IS 'Longueur maximale des lignes situées dans la zone arrière du SRO . Elle est exprimée en kilomètres avec avec 2 chiffres après la virgule (Interop : LongueurMaxLignes)';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_nblogmt IS 'IPE : Ce champ correspond au nombre total de logements dans la zone arrière du SRO Technique (c''est à dire nombre de logements total : ciblé, signé, déployé). Dans le cadre d''un SRO Intérieur il correspond à l''ensemble des logements raccordables. Dans le cadre d''un SRO Extérieur, il correspond à l''ensemble des logements dans la zone arrière du SRO , quel que soit leur statut';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_r1_code IS 'Code d''un référencement du réseau 1 (plaque, dsp, BM, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_r2_code IS 'Code d''un référencement du réseau 2 (poche, tronçon, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_r3_code IS 'Code d''un référencement du réseau 3 (secteur, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_refpm IS 'IPE : Référence SRO propre à chaque OI et pérenne. La reference SRO est obligatoire dès lors que le SRO est en cours de déploiement et ne peut apparaître avant. La référence SRO est celle du SRO de Regroupement dans le cas de plusieurs SRO Techniques rattachés au même SRO .';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_zn_code IS 'Code de la Zone Arrière de NRO correspondante.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_znllong IS 'Ce champ correspond à la longueur du lien entre le SRO et le NRO, en kilomètres avec 2 chiffres après la virgule ou le point. Conditionné à la présence d''une ReferenceLienPMPRDM (Interop : LongueurLienPMPRDM)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_ietat IS 'Permet d''indiquer l''avancement du déploiement. (Obligatoire IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_imneuf IS 'Ce champ permet d''indiquer s''il s''agit d''un habitat en cours de construction (1) pendant le déploiement du SRO qui le dessert. (Facultatif IPE). Si ce n''est pas le cas (0).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_insee IS 'Identifiant INSEE de la commune fondé sur le COG en cours';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_isole IS 'Pour distinguer les locaux de type client considérés comme isolés (1), de ceux qui ne le sont pas (0) (distance supérieure au maximum contractuel)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_itypeim IS 'Type d''immeuble (Obligatoire IPE).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nat IS 'Oui si le site n''est pas une propriété privée.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nbfofon IS 'Nombre de fibres noires.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_dateins IS 'Date de pose du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_lgreel IS 'Longueur réelle du câble en mètres (selon retours terrain)';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_dateins IS 'Date d''installation';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_dateins IS 'Date d''installation';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_datecon IS 'Date de construction';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_dateins IS 'Date d''installation';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_numero IS 'Numéro de plaque adresse.';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_nom IS 'Nom que la collectivité donne à la ZNRO';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_nom IS 'Nom que la collectivité donne à la ZSRO';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nbfogfu IS 'Nombre de fibres GFU (Groupement Ferme d''Utilisateurs tel que defini par la decision ARCEP n 05 0208)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nbfotte IS 'Nombre de fibres FTTE (Fibre activée en point-à-point sur la Boucle Locale Optique Mutualisée)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nbfotth IS 'Nombre de fibres FTTH';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nbfotto IS 'Nombre de fibres FTTO (Offre Sur Mesure sans modalites de raccordement reglemente).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblent IS 'Nombre de locaux d’entreprises identifiés comme éligibles à une offre de raccordement spécifique (FTTE, FTTO, FON).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblobj IS 'Nombre de locaux de type objet connectés';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblope IS 'Nombre de locaux exploités exclusivement pour des usages d’opérateurs télécoms.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblpro IS 'Nombre de locaux professionnels.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblpub IS 'Nombre de locaux exploités par des services publics.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nblres IS 'Nombre de locaux résidentiels.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nom_ld IS 'Nom du lieu-dit qui peut être le nom de la voie parfois';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nombat IS 'Ce champ correspond au nom du batiment tel que décrit par l''opérateur d''immeuble en cohérence avec ce qu''il constate sur le terrain. Ce champ peut apparaitre après la publication de l''adresse dans l''IPE car fiabilisé au cours de la phase de piquetage terrain.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_nomvoie IS 'Nom de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_numero IS 'Numéro éventuel de l’adresse dans la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_postal IS 'Code postal du bureau de distribution de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_prio IS 'Le raccordement du site est-il prioritaire (1) ou non (0) ?';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_prop IS 'Propriétaire de l''immeuble (entreprise ou personne)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_racc IS 'Type de raccordement du site';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_raclong IS 'Pour distinguer les raccordements longs (1) des autres raccordements (0)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_rep IS 'Indice de répétition associé au numéro (par exemple Bis, A, 1…)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_rivoli IS 'Code RIVOLI (source Orange) exploité par certains opérateurs.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_section IS 'Section cadastrale pour ceux qui souhaitent utiliser les numéros de parcelles du PCI.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_sracdem IS 'Adresse susceptible d''être raccordable sur demande.';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_typzone IS 'Type de zone de l''adresse desservie. (Obligatoire IPE)';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_x_ban IS 'X en lambert 93';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_x_parc IS 'X en lambert 93 de la parcelle identifiée comme parcelle de référence (base MAJICIII quand disponible).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_y_ban IS 'Y en lambert 93';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.ad_y_parc IS 'Y en lambert 93 de la parcelle identifiée comme parcelle de référence (base MAJICIII quand disponible).';
COMMENT ON COLUMN gracethd3_1_raw.t_adresse.geom IS 'Point abstrait';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_etat IS 'Etat de la BAIE/FERME';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_haut IS 'Hauteur de la baie/ferme en mm';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_larg IS 'Largeur de la baie/ferme en mm';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_prof IS 'Profondeur de la baie/ferme en mm';
COMMENT ON COLUMN gracethd3_1_raw.t_baie.ba_user IS 'Utilisateur';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cab_chem.cc_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_color IS 'Couleur du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_datemes IS 'Date de mise en service du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_diam IS 'Diamètre du câble en millimètres';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_etat IS 'Etat du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_localis IS 'Localisation du câble lorsqu''il s''agit d''un cablage intrasite. Il peut s''agir d''une indication littérale, ou du code d''un tiroir, du code d''un EBP, etc.';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_r4_code IS 'Code d''un référencement du réseau 4';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_tech IS 'Technologie du câble (fibre optique, cuivre, coaxial, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_cable.cb_user IS 'Utilisateur du câble';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_dtclass IS 'Classe de précision au sens du décret DT-DICT';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_geolmod IS 'Mode d''implantation de l''objet.';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_geolqlt IS 'Précision du positionnement de l''objet, estimée en mètres.';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_long IS 'Longueur totale du câble (héritée de la géométrie) en mètres';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cableline.cl_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_cassette.cs_nb_pas IS 'Taille de la cassette (ou du module dans un tiroir) (en nombre de pas)';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_codeext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_cheminement.cm_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_ca_nb IS 'Nombre de cassettes contenues dans l''EBP';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_datemes IS 'Date de mise en service';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_entrees IS 'Nombre d''entrées de câbles.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_etat IS 'État';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_linecod IS 'Code d''une ligne (cas FTTH) selon la nomenclature du régulateur. Cas d''un PTO. (OO-XXXX-XXXX)';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_nb_pas IS 'Nombre de pas de l''organiseur de l''EBP';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_oc_code IS 'Référence OC (Opérateur Commercial) de la prise terminale. Différent de bp_code. Cas d''une PTO uniquement';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_occp IS 'Occupation.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_racco IS 'Codification Interop de l''échec du raccordement. Cas d''une PTO uniquement.';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_ref_kit IS 'Référence du kit d''entrée de câble utilisé';
COMMENT ON COLUMN gracethd3_1_raw.t_ebp.bp_user IS 'Utilisateur de l''élément';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_code_ext IS 'Code chez un tiers ou dans une autre base de données.';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_color IS 'Numéro de fibre selon le code couleur (valeurs à adapter aux usages).';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_proptyp IS 'Type de propriété';
COMMENT ON COLUMN gracethd3_1_raw.t_fibre.fo_reper IS 'Repérage du tube';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_clim IS 'Présence et type du système éventuel de ventilation ou de climatisation.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_datemes IS 'Date de mise en service du local';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_etat IS 'Etat du local.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_idmajic IS 'Identifiant du local dans un référentiel comme la base MAJICIII lorsque disponible.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_local IS 'Informations de localisation';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_occp IS 'Occupation.';
COMMENT ON COLUMN gracethd3_1_raw.t_local.lc_user IS 'Identifiant de l''utilisateur';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_love.lv_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_comment IS 'Commentaires';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_noeud.nd_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_activ IS 'Activité principale exercée- Littéral ou Code NAF-';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_ad_code IS 'Identifiant de l''adresse dans la table t_adresse';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_l331 IS 'Code court selon liste opérateurs L33-1 (téléchargeable sur le site de l''ARCEP)';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_mail IS 'Mail de contact générique';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_nometab IS 'Nom de l''établissement, de l''agence (sens INSEE, base SIRENE)';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_siren IS 'Numéro SIREN de l''opérateur, de la collectivité, …';
COMMENT ON COLUMN gracethd3_1_raw.t_organisme.or_telfixe IS 'Téléphone fixe';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_pointaccueil.pa_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_etat IS 'Etat de fonctionnement de la position / du corps de traversée,';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_position.ps_usetype IS 'Type d’usage d’un alignement de fibres. Sur un réseau FTTH, à renseigner sur la position de la dernière fibre dans le sens NRO vers PTO.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_dan IS 'Effort disponible après pose (exprimé en daN – décanewtons)';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_dtetu IS 'Date de l''étude de charge';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_passa IS '0 si uniquement pour passage de câbles';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_a_strat IS 'Notion Orange disponible dans les PIT. Notion potentiellement extensible à d''autres types de réseaux.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_ad_code IS 'Identifiant unique contenu dans la table t_adresse. Si le point technique n''est pas localisé à une adresse postale précise, nd_voie permet une localisation à l''adresse moins précise.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_datemes IS 'Date de mise en service';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_detec IS 'Présence d''un boitier pour un fil de détection.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_etat IS 'État du point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_gest_do IS 'Gestionnaire de la voirie';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_idpar IS 'Si un point technique en propriété propre n’est pas en domaine public, possibilité de saisir le numéro de parcelle cadastrale.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_local IS 'Complément d''adresse pour identifier le local.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_occp IS 'Occupation.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_postal IS 'Code postal du bureau de distribution de la voie';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_prop_do IS 'Propriétaire de la voirie';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_rf_code IS 'Référence.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_section IS 'Si un point technique en propriété propre n’est pas en domaine public, possibilité de saisir le numéro de section cadastrale.';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_typelog IS 'Usage du point technique';
COMMENT ON COLUMN gracethd3_1_raw.t_ptech.pt_user IS 'Utilisateur';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_comment IS 'Commentaires';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_etat IS 'Disponibilité de la référence';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_fabric IS 'Fabricant';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_reference.rf_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_ban_id IS 'Identifiant de l’adresse dans la base adresse nationale.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_datemes IS 'Date de mise en service';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_etat IS 'Etat du site.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_hexacle IS 'Code hexacle.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_idpar IS 'Numéro de parcelle cadastrale principale.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nblines IS 'Nombre de lignes du site.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_nom IS 'Nom du site.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_section IS 'Numéro de section cadastrale.';
COMMENT ON COLUMN gracethd3_1_raw.t_site.st_user IS 'Utilisateur du site';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_etat IS 'Etat du TIROIR';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_localis IS 'Informations de localisation du tiroir';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_tiroir.ti_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_tranchee.tr_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_gest IS 'Gestionnaire du site';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_zdep.zd_prop IS 'Propriétaire du site';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_datelpm IS 'Date d''installation du lien entre le NRO et le SRO (Interop CPN)';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_etatlpm IS 'Etat d''avancement du lien entre le NRO et le SRO .';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_nrotype IS 'Type de NRO.';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_r3_code IS 'Code d''un référencement du réseau 3 (secteur, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_znro.zn_r4_code IS 'Code d''un référencement du réseau 4';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.geom IS 'Surface de couverture';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_bp_code IS 'Code de l’élément de branchement passif correspondant au PBO.';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_capamax IS 'Capacité en nombre de lignes.';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_code IS 'Code la zone arrière de PBO';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_nd_code IS 'Code interne hérité du Noeud';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_r1_code IS 'Code d''un référencement du réseau 1 (plaque, dsp, BM, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_r2_code IS 'Code d''un référencement du réseau 2 (poche, tronçon, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_r3_code IS 'Code d''un référencement du réseau 3 (secteur, etc.)';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_r4_code IS 'Code d''un référencement du réseau 4';
COMMENT ON COLUMN gracethd3_1_raw.t_zpbo.zp_zs_code IS 'Code de la Zone Arrière de SRO correspondante.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_abddate IS 'Date d''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_abdsrc IS 'Cause de l''abandon de l''objet';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_accgest IS 'Nécessité de l''accord du gestionnaire d''immeuble (copropriété, syndic, etc.) pour raccorder l''adresse';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_ad_code IS 'Code de l''adresse dans la table adresse.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_brassoi IS 'Brassages uniquement par l''OI lui même.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_comment IS 'Commentaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_creadat IS 'Date de création de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_datcomr IS 'Date à laquelle le raccordement effectif d''un client final à ce SRO est possible du point de vue de la réglementation.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_dateins IS 'Date de passage à l''état déployé du SRO .';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_datemad IS 'Date de Première Mise à Disposition du SRO à un opérateur commercial.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_geolsrc IS 'Source de la géolocalisation pour préciser la source si nécessaire';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_majdate IS 'Date de la mise à jour de l''objet en base';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_majsrc IS 'Source utilisée pour la mise à jour';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_nbcolmt IS 'Nombre de colonnes montantes associées au SRO dans les cas de SRO Intérieur.';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_r4_code IS 'Code d''un référencement du réseau 4';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_typeemp IS 'Localisation physique du SRO (façade, poteau, chambre, intérieur…) et/ou type de SRO (shelter, armoire de rue, en sous-sol….).';
COMMENT ON COLUMN gracethd3_1_raw.t_zsro.zs_typeing IS 'Type d''ingénierie (mono, bi, quadri) tel que décrit dans le contrat de l''OI.';


-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================

COMMIT;

-- Pour vérifier l'installation :
--   SELECT table_name FROM information_schema.tables
--   WHERE table_schema = 'gracethd3_1_raw' ORDER BY table_name;
--
--   SELECT f_table_name, f_geometry_column, type, srid
--   FROM geometry_columns
--   WHERE f_table_schema = 'gracethd3_1_raw';
