SET SCHEMA DB2INST1;

-- Зад 1.  Да се напише заявка, която извежда име на служител (firstnme, lastname - в една колона,
-- конкатенирани), рождена дата и дата на наемане, за тези служители които са наети в същата
-- седмица, в която са имали и рожден ден. Пример: Рожденна дата на служител: 06.11.1998,
-- дата на наемане на служител: 08.11.2018. -- Рождения ден на служителя е във вторник, дата на наемане - четвъртък.

SELECT FIRSTNME || ' ' || LASTNAME AS ENAME, BIRTHDATE, HIREDATE,
DATE(YEAR(HIREDATE) || '-' || MONTH(BIRTHDATE) || '-' || DAY(BIRTHDATE)) AS BHDATE
FROM EMPLOYEE
WHERE WEEK_ISO(HIREDATE)= WEEK_ISO (DATE(YEAR(HIREDATE) || '-' || MONTH(BIRTHDATE) || '-' || DAY(BIRTHDATE)));

-- Зад 2. Напишете заявка, която извежда имената и рождените дати на тези служители, за които е изпълнено,
-- че са родени във високосна година и едновременно с това са и една и съща зодия по китайския календар.
-- Да се счита, че всички родени с 12 години разлика са една и съща зодия по китайския календар.

SELECT E1.FIRSTNME || ' ' || E1.LASTNAME AS E1_NAME, E1.BIRTHDATE AS E1_BDATE,
       E2.FIRSTNME || ' ' || E2.LASTNAME AS E2_NAME, E2.BIRTHDATE AS E2_BDATE
FROM EMPLOYEE E1, EMPLOYEE E2
WHERE E1.EMPNO < E2.EMPNO
AND ((MOD(YEAR(E1.BIRTHDATE), 4) = 0 AND MOD(YEAR(E1.BIRTHDATE), 100) != 0) OR MOD(YEAR(E1.BIRTHDATE), 400) = 0)
AND ((MOD(YEAR(E2.BIRTHDATE), 4) = 0 AND MOD(YEAR(E2.BIRTHDATE), 100) != 0) OR MOD(YEAR(E2.BIRTHDATE), 400) = 0)
AND MOD(YEAR(E1.BIRTHDATE), 12) = MOD(YEAR(E2.BIRTHDATE), 12);

-- Зад 3. Напишете заявка, която извежда рождената дата и имената на тези служители родени на една и съща дата.
-- Изведете имената на служителите по шаблона (E1_LASTNAME, E2_LASTNAME).
-- Повтарящите се двойки от вида (E2_LASTNAME, E1_LASTNAME) да не се извеждат в резултата.

SELECT '(' || E1.LASTNAME || ', ' || E2.LASTNAME || ')' AS PAIRS
FROM EMPLOYEE E1, EMPLOYEE E2
WHERE E1.EMPNO < E2.EMPNO
AND MONTH(E1.BIRTHDATE) = MONTH(E2.BIRTHDATE)
AND DAY(E1.BIRTHDATE) = DAY(E2.BIRTHDATE)
ORDER BY PAIRS;

-- Зад 4. Да се напише заявка, която извежда номер на административен отдел, име на административен отдел,
-- номера и имена на подчинените му отдели и броя на работещите служители за всеки един от подчинените
-- му отдели, за всички административни отдел без отдел с номер E01. Ако в отделите няма нито един
-- работещ служител да се изведе 0.

SELECT ADMR.ADMRDEPTNO, ADMR.ADMRDEPTNAME, DEPT.DEPTNO, DEPT.DEPTNAME, COUNT(*) AS CNT_EMP
FROM (SELECT DEPTNO AS ADMRDEPTNO, DEPTNAME AS ADMRDEPTNAME FROM DEPARTMENT
      WHERE DEPTNO IN (SELECT ADMRDEPT FROM DEPARTMENT)) ADMR
