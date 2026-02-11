@AbapCatalog.sqlViewName: 'ZS4FIN_M_V'
@AbapCatalog.compiler.compareFilter: true
@EndUserText.label: 'ACDOCA BKPF Cube'
@ClientHandling.type: #CLIENT_DEPENDENT
@VDM.viewType: #CONSUMPTION
@Consumption.dbHints: [ 'USE_HEX_PLAN' ]
@AccessControl.authorizationCheck: #NOT_REQUIRED

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
                table: 'ACDOCA',
                role: #MAIN,
                viewElement: ['rldnr', 'bukrs', 'gjahr', 'belnr', 'docln'],
                tableElement: ['rldnr', 'rbukrs', 'gjahr', 'belnr', 'docln'],
                filter: [{tableElement: 'rldnr',operator: #EQ,value: '0L'}]

              }
              ,
               {
                table: 'BKPF',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['bukrs', 'gjahr','belnr'],
                tableElement: ['bukrs', 'gjahr','belnr']

              },
               {
                table: 'PRPS',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['PSPNR'],
                tableElement: ['PSPNR']
              },
//              {
//                table: 'REGUH',
//                role: #LEFT_OUTER_TO_ONE_JOIN,
//                viewElement: ['LAUFD','REGUH_BUKR','REGUH_LIFNR','REGUH_BELNR'],
//                tableElement: ['LAUFD','ZBUKR','LIFNR','VBLNR']
//              },
//              {
//                table: 'PAYR',
//                role: #LEFT_OUTER_TO_ONE_JOIN,
//                viewElement: ['PAYR_BUKR'],
//                tableElement: ['ZBUKR']
//              }
//              ,
              {
                table: 'PA9001',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['PA9001_PERNR','PA9001_BEGDA','PA9001_ENDDA'],
                tableElement: ['PERNR','BEGDA','ENDDA']

              },
              {
                table: 'PA0709',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['PA0709_PERNR'],
                tableElement: ['PERNR']

              }

            ]
         }
      }
    }


