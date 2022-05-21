*********************************************************
*Calculating Gestational Age
*PRiSMA 
*Last Updated: 05/06/2022
*********************************************************

*Working Directory - should be updated by user
cd "C:\Farrukh_data\Anemia\data" // UPDATE BY USER 


*Do Files For Form Merge and Data Cleaning

*include "ReMAPP-Data-Cleaning-Form-Merge-2022-03-28.do"

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


keep if M01_CON_YN_DSDECOD== 1

duplicates report SUBJID
duplicates report PREGNANCY_ID

*********************************************************
*Step 1: Data Cleaning

*destring variables
**Already string in our dataset

/*
foreach x of varlist M06_US_GA_WEEKS_AGE1 M06_US_GA_DAYS_AGE1 M01_GEST_AGE_WKS_SCORRES ///
					 M01_GEST_AGE_MOS_SCORRES {
			replace `x' = "" if(`x' =="SKIPPED" | `x' == "UNDEFINED")
			destring `x', replace 
		}

*/

*cleaning continuous variables
	foreach x of varlist  ///
	M07_CBC_HB_LBORRES1 M07_CBC_HB_LBORRES2 M07_CBC_HB_LBORRES3 M07_CBC_HB_LBORRES4 M07_HB_POC_LBORRES1 M07_HB_POC_LBORRES2 M07_HB_POC_LBORRES3 M07_HB_POC_LBORRES4 M08_SPHB_LBORRES1 M08_SPHB_LBORRES2 M08_SPHB_LBORRES3 M08_SPHB_LBORRES4 M08_SPHB_LBORRES5 M08_SPHB_LBORRES6 M08_SPHB_LBORRES7 M08_SPHB_LBORRES8 M08_SPHB_LBORRES9 M08_SPHB_LBORRES10 M08_SPHB_LBORRES11 M08_SPHB_LBORRES12 M08_SPHB_LBORRES13  ///
	M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES {
		replace `x' = . if `x' == -7
		destring `x', replace 
}		

*converting dates to date format

*M11_INF_1_DSSTDAT (form 11 data is not available)

/*
foreach x of varlist M01_LMP_SCDAT M01_SCRN_OBSSTDAT M01_EDD_SCDAT  {
		replace `x' = "" if(`x' =="SKIPPED")
		gen date2=date(`x', "DMY") 
		rename `x' `x'_str
		rename date2 `x'
		format `x' %d 
		}
*/

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

gen gest_age_month =  gest_age_missing/30.5
*replace gest_age_month=  round(gest_age_month)

replace M01_GEST_AGE_WKS_SCORRES= gest_age_week if  M01_GEST_AGE_WKS_SCORRES== .

replace M01_GEST_AGE_MOS_SCORRES= gest_age_month if  M01_GEST_AGE_MOS_SCORRES== .

			
		
*********************************************************
*Step 2: Calculate the EDD based on first ultrasound in M06

	gen M06_US_OHOSTDAT1_dt=date(M06_US_OHOSTDAT1, "MDY")
    	format M06_US_OHOSTDAT1_dt %d 

		

	gen EDDATUSG=(M06_US_OHOSTDAT1_dt - M06_US_GA_WEEKS_AGE1*7 - M06_US_GA_DAYS_AGE1) + 280
	    	format EDDATUSG %d 

	label var EDDATUSG "EDD based on first ultrasound"


*********************************************************
*Step 3: Calculate EDD based on both LMP date, ultrasound, and estimation

*calculate EDD by last menstrual date (LMP)
    replace M01_LMP_SCDAT= lmp_for_missing if M01_LMP_SCDAT==.
	gen LMPEDD = M01_LMP_SCDAT + 280
	*replace LMPEDD= lmp_for_missing if M01_LMP_SCDAT==.
	format LMPEDD  %d 
	label var LMPEDD "EDD based on date of last menstrual cycle"
	 
*calculate EDD by estimated GA weeks 
    gen EDDUSGEST_WKS = (M01_SCRN_OBSSTDAT - M01_GEST_AGE_WKS_SCORRES * 7) + 280
	
*calculate EDD by estimated GA months
    gen EDDUSGEST_MOS = (M01_SCRN_OBSSTDAT - M01_GEST_AGE_MOS_SCORRES * 30.5) + 280
	
*take estimated GA weeks first, if NA, then take estimated GA months
    gen EDDUSGEST = . 
	replace EDDUSGEST = EDDUSGEST_WKS
	replace EDDUSGEST = EDDUSGEST_MOS if EDDUSGEST_WKS==.
	format EDDUSGEST %d
	label var EDDUSGEST "EDD based on estimated gestational weeks"

