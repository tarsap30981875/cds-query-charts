@AbapCatalog.sqlViewName: 'ZFIN_MAT_REL_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Release Status (A304) View'
@Consumption.dbHints: [ 'USE_HEX_PLAN' ]
@AbapCatalog.buffering.status: #NOT_ALLOWED
@Analytics: { dataCategory: #DIMENSION, dataExtraction.enabled:true }
@ObjectModel: { usageType.sizeCategory: #S,
                usageType.dataClass:  #ORGANIZATIONAL,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#ANALYTICAL_DIMENSION, #CDS_MODELING_ASSOCIATION_TARGET, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE, #EXTRACTION_DATA_SOURCE],
                modelingPattern: #ANALYTICAL_DIMENSION
                }
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions:true

define view ZFIN_I_MAT_RELEASE_STATUS as select from a304 
inner join 
scal_tt_date as CalDate on CalDate.calendardate=a304.datab--Tarun A: Changes added to Push Date Delta Logic
{
    
    key a304.kappl,
    key a304.kschl,
    key a304.vkorg,
    key a304.vtweg,
    key a304.matnr,
    key a304.kfrst,
    max(a304.datbi) as datbi,
    max(a304.datab) as datab,
    max(CalDate.calendardate) as CalendarDate,
    a304.kbstat as kbstat,
    a304.knumh as knumh,
    a304.mandt,
    --dats_days_between($session.system_date,max(a304.datab)) as DatabDiff,
    
    'A304'as FLAG
}
where a304.kappl='V' and a304.kschl='ZPSP' and a304.mandt=$session.client
group by a304.kappl,
    a304.kschl,
    a304.vkorg,
    a304.vtweg,
    a304.matnr,
    a304.kfrst,
    a304.mandt,
    a304.kbstat,
    a304.knumh
