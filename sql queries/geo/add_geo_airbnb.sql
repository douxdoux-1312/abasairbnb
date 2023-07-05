-- 2023-05-31

-- MRC
--- https://www.donneesquebec.ca/recherche/dataset/decoupages-administratifs,
drop table if exists airbnb_analysis_2023_05_31_mrc;
create table airbnb_analysis_2023_05_31_mrc as
SELECT
airbnb_qc_ads_2023_05_31.id,
airbnb_qc_ads_2023_05_31.title,
airbnb_qc_ads_2023_05_31.type,
airbnb_qc_ads_2023_05_31.type_scraped,
airbnb_qc_ads_2023_05_31.url,
airbnb_qc_ads_2023_05_31.host_id,
airbnb_qc_ads_2023_05_31.host_since,
airbnb_qc_ads_2023_05_31.description,
airbnb_qc_ads_2023_05_31.price,
airbnb_qc_ads_2023_05_31.note,
airbnb_qc_ads_2023_05_31.nb_comments,
airbnb_qc_ads_2023_05_31.availabilities,
airbnb_qc_ads_2023_05_31.unvailabilities,
airbnb_qc_ads_2023_05_31.commentaires,
airbnb_qc_ads_2023_05_31.rental_period,
airbnb_qc_ads_2023_05_31.licence,
mrc_s.mrs_nm_mrc as mrc,
airbnb_qc_ads_2023_05_31.geom
FROM airbnb_qc_ads_2023_05_31
LEFT OUTER JOIN mrc_s
ON st_within(airbnb_qc_ads_2023_05_31.geom, mrc_s.geom);

-- REGIONS
--- https://www.donneesquebec.ca/recherche/dataset/decoupages-administratifs,
drop table if exists airbnb_analysis_reg_2023_05_31;
create table airbnb_analysis_reg_2023_05_31 as
SELECT
airbnb_analysis_2023_05_31_mrc.id,
airbnb_analysis_2023_05_31_mrc.title,
airbnb_analysis_2023_05_31_mrc.type,
airbnb_analysis_2023_05_31_mrc.type_scraped,
airbnb_analysis_2023_05_31_mrc.url,
airbnb_analysis_2023_05_31_mrc.host_id,
airbnb_analysis_2023_05_31_mrc.host_since,
airbnb_analysis_2023_05_31_mrc.description,
airbnb_analysis_2023_05_31_mrc.price,
airbnb_analysis_2023_05_31_mrc.note,
airbnb_analysis_2023_05_31_mrc.nb_comments,
airbnb_analysis_2023_05_31_mrc.availabilities,
airbnb_analysis_2023_05_31_mrc.unvailabilities,
airbnb_analysis_2023_05_31_mrc.commentaires,
airbnb_analysis_2023_05_31_mrc.rental_period,
airbnb_analysis_2023_05_31_mrc.licence,
airbnb_analysis_2023_05_31_mrc.mrc,
regio_s.res_nm_reg as reg,
airbnb_analysis_2023_05_31_mrc.geom
FROM airbnb_analysis_2023_05_31_mrc
LEFT OUTER JOIN regio_s
ON st_within(airbnb_analysis_2023_05_31_mrc.geom, regio_s.geom);

-- MUNICIPALITÉS
--- https://www.donneesquebec.ca/recherche/dataset/decoupages-administratifs,
drop table if exists airbnb_analysis_muni_2023_05_31;
create table airbnb_analysis_muni_2023_05_31 as
SELECT
airbnb_analysis_reg_2023_05_31.id,
airbnb_analysis_reg_2023_05_31.title,
airbnb_analysis_reg_2023_05_31.type,
airbnb_analysis_reg_2023_05_31.type_scraped,
airbnb_analysis_reg_2023_05_31.url,
airbnb_analysis_reg_2023_05_31.host_id,
airbnb_analysis_reg_2023_05_31.host_since,
airbnb_analysis_reg_2023_05_31.description,
airbnb_analysis_reg_2023_05_31.price,
airbnb_analysis_reg_2023_05_31.note,
airbnb_analysis_reg_2023_05_31.nb_comments,
airbnb_analysis_reg_2023_05_31.availabilities,
airbnb_analysis_reg_2023_05_31.unvailabilities,
airbnb_analysis_reg_2023_05_31.commentaires,
airbnb_analysis_reg_2023_05_31.rental_period,
airbnb_analysis_reg_2023_05_31.licence,
airbnb_analysis_reg_2023_05_31.mrc,
airbnb_analysis_reg_2023_05_31.reg,
munic_s.mus_nm_mun as muni,
airbnb_analysis_reg_2023_05_31.geom
FROM airbnb_analysis_reg_2023_05_31
LEFT OUTER JOIN munic_s
ON st_within(airbnb_analysis_reg_2023_05_31.geom, munic_s.geom);

