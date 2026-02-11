@AbapCatalog.sqlViewName: 'ZFIN_EXPACC_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Accounts Model'
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

/** This new model created in order to cater requirement of Expense Accounts for Expense Report, Logic is thoroughly discussed with Sandeep K on Dated 03rd Oct 2025: Tarun A **/

/**XREF3 added as requested by Nivedhitha Dated 28th Oct 2025 Tarun A**/

define view ZFIN_I_EXPENSE_ACCOUNTS
  as select
    rclnt,
    gjahr,
    rbukrs     as BUKRS,
    belnr,
    max(zmcksac_xref3_jei) as XREF3,
    max(lifnr) as LIFNR,
    'EXPREC' as EXPRECFlag
  from acdoca
  where
         rldnr =    '0L'
    and(
         lifnr like '001%'
      or lifnr like '003%'
    )
    and  koart =    'K'
    and  rclnt = $session.client
  group by
    gjahr,
    rbukrs,
    belnr
