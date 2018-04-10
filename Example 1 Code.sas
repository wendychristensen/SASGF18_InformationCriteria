/* Data and model interpretation for these examples can be accessed on the UCLA Institute for Digital Research and Education (IDRE) */
/* https://stats.idre.ucla.edu/sas/seminars/mlm_sas_seminar/ */

/***************************************************************************/
/* Example 1.1 - Method 1: Pulling default information criteria from MIXED */
/***************************************************************************/

/* Unconditional means model */

proc mixed data = SASGF.hsb12 covtest noclprint;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
run;

/* Unconditional means model with ODS output statement needed to read out default information critera  */

proc mixed data = SASGF.hsb12 covtest noclprint;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
   ods output FitStatistics=IC_default;  *ODS table name is FitStatistic, output is named IC_default;
run;

/* Pulling and displaying default information criteria */

data ModelAIC;
set IC_default;
if Descr="AIC (smaller is better)";
AIC=Value;
keep AIC;
run;

data ModelAICC;
set IC_default;
if Descr="AICC (smaller is better)";
AICC=Value;
keep AICC;
run;

data ModelBIC;
set IC_default;
if Descr="BIC (smaller is better)";
BIC=Value;
keep BIC;
run;

data Model_default;
merge ModelAIC ModelAICC ModelBIC;
NAME="Unconditional Model"; *Creates a variable to name this model in the output;
run;

title "Default information criteria produced for the unconditional means model";
proc print data=Model_default; 
var NAME AIC AICC BIC;
run;
title;

/*****************************************************************************************/
/* Example 1.2 - Method 2: Pulling expanded information criteria in MIXED with IC option */
/*****************************************************************************************/

/* Unconditional means model - note the addition of the IC option to the PROC MIXED statement */

proc mixed data = SASGF.hsb12 covtest noclprint IC;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
run; 

/* Unconditional means model with ODS output statement needed to read out expanded information critera  */

proc mixed data = SASGF.hsb12 covtest noclprint IC;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
   ods output InfoCrit=IC_expanded;      *ODS table name is InfoCrit, output is named IC_expanded;
run;

/* Pulling and displaying expanded information criteria */

data Model_expanded;
set IC_expanded;
NAME = "Unconditional Model";
keep NAME AIC AICC BIC HQIC CAIC;
run;

title "Expanded information criteria produced for the unconditional means model";
proc print data=Model_expanded;
var NAME AIC AICC BIC CAIC HQIC;
run;
title;

/*****************************************************************************************************************************************/
/* Example 1.3 - Method 3: Computing information criteria by pulling likelihood, number of parameters, and sample size from MIXED output */
/*****************************************************************************************************************************************/
/* This method requires multiple parts of the MIXED output to be read out, put into different data  */
/* sets, which are then compiled into one to facilitate model comparison.							*/
/*																									*/
/*    Model_Likelihood: Retains model likelihood (variable: Likelihood)                             */   
/*	  Model_Parms: Retains number of model parameters (variable: Parms)                             */
/*    m: Retains m-based (Level 2 or cluster) sample size (variable: m)                             */
/*    N: Retains N-based (Level 1, or total) sample size (variable: N)                              */
/*    Model_manual: Merges the likelihood, number of parameters, and sample sizes                   */
/*               Includes a new variable that gives the model a name                                */
/*            (*)Computes AIC, which does not incorporate sample size                               */
/*            (*)Computes AICC(N), using N-based sample size                                        */
/*               Computes AICC(m), using m-based sample size                                        */
/*				 Computes BIC(N), using N-based sample size                                         */
/*            (*)Computes BIC(m), using m-based sample size                                         */
/*               Computes CAIC(N), using N-based sample size                                        */
/*            (*)Computes CAIC(m), using m-based sample size                                        */
/*               Computes HQIC(N), using N-based sample size                                        */
/*            (*)Computes HQIC(m), using m-based sample size                                        */
/*																									*/
/*  (*) Indicates that this computation the one used by PROC MIXED; differences between these       */
/*      manually-computed information criteria and the ones produced by MIXED come from rounding    */
/****************************************************************************************************/

/* Unconditional means model */

proc mixed data = SASGF.hsb12 covtest noclprint;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
run;

/* Unconditional means model with ODS output statement needed to read out component parts of information criteria formulae */

ods trace on;
proc mixed data = SASGF.hsb12 covtest noclprint;
   class school;
   model mathach = / solution;
   random intercept / subject = school;
   ods output Dimensions=parms_m_sample;                       *ODS table name is Dimensions, output is named parms_m_sample);
   ods output NObs=N_sample;                                   *ODS table name is NObs, output is named N_sample;
   ods output FitStatistics=IC_default;                        *ODS table name is FitStatistics, output is called IC_default;
run;
ods trace off;

/* Isolating component parts */

data Model_Likelihood; 
set IC_default;
if Descr="-2 Res Log Likelihood";
Likelihood=Value;
keep Likelihood;
run;

data Model_Parms; 
set parms_m_sample;
if Descr="Covariance Parameters";
Parms=Value;
keep Parms;
run;

data N; 
set N_sample;
if Label="Number of Observations Used";
keep N;
run;

data m;
set parms_m_sample;
if Descr="Subjects";
m=Value;
keep m;
run;

/* Using components to compute sample size-dependent information criteria using N and m */

data Model_manual;
merge Model_Likelihood Model_Parms N m;
NAME = "Unconditional Model";  *Creates a variable to name this model in the output;
AIC = Likelihood + (2*Parms);
AICC_N = Likelihood + (2*Parms)*(N/(N-Parms-1));
AICC_m = Likelihood + (2*Parms)*(m/(m-Parms-1));
BIC_N = Likelihood + log(N)*Parms;
BIC_m = Likelihood + log(m)*Parms;
CAIC_N = Likelihood + (log(N)+1)*Parms;
CAIC_m = Likelihood + (log(m)+1)*Parms;
HQIC_N = Likelihood + (2*Parms)*(log(log(N)));
HQIC_m = Likelihood + (2*Parms)*(log(log(m)));
run;

title "Nine computed information criteria - all except AIC are sample size-dependent";
proc print data=Model_manual;
var NAME AIC AICC_N AICC_m BIC_N BIC_m CAIC_N CAIC_m HQIC_N HQIC_m;
run;
title;

/* Demonstration: compare sample-dependent ICs computed by PROC MIXED with those computed manually */

data IC_compare;
merge Model_expanded Model_manual;
by NAME;
run;

title "Comparing the manually-computed information criteria that match those produced by MIXED";
proc print data=IC_compare;
var NAME AICC AICC_N BIC BIC_m CAIC CAIC_m HQIC HQIC_m; 
run;
title;  *Note that these are identical (within rounding);

title "Comparing the manually-computed information criteria that do not match those produced by MIXED";
proc print data=IC_compare;
var NAME AICC AICC_m BIC BIC_N CAIC CAIC_N HQIC HQIC_N; 
run;
title;  *Note that these are slightly different from each other;
