C0ITEST ; GPL/NEA - Immunizations Forecasting Routine ;05/03/14  17:05
 ;;0.1;Immunizations Forecasting;nopatch;noreleasedate;
 ;
 ; License Apache 2
 ; 
 Q
 ;
EN(WRK,DFN,PARMS) ;
 K WRK
 N C0ARY,G,C0IPOA,CPTMAP,CVXMAP,CPTIMAP,CVXIMAP
 D CPTMAP^C0ITEST
 D CVXMAP^C0ITEST
 D CPTIMAP^C0ITEST
 D CVXIMAP^C0ITEST
 D PAYOUTAV^C0ITEST
 D PAYOUTBV^C0ITEST
 D GET^C0IUTIL("WRK","TPAYOUTC^C0ITEST")
 D PAYOUTDV^C0ITEST
 D GET^C0IUTIL("WRK","TPAYOUTE^C0ITEST")
 M ^TMP("C0IWRK",$J)=WRK
 S OK=$$GTF^%ZISH($NA(^TMP("C0IWRK",$J,1)),3,"/home/vista/","ice-test.xml")
 K WRK(0)
 Q
 ;
TEST1 ;
 S DFN=$$PAT^C0IICE()
 K WRK
 D CPTMAP
 D CVXMAP
 D CPTIMAP
 D CVXIMAP
 D PAYOUTAV
 D PAYOUTBV
 D GET^C0IUTIL("WRK","TPAYOUTC^C0ITEST")
 D PAYOUTDV
 D GET^C0IUTIL("WRK","TPAYOUTE^C0ITEST")
 M ^TMP("C0IWRK",$J)=WRK
 W $$GTF^%ZISH($NA(^TMP("C0IWRK",$J,1)),3,"/home/vista/","ice-test.xml")
 Q
 ; get patient DFN
 ; get patient VPR demographics for sex and DOB
 ; call VPR to get patient Immunizaitons
 ; 
 ; begin building SOAP request XML
 ; loop through immunizations array and generate XML pieces
 ; call build to put all the pieces together into one XML array
 ; base64 encode the XML array
 ;
TENVOUT ; build SOAP envelope
 ;;<S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"> 
 ;;<S:Body>
 ;;<ns2:evaluateAtSpecifiedTime xmlns:ns2="http://www.omg.org/spec/CDSS/201105/dss">
 ;;<interactionId scopingEntityId="gov.nyc.health" interactionId="123456"/>
 ;;<specifiedTime>@@hl7OutTime@@</specifiedTime>
 ;;<evaluationRequest clientLanguage="" clientTimeZoneOffset="">
 ;;<kmEvaluationRequest>
 ;;<kmId scopingEntityId="org.nyc.cir" businessId="ICE" version="1.0.0"/>
 ;;</kmEvaluationRequest>
 ;;<dataRequirementItemData>
 ;;<driId itemId="cdsPayload">
 ;;<containingEntityId scopingEntityId="gov.nyc.health" businessId="ICEData" version="1.0.0.0"/>
 ;;</driId>
 ;;<data>
 ;;<informationModelSSId scopingEntityId="org.opencds.vmr" businessId="VMR" version="1.0"/>
 ;;<base64EncodedPayload>@@outPayload@@</base64EncodedPayload>
 ;;</data>
 ;;</dataRequirementItemData>
 ;;</evaluationRequest>
 ;;</ns2:evaluateAtSpecifiedTime>
 ;; </S:Body>
 ;; </S:Envelope>
 Q
ENVOUTV ; create beginning of envelop
 K C0IARY
 S C0IARY("hl7OutTime")=$$FMDTOCDA^C0IUTIL(DT)
 D GETNMAP^C0IUTIL("WRK","TENVOUT^C0ITEST","C0IARY")
 Q
TPAYOUTA ; First part of payload message with Sex and DOB and a UUID variables
 ;;<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
 ;;<ns4:cdsInput xmlns:ns2="org.opencds" xmlns:ns3="org.opencds.vmr.v1_0.schema.vmr" xmlns:ns4="org.opencds.vmr.v1_0.schema.cdsinput" xmlns:ns5="org.opencds.vmr.v1_0.schema.cdsoutput">
 ;;<templateId root="2.16.840.1.113883.3.795.11.1.1"/>
 ;;<cdsContext>
 ;;<cdsSystemUserPreferredLanguage code="en" codeSystem="2.16.840.1.113883.6.99" displayName="English"/>
 ;;</cdsContext>
 ;;<vmrInput>
 ;;<templateId root="2.16.840.1.113883.3.795.11.1.1"/>
 ;;<patient>
 ;;<templateId root="2.16.840.1.113883.3.795.11.2.1.1"/>
 ;;<id root="@@UUID0@@"/>
 ;;<demographics>
 ;;<birthTime value="@@DOB@@"/>
 ;;<gender code="@@genderCode@@" codeSystem="2.16.840.1.113883.5.1" displayName="@@genderName@@" originalText="@@genderCode@@"/>
 ;;</demographics>
 ;;<clinicalStatements>
 Q
 ;
PAYOUTAV ; setting payload variables sex, DOB and UUID for the first section (PAYOUTA)
 K C0IPOA
 S X=$$GET1^DIQ(2,DFN,"DOB","I")
 S C0IPOA("UUID0")=$$UUID^C0IUTIL
 S C0IPOA("DOB")=$$FMDTOCDA^C0IUTIL(X)
 S C0IPOA("genderCode")=$$GET1^DIQ(2,DFN,"SEX","I")
 I C0IPOA("genderCode")="M" S C0IPOA("genderName")="Male"
 I C0IPOA("genderCode")="F" S C0IPOA("genderName")="Female"
 I C0IPOA("genderCode")="UN" S C0IPOA("genderName")="Undifferentiated" ; ICE term, not VISTA  VistA allow M F only.P
 D GETNMAP^C0IUTIL("WRK","TPAYOUTA^C0ITEST","C0IPOA") 
 Q
 ;
PAYOUTB ;
 ;;;Disease an immunity section which is optional. the DISEASE_DOCUMENTED and IS_IMMUNE
 ;;;Cycle through 6 diseases using reminders to check for prior diagnosis
 ;;;Hep A: 070.1
 ;;;Hep B: 070.3
 ;;;Measles: 055.9
 ;;;Mumps: 072.9
 ;;;Rubella: 056.9
 ;;;Varicella: 052.9
 ;;;First Tag for this section if any prior diagnoses are available
 ;;<observationResults>
 Q
 ;
PAYOUTM ;
 ;;;Populate this section for each disease found leading to immunity
 ;;<observationResult>
 ;;<templateId root="2.16.840.1.113883.3.795.11.6.3.1"/>
 ;;<id root="@@UUIDA@@"/>
 ;;<observationFocus code="@@codeICD9@@" codeSystem="2.16.840.1.113883.6.103" displayName="@@codeName@@" originalText="@@codeICD9@@"/>
 ;;<observationEventTime low="@@timeProblem@@" high="@@timeProblem@@"/>
 ;;<observationValue>
 ;;<concept code="DISEASE_DOCUMENTED" codeSystem="2.16.840.1.113883.3.795.12.100.8" displayName="Disease Documented" originalText="DISEASE_DOCUMENTED"/>
 ;;</observationValue>
 ;;<interpretation code="IS_IMMUNE" codeSystem="2.16.840.1.113883.3.795.12.100.9" displayName="Is Immune" originalText="IS_IMMUNE"/>
 ;;</observationResult>
 Q
 ;
PAYOUTN ;
 ;;;Finishes off the disease section if there is one
 ;;</observationResults>
 Q
