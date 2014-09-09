C0ISOAP   ; GPL/RCR - Web Service utilities; 8/31/09; 12/08/2010
 ;;0.1;IMMUNIZATIONS FORECASTING;nopatch;noreleasedate;Build 82
 ;Copyright 2009 George Lilly.  Licensed Apache 2
 ;
 ; Modified by Chris Richardson, November, 2010.  George's License is still in force.
 ; Code has been modified to accept very large XML documents and block them logically.
 ; 3101208 - RCR - Correct end of buffer condition, BF=">"
 ;
 QUIT
 ;
 ;  ==========
SOAP(C0RTN,C0PARMS,C0DETAIL) ; MAKES A SOAP CALL FOR BASED ON C0PARMS passed by reference
 ; C0PARMS("payload")=name of location of the xml payload
 ; C0PARMS("url")=url string for the SOAP call
 ; C0PARMS("envelop")=name of the location of the xml soap envelop
 ; C0PARMS("payloadVar")=variable in the envelop for the payload; defaults to "payload"
 ; C0PARMS("return")=format to return:  xml, outline, global -- default is global
 ;
 N C0URL,PAYLOAD,ENVELOP,PLVAR,C0RSLT,HEADER,C0RHDR,C0MIME,XML,C0MIME
 S C0URL=$G(C0PARMS("url"))
 I C0URL="" S C0URL="https://54.235.195.41:8443/opencds-decision-support-service-1.0.0-SNAPSHOT/evaluate"
 S PAYLOAD=$G(C0PARMS("payload"))
 S ENVELOP=$G(C0PARMS("envelop"))
 S C0MIME="content-type: text/soap+xml; charset=utf-8"
 S HEADER(1)="User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3074)"
 S HEADER(2)="Expect: 100-continue"
 S HEADER(3)="Connection: Keep-Alive"
 ;
 ; fudge for testing... get the complete xml from a file
 S XMLLOC=$NA(^TMP("ICE",$J,"XML",1))
 W $$FTG^%ZISH("/home/vista/","ice-test.xml",XMLLOC,4)
 S XMLLOC=$NA(^TMP("ICE",$J,"XML"))
 ;
 N C0IV
 S C0IV("outPayload")=$$ENCODE(XMLLOC)
 S C0IV("hl7OutTime")=$$FMDTOUTC^C0IUTIL(DT)
 D GETNMAP^C0IUTIL("XML","TENVOUT^C0ITEST","C0IV")
 I $G(DEBUG) B
 ;
 K C0RSLT,C0RHDR
 ;
 ; make the soap call
 ;
 S ok=$$httpPOST^%zewdGTM(C0URL,.XML,C0MIME,.C0RSLT,.HEADER,"",.PARM5,.C0RHDR)
 ;
 ; locate and decode the embedded xml
 ;
 K C0RXML
 I $D(C0RSLT(1)) D  ;
 . D CHUNK("C0RXML","C0RSLT",1000) ;RETURN IN AN ARRAY
 . I $G(C0RSLT("RELOC",1,1))'="" D  ; THERE WAS EMBEDED XML
 . . K C0RXML ; THROW AWAY WRAPPER
 . . M C0RXML=C0RSLT("RELOC",1) ; REPLACE WITH EMBEDDED DOCUMENT 
 ;
 I '$D(C0RXML(2)) D  Q  ;
 . W !,"ERROR DETECTED",!
 . ZWR C0RXML
 ;
 I $G(C0PARMS("return")="xml" D  Q  ;
 . M @C0RTN=C0RXML
 ;
 ; call the parser
 N C0IDOCID
 S C0IDOCID=$$PARSE^C0IEXTR("C0RXML","C0IDOC"_$J)
 ;
 I $G(C0PARMS("return")="outline" D  Q  ;
 . ;S GN=$NA(^TMP("SOAPOUT",$J))
 . D show^C0IUTIL(1,C0IDOCID,C0RTN)

 ;
 ; convert the MXML DOM into a mumps array to return
 ;
 D domo3^C0IEXTR("C0RTN")
 ;
 ; return all the artifacts here
 ;
 Q
 ;
ENCODE(ZXML) ; extrinsic which returns a base64 encoding of the XML, which 
 ; is passsed by name
 N ZI,ZS
 S ZI="" S ZS=""
 F  S ZI=$O(@ZXML@(ZI)) Q:ZI=""  D  ;
 . S ZS=ZS_@ZXML@(ZI)
 Q $$ENCODE^RGUTUU(ZS)
 ;
 ; begin old code
 ;
 ; TEMPLATE ID C0TID
 ; RETURNS THE XML RESULT IN C0RTN, PASSED BY NAME
 ; C0VOR IS THE NAME OF A VARIABLE OVERRIDE ARRAY, WHICH IS APPLIED 
 ; BEFORE MAPPING
 ;
 ; ARTIFACTS SECTION
 ; THE FOLLOWING WILL SET UP DEBUGGING ARTIFACTS FOR A POSSIBLE FUTURE
 ; ONLINE DEBUGGER. IF DEBUG=1, VARIABLES CONTAINING INTERMEDIATE RESULTS
 ; WILL NOT BE NEWED.
 I $G(DEBUG)="" N C0V ; CATALOG OF ARTIFACT VARIABLES AND ARRAYS
 S C0V(100,"C0XF","XML TEMPLATE FILE NUMBER")=""
 S C0V(200,"C0HEAD","SOAP HEADER VARIABLE NAME")=""
 S C0V(300,"header","SOAP HEADER")=""
 S C0V(400,"C0MIME","MIME TYPE")=""
 S C0V(500,"C0URL","WS URL")=""
 S C0V(550,"C0PURL","PROXY URL")=""
 S C0V(600,"C0XML","XML VARIABLE NAME")=""
 S C0V(700,"xml","OUTBOUND XML")=""
 S C0V(800,"C0RSLT","RAW XML RESULT RETURNED FROM WEB SERVICE")=""
 S C0V(900,"C0RHDR","RETURNED HEADER")=""
 S C0V(1000,"C0RXML","XML RESULT NORMALIZED")=""
 S C0V(1100,"C0R","REPLY TEMPLATE")=""
 S C0V(1200,"C0REDUX","REDUX STRING")=""
 S C0V(1300,"C0IDX","RESULT XPATH INDEX")=""
 S C0V(1400,"C0ARY","RESULT XPATH ARRAY")=""
 S C0V(1500,"C0NOM","RESULT DOM DOCUMENT NAME")=""
 S C0V(1600,"C0ID","RESULT DOM ID")=""
 N ZI,ZN,ZS
 S ZN=""
 D:$G(DEBUG)=""   ; G NOTNEW ; SKIP NEWING THE VARIABLES IF IN DEBUG
 . S ZI="",ZN="",ZS=""
 . F  S ZI=$O(COPV(ZI)) Q:ZI=""  D
 . . ; S ZJ=$O(C0V(ZI,"")) ; SET UP NEW COMMAND
 . . S ZN=ZN_ZS_$O(C0V(ZI,"")),ZS=","
 . .QUIT
 .QUIT
 I $L(ZN) N @ZN  ; Apply collected NEW Variables 1 time
 ;D INITXPF("C0F") ; SET FILE NUMBER AND PARAMATERS 
 S C0XF=C0F("XML FILE NUMBER") ; FILE NUMBER FOR THE C0 XML TEMPLATE FILE
 D
 . I +C0TID=0 D  Q  ; A STRING WAS PASSED FOR THE TEMPLATE NAME
 . . ;S C0UTID=$$RESTID(C0DUZ,C0TID) ;RESOLVE TEMPLATE IEN FROM NAME
 . .QUIT
 . ;
 . S C0UTID=C0TID ; AN IEN WAS PASSED
 .QUIT
 N xml,template,header
 S C0HEAD=$$GET1^DIQ(C0XF,C0UTID_",",2.2,,"header")
 S C0MIME=$$GET1^DIQ(C0XF,C0UTID_",","MIME TYPE")
 S C0PURL=$$GET1^DIQ(C0XF,C0UTID_",","PROXY SERVER")
 ;S C0URL=$$GET1^DIQ(C0XF,C0UTID_",","URL") ;GPL CHANGE TO USE PROD FLAG
 D SETUP^C0MAIN() ; INITIALIZE C0ACCT IEN OF WS ACCOUNT
 S C0URL=$$WSURL^C0MAIN(C0ACCT) ; RESOLVES PRODUCTION VS TEST
 S C0XML=$$GET1^DIQ(C0XF,C0UTID_",",2.1,,"xml")
 S C0TMPL=$$GET1^DIQ(C0XF,C0UTID_",",3,,"template")
 I C0TMPL="template" D  ; there is a template to process
 . K xml ; going to replace the xml array
 . D EN^C0MAIN("xml","url",C0DUZ,C0DFN,C0UTID,$G(C0VOR))
 . ;N ZZG M ZZG(1)=xml
 . ;S ZDIR=^TMP("C0CCCR","ODIR")
 . ;ZWR ZZG(1)
 . ;W $$OUTPUT^C0CXPATH("xml(1)","GPLTEST-"_ZDFN_".xml",ZDIR)
 .QUIT
 I $G(C0PROXY) S C0URL=C0PURL
 K C0RSLT,C0RHDR
 S ok=$$httpPOST^%zewdGTM(C0URL,.xml,C0MIME,.C0RSLT,.header,"",.gpl5,.C0RHDR)
 K C0RXML
 I $D(GPLTEST) D  ; WAY TO TEST WITH DATA FROM LIVE
 . K C0SRLT ; GPL HACK TO TEST XML FROM LIVE
 . I GPLTEST=1 M C0RSLT=^C0G ; THIS IS THE BIG STATUS EMBEDDED XML FROM LIVE
 . I GPLTEST=2 M C0RSLT=^C0G2 ; THIS IS THE BIG REFILL XML  FROM LIVE 
 . Q
 ;I DUZ=135 D  ; patch so others can use the pullback while i debug - gpl
 ;. ;I $D(C0RSLT(1)) D NORMAL("C0RXML","C0RSLT(1)") ;RETURN XML IN AN ARRAY
 ;. I $D(C0RSLT(1)) D CHUNK("C0RXML","C0RSLT",2000) ;RETURN IN AN ARRAY  
 ;. ; SWITCHED TO CHUNK TO HANDLE ARRAYS OF XML
 ;E  I $D(C0RSLT(1)) D NORMAL("C0RXML","C0RSLT(1)") ;RETURN XML IN AN ARRAY
 ; The following is a temporary fix to keep eRx working while a better 
 ; solution is developed. Template ID 6 is GETMEDS for eRx and it needs
 ; to handle xml files that are too big for NORMAL to handle. So, I wrote
 ; CHUNK which will allow us to handle any size xml file bound for the
 ; EWD parser. 
 ; However, all the other templates in eRx need NORMAL to find the 
 ; embedded XML file in their web service responses. So, we will use
 ; CHUNK for template 6 and continue to use NORMAL for all other templates
 ; we can handle big med lists, but not big web service calls.
 ; What is needed is a better NORMAL (see NORMAL2) or another routine
 ; to detect, extract, and decode embeded XML files of any size. gpl 10/8/10
 ;
 I $D(C0RSLT(1)) D  ;
 . D CHUNK("C0RXML","C0RSLT",1000) ;RETURN IN AN ARRAY
 . I $G(C0RSLT("RELOC",1,1))'="" D  ; THERE WAS EMBEDED XML
 . . K C0RXML ; THROW AWAY WRAPPER
 . . M C0RXML=C0RSLT("RELOC",1) ; REPLACE WITH EMBEDDED DOCUMENT 
 ; D:C0UTID=6 
 ;. I $D(C0RSLT(1)) D CHUNK("C0RXML","C0RSLT",2000) QUIT  ;RETURN IN AN ARRAY
 ;. ;
 ;. I $D(C0RSLT(1)) D NORMAL("C0RXML","C0RSLT(1)") ;RETURN XML IN AN ARRAY
 ;.QUIT
 S C0R=$$GET1^DIQ(C0XF,C0UTID_",",.03,"I") ; REPLY TEMPLATE
 ; reply templates are optional and are specified by populating a
 ; template pointer in field 2.5 of the request template
 ; if specified, the reply template is the source of the REDUX string
 ; used for XPath on the reply, and for UNBIND processing
 ; if no reply template is specified, REDUX is obtained from the request
 ; template and no UNBIND processing is performed. The XPath array is
 ; returned without variable bindings
 I C0R'="" D  ; REPLY TEMPLATE EXISTS
 . I +$G(DEBUG)'=0 W "REPLY TEMPLATE:"_C0R,!
 . S C0TID=C0R ;
 .QUIT
 S C0REDUX=$$GET1^DIQ(C0XF,C0UTID_",",2.5) ;XPATH REDUCTION STRING
 K C0IDX,C0ARY ; XPATH INDEX AND ARRAY VARS
 S C0NOM="C0MEDS"_$J ; DOCUMENT NAME FOR THE DOM
 N ZBIG S ZBIG=0
 ;I C0UTID'=6 D  ;
 ;. S ZBIG=$$TOOBIG("C0RXML") ; PATCH BY GPL WHICH ASSUMES ONLY
 ;. ; TEMPLATE 1 IS A REGULAR XML FILE.. EVERYTHING ELSE HAS EMBEDDED XML
 ;.QUIT
 ;D
 ;. I ZBIG>0 D    QUIT  ; PROBABLY AN EMBEDDED XML DOCUMENT
 ;. . S C0ID=$$UNWRAP("C0RXML",ZBIG,C0NOM) ; DECODE AND PARSE THE EMBEDED XML
 ;. .QUIT
 ;. ;
 ;. ; ELSE
 ;. S C0ID=$$PARSE^C0XEWD("C0RXML",C0NOM) ;CALL THE PARSER
 ;.QUIT
 I $D(GPLTEST) B  ; STOP TO LOOK AT C0RXML
 S C0ID=$$PARSE^C0XEWD("C0RXML",C0NOM) ;CALL THE PARSER
 S C0ID=$$FIRST^C0XEWD($$ID^C0XEWD(C0NOM)) ;ID OF FIRST NODE
 D XPATH^C0XEWD(C0ID,"/","C0IDX","C0ARY","",C0REDUX) ;XPATH GENERATOR
 S OK=$$DELETE^C0XEWD(C0NOM) ; REMOVE PARSED XML FROM THE EWD DOM
 ; Next, call UNBIND to map the reply XPath array to variables
 ; This is only done if a Reply Template is provided
 D DEMUXARY(C0RTN,"C0ARY")
 ; M @C0RTN=C0ARY
 QUIT
 ;
 ;  ===================
TOOBIG(ZXML) ; EXTRINSIC WHICH RETURNS TRUE IF ANY NODE IS OVER 2000 CHARS
 ; RETURNS THE INDEX OF THE LARGE NODE . IF NO LARGE NODE, RETURNS ZERO
 N ZI,ZR
 S ZI=""
 S ZR=0 ; DEFAULT FALSE
 ; First time we go over 1,000, we can stop.
 F  S ZI=$O(@ZXML@(ZI)) Q:ZI=""  I $L(@ZXML@(ZI))>1000 S ZR=ZI Q   ; First oversize stops
 QUIT ZR
 ;
 ; end old code
 ; ===================
NORMAL(OUTXML,INXML) ;NORMALIZES AN XML STRING PASSED BY NAME IN INXML
 ; INTO AN XML ARRAY RETURNED IN OUTXML, ALSO PASSED BY NAME
 ;
 N INBF,ZI,ZN,ZTMP
 S ZN=1,INBF=@INXML
 S @OUTXML@(ZN)=$P(INBF,"><",ZN)_">"
 ; S ZN=ZN+1
 ; F  S @OUTXML@(ZN)="<"_$P(@INXML,"><",ZN) Q:$P(@INXML,"><",ZN+1)=""  D  ;
 ; Should speed up, and not leave a dangling node, and doesn't stop at first NULL
 F ZN=2:1:$L(INBF,"><") S @OUTXML@(ZN)="<"_$P(INBF,"><",ZN)_">"
 ; . ; S ZN=ZN+1 
 ; .QUIT
 QUIT
 ;  ================
 ; The goal of this block has changed a little bit.  Most modern MUMPS engines can
 ; handle a 1,000,000 byte string.  We will use BF to hold hunks that big so that 
 ; we can logically suck up a big hunk of the input to supply the reblocking of the XML
 ; into more logical blocks less than 2000 bytes in length blocks.
 ; A series of signals will be needed, Source (INXML) is exhausted (INEND),
 ; BF is less than 2200 bytes (BFLD, BuFfer reLoaD)
 ; BF is Full (BF contains 998,000 bytes or more, BFULL)
 ; BF and Process is Complete (BFEND)
 ; ZSIZE defaults to 2,000 now, but can be set lower or higher
 ;
CHUNK(OUTXML,INXML,ZSIZE) ; BREAKS INXML INTO ZSIZE BLOCKS
 ; INXML IS AN ARRAY PASSED BY NAME OF STRINGS
 ; OUTXML IS ALSO PASSED BY NAME
 ; IF ZSIZE IS NOT PASSED, 2000 IS USED
 I '$D(ZSIZE) S ZSIZE=2000 ; DEFAULT BLOCK SIZE
 N BF,BFEND,BFLD,BFMAX,BFULL,INEND,ZB,ZI,ZJ,ZK,ZL,ZN
 ; S ZB=ZSIZE-1
 S ZN=1
 S BFMAX=998000
 S ZI=0 ; BEGINNING OF INDEX TO INXML
 S (BFLD,BFEND,BFULL,INEND)=0,BF=""
 ; Major loop loads the buffer, BF, and unloads it into the Output Array
 ;  in 
 F  D  Q:BFEND
 . ; Input LOADER
 . D:'INEND
 . . F  S ZI=$O(@INXML@(ZI)) S INEND=(ZI="")  Q:INEND!BFULL  D   ; LOAD EACH STRING IN INXML
 . . . S BF=BF_@INXML@(ZI)                                       ; ADD TO THE BF STRING
 . . . S BFULL=($L(BF)>BFMAX)
 . . .QUIT
 . .QUIT
 . ;  Full Buffer, BF, now check for Encryption and Unpack
 . D TEST4COD(.BF,"C0RSLT(""RELOC"")")
 . ; Output BREAKER
 . F  Q:BFLD  D   ; ZJ=1:ZSIZE:ZL D  ;
 . . ; ZK=$S(ZJ+ZB<ZL:ZJ+ZB,1:ZL) ; END FOR EXTRACT
 . . F ZK=ZSIZE:-1:0  Q:$E(BF,ZK)=">"
 . . I ZK=0 S ZK=ZSIZE
 . . S @OUTXML@(ZN)=$E(BF,1,ZK) ; PULL OUT THE PIECE
 . . S ZN=ZN+1 ; INCREMENT OUT ARRAY INDEX
 . . S BF=$E(BF,ZK+1,BFMAX)
 . . S BFLD=($L(BF)<(ZSIZE*2))
 . .QUIT
 . S BFEND=(INEND&BFLD)!(">"[BF)
 . I $L(BF)&BFEND S @OUTXML@(ZN)=BF,BF=""
 .QUIT
 QUIT
 ;  ==============
 ; Test for Encryption, extract it and decode it.
TEST4COD(INBF,RELOC) 
 N DBF,I,MSK,TBF,TRG,RCNT
 S RCNT=0
 ;  Segments expected <seg 1>DATA</seg 1><seg 2>DATA</seg 2>
 ;                           ^   ^
 S MSK=""   ; It turns out that some of the characters used were not reliable
 F I=32:1:42,44:1:47,62:1:64,91:1:96 S MSK=MSK_$C(I)
 F I=1:1:$L(INBF,"</")-1 D
 . S TBF=$RE($P($RE($P(INBF,"</",I)),">"))
 . ; Remove sample for testing
 . ; Set the trigger, mostly included to show intent and associated code
 . ;  this could be refined later if determined already obvious enough
 . S TRG=0
 . DO:$L(TBF)>20  ; If $TR doesn't remove anything, then these characters are not there
 . . I (TBF=$TR(TBF,MSK))   S TRG=1
 . . ; I (TBF=$TR(TBF," <->@*!?.,:;#$%&[/|\]={}~")) S TRG=1
 . . ;   <>!"#$%&'()*,-./67:;<>?@[\]^_`fqr{|}~  <<= Ignore 6,7,f,q, and r
 . . ; Now we set up for the DECODE and replacement in INBF
 . . DO:TRG
 . . . N A,C,CC,CV,CCX,K,XBF,T,V
 . . . DO
 . . . . N I
 . . . . S DBF=$$DECODER(TBF)
 . . . .QUIT
 . . . ;
 . . . S CCX=""
 . . . F K=1:1:$L(DBF) S CC=$E(DBF,K) S:CC?1C C=$A(CC),A(C)=$G(A(C))+1
 . . . S C="",V=""
 . . . F  S C=$O(A(C)) Q:C=""  S CCX=CCX_$C(C) S:A(C)>V V=A(C),CV=C
 . . . S CC=$C(CV)
 . . . ;  The "_$C(13,10)_" may need to be generalized, tested and set earlier
 . . . ;    Expand embedded XML in XBF
 . . . F K=1:1:$L(DBF,CC) S T=$P(DBF,CC,K),XBF(K)=$TR(T,CCX)
 . . . S RCNT=RCNT+1
 . . . M @RELOC@(RCNT)=XBF
 . . . ;   Curley braces and = makes it so it won't trigger a second time by retest.                                
 . . . S INBF=$P(INBF,TBF)_"<{REPLACED}="_RCNT_$P(INBF,TBF,2,999)
 . . .QUIT
 . .QUIT
 .QUIT
 ;  Now shorten the INBF so it gets smaller
 ;S INBF=$P(INBF,">",I+1,99999)
 QUIT
 ;  ===================
DECODER(BF) ; Decrypts the Encrypted Strings
 QUIT $$DECODE^RGUTUU(BF)
 ;  ===================
NORMAL2(OUTXML,INXML) ;NORMALIZES AN ARRAY OF XML STRINGS PASSED BY NAME INXML
 ; AS @INXML@(1) TO @INXML@(x) ALL NUMERIC
 ; INTO AN XML ARRAY RETURNED IN OUTXML, ALSO PASSED BY NAME
 ; this routine doesn't work unless the blocks are on xml tag boundaries - gpl
 ; which is hard to do... this routine is left here awaiting future development
 N ZI,ZN,ZJ
 S ZJ=0
 S ZN=1
 F  S ZJ=$O(@INXML@(ZJ)) Q:+ZJ=0  D  ; FOR EACH XML STRING IN ARRAY
 . S @OUTXML@(ZN)=$P(@INXML@(ZJ),"><",ZN)_">"
 . S ZN=ZN+1
 . F  S @OUTXML@(ZN)="<"_$P(@INXML@(ZJ),"><",ZN) Q:$P(@INXML@(ZJ),"><",ZN+1)=""  D  ;
 . . S @OUTXML@(ZN)=@OUTXML@(ZN)_">"
 . . S ZN=ZN+1
 . .QUIT
 .QUIT
 QUIT
 ;  ===============
 ;
UNWRAP(ZXML,ZI,ZNOM) ; EXTRINSIC TO LOCATE, DECODE AND PARSE AN EMBEDED XML DOC
 ; RETURNS THE DOCID OF THE DOM
 N ZS,ZX
 S ZS=$P($P(@ZXML@(ZI),">",2),"<",1) ; PULL OUT THE ENCODED STRING
 S ZX=$$DECODE^RGUTUU(ZS)
 N ZZ
 N ZY S ZY="<?xml version=""1.0"" encoding=""utf-8""?>"
 I $E(ZX,1,5)'="<?xml" S ZZ(1)=ZY_ZX
 E  S ZZ(1)=ZX
 N ZI
 ;F ZI=1:1 Q:$$REDUCE(.ZZ,ZI) ; CHOP THE STRING INTO 4000 CHAR ARRAY
 S ZI=$$REDUCRCR(.ZZ,1) ; RECURSIVE VERSION OF REDUCE
 S G=$$PARSE^C0XEWD("ZZ",C0NOM)
 ; GTM Specific
 ; I G=0 ZWR ^TMP("MXMLERR",$J,*) B
 QUIT G
 ;  =============
REDUCE(ZARY,ZN) ; WILL REDUCE ZARY(ZN) BY CHOPPING IT TO 4000 CHARS
 ; AND PUTTING THE REST IN ZARY(ZN+1)
 ; ZARY IS PASSED BY REFERENCE
 ; EXTRINSIC WHICH RETURNS FALSE IF THERE IS NOTHING TO REDUCE
 I $L(ZARY(ZN))<4001   QUIT 0 ;NOTHING TO REDUCE
 ;
 S ZARY(ZN+1)=$E(ZARY(ZN),4001,$L(ZZ(ZN))) ;BREAK IT UP
 S ZARY(ZN)=$E(ZARY(ZN),1,4000) ;  
 QUIT 1  ;ACTUALLY REDUCED
 ;  ===========
REDUCRCR(ZARY,ZN) ; RECURSIVE VERSION OF REDUCE ABOVE
 ; WILL REDUCE ZARY(ZN) BY CHOPPING IT TO 4000 CHARS
 ; AND PUTTING THE REST IN ZARY(ZN+1)
 ; ZARY IS PASSED BY REFERENCE
 ; EXTRINSIC WHICH RETURNS FALSE IF THERE IS NOTHING TO REDUCE
 I $L(ZARY(ZN))<4001 Q 0 ;NOTHING TO REDUCE
 ; 
 S ZARY(ZN+1)=$E(ZARY(ZN),4001,$L(ZZ(ZN))) ;BREAK IT UP
 S ZARY(ZN)=$E(ZARY(ZN),1,4000) ;  
 I '$$REDUCRCR(.ZARY,ZN+1) Q 1 ; CALL RECURSIVELY
 ;  
 QUIT 1  ;ACTUALLY REDUCED
 ;  ===========
DEMUXARY(OARY,IARY) ;CONVERT AN XPATH ARRAY PASSED AS IARY TO
 ; FORMAT @OARY@(x,xpath) where x is the first multiple
 N ZI,ZJ,ZK,ZL S ZI=""
 F  S ZI=$O(@IARY@(ZI)) Q:ZI=""  D  ;
 . D DEMUX^C0CMXP("ZJ",ZI)
 . S ZK=$P(ZJ,"^",3)
 . S ZK=$RE($P($RE(ZK),"/",1))
 . S ZL=$P(ZJ,"^",1)
 . I ZL="" S ZL=1
 . S @OARY@(ZL,ZK)=@IARY@(ZI)
 .QUIT
 QUIT
 ;
 ; BEGIN OLD CODE - REMOVE AFTER A WHILE WHEN "SOAP" SETTLES DOWN - GPL
 ;s URL="http://preproduction.newcropaccounts.com/InterfaceV7/Doctor.xml"
 ;D GETPOST1(URL) ;
 ;N I,J
 ;S J=$O(gpl(""),-1) ; count of things in gpl
 ;F I=1:1:J S gpl(I)=$$CLEAN^C0EWDU(gpl(I))
 ;I $$GET1^DIQ(113059001,"3,",2.1,,"gpl")'="gpl" D  Q  ; ERR GETTING TEMPLATE
 ;. W "ERROR RETRIEVING TEMPLATE",!
 ;S gpl(1)="RxInput="_gpl(1)
 ; S url="https://preproduction.newcropaccounts.com/InterfaceV7/RxEntry.aspx"
 ; S url="https://secure.newcropaccounts.com/V7/WebServices/Doctor.asmx"
 S url="http://76.110.202.22/v7/WebServices/Doctor.asmx" ;RICHARD'S SOAP PROXY SERVER
 ;S url="http://76.110.202.22/" ;RICHARD'S SOAP PROXY SERVER
 N header
 S ZH=$$GET1^DIQ(113059001,"3,",2.2,,"header")
 ;W $$OUTPUT^C0CXPATH("gpl(1)","NewCropV7-DOCTOR2.xml","/home/dev/CCR/"),!
 S ok=$$httpPOST^%zewdGTM(url,.gpl,"text/xml; charset=utf-8",.gpl6,.header,"",.gpl5,.gpl7)
 ;S ok=$$httpPOST2(.RTN,url,.gpl,"text/xml; charset=utf-8",.gpl6,.header,"",.gpl5,.gpl7)
 ;S ok=$$httpPOST2(.RTN,"https://preproduction.newcropaccounts.com/InterfaceV7/RxEntry.aspx",.gpl,"application/x-www-form-urlencoded",.gpl6,"","",.gpl5,.gpl7)
 zwr gpl6
 QUIT
 ;  ============
PARSE(INXML,INDOC) ;CALL THE EWD PARSER ON INXML, PASSED BY NAME
 ; INDOC IS PASSED AS THE DOCUMENT NAME TO EWD
 ; EXTRINSIC WHICH RETURNS THE DOCID ASSIGNED BY EWD
 N ZR
 M ^CacheTempEWD($j)=@INXML ;
 S ZR=$$parseDocument^%zewdHTMLParser(INDOC)
 K ^CacheTempEWD($j) ;clean up after
 QUIT ZR
 ;  ============
ADDWS(WSNAME,WSTNAM,WSURL) ; ADD A WEB SERVICE TEMPLATE GIVEN A WSDL URL
 ; WSNAME IS THE NAME OF THE WEB SERVICE.. WILL BE LAYGO
 ; WSTNAM IS THE TEMPLATE NAME TO BE ADDED TO BE CREATED AND IMPORTED
 ; WSURL IS THE URL TO THE WSDL DEFINITION OF THE TEMPLATE
 ; WILL FIRST TRY AND FETCH THE XML FROM THE INTERNET USING THE URL
 ; IF SUCCESSFUL, AND THE RETURN XML IS VALID, AN ENTRY IN THE XML TEMPLATE
 ; FILE WILL BE CREATED, WITH THE RAW XML AND DERIVED TEMPLATE XML.
 ; THEN ENTRIES IN THE BINDING SUBFILE WILL BE CREATED FOR EACH XPATH
 ; FINALLY, THE TEMPLATE WILL BE POINTED TO IN THE WEB SERVICE FILE TEMPLATE
 ; MULTIPLE
 N C0WSF S C0WSF=113059003 ; WEB SERVICE FILE
 N C0XTF S C0XTF=113059001 ; XML TEMPLATE FILE
 ; NEVER MIND... WRONG APPROACH
 QUIT
 ;  ===========
TBLD(INT) ; TEMPLATE BUILD OF TEMPLATE INT
 ; want to break this up into pieces -  gpl
 ; THE TEMPLATE NEEDS TO EXIST AND THE DEFINING XML URL MUST BE POPULATED
 ; THEN THE DEFINING XML WILL BE RETRIVED AND STORED INTO THE RAW XML FIELD
 ; IT WILL BE TRANSFORMED INTO A TEMPLATE AND STORED IN THE TEMPLATE FIELD
 ; ALL THE XPATHs WILL BE EXTRACTED AND A BINDING MULTIPLE CREATED FOR EACH
 ; ALL IN ONE SIMPLE ROUTINE
 ; WHAT REMAINS IS FOR MANUAL ENTRY OF THE OTHER FIELDS IN THE BINDINGS
 N C0XTF S C0XTF=113059001 ; XML TEMPLATE FILE
 N C0URL ; URL TO RETRIEVE THE DEFINING XML FOR THE TEMPLATE
 S C0URL=$$GET1^DIQ(C0XTF,INT,2)
 D GET1URL^C0EWD2(C0URL)
 D CLEAN^DILF
 ; D WP^DIE(ZF,ZIEN_",",1,,$NA(@ZOR@(ZD,ZI,"TX"))) ; WP OF ORDER TXT
 D WP^DIE(C0XTF,INT_",",2.1,,$NA(gpl))
 D WP^DIE(C0XTF,INT_",",3,,$NA(gplTEMP))
 ;N C0FDA ; DON'T NEW FOR TESTING
 D ADDXP("gpl2",INT)
 QUIT
 ;  ==========
COMPILE(INTID) ;COMPILE A XML TEMPLATE IN RECORD INTID
 D INITXPF("C0F") ;FILE ARRAY TO POINT TO C0 FILES
 D COMPILE^C0CMXP(INTID,"C0F") ;COMPILE THE TEMPLATE
 QUIT
 ;  ==========
CPBIND(INID,OUTID,FORCE) ; COPIES XPATH BINDINGS FROM TEMPLATE INID
 ; TO TEMPLATE OUTID - ONLY BINDINGS FOR MATCHING XPATHS ARE COPIED
 ; NOTE - REDO THIS TO USE FILEMAN CALLS GPL
 ; WILL NOT OVERWRITE UNLESS FORCE=1
 N FARY,ZI
 S FARY="C0F"
 D INITXPF("C0F")
 I +OUTID=0 S OUTID=$$RESTID^C0CSOAP(OUTID,FARY) ;RESOLVE TEMPLATE NAME
 I +INID=0 S INID=$$RESTID^C0CSOAP(INID,FARY) ;RESOLVE TEMPLATE NAME
 S ZI=0
 F  S ZI=$O(^C0X(OUTID,5,ZI)) Q:+ZI=0  D  ; FOR EACH XPATH IN OUTID
 . W !,ZI," ",^C0X(OUTID,5,ZI,0)
 . S ZN=^C0X(OUTID,5,ZI,0)
 . I $D(^C0X(OUTID,5,ZI,1)) D  ;Q  ;
 . . W !,"ERROR XPATH BINDING EXISTS ",ZI
 . .QUIT
 . D  ; LOOK FOR MATCHING XPATH IN SOURCE
 . . S ZJ=$O(^C0X(INID,5,"B",ZN,""))
 . . ;W " FOUND:",ZJ
 . . I ZJ'="" D  ;
 . . . ;W !,"SETTING ",$G(^C0X(INID,5,ZJ,1))
 . . . S ^C0X(OUTID,5,ZI,0)=^C0X(INID,5,ZJ,0) ;GET BOTH FIELDS
 . . . S ^C0X(OUTID,5,ZI,1)=$G(^C0X(INID,5,ZJ,1))
 . . .QUIT
 . .QUIT
 .QUIT
 QUIT
 ;  ===========
INITXPF(ARY) ;INITIAL XML/XPATH FILE ARRAY
 ;
 S @ARY@("XML FILE NUMBER")=113059001
 S @ARY@("BINDING SUBFILE NUMBER")=113059001.04
 S @ARY@("MIME TYPE")="2.3"
 S @ARY@("PROXY SERVER")="2.4"
 S @ARY@("REPLY TEMPLATE")=".03"
 S @ARY@("TEMPLATE NAME")=".01"
 S @ARY@("TEMPLATE XML")="3"
 S @ARY@("URL")="1"
 S @ARY@("WSDL URL")="2"
 S @ARY@("XML")="2.1"
 S @ARY@("XML HEADER")="2.2"
 S @ARY@("XPATH REDUCTION STRING")="2.5"
 S @ARY@("CCR VARIABLE")="4"
 S @ARY@("FILEMAN FIELD NAME")="1"
 S @ARY@("FILEMAN FIELD NUMBER")="1.2"
 S @ARY@("FILEMAN FILE POINTER")="1.1"
 S @ARY@("INDEXED BY")=".05"
 S @ARY@("SQLI FIELD NAME")="3"
 S @ARY@("VARIABLE NAME")="2"
 QUIT
 ;  =============
ADDXP(INARY,TID) ;ADD XPATH .01 FIELD TO BINDING SUBFILE OF TEMPLATE TID
 N FARY
 S FARY="C0FILES"
 D INITXPF(FARY)
 D ADDXP^C0CMXP(INARY,TID,FARY) ;
 QUIT
 ;  =============
ADDXML(INXML,TEMPID) ;ADD XML TO A TEMPLATE ID TEMPID
 ; INXML IS PASSED BY NAME
 N FARY S FARY="C0FILES"
 D INITXPF(FARY)
 D ADDXML^C0CMXP(INXML,TEMPID,FARY) ;CALL C0C ROUTINE TO ADD TO THE FILE
 QUIT
 ;  =============
ADDTEMP(INXML,TEMPID,FARY) ;ADD XML TEMPLATE TO TEMPLATE RECORD TEMPID FIELD 3
 ;
 N FARY
 S FARY="C0FILES"
 D INITXPF(FARY)
 D ADDTEMP^C0CMXP(INXML,TEMPID,FARY)
 QUIT
 ;  =============
GETXML(OUTXML,TEMPID,FARY) ;GET THE XML FROM TEMPLATE TEMPID
 ;
 N FARY
 S FARY="C0FILES"
 D INITXPF(FARY)
 N C0UTID ; TEMPLATE IEN TO USE
 D GETXML^C0CMXP(OUTXML,TEMPID,FARY)
 QUIT
 ;  =============
GETTEMP(OUTXML,TEMPID,FARY) ;GET THE TEMPLATE XML FROM TEMPLATE TEMPID
 ;
 N FARY
 S FARY="C0FILES"
 D INITXPF(FARY)
 N C0UTID ; TEMPLATE IEN TO USE
 D GETTEMP^C0CMXP(OUTXML,TEMPID,FARY)
 QUIT
 ;  =============
COPYHDR(ZS,ZD) ; COPY XML HEADER FROM RECORD ZS TO ZD
 ; ASSUMES C0 XML TEMPLATE FILE
 N FARY
 D INITXPF("FARY")
 D COPYWP^C0CMXP("XML HEADER",ZS,ZD,"FARY")
 QUIT
 ;  =============
UPDIE   ; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
 K ZERR
 D CLEAN^DILF
 D UPDATE^DIE("","C0FDA","","ZERR")
 I $D(ZERR) D  ;
 . W "ERROR",!
 . ZWR ZERR
 . BREAK  ;  Not production
 .QUIT
 K C0FDA
 QUIT
 ;  =============C0UTID ; TEMPLATE IEN TO USE
 D GETTEMP^C0CMXP(OUTXML,TEMPID,FARY)
 QUIT
 ;  =============
