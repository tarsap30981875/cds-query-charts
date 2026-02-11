@AbapCatalog.sqlViewName: 'ZOPS_I_VLP_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Line Positing Documents'
@Metadata.ignorePropagatedAnnotations: true
@Analytics: {
      dataCategory: #DIMENSION,
      dataExtraction: {
        enabled:true,
        delta.changeDataCapture: {
          mapping:
            [
              {
                table:'BSEG',
                role: #MAIN,
                viewElement: ['bukrs','belnr','gjahr'],
                tableElement: ['bukrs','belnr','gjahr']

              }
            ]
         }
      }
    }


----- Taking distinct documents for vendor line posting ----------------as Received from Chhavi Gupta
define view ZOPS_I_INVOICE_VENDOR_L_POST as select distinct from bseg
{
    key belnr,
    key gjahr,
    key bukrs
}
where koart='K' and mandt=$session.client
