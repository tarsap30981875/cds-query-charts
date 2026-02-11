@AbapCatalog.sqlViewName: 'ZOPS_INV_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientHandling.type: #CLIENT_DEPENDENT
@VDM.viewType: #TRANSACTIONAL
@Consumption.dbHints: [ 'USE_HEX_PLAN' ]
@EndUserText.label: 'GLLineItem / Vendor Line Items View'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel: {
                usageType.sizeCategory: #XXL,
                usageType.dataClass:  #TRANSACTIONAL,
                usageType.serviceQuality: #B,
                supportedCapabilities: [#ANALYTICAL_DIMENSION, #CDS_MODELING_ASSOCIATION_TARGET, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE, #EXTRACTION_DATA_SOURCE],
                modelingPattern: #ANALYTICAL_CUBE
                }


@Analytics: {
      dataCategory: #FACT,
      dataExtraction: {
        enabled:true,
        delta.changeDataCapture: {
          mapping:
            [
              {
                table:'BSEG',
                role: #MAIN,
                viewElement: ['bukrs','belnr','gjahr','buzei'],
                tableElement: ['bukrs','belnr','gjahr','buzei']

              },

               {
                table: 'BKPF',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['bukrs', 'gjahr','belnr'],
                tableElement: ['bukrs', 'gjahr','belnr']

              },

                             {
                table: 'T001',
                role: #LEFT_OUTER_TO_ONE_JOIN,
                viewElement: ['bukrs'],
                tableElement: ['bukrs']

              }


            ]
         }
      }
    }

define view ZOPS_I_INVOICE
  as select from ZOPS_I_VENDORLINEITEM as VendorLineItem
  //    left outer to one join ZOPS_I_INVOICE_VENDOR_L_POST as GLLineItem on  VendorLineItem.mandt   = GLLineItem.mandt
  //                                                                      and VendorLineItem.BUKRS   = GLLineItem.bukrs
  //                                                                      and VendorLineItem.GJAHR   = GLLineItem.gjahr
  //                                                                      and VendorLineItem.BELNR   = GLLineItem.belnr
  //                                                                      and (
  //                                                                         VendorLineItem.KOART    = 'K'
  //                                                                         or VendorLineItem.KOART = 'S'
  //                                                                         or VendorLineItem.KOART = 'D'
  //                                                                       )
  //    left outer to one join skat                                       on
  //
  //                                                                          VendorLineItem.mandt = skat.mandt
  //                                                                      and VendorLineItem.HKONT = skat.saknr
  -- and VendorLineItem. = skat.ktopl

  //  left outer to one join tvoit on VendorLineItem.mandt=tvoit.MANDT
  //  and tvoit.langu='E'
  //  AND VendorLineItem.=tvoit.voidr

  //                                                               and (
  //                                                                  VendorLineItem.H_BLART    = 'KA'
  //                                                                  or VendorLineItem.H_BLART = 'KG'
  //                                                                  or VendorLineItem.H_BLART = 'KR'
  //                                                                  or VendorLineItem.H_BLART = 'KZ'
  //                                                                  or VendorLineItem.H_BLART = 'ZC'
  //                                                                  or VendorLineItem.H_BLART = 'ZH'
  //                                                                  or VendorLineItem.H_BLART = 'ZI'
  //                                                                  or VendorLineItem.H_BLART = 'ZP'
  //                                                                  or VendorLineItem.H_BLART = 'ZV'
  //                                                                )
  //                                                               and (
  //                                                                  GLLineItem.koart          = 'K'
  //                                                                  or GLLineItem.koart       = 'S'
  //                                                                  or GLLineItem.koart       = 'D'
  //                                                                )
  //                                                               and (
  //                                                                  GLLineItem.h_blart        = 'KA'
  //                                                                  or GLLineItem.h_blart     = 'KG'
  //                                                                  or GLLineItem.h_blart     = 'KR'
  //                                                                  or GLLineItem.h_blart     = 'KZ'
  //                                                                  or GLLineItem.h_blart     = 'ZC'
  //                                                                  or GLLineItem.h_blart     = 'ZH'
  //                                                                  or GLLineItem.h_blart     = 'ZI'
  //                                                                  or GLLineItem.h_blart     = 'ZP'
  //                                                                  or GLLineItem.h_blart     = 'ZV'
  //                                                                )
  //

  association [0..1] to bkpf  on

                                  $projection.MANDT = $session.client
                              and $projection.MANDT = BKPF.mandt
                              and $projection.GJAHR = BKPF.gjahr
                              and $projection.BUKRS = BKPF.bukrs
                              and $projection.BELNR = BKPF.belnr
                              and $projection.BLART = BKPF.blart
  association [0..1] to t001  on

                                  $projection.MANDT = T001.mandt
                              and $projection.BUKRS = T001.bukrs
  association [0..1] to reguh on

                                  $projection.MANDT = REGUH.mandt
                              and $projection.BUKRS = REGUH.zbukr
                              and $projection.BUDAT = REGUH.laufd
                              and $projection.BELNR = REGUH.vblnr
  association [0..1] to payr  on

                                  $projection.MANDT = PAYR.mandt
                              and $projection.BUKRS = PAYR.zbukr
                              and $projection.GJAHR = PAYR.gjahr
                              and $projection.BELNR = PAYR.vblnr

  association [0..1] to prps  on

                                  $projection.MANDT = PRPS.mandt
                              and $projection.PROJK = PRPS.pspnr

  //  association [0..1] to cskt  on  $projection.mandt = CSKT.mandt
  //                              and cskt.spras        = 'E'
  //                              and $projection.KOSTL = CSKT.kostl
  //                              and $projection.KOKRS = CSKT.kokrs

  association [0..1] to tvzbt on  $projection.MANDT = TVZBT.mandt
                              and $projection.ZTERM = TVZBT.zterm
                              and TVZBT.spras       = 'E'

  association [0..1] to aufk  on  $projection.MANDT = aufk.mandt
                              and $projection.AUFNR = aufk.aufnr

  association [0..1] to t003t on  $projection.MANDT = t003t.mandt
                              and t003t.spras       = 'E'
                              and $projection.BLART = t003t.blart

  //  association [0..1] TO tvoit on $projection.mandt=tvoit.MANDT
  //  and tvoit.langu='E'
  //  AND $projection.VOIDR=tvoit.voidr

  association [0..1] to cepct on  $projection.MANDT = CEPCT.mandt
                              and CEPCT.spras       = 'E'
                              and $projection.PRCTR = CEPCT.prctr
                              and $projection.KOKRS = CEPCT.kokrs

  association [0..1] to t052  on  $projection.MANDT = T052.mandt
                              and $projection.ZTERM = T052.zterm


{
  key VendorLineItem.mandt                                                                               as MANDT,
  key VendorLineItem.BUKRS                                                                               as BUKRS,
  key VendorLineItem.BELNR                                                                               as BELNR,
  key VendorLineItem.GJAHR                                                                               as GJAHR,
  key VendorLineItem.BUZEI                                                                               as BUZEI,
      VendorLineItem.BARCODE,
      VendorLineItem.FMNO_GLP,
      VendorLineItem.XREF3_VENDOR,
      VendorLineItem.XREF3_GL,
      VendorLineItem.XREF1_VENDOR,
      VendorLineItem.XREF1_GL,
      VendorLineItem.PROJK_VENDOR,
      VendorLineItem.PROJK_GL,
      VendorLineItem.BUZID                                                                               as BUZID,
      VendorLineItem.AUGDT                                                                               as AUGDT,
      VendorLineItem.AUGCP                                                                               as AUGCP,
      VendorLineItem.AUGBL                                                                               as AUGBL,
      VendorLineItem.BSCHL                                                                               as BSCHL,
      VendorLineItem.UMSKZ                                                                               as UMSKZ,
      VendorLineItem.UMSKS                                                                               as UMSKS,
      VendorLineItem.ZUMSK,
      --      VendorLineItem.shkzg                                as SHKZG,
      VendorLineItem.GSBER                                                                               as GSBER,
      VendorLineItem.PARGB                                                                               as PARGB,
      VendorLineItem.KTOSL                                                                               as KTOSL,
      VendorLineItem.QSSHB                                                                               as QSSHB,
      VendorLineItem.GBETR                                                                               as GBETR,
      VendorLineItem.VALUT                                                                               as VALUT,
      VendorLineItem.ALTKT                                                                               as ALTKT,
      VendorLineItem.FDLEV                                                                               as FDLEV,
      VendorLineItem.FDGRP                                                                               as FDGRP,
      VendorLineItem.FDTAG                                                                               as FDTAG,
      VendorLineItem.FKONT                                                                               as FKONT,
      VendorLineItem.KOKRS                                                                               as KOKRS,
      VendorLineItem.PROJN                                                                               as PROJN,
      VendorLineItem.VBEL2                                                                               as VBEL2,
      VendorLineItem.POSN2                                                                               as POSN2,
      VendorLineItem.ETEN2                                                                               as ETEN2,
      VendorLineItem.ANLN1                                                                               as ANLN1,
      VendorLineItem.ANLN2                                                                               as ANLN2,
      VendorLineItem.ANBWA                                                                               as ANBWA,
      VendorLineItem.BZDAT                                                                               as BZDAT,
      VendorLineItem.PERNR                                                                               as PERNR,
      VendorLineItem.SAKNR                                                                               as SAKNR,
      VendorLineItem.VENDOR_GL_ACCOUNT,
      VendorLineItem.KUNNR                                                                               as KUNNR,
      VendorLineItem.LIFNR                                                                               as LIFNR,
      VendorLineItem.FILKD                                                                               as FILKD,
      VendorLineItem.XBILK                                                                               as XBILK,
      VendorLineItem.GVTYP                                                                               as GVTYP,
      VendorLineItem.HZUON                                                                               as HZUON,
      VendorLineItem.ZFBDT                                                                               as ZFBDT,
      VendorLineItem.ZTERM                                                                               as ZTERM,
      VendorLineItem.SKFBT                                                                               as SKFBT,
      VendorLineItem.ZLSCH                                                                               as ZLSCH,
      VendorLineItem.ZLSPR                                                                               as ZLSPR,
      VendorLineItem.BVTYP                                                                               as BVTYP,
      VendorLineItem.SAMNR                                                                               as SAMNR,
      VendorLineItem.ABPER                                                                               as ABPER,
      VendorLineItem.WVERW                                                                               as WVERW,
      VendorLineItem.KLIBT                                                                               as KLIBT,
      VendorLineItem.QSZNR                                                                               as QSZNR,
      VendorLineItem.QSFBT                                                                               as QSFBT,
      VendorLineItem.MATNR                                                                               as MATNR,
      VendorLineItem.WERKS                                                                               as WERKS,
      VendorLineItem.MENGE                                                                               as MENGE,
      VendorLineItem.MEINS                                                                               as MEINS,
      VendorLineItem.ERFMG                                                                               as ERFMG,
      VendorLineItem.ERFME                                                                               as ERFME,
      VendorLineItem.BPMNG                                                                               as BPMNG,
      VendorLineItem.BPRME                                                                               as BPRME,
      VendorLineItem.EBELN_LOGSYS,
      VendorLineItem.EBELN                                                                               as EBELN,
      VendorLineItem.EBELP                                                                               as EBELP,
      VendorLineItem.ZEKKN                                                                               as ZEKKN,
      VendorLineItem.ELIKZ                                                                               as ELIKZ,
      VendorLineItem.VPRSV                                                                               as VPRSV,
      VendorLineItem.PEINH                                                                               as PEINH,
      VendorLineItem.BWKEY                                                                               as BWKEY,
      VendorLineItem.BWTAR                                                                               as BWTAR,
      VendorLineItem.PRCTR                                                                               as PRCTR,
      VendorLineItem.VPTNR                                                                               as VPTNR,
      VendorLineItem.TXJCD                                                                               as TXJCD,
      VendorLineItem.KSTRG                                                                               as KSTRG,
      VendorLineItem.DMBE3                                                                               as DMBE3,
      VendorLineItem.XRAGL                                                                               as XRAGL,
      VendorLineItem.XREF1                                                                               as XREF1,
      VendorLineItem.XREF2                                                                               as XREF2,
      VendorLineItem.EMPFB                                                                               as EMPFB,
      VendorLineItem.XREF3                                                                               as XREF3,
      VendorLineItem.KIDNO                                                                               as KIDNO,
      VendorLineItem.BUPLA                                                                               as BUPLA,
      VendorLineItem.SECCO                                                                               as SECCO,
      VendorLineItem.LSTAR                                                                               as LSTAR,
      VendorLineItem.DOCLN                                                                               as DOCLN,
      VendorLineItem.SEGMENT                                                                             as SEGMENT,
      VendorLineItem.XLGCLR                                                                              as XLGCLR,
      VendorLineItem.XFRGE_BSEG                                                                          as XFRGE_BSEG,
      VendorLineItem.BUZEI_SENDER                                                                        as BUZEI_SENDER,
      VendorLineItem.H_MONAT                                                                             as MONAT,
      VendorLineItem.H_BSTAT                                                                             as BSTAT,
      VendorLineItem.H_BUDAT                                                                             as BUDAT,
      VendorLineItem.H_BLDAT                                                                             as BLDAT,
      VendorLineItem.H_BLART                                                                             as BLART,
      VendorLineItem.SK1DT                                                                               as SK1DT,
      VendorLineItem.SK2DT                                                                               as SK2DT,
      VendorLineItem.DATAAGING,
      VendorLineItem.GHKON                                                                               as GHKON,
      VendorLineItem.SQUAN                                                                               as SQUAN,
      VendorLineItem.ACDOC_EEW_DUMMMY,
      VendorLineItem.ZMCKJE_ITEM_PAY_REF_JEI                                                             as ZMCKJE_ITEM_PAY_REF_JEI,
      VendorLineItem.NETDT                                                                               as NETDT,
      VendorLineItem.RE_BUKRS                                                                            as RE_BUKRS,
      VendorLineItem.RE_ACCOUNT                                                                          as RE_ACCOUNT,
      VendorLineItem.ZMCKSTP_UNQ_IDT_NUM_JEI                                                             as ZMCKSTP_UNQ_IDT_NUM_JEI,
      VendorLineItem.ZMCKSTP_ORG_INV_NUM_JEI                                                             as ZMCKSTP_ORG_INV_NUM_JEI,
      VendorLineItem.ZMCKSTP_PYMNT_REF_NUM_JEI                                                           as ZMCKSTP_PYMNT_REF_NUM_JEI,
      VendorLineItem.ZTIMESTAMP,
      VendorLineItem.FDWBT,
      VendorLineItem.WMWST,
      VendorLineItem.MWART,
      VendorLineItem.FWBAS,
      VendorLineItem.TXBFW,
      VendorLineItem.RWCUR,
      VendorLineItem.RHCUR,
      VendorLineItem.HKONT,
      VendorLineItem.KOART,
      VendorLineItem.CC_INV_PERIOD,
      VendorLineItem.CC_SUPPLIER,
      'USD'                                                                                              as CC_RKCUR,
      VendorLineItem.AGING_BUCKET                                                                        as CC_AGING,
      case when VendorLineItem.AGING_BUCKET<0 then 'Pre-Closed'
      when VendorLineItem.AGING_BUCKET>=0 and VendorLineItem.AGING_BUCKET<=5 then '0-5 Days'
      when VendorLineItem.AGING_BUCKET>=6 and VendorLineItem.AGING_BUCKET<=10 then '6-10 Days'
      when VendorLineItem.AGING_BUCKET>=11 and VendorLineItem.AGING_BUCKET<=30 then '11-30 Days'
      when VendorLineItem.AGING_BUCKET>=31 and VendorLineItem.AGING_BUCKET<=60 then '31-60 Days'
      when VendorLineItem.AGING_BUCKET>=61 and VendorLineItem.AGING_BUCKET<=90 then '61-90 Days'
      else 'Greater than 90 Days' end                                                                    as CC_AGING_BUCKET,
      VendorLineItem.CC_ACCOUNT_TYPE,
      concat(VendorLineItem.GJAHR,VendorLineItem.H_MONAT)                                                as CC_PERIOD,


      --VendorLineItem.ZUONR                                as FMNO_GLP,
      VendorLineItem.XREF3                                                                               as XREF3_GLLINEITEM,
      VendorLineItem.BUZEI                                                                               as GL_BUZEI,
      VendorLineItem.HSN_SAC                                                                             as HSN_SAC,
      VendorLineItem.PROJK                                                                               as PROJK,
      VendorLineItem.AUFNR                                                                               as AUFNR,
      VendorLineItem.KOSTL                                                                               as KOSTL,
      VendorLineItem.SGTXT                                                                               as SGTXT,
      VendorLineItem.QSSKZ                                                                               as QSSKZ,
      VendorLineItem.MWSKZ                                                                               as MWSKZ,
      VendorLineItem.SHKZG                                                                               as SHKZG,
      ------RAW Amount Fields- from BSEG for Future Usage--Tarun A: Dated 29/01/2026---------------------------------
      VendorLineItem.DMBTR                                                                               as DMBTR,
      VendorLineItem.DMBE2                                                                               as DMBE2,
      VendorLineItem.WRBTR                                                                               as WRBTR,
      ----------------------------------------------------------------------------------------------------------------
      ------Decimal Shift Amount Fields- from BSEG for Future Usage--Tarun A: Dated 29/01/2026
      VendorLineItem.DMBTR_DECSHFT,
      VendorLineItem.DMBE2_DECSHFT,
      VendorLineItem.WRBTR_DECSHFT,
      ----------------------------------------------------------------------------------------------------------------
      (case left(VendorLineItem.HKONT,3)
            when  '001' then  '1 Series GL'
            when  '002' then  '2 Series GL'
            when  '003' then  '3 Series GL'
            when  '004' then  '4 Series GL'
            when  '005' then  '5 Series GL'
            when  '006' then  '6 Series GL'
            when  '007' then  '7 Series GL'
            when  '008' then  '8 Series GL'
            when  '009' then  '9 Series GL'
            else ''
            end
        )                                                                                                as CC_GL_ACC,
      cast (VendorLineItem.BUZEI as abap.int2)                                                           as CC_LINE_NUM,
      (case VendorLineItem.SHKZG
          when 'H' then (VendorLineItem.DMBTR_DECSHFT *-1)
          when 'S' then VendorLineItem.DMBTR_DECSHFT else 0
          end
      )                                                                                                  as CC_INVOICE_AMT_IN_CC_CURR,
      (case VendorLineItem.SHKZG
          when 'H' then (VendorLineItem.DMBE2_DECSHFT *-1)
          when 'S' then VendorLineItem.DMBE2_DECSHFT
          else 0
          end
      )                                                                                                  as CC_INV_AMT_IN_GLOBAL_CURR,
      (case VendorLineItem.SHKZG
          when 'H' then (VendorLineItem.WRBTR_DECSHFT *-1)
          when 'S' then VendorLineItem.WRBTR_DECSHFT
          else 0
          end
      )                                                                                                  as CC_INV_AMT_IN_TRANS_CURR,
      ( case
      when (VendorLineItem.HSN_SAC <> '') then VendorLineItem.HSN_SAC
      when VendorLineItem.BUKRS = 'BR10' then VendorLineItem.XREF1
      else  VendorLineItem.XREF3
      end)                                                                                               as CC_HSN_SAC,
      VendorLineItem.ZUONR                                                                               as ZUONR,
      --New Field Added as requested by Chhavi.. Dated 27th Jan 2026 by Tarun A
      VendorLineItem.H_HWAE2,
      VendorLineItem.H_HWAER,
      VendorLineItem.H_WAERS,
      --------------------------------------------------------------------------------------------------
      bkpf.monat                                                                                         as BKPF_MONAT,
      bkpf.cpudt                                                                                         as CPUDT,
      bkpf.cputm                                                                                         as CPUTM,
      bkpf.aedat                                                                                         as AEDAT,
      bkpf.upddt                                                                                         as UPDDT,
      bkpf.wwert                                                                                         as WWERT,
      bkpf.usnam                                                                                         as USNAM,
      bkpf.tcode                                                                                         as TCODE,
      bkpf.bvorg                                                                                         as BVORG,
      --bkpf.xblnr                                          as XBLNR,
      bkpf.stblg                                                                                         as STBLG,
      bkpf.bktxt                                                                                         as BKTXT,
      bkpf.waers                                                                                         as WAERS,
      bkpf.bstat                                                                                         as BKPF_BSTAT,
      bkpf.awtyp                                                                                         as AWTYP,
      bkpf.awkey                                                                                         as AWKEY,
      bkpf.hwaer                                                                                         as HWAER,
      bkpf.xstov                                                                                         as XSTOV,
      bkpf.stodt                                                                                         as STODT,
      bkpf.xmwst                                                                                         as XMWST,
      bkpf.kuty2                                                                                         as KUTY2,
      bkpf.kuty3                                                                                         as KUTY3,
      bkpf.xsnet                                                                                         as XSNET,
      bkpf.duefl                                                                                         as DUEFL,
      bkpf.stgrd                                                                                         as STGRD,
      bkpf.brnch                                                                                         as BRNCH,
      bkpf.numpg                                                                                         as NUMPG,
      bkpf.xref1_hd                                                                                      as XREF1_HD,
      bkpf.xref2_hd                                                                                      as XREF2_HD,
      bkpf.xreversal                                                                                     as XREVERSAL,
      bkpf.rldnr                                                                                         as RLDNR,
      bkpf.ldgrp                                                                                         as LDGRP,
      bkpf.xreorg                                                                                        as XREORG,

      t001.ktopl                                                                                         as KTOPL,
      reguh.laufi                                                                                        as LAUFI,
      reguh.laufd                                                                                        as LAUFD,
      reguh.rzawe                                                                                        as RZAWE,
      payr.laufi                                                                                         as PAYR_LAUFI,
      payr.laufd                                                                                         as PAYR_LAUFD,
      payr.lifnr                                                                                         as PAYR_LIFNR,
      payr.voidr                                                                                         as VOIDR,
      payr.voidd                                                                                         as VOIDD,
      payr.chect                                                                                         as CHECT,
      payr.priti                                                                                         as PRITI,
      payr.xmanu                                                                                         as XMANU,
      payr.xbanc                                                                                         as XBANC,
      payr.bancd                                                                                         as BANCD,
      prps.posid                                                                                         as POSID,
      prps.prart                                                                                         as PRART,
      prps.post1                                                                                         as POST1,
      prps.objnr                                                                                         as OBJNR,
      --skat.txt50                                          as TXT50,
      --cskt.ktext                                          as CSKT_KTEXT,
      --cskt.ltext                                          as CSKT_LTEXT,
      tvzbt.vtext                                                                                        as VTEXT,
      --TVOIT.voidt AS VOIDT,
      cepct.ktext                                                                                        as PROFIT_CENTER_TEXT,
      t052.ztag1                                                                                         as ZTAG1,
      t003t.ltext                                                                                        as LTEXT,
      aufk.ktext                                                                                         as KTEXT,
      VendorLineItem.CLEARING_DATE, ---Changes done as per mail request from Pranav Dated: 14/01/2026.. Tarun A
      substring(VendorLineItem.CLEARING_DATE,1,6)                                                        as CLEARING_PERIOD, -----Changes done as per mail request from Pranav Dated: 14/01/2026.. Tarun A
      bkpf.xblnr                                                                                         as XBLNR,
      case left(bkpf.xblnr,3) when 'XPD' then bkpf.xblnr else VendorLineItem.ZMCKSTP_ORG_INV_NUM_JEI end as CC_INVOICE_NUMBER,
      left(prps.posid, 6)                                                                                as PSPID,
      case instr(VendorLineItem.XREF1_GL,'|') when 0 then 0 else instr(VendorLineItem.XREF1_GL,'|') end  as PIPEPOS,
      length(VendorLineItem.XREF1_GL)                                                                    as XREF1_GL_LENGTH,
      VendorLineItem.POSTING_PERIOD

}
where
  (
       VendorLineItem.KOART = 'K'
    or VendorLineItem.KOART = 'S'
    or VendorLineItem.KOART = 'D'
  )
  and  VendorLineItem.mandt = $session.client
