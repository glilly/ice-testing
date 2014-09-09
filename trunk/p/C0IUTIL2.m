C0IUTIL ; GPL/NEA - Immunizations Forecasting Utilities ;05/03/14  17:05
 ;;0.1;Immunizations Forecasting;nopatch;noreleasedate;
 ;
 ; License Apache 2
 ; 
 Q
 ;
GETNMAP(OUTXML,INXML,IARY) ; Retrieves XML stored in Mumps routines and maps
 ; them using IARY, passed by name. Maps use @@var@@ protocol
 ; with @IARY@("var")=value for the map values
 ; OUTXML is passed by name and will hold the result
 ; INXML is the name of the storage place ie "HEADER^JJOHPPC2"
 N GTAG,GRT,GI
 S GTAG=$P(INXML,"^",1)
 S GRT=$P(INXML,"^",2)
 ; first get all of the lines of the XML
 N TXML ; temp var for xml
 S GX=1
 S GN=1
 F  S GI=GTAG_"+"_GX_"^"_GRT  Q:$T(@GI)'[";;"  D  ;
 . S GX=GX+1
 . N LN S LN=$P($T(@GI),";;",2)
 . I $E(LN,1)=";" Q  ; skip over comments
 . S TXML(GN)=LN
 . I $G(CCDADEBUG) W !,GN," ",TXML(GN)
 . S GN=GN+1
 ; next call MAP to resolve mappings and place result directly in OUTXML
 ; if OUTXML has contents already, add the result to the end and update the count (0)
 I $D(@OUTXML@(1)) D  ;
 . N TXML2
 . D MAP^MXMLTMPL("TXML",IARY,"TXML2")
 . S GI=0
 . F  S GI=$O(TXML2(GI)) Q:+GI=0  S @OUTXML@($O(@OUTXML@(""),-1)+1)=TXML2(GI)
 . S @OUTXML@(0)=$O(@OUTXML@(""),-1)
 E  D MAP^MXMLTMPL("TXML",IARY,OUTXML)
 Q
 ;
GET(OUTXML,INXML) ; GET ONLY Retrieves XML stored in Mumps routines 
 ; OUTXML is passed by name and will hold the result
 ; INXML is the name of the storage place ie "HEADER^JJOHPPC2"
 N GTAG,GRT,GI
 S GTAG=$P(INXML,"^",1)
 S GRT=$P(INXML,"^",2)
 ; get all of the lines of the XML
 S GX=1
 S GN=1
 F  S GI=GTAG_"+"_GX_"^"_GRT  Q:$T(@GI)'[";;"  D  ;
 . S GX=GX+1
 . N LN S LN=$P($T(@GI),";;",2)
 . I $E(LN,1)=";" Q  ; skip over comments
 . S @OUTXML@($O(@OUTXML@(""),-1)+1)=LN
 . S @OUTXML@(0)=$O(@OUTXML@(""),-1)
 . I $G(CCDADEBUG) W !,GN," ",@OUTXML@(GN)
 . S GN=GN+1
 Q
 ;
TEST ;
 N GV S GV("hl7OutTime")=$$FMDTOUTC^C0IUTIL(DT)
 K G
 D GETNMAP("G","TENVOUT^C0ITEST","GV")
 ZWR G
 Q
 ;
OUTLOG(ZTXT) ; add text to the log
 I '$D(C0LOGLOC) S C0LOGLOC=$NA(^TMP("C0I",$J,"LOG"))
 N LN S LN=$O(@C0LOGLOC@(""),-1)+1
 S @C0LOGLOC@(LN)=ZTXT
 Q
 ;
LOGARY(ARY) ; LOG AN ARRAY
 N II S II=""
 F  S II=$O(@ARY@(II)) Q:II=""  D  ;
 . D OUTLOG(ARY_" "_II_" = "_$G(@ARY@(II)))
 Q
 ;
