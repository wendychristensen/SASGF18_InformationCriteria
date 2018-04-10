/* Data and model interpretation for these examples can be accessed on the UCLA Institute for Digital Research and Education (IDRE) */
/* https://stats.idre.ucla.edu/sas/seminars/mlm_sas_seminar/ */

/*******************************************************************/
/* Example 2: Running and pulling information criteria for Model 1 */
/*******************************************************************/

/* Model 1 with ODS OUTPUT for expanded information criteria  */

proc mixed data = SASGF.hsb12 covtest noclprint IC;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
   ods output InfoCrit=IC_expanded_1;   *changed from IC_expanded to IC_expanded_1;
run;

data Model_expanded_1;               *changed from Model_expanded to Model_expanded_1;
set IC_expanded_1;                   *changed from IC_expanded to IC_expanded_1;
NAME = "Unconditional model";        *Names this model "Unconditional model", 19 characters long;
keep NAME AIC AICC BIC HQIC CAIC;
run;

/* Model 2 with ODS OUTPUT for expanded information criteria */

proc mixed data = SASGF.hsb12 covtest noclprint IC;
   class school;
   model mathach = meanses / solution ddfm = bw;
   random intercept / subject = school;
   ods output InfoCrit=IC_expanded_2;   *changed from IC_expanded to IC_expanded_2;
run;

data Model_expanded_2;               *changed from Model_expanded to Model_expanded_2;
set IC_expanded_2;                   *changed from IC_expanded to IC_expanded_2;
NAME = "School-level predictor";     *Names this model "School-level predictor", 21 characters long;
keep NAME AIC AICC BIC HQIC CAIC;
run;

/* Model 3 with ODS OUTPUT for expanded information criteria */

data hsbc;
  set SASGF.hsb12;
    cses = ses - meanses;
run;
proc mixed data = hsbc noclprint covtest noitprint IC;
  class school;
  model mathach = cses / solution ddfm = bw notest;
  random intercept cses / subject = school type = un gcorr;
  ods output InfoCrit=IC_expanded_3;   *changed from IC_expanded to IC_expanded_3;
run;

data Model_expanded_3;               *changed from Model_expanded to Model_expanded_3;
set IC_expanded_3;                   *changed from IC_expanded to IC_expanded_3;
NAME = "Student-level predictor";    *Names this model "Student-level predictor", 23 characters long;
keep NAME AIC AICC BIC HQIC CAIC;
run;

/* Model 4 with ODS OUTPUT for expanded information criteria */

proc mixed data = hsbc noclprint covtest noitprint IC;
  class school;
  model mathach = meanses sector cses meanses*cses sector*cses / solution ddfm = bw notest;
  random intercept cses / subject = school type = un;
  ods output InfoCrit=IC_expanded_4;   *changed from IC_expanded to IC_expanded_3;
run;

data Model_expanded_4;               *changed from Model_expanded to Model_expanded_4;
set IC_expanded_4;                   *changed from IC_expanded to IC_expanded_4;
NAME = "Cross-level interaction";    *Names this model "Cross-level interaction", 23 characters long;
keep NAME AIC AICC BIC HQIC CAIC;
run;

/****************************************************************************************/
/* Second step: Compare information criteria to select the "best" model                 */
/*   This step takes the default information criteria computed for each candidate model */
/*   and puts them into one data set (Model_compile).                                   */
/*   Ranks for each information criterion (AIC, AICC, BIC, CAIC, and HQIC) are computed */ 
/*   using PROC RANK, where a higher rank means that the model had a smaller value for  */ 
/*   each respective information criterion. A model with a rank of 1 is the model with  */
/*   the lowest criterion value. Ranks with non-zero decimal values indicate a tie with */
/*   one or more models.                                                                */
/*   These ranks are put into another data set (IC_ranks), and models are sorted by     */
/*   the ranks of each information criteria and displayed with a descriptive title      */
/****************************************************************************************/

/* Compiling model names and information criteria into one data set */

data Model_compile;
length NAME $ 23;    *Matches length of longest model name (23 characters);
set Model_expanded_1 Model_expanded_2 Model_expanded_3 Model_expanded_4;
run; 

/* Creating ranks based on each IC */

proc rank data=Model_compile out=IC_ranks;
   var AIC AICC BIC CAIC HQIC;
   ranks Rank_AIC Rank_AICC Rank_BIC Rank_CAIC Rank_HQIC;
run;


/* Displaying model names, AIC values, and ranks based on AIC */

proc sort data=IC_ranks;
by Rank_AIC;
run;

title "Model ranking by AIC (higher rank is better)";
proc print data=IC_ranks;
var NAME AIC Rank_AIC;
run;
title;

/* Displaying model names, AICC values, and ranks based on AICC */

proc sort data=IC_ranks;
by Rank_AICC;
run;

title "Model ranking by AICC (higher rank is better)";
proc print data=IC_ranks; 
var NAME AICC Rank_AICC;
run;
title;

/* Displaying model names, BIC values, and ranks based on AIC */

proc sort data=IC_ranks;
by Rank_BIC;
run;

title "Model ranking by BIC (higher rank is better)";
proc print data=IC_ranks;
var NAME BIC Rank_BIC;
run;
title;

/* Displaying model names, CAIC values, and ranks based on CAIC */


proc sort data=IC_ranks;
by Rank_CAIC;
run;

title "Model ranking by CAIC (higher rank is better)";
proc print data=IC_ranks;
var NAME CAIC Rank_CAIC;
run;
title;

/* Displaying model names, HQIC values, and ranks based on HQIC */

proc sort data=IC_ranks;
by Rank_HQIC;
run;

title "Model ranking by HQIC (higher rank is better)";
proc print data=IC_ranks;
var NAME HQIC Rank_HQIC;
run;
title;

