C0IICE	; GPL/NEA - ICE main routines ; 4/24/14 6:03pm
 ;;0.1;C0I IMMUNIZATION FORECASTINE;nopatch;noreleasedate;
 ;Copyright 2013 George Lilly.  Licensed Apache 2
 ;
 Q
 ;
 ;EN(RTN,DFN,PARMS) ;
 ;K WRK
 ;D CPTMAP^C0ITEST
 ;D CVXMAP^C0ITEST
 ;D CPTIMAP^C0ITEST
 ;D CVXIMAP^C0ITEST
 ;D PAYOUTAV^C0ITEST
 ;D PAYOUTBV^C0ITEST
 ;D GET^C0IUTIL("WRK","TPAYOUTC^C0ITEST")
 ;D PAYOUTDV^C0ITEST
 ;D GET^C0IUTIL("WRK","TPAYOUTE^C0ITEST")
 ;K WRK(0)
EN(RTN,DFN,PARMS) ;
 N WRK
 D EN^C0ITEST(.WRK,DFN,.PARMS)
 N ICEIN
 S ICEIN=$NA(^TMP("C0IWRK",$J))
 K @ICEIN
 M @ICEIN=WRK
 N OK
 S OK=$$GTF^%ZISH($NA(^TMP("C0IWRK",$J,1)),3,"/home/vista/immu-log/",$$FMDTOUTC^JJOHPPCU($$NOW^XLFDT)_"ice-test.xml")
 ;N PARMS
 S PARMS("payload")=ICEIN
 D SOAP^C0ISOAP3(.RTN,.PARMS)
 Q
 ;
ICE  ;
 N DFN
 S DFN=$$PAT()
 N PARMS
 S PARMS("format")="outline"
 D EN("RETURN",DFN,.PARMS)
 N GN S GN=$NA(^TMP("ICE",$J,"RETURN"))
 ;d listm^C0IUTIL(GN,"RETURN")
 M @GN=RETURN
 I $G(USEBROWSER) D BROWSE^DDBR(GN,"N","PATIENT "_DFN_" Immunization Forecast")
 Q
 ; 
PAT() ; extrinsic which returns a dfn from the patient selected
 S DIC=2,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; EXIT
 S DFN=$P(Y,U,1) ; SET THE PATIENT
 Q +Y
 ;
wsICE(OUT,FILTER) ; get from web service call
 I '$D(DT) N DIQUIET S DIQUIET=1 D DT^DICRW
 N DFN
 S DFN=$G(FILTER("patientId"))
 I DFN="" Q  ; 
 I $G(FILTER("format"))="" S FILTER("format")="report"
 S OUT=$NA(^TMP("ICEOUT",$J,"RETURN"))
 I $G(FILTER("format"))="xml" S HTTPRSP("mime")="text/xml"
 E   S HTTPRSP("mime")="text/html"
 ;W !,"<!DOCTYPE HTML><html><head></head><body><pre>"
 D EN^C0IICE("GPL",DFN,.FILTER)
 I $G(FILTER("format"))="global" d listm^C0IUTIL(OUT,"GPL")
 I $G(FILTER("format"))="simple" d  ;
 . n RETURN
 . d peel^C0IUTIL("RETURN","GPL")
 . d listm^C0IUTIL(OUT,"RETURN")
 I $G(FILTER("format"))="report" D  ;
 . k HTTPRSP("header")
 . n RETURN
 . d peel^C0IUTIL("RETURN","GPL")
 . D DEMHTML(OUT,"RETURN")
 . D ADDTO^C0IUTIL(OUT,"<hr>")
 . I $D(RETURN("observationResults")) D  ;
 . . D DISHTML(OUT,"RETURN")
 . . D ADDTO^C0IUTIL(OUT,"<hr>")
 . D HISHTML(OUT,"RETURN")
 . D ADDTO^C0IUTIL(OUT,"<hr>")
 . D PROHTML(OUT,"RETURN")
 . I $G(FILTER("debug"))=1 d  ;
 . . D ADDTO^C0IUTIL(OUT,"<pre>")
 . . d listm^C0IUTIL(OUT,"RETURN")
 . . D ADDTO^C0IUTIL(OUT,"</pre>")
 . K @OUT@(0)
 ;E  M @OUT=GPL
 I $G(FILTER("format"))="outline" M @OUT=GPL
 I $G(FILTER("format"))="xml" M @OUT=GPL
 I $G(FILTER("format"))'="xml" D  ;
 . N GTOP,GBOT
 . S GTOP="<!DOCTYPE HTML><html><head></head><body>"
 . I $G(FILTER("format"))="outline" S GTOP=GTOP_"<pre>"
 . I $G(FILTER("format"))="global" S GTOP=GTOP_"<pre>"
 . I $G(FILTER("format"))="simple" S GTOP=GTOP_"<pre>"
 . S @OUT=GTOP
 . S GBOT="</body></html>"
 . I $G(FILTER("format"))="outline" S GBOT="</pre>"_GBOT
 . I $G(FILTER("format"))="global" S GBOT="</pre>"_GBOT
 . I $G(FILTER("format"))="simple" S GBOT="</pre>"_GBOT
 . S @OUT@($O(@OUT@(""),-1)+1)=GBOT
 . D ADDCRLF^VPRJRUT(.OUT)
 ;W "</pre></body></html>"
 q
 ;
