@AbapCatalog.sqlViewName: 'ZBILLRATE_H'
@AbapCatalog.compiler.compareFilter: true
--@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bill Rate Historical Data'
@Metadata.ignorePropagatedAnnotations: true
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
        delta.changeDataCapture: {
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
              }
              ,
              {
                table:'TCURX',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['CURRKEY'],
                tableElement: ['CURRKEY']

              }

            ]
         }
      }
    }

--@AccessControl.personalData.blocking: #('TRANSACTIONAL_DATA')

@Metadata.allowExtensions:true

define view ZFIN_I_BillRate_History
  as select from           konp
    left outer to one join a304  on  a304.kschl = 'ZPSP'
                                 and a304.kappl = 'V'
    --and a304.datbi<$session.system_date--Condition added to get Current Records in order to avoid Old Records gettting in Output..Tarun A
                                 and konp.mandt = a304.mandt
                                 and konp.knumh = a304.knumh
                                 and konp.kschl = a304.kschl
                                 and konp.kappl = a304.kappl

    left outer to one join a920  on  a920.kschl = 'ZPSP'
                                 and a920.kappl = 'V'
    -- and a920.datbi<$session.system_date
                                 and konp.mandt = a920.mandt
                                 and konp.knumh = a920.knumh
                                 and konp.kschl = a920.kschl
                                 and konp.kappl = a920.kappl

    left outer to one join tcurx on konp.konwa = tcurx.currkey


{

  key konp.knumh,
  key konp.kopos,
      konp.kschl                                                                                                      as kschl,
      konp.kappl                                                                                                      as kappl,
      max(case when konp.knumh=a304.knumh then a304.vkorg when konp.knumh=a920.knumh then a920.vkorg else '' end)          as vkorg, --Tarun A: Case statements added to get the unique field as output based on conditional mapping.
      max(case when konp.knumh=a304.knumh then a304.vtweg when konp.knumh=a920.knumh then a920.vtweg else '' end)          as vtweg,
      max(case when konp.knumh=a304.knumh then a304.matnr when konp.knumh=a920.knumh then a920.matnr else '' end)          as matnr,
      max(case when konp.knumh=a304.knumh then a304.kfrst when konp.knumh=a920.knumh then a920.kfrst else '' end)          as kfrst,
      max(case when konp.knumh=a304.knumh then (a304.datab) when konp.knumh=a920.knumh then (a920.datab) else '' end) as datab,
      max(case when konp.knumh=a304.knumh then (a304.datbi) when konp.knumh=a920.knumh then (a920.datbi) else '' end) as datbi,
      max(case when konp.knumh=a920.knumh then a920.vkaus else '' end)                                                as vkaus,
      tcurx.currkey,
      konp.knumt                                                                                                      as knumt,
      konp.stfkz                                                                                                      as stfkz,
      konp.kzbzg                                                                                                      as kzbzg,
      konp.kstbm                                                                                                      as kstbm,
      konp.konms                                                                                                      as konms,
      konp.kstbw                                                                                                      as kstbw,
      konp.konws                                                                                                      as konws,
      konp.krech                                                                                                      as krech,
      @DefaultAggregation: #SUM
      konp.kbetr                                                                                                      as kbetr,
      konp.konwa                                                                                                      as konwa,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>konp.kbetr,currency=>konp.konwa) as abap.dec( 20, 2 ))                               as BaseBillRate,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>konp.kbetr,currency=>konp.konwa) as abap.dec( 20, 2 ))*7                             as DailyBillRate,
      konp.kpein                                                                                                      as kpein,
      konp.kmein                                                                                                      as kmein,
      konp.prsch                                                                                                      as prsch,
      konp.kumza                                                                                                      as kumza,
      konp.kumne                                                                                                      as kumne,
      konp.meins                                                                                                      as meins,
      konp.kwaeh                                                                                                      as kwaeh,
      konp.kunnr                                                                                                      as kunnr,
      max(case when konp.knumh=a304.knumh and a304.datbi>=$session.system_date then 'Y'
      when konp.knumh=a920.knumh and a920.datbi>=$session.system_date then 'Y' else 'N' end)                      as ActiveFlag,
      max(case when konp.knumh=a304.knumh then 'A304' when konp.knumh=a920.knumh then 'A920' else 'OTH' end)               as Flag,
      konp.loevm_ko,
      tstmp_current_utctimestamp()                                                                                    as ZTimeStamp ---Tarun A: TimeStamp Field added for Delta Load.

}
where
      konp.kschl = 'ZPSP'
  and konp.kappl = 'V'
group by
  konp.knumh,
  a920.knumh,
  a304.knumh,
  konp.kopos,
  konp.kschl,
  konp.kappl,
  a304.vkorg,
  a304.vtweg,
  a304.matnr,
  a920.matnr,
  a304.kfrst,
  a920.kfrst,
  a920.vkorg,
  a920.vtweg,
  a920.vkaus,
  tcurx.currkey,
  konp.knumt,
  konp.konws,
  konp.stfkz,
  konp.kzbzg,
  konp.kstbm,
  konp.konms,
  konp.kstbw,
  konp.kstbw,
  konp.krech,
  konp.kbetr,
  konp.konwa,
  konp.kpein,
  konp.kmein,
  konp.prsch,
  konp.kumza,
  konp.kumne,
  konp.meins,
  konp.kwaeh,
  konp.kunnr,
  konp.loevm_ko
