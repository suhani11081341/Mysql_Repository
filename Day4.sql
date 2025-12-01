-- Use your database (change this to your DB name)
USE ecommerce_db;

-- ============================
-- 1. TIME TABLE
-- ============================
DROP TABLE IF EXISTS time_val;

CREATE TABLE time_val (
    t1 TIME,
    t2 TIME
);

INSERT INTO time_val (t1, t2) VALUES
('15:00:00', '15:00:00'),
('05:01:30', '02:30:20'),
('12:30:20', '17:30:45');

-- ============================
-- 2. DATE TABLE
-- ============================
DROP TABLE IF EXISTS date_val;

CREATE TABLE date_val (
    d DATE
);

INSERT INTO date_val (d) VALUES
('1864-02-28'),
('1900-01-15'),
('1999-12-31'),
('2000-06-04'),
('2017-03-16');

-- ============================
-- 3. DATETIME TABLE
-- ============================
DROP TABLE IF EXISTS datetime_val;

CREATE TABLE datetime_val (
    dt DATETIME
);

INSERT INTO datetime_val (dt) VALUES
('1970-01-01 00:00:00'),
('1999-12-31 09:00:00'),
('2000-06-04 15:45:30'),
('2017-03-16 12:30:15');

-- Test
SELECT t1, t2 FROM time_val;
SELECT d FROM date_val;
SELECT dt FROM datetime_val;

/*
mycol TIME
- There is no fraction of seconds.
- It only stores hours, minutes, seconds.
- This is the default → TIME(0)

TIME(fsp) → Fractional Seconds Precision
- MySQL lets you store fraction of a second also.
- Syntax:TIME(fsp): Where fsp (Fractional Seconds Precision) can be:

fsp	Meaning	Example         Stored Time
0	No fractions (default)	12:30:45
1	Tenths of second	    12:30:45.1
2	Hundredths of second	12:30:45.12
3	Milliseconds	        12:30:45.123
6	Microseconds	        12:30:45.123456

- Maximum is 6 digits.

💡 Why do we need this?
- Some real-world events need more precise time than seconds.
Examples:
- Sprint races (Olympics)
-  Heart-rate machines, ECG
These events cannot use just seconds — they need milliseconds or microseconds.
*/
SELECT CURTIME(), CURTIME(2), CURTIME(6);

-- Race standings from one of the latest races held in Turkey.
/*

| Column        | One-line Definition                                           |
| ------------- | ------------------------------------------------------------- |
| **id**        | Unique serial number for each record in the table.            |
| **position**  | Driver’s final finishing position in the race.                |
| **driver_no** | Official racing number assigned to the driver.                |
| **driver**    | Full name of the Formula-1 driver.                            |
| **car**       | Team and engine manufacturer of the driver’s car.             |
| **laps**      | Total number of laps completed by the driver in the race.     |
| **race_time** | Total time taken by the driver to finish the race (duration). |
| **points**    | Championship points earned by the driver for that race.       |
*/

CREATE TABLE `formula1` (
 id INT AUTO_INCREMENT PRIMARY KEY,
 position INT UNSIGNED,
 no INT UNSIGNED,
 driver VARCHAR(25),
 car VARCHAR(25),
 laps SMALLINT,
 time TIMESTAMP(3),
 points SMALLINT
);

INSERT INTO formula1 VALUES(0,1,77,"Valtteri Bottas","MERCEDES",58,"2021-10-08 1:31:04.103",26);
INSERT INTO formula1 VALUES(0,2,33,"Max Verstappen","RED BULL RACING HONDA",58,"2021-10-08 1:45:58.243",18);
INSERT INTO formula1 VALUES(0,3,11,"Sergio Perez","RED BULL RACING HONDA",58,"2021-10-08 1:46:10.342",15);
SELECT POSITION as pos, no, driver, car, laps, date_format(time,'%H:%i:%s:%f') as time, points as pts
FROM formula1 ORDER BY time;
 /*
 This tells MySQL:

Convert the time value into a text string, formatted as:
Hours : Minutes : Seconds : Microseconds
| Code   | Meaning                      | Example |
| ------ | ---------------------------- | ------- |
| **%H** | Hour (00–23)                 | 01      |
| **%i** | Minutes (00–59)              | 31      |
| **%s** | Seconds (00–59)              | 04      |
| **%f** | Microseconds (000000–999999) | 103000* |

01:31:04:103000

Explanation:
- 01 → hour
- 31 → minute
- 04 → second
- 103000 → microseconds (because .103 seconds = 103000 microseconds)
 */
 
