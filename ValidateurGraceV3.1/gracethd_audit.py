#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════╗
║           AUDIT GraceTHD v3.1 — Script de conformité            ║
║                                                                  ║
║  Ce script audite un GeoPackage GraceTHD et vérifie sa           ║
║  conformité par rapport au modèle v3.1.                          ║
║                                                                  ║
║  Auteur : Script généré avec Claude (Anthropic)                  ║
║  Version : 2.0 — Complète                                        ║
║  Date : 2026-03-24                                               ║
╚══════════════════════════════════════════════════════════════════╝

PRINCIPES DE CONCEPTION :
    - Chaque test = une fonction indépendante renvoyant une liste de `Issue`
    - La matrice de conformité est chargée depuis l'Excel officiel
    - Le rapport PDF est généré avec reportlab (Platypus)
    - Maintenabilité > Performance : code lisible, commenté, modulaire

TESTS IMPLÉMENTÉS :
    1.  Présence des tables
    2.  Présence des champs
    3.  Valeurs NULL interdites (champs obligatoires)
    4.  Contraintes d'unicité
    5.  Clés étrangères et listes de valeurs
    6.  Géométries NULL
    7.  Géométries invalides (SpatiaLite)
    8.  Types de données des champs
    9.  Cohérence topologique nœuds/lignes
    10. Inclusion spatiale des zones
    11. Chevauchement des zones de même niveau

USAGE :
    python gracethd_audit.py <chemin_geopackage> [--excel <chemin_matrice>] [--conteneur C1|C2|C3|C4]