TEST ;
 S PARM("format")="xml"
 S PARM("patientId")=11
 d wsICE^C0IICE(.GG,.PARM)
 ZWR GG
 Q
 ;
DISHTML(RTN,ARY) ; generate an html file with tables from the return array. 
 ; both passed by name - disease documentation
 N GARY
 S GARY("TITLE")="ICE Return - Disease Documentation"
 S GARY("HEADER",1)="Date"
 S GARY("HEADER",2)="Disease"
 S GARY("HEADER",3)="Interpretation"
 S GARY("HEADER",4)="Number"
 N GN S GN=$NA(@ARY@("observationResults"))
 N ZI S ZI=""
 F  S ZI=$O(@GN@(ZI)) Q:ZI=""  D  ;
 . N C0IDATE S C0IDATE=$G(@GN@(ZI,"observationEventTime@high"))
 . I C0IDATE="" S C0IDATE=$G(@GN@(ZI,"observationEventTime@low"))
 . ;S GARY(ZI,1)=$$HTMLDT^C0IUTIL(C0IDATE)
 . S GARY(ZI,1)=$E(C0IDATE,5,6)_"/"_$E(C0IDATE,7,8)_"/"_$E(C0IDATE,1,4)
 . ;S GARY(ZI,2)=$G(@GN@(ZI,"observationFocus@displayName"))
 . N CODE S CODE=$G(@GN@(ZI,"observationFocus@code"))
 . I $L(CODE)=1 S CODE="0"_CODE
 . S GARY(ZI,2)=$G(@GN@(ZI,"observationFocus@displayName"))_" ("_CODE_")"
 . S GARY(ZI,3)=$G(@GN@(ZI,"interpretation@displayName"))
 . S GARY(ZI,4)=ZI
 D GENHTML^C0IUTIL(RTN,"GARY")
 K @RTN@(0)
 Q
 ;
HISHTML(RTN,ARY) ; generate an html file with tables from the return array. 
 ; both passed by name
 N GARY
 S GARY("TITLE")="ICE Return - Vaccination History"
 S GARY("HEADER",1)="Date"
 S GARY("HEADER",2)="VistA Vaccine Name"
 S GARY("HEADER",3)="Vaccine (CVX)"
 S GARY("HEADER",4)="Vaccine Group (Group Code)"
 S GARY("HEADER",5)="Dose Number"
 S GARY("HEADER",6)="Validity (isValid)"
 S GARY("HEADER",7)="Interpretation"
 S GARY("HEADER",8)="Number"
 N GN S GN=$NA(@ARY@("Events"))
 N ZI S ZI=""
 F  S ZI=$O(@GN@(ZI)) Q:ZI=""  D  ;
 . N C0IDATE S C0IDATE=$G(@GN@(ZI,"administrationTimeInterval@high"))
 . I C0IDATE="" S C0IDATE=$G(@GN@(ZI,"administrationTimeInterval@low"))
 . ;S GARY(ZI,1)=$$HTMLDT^C0IUTIL(C0IDATE)
 . S GARY(ZI,1)=$E(C0IDATE,5,6)_"/"_$E(C0IDATE,7,8)_"/"_$E(C0IDATE,1,4)
 . S GARY(ZI,2)=$G(@GN@(ZI,"substanceCode@originalText"))
 . N CODE S CODE=$G(@GN@(ZI,"substanceCode@code"))
 . I $L(CODE)=1 S CODE="0"_CODE
 . S CODE="<a href=""https://raw.githubusercontent.com/glilly/ice-testing/master/trunk/ice-config/Vaccines/"_CODE_".xml"" target=""_blank"">"_CODE_"</a>"
 . S GARY(ZI,3)=$G(@GN@(ZI,"substanceCode@displayName"))_" ("_CODE_")"
 . N GCODE S GCODE=$G(@GN@(ZI,"observationFocus@code"))
 . S GCODE="<a href=""https://raw.githubusercontent.com/glilly/ice-testing/master/trunk/ice-config/VaccineGroups/"_GCODE_".xml"" target=""_blank"">"_GCODE_"</a>"
 . N GGRP S GGRP=$G(@GN@(ZI,"observationFocus@displayName"))
 . S GGRP=$P($P(GGRP,"(",2),")",1)
 . S GARY(ZI,4)=GGRP_" ("_GCODE_")"
 . S GARY(ZI,5)=$G(@GN@(ZI,"doseNumber@value"))
 . N ISVALID S ISVALID=$G(@GN@(ZI,"isValid@value"))
 . S GARY(ZI,6)=$G(@GN@(ZI,"concept@displayName"))_" ("_ISVALID_")"
 . S GARY(ZI,7)=$G(@GN@(ZI,"interpretation@displayName"))
 . S GARY(ZI,8)=ZI
 D GENHTML^C0IUTIL(RTN,"GARY")
 K @RTN@(0)
 Q
 ;