-- MONTREAL (QUARTIERS)
--- https://www.donneesquebec.ca/recherche/dataset/vmtl-quartiers-sociologiques
drop table if exists airbnb_mtl_data_2023_05_31;
create table airbnb_analysis_mtl_2023_05_31 as
SELECT
airbnb_analysis_muni_2023_05_31.id,
airbnb_analysis_muni_2023_05_31.title,
airbnb_analysis_muni_2023_05_31.type,
airbnb_analysis_muni_2023_05_31.type_scraped,
airbnb_analysis_muni_2023_05_31.url,
airbnb_analysis_muni_2023_05_31.host_id,
airbnb_analysis_muni_2023_05_31.host_since,
airbnb_analysis_muni_2023_05_31.description,
airbnb_analysis_muni_2023_05_31.price,
airbnb_analysis_muni_2023_05_31.note,
airbnb_analysis_muni_2023_05_31.nb_comments,
airbnb_analysis_muni_2023_05_31.availabilities,
airbnb_analysis_muni_2023_05_31.unvailabilities,
airbnb_analysis_muni_2023_05_31.commentaires,
airbnb_analysis_muni_2023_05_31.rental_period,
airbnb_analysis_muni_2023_05_31.licence,
airbnb_analysis_muni_2023_05_31.mrc,
airbnb_analysis_muni_2023_05_31.reg,
airbnb_analysis_muni_2023_05_31.muni,
quartiers_mtl.nom as mtl,
airbnb_analysis_muni_2023_05_31.geom
FROM airbnb_analysis_muni_2023_05_31
LEFT OUTER JOIN quartiers_mtl
ON st_within(airbnb_analysis_muni_2023_05_31.geom, quartiers_mtl.geom);

-- QUÉBEC (QUARTIERS)
--- https://www.donneesquebec.ca/recherche/dataset/vque_9#
drop table if exists airbnb_qc_data_2023_05_31;
create table airbnb_analysis_qc_2023_05_31 as
SELECT
airbnb_analysis_mtl_2023_05_31.id,
airbnb_analysis_mtl_2023_05_31.title,
airbnb_analysis_mtl_2023_05_31.type,
airbnb_analysis_mtl_2023_05_31.type_scraped,
airbnb_analysis_mtl_2023_05_31.url,
airbnb_analysis_mtl_2023_05_31.host_id,
airbnb_analysis_mtl_2023_05_31.host_since,
airbnb_analysis_mtl_2023_05_31.description,
airbnb_analysis_mtl_2023_05_31.price,
airbnb_analysis_mtl_2023_05_31.note,
airbnb_analysis_mtl_2023_05_31.nb_comments,
airbnb_analysis_mtl_2023_05_31.availabilities,
airbnb_analysis_mtl_2023_05_31.unvailabilities,
airbnb_analysis_mtl_2023_05_31.commentaires,
airbnb_analysis_mtl_2023_05_31.rental_period,
airbnb_analysis_mtl_2023_05_31.licence,
airbnb_analysis_mtl_2023_05_31.mrc,
airbnb_analysis_mtl_2023_05_31.reg,
airbnb_analysis_mtl_2023_05_31.muni,
airbnb_analysis_mtl_2023_05_31.mtl,
quebec_quartier.nom as vdq,
airbnb_analysis_mtl_2023_05_31.geom
FROM airbnb_analysis_mtl_2023_05_31
LEFT OUTER JOIN quebec_quartier
ON st_within(airbnb_analysis_mtl_2023_05_31.geom, quebec_quartier.geom);

