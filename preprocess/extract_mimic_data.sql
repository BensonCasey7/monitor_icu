#create master MIMIC event table
drop table if exists CS3750_Group2.KY_MIMIC_EVENTS_V4;
CREATE TABLE CS3750_Group2.KY_MIMIC_EVENTS_V4 as
select
HADM_ID,
EventType,ITEMID,ITEMID2,EventStartTime, Time_to_Discharge
from
(
with sampled_patients as (select distinct HADM_ID
                          from mimiciiiv14.ADMISSIONS
                          order by rand()
                          limit 25000)
select adm.HADM_ID,
#adm.DISCHTIME,adm.DEATHTIME,
'Death' as EventType,
-- It would appear that it is always 0, which is no good
case when adm.DEATHTIME is not null then 1 else 0 end as ITEMID,
case when adm.DEATHTIME is not null then 1 else 0 end as ITEMID2,
adm.ADMITTIME as EventStartTime,
timestampdiff(hour,adm.DISCHTIME,adm.ADMITTIME) as Time_to_Discharge
# timestampdiff(hour,adm.DISCHTIME,adm.DISCHTIME) as Time_to_Discharge
from mimiciiiv14.ADMISSIONS adm
         inner join sampled_patients on adm.HADM_ID = sampled_patients.HADM_ID
#and adm.HADM_ID = 105017

union all

select adm.HADM_ID,
#adm.DISCHTIME,adm.DEATHTIME,
'Lab' as EventType, lab.ITEMID,
case
  when FLAG is not null then concat(lab.ITEMID, lab.FLAG)
  else lab.ITEMID
end as ITEMID2,
lab.CHARTTIME as EventStartTime,
timestampdiff(hour,adm.DISCHTIME,lab.CHARTTIME) as Time_to_Discharge
from mimiciiiv14.ADMISSIONS adm
         inner join sampled_patients on adm.HADM_ID = sampled_patients.HADM_ID
left join mimiciiiv14.LABEVENTS lab on adm.HADM_ID = lab.HADM_ID
where lab.ITEMID is not null
#and adm.HADM_ID = 105017

union all

select adm.HADM_ID,
#adm.DISCHTIME,adm.DEATHTIME,
'Med' as EventType, med.ITEMID, med.ITEMID as ITEMID2,med.STARTTIME as EventStartTime,
timestampdiff(hour, adm.DISCHTIME, med.STARTTIME) as Time_to_Discharge
from mimiciiiv14.ADMISSIONS adm
         inner join sampled_patients on adm.HADM_ID = sampled_patients.HADM_ID
left join mimiciiiv14.INPUTEVENTS_MV med on adm.HADM_ID = med.HADM_ID
where  med.ITEMID is not null
#and adm.HADM_ID = 105017

union all

select adm.HADM_ID,
#adm.DISCHTIME,adm.DEATHTIME,
'Vit' as EventType, vit.ITEMID,
case
    when WARNING = 1 then concat(vit.ITEMID,'W')
    else vit.ITEMID
end as ITEMID2,
vit.CHARTTIME as EventStartTime,
timestampdiff(hour, adm.DISCHTIME, vit.CHARTTIME) as Time_to_Discharge
from mimiciiiv14.ADMISSIONS adm
         inner join sampled_patients on adm.HADM_ID = sampled_patients.HADM_ID
left join mimiciiiv14.CHARTEVENTS vit on adm.HADM_ID = vit.HADM_ID
where vit.ITEMID is not null
#and adm.HADM_ID = 105017
    ) T
order by HADM_ID,Time_to_Discharge
;



#create admission length table
set @row_number = 0;
drop table if exists CS3750_Group2.KY_ADM_LENGTH;
create table CS3750_Group2.KY_ADM_LENGTH as
select (@row_number:=@row_number + 1) as `row`,
t.* from
(select HADM_ID, -1 * min(Time_to_Discharge) adm_length
 from CS3750_Group2.KY_MIMIC_EVENTS_V4
 group by HADM_ID) t
;


#create reference table
drop table if exists CS3750_Group2.KY_LABEL_REF;
create table CS3750_Group2.KY_LABEL_REF as
select *
from (
select 'Lab' as EventType, l.ITEMID2, d.LABEL
from (select distinct ITEMID, ITEMID2 from CS3750_Group2.KY_MIMIC_EVENTS_V4 where EventType = 'Lab') l
left join mimiciiiv14.D_LABITEMS d on l.ITEMID = d.ITEMID

union all

select 'Med' as EventType,l.ITEMID2, d.LABEL
from (select distinct ITEMID,ITEMID2 from CS3750_Group2.KY_MIMIC_EVENTS_V4 where EventType = 'Med') l
left join mimiciiiv14.D_ITEMS d on l.ITEMID = d.ITEMID

union all

select 'Vit' as EventType,l.ITEMID2, d.LABEL
from (select distinct ITEMID, ITEMID2 from CS3750_Group2.KY_MIMIC_EVENTS_V4 where EventType = 'Vit') l
left join mimiciiiv14.D_ITEMS d on l.ITEMID = d.ITEMID
)
t;