LEFT JOIN DEPARTMENT DEPT ON ADMR.ADMRDEPTNO=DEPT.ADMRDEPT
LEFT JOIN EMPLOYEE EMP ON DEPT.DEPTNO = EMP.WORKDEPT
WHERE ADMR.ADMRDEPTNO != 'E01'
GROUP BY ADMR.ADMRDEPTNO, ADMR.ADMRDEPTNAME, DEPT.DEPTNO, DEPT.DEPTNAME
ORDER BY ADMR.ADMRDEPTNO, DEPT.DEPTNO ;


-- Зад 5. Да се напише заявка, която намира имената на служителя с най-висока заплата.
SELECT LASTNAME, SALARY
FROM EMPLOYEE
WHERE SALARY >= ALL (SELECT SALARY FROM EMPLOYEE);

SET SCHEMA DB2MOVIES;

-- 1. За таблицата Movies, да се изведе номер на продуцент, брой на филми за този продуцент.

SELECT PRODUCERC#, COUNT(*) AS CNT_MOVIES
FROM MOVIE
GROUP BY PRODUCERC#;

-- 2. Като задача 1, но искаме и име на продуцент и networth.
SELECT NAME, COUNT(*) AS CNT_MOVIES, NETWORTH
FROM MOVIE, MOVIEEXEC
WHERE PRODUCERC# = CERT#
GROUP BY PRODUCERC#, NAME, NETWORTH;
-- GROUP BY NAME, PRODUCERC#

-- 3. Заявка, която ни връща име на актьор, рождена дата и броя на филмите, в които е участвал

SELECT STARNAME, BIRTHDATE, COUNT(*) AS CNT_MOVIE
FROM STARSIN, MOVIESTAR
WHERE NAME = STARNAME
GROUP BY STARNAME, BIRTHDATE
ORDER BY CNT_MOVIE DESC;

-- 4. Заявка, която ни връща имената на актьорите, рождена дата и броя на филмите,
-- в които са участвали за тези актьори с най-много филми.

SELECT STARNAME, BIRTHDATE, COUNT(*) AS CNT_MOVIE
FROM STARSIN, MOVIESTAR
WHERE NAME = STARNAME
GROUP BY STARNAME, BIRTHDATE
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
                    FROM STARSIN
                    GROUP BY STARNAME);

-- 5. За Movies, име на продуцент, име на студио, и брой на филми за всики продуцент, според студиото.

SELECT NAME, STUDIONAME, COUNT(*) CNT
FROM MOVIE, MOVIEEXEC
WHERE PRODUCERC# = CERT#
-- GROUP BY STUDIONAME, NAME;
GROUP BY PRODUCERC#, NAME, STUDIONAME;

CREATE VIEW V_PROD_STUD_CNT
AS
SELECT NAME, STUDIONAME, COUNT(*) CNT
FROM MOVIE, MOVIEEXEC
WHERE PRODUCERC# = CERT#
GROUP BY PRODUCERC#, NAME, STUDIONAME;

SELECT *
    FROM V_PROD_STUD_CNT
    WHERE CNT IN (SELECT MAX(CNT) FROM V_PROD_STUD_CNT);

-- USER1 ---> SELECT V_PROD_STUD_CNT
-- USER1 ---> SELECT MOVIE x

CREATE VIEW V_UPD_MOVIE
AS
  SELECT * FROM MOVIE;


INSERT INTO V_UPD_MOVIE
VALUES ('A', 1999);

DELETE FROM V_UPD_MOVIE WHERE TITLE = 'A';

-- 6. Име на филм и име на най-възрастния актьор участвал във филма

SELECT T1.*  FROM
(SELECT MOVIETITLE, MOVIEYEAR,
                          STARNAME, ABS(YEAR(BIRTHDATE) - MOVIEYEAR) AS AGE
                          FROM STARSIN, MOVIESTAR
                          WHERE STARNAME=NAME) T1,
(SELECT MOVIETITLE, MOVIEYEAR, MAX(ABS(YEAR(BIRTHDATE) - MOVIEYEAR)) AS AGE
FROM STARSIN, MOVIESTAR
WHERE STARNAME = NAME
GROUP BY MOVIETITLE, MOVIEYEAR) T2
WHERE T1.MOVIETITLE = T2.MOVIETITLE
AND   T1.MOVIEYEAR = T2.MOVIEYEAR
AND T1.AGE = T2.AGE;