PROHTML(RTN,ARY) ; generate a proposed vaccination html table from the return array. 
 ; both passed by name
 N GARY
 S GARY("TITLE")="ICE Return - Proposed Vaccinations"
 S GARY("HEADER",1)="Proposed Date"
 S GARY("HEADER",2)="Vaccine Group (Group Code)"
 S GARY("HEADER",3)="Recommendation"
 S GARY("HEADER",4)="Interpretation"
 S GARY("HEADER",5)="Number"
 N GN S GN=$NA(@ARY@("Proposals"))
 N ZI S ZI=""
 F  S ZI=$O(@GN@(ZI)) Q:ZI=""  D  ;
 . N C0IDATE S C0IDATE=$G(@GN@(ZI,"proposedAdministrationTimeInterval@high"))
 . I C0IDATE="" S C0IDATE=$G(@GN@(ZI,"proposedAdministrationTimeInterval@low"))
 . ;S GARY(ZI,1)=$$HTMLDT^C0IUTIL(C0IDATE)
 . S GARY(ZI,1)=$E(C0IDATE,5,6)_"/"_$E(C0IDATE,7,8)_"/"_$E(C0IDATE,1,4)
 . N CODE S CODE=$G(@GN@(ZI,"substanceCode@code"))
 . I $L(CODE)=1 S CODE="0"_CODE
 . N GGRP S GGRP=$G(@GN@(ZI,"substanceCode@displayName"))
 . S GGRP=$P($P(GGRP,"(",2),")",1)
 . S CODE="<a href=""https://raw.githubusercontent.com/glilly/ice-testing/master/trunk/ice-config/VaccineGroups/"_CODE_".xml"" target=""_blank"">"_CODE_"</a>"
 . S GARY(ZI,2)=GGRP_" ("_CODE_")"
 . S GARY(ZI,3)=$G(@GN@(ZI,"concept@displayName"))
 . N TERP S TERP=$G(@GN@(ZI,"interpretation@code"))
 . S GARY(ZI,4)=$G(@GN@(ZI,"interpretation@displayName"))_" ("_TERP_")"
 . S GARY(ZI,5)=ZI
 D GENHTML^C0IUTIL(RTN,"GARY")
 K @RTN@(0)
 Q
 ;
DEMHTML(RTN,ARY) ; generate an html demographics table from the return array. 
 ; both passed by name
 N GARY
 S GARY("TITLE")="ICE Return - Demographics"
 S GARY("HEADER",1)="Date of Birth"
 S GARY("HEADER",2)="Gender"
 S GARY("HEADER",3)="Patient ID"
 N C0IDATE S C0IDATE=$G(@ARY@("demographics","birthTime@value"))
 S GARY(1,1)=$E(C0IDATE,5,6)_"/"_$E(C0IDATE,7,8)_"/"_$E(C0IDATE,1,4)
 S GARY(2,1)=$G(@ARY@("demographics","gender@displayName"))
 S GARY(3,1)=$G(FILTER("patientId"))
 D GENVHTML^C0IUTIL(RTN,"GARY")
 K @RTN@(0)
 Q
 ;
