# ToolboxTelecom
Contient des outils et des scripts pour la gestion de données télécoms et notamment le modèle Gr@ceTHD.

## Validateur Grace en V3.1
Produit un rapport de conformité en fonction d'un conteneur cible (C1 à C4)
Permet un audit rapide d'un fichier GPKG.

## Script de création de base de données postgres GraceTHD 3.1

Voici ce que contient le script SQL (~2600 lignes) :
- 42 tables de listes (l_*) — dont 31 peuplées avec les 543 valeurs de la matrice, et 11 créées vides (référencées en FK mais absentes de MCD_Valeurs, comme l_occupation, l_tube, l_technologie, etc. — à peupler manuellement).
- 25 tables métier (t_*) — créées dans un ordre qui respecte les dépendances de FK, avec tous les types PostgreSQL natifs (VARCHAR, INTEGER, BIGINT, NUMERIC, TIMESTAMP, DATE).
- 11 colonnes géométriques PostGIS (SRID 2154) — 4 POINT (noeud, adresse, pointaccueil, point_leve), 3 LINESTRING (cheminement, cableline, tranchee), 4 MULTIPOLYGON (znro, zsro, zpbo, zdep), chacune avec son AddGeometryColumn pour l'enregistrement dans geometry_columns.
- 175 clés étrangères — vers les listes de valeurs et entre tables métier (ex: cb_nd1 → t_noeud, zp_zs_code → t_zsro, etc.), ajoutées après toutes les CREATE TABLE pour éviter les dépendances circulaires.
- 192 index — 11 GiST spatiaux + 181 B-tree sur les colonnes FK.
- 589 commentaires — 24 sur les tables + 565 sur les colonnes, tirés directement des définitions de la matrice.
Le tout est encapsulé dans une transaction (BEGIN/COMMIT). Le script Python (generate_gracethd_sql.py) permet de régénérer le SQL à partir de l'Excel si la matrice évolue.

Le script Python permet quant à lui de recréer le schéma SQL en se basant sur une nouvelle version de la grille de remplissage (en attendant une nouvelle version...).

### Dépendances Python pour les scripts GraceTHD v3.0.1
# Installation : pip install -r requirements.txt

# Lecture des fichiers Excel (matrice de conformité An_1b)
pandas>=1.5
openpyxl>=3.0

# Génération du rapport PDF d'audit (gracethd_audit.py)
reportlab>=3.6