PAYOUTBV ;
 ;Placeholder for logic and variables for populating the DISEASE_DOCUMENTED and IS_IMMUNE
 ;Diseases Hep A, Hep B, Measles, Mumps, Rubella, Varicella only as of 5/2014,
 ;If N is 0 after using reminders to test for the diseases in the taxonomies, then skip this section
 ;If more than one of these present, use the needed disease tags to write this part of the message
 ;NEED TO REPLACE HARD CODED REMINDER IENS WITH A LOOKUP!!!
 N IENHEPA,IENHEPB,IENMEASL,IENVARIC,IENMUMPS,IENRUBEL 
 S (IENHEPA,IENHEPB,IENMEASL,IENVARIC,IENMUMPS,IENRUBEL)=""
 N FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG
 S FILE=811.9 
 S IENS=""
 S FLAGS="OQ"
 S INDEX="B"
 S SCREEN=""
 S EMSG=""
 N N,HEPA,HEPB,VARICEL,MUMPS,MEASLES,RUBELLA
 S (N,HEPA,HEPB,VARICEL,MUMPS,MEASLES,RUBELLA)=0
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-HEPATITIS B DIAGNOSIS"
 S IENHEPB=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 I IENHEPB="" Q  ; reminder not found, skip this part
 K REMNAME
 D MAIN^PXRM(DFN,IENHEPB,0)
 I $G(^TMP("PXRHM",$J,IENHEPB,"VIMM-HEPATITIS B DIAGNOSIS"))["DUE NOW" S N=N+1 S HEPB=1
 ;W "HEPB=",HEPB,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-HEPATITIS A DIAGNOSIS"
 S IENHEPA=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG) 
 K REMNAME
 D MAIN^PXRM(DFN,IENHEPA,0)
 I $G(^TMP("PXRHM",$J,IENHEPA,"VIMM-HEPATITIS A DIAGNOSIS"))["DUE NOW" S N=N+1 S HEPA=1
 ;W "HEPA=",HEPA,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-VARICELLA DIAGNOSIS"
 S IENVARIC=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 D MAIN^PXRM(DFN,IENVARIC,0)
 I $G(^TMP("PXRHM",$J,IENVARIC,"VIMM-VARICELLA DIAGNOSIS"))["DUE NOW" S N=N+1 S VARICEL=1
 ;W "VARICEL=",VARICEL,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-MUMPS DIAGNOSIS" 
 S IENMUMPS=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG) D MAIN^PXRM(DFN,267,0)
 K REMNME
 D MAIN^PXRM(DFN,IENMUMPS,0)
 I $G(^TMP("PXRHM",$J,IENMUMPS,"VIMM-MUMPS DIAGNOSIS"))["DUE NOW" S N=N+1 S MUMPS=1
 ;W "MUMPS=",MUMPS,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-MEASLES DIAGNOSIS"
 S IENMEASL=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 D MAIN^PXRM(DFN,IENMEASL,0)
 I $G(^TMP("PXRHM",$J,IENMEASL,"VIMM-MEASLES DIAGNOSIS"))["DUE NOW" S N=N+1 S MEASLES=1
 ;W "MEASLES=",MEASLES,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-RUBELLA DIAGNOSIS"
 S IENRUBEL=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 D MAIN^PXRM(DFN,IENRUBEL,0)
 I $G(^TMP("PXRHM",$J,IENRUBEL,"VIMM-RUBELLA DIAGNOSIS"))["DUE NOW" S N=N+1 S RUBELLA=1
 ;W "RUBELLA=",RUBELLA,!
 K ^TMP("PXRHM",$J)
 I N=0 Q
 E  D
 .D GETNMAP^C0IUTIL("WRK","PAYOUTB^C0ITEST","C0IPOA")
 .I HEPB=1 D HEPB
 .I HEPA=1 D HEPA
 .I VARICEL=1 D VARICEL
 .I MUMPS=1 D MUMPS
 .I MEASLES=1 D MEASLES
 .I RUBELLA=1 D RUBELLA
 .D GETNMAP^C0IUTIL("WRK","PAYOUTN^C0ITEST","C0IPOA")
 .K ^TMP("PXRHM",$J)
 Q
 ;
HEPB ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 S C0IPOA("codeICD9")="070.30"
 S C0IPOA("codeName")="Viral hepatitis B without mention of hepatic coma, acute or unspecified, without mention of hepatitis delta"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName")
 Q
 ;
HEPA ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 ;S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL("3130101")
 S C0IPOA("codeICD9")="070.1"
 S C0IPOA("codeName")="Viral hepatitis A without mention of hepatic coma"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName") 
 Q
 ;
VARICEL ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 S C0IPOA("codeICD9")="052.9"
 S C0IPOA("codeName")="Varicella without mention of complication"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName")
 Q 
 ;  
MUMPS ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 S C0IPOA("codeICD9")="072.9"
 S C0IPOA("codeName")="Mumps without mention of complication"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")  
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName")
 Q
 ; 
MEASLES ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 S C0IPOA("codeICD9")="055.9"
 S C0IPOA("codeName")="Measles without mention of complication"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName")
 Q
 ;
RUBELLA ;
 S C0IPOA("UUIDA")=$$UUID^C0IUTIL
 S C0IPOA("timeProblem")=$$FMDTOCDA^C0IUTIL(DT)
 S C0IPOA("codeICD9")="056.9"
 S C0IPOA("codeName")="Rubella without mention of complication"
 D GETNMAP^C0IUTIL("WRK","PAYOUTM^C0ITEST","C0IPOA")
 K C0IPOA("UUIDA")  
 K C0IPOA("timeProblem")
 K C0IPOA("codeICD9")
 K C0IPOA("codeName")
 Q
 ;
TPAYOUTC ;
 ;;; only one line that is fixed for substance administration 
 ;;<substanceAdministrationEvents>
 Q
 ;
TPAYOUTD ; 
 ;;; this section loops through the immunizations
 ;;<substanceAdministrationEvent>
 ;;<templateId root="2.16.840.1.113883.3.795.11.9.1.1"/>
 ;;<id root="@@UUID1@@"/>
 ;;<substanceAdministrationGeneralPurpose code="384810002" codeSystem="2.16.840.1.113883.6.5"/>
 ;;<substance>
 ;;<id root="@@UUID2@@"/>
 ;;<substanceCode code="@@CVXCode@@" codeSystem="2.16.840.1.113883.12.292" displayName="@@CVXName@@" originalText="@@ORIGName@@"/>
 ;;</substance>
 ;;<administrationTimeInterval low="@@admDate@@" high="@@admDate@@"/>
 ;;</substanceAdministrationEvent>
 Q
 ;
PAYOUTDV ;
 ; Variable and code for the looping IMMUNIZATIONS section
 ; Need UUID x 2, CVX code, name from CVX Short name, administration date 
 ;(need really only one eve thought it asks for high and low - use the same variable)
 D GETPAT^C0IEXTR(.G,DFN,"immunization")
 I G("results","immunizations@total")=0 Q
 E  D
 .N T S T=G("results","immunizations@total")
 .I T=1 D  ;
 ..N GTMP
 ..M GTMP=G("results","immunizations")
 ..K G("results","immunizations")
 .. M G("results","immunizations",1)=GTMP
 .. K GTMP
 .N I S I=""
 .F I=1:1:T D
 ..W:'$G(DIQUIET) "I is ",I,!
 ..D OUTLOG^C0IUTIL("I is "_I)
 ..N CPTIMM,CVXCODE,ADMDATE,IMMNAME,IMMCVX
 ..S C0IPOA("UUID1")=$$UUID^C0IUTIL 
 ..S C0IPOA("UUID2")=$$UUID^C0IUTIL
 ..S C0IPOA("CVXCode")=""
 ..S C0IPOA("CVXName")=""
 ..S C0IPOA("ORIGName")=""
 ..S C0IPOA("admDate")=""
 ..I $D(G("results","immunizations",I,"immunization","cpt@code")) D 
 ...; If there is a CPT code, use that to get the CVX code and the proper CVC code name
 ...N CPTIMM,CVXCODE,ADMDATE 
 ...S CPTIMM="" S CVXCODE="" S ADMDATE=""
 ...S CPTIMM=$G(G("results","immunizations",I,"immunization","cpt@code"))
 ...W:'$G(DIQUIET) "CPTIMM from G is ",CPTIMM,!
 ...S CVXCODE=CPTMAP(CPTIMM)
 ...W:'$G(DIQUIET) "The CVX code for this immunizaton with a CPT code is ",CVXCODE,!
 ...I ((CVXCODE'="")!(CVXCODE=999)) D  Q
 ....; If you found the CVXCode by the CPT code, add the XML to the array and QUIT  
 ....S C0IPOA("CVXCode")=CVXCODE
 ....S C0IPOA("CVXName")=CVXMAP(CVXCODE)
 ....S C0IPOA("ORIGName")=$G(G("results","immunizations",I,"immunization","name@value"))
 ....S ADMDATE=$G(G("results","immunizations",I,"immunization","administered@value"))
 ....S C0IPOA("admDate")=$$FMDTOCDA^C0IUTIL(ADMDATE)
 ....D GETNMAP^C0IUTIL("WRK","TPAYOUTD^C0ITEST","C0IPOA")
 ..I '$D(G("results","immunizations",I,"immunization","cpt@code")) D
 ...; if there is no CPT code, try to look it up by the proper CVX code name
 ...N IMMNAME,IMMCVX,IMMCPT,CVXCODE,ADMDATE
 ...S (IMMNAME,IMMCVX,IMMCPT,CVXCODE,ADMDATE)=""
 ...S IMMNAME=$G(G("results","immunizations",I,"immunization","name@value"))
 ...W:'$G(DIQUIET) "IMMNAME in the no CPT look up by proper CVX code name is ",IMMNAME,!
 ...S IMMCVX=$O(CVXMAP("B",IMMNAME,""))
 ...W:'$G(DIQUIET) "IMMCVX for this vaccine with a proper name is ",IMMCVX,!
 ...I IMMCVX="" D
 ....; If the CVX code is not found by the proper CVX code name, try the lookup in the CPTIMAP section by the
 ....; original name which are odd names in the Immunization file.
 ....; Once you have the CVX code, get the proper text from the CVX code from the CVX Map
 ....; Once a different method of storing the CVX-Immunization map is found, then this section will be replaced
 ....; CVXIMAP is specific a VistA instance.
 ....N CVXCODE,IMMNAME,IMMCVX,ADMDATE,CVXNAME
 ....S (CVXCODE,IMMNAME,IMMCVX,ADMDATE,CVXNAME)=""
 ....S IMMNAME=$G(G("results","immunizations",I,"immunization","name@value"))
 ....I IMMNAME="" S IMMNAME=$G(G("results","immunizations","immunization","name@value"))
 ....I IMMNAME="" D  Q
 ....W:'$G(DIQUIET) "The IMMNAME for this immunization without a proper name is ",IMMNAME,!
 ....S CVXCODE=$O(CVXIMAP("B",IMMNAME,""))
 ....W:'$G(DIQUIET) "The CVX code for this immunization without the proper name is ",CVXCODE,!
 ....S CVXNAME=CVXMAP(CVXCODE) 
 ....W:'$G(DIQUIET) "The proper name for this immunization is ",CVXNAME,!
 ....I CVXCODE="" D  Q
 .....; If there is still no CVX code found, record and error and quit
 .....S ZTXT=$G(G("results","immunizations",I,"immunization","id@value"))
 .....D OUTLOG("ERROR-Missing CVX or Incorrect Name for IEN="_ZTXT)
 ....E  D
 .....; Else, if you have found a CVX code, then write the XML to the array and QUIT
 .....S C0IPOA("CVXCode")=CVXCODE
 .....S C0IPOA("CVXName")=CVXNAME
 .....S C0IPOA("ORIGName")=$G(G("results","immunizations",I,"immunization","name@value"))
 .....S ADMDATE=$G(G("results","immunizations",I,"immunization","administered@value"))
 .....S C0IPOA("admDate")=$$FMDTOCDA^C0IUTIL(ADMDATE) ;S ^GPL("DATE",I)=ADMDATE
 .....D GETNMAP^C0IUTIL("WRK","TPAYOUTD^C0ITEST","C0IPOA")
 Q
 ;
OUTLOG(ZTXT) ; add text to the log
 I '$D(C0LOGLOC) S C0LOGLOC=$NA(^TMP("C0I",$J,"LOG"))
 N LN S LN=$O(@C0LOGLOC@(""),-1)+1
 S @C0LOGLOC@(LN)=ZTXT
 Q
 ;
TPAYOUTE
 ;;;fixed end portion of payload
 ;;</substanceAdministrationEvents>
 ;;</clinicalStatements>
 ;;</patient>
 ;;</vmrInput>
 ;;</ns4:cdsInput>
 Q
 ;
CPTMAP
 S CPTMAP(90281)=86
 S CPTMAP(90283)=87
 S CPTMAP(90287)=27
 S CPTMAP(90291)=29
 S CPTMAP(90296)=12
 S CPTMAP(90371)=30
 S CPTMAP(90375)=34
 S CPTMAP(90376)=34
 S CPTMAP(90378)=93
 S CPTMAP(90379)=71
 S CPTMAP(90389)=13
 S CPTMAP(90393)=79
 S CPTMAP(90396)=36
 S CPTMAP(90470)=128
 S CPTMAP(90476)=54
 S CPTMAP(90477)=55
 S CPTMAP(90581)=24
 S CPTMAP(90585)=19
 S CPTMAP(90632)=52
 S CPTMAP(90633)=83
 S CPTMAP(90634)=84
 S CPTMAP(90636)=104
 S CPTMAP(90644)=148
 S CPTMAP(90645)=47
 S CPTMAP(90646)=46
 S CPTMAP(90647)=49
 S CPTMAP(90648)=48
 S CPTMAP(90649)=62
 S CPTMAP(90650)=118
 S CPTMAP(90654)=144
 S CPTMAP(90655)=140
 S CPTMAP(90656)=140
 S CPTMAP(90657)=141
 S CPTMAP(90658)=141
 S CPTMAP(90659)=16
 S CPTMAP(90660)=111
 S CPTMAP(90661)=153
 S CPTMAP(90662)=135
 S CPTMAP(90663)=128
 S CPTMAP(90664)=125
 S CPTMAP(90665)=66
 S CPTMAP(90666)=126
 S CPTMAP(90668)=127
 S CPTMAP(90669)=100
 S CPTMAP(90670)=133
 S CPTMAP(90672)=149
 S CPTMAP(90673)=155
 S CPTMAP(90675)=18
 S CPTMAP(90676)=40
 S CPTMAP(90680)=116
 S CPTMAP(90681)=119
 S CPTMAP(90685)=150
 S CPTMAP(90686)=150
 S CPTMAP(90688)=158
 S CPTMAP(90690)=25
 S CPTMAP(90691)=101
 S CPTMAP(90692)=41
 S CPTMAP(90693)=53
 S CPTMAP(90696)=130
 S CPTMAP(90698)=120
 S CPTMAP(90700)=20
 S CPTMAP(90700)=106
 S CPTMAP(90701)=01
 S CPTMAP(90702)=28
 S CPTMAP(90703)=35
 S CPTMAP(90704)=07
 S CPTMAP(90705)=05
 S CPTMAP(90706)=06
 S CPTMAP(90707)=03
 S CPTMAP(90708)=04
 S CPTMAP(90710)=94
 S CPTMAP(90712)=02
 S CPTMAP(90713)=10
 S CPTMAP(90714)=113
 S CPTMAP(90714)=91
 S CPTMAP(90715)=115
 S CPTMAP(90716)=21
 S CPTMAP(90717)=37
 S CPTMAP(90718)=09
 S CPTMAP(90720)=22
 S CPTMAP(90721)=50
 S CPTMAP(90723)=110
 S CPTMAP(90724)=88
 S CPTMAP(90725)=26
 S CPTMAP(90726)=90
 S CPTMAP(90727)=23
 S CPTMAP(90728)=19
 S CPTMAP(90730)=85
 S CPTMAP(90731)=45
 S CPTMAP(90732)=33
 S CPTMAP(90733)=32
 S CPTMAP(90734)=136
 S CPTMAP(90734)=114
 S CPTMAP(90735)=39
 S CPTMAP(90736)=121
 S CPTMAP(90737)=17
 S CPTMAP(90738)=134
 S CPTMAP(90740)=44
 S CPTMAP(90741)=14
 S CPTMAP(90743)=43
 S CPTMAP(90744)=08
 S CPTMAP(90745)=42
 S CPTMAP(90746)=43
 S CPTMAP(90747)=44
 S CPTMAP(90748)=51  
 S CPTMAP(90749)=999
 Q
CVXMAP
 S CVXMAP(86)="IG"
 S CVXMAP(87)="IGIV"
 S CVXMAP(27)="botulinum antitoxin"
 S CVXMAP(29)="CMVIG"
 S CVXMAP(12)="diphtheria antitoxin"
 S CVXMAP(30)="HBIG"
 S CVXMAP(34)="RIG"
 S CVXMAP(34)="RIG"
 S CVXMAP(93)="RSV-MAb"
 S CVXMAP(71)="RSV-IGIV"
 S CVXMAP(13)="TIG"
 S CVXMAP(79)="vaccinia immune globulin"
 S CVXMAP(36)="VZIG"
 S CVXMAP(128)="Novel Influenza-H1N1-09, all formulations"
 S CVXMAP(54)="adenovirus, type 4"
 S CVXMAP(55)="adenovirus, type 7"
 S CVXMAP(24)="anthrax"
 S CVXMAP(19)="BCG"
 S CVXMAP(52)="Hep A, adult"
 S CVXMAP(83)="Hep A, ped/adol, 2 dose"
 S CVXMAP(84)="Hep A, ped/adol, 3 dose"
 S CVXMAP(104)="Hep A-Hep B"
 S CVXMAP(148)="Meningococcal C/Y-HIB PRP"
 S CVXMAP(47)="Hib (HbOC)"
 S CVXMAP(46)="Hib (PRP-D)"
 S CVXMAP(49)="Hib (PRP-OMP)"
 S CVXMAP(48)="Hib (PRP-T)"
 S CVXMAP(62)="HPV, quadrivalent"
 S CVXMAP(118)="HPV, bivalent"
 S CVXMAP(144)="influenza, seasonal, intradermal, preservative free"
 S CVXMAP(140)="Influenza, seasonal, injectable, preservative free"
 S CVXMAP(140)="Influenza, seasonal, injectable, preservative free"
 S CVXMAP(141)="Influenza, seasonal, injectable"
 S CVXMAP(141)="Influenza, seasonal, injectable"
 S CVXMAP(16)="influenza, whole"
 S CVXMAP(111)="influenza, live, intranasal"
 S CVXMAP(153)="Influenza, injectable, MDCK, preservative free"
 S CVXMAP(135)="Influenza, high dose seasonal"
 S CVXMAP(128)="Novel Influenza-H1N1-09, all formulations"
 S CVXMAP(125)="Novel Influenza-H1N1-09, nasal"
 S CVXMAP(66)="Lyme disease"
 S CVXMAP(126)="Novel influenza-H1N1-09, preservative-free"
 S CVXMAP(127)="Novel influenza-H1N1-09"
 S CVXMAP(100)="pneumococcal conjugate PCV 7"
 S CVXMAP(133)="Pneumococcal conjugate PCV 13"
 S CVXMAP(149)="influenza, live, intranasal, quadrivalent"
 S CVXMAP(155)="influenza, recombinant, injectable, preservative free"
 S CVXMAP(18)="rabies, intramuscular injection"
 S CVXMAP(40)="rabies, intradermal injection"
 S CVXMAP(116)="rotavirus, pentavalent"
 S CVXMAP(119)="rotavirus, monovalent"
 S CVXMAP(150)="influenza, injectable, quadrivalent, preservative free"
 S CVXMAP(150)="influenza, injectable, quadrivalent, preservative free"
 S CVXMAP(158)="influenza, injectable, quadrivalent"
 S CVXMAP(25)="typhoid, oral"
 S CVXMAP(101)="typhoid, ViCPs"
 S CVXMAP(41)="typhoid, parenteral"
 S CVXMAP(53)="typhoid, parenteral, AKD (U.S. military)"
 S CVXMAP(130)="DTaP-IPV"
 S CVXMAP(120)="DTaP-Hib-IPV"
 S CVXMAP(20)="DTaP"
 S CVXMAP(106)="DTaP, 5 pertussis antigens"
 S CVXMAP(01)="DTP"
 S CVXMAP(28)="DT (pediatric)"
 S CVXMAP(35)="tetanus toxoid, adsorbed"
 S CVXMAP(07)="mumps"
 S CVXMAP(05)="measles"
 S CVXMAP(06)="rubella"
 S CVXMAP(03)="MMR"
 S CVXMAP(04)="M/R"
 S CVXMAP(94)="MMRV"
 S CVXMAP(02)="OPV"
 S CVXMAP(10)="IPV"
 S CVXMAP(113)="Td (adult) preservative free"
 S CVXMAP(91)="typhoid, unspecified formulation"
 S CVXMAP(115)="Tdap"
 S CVXMAP(21)="varicella"
 S CVXMAP(37)="yellow fever"
 S CVXMAP(09)="Td (adult), adsorbed"
 S CVXMAP(22)="DTP-Hib"
 S CVXMAP(50)="DTaP-Hib"
 S CVXMAP(110)="DTaP-Hep B-IPV"
 S CVXMAP(88)="influenza, unspecified formulation"
 S CVXMAP(26)="cholera"
 S CVXMAP(90)="rabies, unspecified formulation"
 S CVXMAP(23)="plague"
 S CVXMAP(19)="BCG"
 S CVXMAP(85)="Hep A, unspecified formulation"
 S CVXMAP(45)="Hep B, unspecified formulation"
 S CVXMAP(33)="pneumococcal polysaccharide PPV23"
 S CVXMAP(32)="meningococcal MPSV4"
 S CVXMAP(136)="Meningococcal MCV4O"
 S CVXMAP(114)="meningococcal MCV4P"
 S CVXMAP(39)="Japanese encephalitis SC"
 S CVXMAP(121)="zoster"
 S CVXMAP(17)="Hib, unspecified formulation"
 S CVXMAP(134)="Japanese Encephalitis IM"
 S CVXMAP(44)="Hep B, dialysis"
 S CVXMAP(14)="IG, unspecified formulation"
 S CVXMAP(43)="Hep B, adult"
 S CVXMAP(08)="Hep B, adolescent or pediatric"
 S CVXMAP(42)="Hep B, adolescent/high risk infant"
 S CVXMAP(43)="Hep B, adult"
 S CVXMAP(44)="Hep B, dialysis"
 S CVXMAP(51)="Hib-Hep B"
 S CVXMAP(999)="unknown"
 S CVXMAP("B","IG",86)=""
 S CVXMAP("B","IGIV",87)=""
 S CVXMAP("B","botulinum antitoxin",27)=""
 S CVXMAP("B","CMVIG",29)=""
 S CVXMAP("B","diphtheria antitoxin",12)=""
 S CVXMAP("B","HBIG",30)=""
 S CVXMAP("B","RIG",34)=""
 S CVXMAP("B","RIG",34)=""
 S CVXMAP("B","RSV-MAb",93)=""
 S CVXMAP("B","RSV-IGIV",71)=""
 S CVXMAP("B","TIG",13)=""
 S CVXMAP("B","vaccinia immune globulin",79)=""
 S CVXMAP("B","VZIG",36)=""
 S CVXMAP("B","Novel Influenza-H1N1-09, all formulations",128)=""
 S CVXMAP("B","adenovirus, type 4",54)=""
 S CVXMAP("B","adenovirus, type 7",55)=""
 S CVXMAP("B","anthrax",24)=""
 S CVXMAP("B","BCG",19)=""
 S CVXMAP("B","Hep A, adult",52)=""
 S CVXMAP("B","Hep A, ped/adol, 2 dose",83)=""
 S CVXMAP("B","Hep A, ped/adol, 3 dose",84)=""
 S CVXMAP("B","Hep A-Hep B",104)=""
 S CVXMAP("B","Meningococcal C/Y-HIB PRP",148)=""
 S CVXMAP("B","Hib (HbOC)",47)=""
 S CVXMAP("B","Hib (PRP-D)",46)=""
 S CVXMAP("B","Hib (PRP-OMP)",49)=""
 S CVXMAP("B","Hib (PRP-T)",48)=""
 S CVXMAP("B","HPV, quadrivalent",62)=""
 S CVXMAP("B","HPV, bivalent",118)=""
 S CVXMAP("B","influenza, seasonal, intradermal, preservative free",144)=""
 S CVXMAP("B","Influenza, seasonal, injectable, preservative free",140)=""
 S CVXMAP("B","Influenza, seasonal, injectable, preservative free",140)=""
 S CVXMAP("B","Influenza, seasonal, injectable",141)=""
 S CVXMAP("B","Influenza, seasonal, injectable",141)=""
 S CVXMAP("B","influenza, whole",16)=""
 S CVXMAP("B","influenza, live, intranasal",111)=""
 S CVXMAP("B","Influenza, injectable, MDCK, preservative free",153)=""
 S CVXMAP("B","Influenza, high dose seasonal",135)=""
 S CVXMAP("B","Novel Influenza-H1N1-09, all formulations",128)=""
 S CVXMAP("B","Novel Influenza-H1N1-09, nasal",125)=""
 S CVXMAP("B","Lyme disease",66)=""
 S CVXMAP("B","Novel influenza-H1N1-09, preservative-free",126)=""
 S CVXMAP("B","Novel influenza-H1N1-09",127)=""
 S CVXMAP("B","pneumococcal conjugate PCV 7",100)=""
 S CVXMAP("B","Pneumococcal conjugate PCV 13",133)=""
 S CVXMAP("B","influenza, live, intranasal, quadrivalent",149)=""
 S CVXMAP("B","influenza, recombinant, injectable, preservative free",155)=""
 S CVXMAP("B","rabies, intramuscular injection",18)=""
 S CVXMAP("B","rabies, intradermal injection",40)=""
 S CVXMAP("B","rotavirus, pentavalent",116)=""
 S CVXMAP("B","rotavirus, monovalent",119)=""
 S CVXMAP("B","influenza, injectable, quadrivalent, preservative free",150)=""
 S CVXMAP("B","influenza, injectable, quadrivalent, preservative free",150)=""
 S CVXMAP("B","influenza, injectable, quadrivalent",158)=""
 S CVXMAP("B","typhoid, oral",25)=""
 S CVXMAP("B","typhoid, ViCPs",101)=""
 S CVXMAP("B","typhoid, parenteral",41)=""
 S CVXMAP("B","typhoid, parenteral, AKD (U.S. military)",53)=""
 S CVXMAP("B","DTaP-IPV",130)=""
 S CVXMAP("B","DTaP-Hib-IPV",120)=""
 S CVXMAP("B","DTaP",20)=""
 S CVXMAP("B","DTaP, 5 pertussis antigens",106)=""
 S CVXMAP("B","DTP",01)=""
 S CVXMAP("B","DT (pediatric)",28)=""
 S CVXMAP("B","tetanus toxoid, adsorbed",35)=""
 S CVXMAP("B","mumps",07)=""
 S CVXMAP("B","measles",05)=""
 S CVXMAP("B","rubella",06)=""
 S CVXMAP("B","MMR",03)=""
 S CVXMAP("B","M/R",04)=""
 S CVXMAP("B","MMRV",94)=""
 S CVXMAP("B","OPV",02)=""
 S CVXMAP("B","IPV",10)=""
 S CVXMAP("B","Td (adult) preservative free",113)=""
 S CVXMAP("B","typhoid, unspecified formulation",91)=""
 S CVXMAP("B","Tdap",115)=""
 S CVXMAP("B","varicella",21)=""
 S CVXMAP("B","yellow fever",37)=""
 S CVXMAP("B","Td (adult), adsorbed",09)=""
 S CVXMAP("B","DTP-Hib",22)=""
 S CVXMAP("B","DTaP-Hib",50)=""
 S CVXMAP("B","DTaP-Hep B-IPV",110)=""
 S CVXMAP("B","influenza, unspecified formulation",88)=""
 S CVXMAP("B","cholera",26)=""
 S CVXMAP("B","rabies, unspecified formulation",90)=""
 S CVXMAP("B","plague",23)=""
 S CVXMAP("B","BCG",19)=""
 S CVXMAP("B","Hep A, unspecified formulation",85)=""
 S CVXMAP("B","Hep B, unspecified formulation",45)=""
 S CVXMAP("B","pneumococcal polysaccharide PPV23",33)=""
 S CVXMAP("B","meningococcal MPSV4",32)=""
 S CVXMAP("B","Meningococcal MCV4O",136)=""
 S CVXMAP("B","meningococcal MCV4P",114)=""
 S CVXMAP("B","Japanese encephalitis SC",39)=""
 S CVXMAP("B","zoster",121)=""
 S CVXMAP("B","Hib, unspecified formulation",17)=""
 S CVXMAP("B","Japanese Encephalitis IM",134)=""
 S CVXMAP("B","Hep B, dialysis",44)=""
 S CVXMAP("B","IG, unspecified formulation",14)=""
 S CVXMAP("B","Hep B, adult",43)=""
 S CVXMAP("B","Hep B, adolescent or pediatric",08)=""
 S CVXMAP("B","Hep B, adolescent/high risk infant",42)=""
 S CVXMAP("B","Hep B, adult",43)=""
 S CVXMAP("B","Hep B, dialysis",44)=""
 S CVXMAP("B","Hib-Hep B",51)=""
 S CVXMAP("B","unknown",999)=""
 Q
 ;
CPTIMAP
 S CPTIMAP(90724)="INFLUENZA"
 S CPTIMAP(90744)="HEPB PED/ADOL-1"
 S CPTIMAP(90744)="HEPB PED/ADOL-2"
 S CPTIMAP(90744)="HEPB PED/ADOL-3"
 S CPTIMAP(90744)="HEPB PED/ADOL-4"
 S CPTIMAP(90701)="DIP.PERT.TET. (DPT) PED 1"
 S CPTIMAP(90701)="DIP.PERT.TET. (DPT) PED 2"
 S CPTIMAP(90701)="DIP.PERT.TET. (DPT) PED 3"
 S CPTIMAP(90701)="DIP.PERT.TET. (DPT) PED 4"
 S CPTIMAP(90701)="DIP.PERT.TET. (DPT) PED 5"
 S CPTIMAP(90645)="HIB PED 1"
 S CPTIMAP(90645)="HIB PED 2"
 S CPTIMAP(90645)="HIB PED 3"
 S CPTIMAP(90645)="HIB PED 4"
 S CPTIMAP(90707)="MEASLESMUMPSRUBELLA PED #1"
 S CPTIMAP(90707)="MEASLESMUMPSRUBELLA PED #2"
 S CPTIMAP(90713)="POLIOVIRUS PED #1"
 S CPTIMAP(90713)="POLIOVIRUS PED #2"
 S CPTIMAP(90713)="POLIOVIRUS PED #3"
 S CPTIMAP(90713)="POLIOVIRUS PED #4"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 1"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 2"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 3"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 4"
 S CPTIMAP(90701)="DIPPERTTET (DPT)"
 S CPTIMAP(90701)="DIPPERTTET (DPT) PED 1"
 S CPTIMAP(90701)="DIPPERTTET (DPT) PED 2"
 S CPTIMAP(90701)="DIPPERTTET (DPT) PED 3"
 S CPTIMAP(90701)="DIPPERTTET (DPT) PED 4"
 S CPTIMAP(90701)="DIPPERTTET (DPT) PED 5"
 S CPTIMAP(90732)="PNEUMOVAX"
 S CPTIMAP(90715)="TETANUS DIPTHERIA AND PERTUSSIS"
 S CPTIMAP(90634)="HEP B PED/ADOL 3 DOSE"
 S CPTIMAP(90633)="HEP A2 PEDS"
 S CPTIMAP(90633)="HEP A1 PEDS"
 S CPTIMAP(90680)="RV 1 PEDS"
 S CPTIMAP(90680)="RV 2 PEDS"
 S CPTIMAP(90680)="RV 3 PEDS"
 S CPTIMAP(90647)="HiB1"
 S CPTIMAP(90647)="HiB2"
 S CPTIMAP(90647)="HiB3"
 S CPTIMAP(90669)="PCV1 PEDS"
 S CPTIMAP(90669)="PCV2 PEDS"
 S CPTIMAP(90669)="PCV3 PEDS"
 S CPTIMAP(90669)="PCV4 PEDS"
 S CPTIMAP(90669)="PCV5 PEDS"
 S CPTIMAP(90716)="VZV1 INFANT"
 S CPTIMAP(90716)="VZV2 INFANT"
 S CPTIMAP(90744)="HEP B1 INFANT"
 S CPTIMAP(90744)="HEP B2 INFANT"
 S CPTIMAP(90744)="HEP B3 INFANT"
 S CPTIMAP(90744)="HEP B4 INFANT"
 S CPTIMAP(90707)="MMR1"
 S CPTIMAP(90713)="IPV1"
 S CPTIMAP(90713)="IPV2"
 S CPTIMAP(90713)="IPV3"
 S CPTIMAP(90713)="IPV4"
 S CPTIMAP(90700)="DTaP1"
 S CPTIMAP(90700)="DTaP2"
 S CPTIMAP(90700)="DTaP3"
 S CPTIMAP(90700)="DTaP4"
 S CPTIMAP(90700)="DTaP5"
 S CPTIMAP(90634)="HEP A3 PEDS"
 S CPTIMAP(90658)="FLU,3 YRS"
 S CPTIMAP("B","INFLUENZA",90724)=""
 S CPTIMAP("B","HEPB, PED/ADOL-1",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-2",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-3",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-4",90744)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 1",90701)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 2",90701)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 3",90701)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 4",90701)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 5",90701)=""
 S CPTIMAP("B","HIB PED 1",90645)=""
 S CPTIMAP("B","HIB PED 2",90645)=""
 S CPTIMAP("B","HIB PED 3",90645)=""
 S CPTIMAP("B","HIB PED 4",90645)=""
 S CPTIMAP("B","MEASLES,MUMPS,RUBELLA PED #1",90707)=""
 S CPTIMAP("B","MEASLES,MUMPS,RUBELLA PED #2",90707)=""
 S CPTIMAP("B","POLIOVIRUS PED #1",90713)=""
 S CPTIMAP("B","POLIOVIRUS PED #2",90713)=""
 S CPTIMAP("B","POLIOVIRUS PED #3",90713)=""
 S CPTIMAP("B","POLIOVIRUS PED #4",90713)=""
 S CPTIMAP("B","PNEUMOCOCCAL PED 1",90670)=""
 S CPTIMAP("B","PNEUMOCOCCAL PED 2",90670)=""
 S CPTIMAP("B","PNEUMOCOCCAL PED 3",90670)=""
 S CPTIMAP("B","PNEUMOCOCCAL PED 4",90670)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT)",90701)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 1",90701)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 2",90701)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 3",90701)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 4",90701)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 5",90701)=""
 S CPTIMAP("B","PNEUMOVAX",90732)=""
 S CPTIMAP("B","TETANUS, DIPTHERIA AND PERTUSSIS",90715)=""
 S CPTIMAP("B","HEP B PED/ADOL 3 DOSE",90634)=""
 S CPTIMAP("B","HEP A2 PEDS",90633)=""
 S CPTIMAP("B","HEP A1 PEDS",90633)=""
 S CPTIMAP("B","RV 1 PEDS",90680)=""
 S CPTIMAP("B","RV 2 PEDS",90680)=""
 S CPTIMAP("B","RV 3 PEDS",90680)=""
 S CPTIMAP("B","HiB1",90647)=""
 S CPTIMAP("B","HiB2",90647)=""
 S CPTIMAP("B","HiB3",90647)=""
 S CPTIMAP("B","PCV1 PEDS",90669)=""
 S CPTIMAP("B","PCV2 PEDS",90669)=""
 S CPTIMAP("B","PCV3 PEDS",90669)=""
 S CPTIMAP("B","PCV4 PEDS",90669)=""
 S CPTIMAP("B","PCV5 PEDS",90669)=""
 S CPTIMAP("B","VZV1 INFANT",90716)=""
 S CPTIMAP("B","VZV2 INFANT",90716)=""
 S CPTIMAP("B","HEP B1 INFANT",90744)=""
 S CPTIMAP("B","HEP B2 INFANT",90744)=""
 S CPTIMAP("B","HEP B3 INFANT",90744)=""
 S CPTIMAP("B","HEP B4 INFANT",90744)=""
 S CPTIMAP("B","MMR1",90707)=""
 S CPTIMAP("B","IPV1",90713)=""
 S CPTIMAP("B","IPV2",90713)=""
 S CPTIMAP("B","IPV3",90713)=""
 S CPTIMAP("B","IPV4",90713)=""
 S CPTIMAP("B","DTaP1",90700)=""
 S CPTIMAP("B","DTaP2",90700)=""
 S CPTIMAP("B","DTaP3",90700)=""
 S CPTIMAP("B","DTaP4",90700)=""
 S CPTIMAP("B","DTaP5",90700)=""
 S CPTIMAP("B","HEP A3 PEDS",90634)=""
 S CPTIMAP("B","FLU,3 YRS",90658)=""
 Q
 ;
