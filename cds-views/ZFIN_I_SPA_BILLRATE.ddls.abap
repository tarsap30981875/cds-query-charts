@AbapCatalog.sqlViewName: 'ZFIN_SPA_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bill Rate Computaion - SPA'

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
define view ZFIN_I_SPA_BILLRATE as select from a920
    
{
    key a920.kappl ,
    key a920.kschl ,
    key a920.vkorg,
    key a920.vtweg,
    key a920.matnr,
    key a920.kfrst,
    key max(a920.datbi) as datbi,
    key a920.vkaus,
    a920.knumh,
    max(a920.datab) as datab,
    a920.kbstat,
    a920.mandt,
    'A920' as Flag
    
}
where a920.mandt=$session.client and a920.kappl='V' and a920.kschl='ZPSP'--Delta Logic Changes done in the Model..Tarun A
group by a920.kappl ,
    a920.kschl ,
    a920.vkorg,
    a920.vtweg,
    a920.matnr,
    a920.kfrst,
    a920.vkaus,
    a920.knumh,
    a920.kbstat
 
