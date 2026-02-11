@AbapCatalog.sqlViewName: 'ZFIN_TEAM_R_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CPM Team Roles Details Model'
@Metadata.ignorePropagatedAnnotations: true
define view ZFIN_I_TEAM_R_DETAILS as select from 
/cpd/d_mp_team as Team
association[0..1] to
/cpd/d_mp_team_r as TeamRoles on Team.mandt=TeamRoles.mandt
and Team.db_key=TeamRoles.parent_key
and TeamRoles.role_id<>'9999'
 
{
    key Team.mandt,
    key Team.db_key as DbKey,
    Team.parent_key as ParentKey,
    Team.parent_team_key as ParentTeamKey,
    Team.team_type as TeamType,
    Team.team_id as TeamId,
    Team.team_name as TeamName,
    Team.status_period as StatusPeriod,
    Team.created_by as CreatedBy,
    Team.created_on as CreatedOn,
    Team.changed_by as ChangedBy,
    Team.changed_on as ChangedOn,
    Team.left_key as LeftKey,
    Team.right_key as RightKey,
    Team.manage_status as ManageStatus,
    Team.status_template as StatusTemplate,
    TeamRoles.db_key as DB_KEY_TEAM_R,
    TeamRoles.parent_key,
    TeamRoles.role_id,
    TeamRoles.root_key
    
}
