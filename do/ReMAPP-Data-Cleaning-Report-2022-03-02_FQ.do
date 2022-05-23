****************************************************************
*Hemoglobin and Screening Code for ReMAPP Study
*Last Updated: 02/07/2022 ALB
*Users: 
****************************************************************

cd "C:\Farrukh_data\Anemia\data" //UPDATE BY USER
****************************************************************
*Part 1: Compiling Final Dataset - Maternal
*Merging all forms into single dataset 

cd "C:\Farrukh_data\Anemia\data"

	use mnh01_pID, clear 
	
	merge m:1 SUBJID using mnh02 
		ren _merge mer02
        
	
	merge m:1 PREGNANCY_ID using mnh03a_pID 
	    ren _merge mer03a 
		
	merge m:1 PREGNANCY_ID using mnh03b_pID 
		ren _merge mer3b
		
	merge m:1 PREGNANCY_ID using mnh04_pID
		ren _merge mer04
		
	merge m:1 PREGNANCY_ID using mnh05_pID 
		ren _merge mer05
		
	merge m:1 PREGNANCY_ID using mnh06_pID 
	     ren _merge mer06 
		 
	merge m:1 PREGNANCY_ID using mnh07_pID 
		ren _merge mer07
		
	merge m:1 PREGNANCY_ID using mnh08_pID 
		ren _merge mer08
	
	*merge 1:1 CASEID using `mnh11' 
	*	drop _merge
		
	*merge 1:1 CASEID using `mnh13' 
	*	drop _merge
		
	*merge 1:1 CASEID using `mnh14' 
	*	drop _merge
		
	*merge 1:1 CASEID using `mnh17' 
	*	drop _merge
		
	*merge 1:1 CASEID using `mnh18' 
	*	drop _merge
		
	*merge 1:1 CASEID using `mnh25' 
	*	drop _merge

*************************************************
*Part 2: Data Cleaning
*************************************************

***************dropping the IDs who did not fill consent

keep if M01_CON_YN_DSDECOD== 1

duplicates report SUBJID
duplicates report PREGNANCY_ID


* fixing M07_CBC_HB_LBORRES2

*******i have locked this command because we have already this variable in numeric

*replace M07_CBC_HB_LBORRES2=" " if (M07_CBC_HB_LBORRES2=="NEGATIVE ")
lab def M07_CBC_HB_LBORRES2 -7 "Negative"
lab val M07_CBC_HB_LBORRES2 M07_CBC_HB_LBORRES2
 
*cleaning continuous variables
	foreach x of varlist  ///
	M07_CBC_HB_LBORRES1 M07_CBC_HB_LBORRES2 M07_CBC_HB_LBORRES3 M07_CBC_HB_LBORRES4 M07_HB_POC_LBORRES1 M07_HB_POC_LBORRES2 M07_HB_POC_LBORRES3 M07_HB_POC_LBORRES4 M08_SPHB_LBORRES1 M08_SPHB_LBORRES2 M08_SPHB_LBORRES3 M08_SPHB_LBORRES4 M08_SPHB_LBORRES5 M08_SPHB_LBORRES6 M08_SPHB_LBORRES7 M08_SPHB_LBORRES8 M08_SPHB_LBORRES9 M08_SPHB_LBORRES10 M08_SPHB_LBORRES11 M08_SPHB_LBORRES12 M08_SPHB_LBORRES13  ///
	M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES {
		replace `x' = . if `x' == -7
		destring `x', replace 
}		 

*cleaning date variables
	
	*foreach x of varlist M01_LMP_SCDAT M01_SCRN_OBSSTDAT {
	*replace `x' = "" if(`x' =="SKIPPED")
	*gen date2=date(`x', "YMD") 
	*rename `x' `x'_str
	*rename date2 `x'
	*format `x' %d 
	
	*}
	foreach var of varlist M01_LMP_SCDAT M01_SCRN_OBSSTDAT M01_EDD_SCDAT M01_ESTIMATED_EDD_SCDAT {
	replace `var' = "" if(`var' == "-7")
	}
	rename M01_LMP_SCDAT M01_LMP_SCDAT_str
	rename M01_SCRN_OBSSTDAT M01_SCRN_OBSSTDAT_str
	rename M01_EDD_SCDAT M01_EDD_SCDAT_str
	rename M01_ESTIMATED_EDD_SCDAT M01_ESTIMATED_EDD_SCDAT_str
	
	gen M01_LMP_SCDAT=date(M01_LMP_SCDAT_str, "MDY") 
	format M01_LMP_SCDAT %d 
	
	gen M01_SCRN_OBSSTDAT=date(M01_SCRN_OBSSTDAT_str, "MDY") 
	format M01_SCRN_OBSSTDAT %d 
     
	gen M01_EDD_SCDAT=date(M01_EDD_SCDAT_str, "MDY") 
	format M01_EDD_SCDAT %d 
	
	gen M01_ESTIMATED_EDD_SCDAT=date(M01_ESTIMATED_EDD_SCDAT_str, "MDY") 
	format M01_ESTIMATED_EDD_SCDAT %d 

	

***********adding additional codes for the calculation of missing gestational age

******gestational age calculation for missing IDs
	
gen edd_for_missing= M01_EDD_SCDAT if M01_ESTIMATED_EDD_SCDAT== .
format edd_for_missing %d
gen lmp_for_missing= edd_for_missing - 280
format lmp_for_missing %d
gen gest_age_missing= M01_SCRN_OBSSTDAT - lmp_for_missing