-- 7. Намира най-възрастният актьор участвал в филм
SELECT MOVIETITLE, MOVIEYEAR, NAME, ABS(YEAR(BIRTHDATE) - MOVIEYEAR) AS AGE
FROM MOVIESTAR, STARSIN
WHERE STARNAME = NAME
AND ABS(YEAR(BIRTHDATE) - MOVIEYEAR) = (SELECT MAX(ABS(YEAR(BIRTHDATE) - MOVIEYEAR)) FROM MOVIESTAR);

SET SCHEMA DB2MOVIE;

-- Напишете заявка, която извежда името на продуцента и имената на филмите,
-- продуцирани от продуцента на ‘Star Wars’

SELECT MSW.NAME, AL.TITLE
FROM MOVIEEXEC MSW JOIN MOVIE M
ON M.PRODUCERC# = MSW.CERT#
JOIN MOVIE AL
ON MSW.CERT# = AL.PRODUCERC#
AND M.TITLE='Star Wars'
AND AL.TITLE!='Star Wars';

-- Напишете заявка, която извежда имената на продуцентите на филмите на
-- ‘Harrison Ford’

SELECT ME.NAME, M.TITLE
FROM MOVIEEXEC ME JOIN MOVIE M
ON ME.CERT# = M.PRODUCERC#
JOIN STARSIN S ON M.TITLE = S.MOVIETITLE and M.YEAR = S.MOVIEYEAR
WHERE S.STARNAME = 'Harrison Ford';

-- Напишете заявка, която извежда името на студиото и имената на актьорите
-- участвали във филми произведени от това студио, подредени по име на студио.

SELECT S.NAME,  SI.STARNAME
FROM STUDIO S JOIN MOVIE M ON S.NAME = M.STUDIONAME
JOIN STARSIN SI ON M.TITLE=SI.MOVIETITLE AND M.YEAR = SI.MOVIEYEAR
ORDER BY S.NAME;

SELECT S.NAME, M.TITLE, SI.STARNAME
FROM STUDIO S LEFT JOIN MOVIE M ON S.NAME = M.STUDIONAME
LEFT JOIN STARSIN SI ON M.TITLE=SI.MOVIETITLE AND M.YEAR = SI.MOVIEYEAR
ORDER BY S.NAME;

-- Напишете заявка, която извежда имената на актьора (актьорите) участвали във
-- филми на най-голяма стойност

SELECT DISTINCT S.STARNAME
FROM MOVIEEXEC MEM JOIN MOVIE M on MEM.CERT# = M.PRODUCERC#
JOIN STARSIN S on M.TITLE = S.MOVIETITLE and M.YEAR = S.MOVIEYEAR
WHERE MEM.NETWORTH IN (SELECT MAX(NETWORTH) FROM MOVIEEXEC);

-- Напишете заявка, която извежда имената на актьорите не участвали в нито един
-- филм. (Използвайте съединение!)

SELECT NAME
FROM MOVIESTAR LEFT JOIN STARSIN S on MOVIESTAR.NAME = S.STARNAME
WHERE MOVIETITLE IS NULL;

SET SCHEMA DB2SHIPS;

-- Напишете заявка, която извежда цялата налична информация за всеки кораб,
-- включително и данните за неговия клас. В резултата не трябва да се включват
-- тези класове, които нямат кораби.

select *
from SHIPS join CLASSES C2
    on SHIPS.CLASS = C2.CLASS
-- where name is not null;

-- Повторете горната заявка като този път включите в резултата и класовете, които
-- нямат кораби, но съществуват кораби със същото име като тяхното.

select c2.class
from SHIPS right join CLASSES C2
on SHIPS.CLASS = C2.CLASS
where exists(select * from ships where name = c2.class)
and  name is null;


select c2.class
from SHIPS right join CLASSES C2
on SHIPS.CLASS = C2.CLASS
where c2.class in(select name from SHIPS)
and  name is null;

-- За всяка страна изведете имената на корабите, които никога не са участвали в битка.