-- RMR ET AR
--- https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
drop table if exists airbnb_rmr_data_2023_05_31;
create table airbnb_analysis_rmr_2023_05_31 as
SELECT
airbnb_analysis_qc_2023_05_31.id,
airbnb_analysis_qc_2023_05_31.title,
airbnb_analysis_qc_2023_05_31.type,
airbnb_analysis_qc_2023_05_31.type_scraped,
airbnb_analysis_qc_2023_05_31.url,
airbnb_analysis_qc_2023_05_31.host_id,
airbnb_analysis_qc_2023_05_31.host_since,
airbnb_analysis_qc_2023_05_31.description,
airbnb_analysis_qc_2023_05_31.price,
airbnb_analysis_qc_2023_05_31.note,
airbnb_analysis_qc_2023_05_31.nb_comments,
airbnb_analysis_qc_2023_05_31.availabilities,
airbnb_analysis_qc_2023_05_31.unvailabilities,
airbnb_analysis_qc_2023_05_31.commentaires,
airbnb_analysis_qc_2023_05_31.rental_period,
airbnb_analysis_qc_2023_05_31.licence,
airbnb_analysis_qc_2023_05_31.mrc,
airbnb_analysis_qc_2023_05_31.reg,
airbnb_analysis_qc_2023_05_31.muni,
airbnb_analysis_qc_2023_05_31.mtl,
airbnb_analysis_qc_2023_05_31.vdq,
replace(rmr_boundaries_qc.rmrnom, 'Ottawa - Gatineau (partie du Québec / Quebec part)', 'Ottawa-Gatineau') as rmr,
airbnb_analysis_qc_2023_05_31.geom
FROM airbnb_analysis_qc_2023_05_31
LEFT OUTER JOIN rmr_boundaries_qc
ON st_within(airbnb_analysis_qc_2023_05_31.geom, rmr_boundaries_qc.geom);

-- FINALE TABLE
drop table if exists airbnb_analysis_data_2023_05_31;
create table airbnb_analysis_data_2023_05_31 as
SELECT
airbnb_analysis_rmr_2023_05_31.id,
airbnb_analysis_rmr_2023_05_31.title,
airbnb_analysis_rmr_2023_05_31.type,
airbnb_analysis_rmr_2023_05_31.type_scraped,
airbnb_analysis_rmr_2023_05_31.url,
airbnb_analysis_rmr_2023_05_31.host_id,
airbnb_analysis_rmr_2023_05_31.host_since,
airbnb_analysis_rmr_2023_05_31.description,
airbnb_analysis_rmr_2023_05_31.price,
airbnb_analysis_rmr_2023_05_31.note,
airbnb_analysis_rmr_2023_05_31.nb_comments,
airbnb_analysis_rmr_2023_05_31.availabilities,
airbnb_analysis_rmr_2023_05_31.unvailabilities,
airbnb_analysis_rmr_2023_05_31.commentaires,
airbnb_analysis_rmr_2023_05_31.rental_period,
airbnb_analysis_rmr_2023_05_31.licence,
concat(airbnb_analysis_rmr_2023_05_31.mrc, ' - MRC') as mrc, -- this is done to link data in ArcGIS Dashboard
concat(airbnb_analysis_rmr_2023_05_31.reg, ' - Région') as reg, -- this is done to link data in ArcGIS Dashboard
concat(airbnb_analysis_rmr_2023_05_31.muni, ' - Municipalité') as muni, -- this is done to link data in ArcGIS Dashboard
concat(airbnb_analysis_rmr_2023_05_31.mtl, ' - Quartiers (Mtl)') as mtl, -- this is done to link data in ArcGIS Dashboard
concat(airbnb_analysis_rmr_2023_05_31.vdq, ' - Quartiers (Québec)') as vdq, -- this is done to link data in ArcGIS Dashboard
concat(airbnb_analysis_rmr_2023_05_31.rmr, ' - Région métropolitaine de recensement') as rmr, -- this is done to link data in ArcGIS Dashboard
airbnb_analysis_rmr_2023_05_31.geom
FROM airbnb_analysis_rmr_2023_05_31
LEFT OUTER JOIN muni_rmr_schl
ON st_within(airbnb_analysis_rmr_2023_05_31.geom, muni_rmr_schl.geom);

drop table airbnb_analysis_reg_2023_05_31;
drop table airbnb_analysis_2023_05_31_mrc;
drop table airbnb_analysis_muni_2023_05_31;
drop table airbnb_analysis_mtl_2023_05_31;
drop table airbnb_analysis_qc_2023_05_31;
drop table airbnb_analysis_rmr_2023_05_31;
