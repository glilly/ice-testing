C0IDDMAP  ;
; Pull information re CPT and CVX codes from dEWDrop
 D CPTMAP^C0ITEST
 D CVXMAP^C0ITEST
 D CPTIMAP^C0ITEST
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
 ....;VOID-IEN of CPT Mapping File;CPT Code;Immunization file Name for the immunization; Short name from Immunization file;CVX Code;proper CVX code short description
 ....;S NANCY(I)=I_";"_$P($P(^PXD(811.1,I,0),U,1),";",1)_";"_$P(^AUTTIMM(IMMIEN,0),U,1)_";"_$P(^AUTTIMM(IMMIEN,0),U,2)_";"_IMMCVX_";"_CVXTXT_";"
 ....;IEN of CPT Mapping File;Immunization File IEN;Immunization file Name for the immunization; Short name from Immunization file;CPT Code;CVX Code;proper CVX code sho 
 ....S NANCY(I)=I_";"_IMMIEN_";"_$P(^AUTTIMM(IMMIEN,0),U,1)_";"_$P(^AUTTIMM(IMMIEN,0),U,2)_";"_$P($P(^PXD(811.1,I,0),U,1),";",1)_";"_IMMCVX_";"_CVXTXT
 ....W NANCY(I),!
 ....S NANCY1(I)=IMMIEN
 ....W NANCY1(I),!
 ; F I=1:1:131 D
 ;.; if there is an entry in the CPT mapping file corrensponding to this imminization, QUIT
 Q
 
