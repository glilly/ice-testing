KBAIICE	; GPL - ICE viewing routines ; 4/24/14 6:03pm
 ;;0.1;KBAIICE;nopatch;noreleasedate;
 ;Copyright 2013 George Lilly.  Licensed Apache 2
 ;
 Q
wsICE(OUT,FILTER) ; get from web service call
 I '$D(DT) N DIQUIET S DIQUIET=1 D DT^DICRW
 N MODE 
 I $G(FILTER("root"))="" S MODE=1 ; mode 1 is the outline of the xml
 E  S MODE=FILTER("root") ; mode 2 is the domo mumps array
 S HTTPRSP("mime")="text/html"
 S OUT=$NA(^TMP("VPROUT",$J))
 K @OUT
 S @OUT="<!DOCTYPE HTML><html><head></head><body><pre>"
 I MODE=3 D  Q  ;
 . N ICEOUT S ICEOUT=$NA(^TMP("ICE",$J,"ICEOUT"))
 . D SOAP^C0ISOAP2(ICEOUT)
 . S ROOT=ICEOUT
 . N ORIG,OL S ORIG=ROOT,OL=$QL(ROOT) ; Orig, Orig Length
 . F  S ROOT=$Q(@ROOT) Q:(($G(ROOT)="")!($NA(@ROOT,OL)'=$NA(@ORIG,OL)))  S @OUT@($O(@OUT@(""),-1)+1)=ROOT_"="_$$CLEAN(@ROOT)
 . S @OUT@($O(@OUT@(""),-1)+1)="</pre></body></html>"
 . D ADDCRLF^VPRJRUT(.OUT)
 N GN S GN=$NA(^TMP("KBAIICE","XML"))
 N DOCID
 S DOCID=$$PARSE^KBAIVPR(GN)
 I MODE'=2 D  ; show the outline of the xml
 . D show^KBAIVPR(1,DOCID,OUT)
 I MODE=2 D  ; show the domo mumps array
 . N G,ROOT
 . D domo3("G")
 . S ROOT="G"
 . N ORIG,OL S ORIG=ROOT,OL=$QL(ROOT) ; Orig, Orig Length
 . F  S ROOT=$Q(@ROOT) Q:(($G(ROOT)="")!($NA(@ROOT,OL)'=$NA(@ORIG,OL)))  S @OUT@($O(@OUT@(""),-1)+1)=ROOT_"="_$$CLEAN(@ROOT)
 S @OUT@($O(@OUT@(""),-1)+1)="</pre></body></html>"
 D ADDCRLF^VPRJRUT(.OUT)
 q
 ;
FILEIN ; import the valueset xml file, parse with MXML, and put the dom in ^TMP
 ;
 N FNAME,DIRNAME
 W !,"Please enter the directory and file name for the XML file"
 Q:'$$GETDIR^KBAIOSD3(.DIRNAME,"/home/vista/") ; prompt the user for the directory
 Q:'$$GETFN^KBAIOSD3(.FNAME,"ICE-Incoming-Base64PortionOfMessageOnlyDecoded.txt") ; 
 N GN S GN=$NA(^TMP("KBAIICE")) ; root to store xml and dom
 K @GN ; clear the area
 N GN1 S GN1=$NA(@GN@("XML",1)) ; place to put the xml file
 W !,"Reading in file ",FNAME," from directory ",DIRNAME
 Q:$$FTG^%ZISH(DIRNAME,FNAME,GN1,3)=""
 N KBAIDID
 W !,"Parsing file ",FNAME
 D PARSE^KBAIOSD3($NA(@GN@("DOM")),$NA(@GN@("XML")))
 Q
 ;
domo3(zary,what,where,zdom,lvl) ; stands for "dom out" returns usable mumps array from a dom
 ; zary is the return array
 ; what is the tag to begin with starting at where, a node in the zdom
 ; multiple is the index to be used for a muliple entry 0 is a singleton
 ; 
 i '$d(zdom) s zdom=$na(^TMP("MXMLDOM",$J,$o(^TMP("MXMLDOM",$J,"AAAAA"),-1)))
 i '$d(where) s where=1
 i $g(what)="" s what=@zdom@(where)
 i '$d(lvl) s lvl=0 n znum s znum=0 ; first time
 ;
 n txt s txt=$$CLEAN($$ALLTXT($NA(@zdom@(where))))
 i txt'="" i txt'=" " d  ;
 . s @zary@(@zdom@(where))=txt
 ;
 n zi s zi=""
 f  s zi=$o(@zdom@(where,"A",zi)) q:zi=""  d  ;
 . s @zary@(what_"@"_zi)=@zdom@(where,"A",zi)
 f  s zi=$o(@zdom@(where,"C",zi)) q:zi=""  d  ;
 . n mult s mult=$$ismult(where,zdom)
 . ;i '$d(znum) n znum s znum(where)=0
 . i mult>0 s znum(where)=$g(znum(where))+1
 . i $g(C0DEBUG) i mult>0 D  ;
 . . w !,"where ",where," what ",what," zi ",zi," lvl ",lvl,!
 . . zwr znum
 . i mult=0 d domo3($na(@zary@(what)),@zdom@(where,"C",zi),zi,zdom,lvl+1)
 . i mult>0 d domo3($na(@zary@(what,znum(where))),@zdom@(where,"C",zi),zi,zdom,lvl+1)
 q
 ;
ismult(zidx,zdom) ; extrinsic which returns one if the node contains multiple
 ; children with the same tag
 n ztags,zzi,zj,rtn s zzi="" s rtn=0
 f  s zzi=$o(@zdom@(zidx,"C",zzi)) q:rtn=1  q:zzi=""  d  ;
 . s zj=@zdom@(zidx,"C",zzi)
 . i $d(ztags(zj)) s rtn=1
 . s ztags(zj)=""
 q rtn
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
ALLTXT(where)	; extrinsic which returns all text lines from the node .. concatinated 
 ; together
 n zti s zti=""
 n ztr s ztr=""
 f  s zti=$o(@where@("T",zti)) q:zti=""  d  ;
 . s ztr=ztr_$g(@where@("T",zti))
 q ztr
 ;
GVTEST   ;Test maximum length of a global variable name.
 N IND,SUB
 S SUB="A"
 F IND=1:1:1000 D
 . W !,"Length=",$L(SUB)
 . S ^TMP("PKR",SUB)=""
 . S SUB=SUB_"A"
 Q
 ;
GVTEST2   ;Test maximum length of a local variable name.
 N IND,SUB
 S SUB="A"
 F IND=1:1:1000 D
 . W !,"Length=",$L(SUB)
 . S G("PKR",SUB)=""
 . S SUB=SUB_"A"
 Q
 ;
					 ;