CVXIMAP 
 S CVXIMAP(75)="SMALLPOX"
 S CVXIMAP(09)="TETANUS DIPTHERIA (TD-ADULT)"
 S CVXIMAP(01)="DIP.,PERT.,TET. (DPT)"
 S CVXIMAP(35)="TETANUS TOXOID"
 S CVXIMAP(91)="TYPHOID"
 S CVXIMAP(02)="ORAL POLIOVIRUS"
 S CVXIMAP(43)="SWINE FLU BIVAL"
 S CVXIMAP(45)="HEPATITIS B"
 S CVXIMAP(05)="MEASLES"
 S CVXIMAP(88)="INFLUENZA"
 S CVXIMAP(26)="CHOLERA"
 S CVXIMAP(06)="RUBELLA"
 S CVXIMAP(07)="MUMPS"
 S CVXIMAP(19)="BCG"
 S CVXIMAP(03)="MEASLES,MUMPS,RUBELLA (MMR)"
 S CVXIMAP(04)="MEASLES,RUBELLA (MR)"
 S CVXIMAP(33)="PNEUMOCOCCAL"
 S CVXIMAP(37)="YELLOW FEVER"
 S CVXIMAP(131)="TYPHUS"
 S CVXIMAP(90)="RABIES"
 S CVXIMAP(28)="DIPTHERIA-TETANUS (DT-PEDS)"
 S CVXIMAP(17)="INFLUENZA B"
 S CVXIMAP(85)="HEPATITIS A"
 S CVXIMAP(32)="MENINGOCOCCAL"
 S CVXIMAP(39)="ENCEPHALITIS"
 S CVXIMAP(21)="CHICKENPOX"
 S CVXIMAP(106)="DIP-TET-a/PERT"
 S CVXIMAP(38)="RUBELLA, MUMPS"
 S CVXIMAP(22)="DTB/HIB"
 S CVXIMAP(94)="MEA-MUMPS-RUB-VARCELLA"
 S CVXIMAP(23)="PLAGUE"
 S CVXIMAP(14)="GAMMA GLOBULIN"
 S CVXIMAP(54)="ADENOVIRUS,TYPE 4"
 S CVXIMAP(55)="ADENOVIRUS,TYPE 7"
 S CVXIMAP(24)="ANTHRAX,SC"
 S CVXIMAP(19)="BCG,PERCUT"
 S CVXIMAP(26)="CHOLERA, ORAL"
 S CVXIMAP(52)="HEPA ADULT"
 S CVXIMAP(83)="HEPA,PED/ADOL-2"
 S CVXIMAP(84)="HEPA,PED/ADOL-3 DOSE"
 S CVXIMAP(104)="HEPA/HEPB ADULT"
 S CVXIMAP(47)="HIB,HBOC"
 S CVXIMAP(46)="HIB,PRP-D"
 S CVXIMAP(49)="HIB,PRP-OMP"
 S CVXIMAP(48)="HIB,PRP-T"
 S CVXIMAP(141)="FLU,3 YRS"
 S CVXIMAP(16)="FLU,WHOLE"
 S CVXIMAP(111)="FLU,NASAL"
 S CVXIMAP(66)="LYME DISEASE"
 S CVXIMAP(100)="PNEUMOCOCCAL,PED"
 S CVXIMAP(18)="RABIES,IM"
 S CVXIMAP(40)="RABIES,ID"
 S CVXIMAP(116)="ROTOVIRUS,ORAL"
 S CVXIMAP(25)="TYPHOID,ORAL"
 S CVXIMAP(101)="TYPHOID"
 S CVXIMAP(41)="TYPHOID,H-P,SC/ID"
 S CVXIMAP(53)="TYPHOID,AKD,SC"
 S CVXIMAP(44)="HEPB, ILL PAT"
 S CVXIMAP(51)="HEPB/HIB"
 S CVXIMAP(08)="HEPB, PED/ADOL-1"
 S CVXIMAP(08)="HEPB PED/ADOL-2"
 S CVXIMAP(08)="HEPB PED/ADOL-3"
 S CVXIMAP(08)="HEPB PED/ADOL-4"
 S CVXIMAP(20)="DIP.,PERT.,TET. (DPT) PED 1"
 S CVXIMAP(20)="DIP.,PERT.,TET. (DPT) PED 2"
 S CVXIMAP(20)="DIP.,PERT.,TET. (DPT) PED 3"
 S CVXIMAP(20)="DIP.,PERT.,TET. (DPT) PED 4"
 S CVXIMAP(20)="DIP.,PERT.,TET. (DPT) PED 5"
 S CVXIMAP(47)="HIB PED 1"
 S CVXIMAP(47)="HIB PED 2"
 S CVXIMAP(47)="HIB PED 3"
 S CVXIMAP(47)="HIB PED 4"
 S CVXIMAP(03)="MEASLES,MUMPS,RUBELLA PED #1"
 S CVXIMAP(03)="MEASLES,MUMPS,RUBELLA PED #2"
 S CVXIMAP(10)="POLIOVIRUS PED #1"
 S CVXIMAP(10)="POLIOVIRUS PED #2"
 S CVXIMAP(10)="POLIOVIRUS PED #3"
 S CVXIMAP(10)="POLIOVIRUS PED #4"
 S CVXIMAP(100)="PNEUMOCOCCAL PED 1"
 S CVXIMAP(100)="PNEUMOCOCCAL PED 2"
 S CVXIMAP(100)="PNEUMOCOCCAL PED 3"
 S CVXIMAP(100)="PNEUMOCOCCAL PED 4"
 S CVXIMAP(01)="DIP,PERT,TET (DPT)"
 S CVXIMAP(106)="DIP,PERT,TET (DPT) PED 1"
 S CVXIMAP(106)="DIP,PERT,TET (DPT) PED 2"
 S CVXIMAP(106)="DIP,PERT,TET (DPT) PED 3"
 S CVXIMAP(106)="DIP,PERT,TET (DPT) PED 4"
 S CVXIMAP(106)="DIP,PERT,TET (DPT) PED 5"
 S CVXIMAP(33)="PNEUMOVAX"
 S CVXIMAP(115)="TETANUS, DIPTHERIA AND PERTUSSIS"
 S CVXIMAP(08)="HEP B PED/ADOL 3 DOSE"
 S CVXIMAP(106)="DTaP1"
 S CVXIMAP(106)="DTaP2"
 S CVXIMAP(106)="DTaP3"
 S CVXIMAP(106)="DTaP4"
 S CVXIMAP(106)="DTaP5"
 S CVXIMAP(83)="HEP A1 PEDS"
 S CVXIMAP(83)="HEP A2 PEDS"
 S CVXIMAP(84)="HEP A3 PEDS"
 S CVXIMAP(42)="HEP B1 INFANT"
 S CVXIMAP(42)="HEP B2 INFANT"
 S CVXIMAP(42)="HEP B3 INFANT"
 S CVXIMAP(42)="HEP B4 INFANT"
 S CVXIMAP(49)="HiB1"
 S CVXIMAP(49)="HiB2"
 S CVXIMAP(49)="HiB3"
 S CVXIMAP(10)="IPV1"
 S CVXIMAP(10)="IPV2"
 S CVXIMAP(10)="IPV3"
 S CVXIMAP(10)="IPV4"
 S CVXIMAP(03)="MMR1"
 S CVXIMAP(133)="PCV1 PEDS"
 S CVXIMAP(133)="PCV2 PEDS"
 S CVXIMAP(133)="PCV3 PEDS"
 S CVXIMAP(133)="PCV4 PEDS"
 S CVXIMAP(133)="PCV5 PEDS"
 S CVXIMAP(116)="RV 1 PEDS"
 S CVXIMAP(116)="RV 2 PEDS"
 S CVXIMAP(116)="RV 3 PEDS"
 S CVXIMAP(116)="RV 4 PEDS"
 S CVXIMAP(21)="VZV1 INFANT"
 S CVXIMAP(21)="VZV2 INFANT"
 S CVXIMAP(141)="FLU,3 YRS"
 S CVXIMAP("B","SMALLPOX",75)=""
 S CVXIMAP("B","TETANUS DIPTHERIA (TD-ADULT)",09)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT)",01)=""
 S CVXIMAP("B","TETANUS TOXOID",35)=""
 S CVXIMAP("B","TYPHOID",91)=""
 S CVXIMAP("B","ORAL POLIOVIRUS",02)=""
 S CVXIMAP("B","SWINE FLU BIVAL",43)=""
 S CVXIMAP("B","HEPATITIS B",45)=""
 S CVXIMAP("B","MEASLES",05)=""
 S CVXIMAP("B","INFLUENZA",88)=""
 S CVXIMAP("B","CHOLERA",26)=""
 S CVXIMAP("B","RUBELLA",06)=""
 S CVXIMAP("B","MUMPS",07)=""
 S CVXIMAP("B","BCG",19)=""
 S CVXIMAP("B","MEASLES,MUMPS,RUBELLA (MMR)",03)=""
 S CVXIMAP("B","MEASLES,RUBELLA (MR)",04)=""
 S CVXIMAP("B","PNEUMOCOCCAL",33)=""
 S CVXIMAP("B","YELLOW FEVER",37)=""
 S CVXIMAP("B","TYPHUS",131)=""
 S CVXIMAP("B","RABIES",90)=""
 S CVXIMAP("B","DIPTHERIA-TETANUS (DT-PEDS)",28)=""
 S CVXIMAP("B","INFLUENZA B",17)=""
 S CVXIMAP("B","HEPATITIS A",85)=""
 S CVXIMAP("B","MENINGOCOCCAL",32)=""
 S CVXIMAP("B","ENCEPHALITIS",39)=""
 S CVXIMAP("B","CHICKENPOX",21)=""
 S CVXIMAP("B","DIP-TET-a/PERT",106)=""
 S CVXIMAP("B","RUBELLA, MUMPS",38)=""
 S CVXIMAP("B","DTB/HIB",22)=""
 S CVXIMAP("B","MEA-MUMPS-RUB-VARCELLA",94)=""
 S CVXIMAP("B","PLAGUE",23)=""
 S CVXIMAP("B","GAMMA GLOBULIN",14)=""
 S CVXIMAP("B","ADENOVIRUS,TYPE 4",54)=""
 S CVXIMAP("B","ADENOVIRUS,TYPE 7",55)=""
 S CVXIMAP("B","ANTHRAX,SC",24)=""
 S CVXIMAP("B","BCG,PERCUT",19)=""
 S CVXIMAP("B","CHOLERA, ORAL",26)=""
 S CVXIMAP("B","HEPA ADULT",52)=""
 S CVXIMAP("B","HEPA,PED/ADOL-2",83)=""
 S CVXIMAP("B","HEPA,PED/ADOL-3 DOSE",84)=""
 S CVXIMAP("B","HEPA/HEPB ADULT",104)=""
 S CVXIMAP("B","HIB,HBOC",47)=""
 S CVXIMAP("B","HIB,PRP-D",46)=""
 S CVXIMAP("B","HIB,PRP-OMP",49)=""
 S CVXIMAP("B","HIB,PRP-T",48)=""
 S CVXIMAP("B","FLU,3 YRS",141)=""
 S CVXIMAP("B","FLU,WHOLE",16)=""
 S CVXIMAP("B","FLU,NASAL",111)=""
 S CVXIMAP("B","LYME DISEASE",66)=""
 S CVXIMAP("B","PNEUMOCOCCAL,PED",100)=""
 S CVXIMAP("B","RABIES,IM",18)=""
 S CVXIMAP("B","RABIES,ID",40)=""
 S CVXIMAP("B","ROTOVIRUS,ORAL",116)=""
 S CVXIMAP("B","TYPHOID,ORAL",25)=""
 S CVXIMAP("B","TYPHOID",101)=""
 S CVXIMAP("B","TYPHOID,H-P,SC/ID",41)=""
 S CVXIMAP("B","TYPHOID,AKD,SC",53)=""
 S CVXIMAP("B","HEPB, ILL PAT",44)=""
 S CVXIMAP("B","HEPB/HIB",51)=""
 S CVXIMAP("B","HEPB, PED/ADOL-1",08)=""
 S CVXIMAP("B","HEPB PED/ADOL-2",08)=""
 S CVXIMAP("B","HEPB PED/ADOL-3",08)=""
 S CVXIMAP("B","HEPB PED/ADOL-4",08)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT) PED 1",20)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT) PED 2",20)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT) PED 3",20)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT) PED 4",20)=""
 S CVXIMAP("B","DIP.,PERT.,TET. (DPT) PED 5",20)=""
 S CVXIMAP("B","HIB PED 1",47)=""
 S CVXIMAP("B","HIB PED 2",47)=""
 S CVXIMAP("B","HIB PED 3",47)=""
 S CVXIMAP("B","HIB PED 4",47)=""
 S CVXIMAP("B","MEASLES,MUMPS,RUBELLA PED #1",03)=""
 S CVXIMAP("B","MEASLES,MUMPS,RUBELLA PED #2",03)=""
 S CVXIMAP("B","POLIOVIRUS PED #1",10)=""
 S CVXIMAP("B","POLIOVIRUS PED #2",10)=""
 S CVXIMAP("B","POLIOVIRUS PED #3",10)=""
 S CVXIMAP("B","POLIOVIRUS PED #4",10)=""
 S CVXIMAP("B","PNEUMOCOCCAL PED 1",100)=""
 S CVXIMAP("B","PNEUMOCOCCAL PED 2",100)=""
 S CVXIMAP("B","PNEUMOCOCCAL PED 3",100)=""
 S CVXIMAP("B","PNEUMOCOCCAL PED 4",100)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT)",01)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT) PED 1",106)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT) PED 2",106)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT) PED 3",106)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT) PED 4",106)=""
 S CVXIMAP("B","DIP,PERT,TET (DPT) PED 5",106)=""
 S CVXIMAP("B","PNEUMOVAX",33)=""
 S CVXIMAP("B","TETANUS, DIPTHERIA AND PERTUSSIS",115)=""
 S CVXIMAP("B","HEP B PED/ADOL 3 DOSE",08)=""
 S CVXIMAP("B","DTaP1",106)=""
 S CVXIMAP("B","DTaP2",106)=""
 S CVXIMAP("B","DTaP3",106)=""
 S CVXIMAP("B","DTaP4",106)=""
 S CVXIMAP("B","DTaP5",106)=""
 S CVXIMAP("B","HEP A1 PEDS",83)=""
 S CVXIMAP("B","HEP A2 PEDS",83)=""
 S CVXIMAP("B","HEP A3 PEDS",84)=""
 S CVXIMAP("B","HEP B1 INFANT",42)=""
 S CVXIMAP("B","HEP B2 INFANT",42)=""
 S CVXIMAP("B","HEP B3 INFANT",42)=""
 S CVXIMAP("B","HEP B4 INFANT",42)=""
 S CVXIMAP("B","HiB1",49)=""
 S CVXIMAP("B","HiB2",49)=""
 S CVXIMAP("B","HiB3",49)=""
 S CVXIMAP("B","IPV1",10)=""
 S CVXIMAP("B","IPV2",10)=""
 S CVXIMAP("B","IPV3",10)=""
 S CVXIMAP("B","IPV4",10)=""
 S CVXIMAP("B","MMR1",03)=""
 S CVXIMAP("B","PCV1 PEDS",133)=""
 S CVXIMAP("B","PCV2 PEDS",133)=""
 S CVXIMAP("B","PCV3 PEDS",133)=""
 S CVXIMAP("B","PCV4 PEDS",133)=""
 S CVXIMAP("B","PCV5 PEDS",133)=""
 S CVXIMAP("B","RV 1 PEDS",116)=""
 S CVXIMAP("B","RV 2 PEDS",116)=""
 S CVXIMAP("B","RV 3 PEDS",116)=""
 S CVXIMAP("B","RV 4 PEDS",116)=""
 S CVXIMAP("B","VZV1 INFANT",21)=""
 S CVXIMAP("B","VZV2 INFANT",21)=""
 S CVXIMAP("B","FLU,3 YRS",141)=""
 Q
 ;
