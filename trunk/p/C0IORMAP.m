C0IORMAP  ;
; Pull information re CPT and CVX codes from dEWDrop
 D CPTMAP
 D CVXMAP
 ;D CPTIMAP^C0ITEST
 N IMMCPT,IMMCVX,CVXTXT,X,IMMIEN,I
 S (IMMCPT,IMMCVX,CVXTXT,X,IMMIEN,I)=""
 F I=1:1:141 D
 .;if there is an entry in the CPT Mapping file that is for an Immunization
 .I $P(^PXD(811.1,I,0),U,2)["AUTTIMM" D
 ..;Pick the CPT code out of the file  
 ..S IMMCPT=$P($P(^PXD(811.1,I,0),U,1),";",1)
 ..W I," CPT Code is ",IMMCPT,!  
 ..;If there is a match to an immunization
 ..I $D(CPTMAP(IMMCPT)) D
 ...S IMMCVX=CPTMAP(IMMCPT)
 ...W I," CVX Code is ",IMMCVX,!
 ...I $D(CVXMAP(IMMCVX)) D
 ...S CVXTXT=CVXMAP(IMMCVX)
 ...W I," CVX Text is ",CVXTXT,!
 ...S X=$P(^PXD(811.1,I,0),U,2) 
 ...I $D(X) D
 ....S IMMIEN=$P($P(^PXD(811.1,I,0),U,2),";",1)
 ....W I," IEN of the Immunization is ",IMMIEN,! 
 ....;VOID-IEN of CPT Mapping File;CPT Code;Immunization file Name for the immunization; Short name from Immunization file;CVX Code;proper CVX code sho$
 ....;S NANCY(I)=I_";"_$P($P(^PXD(811.1,I,0),U,1),";",1)_";"_$P(^AUTTIMM(IMMIEN,0),U,1)_";"_$P(^AUTTIMM(IMMIEN,0),U,2)_";"_IMMCVX_";"_CVXTXT_";"
 ....;IEN of CPT Mapping File;Immunization File IEN;Immunization file Name for the immunization; Short name from Immunization file;CPT Code;CVX Code;pr$
 ....S NANCY(I)=I_";"_IMMIEN_";"_$P(^AUTTIMM(IMMIEN,0),U,1)_";"_$P(^AUTTIMM(IMMIEN,0),U,2)_";"_$P($P(^PXD(811.1,I,0),U,1),";",1)_";"_IMMCVX_";"_CVXTXT
 ....W NANCY(I),!
 ....S NANCY1(I)=IMMIEN
 ....W NANCY1(I),!
 ; F I=1:1:131 D  
 ;.; if there is an entry in the CPT mapping file corrensponding to this imminization, QUIT
 Q
 ;
COUNT ; count usage of immunizations
 N ZI,ZJ
 S (ZI,ZJ)=""
 K C0ITBL
 F  S ZI=$O(^AUPNVIMM("B",ZI)) Q:ZI=""  D  ;
 . S ZJ=""
 . F  S ZJ=$O(^AUPNVIMM("B",ZI,ZJ)) Q:ZJ=""  D  ;
 . . N IMM
 . . S IMM=$P(^AUTTIMM(ZI,0),"^",1)
 . . S C0ITBL(ZI,IMM)=$G(C0ITBL(ZI,IMM))+1
 ZWR C0ITBL
 F  S ZI=$O(C0ITBL(ZI)) Q:ZI=""  D  ;
 . S ZJ=$O(C0ITBL(ZI,""))
 . S CNT=C0ITBL(ZI,ZJ)
 . S C0ICNT(CNT,ZI)=ZJ
 ZWR C0ICNT
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