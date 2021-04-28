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