gen gest_age_missing1= M01_SCRN_OBSSTDAT - lmp_for_missing

gen gest_age_week =  gest_age_missing/7 
*replace gest_age_week=  round(gest_age_week)

gen gest_age_month =  gest_age_missing/30 
*replace gest_age_month=  round(gest_age_month)

replace M01_GEST_AGE_WKS_SCORRES= gest_age_week if  M01_GEST_AGE_WKS_SCORRES== .

replace M01_GEST_AGE_MOS_SCORRES= gest_age_month if  M01_GEST_AGE_MOS_SCORRES== .


************************gestational age by Ultra sound
	
gen gest_age_us_week=.
replace gest_age_us_week= M06_US_GA_WEEKS_AGE1 + (M06_US_GA_DAYS_AGE1/7) if (M06_US_GA_WEEKS_AGE1!= . & M06_US_GA_DAYS_AGE1!= .)

gen gest_age_us_month= gest_age_us_week/4 if gest_age_us_week!= .

*replace gest_age_us_week= round(gest_age_us_week)
*replace gest_age_us_month= round(gest_age_us_month)


replace gest_age_us_week= M01_GEST_AGE_WKS_SCORRES if gest_age_us_week== .
replace gest_age_us_month= M01_GEST_AGE_MOS_SCORRES if gest_age_us_month== .

	
	
*calculating LMP for all participants
gen lmp_cal=.
replace lmp_cal=M01_LMP_SCDAT if(M01_LMP_SCDAT!=.)
replace lmp_cal=lmp_for_missing if (lmp_cal== .) 
replace lmp_cal=M01_SCRN_OBSSTDAT-(gest_age_us_week*7) if(M01_LMP_SCDAT==. & M01_GEST_AGE_MOS_SCORRES ==. )
replace lmp_cal=M01_SCRN_OBSSTDAT-(gest_age_us_month*30.5) if (M01_LMP_SCDAT==. & M01_GEST_AGE_WKS_SCORRES==.)
format lmp_cal %d

*calculating gestage at enrollment for all participants
	*in days
	gen gestage_days_enroll=.
	replace gestage_days_enroll=(M01_SCRN_OBSSTDAT-lmp_cal)
	label var gestage_days_enroll "Gestational age at enrollment (days)"

	*in weeks
			gen gestage_weeks_enroll=.
			replace gestage_weeks_enroll=gestage_days_enroll/7
			label var gestage_weeks_enroll "Gestational age at enrollment (weeks)"
		
				summ gestage_weeks_enroll

	*in trimesters
	gen tri_enroll=.
		replace tri_enroll=1 if(gestage_weeks_enroll>3 & gestage_weeks_enroll<14)
		replace tri_enroll=2 if(gestage_weeks_enroll>=14 & gestage_weeks_enroll<27)
		replace tri_enroll=3 if(gestage_weeks_enroll>=27 & gestage_weeks_enroll<43)	

*summarizing gestational age at enrollment
	summ gestage_days_enroll
	tab tri_enroll,m
****************************************************************
*Do Files For Form Merge and Data Cleaning

*include "ReMAPP-Data-Cleaning-Form-Merge-2022-01-20"