UUID()	 ; thanks to Wally for this.
 N R,I,J,N 
 S N="",R="" F  S N=N_$R(100000) Q:$L(N)>64 
 F I=1:2:64 S R=R_$E("0123456789abcdef",($E(N,I,I+1)#16+1)) 
 Q $E(R,1,8)_"-"_$E(R,9,12)_"-4"_$E(R,14,16)_"-"_$E("89ab",$E(N,17)#4+1)_$E(R,18,20)_"-"_$E(R,21,32)
 ;
 ; the following was borrowed from the C0CUTIL and adapted
 ;
FMDTOCDA(DATE,FORMAT) ; Convert Fileman Date to UTC Date Format; PUBLIC; Extrinsic
 ; FORMAT is Format of Date. Can be either D (Day) or DT (Date and Time)
 ; If not passed, or passed incorrectly, it's assumed that it is D.
 ; FM Date format is "YYYMMDD.HHMMSS" HHMMSS may not be supplied.
 ; UTC date is formatted as follows: YYYY-MM-DDThh:mm:ss_offsetfromUTC
 ; UTC, Year, Month, Day, Hours, Minutes, Seconds, Time offset (obtained from Mailman Site Parameters)
 N UTC,Y,M,D,H,MM,S,OFF
 S Y=1700+$E(DATE,1,3)
 S M=$E(DATE,4,5)
 S D=$E(DATE,6,7)
 S H=$E(DATE,9,10)
 I $L(H)=1 S H="0"_H
 S MM=$E(DATE,11,12)
 I $L(MM)=1 S MM="0"_MM
 S S=$E(DATE,13,14)
 I $L(S)=1 S S="0"_S
 S OFF=$$TZ^XLFDT ; See Kernel Manual for documentation.
 S OFFS=$E(OFF,1,1)
 S OFF0=$TR(OFF,"+-")
 S OFF1=$E(OFF0+10000,2,3)
 S OFF2=$E(OFF0+10000,4,5)
 ;S OFF=OFFS_OFF1_":"_OFF2
 S OFF=OFFS_OFF1_OFF2
 ;S OFF2=$E(OFF,1,2) ;
 ;S OFF2=$E(100+OFF2,2,3) ; GPL 11/08 CHANGED TO -05:00 FORMAT
 ;S OFF3=$E(OFF,3,4) ;MINUTES
 ;S OFF=$S(OFF2="":"00",0:"00",1:OFF2)_"."_$S(OFF3="":"00",1:OFF3)
 ; If H, MM and S are empty, it means that the FM date didn't supply the time.
 ; In this case, set H, MM and S to "00"
 ; S:('$L(H)&'$L(MM)&'$L(S)) (H,MM,S)="00" ; IF ONLY SOME ARE MISSING?
 S:'$L(H) H="00"
 S:'$L(MM) MM="00"
 S:'$L(S) S="00"
 S UTC=Y_M_D_H_MM_$S(S="":"00",1:S)_OFF ; Skip's code to fix hanging colon if no seconds
 ;S UTC=Y_"-"_M_"-"_D_"T"_H_":"_MM_$S(S="":":00",1:":"_S)_OFF ; Skip's code to fix hanging colon if no seconds
 I $E(UTC,9,14)="000000" S UTC=$E(UTC,1,8) ; admit our precision gpl 9/2013
 I $L($G(FORMAT)),FORMAT="DT" Q UTC ; Date with time.
 E  Q $P(UTC,"T")
 ;
FMDTOUTC(DATE,FORMAT) ; Convert Fileman Date to UTC Date Format; PUBLIC; Extrinsic
 ; FORMAT is Format of Date. Can be either D (Day) or DT (Date and Time)
 ; If not passed, or passed incorrectly, it's assumed that it is D.
 ; FM Date format is "YYYMMDD.HHMMSS" HHMMSS may not be supplied.
 ; UTC date is formatted as follows: YYYY-MM-DDThh:mm:ss_offsetfromUTC
 ; UTC, Year, Month, Day, Hours, Minutes, Seconds, Time offset (obtained from Mailman Site Parameters)
 N UTC,Y,M,D,H,MM,S,OFF
 S Y=1700+$E(DATE,1,3)
 S M=$E(DATE,4,5)
 S D=$E(DATE,6,7)
 S H=$E(DATE,9,10)
 I $L(H)=1 S H="0"_H
 S MM=$E(DATE,11,12)
 I $L(MM)=1 S MM="0"_MM
 S S=$E(DATE,13,14)
 I $L(S)=1 S S="0"_S
 S OFF=$$TZ^XLFDT ; See Kernel Manual for documentation.
 S OFFS=$E(OFF,1,1)
 S OFF0=$TR(OFF,"+-")
 S OFF1=$E(OFF0+10000,2,3)
 S OFF2=$E(OFF0+10000,4,5)
 S OFF=OFFS_OFF1_":"_OFF2
 ;S OFF2=$E(OFF,1,2) ;
 ;S OFF2=$E(100+OFF2,2,3) ; GPL 11/08 CHANGED TO -05:00 FORMAT
 ;S OFF3=$E(OFF,3,4) ;MINUTES
 ;S OFF=$S(OFF2="":"00",0:"00",1:OFF2)_"."_$S(OFF3="":"00",1:OFF3)
 ; If H, MM and S are empty, it means that the FM date didn't supply the time.
 ; In this case, set H, MM and S to "00"
 ; S:('$L(H)&'$L(MM)&'$L(S)) (H,MM,S)="00" ; IF ONLY SOME ARE MISSING?
 S:'$L(H) H="00"
 S:'$L(MM) MM="00"
 S:'$L(S) S="00"
 S UTC=Y_"-"_M_"-"_D_"T"_H_":"_MM_$S(S="":":00",1:":"_S)_OFF ; Skip's code to fix hanging colon if no seconds
 I $L($G(FORMAT)),FORMAT="DT" Q UTC ; Date with time.
 E  Q $P(UTC,"T")
 ;
HTMLDT(FMDT) ; extrinsic returns date format MM/DD/YYYY for display in html
 ;
 N TMP,TMP2
 S TMP=$$FMDTOUTC(FMDT)
 S TMP2=$E(TMP,5,6)_"/"_$E(TMP,7,8)_"/"_$E(TMP,1,4)
 I $E(TMP,9,14)'="000000" D  ;
 . I $L(TMP)=8 Q  ; no time
 . S TMP2=TMP2_" "_$E(TMP,9,10)_":"
 . S TMP2=TMP2_$E(TMP,11,12)_":"
 . S TMP2=TMP2_$E(TMP,13,19)
 Q TMP2
 ;
TESTDATE ; test the above transform
 N GT
 S GT=$$FMDTOUTC($$NOW^XLFDT,"DT")
 W !,GT
 Q
 ; 
GENHTML(HOUT,HARY) ; generate an HTML table from array HARY
 ; HOUT AND HARY are passed by name
 ;
 ; format of the table:
 ;  HARY("TITLE")="Problem List"
 ;  HARY("HEADER",1)="column 1 header"
 ;  HARY("HEADER",2)="col 2 header"
 ;  HARY(1,1)="row 1 col1 value"
 ;  HARY(1,2)="row 1 col2 value"
 ;  HARY(1,2,"ID")="the ID of the element" 
 ;  etc...
 ;
 N C0I,C0J
 I $D(@HARY@("TITLE")) D  ;
 . N X
 . S X="<title>"_@HARY@("TITLE")_"</title>"
 . D ADDTO(HOUT,X)
 D ADDTO(HOUT,"<text>")
 D ADDTO(HOUT,"<table border=""1"" width=""100%"">")
 I $D(@HARY@("HEADER")) D  ;
 . D ADDTO(HOUT,"<thead>")
 . D ADDTO(HOUT,"<tr>")
 . S C0I=0
 . F  S C0I=$O(@HARY@("HEADER",C0I)) Q:+C0I=0  D  ;
 . . D ADDTO(HOUT,"<th>"_@HARY@("HEADER",C0I)_"</th>")
 . D ADDTO(HOUT,"</tr>")
 . D ADDTO(HOUT,"</thead>")
 D ADDTO(HOUT,"<tbody>")
 I $D(@HARY@(1)) D  ;
 . S C0I=0 S C0J=0
 . F  S C0I=$O(@HARY@(C0I)) Q:+C0I=0  D  ;
 . . D ADDTO(HOUT,"<tr>")
 . . F  S C0J=$O(@HARY@(C0I,C0J)) Q:+C0J=0  D  ;
 . . . N UID S UID=$G(@HARY@(C0I,C0J,"ID"))
 . . . I UID'="" D ADDTO(HOUT,"<td ID="""_UID_""">"_@HARY@(C0I,C0J)_"</td>")
 . . . E  D ADDTO(HOUT,"<td>"_@HARY@(C0I,C0J)_"</td>")
 . . D ADDTO(HOUT,"</tr>")
 D ADDTO(HOUT,"</tbody>")
 D ADDTO(HOUT,"</table>")
 D ADDTO(HOUT,"</text>")
 Q
 ;
TESTHTML ;
 N HTML
 S HTML("TITLE")="Problem List"
 S HTML("HEADER",1)="column 1 header"
 S HTML("HEADER",2)="col 2 header"
 S HTML(1,1)="row 1 col1 value"
 S HTML(1,2)="row 1 col2 value"
 N GHTML
 D GENHTML("GHTML","HTML")
 ZWR GHTML
 Q
 ;
ADDTO(DEST,WHAT) ; adds string WHAT to list DEST 
 ; DEST is passed by name
 N GN
 S GN=$O(@DEST@("AAAAAA"),-1)+1
 S @DEST@(GN)=WHAT
 S @DEST@(0)=GN ; count
 Q
 ;
ORGOID() ; extrinsic which returns the Organization OID
 Q "2.16.840.1.113883.5.83" ; WORLDVISTA HL7 OID - 
 ; REPLACE WITH OID LOOKUP FROM INSTITUTION FILE
 ;
tree(where,prefix,docid,zout)	; show a tree starting at a node in MXML. 
 ; node is passed by name
 ; 
 i $g(prefix)="" s prefix="|--" ; starting prefix
 i '$d(KBAIJOB) s KBAIJOB=$J
 n node s node=$na(^TMP("MXMLDOM",KBAIJOB,docid,where))
 n txt s txt=$$CLEAN($$ALLTXT(node))
 w:'$G(DIQUIET) !,prefix_@node_" "_txt
 d oneout(zout,prefix_@node_" "_txt)
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . w:'$G(DIQUIET) !,prefix_"  : "_zi_"^"_$g(@node@("A",zi))
 . d oneout(zout,prefix_"  : "_zi_"^"_$g(@node@("A",zi)))
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . d tree(zi,"|  "_prefix,docid,zout)
 q
 ;
oneout(zbuf,ztxt) ; adds a line to zbuf
 n zi s zi=$o(@zbuf@(""),-1)+1
 s @zbuf@(zi)=ztxt
 q
 ;
ALLTXT(where)	; extrinsic which returns all text lines from the node .. concatinated 
 ; together
 n zti s zti=""
 n ztr s ztr=""
 f  s zti=$o(@where@("T",zti)) q:zti=""  d  ;
 . s ztr=ztr_$g(@where@("T",zti))
 q ztr
 ;
CLEAN(STR)	; extrinsic function; returns string - gpl borrowed from the CCR package
 ;; Removes all non printable characters from a string.
 ;; STR by Value
 N TR,I
 F I=0:1:31 S TR=$G(TR)_$C(I)
 S TR=TR_$C(127)
 N ZR S ZR=$TR(STR,TR)
 S ZR=$$LDBLNKS(ZR) ; get rid of leading blanks
 QUIT ZR
 ;
LDBLNKS(st)	; extrinsic which removes leading blanks from a string
 n pos f pos=1:1:$l(st)  q:$e(st,pos)'=" "
 q $e(st,pos,$l(st))
 ;
show(what,docid,zout)	;
 I '$D(C0XJOB) S C0XJOB=$J
 d tree(what,,docid,zout)
 q
 ; 
listm(out,in) ; out is passed by name in is passed by reference
 n i s i=$q(@in@(""))
 f  s i=$q(@i) q:i=""  d oneout(out,i_"="_@i)
 q
 ;
peel(out,in) ; compress a complex global into something simpler
 n i s i=$q(@in@(""))
 f  s i=$q(@i) q:i=""  d  ;
 . n j,k,l,m,n,m1
 . s (l,m)=""
 . s n=$$shrink($qs(i,$ql(i)))
 . s k=$qs(i,0)_"("""
 . f j=1:1:$ql(i)-1  d  ;
 . . i +$qs(i,j)>0 d  ;
 . . . i m'="" q
 . . . s m=$qs(i,j)
 . . . s m1=j
 . . . i j>1 s l=$qs(i,j-1)
 . . . e  s l=$qs(i,j)
 . . . i l["substanceAdministration" s l=$p(l,"substanceAdministration",2)
 . . s k=k_$qs(i,j)_""","""
 . . w:$g(DEBUG) !,j," ",k
 . s k=k_$qs(i,$ql(i))_""")"
 . w:$g(DEBUG) !,k,"=",@k
 . i l'="" d  q  ;
 . . d:$g(@out@(l,m,n))'=""
 . . . ;n jj,n2
 . . . ;f jj=2:1  w !,jj s n2=$qs(i,$ql(i)-1)_"["_jj_"]"_n q:$g(@out@(l,m,n2))=""  w !,n2
 . . . ;s n=n2
 . . . ;s n=$$shrink($qs(i,$ql(i)-1))_"_"_n
 . . . s n=$$mkxpath(i,m1)
 . . . b:$g(@out@(l,m,n))'=""
 . . s @out@(l,m,n)=@k
 . i @k'="" d  ;
 . . i $ql(i)>1 d  q  ;
 . . . s l=$$shrink($qs(i,$ql(i)-1))
 . . . d:$g(@out@(l,n))'=""
 . . . . ;n jj,n2
 . . . . ;f jj=2:1  s n2=$qs(i,$ql(i)-1)_"["_jj_"]"_"_"_n q:$g(@out@(l,n2))=""
 . . . . ;s n=n2
 . . . . ;b:$g(@out@(l,n))'=""
 . . . . s n=$$shrink($qs(i,$ql(i)-1))_"_"_n
 . . . s @out@(l,n)=@k
 . . s @out@(n)=@k
 q
 ;
shrink(x) ; reduce strings 
 n y,z
 s y=x
 s z="substanceAdministration"
 i x[z s y=$p(x,z,2)
 q y
 ;
mkxpath(zq,zm) ; extrinsic which returns the xpath derived from the $query value 
 ;passed by value. zm is the index to begin with
 ;
 n zr s zr=""
 n zi s zi=""
 f zi=1:1:$ql(zq) s zr=zr_"/"_$qs(zq,zi)
 q zr
 ;