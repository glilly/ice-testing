C0IPXRM ; GPL&NEA - Immunizations Forecasting Utilities ;05/03/14  17:05
 ;;0.1;Immunizations Forecasting;nopatch;noreleasedate;
 ;
 ; License Apache 2
 ; 
 Q
 ;
 ; Routines for calling Reminders to see if the patients has had any deseases 
 ;   that make them immune and therefore not requiring a vaccination
 ; 
 ; Since we are not on the latest Reminder's patch (24) we do not have access to
 ;   entry point MAINDF^PXRM. Therefore we import MAIN^PXRM and modify it to act
 ;   as a workaround. When patch 24 is available, this routine should be changed
 ;   to detect it and use it.  gpl
 ;
EN(DFN,REMNDR,ARY,ATTR,RCODE,RNAME) ; extrinsic returns true if the reminder evaluates true
 ; also returns supporting values as "findings" in the array indexed by the attribute ATTR
 ; 
 ; DFN is the patient ien passed by value
 ; REMNDR is the reminder ien passed by value
 ; ARY is the return array passed by reference - results will be added to the end
 ;  of the array ie ARY("findings",4,....) if there is already an ARY("findings",3)
 ; ATTR is the attribute to be associated with this call ie "hadMumps" passed by value
 ; RCODE and RNAME are the Rubrics that will be used for this finding when calling
 ;  clinical decision support. 
 ;
 ; This routine calls the reminders package with the patient and reminder ien passed in.
 ;  if the reminder evaluates true, it then locates and finds the patient entry that
 ;  caused the true evaluation, and collects the source, the date of onset if possible,
 ;  and the date of entry. It will also return the other things retained by the reminders
 ;  package in case they might also be useful. It puts them in the array and indexes the
 ;  entry by the attribute that is passed in.. 
 ;
 ;D MAIN(11,264,0)
 D MAIN(DFN,REMNDR,0)
 I $G(FIEVAL(1))=0 Q 0 ; no positive findings
 ;
 ; first see if there's a problem list entry and give it preference
 ;   (this preference is because with a problem list entry we can get date of onset)
 ;
 N C0IUSE S C0IUSE=0 ; eval entry to use
 N C0I S C0I=""
 F  S C0I=$O(FIEVAL(1,C0I)) Q:((C0I="")!(C0IUSE'=0))  D  ;
 . I $G(FIEVAL(1,C0I,"FILE NUMBER"))=9000011 S C0IUSE=C0I
 I C0IUSE=0 S C0IUSE=1 ; if no problem entry, use the first entry
 ;
 N C0FIND
 S C0FIND=$O(ARY("findings"," "),-1)+1 ; index of this finding
 M ARY("findings",C0FIND)=FIEVAL(1,C0IUSE)
 N FIEN,FFILE
 S FIEN=$G(FIEVAL(1,C0IUSE,"DAS")) ; ien of problem 
 S FFILE=$G(FIEVAL(1,C0IUSE,"FILE NUMBER"))
 ;
 S ARY("findings",C0FIND,"ICD9Code")=$$GET1^DIQ(FFILE,FIEN_",",.01)
 S ARY("findings",C0FIND,"ICD9Name")=$$GET1^DIQ(FFILE,FIEN_",",.05)
 S ARY("findings",C0FIND,"dateOfOnset")=$G(FIEVAL(1,C0IUSE,"DATE ENTERED"))
 S ARY("findings",C0FIND,"date")=$G(FIEVAL(1,C0IUSE,"DATE"))
 N C0IDUZ S C0IDUZ=$G(FIEVAL(1,C0IUSE,"PRIMARY PROVIDER"))
 I +C0IDUZ=0 S C0IDUZ=$G(FIEVAL(1,"PRIMARY PROVIDER"))
 S ARY("findings",C0FIND,"primaryProviderDUZ")=C0IDUZ
 S ARY("findings",C0FIND,"primaryProviderName")=$$GET1^DIQ(200,C0IDUZ_",",.01)
 S ARY("findings",C0FIND,ATTR)=""
 S ARY("findings","B",ATTR,C0FIND)=""
 S ARY("findings",C0FIND,"rubricCode")=$E(RCODE,1,$L(RCODE))
 S ARY("findings",C0FIND,"rubricName")=RNAME
 S ARY("findings","rubric",RCODE,C0FIND)=""
 M ARY("FIEVAL",C0FIND)=FIEVAL ; for debugging
 Q 1
 ;
MAIN(DFN,PXRMITEM,OUTTYPE,DISC)	;Main driver for clinical reminders.
	;INPUT  DFN - Pointer to Patient File (#2)
	;       PXRMITEM - IEN of reminder to evaluate.
	;       OUTTYPE - Flag to indicate type of output information.
	;         0 - Reminders DUE NOW only (CLINICAL REMINDERS DUE
	;             HS component)
	;         1 - All Reminders with Next and Last Information
	;             (CLINICAL REMINDERS SUMMARY HS component)
	;         5 - Health Maintenance (CLINICAL REMINDERS MAINTENANCE
	;              HS component)
	;        10 - MyHealtheVet summary
	;        11 - MyHealtheVet detailed
	;        12 - MyHealtheVet combined
	;        DISC - (optional) if this is true then the disclaimer will
	;             be loaded in ^TMP("PXRM",$J,"DISC").
	;
	;OUTPUT  ^TMP("PXRHM",$J,PXRMITEM,PXRMRNAM)=
	;              STATUS_U_DUE DATE_U_LAST DONE
	;        where PXRMRNAM is the PRINT NAME or if it is undefined then
	;        it is the NAME (.01).
	;        For the Clinical Maintenance component, OUTTYPE=5, there is 
	;        subsequent output of the form
	;        ^TMP("PXRHM",$J,PXRMITEM,PXRMRNAM,"TXT",N)=TEXT
	;        where N is a number and TEXT is a text string.
	;
	;        If DISC is true then the disclaimer will be loaded into
	;        ^TMP("PXRM",$J,"DISC"). The calling application should
	;        delete this when it is done.
	;
	;        The calling application can display the contents of these
	;        two ^TMP arrays as it chooses. The caller should also make
	;        sure the ^TMP globals are killed before it exits.
	;
	N DEFARR ;,FIEVAL gpl don't new FIEVAL
        K FIEVAL ; gpl kill it instead
	;Load the definition into DEFARR.
	D DEF^PXRMLDR(PXRMITEM,.DEFARR)
	;
	I $G(NODISC)="" S NODISC=1
	I $D(GMFLAG) S NODISC=0
	D EVAL^PXRM(DFN,.DEFARR,OUTTYPE,NODISC,.FIEVAL) ; gpl fully qualify routine name
	Q
	;
	;==========================================================
TEST ; try out the above
 S DFN=$$PAT^C0IICE()
 Q:DFN=0
 N IENHEPA,IENHEPB,IENMEASL,IENVARIC,IENMUMPS,IENRUBEL 
 N RCODE,RNAME ; rubric code and name
 S (IENHEPA,IENHEPB,IENMEASL,IENVARIC,IENMUMPS,IENRUBEL)=""
 N FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG
 S FILE=811.9 
 S IENS=""
 S FLAGS="OQ"
 S INDEX="B"
 S SCREEN=""
 S EMSG=""
 ;N N,HEPA,HEPB,VARICEL,MUMPS,MEASLES,RUBELLA
 S (N,HEPA,HEPB,VARICEL,MUMPS,MEASLES,RUBELLA)=0
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-HEPATITIS B DIAGNOSIS"
 S IENHEPB=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 I IENHEPB="" Q  ; reminder not found, skip this part
 K REMNAME
 ;D MAIN^PXRM(DFN,IENHEPB,0)
 S RCODE="070.3"
 S RNAME="Hep B"
 I $$EN^C0IPXRM(DFN,IENHEPB,.RETURN,"hadHepB",RCODE,RNAME) S N=N+1 S HEPB=1
 ;I $G(^TMP("PXRHM",$J,IENHEPB,"VIMM-HEPATITIS B DIAGNOSIS"))["DUE NOW" S N=N+1 S HEPB=1
 ;W "HEPB=",HEPB,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-HEPATITIS A DIAGNOSIS"
 S IENHEPA=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG) 
 K REMNAME
 ;D MAIN^PXRM(DFN,IENHEPA,0)
 S RCODE="070.1"
 S RNAME="Hep A"
 I $$EN^C0IPXRM(DFN,IENHEPA,.RETURN,"hadHepA",RCODE,RNAME) S N=N+1 S HEPA=1
 ;I $G(^TMP("PXRHM",$J,IENHEPA,"VIMM-HEPATITIS A DIAGNOSIS"))["DUE NOW" S N=N+1 S HEPA=1
 ;W "HEPA=",HEPA,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-VARICELLA DIAGNOSIS"
 S IENVARIC=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 ;D MAIN^PXRM(DFN,IENVARIC,0)
 S RCODE="052.9"
 S RNAME="Varicella"
 I $$EN^C0IPXRM(DFN,IENVARIC,.RETURN,"hadVaricella",RCODE,RNAME) S N=N+1 S VARICEL=1
 ;I $G(^TMP("PXRHM",$J,IENVARIC,"VIMM-VARICELLA DIAGNOSIS"))["DUE NOW" S N=N+1 S VARICEL=1
 ;W "VARICEL=",VARICEL,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-MUMPS DIAGNOSIS" 
 S IENMUMPS=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG) D MAIN^PXRM(DFN,267,0)
 K REMNME
 ;D MAIN^PXRM(DFN,IENMUMPS,0)
 S RCODE="072.9"
 S RNAME="Mumps"
 I $$EN^C0IPXRM(DFN,IENMUMPS,.RETURN,"hadMumps",RCODE,RNAME) S N=N+1 S IENMUMPS=1
 ;I $G(^TMP("PXRHM",$J,IENMUMPS,"VIMM-MUMPS DIAGNOSIS"))["DUE NOW" S N=N+1 S MUMPS=1
 ;W "MUMPS=",MUMPS,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-MEASLES DIAGNOSIS"
 S IENMEASL=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 ;D MAIN^PXRM(DFN,IENMEASL,0)
 S RCODE="055.9"
 S RNAME="Measles"
 I $$EN^C0IPXRM(DFN,IENMEASL,.RETURN,"hadMeasles",RCODE,RNAME) S N=N+1 S MEASLES=1
 ;I $G(^TMP("PXRHM",$J,IENMEASL,"VIMM-MEASLES DIAGNOSIS"))["DUE NOW" S N=N+1 S MEASLES=1
 ;W "MEASLES=",MEASLES,!
 K ^TMP("PXRHM",$J)
 N REMNAME S REMNAME="VIMM-RUBELLA DIAGNOSIS"
 S IENRUBEL=$$FIND1^DIC(FILE,IENS,FLAGS,REMNAME,INDEX,SCREEN,EMSG)
 K REMNAME
 ;D MAIN^PXRM(DFN,IENRUBEL,0)
 S RCODE="056.9"
 S RNAME="Rubella"
 I $$EN^C0IPXRM(DFN,IENRUBEL,.RETURN,"hadRubella",RCODE,RNAME) S N=N+1 S RUBELLA=1
 ;I $G(^TMP("PXRHM",$J,IENRUBEL,"VIMM-RUBELLA DIAGNOSIS"))["DUE NOW" S N=N+1 S RUBELLA=1
 ;W "RUBELLA=",RUBELLA,!
 K ^TMP("PXRHM",$J)
 I N=0 Q
 Q
 ;