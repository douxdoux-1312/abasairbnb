--- Dasymetric areal interpolation to estimate the number of rental units in Montreal and Quebec's neighborhood when boundaries between the CHMC's areas and the neighborhood's area are not the same  

-- QUEBEC (QUARTIERS)
--- https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
--- https://www.cmhc-schl.gc.ca/professionnels/marche-du-logement-donnees-et-recherche/donnees-sur-le-logement/tableaux-de-donnees/donnees-sur-le-marche-locatif
DROP TABLE IF EXISTS sr21_quebec_loc;
CREATE TABLE sr21_quebec_loc as
(
SELECT
sr2016_vdq.sridu as sr, -- census tract for Quebec
sr_schl_22_qc.unite as unite, -- number of rental units per census tract
sr2016_vdq.geom
from sr_schl_22_qc
join sr2016_vdq on sr_schl_22_qc.sr :: varchar(255) = sr2016_vdq.srnom :: varchar(255)
);

-- Création de la couche auxiliaire
--- https://www.donneesquebec.ca/recherche/dataset/vque_54
DROP TABLE if exists uds_resid_vdq;
CREATE TABLE uds_resid_vdq AS
(
SELECT
code_usage, -- land use data --> keep only residential area
ST_MakeValid(geom) as geom
FROM uds_vdq
WHERE code_usage = 'RAS' or code_usage = 'RC' or code_usage = 'RF' or code_usage = 'RH' or code_usage = 'RM'
);

-- Validation de la géométrie
SELECT sridu FROM sr2021_vdq WHERE NOT ST_IsValid(geom);
SELECT code_usage FROM uds_vdq WHERE NOT ST_IsValid(geom);

-- Intersection de la couche auxiliaire et de la couche source
DROP TABLE if exists sr2021_vdq_clipped;
CREATE TABLE sr2021_vdq_clipped as
(
SELECT
sr21_quebec_loc.sr,
sr21_quebec_loc.unite,
ST_Intersection(uds_resid_vdq.geom, sr21_quebec_loc.geom) as geom
FROM
sr21_quebec_loc
INNER JOIN uds_resid_vdq on ST_Intersects(uds_resid_vdq.geom, sr21_quebec_loc.geom)
GROUP BY sr21_quebec_loc.sr, sr21_quebec_loc.unite, uds_resid_vdq.geom, sr21_quebec_loc.geom
);

-- Regroupe les polygones de l'intersection par leur dauid
DROP TABLE if exists sr2021_vdq_clipped_grouped;
CREATE TABLE sr2021_vdq_clipped_grouped as
(
SELECT
sr2021_vdq_clipped.sr,
sr2021_vdq_clipped.unite,
ST_Union(sr2021_vdq_clipped.geom) as geom
FROM 
sr2021_vdq_clipped 
GROUP BY 
sr, unite
);

-- Sélection des aires à l'extérieur
DROP TABLE if exists sr2021_vdq_clip_joined;
CREATE TABLE sr2021_vdq_clip_joined as
(
  SELECT
  *
  FROM
  sr2021_vdq_clipped_grouped
)
UNION
(
  SELECT
  sr21_quebec_loc.sr,
  sr21_quebec_loc.unite,
  sr21_quebec_loc.geom AS geom
  FROM
  sr21_quebec_loc
  WHERE
  sr21_quebec_loc.sr NOT IN
  (SELECT sr FROM sr2021_vdq_clipped_grouped)
);

-- Calcul la superficie des intersections
ALTER TABLE sr2021_vdq_clip_joined ADD COLUMN area double precision;
UPDATE sr2021_vdq_clip_joined SET area = ST_AREA(geom);

--- Joint avec la couche cible
-- Validation de la géométrie de la couche cible
UPDATE quebec_quartier SET geom = ST_MakeValid(geom);
SELECT sr FROM sr2021_vdq_clip_joined WHERE NOT ST_IsValid(geom);
SELECT nom  FROM quebec_quartier WHERE NOT ST_IsValid(geom);

drop table if exists wad_sr_quartier_int;
CREATE TABLE wad_sr_quartier_int AS
(
SELECT
sr2021_vdq_clip_joined.sr,
sr2021_vdq_clip_joined.unite,
quebec_quartier.nom as quartier,
sr2021_vdq_clip_joined.area AS area_full,
ST_Intersection(sr2021_vdq_clip_joined.geom, quebec_quartier.geom) AS geom
FROM
sr2021_vdq_clip_joined INNER JOIN quebec_quartier ON ST_Intersects(sr2021_vdq_clip_joined.geom, quebec_quartier.geom)
WHERE sr2021_vdq_clip_joined.geom && quebec_quartier.geom
);

-- update area of intersected geoms - and compute ratio
ALTER TABLE wad_sr_quartier_int ADD COLUMN area_int double precision;
UPDATE wad_sr_quartier_int SET area_int = ST_AREA(geom);

