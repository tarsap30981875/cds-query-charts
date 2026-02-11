@AbapCatalog.sqlViewName: 'ZFIN_TM_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Team Member-Roles Model'
@Metadata.ignorePropagatedAnnotations: true
define view ZFIN_I_TEAM_MEMBER_DETAILS as select from ZFIN_I_TEAM_R_DETAILS as TEAM
association[0..1] to ZFIN_I_TEAM_DETAILS as MEM on TEAM.DbKey=MEM.main_team_guid
{
    
    key TEAM.mandt,
    key TEAM.DbKey,
    TEAM.ParentKey,
    TEAM.ParentTeamKey,
    TEAM.TeamType,
    TEAM.TeamId,
    TEAM.TeamName,
    TEAM.StatusPeriod,
    TEAM.CreatedBy,
    TEAM.CreatedOn,
    TEAM.ChangedBy,
    TEAM.ChangedOn,
    TEAM.LeftKey,
    TEAM.RightKey,
    TEAM.ManageStatus,
    TEAM.StatusTemplate,
    TEAM.DB_KEY_TEAM_R,
    TEAM.parent_key,
    TEAM.role_id,
    TEAM.root_key,
    MEM.DbKey as MEM_DB_KEY,
    MEM.RootKey,
    MEM.PmGuid,
    MEM.ProjRoleGuid,
    MEM.StartDate,
    MEM.EndDate,
    MEM.bupa_id,
    MEM.mem_parent_key,
    MEM.main_team_guid,
    MEM.mp_itm_otyp,
    MEM.mp_item_okey,
    MEM.mem_id,
    MEM.mem_object_type
}
