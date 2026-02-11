/**

Model Created as per JIRA Requirement for HR Master Logic

-----------------------------------As per JIRA Ticket:FPDA-2731---------------------------------------

Model Created by Tarun A: Dated 30/01/2026
**/
@AbapCatalog.sqlViewName: 'ZFIN_HR_MAST_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HR Master Record'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                usageType.sizeCategory: #M,
                usageType.dataClass:  #MASTER,
                usageType.serviceQuality: #C,
                supportedCapabilities: [ #EXTRACTION_DATA_SOURCE,#ANALYTICAL_QUERY ],
                modelingPattern: #ANALYTICAL_CUBE }

@Analytics: {
      dataCategory: #FACT,
      dataExtraction: {
        enabled:true,
        delta.changeDataCapture: {
          mapping:
            [


              {
                table: 'PA0000',
                role: #MAIN,
                viewElement: ['PERNR','SUBTY','OBJPS','SPRPS','BEGDA','ENDDA','SEQNR'],
                tableElement: ['PERNR','SUBTY','OBJPS','SPRPS','BEGDA','ENDDA','SEQNR']

              },


                            {
                table: 'PA9001',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['PA9001_PERNR','PA9001_BEGDA','PA9001_ENDDA'],
                tableElement: ['PERNR','BEGDA','ENDDA']

              }
            ]
         }
      }
    }


define view ZFIN_I_HR_MASTER
  as select from pa0000
  association [0..1] to pa9001 on  pa0000.pernr =  PA9001.pernr
                               and pa0000.endda >= PA9001.begda
                               and pa0000.endda <= PA9001.endda
{
  key pa0000.pernr as Pernr,
  key pa0000.subty as Subty,
  key pa0000.objps as Objps,
  key pa0000.sprps as Sprps,
  key pa0000.endda as Endda,
  key pa0000.begda as Begda,
  key pa0000.seqnr as Seqnr,
      pa0000.aedtm as Aedtm,
      pa0000.uname as Uname,
      pa0000.histo as Histo,
      pa0000.itxex as Itxex,
      pa0000.refex as Refex,
      pa0000.ordex as Ordex,
      pa0000.itbld as Itbld,
      pa0000.preas as Preas,
      pa0000.flag1 as Flag1,
      pa0000.flag2 as Flag2,
      pa0000.flag3 as Flag3,
      pa0000.flag4 as Flag4,
      pa0000.rese1 as Rese1,
      pa0000.rese2 as Rese2,
      pa0000.grpvl as Grpvl,
      pa0000.massn as Massn,
      pa0000.massg as Massg,
      pa0000.stat1 as Stat1,
      pa0000.stat2 as Stat2,
      pa0000.stat3 as Stat3,
          
      pa9001.pernr as PA9001_PERNR,
      pa9001.begda as PA9001_BEGDA,
      pa9001.endda as PA9001_ENDDA,
      pa9001.role_category,
      pa9001.band,
      pa9001.work_percent                                                                                                                                                                         as WORK_PERCENT,
      pa9001.client_serving                                                                                                                                                                       as CLIENT_SERVING,
      pa9001.fcat                                                                                                                                                                                 as FCAT,
      pa9001.sub_band                                                                                                                                                                             as SUB_BAND,
      pa9001.path                                                                                                                                                                                 as PATH,
      pa9001.skill_code                                                                                                                                                                           as SKILL_CODE,
      pa9001.skill_code_text
}