-- To get a proper listing of the time gaps between driver performance, we will use a CTE.

describe formula1;
INSERT INTO formula1 (position, no, driver, car, laps, time, points)
VALUES (4, 99, 'Test Driver', 'TEST TEAM', 58, '2021-10-08 02:41:49.103', 0);

SELECT * FROM formula1;

SELECT MIN(time) from formula1 into @fastest;
SELECT @fastest  AS fastest_time;


WITH time_gap AS ( SELECT position,car,driver,time,TIMESTAMPDIFF(SECOND,@fastest, time ) AS seconds FROM formula1),-- (time - fastest_time)
DIFFERENCES AS (
 SELECT position as pos,driver,car,time,seconds,MOD(seconds, 60) AS seconds_part,MOD(seconds, 3600) AS minutes_part
 FROM time_gap
)
SELECT pos, driver,time,seconds,minutes_part,seconds_part,FLOOR(minutes_part / 60),SUBSTRING_INDEX(SUBSTRING_INDEX(seconds_part,'-',2),'-',-1),
 CONCAT(FLOOR(minutes_part / 60), ' min ', seconds_part,'secs') AS difference
FROM differences;

WITH time_gap AS ( SELECT position,car,driver,time,TIMESTAMPDIFF(SECOND,@fastest, time ) AS seconds FROM formula1),
DIFFERENCES AS (
 SELECT position as pos,driver,car,time,seconds,MOD(seconds, 60) AS seconds_part,FLOOR(seconds/60) AS minutes_part
 FROM time_gap
)
SELECT pos, driver,time,seconds,minutes_part,seconds_part,CONCAT(minutes_part, ' min ', seconds_part,'secs') AS difference
FROM differences;

WITH time_gap AS (SELECT position, car, driver, time, TIMESTAMPDIFF(SECOND, @fastest, time) AS seconds FROM formula1), 
DIFFERENCES AS (SELECT position AS pos, driver, car, time, seconds, FLOOR(seconds/3600) AS hours_part,
FLOOR((seconds%3600)/60) AS minutes_part, (seconds%60) AS seconds_part FROM time_gap) 
SELECT pos, driver, time, seconds, hours_part, minutes_part, seconds_part, 
CONCAT(hours_part, ' hr ', minutes_part, ' min ', seconds_part, ' sec') AS difference FROM differences;

SELECT * FROM formula1;

INSERT INTO date_val (d) VALUES(STR_TO_DATE('May 13, 2007','%M %d, %Y'));
SELECT * FROM date_val;

SELECT d, DATE_FORMAT(d,'%M %d, %Y') FROM date_val;

/*Format sequences to use
with date and time formatting functions 
Sequence Meaning
%Y Four-digit year
%y Two-digit year
%M Complete month name
%b Month name, initial three letters
%m Two-digit month of year (01..12)
%c Month of year (1..12)
%d Two-digit day of month(01..31)
%e Day of month (1..31)
%W Weekday name (Sunday..Saturday)
%r 12-hour time with AM or PM suffix
%T 24-hour time
%H Two-digit hour
%i Two-digit minute
%s Two-digit second
%f Six-digit microsecond
%% Literal %
*/
SELECT dt,DATE_FORMAT(dt,'%c/%e/%y %r') AS format1,DATE_FORMAT(dt,'%M %e, %Y %T') AS format2 FROM datetime_val;
SELECT dt,TIME_FORMAT(dt, '%r') AS '12-hour time',TIME_FORMAT(dt, '%T') AS '24-hour time' FROM datetime_val;

CREATE FUNCTION time_ampm (t TIME)
RETURNS VARCHAR(13) # mm:dd:ss {a.m.|p.m.} format
DETERMINISTIC
RETURN CONCAT(LEFT(TIME_FORMAT(t, '%r'), 9),
 IF(TIME_TO_SEC(t) < 12*60*60, 'a.m.', 'p.m.'));

SELECT t1, time_ampm(t1) FROM time_val;

-- See server time zone
SHOW VARIABLES LIKE 'time_zone';

-- See current session time zone (your connection)
SELECT @@session.time_zone;

DROP TABLE IF EXISTS tz_demo;

CREATE TABLE tz_demo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ts TIMESTAMP,   -- time zone aware
    dt DATETIME     -- NOT time zone aware
);
-- Scenario A – Client & server both in UTC
-- Pretend you are client C1 in UTC.
SET time_zone = '+00:00';   -- session time zone = UTC
SELECT @@session.time_zone;
INSERT INTO tz_demo (ts, dt) VALUES ('2021-06-21 12:30:00', '2021-06-21 12:30:00');
SELECT * FROM tz_demo;
/*
Here, both look the same.
Because you’re in UTC and server is treating your session as UTC.*/


