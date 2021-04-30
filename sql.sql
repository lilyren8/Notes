--select all the columns from the country table 
SELECT * FROM Country ORDER BY Name;

--use double qoutes for identifiers
SELECT Name,LifeExpectancy AS "Life Expectancy" FROM Country ORDER BY Name;

--use WHERE to select rows. use single qoutes for literal string, limit similar to head()
SELECT Name, Continent, Region FROM Country WHERE Continent = 'Europe' ORDER BY Name;

--offset: skip the first # rows
SELECT Name, Continent, Region FROM Country WHERE Continent = 'Europe' ORDER BY Name LIMIT 5 OFFSET 11;

--COUNT returns the number of records
SELECT COUNT(*) FROM Country WHERE Population > 10000;

--use column name in COUNT to return the number of records that has data
SELECT COUNT(LifeExpectancy) FROM Country; 

--have a look at the table
SELECT * FROM customer;

--add rows to the table
INSERT INTO customer (name, address, city, state, zip)
VALUES ('a', 'b', 'c', 'd', 'e');

--use update to change data
UPDATE customer SET address = '1', zip = '2' WHERE id = 4;

--DELETE
DELETE FROM customer WHERE id = 5;
SELECT * FROM customer;

--create table, column name followed by type
CREATE TABLE test (
a INTEGER,
b TEXT,
c TEXT
);

INSERT INTO test VALUES (1, 'A', 'A');
INSERT INTO test (a, b) VALUES (2, 'b');

--add row with no data
INSERT INTO test DEFAULT VALUES;

--add rows from another table
INSERT INTO test SELECT * FROM item;
SELECT * FROM test;

--to delete a row, can first do select to check if the rows are the ones to delete, then change delete from
SELECT * FROM test WHERE a = 1;
DELETE FROM test WHERE a = 1;
SELECT * FROM test;

--delete table, use IF EXISTS so don't return error
DROP TABLE IF EXISTS test;

--NULL is an absence in value, so cannot use a = NULL
INSERT INTO test (a, c) VALUES (1,'R');
SELECT * FROM test WHERE b IS NULL;


--constraints about null value, insert will fail if insert null value
CREATE TABLE test (
a INTEGER NOT NULL,
b TEXT NOT NULL,
c TEXT
);

--have a default value, have a unique constraint(NULL is exampt from some and not for others), can combine constraint
DROP TABLE test;
CREATE TABLE test (
a INTEGER UNIQUE NOT NULL,
b TEXT DEFAULT 'panda',
c TEXT
);

--change table schema
DROP TABLE IF EXISTS test;
CREATE TABLE test (a TEXT, b TEXT, c TEXT);
INSERT INTO test VALUES ('A', 'B', 'C');
INSERT INTO test VALUES ('D', 'B', 'C');


ALTER TABLE test ADD e TEXT DEFAULT 'panda';
SELECT * FROM test;

--primary key, system generates sequential id, only work on sqlite
DROP TABLE IF EXISTS test;
CREATE TABLE test (id INTEGER PRIMARY KEY, b TEXT, c TEXT);
INSERT INTO test (b, c) VALUES ('A', 'B');
INSERT INTO test (b, c) VALUES ('D', 'B');
SELECT * FROM test;

--select countries with less than 100000 people in desending order. Also include countries with NULL in population
SELECT Name, Population FROM Country
WHERE Population < 100000 OR Population IS NULL ORDER BY Population DESC;

--select rows with 'island' somewhere in the name
SELECT Name, Population FROM Country
WHERE Name LIKE '%island%' ORDER BY Name;

--select name whose second letter is a
SELECT Name, Population FROM Country
WHERE Name LIKE '_a%' ORDER BY Name;

--select results match values in a list
SELECT Name, Continent, Population FROM Country
WHERE Continent IN ('Europe', 'Asia') ORDER BY Name;

--removing duplicates, can also use for multiple columns
SELECT DISTINCT Continent FROM Country;

--order alphatically by continent first, then the name
SELECT Name, Continent FROM Country ORDER BY Continent, Name;

---------------------------------relationships-------------------------------------
--setup
CREATE TABLE left ( id INTEGER, description TEXT );
CREATE TABLE right ( id INTEGER, description TEXT );

INSERT INTO left VALUES ( 1, 'left 01' );
INSERT INTO left VALUES ( 2, 'left 02' );
INSERT INTO left VALUES ( 3, 'left 03' );
INSERT INTO left VALUES ( 4, 'left 04' );
INSERT INTO left VALUES ( 5, 'left 05' );
INSERT INTO left VALUES ( 6, 'left 06' );
INSERT INTO left VALUES ( 7, 'left 07' );
INSERT INTO left VALUES ( 8, 'left 08' );
INSERT INTO left VALUES ( 9, 'left 09' );

