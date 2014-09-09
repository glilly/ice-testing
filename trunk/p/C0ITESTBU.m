C0ITEST ; GPL/NEA - Immunizations Forecasting Routine ;05/03/14  17:05
 ;;0.1;Immunizations Forecasting;nopatch;noreleasedate;
 ;
 ; License Apache 2
 ; 
 Q
 ;
TEST1 ;
 S DFN=29
 K WRK
 D CPTMAP
 D CVXMAP
 D CPTIMAP
 D PAYOUTAV
 ;D PAYOUTBV
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
 S C0IARY("hl7OutTime")=$$FMDTOUTC^C0IUTIL(DT)
 D GETNMAP^C0IUTIL("WRK","TENVOUT^C0ITEST","C0IARY")
 Q
TPAYOUTA ; First part of payload message with Sex and DOB and a UUID variables
 ;;<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
 ;;<ns4:cdsInput xmlns:ns2="org.opencds" xmlns:ns3="org.opencds.vmr.v1_0.schema.vmr"
 ;;xmlns:ns4="org.opencds.vmr.v1_0.schema.cdsinput" xmlns:ns5="org.opencds.vmr.v1_0.schema.cdsoutput">
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
 ;;<gender code="@@genderCode@@" codeSystem="2.16.840.1.113883.5.1" displayName="genderName" originalText="@@genderCode@@"/>
 ;;</demographics>
 ;;<clinicalStatements>
 Q
 ;
PAYOUTAV ; setting payload variables sex, DOB and UUID for the first section (PAYOUTA)
 K COIPOA
 S X=$$GET1^DIQ(2,DFN,"DOB","I")
 S C0IPOA("UUID0")=$$UUID^C0IUTIL
 S C0IPOA("DOB")=$$FMDTOUTC^C0IUTIL(X)
 S C0IPOA("genderCode")=$$GET1^DIQ(2,DFN,"SEX","I")
 I C0IPOA("genderCode")="M" S C0IPOA("genderName")="Male"
 I C0IPOA("genderCode")="F" S C0IPOA("genderName")="Female"
 I C0IPOA("genderCode")="UN" S C0IPOA("genderName")="Undifferentiated" ; ICE term, not VISTA  VistA allow M F only.P
 D GETNMAP^C0IUTIL("WRK","TPAYOUTA^C0ITEST","C0IPOA") 
 Q
 ;
TPAYOUTB ;
 ;;; Disease an immunity section which is optional. the DISEASE_DOCUMENTED and IS_IMMUNE
 ;;;Optional section awaiting more info skip for now
 ;;;Hep A: 070.1
 ;;;Hep B: 070.3
 ;;;Measles: 055.9
 ;;;Mumps: 072.9
 ;;;Rubella: 056.9
 ;;;Varicella: 052.9
 ;;;<observationResults>
 ;;;<observationResult>
 ;;;<templateId root="2.16.840.1.113883.3.795.11.6.3.1"/>
 ;;;<id root="@@UUID1@@"/>
 ;;;<observationFocus code="@@codeICD9@@" codeSystem="2.16.840.1.113883.6.103" displayName="@@codeName@@" originalText="@@codeICD9@@"/>
 ;;;<observationEventTime low="@@timeProblem" high="@@timeProblem@@"/>
 ;;;<observationValue>
 ;;;<concept code="DISEASE_DOCUMENTED" codeSystem="2.16.840.1.113883.3.795.12.100.8" displayName="Disease Documented" originalText="DISEASE_DOCUMENTED"/>                                 ;;;</observationValue>
 ;;;<interpretation code="IS_IMMUNE" codeSystem="2.16.840.1.113883.3.795.12.100.9" displayName="Is Immune" originalText="IS_IMMUNE"
 ;;;</observationResult>
 ;;;</observationResults>
 Q
 ;