-- Scenario B – Same data, but client in India (UTC+5:30)
/*
Now pretend you’re client C2 in India (IST).
We’ll keep the same table, just change session time_zone*/
SET time_zone = '+05:30';   -- session now IST
SELECT @@session.time_zone;
SELECT * FROM tz_demo; -- 2021-06-21 18:00:00	2021-06-21 12:30:00
/*
Explanation:
ts (TIMESTAMP): previously stored as UTC 12:30, now converted to IST → 12:30 + 5:30 = 18:00
dt (DATETIME): stored as plain text 12:30, no conversion → always 2021-06-21 12:30:00
Key learning:
- Same row, two “clients”:
- UTC client saw ts = 12:30, IST client sees ts = 18:00
- But dt is unchanged (always 12:30)
*/

-- Scenario C – Insert from India correctly (session set to +05:30)

SET time_zone = '+05:30';
SELECT @@session.time_zone;
INSERT INTO tz_demo (ts, dt) VALUES ('2021-06-21 12:30:00', '2021-06-21 12:30:00');
SELECT * FROM tz_demo;

/*Row 2: you inserted local 12:30 IST, MySQL stored UTC 07:00,
and when you query in IST it converts back to 12:30. So you see what you expect.

Now switch back to UTC client (simulate C1)*/

SET time_zone = '+00:00';
SELECT @@session.time_zone;
SELECT * FROM tz_demo;
/*
Row 2 ts = 07:00 UTC, because it was inserted as 12:30 IST (UTC+5:30 → 7:00 UTC).
dt didn’t move: always 12:30.
💡 So:
- India client saw row2 ts as 12:30
- UTC client sees row2 ts as 07:00
Both are “correct” in their time zones.
ts					dt
2021-06-21 12:30:00	2021-06-21 12:30:00
2021-06-21 07:00:00	2021-06-21 12:30:00 */

-- Scenario D – What happens if client forgets to set time zone?
-- Now pretend you are in India but your session is wrong (UTC):

SET time_zone = '+00:00';   -- but you are actually in IST in real life
SELECT @@session.time_zone;

INSERT INTO tz_demo (ts, dt) VALUES ('2021-06-21 12:30:00', '2021-06-21 12:30:00');

/* But MySQL thinks '2021-06-21 12:30:00' is UTC, so it stores that as UTC.
Now switch to IST to see how bad it looks:*/
SET time_zone = '+05:30';
SELECT * FROM tz_demo;
/* Now check row 3:
Stored as UTC 12:30
Displayed in IST = 18:00

So you, as an Indian user, expected 12:30, but you now see 18:00.
That’s the “wrong UTC” problem the book talks about.*/

-- Scenario E – Two “clients” viewing same TIMESTAMP

/* Let’s just focus on row 2 (correct IST insert):
Row 2 was inserted in IST as 12:30, so stored UTC 07:00.
Client C1 in UTC: */
SET time_zone = '+00:00';
SELECT * FROM tz_demo ;
SELECT id, ts, dt FROM tz_demo WHERE id = 2; 
-- ts = 2021-06-21 07:00:00
-- dt = 2021-06-21 12:30:00

-- Client C2 in IST:
SET time_zone = '+05:30';
SELECT * FROM tz_demo ;
SELECT id, ts, dt FROM tz_demo WHERE id = 2;
-- ts = 2021-06-21 12:30:00
-- dt = 2021-06-21 12:30:00

/*
Same TIMESTAMP row:
UTC view: 07:00
IST view: 12:30
DATETIME row:
Same 12:30 everywhere, no conversion.*/

/*
Mini summary of each concept with this table

- Using tz_demo(ts TIMESTAMP, dt DATETIME):

1. TIMESTAMP is time-zone aware
- Insert under IST → stored as UTC
-Viewed under UTC vs IST → different ts

2. DATETIME is not converted
- Always shows exactly what you inserted.

3. If session time_zone = server time_zone and clients are actually in same place
- life is simple; you usually don’t notice conversions.

4. If you’re physically in a different zone but do not set time_zone
- your inserts are interpreted in wrong zone → stored UTC becomes wrong → everyone sees wrong logical time.
*/
DROP TABLE IF EXISTS tz_now_demo;

CREATE TABLE tz_now_demo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- See how created_at behaves with different time_zone
-- Session 1 – Pretend you are in Asia/Kolkata (IST, +05:30)
SET time_zone = '+05:30';
SELECT @@session.time_zone;
INSERT INTO tz_now_demo VALUES ();   -- only id auto + created_at auto
SELECT * FROM tz_now_demo;