INSERT INTO right VALUES ( 6, 'right 06' );
INSERT INTO right VALUES ( 7, 'right 07' );
INSERT INTO right VALUES ( 8, 'right 08' );
INSERT INTO right VALUES ( 9, 'right 09' );
INSERT INTO right VALUES ( 10, 'right 10' );
INSERT INTO right VALUES ( 11, 'right 11' );
INSERT INTO right VALUES ( 11, 'right 12' );
INSERT INTO right VALUES ( 11, 'right 13' );
INSERT INTO right VALUES ( 11, 'right 14' );

SELECT * FROM left;
SELECT * FROM right;

--inner join: join tables where id match,ON tells the condition the 2 table will join
SELECT l.description AS left, r.description AS right
FROM left AS l
JOIN right AS r ON l.id = r.id
;

-- outer join, include everything from the left table
SELECT l.description AS left, r.description AS right
FROM left AS l
LEFT JOIN right AS r ON l.id = r.id
;

---------------------------------string-------------------------------------

SELECT LENGTH('AA');

--show the numbers of character in Name, orderd by length then name.
SELECT Name, LENGTH(Name) AS Len FROM City ORDER BY Len DESC, Name;

--substring. get everything in the string from the starting position to the end
SELECT SUBSTR('this string', 6);

--substring. just get 3 characters 
SELECT SUBSTR('this string', 6, 3);

--parse out packed data. for example, yyyy-mm-dd to year, month and day
SELECT released,
SUBSTR(released, 1, 4) AS year,
SUBSTR(released, 6, 2) AS month,
SUBSTR(released, 9, 2) AS day
FROM album ORDER BY released
;

--remove spaces from string, useful for processing user input
SELECT TRIM('     string    ');

--remove spaces from left
SELECT LTRIM('     string    ');

--remove spaces from right
SELECT RTRIM('     string    ');

-- remove period
SELECT TRIM('....string..', '.');
SELECT LTRIM('....string..', '.');

--the 2 strings are not equal
SELECT 'STRing' = 'string';

--convert to all lower case
SELECT LOWER('STRing') = 'string';

--normalize the case in a column,  cannot acent characters in SQLite
SELECT UPPER(Name) FROM City ORDER BY Name;

---------------------------------numbers-------------------------------------
--single number is integer
SELECT TYPEOF( 1+1 );

--decimal point is real number
SELECT TYPEOF( 1+1.0 );

--the type is integer
SELECT TYPEOF('panda'+'panda');

--the result 0 is an integer,.5 is not integer
SELECT 1 / 2;
SELECT CAST(1 AS REAL) / 2;

--round 
SELECT ROUND(2.4444);

--round to 3 decimal spaces
SELECT ROUND(2.44444, 3);

---------------------------------dates and time-------------------------------------

--return time stand in UTC 
SELECT DATETIME('now');
SELECT DATE('now');

--add argument to change date time
SELECT DATETIME('now', '+3 hours', '-1 day');

---------------------------------aggregates-------------------------------------

--GROUP BY groups results before calling the aggregate function
SELECT Region, COUNT(*) AS Count
FROM Country
GROUP BY Region
ORDER BY Count DESC, Region
;

--the number of tracks for each album, HAVING is for aggregate data, WHERE is for non-aggregate data
SELECT a.title AS album, COUNT(t.track_number) AS tracks
FROM album AS a
JOIN track AS t
ON a.id = t.album_id
--WHERE needs to be before group by
WHERE a.artist = 'The beatles'
GROUP BY a.id
HAVING Tracks >= 10
ORDER BY tracks, album
;

--COUNT(*) count the number of rows. COUNT(column) count all non-null values
SELECT COUNT(Population) FROM Country;

--AVG, SUM, MIN
SELECT SUM(Population) FROM Country;
SELECT AVG(Population) FROM Country;

--count distinct
SELECT COUNT(DISTINCT HeadOfState) FROM Country;

---------------------------------trigger-------------------------------------
--automating data: update table when another table is updated

--prevent items to be modified
CREATE TRIGGER updateWidgetSale BEFORE UPDATE ON widgetSale
BEGIN
SELECT RAISE(ROLLBACK, 'cannot update table "widgetSale"') FROM widgetSale
WHERE id = NEW.id AND reconciled = 1;
end
;

--rollback the transaction
BEGIN TRANSACTION;
UPDATE widgetSale SET quan = 8 WHERE id = 2;
END TRANSACTION;


---------------------------------view-------------------------------------

--create a view, use view as you would use a table in a join
CREATE VIEW trackView AS
SELECT id, album_id, title, duration / 60 AS m, duration % 60 AS s FROM track ORDER BY title; 
SELECT * FROM trackView;

--delete
DROP VIEW IF EXISTS trackView;