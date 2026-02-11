/************************************************************************
* Created By   : 30981875 (Tarun Arora)
* Creation Date: 13-01-2024
* TS ID        :
* Description  : Bill Rate Model (for Interface)
* FS Revison   :
************************************************************************
* Bill Rate Base Model with the Key Tables KONP, A304, A920 with Delta Enabled Logic
* Modification History (Most Recent on Top)
************************************************************************
* Date         User_ID    Transport#  Description
* ----------------------------------------------------------------------
* 13-Jan-2025  30981875-Tarun Arora
* SD1K915770   Bill Rate
*************************************************************************/
@AbapCatalog.sqlViewName: 'ZBILLRATE_V'
@AbapCatalog.compiler.compareFilter: true
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Consumption.dbHints: [ 'USE_HEX_PLAN' ]
@EndUserText.label: 'Bill Rate Computation Base View'
@AbapCatalog.buffering.status: #NOT_ALLOWED


@ObjectModel: {
                usageType.sizeCategory: #XXL,
                usageType.dataClass:  #TRANSACTIONAL,
                usageType.serviceQuality: #B,
                supportedCapabilities: [ #EXTRACTION_DATA_SOURCE ],
                modelingPattern: #NONE

               }

@Analytics: {
      dataCategory: #CUBE,
      dataExtraction: {
        enabled:true,
        delta.byElement.name: 'lastChangedDate',
        //delta.changeDataCapture.automatic: true,
        delta.changeDataCapture:
         {
          mapping:
            [

               {
                table: 'KONP',
                role: #MAIN,
                viewElement: ['knumh','kopos'],
                tableElement: ['knumh','kopos']
              },

              {
                table: 'A304',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['kappl','kschl','vkorg','vtweg','matnr','kfrst','datbi'],
                tableElement: ['kappl','kschl','vkorg','vtweg','matnr','kfrst','datbi'],
                filter: [{tableElement: 'kschl',operator: #EQ,value: 'ZPSP'},{tableElement: 'kappl',operator: #EQ,value: 'V' }]
              }
              ,
               {
                table:'a920',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['kappl','kschl','vkorg','vtweg','matnr','kfrst','datbi','vkaus'],--
                tableElement: ['kappl','kschl','vkorg','vtweg','matnr','kfrst','datbi','vkaus'],
                filter: [{tableElement: 'kschl',operator: #EQ,value: 'ZPSP'},{tableElement: 'kappl',operator: #EQ,value: 'V' }]
              },
              {
                table:'scal_tt_date',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['CalendarDate'],--
                tableElement: ['CalendarDate']
              }
             ]
         }
      }
    }

define view ZFIN_I_BILLRATE
  as select from           konp

    left outer to one join ZFIN_I_MAT_RELEASE_STATUS as A304 on  konp.mandt = A304.mandt
                                                             and konp.knumh = A304.knumh
                                                             and konp.kschl = A304.kschl
                                                             and konp.kappl = A304.kappl

    left outer to one join ZFIN_I_SPA_BILLRATE       as a920 on  konp.mandt = a920.mandt
                                                             and konp.knumh = a920.knumh
                                                             and konp.kschl = a920.kschl
                                                             and konp.kappl = a920.kappl

{

  key konp.knumh,
  key konp.kopos,
      A304.CalendarDate,
      konp.kschl                                                                                                                    as kschl,
      konp.kappl                                                                                                                    as kappl,
      ----Tarun A: Dated 4th March: the below code is not performance wise effective but this is written to avoid data
      --- quality issues at S4HANA, Sandeep is aware on the same as we have for single condition record KUNMH have multiple values
      ----because DATAB and DATBI in A304 which is business wise not a valid case but since we have records all the way till Production
      ----and this particular issue is stopping the logic to move forward, made me need to write below expensive code...Tarun A
      //      max(case when konp.knumh=a304.knumh then a304.vkorg when konp.knumh=a920.knumh then a920.vkorg else '' end)                   as vkorg, --Tarun A: Case statements added to get the unique field as output based on conditional mapping.
      //      max(case when konp.knumh=a304.knumh then a304.vtweg when konp.knumh=a920.knumh then a920.vtweg else '' end)                   as vtweg,
      //      max(case when konp.knumh=a304.knumh then a304.matnr when konp.knumh=a920.knumh then a920.matnr else '' end)                   as matnr,
      //      max(case when konp.knumh=a304.knumh then a304.kfrst when konp.knumh=a920.knumh then a920.kfrst else '' end)                   as kfrst,
      //      max(case when konp.knumh=a304.knumh then (a304.datbi) when konp.knumh=a920.knumh then (a920.datbi) else '' end)               as datbi,
      //      min(case when konp.knumh=a304.knumh then (a304.datab) when konp.knumh=a920.knumh then (a920.datab) else '' end)               as datab,
      //      max(case when konp.knumh=a920.knumh then a920.vkaus else '' end)                                                              as vkaus,

      (case when konp.knumh=A304.knumh then A304.vkorg when konp.knumh=a920.knumh then a920.vkorg else '' end)                      as vkorg, --Tarun A: Case statements added to get the unique field as output based on conditional mapping.
      (case when konp.knumh=A304.knumh then A304.vtweg when konp.knumh=a920.knumh then a920.vtweg else '' end)                      as vtweg,
      (case when konp.knumh=A304.knumh then A304.matnr when konp.knumh=a920.knumh then a920.matnr else '' end)                      as matnr,
      (case when konp.knumh=A304.knumh then A304.kfrst when konp.knumh=a920.knumh then a920.kfrst else '' end)                      as kfrst,
      (case when konp.knumh=A304.knumh then (A304.datbi) when konp.knumh=a920.knumh then (a920.datbi) else '' end)                  as datbi,
      (case when konp.knumh=A304.knumh then (A304.datab) when konp.knumh=a920.knumh then (a920.datab) else '' end)                  as datab,
      (case when konp.knumh=a920.knumh then a920.vkaus else '' end)                                                                 as vkaus,

      --tcurx.currkey,
      konp.knumt                                                                                                                    as knumt,
      konp.stfkz                                                                                                                    as stfkz,
      konp.kzbzg                                                                                                                    as kzbzg,
      konp.kstbm                                                                                                                    as kstbm,
      konp.konms                                                                                                                    as konms,
      konp.kstbw                                                                                                                    as kstbw,
      konp.konws                                                                                                                    as konws,
      konp.krech                                                                                                                    as krech,
      @DefaultAggregation: #SUM
      konp.kbetr                                                                                                                    as kbetr,
      konp.konwa                                                                                                                    as konwa,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>konp.kbetr,currency=>konp.konwa) as abap.dec( 20, 2 ))                                             as BaseBillRate,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>konp.kbetr,currency=>konp.konwa) as abap.dec( 20, 2 ))*7                                           as DailyBillRate,
      konp.kpein                                                                                                                    as kpein,
      konp.kmein                                                                                                                    as kmein,
      konp.prsch                                                                                                                    as prsch,
      konp.kumza                                                                                                                    as kumza,
      konp.kumne                                                                                                                    as kumne,
      konp.meins                                                                                                                    as meins,
      konp.kwaeh                                                                                                                    as kwaeh,
      konp.kunnr                                                                                                                    as kunnr,

      //      max(case when konp.knumh=a304.knumh and a304.datbi>=$session.system_date then 'Y'
      //      when konp.knumh=a920.knumh and a920.datbi>=$session.system_date then 'Y' else 'N' end)                                        as ActiveFlag,

      --Added below code as suggested by Sandeep K Dated Dec 15 2025 for Skill Code Issue...Tarun A
      --DATAB: Validity start date of the condition record
      --DATBI: Validity end date of the condition record
      //      max(case when konp.knumh=a304.knumh and (a304.datab<=$session.system_date and a304.datbi>=$session.system_date) then 'Y'
      //      when konp.knumh=a920.knumh and (a920.datab<=$session.system_date and a920.datbi>=$session.system_date) then 'Y' else 'N' end) as ActiveFlag,
      (case when konp.knumh=A304.knumh and (A304.datab<=$session.system_date and A304.datbi>=$session.system_date) then 'Y'
      when konp.knumh=a920.knumh and (a920.datab<=$session.system_date and a920.datbi>=$session.system_date) then 'Y' else 'N' end) as ActiveFlag,


      --max(case when konp.knumh=a304.knumh then 'A304' when konp.knumh=a920.knumh then 'A920' else 'OTH' end)                        as Flag,
      (case when konp.knumh=A304.knumh then 'A304' when konp.knumh=a920.knumh then 'A920' else 'OTH' end)                           as Flag,
      konp.loevm_ko,
      tstmp_current_utctimestamp()                                                                                                  as ZTimeStamp, ---Tarun A: TimeStamp Field added for Delta Load.
      @Semantics.systemDate.lastChangedAt:true
      $session.system_date                                                                                                          as lastChangedDate ---Tarun A: TimeStamp Field added for Delta Load.


}
where
      konp.kschl = 'ZPSP'
  and konp.kappl = 'V'