-- Session 2 – Pretend you are in Europe/London (often UTC or UTC+1)
SET time_zone = '+00:00';
SELECT @@session.time_zone;
SELECT * FROM tz_now_demo;
/*
When you inserted in IST, CURRENT_TIMESTAMP used IST time (say 12:00).
MySQL stored it as UTC inside.
When you later changed session to Europe/London, MySQL converted that stored UTC to London time 
(e.g., 06:30).So created_at “moves” based on time_zone for TIMESTAMP.
*/

-- Second concept: Asia/Kolkata vs Europe/London with fixed values
DROP TABLE IF EXISTS tz_city_demo;

CREATE TABLE tz_city_demo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ts TIMESTAMP,
    dt DATETIME
);
-- Be “client in Asia/Kolkata”
SET time_zone = '+05:30';
SELECT @@session.time_zone;
INSERT INTO tz_city_demo (ts, dt) VALUES ('2025-12-01 10:00:00', '2025-12-01 10:00:00');
SELECT * FROM tz_city_demo;

-- Now “travel” to Europe/London (second client)
SET time_zone = '+00:00';
SELECT @@session.time_zone;
SELECT * FROM tz_city_demo;
/* Why?
IST is 5.5 hours ahead of UTC. So 10:00 IST = 04:30 UTC.
Europe/London at some times of year is UTC or UTC+1 – assuming UTC here for simplicity:
  So TIMESTAMP is shown as 04:30.
DATETIME never changes → always 10:00.
*/
SELECT NOW();
SET time_zone = '+05:30';
SELECT NOW();
/*
Simple definition:NOW() returns the current date & time in your session's time_zone.
- NOT the server’s time.
- NOT UTC (unless your session is UTC).
- NOT your computer time.
- It depends ONLY on:SET time_zone = '...';
So:
- If your session is set to +05:30, NOW() returns IST.
- If session is +00:00, NOW() returns UTC.
- If session is -04:00, NOW() returns New York time.*/
SELECT @fastest := MIN(time) FROM formula1;
SELECT @fastest;

SELECT @fastest := MIN(x) FROM (SELECT 6 AS x UNION ALL SELECT 7) AS t;
SELECT @fastest;

SELECT @fastest := LEAST(6, 7);
SELECT @fastest;


SELECT @@version;
SELECT @@autocommit;
SELECT @@sql_mode;
SELECT @@time_zone;
SELECT @@global.time_zone, @@session.time_zone;
SHOW GLOBAL VARIABLES LIKE "system_time_zone";
 
HELP DATETIME;

SHOW VARIABLES LIKE 'system_time_zone';
SET GLOBAL time_zone = '+03:00';
SELECT @@global.time_zone, @@session.time_zone;
SET GLOBAL time_zone = 'SYSTEM';
SELECT @@global.time_zone, @@session.time_zone;
/*
@@session.var → applies to your connection only
@@global.var → applies to entire server, all connections
*/
SET @dt = '2021-11-28 08:00:00';

SELECT 
    @dt AS Chicago,
    CONVERT_TZ(@dt, 'US/Central', 'Europe/Istanbul') AS Istanbul,
    CONVERT_TZ(@dt, 'US/Central', 'Europe/London') AS London,
    CONVERT_TZ(@dt, 'US/Central', 'America/Edmonton') AS Edmonton,
    CONVERT_TZ(@dt, 'US/Central', 'Asia/Kolkata') AS India;

SET @dt = '2021-11-28 08:00:00';

SELECT 
    @dt AS Chicago,
    CONVERT_TZ(@dt, '-06:00', '+03:00')  AS Istanbul,
    CONVERT_TZ(@dt, '-06:00', '+00:00')  AS London,
    CONVERT_TZ(@dt, '-06:00', '-07:00')  AS Edmonton,
    CONVERT_TZ(@dt, '-06:00', '+05:30')  AS India;
/*
CONVERT_TZ(datetime_value, from_zone, to_zone)
Meaning:
- datetime_value → The date–time you want to convert
- from_zone → The timezone that the datetime_value is currently in
- to_zone → The timezone you want to convert to
Step 1: Source time
- @dt = 08:00
- from_zone = -06:00

Meaning:
- Local = UTC – 6
- UTC = Local + 6 = 8+6=14:00
So now we know the UTC moment:14:00 (2 PM) on 2021-11-28

India = UTC + 5:30
      = 14:00 + 5:30 = 19:30
*/
SET time_zone = '+00:00';
SELECT CONVERT_TZ(NOW(), '+00:00', '+05:30') AS IndiaTime;