SELECT C.COUNTRY, S.NAME
FROM CLASSES C  LEFT JOIN SHIPS S ON C.CLASS = S.CLASS
LEFT JOIN OUTCOMES O on S.NAME = O.SHIP
WHERE
S.NAME IS NULL OR
O.BATTLE IS NULL
ORDER BY C.COUNTRY, S.NAME;

SET SCHEMA DB2SHIPS;

-- Напишете заявка, която извежда броя на класовете кораби

SELECT COUNT(*) CNT FROM CLASSES;

-- Напишете заявка, която извежда средния брой на оръжия, според класа на кораба

SELECT CLASS, NUMGUNS FROM CLASSES;

SELECT CLASS, AVG(NUMGUNS) AVG_NUM
FROM CLASSES
GROUP BY CLASS;

SELECT COUNTRY, AVG(NUMGUNS) AVG_NUM, COUNT(*) AS CNT
FROM CLASSES
GROUP BY COUNTRY;

-- Напишете заявка, която извежда средния брой на оръжия за всички кораби
SELECT AVG(C.NUMGUNS) AS AVG_NUM, COUNT(*) AS CNT
FROM CLASSES C JOIN SHIPS S ON C.CLASS = S.CLASS;

-- Напишете заявка, която извежда за всеки клас първата и последната година, в
-- която кораб от съответния клас е пуснат на вода

SELECT CLASS, MIN(LAUNCHED) AS MIN_YEAR, MAX(LAUNCHED) AS MAX_YEAR
FROM SHIPS
GROUP BY CLASS;

SELECT CLASS, MIN(LAUNCHED) AS MIN_YEAR, (SELECT COUNT(*)
                                          FROM SHIPS
                                          WHERE CLASS = S.CLASS
                                          AND LAUNCHED = (SELECT MIN(LAUNCHED)
                                                          FROM SHIPS WHERE CLASS = S.CLASS)
                                         ) MIN_CNT,
       MAX(LAUNCHED) AS MAX_YEAR,  (SELECT COUNT(*)
                                          FROM SHIPS
                                          WHERE CLASS = S.CLASS
                                          AND LAUNCHED = (SELECT MAX(LAUNCHED)
                                                          FROM SHIPS WHERE CLASS = S.CLASS)
                                         ) MAX_CNT
FROM SHIPS S
GROUP BY CLASS;

-- Напишете заявка, която извежда броя на корабите потънали в битка според класа

SELECT S.CLASS, COUNT(S.NAME) AS CNT_SHIPS
FROM SHIPS S JOIN OUTCOMES O ON S.NAME = O.SHIP
WHERE O.RESULT = 'sunk'
GROUP BY S.CLASS;

-- Напишете заявка, която извежда броя на корабите потънали в битка според класа, за тези класове
-- с повече от 2 кораба

SELECT S.CLASS, COUNT(S.NAME) AS CNT_SHIPS
FROM SHIPS S JOIN OUTCOMES O ON S.NAME = O.SHIP
WHERE O.RESULT = 'sunk'
GROUP BY S.CLASS
HAVING COUNT(S.NAME) >= 2;

-- Напишете заявка, която извежда средното тегло на корабите, за всяка страна.

SELECT COUNTRY, AVG(DISPLACEMENT) AVG_DIS, SUM(DISPLACEMENT) SUM_DIS, COUNT(*) AS CNT
FROM CLASSES
GROUP BY COUNTRY;

SELECT C.COUNTRY, AVG(DISPLACEMENT) AVG_DIS, SUM(DISPLACEMENT) SUM_DIS, COUNT(*) AS CNT
FROM CLASSES C, SHIPS S
WHERE C.CLASS = S.CLASS
GROUP BY COUNTRY;

SELECT C.COUNTRY, AVG(DISPLACEMENT) AVG_DIS, SUM(DISPLACEMENT) SUM_DIS, COUNT(S.NAME) AS CNT
FROM CLASSES C LEFT JOIN SHIPS S
ON C.CLASS = S.CLASS
GROUP BY COUNTRY;