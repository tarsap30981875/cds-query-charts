--OPS_INVOICE as per requested by the OPS Team JIRA Ticket:FPDA-2181:BSEG driven OPS view optimization with consumption of CDS view
@AbapCatalog.sqlViewName: 'Z_VLITEM_V'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Line Item Details'
@ObjectModel: { usageType.sizeCategory: #XL,
                usageType.dataClass:  #ORGANIZATIONAL,
                usageType.serviceQuality: #A,
                supportedCapabilities: [#ANALYTICAL_DIMENSION, #CDS_MODELING_ASSOCIATION_TARGET, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE, #EXTRACTION_DATA_SOURCE],
                modelingPattern: #ANALYTICAL_DIMENSION
                }
@ClientHandling.algorithm: #SESSION_VARIABLE
@Metadata.ignorePropagatedAnnotations: true
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

              }
            ]
         }
      }
    }

define view ZOPS_I_VENDORLINEITEM
  as select from bseg as VendorLineItem
{
  key VendorLineItem.mandt,
  key VendorLineItem.bukrs                                                                                       as BUKRS,
  key VendorLineItem.belnr                                                                                       as BELNR,
  key VendorLineItem.gjahr                                                                                       as GJAHR,
  key VendorLineItem.buzei                                                                                       as BUZEI,
      VendorLineItem.buzid                                                                                       as BUZID,
      VendorLineItem.augdt                                                                                       as AUGDT,
      VendorLineItem.augcp                                                                                       as AUGCP,
      VendorLineItem.augbl                                                                                       as AUGBL,
      VendorLineItem.bschl                                                                                       as BSCHL,
      VendorLineItem.umskz                                                                                       as UMSKZ,
      VendorLineItem.umsks                                                                                       as UMSKS,
      VendorLineItem.zumsk                                                                                       as ZUMSK,
      --      VendorLineItem.shkzg                                as SHKZG,
      VendorLineItem.koart                                                                                       as KOART,
      VendorLineItem.gsber                                                                                       as GSBER,
      VendorLineItem.pargb                                                                                       as PARGB,
      ----Decimal Shift Logic added as per requested by the OPS Team JIRA Ticket:FPDA-2181:BSEG driven OPS view optimization with consumption of CDS view
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>VendorLineItem.dmbtr,currency=>VendorLineItem.h_hwaer) as abap.dec(23,2))                                                                                       as DMBTR_DECSHFT,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>VendorLineItem.wrbtr,currency=>VendorLineItem.h_waers) as abap.dec(23,2))                                                                                       as WRBTR_DECSHFT,
      @DefaultAggregation: #SUM
      cast(decimal_shift(amount=>VendorLineItem.dmbe2,currency=>VendorLineItem.h_hwae2) as abap.dec(23,2))                                                                                      as DMBE2_DECSHFT,
      ------------------------------------------------------------------------------------------------------- 
      ------RAW Amount Fields- from BSEG for Future Usage--Tarun A: Dated 29/01/2026 
      @DefaultAggregation: #SUM
      VendorLineItem.dmbtr as DMBTR,
      @DefaultAggregation: #SUM
      VendorLineItem.wrbtr as WRBTR,
      @DefaultAggregation: #SUM
      VendorLineItem.dmbe2 as DMBE2,
      -----------------------------------------------------------------------------------------------------
      VendorLineItem.h_hwae2 as H_HWAE2,
      VendorLineItem.h_waers as H_WAERS,
      VendorLineItem.h_hwaer as H_HWAER, 
      VendorLineItem.ktosl                                                                                       as KTOSL,
      VendorLineItem.qsshb                                                                                       as QSSHB,
      VendorLineItem.gbetr                                                                                       as GBETR,
      VendorLineItem.valut                                                                                       as VALUT,
      VendorLineItem.zuonr                                                                                       as ZUONR,
      VendorLineItem.altkt                                                                                       as ALTKT,
      VendorLineItem.fdlev                                                                                       as FDLEV,
      VendorLineItem.fdgrp                                                                                       as FDGRP,
      VendorLineItem.fdtag                                                                                       as FDTAG,
      VendorLineItem.fkont                                                                                       as FKONT,
      VendorLineItem.kokrs                                                                                       as KOKRS,
      VendorLineItem.projn                                                                                       as PROJN,
      VendorLineItem.vbel2                                                                                       as VBEL2,
      VendorLineItem.posn2                                                                                       as POSN2,
      VendorLineItem.eten2                                                                                       as ETEN2,
      VendorLineItem.anln1                                                                                       as ANLN1,
      VendorLineItem.anln2                                                                                       as ANLN2,
      VendorLineItem.anbwa                                                                                       as ANBWA,
      VendorLineItem.bzdat                                                                                       as BZDAT,
      VendorLineItem.pernr                                                                                       as PERNR,
      VendorLineItem.saknr                                                                                       as SAKNR,
      VendorLineItem.hkont                                                                                       as VENDOR_GL_ACCOUNT,
      VendorLineItem.kunnr                                                                                       as KUNNR,
      VendorLineItem.lifnr                                                                                       as LIFNR,
      VendorLineItem.filkd                                                                                       as FILKD,
      VendorLineItem.xbilk                                                                                       as XBILK,
      VendorLineItem.gvtyp                                                                                       as GVTYP,
      VendorLineItem.hzuon                                                                                       as HZUON,
      VendorLineItem.zfbdt                                                                                       as ZFBDT,
      VendorLineItem.zterm                                                                                       as ZTERM,
      VendorLineItem.skfbt                                                                                       as SKFBT,
      VendorLineItem.zlsch                                                                                       as ZLSCH,
      VendorLineItem.zlspr                                                                                       as ZLSPR,
      VendorLineItem.bvtyp                                                                                       as BVTYP,
      VendorLineItem.samnr                                                                                       as SAMNR,
      VendorLineItem.abper                                                                                       as ABPER,
      VendorLineItem.wverw                                                                                       as WVERW,
      VendorLineItem.klibt                                                                                       as KLIBT,
      VendorLineItem.qsznr                                                                                       as QSZNR,
      VendorLineItem.qsfbt                                                                                       as QSFBT,
      VendorLineItem.matnr                                                                                       as MATNR,
      VendorLineItem.werks                                                                                       as WERKS,
      VendorLineItem.menge                                                                                       as MENGE,
      VendorLineItem.meins                                                                                       as MEINS,
      VendorLineItem.erfmg                                                                                       as ERFMG,
      VendorLineItem.erfme                                                                                       as ERFME,
      VendorLineItem.bpmng                                                                                       as BPMNG,
      VendorLineItem.bprme                                                                                       as BPRME,
      VendorLineItem.ebeln_logsys                                                                                as EBELN_LOGSYS,
      VendorLineItem.ebeln                                                                                       as EBELN,
      VendorLineItem.ebelp                                                                                       as EBELP,
      VendorLineItem.zekkn                                                                                       as ZEKKN,
      VendorLineItem.elikz                                                                                       as ELIKZ,
      VendorLineItem.vprsv                                                                                       as VPRSV,
      VendorLineItem.peinh                                                                                       as PEINH,
      VendorLineItem.bwkey                                                                                       as BWKEY,
      VendorLineItem.bwtar                                                                                       as BWTAR,
      VendorLineItem.prctr                                                                                       as PRCTR,
      VendorLineItem.vptnr                                                                                       as VPTNR,
      VendorLineItem.txjcd                                                                                       as TXJCD,
      VendorLineItem.kstrg                                                                                       as KSTRG,
      VendorLineItem.dmbe3                                                                                       as DMBE3,
      VendorLineItem.xragl                                                                                       as XRAGL,
      VendorLineItem.xref1                                                                                       as XREF1,
      VendorLineItem.xref2                                                                                       as XREF2,
      VendorLineItem.empfb                                                                                       as EMPFB,
      VendorLineItem.xref3                                                                                       as XREF3,
      VendorLineItem.kidno                                                                                       as KIDNO,
      VendorLineItem.bupla                                                                                       as BUPLA,
      VendorLineItem.secco                                                                                       as SECCO,
      VendorLineItem.lstar                                                                                       as LSTAR,
      VendorLineItem.docln                                                                                       as DOCLN,
      VendorLineItem.segment                                                                                     as SEGMENT,
      VendorLineItem.xlgclr                                                                                      as XLGCLR,
      VendorLineItem.xfrge_bseg                                                                                  as XFRGE_BSEG,
      VendorLineItem.buzei_sender                                                                                as BUZEI_SENDER,
      VendorLineItem.h_monat                                                                                     as H_MONAT,
      VendorLineItem.h_bstat                                                                                     as H_BSTAT,
      VendorLineItem.h_budat                                                                                     as H_BUDAT,
      VendorLineItem.h_bldat                                                                                     as H_BLDAT,
      VendorLineItem.h_blart                                                                                     as H_BLART,
      VendorLineItem.sk1dt                                                                                       as SK1DT,
      VendorLineItem.sk2dt                                                                                       as SK2DT,
      VendorLineItem._dataaging                                                                                  as DATAAGING,
      VendorLineItem.ghkon                                                                                       as GHKON,
      VendorLineItem.squan                                                                                       as SQUAN,
      VendorLineItem.acdoc_eew_dummy                                                                             as ACDOC_EEW_DUMMMY,
      VendorLineItem.zmckje_item_pay_ref_jei                                                                     as ZMCKJE_ITEM_PAY_REF_JEI,
      VendorLineItem.netdt                                                                                       as NETDT,
      VendorLineItem.re_bukrs                                                                                    as RE_BUKRS,
      VendorLineItem.re_account                                                                                  as RE_ACCOUNT,
      VendorLineItem.zmckstp_unq_idt_num_jei                                                                     as ZMCKSTP_UNQ_IDT_NUM_JEI,
      VendorLineItem.zmckstp_org_inv_num_jei                                                                     as ZMCKSTP_ORG_INV_NUM_JEI,
      VendorLineItem.zmckstp_pymnt_ref_num_jei                                                                   as ZMCKSTP_PYMNT_REF_NUM_JEI,
      $session.system_date                                                                                       as ZTIMESTAMP,
      VendorLineItem.fdwbt                                                                                       as FDWBT,
      VendorLineItem.wmwst                                                                                       as WMWST,
      VendorLineItem.mwart                                                                                       as MWART,
      VendorLineItem.fwbas                                                                                       as FWBAS,
      VendorLineItem.txbfw                                                                                       as TXBFW,
      VendorLineItem.pswsl                                                                                       as RWCUR,
      VendorLineItem.rfccur                                                                                      as RHCUR,
      VendorLineItem.hkont                                                                                       as HKONT,
      VendorLineItem.hsn_sac                                                                                     as HSN_SAC,
      VendorLineItem.projk                                                                                       as PROJK,
      VendorLineItem.aufnr                                                                                       as AUFNR,
      VendorLineItem.kostl                                                                                       as KOSTL,
      VendorLineItem.sgtxt                                                                                       as SGTXT,
      VendorLineItem.qsskz                                                                                       as QSSKZ,
      VendorLineItem.mwskz                                                                                       as MWSKZ,
      VendorLineItem.shkzg                                                                                       as SHKZG,
      
      concat(VendorLineItem.gjahr,VendorLineItem.h_monat)                                                        as CC_INV_PERIOD,
      dats_days_between(VendorLineItem.h_budat,cast($session.system_date as abap.dats(8)))                       as AGING_BUCKET,
      (case left(VendorLineItem.lifnr,3)
      when  'ICV' then 'Intercompany'
      when  '001' then  '1 Series'
      when  '003' then  '3 Series'
      when  '004' then  '4 Series'
      else ''
      end
      )                                                                                                          as CC_SUPPLIER,
      case when VendorLineItem.koart = 'K' and VendorLineItem.buzei = '001'  then 'VENDOR_LINE'
      when (VendorLineItem.koart = 'S' or VendorLineItem.koart = 'D') then 'GL_LINE' else ''
      end                                                                                                        as CC_ACCOUNT_TYPE,

      case when VendorLineItem.koart = 'K' then VendorLineItem.zuonr else '' end                                 as BARCODE,
      case when (VendorLineItem.koart = 'S' or VendorLineItem.koart = 'D') then VendorLineItem.zuonr else '' end as FMNO_GLP,
      case when VendorLineItem.koart = 'K' then VendorLineItem.xref3 else '' end                                 as XREF3_VENDOR,
      case when (VendorLineItem.koart = 'S' or VendorLineItem.koart = 'D') then VendorLineItem.xref3 else '' end as XREF3_GL,
      case when VendorLineItem.koart = 'K' then VendorLineItem.xref1 else '' end                                 as XREF1_VENDOR,
      case when (VendorLineItem.koart = 'S' or VendorLineItem.koart = 'D') then VendorLineItem.xref1 else '' end as XREF1_GL,
      case when VendorLineItem.koart = 'K' then VendorLineItem.projk else '' end                                 as PROJK_VENDOR,
      case when (VendorLineItem.koart = 'S' or VendorLineItem.koart = 'D') then VendorLineItem.projk else '' end as PROJK_GL,
      case when VendorLineItem.augdt='00000000' then h_budat else augdt end as CLEARING_DATE,---Changes done as per mail request from Pranav Dated: 14/01/2026.. Tarun A
      left(VendorLineItem.h_budat,6) as POSTING_PERIOD
      
      --case instr('9999999|01','|') when 0 then 1 else (instr('9999999|01','|')+1) end as PIPEPOS,
      --length('9999999|01')
      --'2' as PIPELEN,
      --length('9999999|01')-cast(case instr('9999999|01','|') when 0 then 1 else (instr('9999999|01','|')+1) end as abap.int2) as PIPEDIFF
          
      
      

}
where

  (
       VendorLineItem.h_blart = 'KA'
    or VendorLineItem.h_blart = 'KG'
    or VendorLineItem.h_blart = 'KR'
    or VendorLineItem.h_blart = 'KZ'
    or VendorLineItem.h_blart = 'ZC'
    or VendorLineItem.h_blart = 'ZH'
    or VendorLineItem.h_blart = 'ZI'
    or VendorLineItem.h_blart = 'ZP'
    or VendorLineItem.h_blart = 'ZV'
  )
  and (VendorLineItem.koart='K' or VendorLineItem.koart='S' or VendorLineItem.koart='D')
  and  VendorLineItem.mandt   = $session.client