PAYOUTBV ;
 ;Placeholder for logic and variables for populating the DISEASE_DOCUMENTED and IS_IMMUNE
 ;Diseases Hep A, Hep B, Measles, Mumps, Rubella, Varicella only as of 5/2014, 
 D GETNMAP^C0IUTIL("WRK","TPAYOUTB^C0ITEST","C0IPOA")
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
 .N I S I=""
 .F I=1:1:T D
 ..N CPTIMM,CVXCODE,ADMDATE,IMMNAME,IMMCVX
 ..S C0IPOA("UUID1")=$$UUID^C0IUTIL 
 ..S C0IPOA("UUID2")=$$UUID^C0IUTIL
 ..S C0IPOA("CVXCode")=""
 ..S C0IPOA("CVXName")=""
 ..S C0IPOA("ORIGName")=""
 ..S C0IPOA("admDate")=""
 ..W "I is ",I,!
 ..I $D(G("results","immunizations",I,"immunization","cpt@code")) D 
 ...; If there is a CPT code, use that to get the CVX code and the proper CVC code name
 ...N CPTIMM,CVXCODE,ADMDATE 
 ...S CPTIMM="" S CVXCODE="" S ADMDATE=""
 ...S CPTIMM=$G(G("results","immunizations",I,"immunization","cpt@code"))
 ...W "CPTIMM from G is ",CPTIMM,!
 ...S CVXCODE=CPTMAP(CPTIMM)
 ...W "The CVX code for this immunizaton with a CPT code is ",CVXCODE,!
 ...I CVXCODE'="" D  Q
 ....; If you found the CVXCode by the CPT code, add the XML to the array and QUIT  
 ....S C0IPOA("CVXCode")=CVXCODE
 ....S C0IPOA("CVXName")=CVXMAP(CVXCODE)
 ....S C0IPOA("ORIGName")=$G(G("results","immunizations",I,"immunization","name@value"))
 ....S ADMDATE=$G(G("results","immunizations",I,"immunization","administered@value"))
 ....S C0IPOA("admDate")=$$FMDTOUTC^C0IUTIL(ADMDATE)
 ....D GETNMAP^C0IUTIL("WRK","TPAYOUTD^C0ITEST","C0IPOA")
 ..I '$D(G("results","immunizations",I,"immunization","cpt@code")) D
 ...; if there is no CPT code, try to look it up by the proper CVX code name
 ...N IMMNAME,IMMCVX,IMMCPT,CVXCODE,ADMDATE
 ...S IMMNAME="" 
 ...S IMMNAME=$G(G("results","immunizations",I,"immunization","name@value"))
 ...W "IMMNAME in the no CPT look up by proper CVX code name is ",IMMNAME,!
 ...S IMMCVX=$O(CVXMAP("B",IMMNAME,""))
 ...W "IMMCVX for this vaccine with a proper name is ",IMMCVX,!
 ...I IMMCVX="" D
 ....; If the CVX code is not found by the proper CVX code name, try the lookup in the CPTIMAP section by the
 ....; original name which are odd names in the Immunization file.
 ....; Should probably use PCE Code Map for this when it is fixed
 ....N IMMCPG,CVXCODE,IMMNAME,IMMCVX,ADMDATE
 ....S IMMCPT="" S CVXCODE="" S IMMNAME="" S IMMCVX="" S ADMDATE=""
 ....S IMMNAME=$G(G("results","immunizations",I,"immunization","name@value")) 
 ....W "The IMMNAME for this immunization without a proper name is ",IMMNAME,!
 ....S IMMCPT=$O(CPTIMAP("B",IMMNAME,""))
 ....W "The CPT code for IMMNAME is ",IMMCPT,!
 ....S CVXCODE=CPTMAP(IMMCPT)
 ....I CVXCODE'="" D  Q
 .....; If there is still no CVX code found, record and error and quit
 .....S ZTXT=$G(G("results","immunizations",I,"immunization","id@value"))
 .....D OUTLOG("ERROR-Missing CVX or Incorrect Name for IEN="_ZTXT)
 ....E  D
 .....; Else, if you have found a CVX code, then write the XML to the array and QUIT
 .....S C0IPOA("CVXCode")=CVXCODE
 .....S C0IPOA("CVXName")=CVXMAP(CVXCODE)
 .....S C0IPOA("ORIGName")=$G(G("results","immunizations",I,"immunization","name@value"))
 .....S ADMDATE=$G(G("results","immunizations",I,"immunization","administered@value"))
 .....S C0IPOA("admDate")=$$FMDTOUTC^C0IUTIL(ADMDATE)
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
 Q
 ;