"""

import argparse
import os
import re
import sys
import sqlite3
from datetime import datetime
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Tuple

import pandas as pd

# =============================================================================
# 1. MODÈLES DE DONNÉES
# =============================================================================

@dataclass
class Issue:
    """
    Représente une anomalie détectée lors de l'audit.

    Attributs :
        categorie : Famille du test (ex: "1. Présence des tables")
        severite  : "ERREUR", "AVERTISSEMENT" ou "INFO"
        table     : Nom de la table concernée (ou None si global)
        champ     : Nom du champ concerné (ou None si test sur table)
        message   : Description lisible de l'anomalie
        detail    : Détail complémentaire optionnel
    """
    categorie: str
    severite: str  # "ERREUR", "AVERTISSEMENT", "INFO"
    table: Optional[str]
    champ: Optional[str]
    message: str
    detail: str = ""


@dataclass
class AuditResult:
    """
    Résultat complet d'un audit GraceTHD.
    """
    fichier_gpkg: str
    conteneur: str
    date_audit: str = field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d %H:%M"))
    issues: List[Issue] = field(default_factory=list)

    @property
    def nb_erreurs(self) -> int:
        return sum(1 for i in self.issues if i.severite == "ERREUR")

    @property
    def nb_avertissements(self) -> int:
        return sum(1 for i in self.issues if i.severite == "AVERTISSEMENT")

    @property
    def nb_infos(self) -> int:
        return sum(1 for i in self.issues if i.severite == "INFO")

    @property
    def est_conforme(self) -> bool:
        return self.nb_erreurs == 0

    def issues_par_categorie(self) -> Dict[str, List[Issue]]:
        result = {}
        for issue in self.issues:
            if issue.categorie not in result:
                result[issue.categorie] = []
            result[issue.categorie].append(issue)
        return result

    def issues_par_table(self) -> Dict[str, List[Issue]]:
        """Regroupe les issues par table pour le résumé."""
        result = {}
        for issue in self.issues:
            key = issue.table or "(global)"
            if key not in result:
                result[key] = []
            result[key].append(issue)
        return result


# =============================================================================
# 2. CHARGEMENT DE LA MATRICE DE CONFORMITÉ
# =============================================================================

class GraceTHDModel:
    """
    Charge et structure les règles du modèle GraceTHD v3.1
    depuis le fichier Excel de conformité officiel (An_1b).
    """

    def __init__(self, chemin_excel: str):
        print(f"[INFO] Chargement de la matrice : {chemin_excel}")
        self.chemin = chemin_excel

        # --- Tables (MCD_Classes) ---
        df_classes = pd.read_excel(chemin_excel, sheet_name='MCD_Classes', header=0)
        df_classes.columns = [c.replace('\xa0', ' ').replace('\n', ' ').strip() for c in df_classes.columns]
        self.tables = df_classes

        # --- Attributs (MCD_Attributs) ---
        df_attr = pd.read_excel(chemin_excel, sheet_name='MCD_Attributs', header=0)
        df_attr.columns = [
            'table_name', 'attr_name', 'attr_v2', 'type_sql', 'type_gpkg',
            'contraintes', 'relation', 'definition',
            'c1', 'c2', 'c3', 'c4',
            'condition', 'regle_gestion', 'commentaire',
            'comparaison_v3', 'test_c3c4', 'desc_changements'
        ]
        df_attr['table_name'] = df_attr['table_name'].astype(str).str.strip()
        df_attr['attr_name'] = df_attr['attr_name'].astype(str).str.strip()
        # Attributs actifs v3.1 uniquement
        self.attributs = df_attr[df_attr['test_c3c4'] == 1].copy()
        print(f"  -> {len(self.attributs)} attributs actifs v3.1")

        # --- Valeurs de listes (MCD_Valeurs) ---
        self.valeurs = pd.read_excel(chemin_excel, sheet_name='MCD_Valeurs', header=0)
        print(f"  -> {len(self.valeurs)} valeurs de listes")

    # ----- Méthodes d'accès aux tables -----

    def get_tables_for_conteneur(self, conteneur: str) -> List[str]:
        """Tables requises (O ou C) pour un conteneur donné."""
        col = f"Conteneur {conteneur[-1]}"
        mask = self.tables[col].isin(['O', 'C'])
        return self.tables.loc[mask, 'Nom de la table'].str.strip().tolist()

    def get_tables_obligatoires_for_conteneur(self, conteneur: str) -> List[str]:
        """Tables strictement obligatoires (O) pour un conteneur."""
        col = f"Conteneur {conteneur[-1]}"
        mask = self.tables[col] == 'O'
        return self.tables.loc[mask, 'Nom de la table'].str.strip().tolist()

    def get_tables_conditionnelles_for_conteneur(self, conteneur: str) -> List[str]:
        col = f"Conteneur {conteneur[-1]}"
        mask = self.tables[col] == 'C'
        return self.tables.loc[mask, 'Nom de la table'].str.strip().tolist()

    def get_table_statut(self, table_name: str, conteneur: str) -> str:
        """Retourne O/C/N pour une table et un conteneur."""
        col = f"Conteneur {conteneur[-1]}"
        row = self.tables[self.tables['Nom de la table'].str.strip() == table_name]
        if row.empty:
            return 'N'
        return str(row.iloc[0][col])

    # ----- Méthodes d'accès aux attributs -----

    def get_attributs_for_table(self, table_name: str, conteneur: str) -> pd.DataFrame:
        """Attributs attendus (O ou C) pour une table et un conteneur."""
        col_c = f"c{conteneur[-1]}"
        mask = (
            (self.attributs['table_name'] == table_name) &
            (self.attributs[col_c].isin(['O', 'C']))
        )
        return self.attributs[mask]

    def get_all_attributs_for_table(self, table_name: str) -> pd.DataFrame:
        """Tous les attributs v3.1 pour une table (O, C et N)."""
        return self.attributs[self.attributs['table_name'] == table_name]

    def get_attributs_obligatoires(self, table_name: str, conteneur: str) -> pd.DataFrame:
        col_c = f"c{conteneur[-1]}"
        mask = (
            (self.attributs['table_name'] == table_name) &
            (self.attributs[col_c] == 'O')
        )
        return self.attributs[mask]

    def get_attributs_avec_contrainte(self, table_name: str, mot_cle: str) -> pd.DataFrame:
        mask = (
            (self.attributs['table_name'] == table_name) &
            (self.attributs['contraintes'].str.contains(mot_cle, case=False, na=False))
        )
        return self.attributs[mask]

    def get_foreign_keys(self, table_name: str, conteneur: str) -> pd.DataFrame:
        col_c = f"c{conteneur[-1]}"
        mask = (
            (self.attributs['table_name'] == table_name) &
            (self.attributs['relation'].notna()) &
            (self.attributs[col_c].isin(['O', 'C']))
        )
        return self.attributs[mask]

    # ----- Géométrie -----

    def is_table_spatiale(self, table_name: str) -> bool:
        row = self.tables[self.tables['Nom de la table'].str.strip() == table_name]
        if row.empty:
            return self.attributs[
                (self.attributs['table_name'] == table_name) &
                (self.attributs['attr_name'] == 'geom')
            ].shape[0] > 0
        spatiale = str(row.iloc[0].get('Spatiale ?', 'Non'))
        return spatiale != 'Non'

    def get_geometry_type(self, table_name: str) -> Optional[str]:
        geom_attr = self.attributs[
            (self.attributs['table_name'] == table_name) &
            (self.attributs['attr_name'] == 'geom')
        ]
        if geom_attr.empty:
            return None
        return str(geom_attr.iloc[0]['type_gpkg'])

    # ----- Listes de valeurs -----

    def get_valeurs_liste(self, nom_liste: str) -> List[str]:
        mask = self.valeurs['TABLE'] == nom_liste
        return self.valeurs.loc[mask, 'code'].astype(str).tolist()

    # ----- Parsing -----

    def parse_relation(self, relation_str: str) -> Tuple[Optional[str], Optional[str]]:
        """Parse 'REFERENCES t_table (champ)'. Retourne (table_cible, champ_cible)."""
        match = re.search(r'REFERENCES\s+(\w+)\s*\((\w+)\)', str(relation_str).strip())
        if match:
            return match.group(1), match.group(2)
        return None, None

    def get_expected_gpkg_type_family(self, type_gpkg: str) -> str:
        """Normalise un type GPKG en famille pour comparaison."""
        t = str(type_gpkg).strip().upper()
        if any(k in t for k in ['GEOMETRY', 'POINT', 'LINE', 'POLYGON', 'MULTI']):
            return 'GEOMETRY'
        if any(t.startswith(k) for k in ['TEXT', 'STRING', 'LONGUEUR', 'VARCHAR']):
            return 'TEXT'
        if any(t.startswith(k) for k in ['REAL', 'DOUBLE', 'FLOAT']):
            return 'REAL'
        if any(t.startswith(k) for k in ['INTEGER', 'INT', 'SMALLINT']):
            return 'INTEGER'
        if any(t.startswith(k) for k in ['TIMESTAMP', 'DATE']):
            return 'TEXT'
        return 'TEXT'

    @staticmethod
    def sqlite_type_to_family(sqlite_type: str) -> str:
        """Normalise un type SQLite en famille."""
        t = str(sqlite_type).strip().upper()
        if any(k in t for k in ['BLOB', 'GEOM', 'POINT', 'LINE', 'POLYGON']):
            return 'GEOMETRY'
        if any(k in t for k in ['TEXT', 'CHAR', 'VARCHAR', 'STRING', 'CLOB']):
            return 'TEXT'
        if any(k in t for k in ['REAL', 'DOUBLE', 'FLOAT', 'NUMERIC']):
            return 'REAL'
        if 'INT' in t:
            return 'INTEGER'
        return 'TEXT'


# =============================================================================
# 3. ACCÈS AU GEOPACKAGE
# =============================================================================

class GeoPackageReader:
    """Interface simplifiée pour lire un GeoPackage via SQLite."""

    def __init__(self, chemin_gpkg: str):
        if not os.path.exists(chemin_gpkg):
            raise FileNotFoundError(f"GeoPackage introuvable : {chemin_gpkg}")
        self.chemin = chemin_gpkg
        self.conn = sqlite3.connect(chemin_gpkg)
        try:
            self.conn.enable_load_extension(True)
        except Exception:
            pass
        self._spatialite_loaded = False
        self.spatialite_path = None  # Sera défini par run_audit si --spatialite est passé
        print(f"[INFO] GeoPackage ouvert : {chemin_gpkg}")

    def close(self):
        self.conn.close()

    def get_tables(self) -> List[str]:
        cursor = self.conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'gpkg_%' AND name NOT LIKE 'rtree_%' "
            "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'trigger_%'")
        return [row[0] for row in cursor.fetchall()]

    def get_columns(self, table_name: str) -> List[Dict]:
        cursor = self.conn.execute(f"PRAGMA table_info('{table_name}')")
        return [{'name': r[1], 'type': r[2], 'notnull': bool(r[3]), 'pk': bool(r[5])} for r in cursor.fetchall()]

    def get_column_names(self, table_name: str) -> List[str]:
        return [col['name'] for col in self.get_columns(table_name)]

    def get_row_count(self, table_name: str) -> int:
        return self.conn.execute(f'SELECT COUNT(*) FROM "{table_name}"').fetchone()[0]

    def execute_query(self, sql: str, params=None) -> list:
        cursor = self.conn.execute(sql, params) if params else self.conn.execute(sql)
        return cursor.fetchall()

    def has_table(self, table_name: str) -> bool:
        return table_name.lower() in {t.lower() for t in self.get_tables()}

    def load_spatialite(self, spatialite_path: str = None) -> bool:
        """
        Charge l'extension SpatiaLite.

        Sur Windows avec Python 3.8+, le PATH système n'est plus utilisé
        pour chercher les DLL. Il faut déclarer explicitement le dossier
        contenant mod_spatialite.dll via os.add_dll_directory().

        Paramètres :
            spatialite_path : Chemin vers le dossier contenant mod_spatialite.
                              Si None, utilise self.spatialite_path ou les
                              emplacements standards.
        """
        if self._spatialite_loaded:
            return True

        # Utiliser le chemin stocké si aucun n'est passé en paramètre
        if spatialite_path is None:
            spatialite_path = self.spatialite_path

        # --- Sur Windows, déclarer les dossiers DLL ---
        if sys.platform == 'win32' and hasattr(os, 'add_dll_directory'):
            # Dossiers candidats à déclarer
            dll_dirs = []
            if spatialite_path:
                dll_dirs.append(spatialite_path)
            # Chemins fréquents sur Windows
            dll_dirs += [
                r"C:\spatialite",
                os.path.join(os.environ.get('CONDA_PREFIX', ''), 'Library', 'bin'),
                os.path.join(os.environ.get('OSGEO4W_ROOT', r'C:\OSGeo4W'), 'bin'),
            ]
            for d in dll_dirs:
                if os.path.isdir(d):
                    try:
                        os.add_dll_directory(d)
                    except OSError:
                        pass

        # --- Tenter le chargement ---
        libs = ['mod_spatialite']
        if sys.platform == 'win32':
            # Ajouter les chemins complets sur Windows
            for d in [spatialite_path, r"C:\spatialite"]:
                if d and os.path.isdir(d):
                    libs.append(os.path.join(d, 'mod_spatialite'))
        else:
            libs += ['libspatialite', 'mod_spatialite.so', 'mod_spatialite.dylib']

        for lib in libs:
            try:
                self.conn.load_extension(lib)
                self._spatialite_loaded = True
                return True
            except Exception:
                continue
        return False


# =============================================================================
# 4. FONCTIONS DE TEST
# =============================================================================

def test_presence_tables(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 1 : Présence de toutes les tables attendues."""
    issues = []
    cat = "1. Presence des tables"
    tables_gpkg_lower = {t.lower(): t for t in reader.get_tables()}

    for table in model.get_tables_obligatoires_for_conteneur(conteneur):
        if table.lower() not in tables_gpkg_lower:
            issues.append(Issue(cat, "ERREUR", table, None,
                f"Table obligatoire absente pour {conteneur}",
                f"La table '{table}' est marquee 'O' dans le modele GraceTHD v3.1."))

    for table in model.get_tables_conditionnelles_for_conteneur(conteneur):
        if table.lower() not in tables_gpkg_lower:
            issues.append(Issue(cat, "AVERTISSEMENT", table, None,
                f"Table conditionnelle absente pour {conteneur}",
                f"Table '{table}' marquee 'C'. Son absence peut etre justifiee."))

    tables_modele = set(model.tables['Nom de la table'].str.strip().str.lower())
    tables_modele |= set(model.attributs['table_name'].str.lower().unique())
    for t_low, t_real in tables_gpkg_lower.items():
        if t_low not in tables_modele:
            issues.append(Issue(cat, "INFO", t_real, None,
                "Table non referencee dans le modele GraceTHD v3.1",
                "Table specifique a votre organisation."))

    if not any(i.severite == "ERREUR" for i in issues):
        issues.append(Issue(cat, "INFO", None, None,
            f"Toutes les tables obligatoires du {conteneur} sont presentes."))
    return issues


