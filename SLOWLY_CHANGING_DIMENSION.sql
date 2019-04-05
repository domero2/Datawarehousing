/*1.1.1.1.1	Slowly Changing Dimension Type 3 – no changes on time ranges in the past

There are 3 different cases to be differentiated
-	Insert new entity instance
o	A new object is being inserted into the target table, as no object with the same logical key exists.
-	Update an existing entity instance
o	The existing record is being terminated.
o	A new record with the new attribute values is inserted.
-	Terminate an entity instance
o	The object doesn’t exist in the source system any more. 

To solve this business problem i did.
1. Get last trade based on bus_key from target table which in this step are our source table
2. Make full outer join, because in new load could be less trades than in previous and all trades
 that don't exist in second run should be set as not active
3. Created router which separate Insert, Update and Update_OLD 
*/
1.
Select 
MAX(LD.TABA_LDD_ID) as TABA_LDD_ID,
LD.MSG_ID,
LD.BUS_KEY,
LD.MD5_HASH
FROM
USER1.TABA LD
group by LD.MSG_ID, LD.BUS_KEY, LD.MD5_HASH
order by 
LD.BUS_KEY
2.
FULL OUTHER JOIN
on TRM.BUS_KEY = LDD.BUS_KEY
3. 
--Router GROUPS
--Insert
ISNULL(LDD_ID) 
OR 
(NOT ISNULL(LDD_ID) AND MD5_HASH != LDD_MD5_HASH)
--UPDATE
NOT ISNULL(LDD_ID) AND MD5_HASH != LDD_MD5_HASH
--UPDATE_OLD
/*
1.When trades are the same do nothing or if trades didn't present in LDD then insert.
2. Update last trade in LDD table when something has change (set 'N') and insert new with 'Y' flag.
3. Data get from LDD doesn't match to data coming from TRM. This transaction is no more active.
*/