ALLMAP ; 
 ; create a single map out the above maps
 N CVX,MAP
 S CVX=""
 D CPTMAP
 D CVXMAP
 D CPTIMAP
 D CVXIMAP
 S MAP=$NA(^C0CodeMap("immunizations"))
 K @MAP
 F  S CVX=$O(CVXMAP(CVX)) Q:+CVX=0  D  ;
 . S @MAP@(CVX,"preferredName")=CVXMAP(CVX)
 . S @MAP@(CVX,"CVXcode")=CVX
 . S @MAP@("B",CVXMAP(CVX),CVX)=""
 . D:$G(CVXIMAP(CVX))'="" 
 . . S @MAP@(CVX,"altName",1)=CVXIMAP(CVX)
 . . S @MAP@("B",CVXIMAP(CVX),CVX)=""
 N CPT S CPT=""
 F  S CPT=$O(CPTMAP(CPT)) Q:+CPT=0  D  ;
 . S CVX=CPTMAP(CPT)
 . S @MAP@(CVX,"CPT")=CPT
 . S @MAP@("CPT",CPT,CVX)=""
 ; now do all the extra names in the B index of CVXIMAP
 N ZJ S ZJ=""
 F  S ZJ=$O(CVXIMAP("B",ZJ)) Q:ZJ=""  D  ;
 . S CVX=""
 . F  S CVX=$O(CVXIMAP("B",ZJ,CVX)) Q:CVX=""  D  ;
 . . I $D(@MAP@("B",ZJ)) Q  ; already in the map
 . . S @MAP@(CVX,"altName",$O(@MAP@(CVX,"altName",""),-1)+1)=ZJ
 . . S @MAP@("B",ZJ,CVX)=""
 M G=@MAP
 ZWR G
 Q
 ;
