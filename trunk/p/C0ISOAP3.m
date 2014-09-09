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
 ; C0PARMS("xml")=location of ready to go xml (skip encoding and soap envelop buildling)
 ; C0PARMS("url")=url string for the SOAP call
 ; C0PARMS("payload")=name of location of the xml payload
 ; C0PARMS("envelop")=name of the location of the xml soap envelop
 ; C0PARMS("payloadVarOut")=variable for outgoing payload; default "outPayload"
 ; C0PARMS("payloadVarIn")=incoming tag for payload; default "base64EncodedPayload"
 ; C0PARMS("format")=format of the output: xml,outline,global - default global
 ;
 N C0URL,PAYLOAD,ENVELOP,PLVAR,C0RSLT,HEADER,C0RHDR,C0MIME,XML,XMLLOC,C0MIME
 ;K @C0RTN
 S C0URL=$G(C0PARMS("url"))
 ;I C0URL="" S C0URL="https://54.235.195.41:8443/opencds-decision-support-service-1.0.0-SNAPSHOT/evaluate"
 I C0URL="" S C0URL="http://54.235.195.41:8080/opencds-decision-support-service-1.0.0-SNAPSHOT/evaluate"
 S PAYLOAD=$G(C0PARMS("payload"))
 S OUTPLV=$G(C0PARMS("payloadVarOut"),"outPayload") ; payload variable outgoing
 S INPLV=$G(C0PARMS("payloadVarIn"),"base64EncodedPayload") ; payload tag incoming
 S ENVELOP=$G(C0PARMS("envelop"))
 S C0MIME="content-type: text/soap+xml; charset=utf-8"
 S HEADER(1)="User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3074)"
 S HEADER(2)="Expect: 100-continue"
 S HEADER(3)="Connection: Keep-Alive"
 S XMLLOC=$G(C0PARMS("xml")) ; only set as an override - means skipping payload building
 I XMLLOC'="" M XML=@XMLLOC
 ;
 I XMLLOC="" D  ; no complete xml supplied, build the payload
 . S XMLLOC=$NA(^TMP("ICE",$J,"XML"))
 . K @XMLLOC
 . N C0IV
 . S C0IV(OUTPLV)=$$ENCODE(PAYLOAD)
 . S C0IV("hl7OutTime")=$$FMDTOUTC^C0CUTIL(DT)
 . D GETNMAP^C0IUTIL("XML","TENVOUT^C0ITEST","C0IV")
 . K XML(0)
 . ;M @XMLLOC=XML
 . ;W $$GTF^%ZISH($NA(@XMLLOC@(1)),4,"/home/vista/immu-log/",$$FMDTOUTC^JJOHPPCU($$NOW^XLFDT)_"ice-sending.xml") 
 ;
 ;M XML=@XMLLOC
 K C0RSLT,C0RHDR
 N C0RXML
 ;
 ; make the soap call
 ;
 S ok=$$httpPOST^C0IEWD(C0URL,.XML,C0MIME,.C0RXML,.HEADER) ;,,1) ;for test
 ;S ok=$$httpPOST^%zewdGTM(C0URL,.XML,C0MIME,.C0RSLT,.HEADER,"",.PARM5,.C0RHDR)
 ;
 ; locate and decode the embedded xml
 ;
 N %BEG,%END
 S %BEG="<"_INPLV_">"
 S %END="</"_INPLV_">"
 N ALLXML S ALLXML=""
 N ZI
 S ZI=""
 F  S ZI=$O(C0RXML(ZI)) Q:ZI=""  D  ;
 . S ALLXML=ALLXML_C0RXML(ZI)
 . ;W !,ZI
 I ALLXML'[%BEG D  B  Q  ;
 . W !,"ERROR DETECTED",!
 . ZWR C0RXML
 ;
 N XMLBASE64
 S XMLBASE64=$P($P(ALLXML,%END,1),%BEG,2)
 N RTNXML
 S RTNXML(1)=$$DECODER(XMLBASE64)
 S OK=$$REDUCRCR(.RTNXML,1)
 N RXML S RXML=$NA(^TMP("ICE",$J,"RETURNXML"))
 K @RXML
 M @RXML=RTNXML
 W $$GTF^%ZISH($NA(@RXML@(1)),4,"/home/vista/immu-log/",$$FMDTOUTC^JJOHPPCU($$NOW^XLFDT)_"ice-return.xml") 
 ;
 ;B
 ;K C0RSLT
 ;I $D(C0RXML(1)) D  ;
 ;. D CHUNK("C0RSLT","C0RXML",1000) ;RETURN IN AN ARRAY
 ;. I $G(C0RSLT("RELOC",1,1))'="" D  ; THERE WAS EMBEDED XML
 ;. . K C0RXML ; THROW AWAY WRAPPER
 ;. . M C0RXML=C0RSLT("RELOC",1) ; REPLACE WITH EMBEDDED DOCUMENT 
 ;
 I '$D(C0RXML(2)) D  Q  ;
 . W !,"ERROR DETECTED",!
 . ZWR C0RXML
 ;
 I $G(C0PARMS("format"))="xml" D  Q  ;
 . M @C0RTN=RTNXML
 ;
 ; call the parser
 N C0IDOCID
 S C0IDOCID=$$PARSE^C0IEXTR(RXML,"C0IDOC"_$J)
 ;
 I $G(C0PARMS("format"))="outline" D  Q  ;
 . ;S GN=$NA(^TMP("SOAPOUT",$J))
 . D show^C0IUTIL(1,C0IDOCID,C0RTN)
 ;
 ; convert the MXML DOM into a mumps array to return
 ;
 D domo3^C0IEXTR(C0RTN)
 ;
 ; return all the artifacts here
 ;
 Q
 ;