ALTER TABLE wad_sr_quartier_int ADD COLUMN area_ratio double precision;
UPDATE wad_sr_quartier_int SET area_ratio = area_int / area_full;

-- grouping by ct - summing ratios
drop table if exists cwad_sr_to_quartier;
CREATE TABLE cwad_sr_to_quartier AS
(
SELECT
sr,
unite,
quartier,
sum(area_ratio) AS weight
FROM
wad_sr_quartier_int
WHERE area_ratio > 0.00999 OR area_int > 999
GROUP BY sr, quartier, unite
ORDER BY sr, quartier, unite
);

UPDATE cwad_sr_to_quartier SET unite=NULL where unite='';

ALTER TABLE cwad_sr_to_quartier ADD COLUMN unite_est double precision;
UPDATE cwad_sr_to_quartier SET unite_est = unite :: double precision * weight :: double precision;

DROP TABLE IF EXISTS daw_unite_vdq_quartiers;
CREATE TABLE daw_unite_vdq_quartiers as 
(
SELECT 
quartier,
sum(unite_est :: double precision) as unite_est 
FROM 
cwad_sr_to_quartier
GROUP BY 
quartier
);

--drop table if exists cwad_sr_to_quartier_t2;
--CREATE TABLE cwad_sr_to_quartier_t2 AS
--(-- selecting target CTs which were not included!
--SELECT
--'-1'::TEXT AS sr,
--quebec_quartier.nom AS quartier,
---1 AS weight
-- count(*)
--FROM quebec_quartier
--WHERE quebec_quartier.nom NOT IN
--(select distinct quartier from cwad_sr_to_quartier_t1 WHERE quartier IS NOT NULL))
--UNION
--(-- selecting target CTs which were not included!
--SELECT
--sr2021_vdq.sridu AS sr,
--'-1'::TEXT AS quartier,
---1 AS weight
-- count(*)
--FROM sr2021_vdq
--WHERE sr2021_vdq.sridu NOT IN
--(select distinct sr from cwad_sr_to_quartier_t1 WHERE quartier IS NOT NULL));


--drop table if exists cwad_sr_to_quartier_ct;
--CREATE TABLE cwad_sr_to_quartier_ct AS
--(
--select * from cwad_sr_to_quartier_t1
--union
--select * from cwad_sr_to_quartier_t2
--);

drop table sr21_quebec_loc;
drop table uds_resid_vdq;
drop table sr2021_vdq_clipped;
drop table sr2021_vdq_clipped_grouped;
drop table sr2021_vdq_clip_joined;
drop table wad_sr_quartier_int;
drop table cwad_sr_to_quartier;


-- MONTREAL (QUARTIERS)
DROP TABLE IF EXISTS sr21_mtl_loc;
CREATE TABLE sr21_mtl_loc as
(
SELECT
sr2016_mtl.sridu as sr,
sr_schl_22_mtl.unite as unite,
sr2016_mtl.geom
from sr_schl_22_mtl
join sr2016_mtl on sr_schl_22_mtl.sr :: varchar(255) = sr2016_mtl.srnom :: varchar(255)
);

-- Création de la couche auxiliaire
--- https://observatoire.cmm.qc.ca/produits/donnees-georeferencees/#utilisation_du_sol
DROP TABLE if exists uds_resid_mtl;
CREATE TABLE uds_resid_mtl AS
(
SELECT
util_sol,
ST_MakeValid(geom) as geom
FROM uds2016_mtl
WHERE util_sol >= 100 and util_sol <= 114
);

-- Validation de la géométrie
SELECT sridu FROM sr2021_mtl WHERE NOT ST_IsValid(geom);
SELECT util_sol FROM uds_resid_mtl WHERE NOT ST_IsValid(geom);

-- Intersection de la couche auxiliaire et de la couche source
DROP TABLE if exists sr2021_mtl_clipped;
CREATE TABLE sr2021_mtl_clipped as
(
SELECT
sr21_mtl_loc.sr,
sr21_mtl_loc.unite,
ST_Intersection(uds_resid_mtl.geom, sr21_mtl_loc.geom) as geom
FROM
sr21_mtl_loc
INNER JOIN uds_resid_mtl on ST_Intersects(uds_resid_mtl.geom, sr21_mtl_loc.geom)
GROUP BY sr21_mtl_loc.sr, sr21_mtl_loc.unite, uds_resid_mtl.geom, sr21_mtl_loc.geom
);

-- Regroupe les polygones de l'intersection par leur dauid
DROP TABLE if exists sr2021_mtl_clipped_grouped;
CREATE TABLE sr2021_mtl_clipped_grouped as
(
SELECT
sr2021_mtl_clipped.sr,
sr2021_mtl_clipped.unite,
ST_Union(sr2021_mtl_clipped.geom) as geom
FROM 
sr2021_mtl_clipped 
GROUP BY 
sr, unite
);