def test_presence_champs(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 2 : Présence de tous les champs attendus."""
    issues = []
    cat = "2. Presence des champs"
    col_c = f"c{conteneur[-1]}"

    for table in reader.get_tables():
        attrs = model.get_attributs_for_table(table, conteneur)
        if attrs.empty:
            continue
        cols_gpkg = {c.lower() for c in reader.get_column_names(table)}

        for _, attr in attrs.iterrows():
            if attr['attr_name'].lower() not in cols_gpkg:
                sev = "ERREUR" if attr[col_c] == 'O' else "AVERTISSEMENT"
                msg = "Champ obligatoire absent" if sev == "ERREUR" else "Champ conditionnel absent"
                detail = f"Type attendu : {attr['type_gpkg']}"
                if sev == "AVERTISSEMENT" and pd.notna(attr.get('condition')):
                    detail += f" | Condition : {str(attr['condition'])[:100]}"
                issues.append(Issue(cat, sev, table, attr['attr_name'], msg, detail))
    return issues


def test_contraintes_not_null(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 3 : Les champs 'Obligatoire' ne doivent pas contenir de NULL."""
    issues = []
    cat = "3. Valeurs NULL interdites"

    for table in reader.get_tables():
        attrs = model.get_attributs_obligatoires(table, conteneur)
        attrs = attrs[attrs['contraintes'].str.contains('Obligatoire', case=False, na=False)]
        if attrs.empty:
            continue
        cols_gpkg = {c.lower() for c in reader.get_column_names(table)}

        for _, attr in attrs.iterrows():
            nom = attr['attr_name'].lower()
            if nom not in cols_gpkg:
                continue
            try:
                if nom == 'geom':
                    sql = f'SELECT COUNT(*) FROM "{table}" WHERE "{nom}" IS NULL'
                else:
                    sql = f'SELECT COUNT(*) FROM "{table}" WHERE "{nom}" IS NULL OR TRIM(CAST("{nom}" AS TEXT)) = \'\''
                cnt = reader.execute_query(sql)[0][0]
                total = reader.get_row_count(table)
                if cnt > 0:
                    issues.append(Issue(cat, "ERREUR", table, attr['attr_name'],
                        f"{cnt} valeur(s) NULL ou vide sur {total} enregistrement(s)",
                        "Champ marque 'Obligatoire' : aucune valeur nulle autorisee."))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                    f"Impossible de verifier les NULL : {e}"))
    return issues


