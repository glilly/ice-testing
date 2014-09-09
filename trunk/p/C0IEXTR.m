C0IEXTR ; GPL - Patient extract and  DOM PROCESSING ROUTINES ;8/29/13  17:05
 ;;0.1;Immunizations Forcasting;nopatch;noreleasedate;
 ;
 ; License Apache 2
 ; 
 ; This software was funded in part by Oroville Hospital, and was
 ; created with help from Oroville's doctors and staff.
 ;
 Q
 ;
 ; here are the types that are supported:
 ;demographics;reactions;problems;vitals;labs;meds;immunizations;observation;
 ;visits;appointments;documents;procedures;consults;flags;factors;skinTests;
 ;exams;education;insurance
 ;
GETPAT(RTN,ZPATID,ZTYP,START,STOP) ; get patient data
 N JJOHARY
 S START=$G(START) 
 S STOP=$G(STOP)
 D GET^VPRD(.JJOHARY,ZPATID,ZTYP,START,STOP)
 ;K ^TMP("MXMLDOM",$J,1)
 S JJOHDID=$$PARSE(JJOHARY,ZPATID_"-"_ZTYP)
 k RTN
 N ZDOM S ZDOM=$NA(^TMP("MXMLDOM",$J,JJOHDID))
 d domo3("RTN",,,ZDOM)
 ;D DOMO(1,"/","RTN","GIDX","GARY",,"/results/"_ZTYP_"/")
 K GIDX,GARY,@JJOHARY
 ;
 Q
 ;
GETNHIN(RTN,ZPATID,ZTYP) ; get patient data
 N JJOHARY
 D GET^JJOHPPCN(.JJOHARY,ZPATID,ZTYP)
 K ^TMP("MXMLDOM",$J,1)
 S JJOHDID=$$PARSE(JJOHARY,ZPATID_"-"_ZTYP)
 k RTN
 N ZDOM S ZDOM=$NA(^TMP("MXMLDOM",$J,JJOHDID))
 ;d domo2("RTN",ZDOM)
 d domo3("RTN",,,ZDOM)
 ;D DOMO(1,"/","RTN","GIDX","GARY",,"/results/")
 ;K GIDX,GARY,@JJOHARY
 ;
 Q
 ;
tree(where,prefix,docid,zout,zary) ; show a tree starting at a node in MXML. 
 ; node is passed by name
 ; 
 i '$d(zary) s zary="GARY"
 i '$d(@zary) s @zary=""
 i $g(prefix)="" s prefix="/" ; starting prefix
 i '$d(KBAIJOB) s KBAIJOB=$J
 n node s node=$na(^TMP("MXMLDOM",KBAIJOB,docid,where))
 n txt s txt=$$CLEAN($$ALLTXT(node))
 n g s g=prefix
 n gt s gt=prefix_"/"_@node
 n gt1 s gt1=1
 i $d(@zary@(gt)) d  ;
 . s gt1=$o(@zary@(gt,""),-1)+1
 ;i txt'="",txt'=" " d  ;
 s @zary@(gt1,gt)=txt
 s @zary@(gt,gt1)=txt
 w !,gt_" "_txt
 d oneout(zout,prefix_@node_" "_txt)
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . s @zary@(gt1,g,@node_"@"_zi)=$g(@node@("A",zi))
 . w !,prefix_"/"_@node_"@"_zi_"="_$g(@node@("A",zi))
 . d oneout(zout,prefix_"/"_@node_"@"_zi_"="_$g(@node@("A",zi)))
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . d tree(zi,prefix_"/"_@node,docid,zout)
 q
 ;
domo3(zary,what,where,zdom,lvl) ; simplified domo
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
testmult ;
 n zdom
 s zdom=$na(^TMP("MXMLDOM",$J,1))
 n gi,gj s gi=""
 f  s gi=$o(@zdom@(gi)) q:gi=""  d  ;
 . i $$ismult(gi,zdom) b  ;
 q
 ;
findnxt(tag,znd) ; private extrinsic which returns a node id of tag
 i '$d(zdom) s zdom=$na(^TMP("MXMLDOM",$J,$o(^TMP("MXMLDOM",$J,"AAAAA"),-1)))
 ;i @zdom@(znd)=tag q znd ; easy case
 n gi,done,rslt s gi="" s done=0
 f  s gi=$o(@zdom@(znd,"C",gi)) q:done  q:gi=""  d  ;
 . i @zdom@(znd,"C",gi)=tag s done=1 s rslt=gi
 q:done rslt
 f  s gi=$o(@zdom@(znd,"C",gi)) q:done  q:gi=""  d  ;
 . s rslt=$$findnxt(tag,gi)
 . i rslt'="" s done=1
 q:done rslt
 ;i $d(@zdom@(znd,"P")) d  ;
 ;. s rslt=$$findnxt(tag,@zdom@(znd,"P")) ; check the parent if any
 q rslt
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
TEST ;
 S GDOM=$NA(^KBAI("TOOBIG","DOM"))
 K ^TMP("MXMLDOM",$J)
 M ^TMP("MXMLDOM",$J,1)=@GDOM
 K GARY,GIDX,GNARY
 S JJOHDID=1
 ;D DOMO(1,"/","GNARY","GIDX","GARY",,"/results/")
 K G,GARY
 ;d domo2("GARY",,"..results.")
 d domo3("GARY")
 Q
 ;
