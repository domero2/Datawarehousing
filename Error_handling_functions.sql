USER DEFINE FUNCTION FOR TEST STRING

-- Input ports
1.FIELD string (500)
2.T_LENGTH integer
2. NAME string (70)
---
IIF(ISNULL(FIELD) OR  RTRIM(LTRIM(FIELD)) =  '',
NULL,	
	IIF(LENGTH(FIELD) > T_LENGTH,  
		'8 ' || 'STRING LENGTH ERROR'||' ' || NAME || ': '|| FIELD, 
NULL))

/*Usefull function for test length of the string Filed is variable for incoming data
t_Length is varaiable which specify the length of the field Name is the name of the field*/

TEST NUMBER FUNCTION
--Input
1. FIELD string(500),
2. NUM_LENGTH integer,
3. Name  string(500)
---
IIF(ISNULL(FIELD) 
OR LTRIM(RTRIM(FIELD)) = '',
NULL,
	IIF(NOT IS_NUMBER(FIELD),
		'2 ' || 'NUMERIC FORMAT ERROR'||' ' || NAME|| ': ' || FIELD,              
	IIF( ABS(TO_DECIMAL(FIELD)) >= POWER(10,NUM_LENGTH) ,
		'5 ' || 'NUMERIC LENGTH ERROR'||' ' || NAME|| ': '|| FIELD,
NULL)))

/*function for checking if tested field is number if not it will return an error, and checking the length of string*/

TEST DATE
--Input
1. FIELD string(500),
2. FORMAT 
3. NAME
---
IIF(NOT ISNULL(FIELD) 
AND RTRIM(LTRIM(FIELD))  != ''  
AND NOT IS_DATE(FIELD, FORMAT),  
'1 ' || 'DATE FORMAT ERROR'||' ' || NAME|| ': '|| FIELD,
NULL)

/*function for checking if tested field is date if not it will return an error, and checking the date format*/

/* There was most popular tested function. Now we create output function.

##OUTPUT##*/
OUT STRING
--Input
1. FIELD string(500),
2. TEST_FIELD string(500)
--
IIF( 
ISNULL(FIELD) 
OR RTRIM(LTRIM(FIELD))  = ''  
OR NOT ISNULL(TEST_FIELD),
NULL,
FIELD
)

OUT DECIMAL
--Input
1. Data string(500)
2. TESTED_DATA string(500)
----
IIF( 
ISNULL(DATA) 
OR RTRIM(LTRIM(DATA))  = ''  
OR NOT ISNULL(TESTED_DATA)
,NULL,
TO_DECIMAL(:UDF.CLEAN_NUMERIC_STRING(DATA)))
-----------------------------FUNCTION
CLEAN_NUMERIC_STRING
--Input
S string(100)
--
REPLACECHR(0, S, ',', '')
/* zero means not case senstive, replace input string represent by 'S' char, where comma is present 
and delete comma.*/
OUT_DATE
--Input
1. DATA string(500),
2. TESTED_DATA string(500),
3. DATE_FORMAT string (50)
-----
IIF( 
ISNULL(DATA) 
OR RTRIM(LTRIM(DATA))  = ''  
OR NOT ISNULL(TESTED_DATA),
NULL,
TO_DATE(DATA, DATE_FORMAT)
)


/* Then we recognise error trades using out_ERROR_FLAG variable
*/
IIF(v_ERROR_MESSAGE='' OR ISNULL(v_ERROR_MESSAGE),NULL,'E')

/* we need to create variable v_ERROR_MESSAGE which checking if is null in tested field*/
IIF(ISNULL(v_TEST_FIELD1),'', v_TEST_FIELD1 || ' | ')||
IIF(ISNULL(v_TEST_FIELD2),'', v_TEST_FIELD2 || ' | ')
/*for v_Error_message variable we create output ports where we check if some fields has an error*/
IIF(LENGTH(v_ERROR_MESSAGE)>0, SUBSTR(v_ERROR_MESSAGE, 1, LENGTH(v_ERROR_MESSAGE)-3),'')

Vairables in mapping
/* For each field we create 5 ports:*/
1. in_FIELD1
2. v_FIELD1 (in_FIELD1)
3. v_TEST_FIELD1 (:UDF.TEST_STRING(v_FIELD1,15,'FIELD1'))
4. out_FIELD1_ERR (v_FIELD1)
5. out_FIELD1 (:UDF.OUT_STRING(v_FIELD1,v_TEST_FIELD1))

Filter (ERROR_FLAG='E')
/* then we create filter with condition ERROR_FLAG='E'
and to filter goes fields:
1. out_FIELD1_ERR
2. out_ERROR_FLAG
3. out_ERROR_MESSAGE
*/

