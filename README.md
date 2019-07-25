# Datawarehousing
Data ware housing using Tool as Informatica Power Center 
<img src="https://d7umqicpi7263.cloudfront.net/img/product/f782dfc1-9f5b-4222-8aea-22eb00e082da/09c25e3f-1941-4c93-9ae4-adfa47e9b290.jpg" alt="Informatica Power Center">
This repository was created to share solution for the biggest bussiness problem which i met so far, working as ETL Informatica Power Center Developer.
I think that some people can take advantage of these solution, because most of this could be common Informatica Power Center business problem.
Database we are using is Oracle.

SLOWLY_CHANGING_DIMENSION.sql
This file contains solution for slowly changing dimesnsion based on flag active(Y) and not active (N). It is usefule when we need sotred for exapmle all active counterparty i uor database and setting the date from what time to what time this counterparty was active. Or maybe he is still active from the beging.
This slowly changing dimesnion help us to stored te historization of active/not active of counterparties and sometimes one counterparty could be active then not active then after some months/years acive again.

Error_handling_functions.sql
This file contains solution for handling errors based on informatica stuff. This is combination of user defined functions and variables. 

Inf_procedure
Procedure should contains out variable defined in the beging. In informatica procedure you need to have additional column. New column could be v_dummy for example where you will have output port and then process this result to filter where condition will be always false. Thanks this combination nothing will be loaded into target.