*creating subfolder for figures
shell mkdir plots


	***************************************************************
	*Label values used throughout the code
	 label define yesno 0 "no" 1 "yes"

	 label define yesno1 0 "no" 1 "yes" 9 "unknown"

	****************************************************************
	*Table a.1: Enrollment numbers for PRiSMA MNH Study

	*Creating variable for screened for PRiSMA - currently based on if date of screening recorded
		gen screened_prisma=.
		replace screened_prisma = 1 if M01_SCRN_OBSSTDAT!= .
		replace screened_prisma =0 if M01_SCRN_OBSSTDAT== .
		label var screened_prisma "Participant was screened for enrollment"
		label define screened_prisma 1"yes" 0"no"
		label val screened_prisma screened_prisma

	*Creating variable for eligibility for PRiSMA
		gen eligible_prisma=.
		replace eligible_prisma= 1 if (M01_AGE_IEORRES == 1 & M01_PC_IEORRES == 1 & M01_EXCL_YN_IEORRES == 0) 
		replace eligible_prisma=0 if (M01_AGE_IEORRES != 1 | M01_PC_IEORRES != 1 | M01_EXCL_YN_IEORRES != 0) 
		label var eligible_prisma "Participant was found eligible for PRiSMA"
		label def eligible_prisma 1"yes" 0"no"
		lab val eligible_prisma eligible_prisma
		
	*Creating variable for enrolled for PRiSMA - this is assuming you cannot consent and not enroll
	*"M01_CON_SIGNYN_DSDECOD" this variable is not available in our data set
		gen enrolled_prisma=.
		replace enrolled_prisma=1 if (M01_CON_YN_DSDECOD==1)
		replace enrolled_prisma=0 if ( M01_CON_YN_DSDECOD!=1)
		label var enrolled_prisma "Participant enrolled for PRiSMA"
		label define enrolled_prisma 1"yes" 2"no"
		
	****************************************************************
	*Table a.2:  Site demographics for PRiSMA MNH Study 

	*Creating maternal age at enrollment variable - using date at enrollment  
		
		*cleaning date variables
        gen dob=date(M01_BRTHDAT , "MDY")
	    format dob %td
		gen scrn_date=(M01_SCRN_OBSSTDAT)
		format scrn_date %td
	
		*cleaning age variable
		replace M01_ESTIMATED_AGE= . if(M01_ESTIMATED_AGE== -7)
		*destring M01_ESTIMATED_AGE, replace 
		
		*maternal age at enrollment 
		gen mat_age_enroll=.
		replace mat_age_enroll=(scrn_date-dob)/365
		replace mat_age_enroll=M01_ESTIMATED_AGE if mat_age_enroll==.
		label var mat_age_enroll "Maternal age at enrollment"
		ta mat_age_enroll,m
		
	*Creating BMI at enrollment variable
		*TBD
	
	*Creating variable for gestational age at enrollment 
		
		*converting dates of LMP and screening to date format
	
	*foreach x of varlist M01_LMP_SCDAT {
		*replace `x' = "" if(`x' =="SKIPPED")
		*gen date2=date(`x', "DMY") 
		*rename `x' `x'_str
		*rename date2 `x'
		*format `x' %d 
	*}
	
		*converting estimated gestational age variables to numeric
		*foreach x of varlist M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES {
		*replace `x' = "" if(`x' =="SKIPPED" | `x' == "UNDEFINED")
		*destring `x', replace 
		*}
	
		*calculating last menstrual cycle (LMP) for all participants
		
		*gen lmp_cal=.
		*replace lmp_cal=M01_LMP_SCDAT if(M01_LMP_SCDAT!=.)
		*replace lmp_cal=scrn_date-(M01_GEST_AGE_WKS_SCORRES*7) if(M01_LMP_SCDAT==. & M01_GEST_AGE_MOS_SCORRES ==. )
		*replace lmp_cal=scrn_date-(M01_GEST_AGE_MOS_SCORRES*30.5) if (M01_LMP_SCDAT==. & M01_GEST_AGE_WKS_SCORRES==.)
		*format lmp_cal %d
		label var lmp_cal "Calculated date of LMP at enrollment - incl est gest age"

		*calculating gestage at enrollment for all participants
			*in days
			
			*gen gestage_days_enroll=.
			*replace gestage_days_enroll=(scrn_date-lmp_cal)
			*label var gestage_days_enroll "Gestational age at enrollment (days)"
		
			*in weeks
			
			*gen gestage_weeks_enroll=.
			*replace gestage_weeks_enroll=gestage_days_enroll/7
			*label var gestage_weeks_enroll "Gestational age at enrollment (weeks)"
		
				summ gestage_weeks_enroll
				
				*looking at implausible gestational age at enrollment <4 weeks or >42
				list PREGNANCY_ID M01_SCRN_OBSSTDAT M01_LMP_SCDAT M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES lmp_cal gestage_days_enroll gestage_weeks_enroll if gestage_weeks_enroll>42 & gestage_weeks_enroll!=.
				
				*looking at implausible gestational age at enrollment <4 weeks or >42
				list PREGNANCY_ID M01_SCRN_OBSSTDAT M01_LMP_SCDAT M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES lmp_cal gestage_days_enroll gestage_weeks_enroll if gestage_weeks_enroll<4 & gestage_weeks_enroll!=.
			
		
		*in trimesters
		
		*gen tri_enroll=. 
		*replace tri_enroll=1 if(gestage_weeks_enroll>3 & gestage_weeks_enroll<14)
		*replace tri_enroll=2 if(gestage_weeks_enroll>=14 & gestage_weeks_enroll<27)
		*replace tri_enroll=3 if(gestage_weeks_enroll>=27 & gestage_weeks_enroll<43)	
	
	*Marital Status - married or cohabitating
		
		label define marital_stat1 1 "Married" 2 "Not married but living with partner" 3 "Divorced/seperated" 4 "Widowed" 5 "Single - never married"
		label values M02_MARITAL_SCORRES marital_stat1
		
		
		*creating variable for married or cohabitating - combining 1 and 2 categories of M02_MARITAL_SCORRES
		gen married=.
		replace married=1 if (M02_MARITAL_SCORRES==1 | M02_MARITAL_SCORRES==2)
		replace married=0 if (M02_MARITAL_SCORRES==3 | M02_MARITAL_SCORRES==4 | M02_MARITAL_SCORRES==5)
		label var married "Participant married or cohabitating at enrollment?"
		lab def married 1"Yes" 0"No"
		label values married married
		
	*Creating variable for parity - defined as woman who has not had a live birth
		
		*converting variables M03a_PH_LIVE_RPORRES to numeric
		
		
		*foreach x of varlist M03a_PH_LIVE_RPORRES {
		*replace `x' = "" if(`x' =="SKIPPED" | `x' == "UNDEFINED")
		*destring `x', replace 
		*}
		
		gen nulliparous=.
		replace nulliparous=1 if (M03a_PH_PREV_RPORRES==0 | M03a_PH_LIVE_RPORRES ==0)
		replace nulliparous=0 if (M03a_PH_LIVE_RPORRES >=1 & M03a_PH_LIVE_RPORRES!=.)
		label var nulliparous "No report of prior live birth"
		label values nulliparous yesno
		
		