define view ZFIN_I_S4FINDATAMODEL
  as select from acdoca as acdoca
  //     Below Code is Commented to Improve the Join Performance as below Join is creating duplicate records.Tarun A
  //    left outer to one join acdoca as acsupp
  //                                 on (acdoca.rldnr  = '0L')
  //                                and (acsupp.rldnr  = '0L')
  //                                and acdoca.rclnt=acsupp.rclnt
  //                                and acsupp.zmckstp_org_inv_num_jei!=''----Vendor Line Item Flag..Tarun A
  //                                --and acsupp.koart='K'-----Vendor Line Item Flag..Tarun A
  //                                and acdoca.rbukrs = acsupp.rbukrs
  //                                and acdoca.gjahr  = acsupp.gjahr
  //                                and acdoca.belnr  = acsupp.belnr
  //                                --and acdoca.docln  = acsupp.docln
  //                                and acdoca.racct  = acsupp.gkont
  association [0..1] to ZFIN_I_EXPENSE_ACCOUNTS as expacc  on  $projection.RCLNT = $session.client
                                                           and $projection.RCLNT = expacc.rclnt
                                                           and $projection.BUKRS = expacc.BUKRS
                                                           and $projection.GJAHR = expacc.gjahr
                                                           and $projection.BELNR = expacc.belnr
  --and $projection.DOCLN = expacc.docln







  association [0..1] to acdoca                  as acdas   on  $projection.RCLNT = $session.client
                                                           and $projection.RCLNT = acdas.rclnt
                                                           and (
                                                              $projection.RLDNR  = '0L'
                                                            )
                                                           and (
                                                              acdas.rldnr        = '0L'
                                                            )
                                                           and $projection.RACCT = '0041000000'
                                                           and (
                                                              acdas.racct        = '0067000038'
                                                              or acdas.racct     = '0067000039'
                                                              or acdas.racct     = '0067000040'
                                                            ) ---'0067000038', '0067000039', '0067000040'

                                                           and acdoca.rbukrs     = acdas.rbukrs
                                                           and acdoca.gjahr      = acdas.gjahr
                                                           and acdoca.awref      = acdas.belnr
                                                           and acdoca.ps_psp_pnr = acdas.ps_psp_pnr
                                                           and acdoca.awitem     = acdas.docln


  association [0..1] to bkpf                               on

                                                               (
                                                                                               acdoca.rldnr = '0L'
                                                                                             ) --Tarun A: Commented for DataLoad or acdoca.rldnr  = '2L')
                                                           and bkpf.mandt                                   = $session.client
                                                           and acdoca.rclnt                                 = bkpf.mandt
                                                           and acdoca.rbukrs                                = bkpf.bukrs
                                                           and acdoca.gjahr                                 = bkpf.gjahr
                                                           and acdoca.belnr                                 = bkpf.belnr

  //  association [0..1] to reguh             on  ---Settlement data from payment program
  //
  //                                              (
  //     acdoca.rldnr                                           = '0L'
  //   )
  //                                          and reguh.mandt   = $session.client
  //                                          and acdoca.rclnt  = reguh.mandt
  //                                          and acdoca.budat  = reguh.laufd
  //                                          and acdoca.belnr  = reguh.vblnr
  //                                          and acdoca.rbukrs = reguh.zbukr
  //                                          and acdoca.lifnr  = reguh.lifnr
  //  association [0..1] to payr              on  ---Payment Medium File
  //
  //                                              (
  //     acdoca.rldnr                                           = '0L'
  //   )
  //                                          and payr.mandt    = $session.client
  //                                          and acdoca.belnr  = payr.vblnr
  //                                          and acdoca.rbukrs = payr.zbukr
  //                                          and acdoca.gjahr  = payr.gjahr

  --association [0..1] to pa9001                             on  ---HR Master Record: Infotype 0901 (Purchasing Data)

  association [0..1] to ZFIN_I_HR_MASTER        as PA9001  on  (
       acdoca.rldnr                                                         =  '0L'
     )
                                                           and PA9001.mandt = $session.client
                                                           and acdoca.pernr != '00000000'
                                                           and acdoca.pernr =  PA9001.Pernr
                                                           and acdoca.budat >= PA9001.Begda
                                                           and acdoca.budat <= PA9001.Endda

  association [0..1] to pa0709                             on  acdoca.rldnr =  '0L' --HR Master Record: Infotype 0709 (Person ID)
                                                           and pa0709.mandt = $session.client
                                                           and acdoca.rclnt =  pa0709.mandt
                                                           and acdoca.pernr != '00000000'
                                                           and acdoca.pernr =  pa0709.pernr


  association [0..1] to prps                               on

                                                               (
                                                                                               acdoca.rldnr = '0L'
                                                                                             )
                                                           and prps.mandt                                   = $session.client
                                                           and acdoca.rclnt                                 = prps.mandt
                                                           and acdoca.ps_psp_pnr                            = prps.pspnr
  -- and SUBSTR(acdoca.RCNTR, 4,5)  <> '99999'

  association [0..1] to prps                    as prsxref on  (
      acdoca.rldnr                                                                      = '0L'
    )
                                                           and prsxref.mandt            = $session.client
                                                           and acdoca.rclnt             = prsxref.mandt
                                                           and acdoca.zmcksac_xref3_jei = prsxref.posid

  /**    left outer join jcds              on

                                                   jcds.mandt = $session.client
                                               and prps.mandt = jcds.mandt
                                               and prps.objnr = jcds.objnr
                                               and jcds.stat  = 'E0012'
                                               and jcds.chgnr = '001'

  **/