*calculate GA in days at enrollment, based on ultrasound EDD
    gen GAUSGSCRNDAYS = (M01_SCRN_OBSSTDAT - (EDDATUSG - 280))
	label var GAUSGSCRNDAYS "gestational age at enrollment based on ultrasound EDD"

*calculate GA in days at enrollment, based on LMP
    gen GALMPSCRNDAYS = M01_SCRN_OBSSTDAT - M01_LMP_SCDAT
	label var GALMPSCRNDAYS "gestational age at enrollment based on LMP"
	
	
*absolute difference between GA days (LMP) and GA days (USG)
    gen GA_LMP_USG_DIFF = abs(GALMPSCRNDAYS - GAUSGSCRNDAYS)
	label var  GA_LMP_USG_DIFF "absolute difference between LMP vs USG GA days at enrollment"
	
*******************************************************************************
*determine the best source of calculating EDD
 /* 1: Use LMPEDD if 
		1) ultrasound GA weeks is between [16, 21] and 
			absolute difference between ultrasound GA days and LMP GA days <= 10, or
		2) ultrasound GA weeks is between [22, 27] and 
			absolute difference between ultrasound GA days and LMP GA days <= 14, or
		3) ultrasound GA weeks is greater than 28 and 
			absolute difference between ultrasound GA days and LMP GA days <= 21
    2: Use EDDATUSG if
		1) ultrasound GA weeks is between [0, 15], or
		2) ultrasound GA weeks is between [16, 21] and 
			absolute difference between ultrasound GA days and LMP GA days > 10, or
		3) ultrasound GA weeks is between [22, 27] and 
			absolute difference between ultrasound GA days and LMP GA days > 14, or
		4) ultrasound GA weeks is greater than 28 and 
			absolute difference between ultrasound GA days and LMP GA days > 21
     3: Use EDDATUSG if GAUSGSCRNDAYS is not missing
     4: Use LMPEDD if GALMPSCRNDAYS is not missing
     5: use M01_EDD_SCDAT if M01_EDD_SCDAT is not missing
     6: otherwise set as NA */



gen BESTEDD =.
	replace BESTEDD=LMPEDD if ((M06_US_GA_WEEKS_AGE1 >= 16) & (M06_US_GA_WEEKS_AGE1 <= 21) & (GA_LMP_USG_DIFF <= 10)) | ///
       ((M06_US_GA_WEEKS_AGE1 >= 22) & (M06_US_GA_WEEKS_AGE1 <= 27) & (GA_LMP_USG_DIFF <= 14)) | ///
       ((M06_US_GA_WEEKS_AGE1 > 28) & (GA_LMP_USG_DIFF <= 21))
	   
	replace BESTEDD=EDDATUSG if ((M06_US_GA_WEEKS_AGE1 >= 0) & (M06_US_GA_WEEKS_AGE1 <= 15)) | ///
       ((M06_US_GA_WEEKS_AGE1 >= 16) & (M06_US_GA_WEEKS_AGE1 <= 21) & (GA_LMP_USG_DIFF > 10)) | ///
       ((M06_US_GA_WEEKS_AGE1 >= 22) & (M06_US_GA_WEEKS_AGE1 <= 27) & (GA_LMP_USG_DIFF > 14)) | ///
       ((M06_US_GA_WEEKS_AGE1 > 28) & (GA_LMP_USG_DIFF > 21)) 
	
	
	replace BESTEDD=EDDATUSG if GALMPSCRNDAYS==.
	
	replace BESTEDD=LMPEDD if GAUSGSCRNDAYS==.
	
	replace BESTEDD=M01_EDD_SCDAT if GALMPSCRNDAYS==. & GAUSGSCRNDAYS==.
   
*************************************************************************
*step 5: calculate GA at birth based on BESTEDD
gen GA_LABOR = (M11_INF_1_DSSTDAT - (BESTEDD - 280))/7

 
**************************************************************************
*step 6: histograms

*Histogram of gestational age at birth
hist GA_LABOR

   *Indicator of outlier, if GA_LBAOR is outside the range (0, 42], it's an outlier
         gen GA_LABOR_OUTLIER = . 
		 replace GA_LABOR_OUTLIER=1 if (GA_LABOR <=0 | GA_LABOR > 42) 
		 
	*Histogram of gestation age at birth with outliers removed
		 hist GA_LABOR if GA_OUTLIER!=1
		 

gen gestage_enroll=(M01_SCRN_OBSSTDAT - (BESTEDD - 280))/7
hist gestage_enroll