-- Sélection des aires à l'extérieur
DROP TABLE if exists sr2021_mtl_clip_joined;
CREATE TABLE sr2021_mtl_clip_joined as
(
  SELECT
  *
  FROM
  sr2021_mtl_clipped_grouped
)
UNION
(
  SELECT
  sr21_mtl_loc.sr,
  sr21_mtl_loc.unite,
  sr21_mtl_loc.geom AS geom
  FROM
  sr21_mtl_loc
  WHERE
  sr21_mtl_loc.sr NOT IN
  (SELECT sr FROM sr2021_mtl_clipped_grouped)
);

-- Calcul la superficie des intersections
ALTER TABLE sr2021_mtl_clip_joined ADD COLUMN area double precision;
UPDATE sr2021_mtl_clip_joined SET area = ST_AREA(geom);

--- Joint avec la couche cible
-- Validation de la géométrie de la couche cible
UPDATE quartiers_mtl SET geom = ST_MakeValid(geom);
SELECT sr FROM sr2021_mtl_clip_joined WHERE NOT ST_IsValid(geom);
SELECT nom  FROM quartiers_mtl WHERE NOT ST_IsValid(geom);

drop table if exists wad_sr_quartier_int;
CREATE TABLE wad_sr_quartier_int AS
(
SELECT
sr2021_mtl_clip_joined.sr,
sr2021_mtl_clip_joined.unite,
quartiers_mtl.nom as quartier,
sr2021_mtl_clip_joined.area AS area_full,
ST_Intersection(sr2021_mtl_clip_joined.geom, quartiers_mtl.geom) AS geom
FROM
sr2021_mtl_clip_joined INNER JOIN quartiers_mtl ON ST_Intersects(sr2021_mtl_clip_joined.geom, quartiers_mtl.geom)
WHERE sr2021_mtl_clip_joined.geom && quartiers_mtl.geom
);

-- update area of intersected geoms - and compute ratio
ALTER TABLE wad_sr_quartier_int ADD COLUMN area_int double precision;
UPDATE wad_sr_quartier_int SET area_int = ST_AREA(geom);

ALTER TABLE wad_sr_quartier_int ADD COLUMN area_ratio double precision;
UPDATE wad_sr_quartier_int SET area_ratio = area_int / area_full;

-- grouping by ct - summing ratios
drop table if exists cwad_sr_to_quartier;
CREATE TABLE cwad_sr_to_quartier AS
(
SELECT
sr,
unite,
quartier,
sum(area_ratio) AS weight
FROM
wad_sr_quartier_int
WHERE area_ratio > 0.00999 OR area_int > 999
GROUP BY sr, quartier, unite
ORDER BY sr, quartier, unite
);

UPDATE cwad_sr_to_quartier SET unite=NULL where unite='';

ALTER TABLE cwad_sr_to_quartier ADD COLUMN unite_est double precision;
UPDATE cwad_sr_to_quartier SET unite_est = unite :: double precision * weight :: double precision;

DROP TABLE IF EXISTS daw_unite_mtl_quartiers;
CREATE TABLE daw_unite_mtl_quartiers as 
(
SELECT 
quartier,
sum(unite_est :: double precision) as unite_est 
FROM 
cwad_sr_to_quartier
GROUP BY 
quartier
);

--drop table if exists cwad_sr_to_quartier_t2;
--CREATE TABLE cwad_sr_to_quartier_t2 AS
--(-- selecting target CTs which were not included!
--SELECT
--'-1'::TEXT AS sr,
--mtl_quartier.nom AS quartier,
---1 AS weight
-- count(*)
--FROM mtl_quartier
--WHERE mtl_quartier.nom NOT IN
--(select distinct quartier from cwad_sr_to_quartier_t1 WHERE quartier IS NOT NULL))
--UNION
--(-- selecting target CTs which were not included!
--SELECT
--sr2021_mtl.sridu AS sr,
--'-1'::TEXT AS quartier,
---1 AS weight
-- count(*)
--FROM sr2021_mtl
--WHERE sr2021_mtl.sridu NOT IN
--(select distinct sr from cwad_sr_to_quartier_t1 WHERE quartier IS NOT NULL));


--drop table if exists cwad_sr_to_quartier_ct;
--CREATE TABLE cwad_sr_to_quartier_ct AS
--(
--select * from cwad_sr_to_quartier_t1
--union
--select * from cwad_sr_to_quartier_t2
--);

drop table sr21_mtl_loc;
drop table uds_resid_mtl;
drop table sr2021_mtl_clipped;
drop table sr2021_mtl_clipped_grouped;
drop table sr2021_mtl_clip_joined;
drop table wad_sr_quartier_int;
drop table cwad_sr_to_quartier;