ADDNARY(ZXP,ZVALUE) ; ADD AN NHIN ARRAY VALUE TO ZNARY
 ;
 ; IF ZATT=1 THE ARRAY IS ADDED AS ATTRIBUTES
 ;
 N ZZI,ZZJ,ZZN
 S ZZI=$P(ZXP,"/",1) ; FIRST PIECE OF XPATH ARRAY
 I ZZI="" Q  ; DON'T ADD THIS ONE .. PROBABLY THE //results NODE
 S ZZJ=$P(ZXP,ZZI_"/",2) ; REST OF XPATH ARRAY
 S ZZJ=$TR(ZZJ,"/",".") ; REPLACE / WITH .
 I ZZI'["]" D  ; A SINGLETON
 . S ZZN=1
 E  D  ; THERE IS AN [x] OCCURANCE
 . S ZZN=$P($P(ZZI,"[",2),"]",1) ; PULL OUT THE OCCURANCE
 . S ZZI=$P(ZZI,"[",1) ; TAKE OUT THE [X]
 I ZZJ'="" D  ; TIME TO ADD THE VALUE
 . S @ZNARY@(ZZI,ZZN,ZZJ)=ZVALUE
 Q
 ;
PARSE(INXML,INDOC) ;CALL THE MXML PARSER ON INXML, PASSED BY NAME
 ; INDOC IS PASSED AS THE DOCUMENT NAME - DON'T KNOW WHERE TO STORE THIS NOW
 ; EXTRINSIC WHICH RETURNS THE DOCID ASSIGNED BY MXML
 ;Q $$EN^MXMLDOM(INXML)
 Q $$EN^MXMLDOM(INXML,"W")
 ;
ISMULT(ZOID) ; RETURN TRUE IF ZOID IS ONE OF A MULTIPLE
 N ZN
 ;I $$TAG(ZOID)["entry" B
 S ZN=$$NXTSIB(ZOID)
 I ZN'="" Q $$TAG(ZOID)=$$TAG(ZN) ; IF TAG IS THE SAME AS NEXT SIB TAG
 Q 0
 ;
FIRST(ZOID) ;RETURNS THE OID OF THE FIRST CHILD OF ZOID
 Q $$CHILD^MXMLDOM(JJOHDID,ZOID)
 ;
PARENT(ZOID) ;RETURNS THE OID OF THE PARENT OF ZOID
 Q $$PARENT^MXMLDOM(JJOHDID,ZOID)
 ;
ATT(RTN,NODE) ;GET ATTRIBUTES FOR ZOID
 S HANDLE=JJOHDID
 K @RTN
 D GETTXT^MXMLDOM("A")
 Q
 ;
TAG(ZOID) ; RETURNS THE XML TAG FOR THE NODE
 ;
 N X,Y
 S Y=""
 S X=$G(JJOHCBK("TAG")) ;IS THERE A CALLBACK FOR THIS ROUTINE
 I X'="" X X ; EXECUTE THE CALLBACK, SHOULD SET Y
 I Y="" S Y=$$NAME^MXMLDOM(JJOHDID,ZOID)
 Q Y
 ;
NXTSIB(ZOID) ; RETURNS THE NEXT SIBLING
 Q $$SIBLING^MXMLDOM(JJOHDID,ZOID)
 ;
DATA(ZT,ZOID) ; RETURNS DATA FOR THE NODE
 ;N ZT,ZN S ZT=""
 ;S C0SDOM=$NA(^TMP("MXMLDOM",$J,JJOHDID))
 ;Q $G(@C0SDOM@(ZOID,"T",1))
 S ZN=$$TEXT^MXMLDOM(JJOHDID,ZOID,ZT)
 Q
 ;
DEMUX2(OARY,IARY,DEPTH) ;CONVERT AN XPATH ARRAY PASSED AS IARY TO
 ; FORMAT @OARY@(x,variablename) where x is the first multiple
 ; IF DEPTH=2, THE LAST 2 PARTS OF THE XPATH WILL BE USED
 N ZI,ZJ,ZK,ZL,ZM S ZI=""
 F  S ZI=$O(@IARY@(ZI)) Q:ZI=""  D  ;
 . D DEMUX^C0CMXP("ZJ",ZI)
 . S ZK=$P(ZJ,"^",3)
 . S ZM=$RE($P($RE(ZK),"/",1))
 . I $G(DEPTH)=2 D  ;LAST TWO PARTS OF XPATH USED FOR THE VARIABLE NAME
 . . S ZM=$RE($P($RE(ZK),"/",2))_"."_ZM
 . S ZL=$P(ZJ,"^",1)
 . I ZL="" S ZL=1
 . I $D(@OARY@(ZL,ZM)) D  ;IT'S A DUP
 . . S @OARY@(ZL,ZM_"[2]")=@IARY@(ZI)
 . E  S @OARY@(ZL,ZM)=@IARY@(ZI)
 Q
 ;