EXTRACT(C0RXML)
 I $G(INPLV)="" S INPLV="base64EncodedPayload"
 N %BEG,%END
 S %BEG="<"_INPLV_">"
 S %END="</"_INPLV_">"
 N ALLXML S ALLXML=""
 N ZI
 S ZI=""
 F  S ZI=$O(C0RXML(ZI)) Q:ZI=""  D  ;
 . S ALLXML=ALLXML_C0RXML(ZI)
 . ;W !,ZI
 I ALLXML'[%BEG D  Q  ;
 . W !,"ERROR DETECTED",!
 . ZWR C0RXML
 ;
 N XMLBASE64
 S XMLBASE64=$P($P(ALLXML,%END,1),%BEG,2)
 N RTNXML
 S RTNXML(1)=$$DECODER(XMLBASE64)
 S OK=$$REDUCRCR(.RTNXML,1)
 N RXML S RXML=$NA(^TMP("ICE",$J,"RETURNXML"))
 K @RXML
 M @RXML=RTNXML
 W $$GTF^%ZISH($NA(@RXML@(1)),4,"/home/vista/immu-log/",$$FMDTOUTC^JJOHPPCU($$NOW^XLFDT)_"ice-unwrap.xml") 
 Q
 ;
TEST ;
 ; SOAP testing... get the override request xml from a file
 N TESTXML
 S TESTXML=$NA(^TMP("ICE",$J,"XML",1))
 N ZOK
 ;S ZOK=$$FTG^%ZISH("/home/vista/immu-log/","ice-test.xml",TESTXML,4)
 S ZOK=$$FTG^%ZISH("/home/vista/immu-log/","ICE-SOAP-NoImmunizationMessage.xml",TESTXML,4)
 S TESTXML=$NA(^TMP("ICE",$J,"XML")) ; name to pass as xml parameter
 ; correct for overflow produced by GTF^%ZISH
 N ZI S ZI=""
 N XML
 F  S ZI=$O(@TESTXML@(ZI)) Q:ZI=""  D  ;
 . S XML(ZI)=@TESTXML@(ZI)
 . I $D(@TESTXML@(ZI,"OVF")) D  ;
 . . N ZJ S ZJ=""
 . . F  S ZJ=$O(@TESTXML@(ZI,"OVF",ZJ)) Q:ZJ=""  D  ;
 . . . S XML(ZI)=XML(ZI)_@TESTXML@(ZI,"OVF",ZJ)
 K @TESTXML
 M @TESTXML=XML
 D EXTRACT(.XML)
 K XML
 N PARMS
 S PARMS("xml")=TESTXML
 S PARMS("url")="http://54.235.195.41:8080/opencds-decision-support-service-1.0.0-SNAPSHOT/evaluate"
 D SOAP("RETURN",.PARMS)
 ZWR RETURN
 W !,"SUCCESS !"
 Q
 ;
TEST2 ;
 ; SOAP testing... get the request xml from a file, but let SOAP encode and wrap
 S TESTXML=$NA(^TMP("ICE",$J,"TESTXML",1))
 N ZOK
 S ZOK=$$FTG^%ZISH("/home/vista/immu-log/","ice-test.xml",TESTXML,4)
 ;S ZOK=$$FTG^%ZISH("/home/vista/immu-log/","ICE-SOAP-NoImmunizationMessage.xml",TESTXML,4)
 S TESTXML=$NA(^TMP("ICE",$J,"TESTXML")) ; name to pass as xml parameter
 ; correct for overflow produced by GTF^%ZISH
 N ZI S ZI=""
 N XML
 F  S ZI=$O(@TESTXML@(ZI)) Q:ZI=""  D  ;
 . S XML(ZI)=@TESTXML@(ZI)
 . I $D(@TESTXML@(ZI,"OVF")) D  ;
 . . N ZJ S ZJ=""
 . . F  S ZJ=$O(@TESTXML@(ZI,"OVF",ZJ)) Q:ZJ=""  D  ;
 . . . S XML(ZI)=XML(ZI)_@TESTXML@(ZI,"OVF",ZJ)
 K @TESTXML
 M @TESTXML=XML
 K XML
 N PARMS
 S PARMS("payload")=TESTXML
 S PARMS("url")="http://54.235.195.41:8080/opencds-decision-support-service-1.0.0-SNAPSHOT/evaluate"
 D SOAP("RETURN",.PARMS)
 ZWR RETURN
 W !,"SUCCESS !"
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
 S ZARY(ZN+1)=$E(ZARY(ZN),4001,$L(ZARY(ZN))) ;BREAK IT UP
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
