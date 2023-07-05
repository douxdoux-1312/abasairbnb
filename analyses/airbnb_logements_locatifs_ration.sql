-- RMR ET AR
drop table if exists airbnb_rmr;
create table airbnb_rmr as 
select 
count(id) as airbnb,
rmr
from airbnb_analysis_data_2023_05_31
where type like '%Entire rental unit%'
group by rmr;

drop table if exists rmr_log_airbnb;
create table rmr_log_airbnb as 
select 
concat(schl_locatif_22.rmr, ' - Région métropolitaine de recensement') as nom,
airbnb :: double precision,
unitees :: double precision as unite
from airbnb_rmr
join schl_locatif_22 on concat(schl_locatif_22.rmr, ' - Région métropolitaine de recensement') = airbnb_rmr.rmr;

ALTER TABLE rmr_log_airbnb ADD COLUMN pc_airbnb double precision;
UPDATE rmr_log_airbnb SET pc_airbnb = (airbnb :: double precision/unite :: double precision) * 100;
--UPDATE wa_sr21_quartier_vdq_int SET unite=NULL where unite='';

-- MUNICIPALITÉS
drop table if exists airbnb_muni;
create table airbnb_muni as 
select 
count(id) as airbnb,
muni
from airbnb_analysis_data_2023_05_31
where type like '%Entire rental unit%'
group by muni;

drop table if exists muni_log_airbnb;
create table muni_log_airbnb as 
select 
concat(schl_muni_unites_2022.muni, ' - Municipalité') as nom,
airbnb :: double precision,
replace(replace(unite, '--', ''), ',', '')  as unite
from airbnb_muni
join schl_muni_unites_2022 on concat(schl_muni_unites_2022.muni, ' - Municipalité') = airbnb_muni.muni;

UPDATE muni_log_airbnb SET unite = NULL where unite = '';
ALTER TABLE muni_log_airbnb ALTER COLUMN unite TYPE double precision USING unite :: double precision;
ALTER TABLE muni_log_airbnb ADD COLUMN pc_airbnb double precision;
UPDATE muni_log_airbnb SET pc_airbnb = (airbnb :: double precision/unite :: double precision) * 100;
--UPDATE wa_sr21_quartier_vdq_int SET unite=NULL where unite='';

-- MONTRÉAL (QUARTIERS)
drop table if exists airbnb_mtl;
create table airbnb_mtl as 
select 
count(id) as airbnb,
mtl
from airbnb_analysis_data_2023_05_31
where type like '%Entire rental unit%'
group by mtl;

drop table if exists mtl_log_airbnb;
create table mtl_log_airbnb as 
select 
concat(daw_unite_mtl_quartiers.quartier, ' - Quartiers (Mtl)') as nom,
airbnb :: double precision,
unite_est :: double precision as unite
from airbnb_mtl
join daw_unite_mtl_quartiers on concat(daw_unite_mtl_quartiers.quartier, ' - Quartiers (Mtl)') = airbnb_mtl.mtl;

ALTER TABLE mtl_log_airbnb ADD COLUMN pc_airbnb double precision;
UPDATE mtl_log_airbnb SET pc_airbnb = (airbnb :: double precision/unite :: double precision) * 100;

-- QUÉBEC (QUARTIERS)
drop table if exists airbnb_vdq;
create table airbnb_vdq as 
select 
count(id) as airbnb,
vdq
from airbnb_analysis_data_2023_05_31
where type like '%Entire rental unit%'
group by vdq;

drop table if exists vdq_log_airbnb;
create table vdq_log_airbnb as 
select 
concat(daw_unite_vdq_quartiers.quartier, ' - Quartiers (Québec)') as nom,
airbnb :: double precision,
unite_est :: double precision as unite
from airbnb_vdq
join daw_unite_vdq_quartiers on concat(daw_unite_vdq_quartiers.quartier, ' - Quartiers (Québec)') = airbnb_vdq.vdq;

ALTER TABLE vdq_log_airbnb ADD COLUMN pc_airbnb double precision;
UPDATE vdq_log_airbnb SET pc_airbnb = (airbnb :: double precision/unite :: double precision) * 100;

drop table airbnb_vdq;
drop table airbnb_mtl;
drop table airbnb_muni;
drop table airbnb_rmr;

drop table if exists locatif_airbnb_2023_05_31;
create table locatif_airbnb_2023_05_31 as 
select * from vdq_log_airbnb
union
select * from mtl_log_airbnb
union
select * from muni_log_airbnb
union
select * from rmr_log_airbnb;