SET time_zone = '+05:30';
SELECT  NOW() AS Local_Server_Time, CONVERT_TZ(NOW(), '+00:00', '+05:30') AS India_UTCplus530;

/* But WARNING:
This only works correctly if your session timezone is set to UTC.
Otherwise NOW() is in your session timezone, not UTC.
So let’s set that first:

SET time_zone = '+00:00';
SELECT CONVERT_TZ(NOW(), '+00:00', '+05:30') AS IndiaTime; */

SELECT CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+05:30') AS India_Time;
SELECT CURDATE(), CURTIME(), NOW();
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;
SELECT UTC_DATE(),UTC_TIME(), UTC_TIMESTAMP();


/*
CURRENT_DATE, CURRENT_TIME, and CURRENT_TIMESTAMP are synonyms for CURDATE(), CURTIME(), and NOW(), 
respectively. The preceding functions return values in the client session time zone. 
For values in UTC time, use the UTC_DATE(),UTC_TIME(), or UTC_TIMESTAMP() */

/* What is UTC_TIMESTAMP() in MySQL?
It returns the current date & time in UTC
- NOT your local time
- NOT session time
- NOT server time
Always pure UTC.

It does not care about:
- your laptop zone
- MySQL session zone
- server zone

It always gives global standard time */

/* If your local India time is: 2025-02-10 18:48
Then UTC is:
    = India time – 5 hours 30 minutes  
    = 18:48 – 5:30  
    ≈ 13:18

Now check:
SELECT UTC_TIMESTAMP();

You will see something close to: 2025-02-10 13:18:00

🟡 Difference between NOW() and UTC_TIMESTAMP()
Function	          Returns	                        Depends On
NOW()	              Current time in session timezone	SET time_zone
UTC_TIMESTAMP()	      Current time in UTC	            NEVER changes

Example:
SET time_zone = '+05:30';
SELECT NOW(), UTC_TIMESTAMP();
Output:
NOW()           = 18:48 (India)
UTC_TIMESTAMP() = 13:18 (UTC)

🔵 Why do we use UTC_TIMESTAMP()?
Because it helps convert to ANY timezone reliably:
*/
SELECT
    UTC_TIMESTAMP() AS utc_now,
    CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+05:30') AS india_now,
    CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-06:00') AS chicago_now;

DROP TABLE IF EXISTS tsdemo;
CREATE TABLE `tsdemo` (
`val` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
`ts_both` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
`ts_create` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`ts_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB ;

INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES(0,NULL,NULL,NULL);
INSERT INTO tsdemo (val) VALUES(5);
INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES(10,NULL,NULL,NULL);
SELECT val, ts_both, ts_create, ts_update FROM tsdemo;

INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES(15,NULL,NULL,NULL);
INSERT INTO tsdemo (val) VALUES(50);
INSERT INTO tsdemo VALUES();
INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES(100,NULL,NULL,NULL);
SELECT val, ts_both, ts_create, ts_update FROM tsdemo;
UPDATE tsdemo SET val = 11 WHERE val = 10;
SELECT val, ts_both, ts_create, ts_update FROM tsdemo;
UPDATE tsdemo SET val = val + 1;
SELECT val, ts_both, ts_create, ts_update FROM tsdemo;
UPDATE tsdemo SET val = val;
SELECT val, ts_both, ts_create, ts_update FROM tsdemo;
INSERT INTO tsdemo VALUES();
SELECT * FROM tsdemo;
DROP TABLE  IF EXISTS tsdemo;
CREATE TABLE tsdemo (
  val INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ts_both   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ts_create TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ts_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

SHOW CREATE TABLE tsdemo;
INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES (0, NULL, NULL, NULL);
INSERT INTO tsdemo (val) VALUES (5);
INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES (10, NULL, NULL, NULL);
INSERT INTO tsdemo (val,ts_both,ts_create,ts_update) VALUES (15, NULL, NULL, NULL);
INSERT INTO tsdemo (val) VALUES (50);
INSERT INTO tsdemo VALUES (0, DEFAULT, DEFAULT, DEFAULT);
SELECT * FROM tsdemo;

CREATE TABLE t (
  ts TIMESTAMP NULL
);

INSERT INTO t VALUES (NULL);
SELECT * FROM t;

CREATE TABLE tt (
  ts TIMESTAMP NOT NULL
);
INSERT INTO tt VALUES (NULL);
SELECT * FROM tt;
SELECT @@sql_mode;