CPTIMAP
 S CPTIMAP(90724)="INFLUENZA"
 S CPTIMAP(90744)="HEPB PED/ADOL-1"
 S CPTIMAP(90744)="HEPB PED/ADOL-2"
 S CPTIMAP(90744)="HEPB PED/ADOL-3"
 S CPTIMAP(90744)="HEPB PED/ADOL-4"
 S CPTIMAP(90700)="DIP.PERT.TET. (DPT) PED 1"
 S CPTIMAP(90700)="DIP.PERT.TET. (DPT) PED 2"
 S CPTIMAP(90700)="DIP.PERT.TET. (DPT) PED 3"
 S CPTIMAP(90700)="DIP.PERT.TET. (DPT) PED 4"
 S CPTIMAP(90700)="DIP.PERT.TET. (DPT) PED 5"
 S CPTIMAP(90645)="HIB PED 1"
 S CPTIMAP(90645)="HIB PED 2"
 S CPTIMAP(90645)="HIB PED 3"
 S CPTIMAP(90645)="HIB PED 4"
 S CPTIMAP(90707)="MEASLES,MUMPS,RUBELLA PED #1"
 S CPTIMAP(90707)="MEASLES,MUMPS,RUBELLA PED #2"
 S CPTIMAP(90713)="POLIOVIRUS PED #1"
 S CPTIMAP(90713)="POLIOVIRUS PED #2"
 S CPTIMAP(90713)="POLIOVIRUS PED #3"
 S CPTIMAP(90713)="POLIOVIRUS PED #4"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 1"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 2"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 3"
 S CPTIMAP(90670)="PNEUMOCOCCAL PED 4"
 S CPTIMAP(90701)="DIP,PERT,TET (DPT)"
 S CPTIMAP(90700)="DIP,PERT,TET (DPT) PED 1"
 S CPTIMAP(90700)="DIP,PERT,TET (DPT) PED 2"
 S CPTIMAP(90700)="DIP,PERT,TET (DPT) PED 3"
 S CPTIMAP(90700)="DIP,PERT,TET (DPT) PED 4"
 S CPTIMAP(90700)="DIP,PERT,TET (DPT) PED 5"
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
 S CPTIMAP(90670)="PCV1 PEDS"
 S CPTIMAP(90670)="PCV2 PEDS"
 S CPTIMAP(90670)="PCV3 PEDS"
 S CPTIMAP(90670)="PCV4 PEDS"
 S CPTIMAP(90670)="PCV5 PEDS"
 S CPTIMAP(90716)="VZV1 INFANT"
 S CPTIMAP(90716)="VZV2 INFANT"
 S CPTIMAP(90745)="HEP B1 INFANT"
 S CPTIMAP(90745)="HEP B2 INFANT"
 S CPTIMAP(90745)="HEP B3 INFANT"
 S CPTIMAP(90745)="HEP B4 INFANT"
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
 S CPTIMAP("B","INFLUENZA",90724)=""
 S CPTIMAP("B","HEPB,PED/ADOL-1",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-2",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-3",90744)=""
 S CPTIMAP("B","HEPB PED/ADOL-4",90744)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 1",90700)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 2",90700)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 3",90700)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 4",90700)=""
 S CPTIMAP("B","DIP.,PERT.,TET. (DPT) PED 5",90700)=""
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
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 1",90700)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 2",90700)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 3",90700)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 4",90700)=""
 S CPTIMAP("B","DIP,PERT,TET (DPT) PED 5",90700)=""
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
 S CPTIMAP("B","PCV1 PEDS",90670)=""
 S CPTIMAP("B","PCV2 PEDS",90670)=""
 S CPTIMAP("B","PCV3 PEDS",90670)=""
 S CPTIMAP("B","PCV4 PEDS",90670)=""
 S CPTIMAP("B","PCV5 PEDS",90670)=""
 S CPTIMAP("B","VZV1 INFANT",90716)=""
 S CPTIMAP("B","VZV2 INFANT",90716)=""
 S CPTIMAP("B","HEP B1 INFANT",90745)=""
 S CPTIMAP("B","HEP B2 INFANT",90745)=""
 S CPTIMAP("B","HEP B3 INFANT",90745)=""
 S CPTIMAP("B","HEP B4 INFANT",90745)=""
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
 Q
 ;
