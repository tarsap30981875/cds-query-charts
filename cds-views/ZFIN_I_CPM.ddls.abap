@AbapCatalog.sqlViewName: 'ZCPM_MAST_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CPM Master Data Model'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
                usageType.sizeCategory: #XXL,
                usageType.dataClass:  #TRANSACTIONAL,
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
                table: '/cpd/d_mp_hdr',
                role: #MAIN,
                viewElement: ['DBKEY'],
                tableElement: ['db_key']

              }
              ,
               {
                table: '/cpd/d_mp_item',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['ITEM_DB_KEY'],
                tableElement: ['db_key']

              },
               {
                table: '/cpd/d_mp_team',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['TEAM_DB_KEY'],
                tableElement: ['db_key']
              }


            ]
         }
      }
    }


define view ZFIN_I_CPM
  as

  select from /cpd/d_mp_hdr as HDR
  association [0..1] to /cpd/d_mp_item as ITEM on  HDR.mandt  = ITEM.mandt
                                               and HDR.db_key = ITEM.parent_key
  association [0..1] to /cpd/d_mp_team as TEAM on  HDR.mandt  = TEAM.mandt
                                               and HDR.db_key = TEAM.parent_key

  //  association[0..1] to ZFIN_I_TEAM_MEMBER_DETAILS  AS TEAM ON
  //HDR.MANDT = TEAM.MANDT AND
  //HDR.DB_KEY = TEAM.PARENT_KEY AND
  //HDR.db_key =
  //
  //
  //association[0..1] to BUT000 ON
  //MEM.MANDT = BUT000.CLIENT AND
  //MEM.BUPA_ID = BUT000.PARTNER
  //
  //association[0..1] to BUT0ID
  //LEFT JOIN "MCK_S4"."PA0709" AS "PA0709" ON
  //BUT0ID.CLIENT = PA0709.MANDT AND
{
  key HDR.db_key                    as DBKEY,
  HDR.mp_id                     as MPID,
  HDR.mp_type                   as MPTYPE,
  HDR.mp_stage                  as MPSTAGE,
  HDR.start_date                as STARTDATE,
  HDR.end_date                  as ENDDATE,
  HDR.customer                  as CUSTOMER,
  HDR.org_id                    as ORGID,
  HDR.confidential              as CONFIDENTIAL,
  HDR.proj_manager_id           as PROJMANAGERID,
  HDR.project_type              as PROJECTTYPE,
  HDR.proj_mgr_bupa_id          as PROJMGRBUPAID,
  HDR.proj_currency             as PROJCCURRENCY,
  HDR.overall_status_id         as OVERALLSTATUSID,
  HDR.cut_off_date              as CUTOFFDATE,
  HDR.created_by                as CREATEDBY,
  HDR.created_on                as CREATEDON,
  HDR.changed_by                as CHANGEDBY,
  HDR.changed_on                as CHANGEDON,
  HDR.country                   as COUNTRY,
  HDR.region                    as REGION,
  HDR.active                    as ACTIVE,
  HDR.int_inspect_date          as INTINSPECTDATE,
  HDR.ext_inspect_date          as EXTINSPECTDATE,
  HDR.work_type                 as WORKTYPE,
  HDR.industry                  as INDUSTRY,
  HDR.proj_risk                 as PROJRISK,
  HDR.fin_risk                  as FINRISK,
  HDR.tech_risk                 as TECHRISK,
  HDR.indic                     as INDIC,
  HDR.cr_relevant               as CRRELEVANT,
  HDR.overall_risk              as OVERALLRISK,
  HDR.ey                        as EY,
  HDR.cost_center               as COSTCENTER,
  HDR.profit_center             as PROFITCENTER,
  HDR./cpd/mp_dummy_incl_eew_ps as /CPD/MPDUMMYINCLEEWPS,
  HDR.zprogram                  as ZPROGRAM,
  HDR.zexparn                   as ZEXPARN,
  HDR.zffamt                    as ZFFAMT,
  HDR.zffamt_curr               as ZFFAMT_CURR,
  HDR.zrbamt                    as ZRBAMT,
  HDR.zubamt                    as ZUBAMT,
  HDR.zpaymeth                  as ZPAYMETH,
  HDR.zbillst                   as ZBILLST,
  HDR.zci                       as ZCI,
  HDR.zhb                       as ZHB,
  HDR.zffcash                   as ZFFCASH,
  HDR.zffequity                 as ZFFEQUITY,
  HDR.zrbcash                   as ZRBCASH,
  HDR.zrbequity                 as ZRBEQUITY,
  HDR.template                  as TEMPLATE,
  HDR.is_mpid_copied            as ISMPIDCOPIED,
  HDR.archiving_status          as ARCHIVINGSTATUS,
  HDR./cpd/dummy_incl_eew_ps    as /CPD/DUMMMYINCLEEWPS,
  HDR.restrict_time_posting     as RSTRICTTIMEPOSTING,
  HDR.use_project_billing       as USEPROJECTBILLING,
  HDR.data_model_version        as DATAMODELVERSION,
  HDR.pm_bupa_id                as PMBUPAID,
  HDR.pm_bupa_name              as PMBUPANAME,
  ITEM.db_key as ITEM_DB_KEY,
  ITEM.parent_key               as PARENT_KEY,
  ITEM.item_id                  as ITEM_ID,
  ITEM.mp_itm_otyp              as MP_UTEM_OTYP,
  ITEM.mp_item_okey             as MP_ITEM_OKEY,
  ITEM.changed_by               as CHANGED_BY_ITEM,
  ITEM.changed_on               as CHANGED_ON_ITEM,
  TEAM.db_key as TEAM_DB_KEY,
  TEAM.parent_key               as TEAM_PARENT_KEY,
  TEAM.team_type,
  TEAM.team_id,
  TEAM.team_name
  --ITEM.ZTIMESTAMP
}