****************************************************************
*Table 1.1: Aim 1 inclusion criteria for those enrolled in PRiSMA
	*All variables will start with aim1e_* - those screend but not enrolled will have missing values for all variables
	
	*1. Age 18-35
		gen aim1e_mage=.
		replace aim1e_mage=1 if (mat_age_enroll>=18 & mat_age_enroll<=35)
		replace aim1e_mage=0 if (mat_age_enroll<18 | mat_age_enroll>35)
		replace aim1e_mage=9 if mat_age_enroll==.
		replace aim1e_mage=. if enrolled_prisma==0
		label var aim1e_mage "Aim 1 Eligibility: Age 18-35"
		label values aim1e_mage yesno1
		
	
	*2. Gestational age <14 weeks
		gen aim1e_gestage=.
		replace aim1e_gestage=1 if (gestage_weeks_enroll>3 & gestage_weeks_enroll<14) 
		replace aim1e_gestage=0 if (gestage_weeks_enroll>=14 & gestage_weeks_enroll!=.)
		replace aim1e_gestage=9 if gestage_weeks_enroll==.
		replace aim1e_gestage=. if enrolled_prisma==0
		label var aim1e_gestage "Aim 1 Eligibility: Gestational age at enrollment <14"
		label values aim1e_gestage yesno1
		
		tab aim1e_gestage
	
	*3. BMI in early pregnancy (currenlty first trimester)
		
		*destring maternal weight measure (we have already in numeric format)
			
			*replace M05_WEIGHT_PERES1= . if (M05_WEIGHT_PERES1 =="SKIPPED")
			*replace M05_WEIGHT_PERES1="60.9" if (M05_WEIGHT_PERES1=="60.9i")
			*replace M05_WEIGHT_PERES1="44.5" if (M05_WEIGHT_PERES1=="44.5.")
			*destring M05_WEIGHT_PERES1, replace 
			
			*gen byte flag_notnumeric = real(M05_WEIGHT_PERES1)==.
			
		*destring maternal height measure (we have already in numeric format)
		
			*replace M05_HEIGHT_PERES1="" if (M05_HEIGHT_PERES1== "SKIPPED")
			*replace M05_HEIGHT_PERES1="158.4" if (M05_HEIGHT_PERES1=="158.4.")
			*destring M05_HEIGHT_PERES1, replace 
			
			*gen byte flag_notnumeric = real(M05_HEIGHT_PERES1)==.
		
		*gestage at anthropometric measure 
			
			*M05_ANT_PEDAT1 - date of 1st anthropometric measure
			
			**We have already in same format
			
			
			*foreach x of varlist M05_ANT_PEDAT1 {
			*replace `x' = "" if(`x' =="SKIPPED")
			*gen date2=date(`x', "DMY") 
			*rename `x' `x'_str
			*rename date2 `x'
			*format `x' %d 
		*}
		
			
			gen gestage_anthro1=(M05_ANT_PEDAT1-lmp_cal)/7 if M05_WEIGHT_PERES1!=.
				*need to think through if 1st anthro date wasn't first date of weight...
				*replace gestage_anthro1=(M05_ANT_PEDAT2-lmp_cal)/7 if M05_WEIGHT_PERES1==.
			label var gestage_anthro1 "Gestational age at 1st anthropometric measure" 
			
		*calculating BMI at 1st anthropometric visit
			gen BMI_1=M05_WEIGHT_PERES1/((M05_HEIGHT_PERES1/100)^2)
			label var BMI_1 "BMI at 1st anthropometric measure"
			
		*Aim 1 BMI Criteria
			gen aim1e_bmi=.
			replace aim1e_bmi=1 if (BMI_1>18.5 & BMI_1<30) 
			replace aim1e_bmi=0 if (BMI_1<18.5 | BMI_1>30) 
			replace aim1e_bmi=9 if (BMI_1==. | gestage_anthro1>20)
			replace aim1e_bmi=. if enrolled_prisma==0
			label var aim1e_bmi "Aim 1 Eligibility: BMI during early pregnancy"
			label values aim1e_bmi yesno1
	        ta aim1e_bmi,m
	*4. MUAC > 23cm
	
		*Destring muac (already in numeric format)
		
		*replace M05_MUAC_PERES1="" if (M05_MUAC_PERES1== "SKIPPED")
		*destring M05_MUAC_PERES1, replace 

		
		gen aim1e_muac=.
		replace aim1e_muac=1 if (M05_MUAC_PERES1 >23 & M05_MUAC_PERES1!=.)
		replace aim1e_muac=0 if (M05_MUAC_PERES1<23 | M05_MUAC_PERES1== 23)
		replace aim1e_muac=9 if M05_MUAC_PERES1==.
		replace aim1e_muac=. if enrolled_prisma==0
		label var aim1e_muac "Aim 1 Eligibility: MUAC >23cm"
		label values aim1e_muac yesno1
		ta aim1e_muac,m
	
	*5. Height > 153 cm
		gen aim1e_height=.
		replace aim1e_height=1 if (M05_HEIGHT_PERES1 >153 & M05_HEIGHT_PERES1!=.)
		replace aim1e_height=0 if (M05_HEIGHT_PERES1<153| M05_HEIGHT_PERES1== 153)
		replace aim1e_height=9 if M05_HEIGHT_PERES1==.
		replace aim1e_height=. if enrolled_prisma==0
		label var aim1e_height "Aim 1 Eligibility: Height >153cm"
		label values aim1e_height yesno1
		ta aim1e_height,m

	*6. Single Fetus 
	
	 *Destring muac
		
		*already in numeric 
		
		*replace M06_SINGLE_FAORRES1  ="" if (M06_SINGLE_FAORRES1  == "SKIPPED" | M06_SINGLE_FAORRES1 == "UNDEFINED")
		*destring M06_SINGLE_FAORRES1, replace 
		
		gen aim1e_singleton=.
		replace aim1e_singleton=1 if M06_SINGLE_FAORRES1==1
		replace aim1e_singleton=0 if M06_SINGLE_FAORRES1==0
		replace aim1e_singleton=9 if M06_SINGLE_FAORRES1 ==.
		replace aim1e_singleton=. if enrolled_prisma==0
		label var aim1e_singleton "Aim 1 Eligibility: Singleton fetus"
		label values aim1e_singleton yesno1
        ta aim1e_singleton,m
		
		
		
	*7. Normal blood pressure - at enrollment
		
		
		*foreach x of varlist M08_BPAVG_SYS_VSORRES1 M17_BP_SYS_VSORRES1 M08_BPAVG_DIA_VSORRES1 M17_BP_DIA_VSORRES1 {
		*replace `x' = "" if(`x' =="SKIPPED" | `x' == "UNDEFINED")
		*destring `x', replace 
		*}
		
		gen sysbp_norm=.
		replace sysbp_norm=1 if (M08_BPAVG_SYS_VSORRES1<140 | M08_BPAVG_SYS_VSORRES1== 140)
		***we donot have mapped form 17 so making it command
		*replace sysbp_norm=1 if M17_BP_SYS_VSORRES1<140
		replace sysbp_norm=0 if (M08_BPAVG_SYS_VSORRES1>140 & M08_BPAVG_SYS_VSORRES1!=.)
		***we donot have mapped form 17 so making it command
		*replace sysbp_norm=0 if (M17_BP_SYS_VSORRES1>140 & M17_BP_SYS_VSORRES1!=.)
		*replace sysbp_norm=9 if (M08_BPAVG_SYS_VSORRES1==. & M17_BP_SYS_VSORRES1!=.)
		replace sysbp_norm=9 if (M08_BPAVG_SYS_VSORRES1==.)
		ta sysbp_norm,m
		
		
		gen diabp_norm=.
		replace diabp_norm=1 if (M08_BPAVG_DIA_VSORRES1<90 | M08_BPAVG_DIA_VSORRES1== 90)
		*replace diabp_norm=1 if M17_BP_DIA_VSORRES1<90
		replace diabp_norm=0 if (M08_BPAVG_DIA_VSORRES1>90 & M08_BPAVG_DIA_VSORRES1!=.) 
		*replace diabp_norm=0 if (M17_BP_DIA_VSORRES1>90 & M17_BP_DIA_VSORRES1!=.)
		*replace diabp_norm=9 if (M08_BPAVG_DIA_VSORRES1==. & M17_BP_DIA_VSORRES1==.)
		replace diabp_norm=9 if (M08_BPAVG_DIA_VSORRES1==. )
		ta diabp_norm,m
		
		
		gen aim1e_bp=.
		replace aim1e_bp=1 if (sysbp_norm==1 & diabp_norm==1)
		replace aim1e_bp=0 if (sysbp_norm==0 | diabp_norm==0)
		replace aim1e_bp=9 if (sysbp_norm==9 | diabp_norm==9)
		replace aim1e_bp=. if enrolled_prisma==0
		label var aim1e_bp "Aim 1 Eligibility: Normal blood pressue - SBP<140 & DBP<90"
		label values aim1e_bp yesno1
		ta aim1e_bp
		
		drop sysbp_norm diabp_norm
		
	*8. Miscarriage in two consecutive pregnancies 
		 /*perhaps make a note that how currently collected is not clear it was two consecutive pregnancies*/
		 /*when do you make this missing? if missing and number of previous pregnancies >0*/
		 
			foreach x of varlist M03b_PH2_BS_RPORRES M03b_PH3_BS_RPORRES  {
			replace `x' = . if(`x' == -7 )
			*destring `x', replace 
			}
		 
		 gen miscarriage_1=0
		 replace miscarriage_1=1 if M03b_PH_BS_RPORRES==3
		 
		 gen miscarriage_2=0
		 replace miscarriage_2=1 if M03b_PH2_BS_RPORRES==3
		 
		 gen miscarriage_3=0
		 replace miscarriage_3=1 if M03b_PH3_BS_RPORRES==3
		 
		 gen miscarriage_tot=miscarriage_1+miscarriage_2+miscarriage_3
		 
		 gen aim1e_miscarriage=.
		 replace aim1e_miscarriage=1 if (M03a_PH_PREV_RPORRES==0) //women who were never pregnant
		 replace aim1e_miscarriage=1 if (miscarriage_tot<2)	
		 replace aim1e_miscarriage=0 if (miscarriage_tot>=2)
		 replace aim1e_miscarriage=9 if (miscarriage_tot==. & M03a_PH_PREV_RPORRES==1)
		 replace aim1e_bp=. if enrolled_prisma==0	
		 label var aim1e_miscarriage "Aim 1 Eligibility: <=1 miscarriage in two consecutive pregnancies"
		 label values aim1e_miscarriage yesno1
		 ta aim1e_miscarriage,m 
		 
		 
	*9. No preterm delivery or low birthweight 
		foreach x of varlist M03b_LB_WEIGHT  M03b_LB2_WEIGHT M03b_LB3_WEIGHT M04_LOWBIRTHWT_RPORRES1 M04_LOWBIRTHWT_RPORRES2 M04_LOWBIRTHWT_RPORRES3 M04_LOWBIRTHWT_RPORRES4 M04_LOWBIRTHWT_RPORRES5 M04_LOWBIRTHWT_RPORRES6 M04_LOWBIRTHWT_RPORRES7 M04_LOWBIRTHWT_RPORRES8 M04_LOWBIRTHWT_RPORRES9 M04_LOWBIRTHWT_RPORRES10 M04_LOWBIRTHWT_RPORRES11 M04_LOWBIRTHWT_RPORRES12 M04_LOWBIRTHWT_RPORRES13  M04_LOWBIRTHWT_RPORRES15  M04_LOWBIRTHWT_RPORRES17  M04_LOWBIRTHWT_RPORRES19  M04_LOWBIRTHWT_RPORRES21  M04_LOWBIRTHWT_RPORRES23  M04_LOWBIRTHWT_RPORRES25 M04_PRETERM_RPORRES1 M04_PRETERM_RPORRES2 M04_PRETERM_RPORRES3 M04_PRETERM_RPORRES4 M04_PRETERM_RPORRES5 M04_PRETERM_RPORRES6 M04_PRETERM_RPORRES7 M04_PRETERM_RPORRES8 M04_PRETERM_RPORRES9 M04_PRETERM_RPORRES10 M04_PRETERM_RPORRES11 M04_PRETERM_RPORRES12 M04_PRETERM_RPORRES13  M04_PRETERM_RPORRES15  M04_PRETERM_RPORRES17  M04_PRETERM_RPORRES19  M04_PRETERM_RPORRES21  M04_PRETERM_RPORRES23  M04_PRETERM_RPORRES25 M03b_LB_LENGTH_RPORRES ///
		M03b_LB2_LENGTH_RPORRES M03b_LB3_LENGTH_RPORRES {
			replace `x' = . if `x'== -7
			} 
		
		foreach x of varlist M03b_LB_WEIGHT  M03b_LB2_WEIGHT M03b_LB3_WEIGHT M04_LOWBIRTHWT_RPORRES1 M04_LOWBIRTHWT_RPORRES2 M04_LOWBIRTHWT_RPORRES3 M04_LOWBIRTHWT_RPORRES4 M04_LOWBIRTHWT_RPORRES5 M04_LOWBIRTHWT_RPORRES6 M04_LOWBIRTHWT_RPORRES7 M04_LOWBIRTHWT_RPORRES8 M04_LOWBIRTHWT_RPORRES9 M04_LOWBIRTHWT_RPORRES10 M04_LOWBIRTHWT_RPORRES11 M04_LOWBIRTHWT_RPORRES12 M04_LOWBIRTHWT_RPORRES13  M04_LOWBIRTHWT_RPORRES15  M04_LOWBIRTHWT_RPORRES17  M04_LOWBIRTHWT_RPORRES19  M04_LOWBIRTHWT_RPORRES21  M04_LOWBIRTHWT_RPORRES23  M04_LOWBIRTHWT_RPORRES25 M04_PRETERM_RPORRES1 M04_PRETERM_RPORRES2 M04_PRETERM_RPORRES3 M04_PRETERM_RPORRES4 M04_PRETERM_RPORRES5 M04_PRETERM_RPORRES6 M04_PRETERM_RPORRES7 M04_PRETERM_RPORRES8 M04_PRETERM_RPORRES9 M04_PRETERM_RPORRES10 M04_PRETERM_RPORRES11 M04_PRETERM_RPORRES12 M04_PRETERM_RPORRES13  M04_PRETERM_RPORRES15  M04_PRETERM_RPORRES17  M04_PRETERM_RPORRES19  M04_PRETERM_RPORRES21  M04_PRETERM_RPORRES23  M04_PRETERM_RPORRES25 M03b_LB_LENGTH_RPORRES ///
		M03b_LB2_LENGTH_RPORRES M03b_LB3_LENGTH_RPORRES {
			tab `x'
			}
		
		*Checks - this is a list of variable that have birthweights outside of expected ranges
		list PREGNANCY_ID M04_LOWBIRTHWT_RPORRES1 M04_LOWBIRTHWT_RPORRES2 M04_LOWBIRTHWT_RPORRES3 M04_LOWBIRTHWT_RPORRES4 M04_LOWBIRTHWT_RPORRES5 M04_LOWBIRTHWT_RPORRES6 M04_LOWBIRTHWT_RPORRES7 M04_LOWBIRTHWT_RPORRES8 M04_LOWBIRTHWT_RPORRES9 M04_LOWBIRTHWT_RPORRES10 M04_LOWBIRTHWT_RPORRES11 M04_LOWBIRTHWT_RPORRES12 M04_LOWBIRTHWT_RPORRES13  M04_LOWBIRTHWT_RPORRES15  M04_LOWBIRTHWT_RPORRES17  M04_LOWBIRTHWT_RPORRES19  M04_LOWBIRTHWT_RPORRES21  M04_LOWBIRTHWT_RPORRES23  M04_LOWBIRTHWT_RPORRES25 M03b_LB_WEIGHT if (M03b_LB_WEIGHT<500 | (M03b_LB_WEIGHT>5000 & M03b_LB_WEIGHT!=.))
		
		list PREGNANCY_ID M04_LOWBIRTHWT_RPORRES1 M04_LOWBIRTHWT_RPORRES2 M04_LOWBIRTHWT_RPORRES3 M04_LOWBIRTHWT_RPORRES4 M04_LOWBIRTHWT_RPORRES5 M04_LOWBIRTHWT_RPORRES6 M04_LOWBIRTHWT_RPORRES7 M04_LOWBIRTHWT_RPORRES8 M04_LOWBIRTHWT_RPORRES9 M04_LOWBIRTHWT_RPORRES10 M04_LOWBIRTHWT_RPORRES11 M04_LOWBIRTHWT_RPORRES12 M04_LOWBIRTHWT_RPORRES13  M04_LOWBIRTHWT_RPORRES15  M04_LOWBIRTHWT_RPORRES17  M04_LOWBIRTHWT_RPORRES19  M04_LOWBIRTHWT_RPORRES21  M04_LOWBIRTHWT_RPORRES23  M04_LOWBIRTHWT_RPORRES25  M03b_LB2_WEIGHT if (M03b_LB2_WEIGHT<500 | (M03b_LB2_WEIGHT>5000 & M03b_LB2_WEIGHT!=.))
		
		list PREGNANCY_ID M04_LOWBIRTHWT_RPORRES1 M04_LOWBIRTHWT_RPORRES2 M04_LOWBIRTHWT_RPORRES3 M04_LOWBIRTHWT_RPORRES4 M04_LOWBIRTHWT_RPORRES5 M04_LOWBIRTHWT_RPORRES6 M04_LOWBIRTHWT_RPORRES7 M04_LOWBIRTHWT_RPORRES8 M04_LOWBIRTHWT_RPORRES9 M04_LOWBIRTHWT_RPORRES10 M04_LOWBIRTHWT_RPORRES11 M04_LOWBIRTHWT_RPORRES12 M04_LOWBIRTHWT_RPORRES13  M04_LOWBIRTHWT_RPORRES15  M04_LOWBIRTHWT_RPORRES17  M04_LOWBIRTHWT_RPORRES19  M04_LOWBIRTHWT_RPORRES21  M04_LOWBIRTHWT_RPORRES23  M04_LOWBIRTHWT_RPORRES25  M03b_LB3_WEIGHT if (M03b_LB3_WEIGHT<500 | (M03b_LB3_WEIGHT>5000 & M03b_LB3_WEIGHT!=.))
		
		*Any lowbirthweight
		gen any_m04_lbw=.
		replace any_m04_lbw=0 if (M04_LOWBIRTHWT_RPORRES1==0 & M04_LOWBIRTHWT_RPORRES2==0 & M04_LOWBIRTHWT_RPORRES3==0 & M04_LOWBIRTHWT_RPORRES4==0 & M04_LOWBIRTHWT_RPORRES5==0 & M04_LOWBIRTHWT_RPORRES6==0 &  M04_LOWBIRTHWT_RPORRES7== 0 & M04_LOWBIRTHWT_RPORRES8== 0 & M04_LOWBIRTHWT_RPORRES9== 0 & M04_LOWBIRTHWT_RPORRES10== 0 & M04_LOWBIRTHWT_RPORRES11== 0 & M04_LOWBIRTHWT_RPORRES12== 0 & M04_LOWBIRTHWT_RPORRES13== 0 &  M04_LOWBIRTHWT_RPORRES15== 0 &  M04_LOWBIRTHWT_RPORRES17== 0 &  M04_LOWBIRTHWT_RPORRES19== 0 &  M04_LOWBIRTHWT_RPORRES21== 0 &  M04_LOWBIRTHWT_RPORRES23== 0 &  M04_LOWBIRTHWT_RPORRES25== 0 )
		
		gen any_lbw=.
		replace any_lbw=0 if (any_m04_lbw==0 & (M03b_LB_WEIGHT>2500 & M03b_LB_WEIGHT!=.) & (M03b_LB2_WEIGHT>2500 & M03b_LB2_WEIGHT!=.) & (M03b_LB3_WEIGHT>2500 & M03b_LB3_WEIGHT!=.))
		replace any_lbw=1 if (M04_LOWBIRTHWT_RPORRES1==1 | M04_LOWBIRTHWT_RPORRES2==1 | M04_LOWBIRTHWT_RPORRES3==1 | M04_LOWBIRTHWT_RPORRES4==1 | M04_LOWBIRTHWT_RPORRES5==1 | M04_LOWBIRTHWT_RPORRES6==1 | M04_LOWBIRTHWT_RPORRES7== 1 | M04_LOWBIRTHWT_RPORRES8== 1 | M04_LOWBIRTHWT_RPORRES9== 1 | M04_LOWBIRTHWT_RPORRES10== 1 | M04_LOWBIRTHWT_RPORRES11== 1 |M04_LOWBIRTHWT_RPORRES12== 1 | M04_LOWBIRTHWT_RPORRES13== 1 |  M04_LOWBIRTHWT_RPORRES15==1 |  M04_LOWBIRTHWT_RPORRES17== 1 |  M04_LOWBIRTHWT_RPORRES19== 1 |  M04_LOWBIRTHWT_RPORRES21== 1 |  M04_LOWBIRTHWT_RPORRES23== 1 |  M04_LOWBIRTHWT_RPORRES25== 1 )
		replace any_lbw=1 if (M03b_LB_WEIGHT<2500 | M03b_LB2_WEIGHT<2500 | M03b_LB3_WEIGHT<2500)
		ta any_lbw,m
		
		*Any preterm
		gen any_preterm=.
		replace any_preterm=0 if (M04_PRETERM_RPORRES1==0 & M04_PRETERM_RPORRES2==0 & M04_PRETERM_RPORRES3==0 & M04_PRETERM_RPORRES4==0 & M04_PRETERM_RPORRES5==0 & M04_PRETERM_RPORRES6==0 & M04_PRETERM_RPORRES7== 0 & M04_PRETERM_RPORRES8== 0 & M04_PRETERM_RPORRES9== 0 & M04_PRETERM_RPORRES10== 0 & M04_PRETERM_RPORRES11== 0 & M04_PRETERM_RPORRES12== 0 & M04_PRETERM_RPORRES13== 0 &  M04_PRETERM_RPORRES15== 0 &  M04_PRETERM_RPORRES17== 0 &  M04_PRETERM_RPORRES19== 0 &  M04_PRETERM_RPORRES21== 0 &  M04_PRETERM_RPORRES23== 0 &  M04_PRETERM_RPORRES25== 0 )
		replace any_preterm=1 if (M04_PRETERM_RPORRES1==1 | M04_PRETERM_RPORRES2==1 | M04_PRETERM_RPORRES3==1 | M04_PRETERM_RPORRES4==1 | M04_PRETERM_RPORRES5==1 | M04_PRETERM_RPORRES6==1 | M04_PRETERM_RPORRES7== 1| M04_PRETERM_RPORRES8== 1| M04_PRETERM_RPORRES9== 1| M04_PRETERM_RPORRES10== 1| M04_PRETERM_RPORRES11== 1| M04_PRETERM_RPORRES12== 1| M04_PRETERM_RPORRES13== 1|  M04_PRETERM_RPORRES15== 1|  M04_PRETERM_RPORRES17== 1|  M04_PRETERM_RPORRES19== 1|  M04_PRETERM_RPORRES21== 1|  M04_PRETERM_RPORRES23== 1|  M04_PRETERM_RPORRES25== 1)
		replace any_preterm=9 if (M03a_PH_PREV_RPORRES==1 & (M04_PRETERM_RPORRES1==99 & M04_PRETERM_RPORRES2==99 | M04_PRETERM_RPORRES3==99 & M04_PRETERM_RPORRES4==99 | M04_PRETERM_RPORRES5==99 | M04_PRETERM_RPORRES6==99))
		
		gen aim1e_lbw=.
		replace aim1e_lbw=1 if M03a_PH_PREV_RPORRES==0 & M03a_PH_PREV_RPORRES!= . //women who were never pregnant
		replace aim1e_lbw=1 if (any_lbw==0 & any_preterm==0) & any_lbw!= . & any_preterm!= .
		replace aim1e_lbw=0 if (any_lbw==1 | any_preterm==1) & any_lbw!= . & any_preterm!= .
		replace aim1e_lbw=9 if (M03a_PH_PREV_RPORRES==1 & (any_lbw==9 | any_preterm==9))
		replace aim1e_lbw=. if enrolled_prisma==0	
		label var aim1e_lbw "Aim 1 Eligibility: no previous preterm or lbw delivery"
		label values aim1e_lbw yesno1
	    ta aim1e_lbw 
		 
	*9. No previous neonatal or fetal death
		*neonatal death is defined <28 days old
		foreach x of varlist M03b_LB_DEATH_CAT_AGE M03b_LB2_DEATH_CAT_AGE M03b_LB3_DEATH_CAT_AGE {
			replace `x' = . if(`x' == -7)
			*destring `x', replace 
			}
		
	    gen any_neodeath=0
		replace any_neodeath=1 if (M03b_LB_DEATH_CAT_AGE==1 | M03b_LB2_DEATH_CAT_AGE == 1 | M03b_LB_DEATH_CAT_AGE == 1)
		
		gen any_stillbirth=0
		replace any_stillbirth=1 if (M03b_PH_BS_RPORRES==2 | M03b_PH2_BS_RPORRES == 2 | M03b_PH3_BS_RPORRES == 2)
		
		gen aim1e_death=.
		replace aim1e_death=1 if M03a_PH_PREV_RPORRES==0 //women who were never pregnant
		replace aim1e_death=1 if (any_neodeath==0 & any_stillbirth==0)
		replace aim1e_death=0 if (any_neodeath==1 | any_stillbirth==1)
		replace aim1e_death=9 if (M03a_PH_PREV_RPORRES==1 & (any_neodeath==9 | any_stillbirth==9))
		replace aim1e_death=. if enrolled_prisma==0	
		label var aim1e_death "Aim 1 Eligibility: no previous neonatal or fetal death"
		label values aim1e_death yesno1
	    ta aim1e_death
	
	  
************************************************************************************
*Generating Log File  
	capture log close
	log using "C:\Farrukh_data\Anemia\log_files\ReMAPP_Eligibility_2022-03-02.txt", text  replace

	*PRiSMA Enrollment
		*table eligible_prisma enrolled_prisma, by(screened_prisma)
			table (eligible_prisma) (enrolled_prisma) (screened_prisma)

	*ReMAPP Aim 1 Eligibility Criteria
	tab aim1e_mage
	tab aim1e_gestage
	tab aim1e_bmi
	tab aim1e_muac
	tab aim1e_height
	tab aim1e_singleton
	tab aim1e_bp
	tab aim1e_miscarriage
	tab aim1e_lbw
	tab aim1e_death
	
	log close 
	
	
	 
	*7. Iron deficieny - ferritin 
		/* how will we adjust ferritin for inflation */
		
	    gen aim1e_ferritin=.
 