{
  key acdoca.rclnt                                                                                                                                                                                as RCLNT,
  key acdoca.rldnr                                                                                                                                                                                as RLDNR,
  key acdoca.rbukrs                                                                                                                                                                               as BUKRS,
  key acdoca.gjahr                                                                                                                                                                                as GJAHR,
  key acdoca.belnr                                                                                                                                                                                as BELNR,
  key acdoca.docln                                                                                                                                                                                as DOCLN,

      prps.pspnr                                                                                                                                                                                  as PSPNR,
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
        case when prsxref.posid is not null then prsxref.posid
      end
      else
        prps.posid
      end                                                                                                                                                                                         as PROJID, --WBS Element
      /**
      case when prsxref.posid is null then prps.posid else prsxref.posid end                                                                                                as PROJID, --WBS Element
      case when prsxref.posid is null then prps.tadat else prsxref.tadat end                                                                                                as TADAT, --Technical Complete Date
      case when prsxref.posid is null then prps.prart else prsxref.prart end                                                                                                as PRART, --Project Activity Type
      --acdoca.rclnt,--We don't need Client to be explicitly called unless we have multi client scenario to avoid cross client situation.. Tarun A
      case when prsxref.posid is null then prps.fkokr else prsxref.fkokr end                                                                                                as FKOKR, --Responsible Cost Center Controlling Area
      case when prsxref.posid is null then prps.fkstl else prsxref.fkstl end                                                                                                as FKSTL, --Responsible Cost Center
      case when prsxref.posid is null then prps.pbukr else prsxref.pbukr end                                                                                                as PBUKR, --Company code for WBS element
      case when prsxref.posid is null then prps.psphi else prsxref.psphi end                                                                                                as PSPHI, --Current number of the appropriate project
      case when prsxref.posid is null then prps.pwpos else prsxref.pwpos end                                                                                                as PWPOS, --WBS Element Currency

      **/

      case substring(acdoca.rcntr, 4,5) when '99999'
      then
        case when prsxref.posid is not null then prsxref.tadat
      end
      else
        prps.tadat
      end                                                                                                                                                                                         as TADAT, --Technical Complete Date
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
        case when prsxref.posid is not null then prsxref.prart
      end
      else
        prps.prart
      end                                                                                                                                                                                         as PRART, --Project Activity Type
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
       case when prsxref.posid is not null then prsxref.fkokr
      end
      else
       prps.fkokr
      end                                                                                                                                                                                         as FKOKR, --Responsible Cost Center Controlling Area
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
       case when prsxref.posid is not null then prsxref.fkstl
      end
      else
       prps.fkstl
      end                                                                                                                                                                                         as FKSTL, --Responsible Cost Center
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
       case when prsxref.posid is not null then prsxref.pbukr
      end
      else
       prps.pbukr
      end                                                                                                                                                                                         as PBUKR, --Company code for WBS element

      case substring(acdoca.rcntr, 4,5) when '99999'
         then
           case when prsxref.posid is not null then prsxref.psphi
         end
         else
           prps.psphi
         end                                                                                                                                                                                      as PSPHI, --Current number of the appropriate project
      case substring(acdoca.rcntr, 4,5) when '99999'
      then
        case when prsxref.posid is not null then prsxref.pwpos
      end
      else
        prps.pwpos
      end                                                                                                                                                                                         as PWPOS, --WBS Element Currency

      --jcds.udate                                                                                                                                                            as UDATE,
      acdoca.ryear                                                                                                                                                                                as RYEAR,
      acdoca.sgtxt                                                                                                                                                                                as SGTXT,
      acdoca.vorgn                                                                                                                                                                                as VORGN,
      acdoca.awtyp                                                                                                                                                                                as AWTYP,
      acdoca.rtcur                                                                                                                                                                                as RTCUR,   --Balance Transaction Currency
      acdoca.rwcur                                                                                                                                                                                as RWCUR,   --Transaction Currency
      acdoca.rhcur                                                                                                                                                                                as RHCUR,   --Company Code Currency
      acdoca.rkcur                                                                                                                                                                                as RKCUR,   --Global Currency
      acdoca.racct                                                                                                                                                                                as RACCT,
      acdoca.rcntr                                                                                                                                                                                as RCNTR,
      acdoca.prctr                                                                                                                                                                                as PRCTR,
      acdoca.rbusa                                                                                                                                                                                as RBUSA,
      acdoca.scntr                                                                                                                                                                                as SCNTR,
      acdoca.lifnr                                                                                                                                                                                as LIFNR,
      ---Raw Fields (ACDOCA based Key Figures to be used as-is)--Dated 3rd June 2025........Tarun A
      @DefaultAggregation: #SUM
      acdoca.tsl                                                                                                                                                                                  as TSL,
      @DefaultAggregation: #SUM
      acdoca.ksl                                                                                                                                                                                  as KSL,
      @DefaultAggregation: #SUM
      acdoca.wsl                                                                                                                                                                                  as WSL,
      @DefaultAggregation: #SUM
      acdoca.hsl                                                                                                                                                                                  as HSL,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>acdoca.hsl,currency=>acdoca.rhcur) as abap.dec( 23, 2 ))                                                                                                         as HSL_DECSHIFT, ---Decimal Shift Logic Implemented for HSL..Tarun A

      --------------------------------------------------------------------------------------------
      ----Converted: Using Currency Conversion and Decimal Shift Logic... Tarun A: Dated 03/06/2025
      --Logic Provided by Shagun Dated:3rd June 2025 to use WSL as Value for KSL
      @DefaultAggregation: #SUM
      currency_conversion( amount => acdoca.wsl, source_currency => acdoca.rwcur, target_currency => acdoca.rkcur, exchange_rate_date => acdoca.budat, decimal_shift=>'X',decimal_shift_back=>'') as CONV_KSL, ---Currency Conversion and Decimal Shift Logic...Tarun A
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>acdoca.wsl,currency=>acdoca.rwcur) as abap.dec( 23, 2 ))                                                                                                         as CONV_WSL, ---Decimal Shift Logic Implemented..Tarun A
      @DefaultAggregation: #SUM
      --cast(decimal_shift(amount=>acdoca.hsl,currency=>acdoca.rwcur) as abap.dec( 20, 2 )) as CONV_HSL,
      --HSL Value is mapped/computed from WSL suggested by Sandeep K

      currency_conversion( amount => acdoca.wsl, source_currency => acdoca.rwcur, target_currency => acdoca.rhcur, exchange_rate_date => acdoca.budat,decimal_shift=>'X',decimal_shift_back=>'')  as CONV_HSL, ---Currency Conv & Decimal Shift Logic Implemented..Tarun A

      --DAS Based Key Figures...Tarun Arora Modified Dated 03/06/2025---------------------------------------

      @DefaultAggregation: #SUM
      --HSL Value is mapped/computed from WSL suggested by Sandeep K
      currency_conversion( amount => acdas.wsl, source_currency => acdoca.rwcur, target_currency => acdoca.rhcur, exchange_rate_date => acdoca.budat,decimal_shift=>'X', decimal_shift_back=>'' ) as MEXCH_HSL,

      @DefaultAggregation: #SUM
      --acdas.ksl as MEXCH_KSL,
      --Logic Provided by Shagun Dated:3rd June 2025 to use WSL as Value for KSL
      currency_conversion( amount => acdas.wsl, source_currency => acdoca.rwcur, target_currency => acdoca.rkcur, exchange_rate_date => acdoca.budat,decimal_shift=>'X', decimal_shift_back=>'' ) as MEXCH_KSL,

      ---Decimal Shift Logic Implemented..Tarun A
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>acdas.wsl,currency=>acdoca.rwcur) as abap.dec( 23, 2 ))                                                                                                          as MEXCH_WSL,

      --DAS Based Key Figures Blocks ends here...Tarun Arora Modified Dated 03/06/2025-----------------------------

      acdas.racct                                                                                                                                                                                 as DASACCT,
      case when acdas.sgtxt like '%DAS_OT%' then 'Asset-OneTime'
      else 'Asset-Subscript' end                                                                                                                                                                  as DAS_FEES_TYPE, ---DAS Logic for Calculating Fees type added. Tarun A: Dated 22/04/2025
      acdas.sgtxt                                                                                                                                                                                 as DASTEXT, --SGTXT added from DAS Conditions for referring the values changes that impact DAS Fees Type . Tarun A
      acdoca.fiscyearper                                                                                                                                                                          as FISCYEARPER,
      acdoca.budat                                                                                                                                                                                as BUDAT,   --Posting Date
      left(replace(acdoca.budat,'-',''),6)                                                                                                                                                        as BUDAT_YEARMON, ---Posting Date (YearMonth)..Tarun A: 03/07/2025 (Sandeep K Requested)
      acdoca.bldat                                                                                                                                                                                as BLDAT, --Document Date
      left(replace(acdoca.bldat,'-',''),6)                                                                                                                                                        as BLDAT_YEARMON, ---Document Date (YearMonth)..Tarun A: 03/07/2025 (Sandeep K Requested)
      acdoca.blart                                                                                                                                                                                as BLART,   --Document Type
      acdoca.buzei                                                                                                                                                                                as BUZEI,   --New Line Item in Document
      acdoca.zuonr                                                                                                                                                                                as ZUONR,
      acdoca.timestamp                                                                                                                                                                            as TIMESTAMP,
      acdoca.glaccount_type                                                                                                                                                                       as GL_ACCOUNT_TYPE,
      --acdoca.sgtxt,
      acdoca.kdauf                                                                                                                                                                                as KDAUF,
      acdoca.kdpos                                                                                                                                                                                as KDPOS,
      acdoca.matnr                                                                                                                                                                                as MATNR,
      acdoca.werks                                                                                                                                                                                as WERKS,
      --acsupp.lifnr,---Tarun A: Supplier Number Update
      acdoca.kunnr                                                                                                                                                                                as KUNNR,
      acdoca.augdt                                                                                                                                                                                as AUGDT,
      acdoca.augbl                                                                                                                                                                                as AUGBL,
      acdoca.mat_lifnr                                                                                                                                                                            as MAT_LIFNR,
      acdoca.objnr                                                                                                                                                                                as OBJNR,
      acdoca.gkont                                                                                                                                                                                as GKONT,
      acdoca.gkoar                                                                                                                                                                                as GKOAR,
      acdoca.pernr                                                                                                                                                                                as PERNR,
      acdoca.aufnr                                                                                                                                                                                as AUFNR,
      acdoca.autyp                                                                                                                                                                                as AUTYP,
      acdoca.ps_psp_pnr                                                                                                                                                                           as PS_PSP_PNR,
      acdoca.ps_posid                                                                                                                                                                             as PS_POSID,
      acdoca.ps_prj_pnr                                                                                                                                                                           as PS_PRJ_PNR,
      acdoca.ps_pspid                                                                                                                                                                             as PS_PSPID,
      acdoca.drcrk                                                                                                                                                                                as DRCRK,
      acdoca.poper                                                                                                                                                                                as POPER,
      acdoca.periv                                                                                                                                                                                as PERIV,
      acdoca.awref                                                                                                                                                                                as AWREF,
      acdoca.awitem                                                                                                                                                                               as AWITEM,
      acdoca.bttype                                                                                                                                                                               as BTTYPE,

      acdoca.cbttype                                                                                                                                                                              as CBTTYPE,
      concat(acdoca.gjahr,bkpf.monat)                                                                                                                                                             as FISCYEARPERIOD, ---YYYYMM Format based Fiscal Year Period
      acdoca.zmckstp_org_inv_num_jei                                                                                                                                                              as ZMCKSTP_ORG_INV_NUM_JEI,
      acdoca.zmckstp_unq_idt_num_jei                                                                                                                                                              as ZMCKSTP_UNQ_IDT_NUM_JEI,
      acdoca.zmckje_item_pay_ref_jei                                                                                                                                                              as ZMCKJE_ITEM_PAY_REF_JEI,
      acdoca.zmckstp_pymnt_ref_num_jei                                                                                                                                                            as ZMCKSTP_PYMNT_REF_NUM_JEI,
      acdoca.zmckcb_ext_field_cob                                                                                                                                                                 as ZMCKCB_EXT_FIELD_COB,
      -----------------------------------------------------------------------------------------------
      -- bkpf.budat, --WE have BUDAT from ACDOCA also--Updated Flag Value for CDS Lite Report Requirements...Tarun A
      case when bkpf.bktxt='Payroll-CDLite' then 'CD' else bkpf.bktxt end                                                                                                                         as PAYROLL_CD_FLAG,
      bkpf.bktxt                                                                                                                                                                                  as BKTXT,
      bkpf.monat                                                                                                                                                                                  as MONAT,
      bkpf.xblnr                                                                                                                                                                                  as XBLNR,
      bkpf.usnam                                                                                                                                                                                  as USNAM,
      bkpf.brnch                                                                                                                                                                                  as BRNCH,
      bkpf.numpg                                                                                                                                                                                  as NUMPG,
      bkpf.aedat                                                                                                                                                                                  as AEDAT,
      bkpf.cpudt                                                                                                                                                                                  as CPUDT,
      bkpf.upddt                                                                                                                                                                                  as UPDDT,
      bkpf.stblg                                                                                                                                                                                  as STBLG,
      bkpf.awkey                                                                                                                                                                                  as AWKEY,
      bkpf.stodt                                                                                                                                                                                  as STODT,
      bkpf.xmwst                                                                                                                                                                                  as XMWST,
      bkpf.kuty2                                                                                                                                                                                  as KUTY2,
      bkpf.kuty3                                                                                                                                                                                  as KUTY3,
      bkpf.xsnet                                                                                                                                                                                  as XSNET,
      bkpf.duefl                                                                                                                                                                                  as DUEFL,
      bkpf.stgrd                                                                                                                                                                                  as STGRD,
      bkpf.xref1_hd                                                                                                                                                                               as XREF1_HD,
      bkpf.xref2_hd                                                                                                                                                                               as XREF2_HD,
      bkpf.xreversal                                                                                                                                                                              as XREVERSAL,
      bkpf.ldgrp                                                                                                                                                                                  as LDGRP,
      bkpf.xreorg                                                                                                                                                                                 as XREORG,

      acdoca.zmcksac_xref1_jei                                                                                                                                                                    as XREF1,
      acdoca.zmcksac_xref2_jei                                                                                                                                                                    as XREF2,
      acdoca.zmcksac_xref3_jei                                                                                                                                                                    as XREF3,
      acdoca.koart                                                                                                                                                                                as KOART,
      acdoca.ktopl                                                                                                                                                                                as KTOPL,
      acdoca.bstat                                                                                                                                                                                as BSTAT,
      acdoca.xreversed                                                                                                                                                                            as XREVERSED,
      acdoca.rmvct                                                                                                                                                                                as RMVCT,
      acdoca.rfarea                                                                                                                                                                               as RFAREA, -- statutory
      acdoca.mwskz                                                                                                                                                                                as MWSKZ,
      acdoca.land1                                                                                                                                                                                as LAND1,
      acdoca.bschl                                                                                                                                                                                as BSCHL,
      acdoca.fcsl                                                                                                                                                                                 as FCSL,
      acdoca.co_osl                                                                                                                                                                               as CO_OSL,
      acdoca.xopvw                                                                                                                                                                                as XOPW,
      acdoca.fkart                                                                                                                                                                                as FKART,
      acdoca.hbkid                                                                                                                                                                                as HBKID,
      acdoca.segment                                                                                                                                                                              as SEGMENT,
      acdoca.ktop2                                                                                                                                                                                as KTOP2,
      acdoca.lokkt                                                                                                                                                                                as LOKKT,
      acdoca.osl                                                                                                                                                                                  as OSL,
      acdoca.rocur                                                                                                                                                                                as ROCUR,
      acdoca.rfccur                                                                                                                                                                               as RFCCUR,
      acdoca.rco_ocur                                                                                                                                                                             as RCO_OCUR,
      acdoca.kokrs                                                                                                                                                                                as KOKRS,
      acdoca.rebzg                                                                                                                                                                                as REBZG,
      acdoca.rebzj                                                                                                                                                                                as REBZJ,
      acdoca.rebzz                                                                                                                                                                                as REBZZ,
      acdoca.rebzt                                                                                                                                                                                as REBZT,
      acdoca.netdt                                                                                                                                                                                as NETDT,
      acdas.racct                                                                                                                                                                                 as DAS_EAVGI_COST_RACCT,
      acdas.rwcur                                                                                                                                                                                 as DAS_EAVGI_COST_RWCUR,
      @DefaultAggregation: #SUM
      acdas.hsl                                                                                                                                                                                   as DAS_EAVGI_COST_HSL,
      acdoca.ulstar                                                                                                                                                                               as ULSTAR,
      acdas.rkcur                                                                                                                                                                                 as DAS_EAVGI_COST_RHCUR,
      acdas.rkcur                                                                                                                                                                                 as DAS_EAVGI_COST_RKCUR,
      @DefaultAggregation: #SUM
      acdas.ksl                                                                                                                                                                                   as DAS_EAVGI_COST_KSL,
      @DefaultAggregation: #SUM
      acdas.wsl                                                                                                                                                                                   as DAS_EAVGI_COST_WSL,
      @DefaultAggregation: #SUM
      acdoca.msl                                                                                                                                                                                  as MSL, ---Requested by Srikanth for H&F and SLC..Tarun  A

      ---List of Fields added for OPS Team, main tables are REGUH,PAYR..Tarun A: Dated: 07/07/2025
      /**
            reguh.laufd                                                                                                                                                           as LAUFD,
            reguh.laufi                                                                                                                                                           as LAUFI,
            reguh.xvorl                                                                                                                                                           as XVORL,
            reguh.zbukr                                                                                                                                                           as REGUH_BUKR,
            reguh.lifnr                                                                                                                                                           as REGUH_LIFNR,
            reguh.kunnr                                                                                                                                                           as REGUH_KUNNR,
            reguh.empfg                                                                                                                                                           as EMPFG,
            reguh.vblnr                                                                                                                                                           as REGUH_BELNR,
            reguh.rzawe                                                                                                                                                           as RZAWE,
            payr.zbukr                                                                                                                                                            as PAYR_BUKR,
            payr.vblnr                                                                                                                                                            as PAYR_BELNR,
            payr.gjahr                                                                                                                                                            as PAYR_GJAHR,
            payr.voidd                                                                                                                                                            as VOIDD,
            payr.chect                                                                                                                                                            as CHECT,
            payr.priti                                                                                                                                                            as PRITI,
            payr.xmanu                                                                                                                                                            as XMANU,
            payr.xbanc                                                                                                                                                            as XBANC,
            payr.bancd                                                                                                                                                            as BANCD,
            payr.xbukr                                                                                                                                                            as XBUKR,
            payr.voidr                                                                                                                                                            as VOIDR,
            **/
      --User Master Record to capture User Role with in specific periods..Tarun A
      PA9001.Pernr                                                                                                                                                                                as PA9001_PERNR,
      PA9001.Begda                                                                                                                                                                                as PA9001_BEGDA,
      PA9001.Endda                                                                                                                                                                                as PA9001_ENDDA,
      PA9001.role_category as RAW_ROLE_CATEGORY,----Tarun A: Kept this Raw DB Field as Output for future Business Logic Enhancements.
      case PA9001.role_category 
      when '1380705' then 'CSP' 
      when '138706' then 'ESP' 
      when '138707' then 'FSP' 
      else PA9001.role_category end                                                         as ROLE_CATEGORY,---As per Logic given by Prasoon JIRA Ticket:FPDA-2731
      //      Role category when :
      //1380705 -> CSP
      //1380706 -> ESP
      //1380707 -> FSP
      PA9001.WORK_PERCENT                                                                                                                                                                         as WORK_PERCENT,
      PA9001.CLIENT_SERVING                                                                                                                                                                       as CLIENT_SERVING,
      PA9001.band                                                                                                                                                                                 as BAND,
      PA9001.FCAT                                                                                                                                                                                 as FCAT,
      PA9001.SUB_BAND                                                                                                                                                                             as SUB_BAND,
      PA9001.PATH                                                                                                                                                                                 as PATH,
      PA9001.SKILL_CODE                                                                                                                                                                           as SKILL_CODE,
      PA9001.skill_code_text                                                                                                                                                                      as SKILL_CODE_TEXT,
      pa0709.pernr                                                                                                                                                                                as PA0709_PERNR,
      pa0709.personid_ext                                                                                                                                                                         as FMNO,
      tstmp_current_utctimestamp()                                                                                                                                                                as ZTIMESTAMP,
      -----------------------------------EXPENSE KPI'S----CALCULATED COLUMNS Requested by Nivedhitha for Expense Report Optimization--------------------------------------------------------Tarun A: 06/08/2025-------
      case substring(acdoca.rcntr,4,5) when '99999' then 'Y' else 'N' end                                                                                                                         as EXPENSE_COST_CENTER,
      length(acdoca.zuonr)                                                                                                                                                                        as EXPENSE_ZUONR_LENGTH,
      case when (acdoca.zuonr like '2%') then 'Y' else 'N' end                                                                                                                                    as EXPENSE_PERNR_2,
      case when (acdoca.blart='ZI' or acdoca.blart='ZC' or acdoca.blart='KR' or acdoca.blart='KZ') then 'RC'
      else 'OE'
      end                                                                                                                                                                                         as EXPENSE_SRC,
      case substring(acdoca.rcntr, 4,5)  when '99999' then
      case when ((acdoca.zmcksac_xref3_jei != '' or acdoca.zmcksac_xref3_jei is not null)
      and acdoca.ps_psp_pnr = '00000000')
      then 'INT' end
      else 'NON-INT' end                                                                                                                                                                          as EXPENSE_FLAG,
      case substring(acdoca.rcntr, 4,5)  when '99999' then
      case when ((acdoca.zmcksac_xref3_jei != '' or acdoca.zmcksac_xref3_jei is not null)
      and acdoca.ps_psp_pnr = '00000000')
      then acdoca.zmcksac_xref3_jei end
      else acdoca.ps_posid end                                                                                                                                                                    as EXPENSE_PS_POSID,
      expacc.LIFNR                                                                                                                                                                                as EXPENSE_LIFNR_CODE,
      case when (expacc.LIFNR like '003%') then 'COUPA_VENDOR'
      when (expacc.LIFNR like '001%') then 'RYDOO_VENDOR' else '-' end                                                                                                                            as EXPENSE_LIFNR,
      case acdoca.ps_psp_pnr when '00000000' then 'Y' else 'N' end                                                                                                                                as PS_PSP_PNR_FLAG,
      case rtrim(ltrim(acdoca.zmcksac_xref1_jei,''),'') when '' then 'Y' else 'N' end                                                                                                             as XREF1_FLAG,
      case rtrim(ltrim(acdoca.zmcksac_xref3_jei,''),'') when '' then 'Y' else 'N' end                                                                                                             as XREF3_FLAG,
      expacc.XREF3                                                                                                                                                                                as EXPENSE_ACC_XREF3,
      expacc.EXPRECFlag ---Flag to Identify Expense Records..Tarun A Dated 29th Oct 2025





}
where
  (
        acdoca.rldnr = '0L'
    and acdoca.rclnt = $session.client
  ) -- or acdoca.rldnr = '2L')--2L removed to take care of performance..Tarun A:24/04/2025
