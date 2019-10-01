/*
Business problem: They need to get last trade for coherent product group (SOR_TRANS_INSTR_CODE_INT_SRC) from target table. 
Solution:
Trades from target table was gouped by (SOR_TRANS_INSTR_CODE_INT_SRC) using partition by clause, and ordered by (sor_trans_id) desc. 
Then we get only last trades, because we specify RN as 1 and other filters after where clause.

This join is first step before join coherent trade which we retrieve, with incoming data in first load.

*/
SELECT  
SOR_TRANS_CODE AS SOR_TRANS_CODE,
TRUNC(TRADE_TIME) AS TRADE_TIME,
    TRADE_PRICE AS TRADE_PRICE,
    TRANS_NETAMOUNT as TRANS_NETAMOUNT
FROM
	(SELECT 
		SOR_TRANS_CODE AS SOR_TRANS_CODE,
    TRUNC(TRADE_TIME) AS TRADE_TIME,
    TRADE_PRICE AS TRADE_PRICE,
    TRANS_NETAMOUNT as TRANS_NETAMOUNT,
	ROW_NUMBER()OVER (PARTITION BY SOR_TRANS_CODE ORDER BY sor_trans_id desc) RN
FROM TableA
where  PRODUCT_TYPE in ('ABCD', 'EFG')
AND TRADE_QTY  IN(1,-1)
	) RN
WHERE
RN= 1

/*
Logic for join:
Join with DIM_AC:
Step1:  IF CPTY_CODE = 'NDGIII' perform direct join:
   TE.COUNTERPARTY_CODE = DIM_ACC.UCNDG
Step2: IF join from 1 is not succesfull or CTP_CODE_TYPE <> 'NDG' then
   a. Join TE.COUNTERPARTY_CODE = MV_MR.MATCHCODE and in next step
   b. Join MV_MR.NDG = DIM_ACC.UCNDG
If more than one MATCHCODE is obtained for each CTPY_CODE, in the MV_MR table,
following steps should be implemented to select one row:
   a. IF exists, take row where SOURCE = 'DOMEROPL'
   b. ELSE, first encountered, where MV_MR.SOURCE starts with 'KAK' string
   c. ELSE, first encountered, selecting always MV_MR. SOURCE = 'JARO' as the last one
   d. ELSE, take any row matching the join
Step3: IF join from 2a and 2b not successful and CTPY_CODE_SRC contains '_', join on the part 
       following ‘_’ and preceding ‘_” sign need to be tried (in this order). E.g. when CTPY_CODE_SRC=’ABC_DGF’,  try joining on ‘DGF’ first and then on ‘ABC’
Solution:
*/
--For step one was prepared the lookup which get UCNDG for coherent COUNTERPARTY and used in field logic LKP.LKP_DIM_ACCOUNT_CHECK_NDG.
/*Step 2 Data was grouped by matchcode and ordered according if, else logic in join description. ROW_NUMBER() clause 
return only one trade for each MATCHCODE, and order by clause will specify which of these it will be,
as a first will return where SOURCE = DOMEROPL*/
:LKP.LKP_GET_NDG
SELECT NDG as NDG, 
MATCHCODE as MATCHCODE
FROM 
(SELECT MATCHCODE, NDG,
ROW_NUMBER() OVER (PARTITION BY MATCHCODE ORDER BY 
CASE
  WHEN SOURCE = 'DOMEROPL' THEN 1 
  WHEN SOURCE LIKE 'KAK%' THEN 2
  WHEN SOURCE = 'JARO' THEN 3
  ELSE 4
END) RN
FROM $$p_s_MV_MRIOP
)
WHERE RN = 1


DECODE(TRUE,
in_CPTY_CODE_TYPE_SRC='NDG',
in_COUNTERPARTY_CODE_INT_SRC,
NOT ISNULL(:LKP.LKP_DIM_ACCOUNT_CHECK_NDG(:LKP.LKP_GET_NDG(in_CPTY_CODE_TYPE_SRC))), 
:LKP.LKP_GET_NDG(in_CPTY_CODE_TYPE_SRC),

INSTR(in_COUNTERPARTY_ID, '_') > 0 AND NOT ISNULL(:LKP.LKP_DIM_ACCOUNT_CHECK_NDG(:LKP.LKP_GET_NDG(v_CPTY_CODE_AFTER))), 
:LKP.LKP_GET_NDG(v_CPTY_CODE_AFTER),

INSTR(in_CPTY_CODE_TYPE_SRC, '_') > 0 AND NOT ISNULL(:LKP.LKP_DIM_ACCOUNT_CHECK_NDG(:LKP.LKP_GET_NDG(v_CPTY_CODE_BEFORE))), 
:LKP.LKP_GET_NDG(v_CPTY_CODE_BEFORE),

NULL)
--STEP 3
Varibles:  
v_CPTY_CODE_BEFORE = SUBSTR(in_COUNTERPARTYCODE_TYPE_SRC, 1, INSTR(in_COUNTERPARTYCODE_TYPE_SRC, '_')- 1)
v_CPTY_CODE_AFTER = SUBSTR(in_COUNTERPARTYCODE_TYPE_SRC, INSTR(in_COUNTERPARTYCODE_TYPE_SRC, '_')+1, LENGTH(in_COUNTERPARTYCODE_TYPE_SRC))



---JOin for lookups---
SELECT  DISTINCT
ID AS ID,
	UPPER(A.ISIN) AS ISIN,
	A.POSITION_MATURITY AS POSITION_MATURITY
FROM
	First_table A,
	(SELECT 
		ISIN,
		MAX(ID)AS IDD,
		MAX(CON_EXPIRY) as CON_EXPIRY
	FROM 
		First_table A
	WHERE 
		TRUNC(CON_EXPIRY) > TRUNC(TO_DATE(SYSDATE)) AND
		SEC_TYPE = 'FUYU'
	GROUP BY
		ISIN
	) B
WHERE
	TRUNC(A.CON_EXPIRY) > TRUNC(TO_DATE(SYSDATE)) AND
	A.ISIN = B.ISIN AND
	A.CON_EXPIRY = B.CON_EXPIRY AND
	A.SEC_TYPE = 'FUTR'AND
	A.ID = B.IDD


/*HOw select many columns from lookup with partition by*/

SELECT DISTINCT
TE.ISIN AS ISIN,
TE.TRADE_STRUCTURED AS TRADE_STRUCTURED,
TE.TV_TSTAMP AS TV_TSTAMP,
TE.ID AS ID						 
FROM
(
	SELECT
		MAX(TE1.KG1_T_TRADES_ID) OVER (PARTITION BY TE1.DEALID, TE1.PRODUCT_TYPE) AS MAX_ID,
		TE1.*
	FROM TABLE_LDD TE1,
		 TABLE_TRM STE
	WHERE STE.STATUS_FLAG = 'N'
	AND STE.DEALID = TE1.DEALID
	AND STE.PRODUCT_TYPE = TE1.PRODUCT_TYPE
) TE
WHERE TE.MAX_ID = TE.KG1_T_TRADES_ID
ORDER BY TE.DEALID, TE.PRODUCT_TYPE
--


