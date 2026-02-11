@AbapCatalog.sqlViewName: 'ZFIN_TEAM_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Team Member-Roles Model'
@Metadata.ignorePropagatedAnnotations: true
define view ZFIN_I_TEAM_DETAILS as 
select from /cpd/d_mp_team_m as M
association [0..1] to /cpd/d_mp_member as MEM on M.mandt=MEM.mandt
and M.pm_guid =MEM.db_key
{
    key M.db_key as DbKey,
    M.root_key as RootKey,
    M.parent_key as ParentKey,
    M.pm_guid as PmGuid,
    M.proj_role_guid as ProjRoleGuid,
    M.start_date as StartDate,
    M.end_date as EndDate,
    MEM.db_key as MEM_DB_KEY,
    MEM.bupa_id,
    MEM.parent_key as mem_parent_key,
    MEM.main_team_guid,
    MEM.mp_itm_otyp , MEM.mp_item_okey , MEM.mem_id , MEM.mem_object_type 
    
}