def test_contraintes_unique(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 4 : Les champs UNIQUE ne doivent pas contenir de doublons."""
    issues = []
    cat = "4. Contraintes d'unicite"
    col_c = f"c{conteneur[-1]}"

    for table in reader.get_tables():
        attrs = model.get_attributs_avec_contrainte(table, 'UNIQUE')
        attrs = attrs[attrs[col_c].isin(['O', 'C'])]
        if attrs.empty:
            continue
        cols_gpkg = {c.lower() for c in reader.get_column_names(table)}

        for _, attr in attrs.iterrows():
            nom = attr['attr_name'].lower()
            if nom not in cols_gpkg:
                continue
            try:
                doublons = reader.execute_query(
                    f'SELECT "{nom}", COUNT(*) as nb FROM "{table}" '
                    f'WHERE "{nom}" IS NOT NULL GROUP BY "{nom}" HAVING nb > 1 '
                    f'ORDER BY nb DESC LIMIT 5')
                if doublons:
                    total_dup = sum(r[1] for r in doublons)
                    ex = ", ".join(f"'{r[0]}' (x{r[1]})" for r in doublons[:3])
                    issues.append(Issue(cat, "ERREUR", table, attr['attr_name'],
                        f"{total_dup} enregistrement(s) en doublon", f"Exemples : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                    f"Erreur verification unicite : {e}"))
    return issues


def test_cles_etrangeres(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 5 : Intégrité référentielle des clés étrangères."""
    issues = []
    cat = "5. Cles etrangeres"
    tables_gpkg_lower = {t.lower(): t for t in reader.get_tables()}

    for table in reader.get_tables():
        fk_attrs = model.get_foreign_keys(table, conteneur)
        if fk_attrs.empty:
            continue
        cols_gpkg = {c.lower() for c in reader.get_column_names(table)}

        for _, attr in fk_attrs.iterrows():
            nom = attr['attr_name'].lower()
            if nom not in cols_gpkg:
                continue
            table_cible, champ_cible = model.parse_relation(str(attr['relation']))
            if not table_cible:
                continue

            if table_cible.lower() not in tables_gpkg_lower:
                if table_cible.startswith('l_'):
                    codes = model.get_valeurs_liste(table_cible)
                    if codes:
                        _check_fk_list(reader, issues, cat, table, attr['attr_name'], nom, table_cible, codes)
                    else:
                        issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                            f"Liste '{table_cible}' absente du GPKG et de la matrice",
                            f"Relation : {attr['relation']}"))
                else:
                    issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                        f"Table cible FK '{table_cible}' absente du GeoPackage",
                        f"Relation : {attr['relation']}"))
                continue

            real_target = tables_gpkg_lower[table_cible.lower()]
            try:
                orphans = reader.execute_query(
                    f'SELECT COUNT(*) FROM "{table}" AS a '
                    f'WHERE a."{nom}" IS NOT NULL AND a."{nom}" != \'\' '
                    f'AND a."{nom}" NOT IN '
                    f'(SELECT "{champ_cible}" FROM "{real_target}" WHERE "{champ_cible}" IS NOT NULL)')[0][0]
                if orphans > 0:
                    ex_rows = reader.execute_query(
                        f'SELECT DISTINCT a."{nom}" FROM "{table}" AS a '
                        f'WHERE a."{nom}" IS NOT NULL AND a."{nom}" != \'\' '
                        f'AND a."{nom}" NOT IN '
                        f'(SELECT "{champ_cible}" FROM "{real_target}" WHERE "{champ_cible}" IS NOT NULL) LIMIT 5')
                    ex = ", ".join(f"'{r[0]}'" for r in ex_rows)
                    issues.append(Issue(cat, "ERREUR", table, attr['attr_name'],
                        f"{orphans} reference(s) orpheline(s) -> {table_cible}.{champ_cible}",
                        f"Valeurs orphelines : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                    f"Erreur verification FK : {e}", f"Relation : {attr['relation']}"))
    return issues


def _check_fk_list(reader, issues, cat, table, attr_display, attr_lower, list_name, valid_codes):
    """Vérifie les valeurs d'un champ contre une liste de valeurs du modèle."""
    try:
        vals = reader.execute_query(
            f'SELECT DISTINCT "{attr_lower}" FROM "{table}" WHERE "{attr_lower}" IS NOT NULL AND TRIM("{attr_lower}") != \'\'')
        valid_set = {str(c).strip() for c in valid_codes}
        invalides = [str(r[0]) for r in vals if str(r[0]).strip() not in valid_set]
        if invalides:
            issues.append(Issue(cat, "ERREUR", table, attr_display,
                f"{len(invalides)} valeur(s) hors liste '{list_name}'",
                f"Valeurs invalides : {', '.join(invalides[:10])}"))
    except Exception as e:
        issues.append(Issue(cat, "AVERTISSEMENT", table, attr_display,
            f"Erreur verification liste {list_name} : {e}"))


def test_geometries_nulles(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 6 : Pas de géométries NULL dans les tables spatiales."""
    issues = []
    cat = "6. Geometries NULL"

    for table in reader.get_tables():
        if not model.is_table_spatiale(table):
            continue
        cols = {c.lower() for c in reader.get_column_names(table)}
        if 'geom' not in cols:
            continue
        attrs_geom = model.get_attributs_for_table(table, conteneur)
        if attrs_geom[attrs_geom['attr_name'].str.lower() == 'geom'].empty:
            continue
        try:
            cnt = reader.execute_query(f'SELECT COUNT(*) FROM "{table}" WHERE geom IS NULL')[0][0]
            total = reader.get_row_count(table)
            if cnt > 0:
                issues.append(Issue(cat, "ERREUR", table, "geom",
                    f"{cnt} geometrie(s) NULL sur {total} enregistrement(s)",
                    "Chaque objet spatial doit avoir une geometrie valide."))
        except Exception as e:
            issues.append(Issue(cat, "AVERTISSEMENT", table, "geom",
                f"Erreur verification geom NULL : {e}"))
    return issues


def test_geometries_invalides(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """TEST 7 : Validité géométrique via ST_IsValid (SpatiaLite)."""
    issues = []
    cat = "7. Geometries invalides"

    if not reader.load_spatialite():
        issues.append(Issue(cat, "INFO", None, None,
            "SpatiaLite non disponible - test ST_IsValid ignore.",
            "Installez mod_spatialite pour activer ce test."))
        return issues

    for table in reader.get_tables():
        if not model.is_table_spatiale(table):
            continue
        cols = {c.lower() for c in reader.get_column_names(table)}
        if 'geom' not in cols:
            continue
        try:
            cnt = reader.execute_query(
                f'SELECT COUNT(*) FROM "{table}" WHERE geom IS NOT NULL AND ST_IsValid(geom) = 0')[0][0]
            if cnt > 0:
                total = reader.get_row_count(table)
                issues.append(Issue(cat, "ERREUR", table, "geom",
                    f"{cnt} geometrie(s) invalide(s) sur {total}",
                    "Corrigez avec ST_MakeValid() ou un outil SIG."))
        except Exception as e:
            issues.append(Issue(cat, "AVERTISSEMENT", table, "geom",
                f"Erreur test validite : {e}"))
    return issues


def test_types_donnees(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """
    TEST 8 : Types de données des champs.
    Compare la famille de type (TEXT, REAL, INTEGER, GEOMETRY).
    """
    issues = []
    cat = "8. Types de donnees"

    for table in reader.get_tables():
        attrs = model.get_attributs_for_table(table, conteneur)
        if attrs.empty:
            continue
        cols_gpkg = {c['name'].lower(): c['type'] for c in reader.get_columns(table)}

        for _, attr in attrs.iterrows():
            nom = attr['attr_name'].lower()
            if nom not in cols_gpkg or nom == 'geom':
                continue

            type_attendu = model.get_expected_gpkg_type_family(str(attr['type_gpkg']))
            type_reel = GraceTHDModel.sqlite_type_to_family(cols_gpkg[nom])

            if type_attendu != type_reel and type_reel != 'TEXT':
                issues.append(Issue(cat, "AVERTISSEMENT", table, attr['attr_name'],
                    f"Type inattendu : '{cols_gpkg[nom]}' au lieu de '{attr['type_gpkg']}'",
                    f"Famille attendue : {type_attendu}, trouvee : {type_reel}"))
    return issues


def test_topologie_noeuds_lignes(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """
    TEST 9 : Cohérence topologique nœuds/lignes.
    Vérifie que les extrémités des cheminements et câbles coïncident
    avec les nœuds référencés (tolérance 1m en Lambert-93).
    Vérifie la cohérence géométrique des objets hérités du nœud.
    """
    issues = []
    cat = "9. Topologie noeuds/lignes"

    if not reader.has_table('t_noeud'):
        issues.append(Issue(cat, "INFO", None, None,
            "Table t_noeud absente - tests topologiques ignores."))
        return issues

    spatialite_ok = reader.load_spatialite()

    # 9a. Extrémités des cheminements
    if reader.has_table('t_cheminement') and spatialite_ok:
        cols_cm = {c.lower() for c in reader.get_column_names('t_cheminement')}
        if all(c in cols_cm for c in ['geom', 'cm_ndcode1', 'cm_ndcode2', 'cm_code']):
            try:
                for endpoint, nd_col, label in [
                    ('ST_StartPoint', 'cm_ndcode1', 'debut'),
                    ('ST_EndPoint', 'cm_ndcode2', 'fin')
                ]:
                    mismatches = reader.execute_query(f"""
                        SELECT cm.cm_code, cm."{nd_col}",
                               ST_Distance({endpoint}(cm.geom), nd.geom) as dist
                        FROM t_cheminement cm
                        LEFT JOIN t_noeud nd ON cm."{nd_col}" = nd.nd_code
                        WHERE cm.geom IS NOT NULL AND nd.geom IS NOT NULL
                        AND ST_Distance({endpoint}(cm.geom), nd.geom) > 1.0
                        LIMIT 10
                    """)
                    if mismatches:
                        ex = ", ".join(f"{r[0]} ({r[2]:.1f}m)" for r in mismatches[:3])
                        issues.append(Issue(cat, "ERREUR", "t_cheminement", nd_col,
                            f"{len(mismatches)} cheminement(s) : {label} ne coincide pas avec le noeud",
                            f"Exemples (distance) : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", "t_cheminement", None,
                    f"Erreur test topologie cheminement : {e}"))

    # 9b. Extrémités des câbles (via t_cableline)
    if reader.has_table('t_cableline') and reader.has_table('t_cable') and spatialite_ok:
        cols_cl = {c.lower() for c in reader.get_column_names('t_cableline')}
        cols_cb = {c.lower() for c in reader.get_column_names('t_cable')}
        if 'geom' in cols_cl and all(c in cols_cb for c in ['cb_nd1', 'cb_nd2', 'cb_code']):
            try:
                for endpoint, nd_col, label in [
                    ('ST_StartPoint', 'cb_nd1', 'debut'),
                    ('ST_EndPoint', 'cb_nd2', 'fin')
                ]:
                    mismatches = reader.execute_query(f"""
                        SELECT cb.cb_code, cb."{nd_col}",
                               ST_Distance({endpoint}(cl.geom), nd.geom) as dist
                        FROM t_cable cb
                        JOIN t_cableline cl ON cb.cb_code = cl.cl_cb_code
                        LEFT JOIN t_noeud nd ON cb."{nd_col}" = nd.nd_code
                        WHERE cl.geom IS NOT NULL AND nd.geom IS NOT NULL
                        AND ST_Distance({endpoint}(cl.geom), nd.geom) > 1.0
                        LIMIT 10
                    """)
                    if mismatches:
                        ex = ", ".join(f"{r[0]} ({r[2]:.1f}m)" for r in mismatches[:3])
                        issues.append(Issue(cat, "ERREUR", "t_cable/t_cableline", nd_col,
                            f"{len(mismatches)} cable(s) : {label} ne coincide pas avec le noeud",
                            f"Exemples : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", "t_cable/t_cableline", None,
                    f"Erreur test topologie cable : {e}"))

    # 9c. Cohérence nœud parent pour tables héritées (site, ptech)
    heritage = [('t_site', 'st_nd_code', 'st_code'), ('t_ptech', 'pt_nd_code', 'pt_code')]
    if spatialite_ok:
        for tbl, fk_col, pk_col in heritage:
            if not reader.has_table(tbl):
                continue
            cols = {c.lower() for c in reader.get_column_names(tbl)}
            if not all(c in cols for c in ['geom', fk_col]):
                continue
            try:
                mismatches = reader.execute_query(f"""
                    SELECT t."{pk_col}", t."{fk_col}",
                           ST_Distance(t.geom, nd.geom) as dist
                    FROM "{tbl}" t
                    LEFT JOIN t_noeud nd ON t."{fk_col}" = nd.nd_code
                    WHERE t.geom IS NOT NULL AND nd.geom IS NOT NULL
                    AND ST_Distance(t.geom, nd.geom) > 0.01
                    LIMIT 10
                """)
                if mismatches:
                    ex = ", ".join(f"{r[0]} ({r[2]:.1f}m)" for r in mismatches[:3])
                    issues.append(Issue(cat, "AVERTISSEMENT", tbl, fk_col,
                        f"{len(mismatches)} objet(s) : geometrie differe du noeud parent",
                        f"Exemples (distance) : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", tbl, fk_col,
                    f"Erreur test heritage noeud : {e}"))

    if not spatialite_ok:
        issues.append(Issue(cat, "INFO", None, None,
            "SpatiaLite absent - tests de distance geometrique ignores.",
            "Les tests FK noeuds/lignes sont couverts par le test 5."))
    return issues


def test_inclusion_spatiale(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """
    TEST 10 : Inclusion spatiale des zones.
    Vérifie : zsro dans znro, zpbo dans zsro, adresses dans zsro.
    """
    issues = []
    cat = "10. Inclusion spatiale"

    if not reader.load_spatialite():
        issues.append(Issue(cat, "INFO", None, None,
            "SpatiaLite non disponible - tests d'inclusion spatiale ignores."))
        return issues

    # Règles d'inclusion entre zones
    regles = [
        ('t_zsro', 'zs_zn_code', 't_znro', 'zn_code', 'zs_code',
         "Zone SRO doit etre contenue dans sa zone NRO"),
        ('t_zpbo', 'zp_zs_code', 't_zsro', 'zs_code', 'zp_code',
         "Zone PBO doit etre contenue dans sa zone SRO"),
    ]

    for tbl_e, fk_col, tbl_p, pk_col, pk_enfant, desc in regles:
        if not (reader.has_table(tbl_e) and reader.has_table(tbl_p)):
            continue
        cols_e = {c.lower() for c in reader.get_column_names(tbl_e)}
        cols_p = {c.lower() for c in reader.get_column_names(tbl_p)}
        if not ('geom' in cols_e and 'geom' in cols_p and fk_col in cols_e and pk_enfant in cols_e):
            continue

        try:
            non_inclus = reader.execute_query(f"""
                SELECT e."{pk_enfant}", e."{fk_col}"
                FROM "{tbl_e}" e
                JOIN "{tbl_p}" p ON e."{fk_col}" = p."{pk_col}"
                WHERE e.geom IS NOT NULL AND p.geom IS NOT NULL
                AND ST_Within(ST_Centroid(e.geom), p.geom) = 0
                LIMIT 10
            """)
            if non_inclus:
                ex = ", ".join(f"{r[0]}" for r in non_inclus[:5])
                issues.append(Issue(cat, "ERREUR", tbl_e, fk_col,
                    f"{len(non_inclus)} objet(s) hors de leur zone parente ({tbl_p})",
                    f"{desc}. Exemples : {ex}"))
        except Exception as e:
            issues.append(Issue(cat, "AVERTISSEMENT", tbl_e, None,
                f"Erreur test inclusion {tbl_e} dans {tbl_p} : {e}"))

    # Adresses dans au moins une zone SRO
    if reader.has_table('t_adresse') and reader.has_table('t_zsro'):
        cols_ad = {c.lower() for c in reader.get_column_names('t_adresse')}
        if 'geom' in cols_ad and 'ad_code' in cols_ad:
            try:
                hors_zone = reader.execute_query("""
                    SELECT ad.ad_code FROM t_adresse ad
                    WHERE ad.geom IS NOT NULL
                    AND NOT EXISTS (
                        SELECT 1 FROM t_zsro zs
                        WHERE zs.geom IS NOT NULL AND ST_Within(ad.geom, zs.geom) = 1
                    ) LIMIT 20
                """)
                if hors_zone:
                    total_ad = reader.get_row_count('t_adresse')
                    ex = ", ".join(f"{r[0]}" for r in hors_zone[:5])
                    issues.append(Issue(cat, "AVERTISSEMENT", "t_adresse", "geom",
                        f"{len(hors_zone)}+ adresse(s) hors de toute zone SRO (sur {total_ad})",
                        f"Exemples : {ex}"))
            except Exception as e:
                issues.append(Issue(cat, "AVERTISSEMENT", "t_adresse", None,
                    f"Erreur test adresses dans ZSRO : {e}"))
    return issues


def test_chevauchement_zones(model: GraceTHDModel, reader: GeoPackageReader, conteneur: str) -> List[Issue]:
    """
    TEST 11 : Chevauchement des zones de même niveau.
    Les zones NRO/SRO/PBO ne doivent pas se chevaucher significativement
    (tolérance 1% de la plus petite surface).
    """
    issues = []
    cat = "11. Chevauchement des zones"

    if not reader.load_spatialite():
        issues.append(Issue(cat, "INFO", None, None,
            "SpatiaLite non disponible - test de chevauchement ignore."))
        return issues

    tables_zones = [
        ('t_znro', 'zn_code', "Zones NRO"),
        ('t_zsro', 'zs_code', "Zones SRO"),
        ('t_zpbo', 'zp_code', "Zones PBO"),
    ]

    for tbl, pk_col, label in tables_zones:
        if not reader.has_table(tbl):
            continue
        cols = {c.lower() for c in reader.get_column_names(tbl)}
        if 'geom' not in cols or pk_col not in cols:
            continue
        if reader.get_row_count(tbl) < 2:
            continue

        try:
            overlaps = reader.execute_query(f"""
                SELECT a."{pk_col}", b."{pk_col}",
                       ST_Area(ST_Intersection(a.geom, b.geom)) as area_inter,
                       MIN(ST_Area(a.geom), ST_Area(b.geom)) as area_min
                FROM "{tbl}" a, "{tbl}" b
                WHERE a.rowid < b.rowid
                AND a.geom IS NOT NULL AND b.geom IS NOT NULL
                AND ST_Intersects(a.geom, b.geom) = 1
                AND ST_Area(ST_Intersection(a.geom, b.geom)) >
                    0.01 * MIN(ST_Area(a.geom), ST_Area(b.geom))
                LIMIT 10
            """)
            if overlaps:
                ex = ", ".join(f"{r[0]}<->{r[1]}" for r in overlaps[:5])
                issues.append(Issue(cat, "ERREUR", tbl, "geom",
                    f"{len(overlaps)} chevauchement(s) significatif(s) entre {label}",
                    f"Paires : {ex}"))
        except Exception as e:
            issues.append(Issue(cat, "AVERTISSEMENT", tbl, "geom",
                f"Erreur test chevauchement {label} : {e}"))
    return issues


# =============================================================================
# 5. GÉNÉRATION DU RAPPORT PDF
# =============================================================================

def generer_rapport_pdf(result: AuditResult, chemin_pdf: str, model: GraceTHDModel, reader: GeoPackageReader):
    """Génère un rapport PDF professionnel et lisible."""
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.units import mm
    from reportlab.lib.colors import HexColor, white, black
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.enums import TA_CENTER
    from reportlab.platypus import (
        SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
        PageBreak, HRFlowable
    )

    # Palette
    BLEU_F = HexColor("#1a365d"); BLEU_M = HexColor("#2b6cb0"); BLEU_C = HexColor("#ebf8ff")
    ROUGE = HexColor("#c53030"); ROUGE_C = HexColor("#fff5f5")
    ORANGE_C = HexColor("#fffaf0"); VERT = HexColor("#276749"); VERT_C = HexColor("#f0fff4")
    GRIS = HexColor("#718096"); GRIS_C = HexColor("#f7fafc"); GRIS_M = HexColor("#e2e8f0")

    styles = getSampleStyleSheet()
    s_titre = ParagraphStyle('TR', parent=styles['Title'], fontSize=28, textColor=BLEU_F,
        spaceAfter=6*mm, fontName='Helvetica-Bold', alignment=TA_CENTER)
    s_soustitre = ParagraphStyle('ST', parent=styles['Normal'], fontSize=14, textColor=BLEU_M,
        spaceAfter=4*mm, fontName='Helvetica', alignment=TA_CENTER)
    s_section = ParagraphStyle('SE', parent=styles['Heading1'], fontSize=16, textColor=BLEU_F,
        spaceBefore=8*mm, spaceAfter=4*mm, fontName='Helvetica-Bold', leftIndent=0)
    s_ssection = ParagraphStyle('SS', parent=styles['Heading2'], fontSize=12, textColor=BLEU_M,
        spaceBefore=5*mm, spaceAfter=2*mm, fontName='Helvetica-Bold')
    s_normal = ParagraphStyle('NO', parent=styles['Normal'], fontSize=9, textColor=black,
        fontName='Helvetica', leading=12)
    s_cell = ParagraphStyle('CE', parent=styles['Normal'], fontSize=7.5, textColor=black,
        fontName='Helvetica', leading=9.5, wordWrap='CJK')
    s_cell_b = ParagraphStyle('CB', parent=s_cell, fontName='Helvetica-Bold')
    s_vok = ParagraphStyle('VOK', fontSize=18, textColor=VERT, fontName='Helvetica-Bold',
        alignment=TA_CENTER, spaceBefore=6*mm, spaceAfter=6*mm)
    s_vko = ParagraphStyle('VKO', fontSize=18, textColor=ROUGE, fontName='Helvetica-Bold',
        alignment=TA_CENTER, spaceBefore=6*mm, spaceAfter=6*mm)

    doc = SimpleDocTemplate(chemin_pdf, pagesize=A4,
        topMargin=20*mm, bottomMargin=20*mm, leftMargin=15*mm, rightMargin=15*mm)

    story = []
    pw = A4[0] - 30*mm

    # ===== COUVERTURE =====
    story.append(Spacer(1, 35*mm))
    story.append(Paragraph("RAPPORT D'AUDIT", s_titre))
    story.append(Paragraph("Conformite GraceTHD v3.1", s_soustitre))
    story.append(Spacer(1, 8*mm))
    story.append(HRFlowable(width="60%", thickness=2, color=BLEU_M, spaceAfter=10*mm, spaceBefore=4*mm))

    info = [
        ["Fichier audite", os.path.basename(result.fichier_gpkg)],
        ["Conteneur cible", result.conteneur],
        ["Date de l'audit", result.date_audit],
        ["Referentiel", "GraceTHD v3.1 (Matrice An_1b)"],
        ["Tests executes", "11 categories"],
    ]
    t = Table(info, colWidths=[45*mm, 105*mm])
    t.setStyle(TableStyle([
        ('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'), ('FONTNAME', (1,0), (1,-1), 'Helvetica'),
        ('FONTSIZE', (0,0), (-1,-1), 10), ('TEXTCOLOR', (0,0), (0,-1), BLEU_F),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5*mm), ('TOPPADDING', (0,0), (-1,-1), 1.5*mm),
    ]))
    story.append(t)
    story.append(Spacer(1, 12*mm))

    if result.est_conforme:
        story.append(Paragraph("CONFORME", s_vok))
    else:
        story.append(Paragraph(f"NON CONFORME - {result.nb_erreurs} erreur(s)", s_vko))

    story.append(PageBreak())

    # ===== SYNTHÈSE =====
    story.append(Paragraph("Synthese globale", s_section))
    story.append(HRFlowable(width="100%", thickness=1, color=GRIS_M, spaceAfter=4*mm))

    c_data = [
        [Paragraph("<b>Severite</b>", s_cell_b), Paragraph("<b>Nombre</b>", s_cell_b),
         Paragraph("<b>Description</b>", s_cell_b)],
        [Paragraph("ERREUR", s_cell), Paragraph(str(result.nb_erreurs), s_cell),
         Paragraph("Non-conformite bloquante", s_cell)],
        [Paragraph("AVERTISSEMENT", s_cell), Paragraph(str(result.nb_avertissements), s_cell),
         Paragraph("Point d'attention ou conformite conditionnelle", s_cell)],
        [Paragraph("INFO", s_cell), Paragraph(str(result.nb_infos), s_cell),
         Paragraph("Information complementaire, non bloquante", s_cell)],
    ]
    ct = Table(c_data, colWidths=[35*mm, 22*mm, pw-57*mm])
    ct.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), BLEU_F), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('BACKGROUND', (0,1), (-1,1), ROUGE_C if result.nb_erreurs else GRIS_C),
        ('BACKGROUND', (0,2), (-1,2), ORANGE_C if result.nb_avertissements else GRIS_C),
        ('BACKGROUND', (0,3), (-1,3), BLEU_C),
        ('GRID', (0,0), (-1,-1), 0.5, GRIS_M),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2.5*mm), ('BOTTOMPADDING', (0,0), (-1,-1), 2.5*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 2.5*mm),
    ]))
    story.append(ct)
    story.append(Spacer(1, 5*mm))

    if result.est_conforme:
        story.append(Paragraph(
            f"Le GeoPackage est <b>conforme</b> au modele GraceTHD v3.1 pour le <b>{result.conteneur}</b>.", s_normal))
    else:
        story.append(Paragraph(
            f"Le GeoPackage presente <b>{result.nb_erreurs} erreur(s)</b> bloquante(s) "
            f"pour le <b>{result.conteneur}</b>. Details ci-apres.", s_normal))

    # ===== DASHBOARD PAR CATÉGORIE =====
    story.append(Spacer(1, 5*mm))
    story.append(Paragraph("Resume par categorie de test", s_ssection))

    cats = result.issues_par_categorie()
    dash_rows = [[
        Paragraph("<b>Categorie de test</b>", s_cell_b),
        Paragraph("<b>Erreurs</b>", s_cell_b),
        Paragraph("<b>Avert.</b>", s_cell_b),
        Paragraph("<b>Infos</b>", s_cell_b),
        Paragraph("<b>Statut</b>", s_cell_b),
    ]]
    cat_list = list(cats.items())  # Preserve order
    for cat_name, cat_issues in cat_list:
        ne = sum(1 for i in cat_issues if i.severite == "ERREUR")
        nw = sum(1 for i in cat_issues if i.severite == "AVERTISSEMENT")
        ni = sum(1 for i in cat_issues if i.severite == "INFO")
        statut = "OK" if ne == 0 else f"{ne} err."
        color = "#276749" if ne == 0 else "#c53030"
        dash_rows.append([
            Paragraph(cat_name, s_cell),
            Paragraph(f"<font color='#c53030'><b>{ne}</b></font>" if ne else "0", s_cell),
            Paragraph(f"<font color='#c05621'><b>{nw}</b></font>" if nw else "0", s_cell),
            Paragraph(str(ni), s_cell),
            Paragraph(f"<font color='{color}'><b>{statut}</b></font>", s_cell),
        ])

    dt = Table(dash_rows, colWidths=[pw*0.45, 18*mm, 18*mm, 16*mm, pw*0.18], repeatRows=1)
    dt_s = [
        ('BACKGROUND', (0,0), (-1,0), BLEU_F), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('GRID', (0,0), (-1,-1), 0.4, GRIS_M), ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2*mm), ('BOTTOMPADDING', (0,0), (-1,-1), 2*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 2*mm),
    ]
    for i in range(1, len(dash_rows)):
        if i % 2 == 0:
            dt_s.append(('BACKGROUND', (0,i), (-1,i), GRIS_C))
        ne = sum(1 for iss in cat_list[i-1][1] if iss.severite == "ERREUR")
        dt_s.append(('BACKGROUND', (-1,i), (-1,i), ROUGE_C if ne > 0 else VERT_C))
    dt.setStyle(TableStyle(dt_s))
    story.append(dt)
    story.append(PageBreak())

    # ===== DÉTAIL =====
    story.append(Paragraph("Detail des anomalies", s_section))
    story.append(HRFlowable(width="100%", thickness=1, color=GRIS_M, spaceAfter=4*mm))

    for cat_name, cat_issues in cat_list:
        ne = sum(1 for i in cat_issues if i.severite == "ERREUR")
        nw = sum(1 for i in cat_issues if i.severite == "AVERTISSEMENT")
        ni = sum(1 for i in cat_issues if i.severite == "INFO")

        badges = []
        if ne: badges.append(f"<font color='#c53030'>{ne} err.</font>")
        if nw: badges.append(f"<font color='#c05621'>{nw} avert.</font>")
        if ni: badges.append(f"<font color='#718096'>{ni} info</font>")
        story.append(Paragraph(f"{cat_name}  -  {' | '.join(badges)}", s_ssection))

        if ne == 0 and nw == 0:
            for iss in cat_issues:
                story.append(Paragraph(f"<font color='#276749'>i {iss.message}</font>", s_normal))
            story.append(Spacer(1, 3*mm))
            continue

        rows = [[
            Paragraph("<b>Sev.</b>", s_cell_b), Paragraph("<b>Table</b>", s_cell_b),
            Paragraph("<b>Champ</b>", s_cell_b), Paragraph("<b>Message</b>", s_cell_b),
            Paragraph("<b>Detail</b>", s_cell_b),
        ]]
        sorted_iss = sorted(cat_issues, key=lambda x: {"ERREUR":0,"AVERTISSEMENT":1,"INFO":2}[x.severite])
        for iss in sorted_iss:
            sc = "#c53030" if iss.severite == "ERREUR" else ("#c05621" if iss.severite == "AVERTISSEMENT" else "#718096")
            sl = "ERR" if iss.severite == "ERREUR" else ("AVT" if iss.severite == "AVERTISSEMENT" else "INF")
            det = (iss.detail[:140] + "..." if len(iss.detail) > 140 else iss.detail) if iss.detail else ""
            rows.append([
                Paragraph(f"<font color='{sc}'><b>{sl}</b></font>", s_cell),
                Paragraph(iss.table or "-", s_cell),
                Paragraph(iss.champ or "-", s_cell),
                Paragraph(iss.message, s_cell),
                Paragraph(det, s_cell),
            ])

        cw = [12*mm, 26*mm, 22*mm, pw*0.28, pw*0.27]
        tbl = Table(rows, colWidths=cw, repeatRows=1)
        tbl_s = [
            ('BACKGROUND', (0,0), (-1,0), BLEU_F), ('TEXTCOLOR', (0,0), (-1,0), white),
            ('GRID', (0,0), (-1,-1), 0.3, GRIS_M), ('VALIGN', (0,0), (-1,-1), 'TOP'),
            ('TOPPADDING', (0,0), (-1,-1), 1.5*mm), ('BOTTOMPADDING', (0,0), (-1,-1), 1.5*mm),
            ('LEFTPADDING', (0,0), (-1,-1), 1.5*mm), ('RIGHTPADDING', (0,0), (-1,-1), 1.5*mm),
        ]
        for i in range(1, len(rows)):
            if i % 2 == 0:
                tbl_s.append(('BACKGROUND', (0,i), (-1,i), GRIS_C))
            iss = sorted_iss[i-1]
            if iss.severite == "ERREUR":
                tbl_s.append(('BACKGROUND', (0,i), (0,i), ROUGE_C))
            elif iss.severite == "AVERTISSEMENT":
                tbl_s.append(('BACKGROUND', (0,i), (0,i), ORANGE_C))
        tbl.setStyle(TableStyle(tbl_s))
        story.append(tbl)
        story.append(Spacer(1, 3*mm))

    # ===== MATRICE MULTI-CONTENEURS =====
    story.append(PageBreak())
    story.append(Paragraph("Matrice de conformite par conteneur", s_section))
    story.append(HRFlowable(width="100%", thickness=1, color=GRIS_M, spaceAfter=4*mm))
    story.append(Paragraph(
        "Statut de chaque table du GeoPackage dans le modele GraceTHD v3.1 par conteneur.", s_normal))
    story.append(Spacer(1, 3*mm))

    tables_gpkg = sorted(reader.get_tables())
    mx_rows = [[
        Paragraph("<b>Table</b>", s_cell_b), Paragraph("<b>Lignes</b>", s_cell_b),
        Paragraph("<b>C1</b>", s_cell_b), Paragraph("<b>C2</b>", s_cell_b),
        Paragraph("<b>C3</b>", s_cell_b), Paragraph("<b>C4</b>", s_cell_b),
    ]]
    for tbl_name in tables_gpkg:
        nb = reader.get_row_count(tbl_name)
        row = [Paragraph(tbl_name, s_cell), Paragraph(str(nb), s_cell)]
        for ci in ['C1','C2','C3','C4']:
            statut = model.get_table_statut(tbl_name, ci)
            if statut == 'O':
                row.append(Paragraph("<font color='#276749'><b>O</b></font>", s_cell))
            elif statut == 'C':
                row.append(Paragraph("<font color='#c05621'>C</font>", s_cell))
            else:
                row.append(Paragraph("<font color='#718096'>-</font>", s_cell))
        mx_rows.append(row)

    mx_t = Table(mx_rows, colWidths=[40*mm, 20*mm, 16*mm, 16*mm, 16*mm, 16*mm], repeatRows=1)
    mx_s = [
        ('BACKGROUND', (0,0), (-1,0), BLEU_F), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('GRID', (0,0), (-1,-1), 0.3, GRIS_M), ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2*mm), ('BOTTOMPADDING', (0,0), (-1,-1), 2*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 2*mm), ('ALIGN', (2,0), (-1,-1), 'CENTER'),
    ]
    for i in range(1, len(mx_rows)):
        if i % 2 == 0:
            mx_s.append(('BACKGROUND', (0,i), (-1,i), GRIS_C))
    mx_t.setStyle(TableStyle(mx_s))
    story.append(mx_t)
    story.append(Spacer(1, 4*mm))
    story.append(Paragraph("<b>Legende :</b> O = Obligatoire | C = Conditionnel | - = Non requis", s_normal))

    # ===== ANNEXE =====
    story.append(PageBreak())
    story.append(Paragraph("Annexe - Inventaire detaille des tables", s_section))
    story.append(HRFlowable(width="100%", thickness=1, color=GRIS_M, spaceAfter=4*mm))

    inv_rows = [[
        Paragraph("<b>Table</b>", s_cell_b), Paragraph("<b>Nb lignes</b>", s_cell_b),
        Paragraph("<b>Nb champs</b>", s_cell_b), Paragraph("<b>Spatiale</b>", s_cell_b),
        Paragraph(f"<b>Statut {result.conteneur}</b>", s_cell_b),
    ]]
    for tbl_name in tables_gpkg:
        nb = reader.get_row_count(tbl_name)
        nb_cols = len(reader.get_column_names(tbl_name))
        spatial = "Oui" if model.is_table_spatiale(tbl_name) else "Non"
        statut = model.get_table_statut(tbl_name, result.conteneur)
        sl = "Obligatoire" if statut == 'O' else ("Conditionnel" if statut == 'C' else "Hors modele")
        inv_rows.append([
            Paragraph(tbl_name, s_cell), Paragraph(str(nb), s_cell),
            Paragraph(str(nb_cols), s_cell), Paragraph(spatial, s_cell), Paragraph(sl, s_cell),
        ])

    inv_t = Table(inv_rows, colWidths=[40*mm, 22*mm, 22*mm, 20*mm, 30*mm], repeatRows=1)
    inv_s = [
        ('BACKGROUND', (0,0), (-1,0), BLEU_F), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('GRID', (0,0), (-1,-1), 0.3, GRIS_M), ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2*mm), ('BOTTOMPADDING', (0,0), (-1,-1), 2*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 2*mm),
    ]
    for i in range(1, len(inv_rows)):
        if i % 2 == 0:
            inv_s.append(('BACKGROUND', (0,i), (-1,i), GRIS_C))
    inv_t.setStyle(TableStyle(inv_s))
    story.append(inv_t)

    # Footer
    def footer(canvas, doc):
        canvas.saveState()
        canvas.setFont('Helvetica', 7)
        canvas.setFillColor(GRIS)
        canvas.drawCentredString(A4[0]/2, 10*mm,
            f"Audit GraceTHD v3.1 - {os.path.basename(result.fichier_gpkg)} - {result.conteneur} - Page {doc.page}")
        if doc.page > 1:
            canvas.setStrokeColor(GRIS_M); canvas.setLineWidth(0.5)
            canvas.line(15*mm, A4[1]-15*mm, A4[0]-15*mm, A4[1]-15*mm)
        canvas.restoreState()

    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(f"[OK] Rapport PDF genere : {chemin_pdf}")


# =============================================================================
# 6. ORCHESTRATION
# =============================================================================

ALL_TESTS = [
    ("1. Presence des tables",         test_presence_tables),
    ("2. Presence des champs",         test_presence_champs),
    ("3. Valeurs NULL interdites",     test_contraintes_not_null),
    ("4. Contraintes d'unicite",       test_contraintes_unique),
    ("5. Cles etrangeres",             test_cles_etrangeres),
    ("6. Geometries NULL",             test_geometries_nulles),
    ("7. Geometries invalides",        test_geometries_invalides),
    ("8. Types de donnees",            test_types_donnees),
    ("9. Topologie noeuds/lignes",     test_topologie_noeuds_lignes),
    ("10. Inclusion spatiale",         test_inclusion_spatiale),
    ("11. Chevauchement des zones",    test_chevauchement_zones),
]


def run_audit(chemin_gpkg: str, chemin_excel: str, conteneur: str, spatialite_path: str = None) -> Tuple[AuditResult, GraceTHDModel, GeoPackageReader]:
    """Exécute tous les tests et retourne le résultat, le modèle et le reader."""
    model = GraceTHDModel(chemin_excel)
    reader = GeoPackageReader(chemin_gpkg)
    reader.spatialite_path = spatialite_path  # Pour les appels load_spatialite()
    result = AuditResult(fichier_gpkg=chemin_gpkg, conteneur=conteneur)

    for nom_test, fn_test in ALL_TESTS:
        print(f"  -> {nom_test}...")
        try:
            issues = fn_test(model, reader, conteneur)
            result.issues.extend(issues)
            ne = sum(1 for i in issues if i.severite == "ERREUR")
            nw = sum(1 for i in issues if i.severite == "AVERTISSEMENT")
            status = "OK" if ne == 0 else "KO"
            print(f"    [{status}]  {ne} erreur(s), {nw} avertissement(s)")
        except Exception as e:
            result.issues.append(Issue(nom_test, "ERREUR", None, None,
                f"Erreur critique lors du test : {e}"))
            print(f"    [!!] Erreur critique : {e}")

    return result, model, reader


def main():
    parser = argparse.ArgumentParser(
        description="Audit de conformite GraceTHD v3.1 d'un GeoPackage",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples :
  python gracethd_audit.py reseau.gpkg --conteneur C3
  python gracethd_audit.py reseau.gpkg --excel matrice.xlsx --conteneur C4
  python gracethd_audit.py reseau.gpkg --output rapport_audit.pdf
  python gracethd_audit.py reseau.gpkg --spatialite C:\\spatialite
        """)
    parser.add_argument("gpkg", help="Chemin vers le GeoPackage a auditer")
    parser.add_argument("--excel", default=None, help="Matrice de conformite Excel")
    parser.add_argument("--conteneur", default="C3", choices=["C1","C2","C3","C4"],
                        help="Conteneur a verifier (defaut: C3)")
    parser.add_argument("--output", default=None, help="Chemin du PDF en sortie")
    parser.add_argument("--spatialite", default=None,
                        help="Dossier contenant mod_spatialite (ex: C:\\spatialite)")

    args = parser.parse_args()

    if args.excel is None:
        for path in [
            os.path.join(os.path.dirname(os.path.abspath(__file__)), "An_1b_-_grilles_de_remplissage.xlsx"),
            os.path.join(os.path.dirname(args.gpkg) or ".", "An_1b_-_grilles_de_remplissage.xlsx"),
        ]:
            if os.path.exists(path):
                args.excel = path
                break
        if not args.excel:
            print("[ERREUR] Matrice non trouvee. Utilisez --excel.")
            sys.exit(1)

    if args.output is None:
        base = os.path.splitext(os.path.basename(args.gpkg))[0]
        horodatage = datetime.now().strftime("%Y%m%d-%Hh%M")
        args.output = os.path.join(
            os.path.dirname(args.gpkg) or ".",
            f"{horodatage}-{base}_audit_{args.conteneur}.pdf"
        )

    print("=" * 65)
    print("  AUDIT GraceTHD v3.1 - 11 categories de tests")
    print("=" * 65)
    print(f"  Fichier    : {args.gpkg}")
    print(f"  Conteneur  : {args.conteneur}")
    print(f"  Matrice    : {args.excel}")
    print(f"  Sortie     : {args.output}")
    if args.spatialite:
        print(f"  SpatiaLite : {args.spatialite}")
    print("=" * 65)

    result, model, reader = run_audit(args.gpkg, args.excel, args.conteneur, args.spatialite)
    generer_rapport_pdf(result, args.output, model, reader)
    reader.close()

    print("\n" + "=" * 65)
    print("  RESULTAT")
    print("=" * 65)
    print(f"  Erreurs         : {result.nb_erreurs}")
    print(f"  Avertissements  : {result.nb_avertissements}")
    print(f"  Informations    : {result.nb_infos}")
    print(f"  Verdict         : {'CONFORME' if result.est_conforme else 'NON CONFORME'}")
    print("=" * 65)


if __name__ == "__main__":
    main()
