CREATE OR REPLACE PROCEDURE ADD_PAYMENT_DATE
(  p_ACTUAL_DATE IN T_DM_TEMP_REPAYMENT_A.ACTUAL_DATE%TYPE,
   p_INSTRUMENT_ISIN_KEY IN T_DM_TEMP_REPAYMENT_A.INSTRUMENT_ISIN_KEY%TYPE,
   p_CUSTODY_ACCOUNT_KEY IN T_DM_TEMP_REPAYMENT_A.CUSTODY_ACCOUNT_KEY%TYPE,
   p_NOMINAL_EUR_VAL IN T_DM_TEMP_REPAYMENT_A.NOMINAL_EUR_VAL%TYPE,
   p_INTERVAL_TYPE IN T_DM_TEMP_REPAYMENT_A.INTERVAL_TYPE%TYPE,
   p_FIRST_PAYMENT_DATE IN T_DM_TEMP_REPAYMENT_A.ACTUAL_DATE%TYPE,
   p_LAST_PAYMENT_DATE IN T_DM_TEMP_REPAYMENT_A.ACTUAL_DATE%TYPE,
   p_AMORTIZATION_TYPE_TR IN T_DM_TEMP_REPAYMENT_A.AMORTIZATION_TYPE_TR%TYPE,
   p_dummy OUT varchar2
   )
IS
	v_YEAR NUMBER;
	v_QUARTER NUMBER;
	v_MONTH NUMBER;
	v_PAYMENT_DATE DATE;
	v_FIRST_PAYMENT_DATE DATE;
	v_INTERVAL_COUNT NUMBER;
	v_MON_NUMBER NUMBER;
	v_AMOUNT_EUR_VAL NUMBER(17,2);
	v_NOMINAL_EUR_VAL NUMBER(17,2);
BEGIN
	
	v_FIRST_PAYMENT_DATE := p_FIRST_PAYMENT_DATE;
    v_NOMINAL_EUR_VAL := p_NOMINAL_EUR_VAL;
	v_AMOUNT_EUR_VAL :=0;
	
	IF p_FIRST_PAYMENT_DATE > p_LAST_PAYMENT_DATE THEN
 		v_PAYMENT_DATE := p_LAST_PAYMENT_DATE;
 	END IF;
 	 
  	v_QUARTER := GET_QUARTER(v_PAYMENT_DATE);
    v_MONTH := GET_MONTH(v_PAYMENT_DATE);
   	v_YEAR := GET_YEAR(v_PAYMENT_DATE);
    select floor(months_between(v_FIRST_PAYMENT_DATE,v_PAYMENT_DATE)) 
	INTO v_MON_NUMBER from DUAL;
	v_INTERVAL_COUNT := TRUNC(v_MON_NUMBER/p_INTERVAL_TYPE);
	
	 IF p_AMORTIZATION_TYPE_TR IN (3,4) THEN 
 	v_AMOUNT_EUR_VAL := ROUND(v_NOMINAL_EUR_VAL/(v_INTERVAL_COUNT),2);
 	ELSE
 	v_AMOUNT_EUR_VAL := 0;
 	END IF;
 

	
  WHILE v_FIRST_PAYMENT_DATE >= v_PAYMENT_DATE LOOP
	   
  INSERT INTO T_DM_ABS_REPAYMENT_A ("ACTUAL_DATE", "INSTRUMENT_ISIN_KEY",  
  "CUSTODY_ACCOUNT_KEY", "PAYMENT_DATE", "NOMINAL_EUR_VAL","AMOUNT_EUR_VAL",
  "YEAR", "QUARTER", "MONTH"
 )   VALUES (p_ACTUAL_DATE, p_INSTRUMENT_ISIN_KEY,
 p_CUSTODY_ACCOUNT_KEY, v_PAYMENT_DATE, v_NOMINAL_EUR_VAL, v_AMOUNT_EUR_VAL,
 v_YEAR, v_QUARTER, v_MONTH
);
	
    v_PAYMENT_DATE := ADD_MONTHS(v_PAYMENT_DATE,p_INTERVAL_TYPE);
	v_NOMINAL_EUR_VAL := ROUND((v_NOMINAL_EUR_VAL -v_AMOUNT_EUR_VAL),2);
   	v_QUARTER := GET_QUARTER(v_PAYMENT_DATE);
 	v_MONTH := GET_MONTH(v_PAYMENT_DATE);
   	v_YEAR := GET_YEAR(v_PAYMENT_DATE);
    v_INTERVAL_COUNT := v_INTERVAL_COUNT -1;
   
     IF v_INTERVAL_COUNT = 0 THEN
	v_AMOUNT_EUR_VAL := v_AMOUNT_EUR_VAL + v_NOMINAL_EUR_VAL;
	v_NOMINAL_EUR_VAL := 0;
	v_PAYMENT_DATE := v_FIRST_PAYMENT_DATE;

	END IF;
   
  END LOOP;
 COMMIT;
 p_dummy := 'Y';
/*======================================================================*/
/* Author: Albert Majcher                                               */
/* Purpose: PROCEDURE used to generate payment dates, nominal           */
/* and amount values. Based on input ports from REPAYMENT_TEMP          */
/* v_dummy additional variable used to perform procedure on informatica*/                                    */
/*======================================================================*/
END;