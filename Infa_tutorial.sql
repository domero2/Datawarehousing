Case sensitive - rozroznienie małych i wielkich liter, insensitive - nie rozróznia wielkosci liter.
--LOOKUP
1.Lepiej jest stosować unconected lookup, ponieważ, cache lookupajest wyliczany i tworzony raz w obrębie mappingu, dzięki czemu, możemy użyć go wielokrotnie(lookupa) na mappingu
i nie bedzie to psuło performancu.

CACHE
1. (Mapping)Automatycznie prebulid lookup cache jest ustawiony na auto.
2. (Workflow) Additional Concurrent Pipelines for Lookup Cache Creation jest defaultowo na auto.
3. Domyslnie jest to static cache
4. Można zaznaczyć dynamic cache, dzięki któremu bedzie mozna updatowac cache file po utworzeniu go przezn infe
5. Cahce file could be shared.

SHARING UNAMED_CACHE
1. Jeżeli będę dwa lookupy z tymi samymi portami, a innymi operatorami informatica stworzy jeden unamed chache dla tych dwóch przypadków.

PASSIVE_ACTIVE
Active - jezeli zaznaczymy przy tworzeniu lookupu opcje Return All Values on Multiple Match

LOOKUP_ORDER_BY
1. JEzeli zobimy SQL Override w lookupie i nie chcemy sortowania przed złączeniem, możemy dodać'--' za poleceniem from, wtedy informatica nie doda automatycznie sortowania w lookupie.


Tuning
1. Mozna stworzyć folder cache na oddzielnym dysku na serverze i wskazać na niego od strony administratora informaticy
pomorze to w performencie severa, jezeli integration memory jest przepełniony.
2. W sql overrdie odfiltrować niepotrzebne dane.
3. Wyciagac z lookupa tylko te tabel, których potrzebujemy, nie wszystkie dane w connected lookup.

Persistent_cache
1.Presistenet cache nie zostanie usuniety przez infe. Pliki zostały stworzone na serwerze i lookup nie bedzie ich tworzył na nowo, tylko odwoła sie do nich kiedy bedzie taka potrzeba.
2. moze byc wykorzystany do danych sttycznych, ktore sie nie zmianiaja.
3. Może być użyty przez kilka lookupów, nazywany także shared named cache.
4. Po zaznaczaeniu opcji persistenet, można zazcnaczyć opcje odświeżenia cache w runie infy.
5. Moze byc uzywany do dużych zbiorów, które żadko się zmieniają.

Sequential cache - jest tworzony, kiedy mamy sql override w lookupie, cache jest budowany kiedy wykonają się pozostałe procesy.

Concurrent cache - jest wykonywany kiedy zaczyna się sesja, wiedz powinien działać szybciej niz sequential.

DYNAMIC_CAHE
1. Jezeli przychodzące dane będą takie same jak w pliku z cachem, to nie zajdzie zadna zmiana, jezeli jakichś danych nie bedzie to zostaną dodane, a te która w sourcie są z inną wartość zsotana zupdatowane.

Kiedy użyć
1. Przy ładowaniu danych które się rzadko zmieniają

----------------------------------------------------------------------------------------------
Dimension modeling

Ważne pojęcia:
Surrogate key - Tworzony przez sequencer do nadawania unique id dla kazdego row. Zazwyczaj jako primary key dla tabel wymiarów.

STAR SCHEMA - jest najprostszym schematem DW, rekomendowany przez Kimballa i przez Oracle.
DEGENERATE DIMENSION - kolumna w tabeli faktów która nie jest klueczem do wymiarów. (np. Sales amount, TransactionNumber)

Types of SCDs (tyoes of dimensions)


--------------------------------------------------------
RANK TRANSFORTAMION

1. IS using to get TOP or BOTTOM 10, 50, 100, 150 records

---------------------------------------------------------
SQL TRANSFORMATION

Configure SQL Transformation in script mode
We have prebuild query in file, and informatica get this script and run it.
Dynamic connection is option that connection could change based on data.
Passive mode, when same quantity of columns get from previous transformation to next.
Active mode when quantity will change.
Script is setuping in workflow.

Configure SQL Transformation in query mode
-------------------------------------------------------------
UPDATE STRATEGY.
Insert -> DD_INSERT->0
Update -> DD_UPDATE ->1
Delete -> DD_ELETE ->2
Data Driven -> DD_REJECT ->3

Session Properties:
Update as update -> Update each row flagged for update if exist in target
Update as Insert -> Insert each row flagged for update
Update else Insert -> Update the row if exists, else insert it
  
Forawrd rejected rows
1. In this statement you could pass rejected rows to the next transformation or drop them.
2. If Forward Rejected Rows will be not selected. Integration Service writes the rejected and the writes them to the session log file.

In the wf manager we have option in Error handling to change Error Log Type. By default 
it is setup as none but we could change it into (Relational Database or Flat File)
------------------------------------------------------------
TRANSACTION CONTROL TRANSFORMATION - active transformation

Is used to processed all steps in mapping or none. It is useful if we need completed workflow but only when whole process will complete.

It could be setup on mapping or session level.

We can create dynamic amount of targets in Informatica.
1. We need to add file name (special column).
2. Transaction Control Condition meanigs:
TC_CONTINUE_TRANSACTION -> Do nothing
TC_COMMIT_BEFORE -> Commit before trades comes into next row 
TC_COMMIT_AFTER -> Commit after new trades will be processed 
TC_ROLLBACK_BEFORE -> 
TC_ROLLBACK_AFTER -> 

So we need to sort data using for example Departament name when we want to dynamically creat files with various DETPNO name




