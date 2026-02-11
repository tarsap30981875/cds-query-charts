@AbapCatalog.sqlViewName: 'ZSYSDATE_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'System Date'
@Metadata.ignorePropagatedAnnotations: true
define view ZFIN_SYSDATE as select distinct from dd02t
{
    $session.system_date as SYSTEMDT,
    'ZPSP' as Flag
}
where dd02t.ddlanguage='E' and dd02t.tabname='PRPS_STATUS'
