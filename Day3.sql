/*
MySQL has both CHARACTER SET and COLLATE:
- Character set decides what characters you can store (Hindi, Tamil, English, emojis, Japanese)
- Collation decides how to compare or sort those characters(case-sensitive? accent-sensitive? language rules?)

Since MySQL 8.0 (latest versions):
- Default CHARACTER SET = utf8mb4
- Default COLLATION = utf8mb4_0900_ai_ci

✔ utf8mb4 = full UTF-8 (supports emojis, all languages)
✔ 0900_ai_ci = Unicode collation, accent-insensitive, case-insensitive

🚀 Example: default behavior

If you do:

CREATE TABLE test (
    name VARCHAR(50)
);

MySQL automatically assigns:
- CHARACTER SET = utf8mb4
- COLLATE = utf8mb4_0900_ai_ci

Meaning of utf8mb4_0900_ai_ci

0900 → Unicode standard version 9.0 rules
ai → accent-insensitive (á,à,â = a)
ci → case-insensitive (A=a)

✔ So searching is easy:

WHERE name = 'RAHUL';
WHERE name = 'rahul';
WHERE name = 'Ráhül';
*/

SHOW VARIABLES LIKE 'character_set_server';
SHOW VARIABLES LIKE 'collation_server';
SHOW COLLATION LIKE 'utf8mb4%';
SELECT "I'm asleep", 'He said, "Boo!"';
SELECT 'I ''m asleep', 'I\'m wide awake';
SELECT "He said, ""Boo!"" ", "And I said, \"Yikes!\" ";
SELECT 'Install MySQL in C:\\mysql on Windows';


DROP TABLE IF EXISTS limbs;

CREATE TABLE limbs (
    thing  VARCHAR(20),
    limbs  INT
);

INSERT INTO limbs (thing, limbs) VALUES
(' human',      4),
('insect ',     6),
('squid',      10),
('fish',       0),
(' centipede ',  100);

SELECT * FROM limbs;
SELECT thing,UPPER(thing) AS upper_thing,LOWER(thing) AS lower_thing FROM limbs;
SELECT thing,LENGTH(thing) AS byte_length ,-- bytes ,
CHAR_LENGTH(thing) AS char_length FROM limbs;   -- characters 
SELECT '😊'                           AS val,LENGTH('😊')      AS byte_length,CHAR_LENGTH('😊') AS char_length;
SELECT 'हिंदी'                        AS val,LENGTH('हिंदी')      AS byte_length,CHAR_LENGTH('हिंदी') AS char_length;
/*
💡 Core idea
LENGTH(str) → how many BYTES
CHAR_LENGTH(str) → how many CHARACTERS

For plain English text (A–Z, a–z, digits) in utf8/latin1:
1 character = 1 byte
→ so both numbers are the same.

That’s why in your limbs table they look identical.
When do they differ?
They differ when a character takes more than 1 byte.
That happens with:
Emojis 😄
Hindi / other Indian scripts
Chinese, Japanese, etc.
Accented letters (é, ü, ñ) in UTF-8
 */
SELECT LEFT('centipede', 3),RIGHT('centipede', 3),MID('centipede', 3, 4),SUBSTRING('centipede', 3,4);
 SELECT 'cat' = 'dog', 'cat' <> 'cat', 'cat'<> 'dog',"cat"="Cat","cat"="CAT", 'cat' = 'cat';

SELECT thing,CONCAT('[', TRIM(thing),  ']') AS trimmed,CONCAT('[', LTRIM(thing), ']') AS left_trimmed, 
CONCAT('[', RTRIM(thing), ']')  AS right_trimmed FROM limbs;

SELECT thing,CONCAT(thing, ' has ', limbs, ' limbs') AS sentence,CONCAT_WS(' - ', thing, limbs) AS joined_with_dash
FROM limbs;

SELECT CONCAT('A', NULL, 'B')/* NULL */,CONCAT_WS('-', 'A', NULL, 'B'); -- 'A-B'
/* What is CONCAT_WS?
CONCAT_WS means:CONCAT With Separator
Syntax:
    CONCAT_WS(separator, value1, value2, value3, ...)
First argument = separator string (here: ' - ')
- Then any number of values
- It joins them with that separator
- It skips NULL values automatically

How is it different from CONCAT?
This:
     CONCAT(thing, ' - ', limbs)
Gives same result if nothing is NULL.

But:

     CONCAT → if any argument is NULL, whole result becomes NULL
	CONCAT_WS → skips NULL values
*/
SELECT thing,SUBSTRING(thing, 1, 3) AS first_3,LEFT(thing, 2) AS left_2,RIGHT(thing, 3) AS right_3 FROM limbs;

INSERT INTO limbs Values("insect in house",4);
SELECT thing,INSTR(thing, 'i')  AS pos_of_i, /* -- 0 if not found*/ LOCATE('e', thing) AS pos_of_e,
POSITION('fi' IN thing) AS pos_of_fi FROM limbs;

/*
Position:    1 2 3 4 5 6 7 8 9 10
Characters:  _ c e n t i p e d e

So positions:
position 1 → space
position 2 → c
position 3 → e ← first 'e' is here
position 7 → another e
position 10 → last e
Why it happens?
- LOCATE counts characters exactly as they are, including:
  -- spaces
  -- tabs
  -- newline
  -- invisible UTF-8 characters
  -- accidental leading/trailing whitespace

So LOCATE('e', ' centipede') returns 3 because: SELECT LOCATE('e', TRIM(' centipede'));

LOCATE(substr, str[, start_pos]) (most powerful)
Same as INSTR but syntax reversed
Supports start position (unique feature)

Examples:
   SELECT LOCATE('e', 'centipede'); 
   -- Output: 2   (first e)

   SELECT LOCATE('e', 'centipede', 3);
   -- Output: 7   (next e after position 3)
*/

/*
| Function       | Syntax                                                         | What it does               | Return Value                                   | Supports start position? | Case-sensitive? | Example                    | Output | Notes                                        |
| -------------- | -------------------------------------------------------------- | -------------------------- | ---------------------------------------------- | ------------------------ | --------------- | -------------------------- | ------ | -------------------------------------------- |
| **INSTR()**    | `INSTR(str, substr)`                                           | Searches substr inside str | First match position (1-based). 0 if not found | ❌ No                     | Yes             | `INSTR('centipede','e')`   | **2**  | Arguments reversed vs LOCATE                 |
| **LOCATE()**   | `LOCATE(substr, str)` <br> or `LOCATE(substr, str, start_pos)` | Searches substr inside str | First match position (1-based). 0 if not found | ✔ Yes (third argument)   | Yes             | `LOCATE('e','centipede')`  | **2**  | Same as POSITION but has start_pos parameter |
| **POSITION()** | `POSITION(substr IN str)`                                      | ANSI-SQL search            | First match position (1-based). 0 if not found | ❌ No                     | Yes             | `POSITION('fi' IN 'fish')` | **1**  | Pure SQL standard syntax                     |

*/
SELECT LOCATE('E','
 centipede '),LENGTH('
 centipede ');

SELECT thing,POSITION('qu' IN thing) from limbs;
SELECT thing, REPLACE(thing, 'in', 'IN') AS replaced_in FROM limbs;
SELECT * FROM limbs;

SELECT thing, LPAD(thing, 12, '*') AS left_padded, RPAD(thing, 12, '_') AS right_padded FROM limbs;
SELECT 'centipede' AS original,LPAD('centipede', 5, ' ') AS left_padded,RPAD('centipede', 5, ' ') AS right_padded;
SELECT 'human' AS original,LPAD( RPAD('human', 10, ' '),15,' ') AS centered_15;
/* Summary in words

LPAD(str, n, ' ') →
If n > length(str) → adds spaces on the left
If n < length(str) → cuts from left side, keeps right part

RPAD(str, n, ' ') →
If n > length(str) → adds spaces on the right
If n < length(str) → cuts from right side, keeps left part

To have spaces on both sides (centered in 15 chars):
First RPAD to some mid length, then LPAD to final: LPAD(RPAD(str, 10, ' '), 15, ' ')
*/
SELECT thing,REPEAT(thing, 2) AS repeated_twice,REVERSE(thing) AS reversed FROM limbs;

/* ============================================================
   INSERT() FUNCTION – THEORY + PRACTICAL EXAMPLES (MySQL)
   --------------------------------------------------------
   Syntax:
       INSERT(str, pos, len, newstr)

   Meaning:
       - str    : original string
       - pos    : starting position (1-based index)
       - len    : how many characters to remove from str
       - newstr : what to insert in place of the removed chars

   Result:
       Take str, starting at position pos, remove len characters,
       and in that place insert newstr.

   NOTE:
       INSERT() returns a NEW string in the SELECT result.
       It does NOT modify the table unless used in an UPDATE.
   ============================================================ */

-- ============================================================
-- 0. Setup sample table: limbs
-- ============================================================

DROP TABLE IF EXISTS limbs;

CREATE TABLE limbs (
    thing VARCHAR(20),
    limbs INT
);

INSERT INTO limbs (thing, limbs) VALUES
('human',      4),
('insect',     6),
('squid',      10),
('fish',       0),
('centipede',  100);

SELECT * FROM limbs;

-- ============================================================
-- 1. Simple INSERT() example on limbs
-- ------------------------------------------------------------
-- Example:
--   INSERT(thing, 2, 3, 'XX')
-- Steps for thing = 'human':
--   Positions:  h(1) u(2) m(3) a(4) n(5)
--   pos = 2, len = 3
--   Keep characters before pos 2: 'h'
--   Remove 3 chars from pos 2: 'u','m','a'
--   Remaining right part: 'n'
--   Insert 'XX' in place of removed chars
--   Result: 'h' + 'XX' + 'n' = 'hXXn'
-- ============================================================

SELECT thing,INSERT(thing, 2, 3, 'XX') AS inserted_example FROM limbs;

-- ============================================================
-- 2. EXTREME / EDGE CASES WITH STRING 'ABCDEFGHIJ'
--    Base string length = 10
--    Characters and positions:
--        Pos : 1 2 3 4 5 6 7 8 9 10
--        Chr : A B C D E F G H I  J
-- ============================================================

-- Show base string
SELECT 'ABCDEFGHIJ' AS base_string;

-- ------------------------------------------------------------
-- 2A. Normal replacement in the middle
--   INSERT('ABCDEFGHIJ', 3, 4, 'XX')
--   Start at pos 3 → 'C'
--   Remove 4 chars: 'C','D','E','F'
--   Left = 'AB', right = 'GHIJ'
--   Result = 'AB' + 'XX' + 'GHIJ' = 'ABXXGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 3, 4, 'XX') AS example_2A;

-- ------------------------------------------------------------
-- 2B. Replace at the start (pos = 1)
--   INSERT('ABCDEFGHIJ', 1, 3, 'Z')
--   Remove 3 chars from start: 'A','B','C'
--   Remaining: 'DEFGHIJ'
--   Insert 'Z' at front → 'ZDEFGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 1, 3, 'Z') AS example_2B;

-- ------------------------------------------------------------
-- 2C. Replace at the end
--   INSERT('ABCDEFGHIJ', 8, 5, 'END')
--   Start at pos 8 → 'H'
--   Remove 5 chars from pos 8:
--       only 'H','I','J' exist, so remove till end
--   Left = 'ABCDEFG', right = ''
--   Result = 'ABCDEFG' + 'END' = 'ABCDEFGEND'
-- ------------------------------------------------------------
SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 8, 5, 'END') AS example_2C;
-- ------------------------------------------------------------
-- 2D. len bigger than remaining string
--   INSERT('ABCDEFGHIJ', 5, 100, 'XX')
--   Start at pos 5 → 'E'
--   Remove 100 chars from there → removes 'E','F','G','H','I','J'
--   Left = 'ABCD', right = ''
--   Result = 'ABCDXX'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 5, 100, 'XX') AS example_2D;

-- ------------------------------------------------------------
-- 2E. len = 0 (insertion without deletion)
--   INSERT('ABCDEFGHIJ', 4, 0, 'X')
--   Start at pos 4 (between 'C' and 'D')
--   Remove 0 characters
--   Left  = 'ABC'
--   Right = 'DEFGHIJ'
--   Result = 'ABC' + 'X' + 'DEFGHIJ' = 'ABCXDEFGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 4, 0, 'X') AS example_2E;

-- ------------------------------------------------------------
-- 2F. pos beyond string length
--   INSERT('ABCDEFGHIJ', 20, 3, 'Z')
--   String length = 10
--   pos = 20 > 10
--   Rule: if pos > length(str), return original string unchanged
--   Result = 'ABCDEFGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 20, 3, 'Z') AS example_2F;

-- ------------------------------------------------------------
-- 2G. pos = 0 or negative
--   INSERT('ABCDEFGHIJ', 0, 3, 'Z')
--   INSERT('ABCDEFGHIJ', -2, 3, 'Z')
--   Rule: if pos <= 0, return original string unchanged
--   Both results = 'ABCDEFGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 0, 3, 'Z')  AS example_2G_pos_0,
INSERT('ABCDEFGHIJ', -2, 3, 'Z') AS example_2G_pos_negative;

-- ------------------------------------------------------------
-- 2H. newstr = '' (empty string) → behaves like delete
--   INSERT('ABCDEFGHIJ', 3, 4, '')
--   Start at pos 3 → 'C'
--   Remove 4 chars: 'C','D','E','F'
--   Left = 'AB', right = 'GHIJ'
--   Insert '' (nothing)
--   Result = 'ABGHIJ' (substring removed)
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 3, 4, '') AS example_2H;

-- ------------------------------------------------------------
-- 2I. newstr longer than removed part
--   INSERT('ABCDEFGHIJ', 3, 2, 'XXXX')
--   Start at pos 3 → 'C'
--   Remove 2 chars: 'C','D'
--   Left = 'AB', right = 'EFGHIJ'
--   Insert 'XXXX'
--   Result = 'AB' + 'XXXX' + 'EFGHIJ' = 'ABXXXXEFGHIJ'
-- ------------------------------------------------------------

SELECT 'ABCDEFGHIJ' AS original,INSERT('ABCDEFGHIJ', 3, 2, 'XXXX') AS example_2I;

-- ============================================================
-- 3. INSERT() WITH limbs TABLE
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Mask first 2 letters with 'XX'
--   INSERT(thing, 1, 2, 'XX')
--   Example: 'human'  → 'XXman'
--            'insect' → 'XXsect'
--            'fish'   → 'XXsh'
-- ------------------------------------------------------------

SELECT thing,INSERT(thing, 1, 2, 'XX') AS masked_first_2 FROM limbs;

-- ------------------------------------------------------------
-- 3.2 Insert '::' after first character
--   INSERT(thing, 2, 0, '::')
--   pos = 2, len = 0 → insert without deleting
--   'human'  → 'h::uman'
--   'insect' → 'i::nsect'
-- ------------------------------------------------------------

SELECT thing,INSERT(thing, 2, 0, '::') AS with_colon FROM limbs;

-- ------------------------------------------------------------
-- 3.3 Remove last 2 characters (for variable-length strings)
--   We want to delete last 2 chars:
--   Strategy:
--     pos = CHAR_LENGTH(thing) - 1
--     len = 2
--   For 'human' (length 5):
--     pos = 5 - 1 = 4
--     remove 2 chars from pos 4 → 'a','n'
--     result = 'hum'
-- ------------------------------------------------------------

SELECT thing,CHAR_LENGTH(thing) AS original_length,INSERT(thing, CHAR_LENGTH(thing)-1, 2, '') AS chopped_last_2 FROM limbs;

-- ============================================================
-- 4. QUICK MENTAL MODEL (IN COMMENTS)
-- ------------------------------------------------------------
-- INSERT(str, pos, len, newstr) works like:
--
--   1. Split str into:
--        left  = characters BEFORE pos
--        mid   = characters from pos for len chars (this part is removed)
--        right = remaining characters AFTER (pos + len - 1)
--
--   2. Result string:
--        result = left + newstr + right
--
-- EDGE CASE RULES:
--   - pos <= 0               → return original str unchanged
--   - pos > LENGTH(str)      → return original str unchanged
--   - len > remaining length → delete from pos to end
--   - len = 0                → pure insertion (no deletion)
--   - newstr = ''            → pure deletion (mid part removed)
-- ============================================================
-- Things whose name contains 'E'
SELECT * FROM limbs WHERE INSTR(thing, 'E') > 0;

-- Order by length of the name
SELECT * FROM limbs ORDER BY CHAR_LENGTH(thing);

SELECT REVERSE(0123456789),REVERSE("0123456789"),REVERSE(001122334455);
/* The following example shows that when the expression is a numeric
value, the zero value is omitted by the function.*/
 SELECT COUNT(*) FROM limbs WHERE REVERSE(thing) = thing;

SET @date = '2015-07-21';
SELECT @date, LEFT(@date,4) AS year,MID(@date,6,2) AS month, RIGHT(@date,2) AS day;
SELECT @date, SUBSTRING(@date,6), MID(@date,6);

/*
Use SUBSTRING_INDEX(str,c,n) to return everything to the right or left of a given character. 
It searches into a string, str, for the n-th occurrence of the character c and returns everything to its left. 
If n is negative, the search for c starts from the right and returns everything to the right of the character:
If there is no n-th occurrence of the character, SUBSTRING_INDEX() returns the entire string. SUBSTRING_INDEX() is case sensitive.
*/
SET @email = 'postmaster@example.com';
SELECT @email,SUBSTRING_INDEX(@email,'@',1) AS user,SUBSTRING_INDEX(@email,'@',-1) AS host;
SELECT thing from limbs  WHERE LEFT(thing,1) >= 'n';
SELECT CONCAT(thing,' ends in "d": ',IF(thing LIKE'%d','YES','NO')) AS 'ends in "d"?' FROM limbs;
/* not working */
UPDATE limbs SET thing = CONCAT(thing,'ide') where 1=1;
SELECT thing FROM limbs;
SELECT * FROM limbs;
INSERT INTO limbs values (NULL,70);
SELECT * FROM limbs;
SET SQL_SAFE_UPDATES = 0;
UPDATE limbs SET thing = IF(thing IS NULL,":null",CONCAT(thing,':',"not null"));
SELECT * FROM limbs;
SET SQL_SAFE_UPDATES = 0;
UPDATE limbs SET thing = replace(thing,":not null","");
SELECT * FROM limbs;
UPDATE limbs SET thing = replace(thing,":null",NULL) where thing=":null";
SELECT * FROM limbs;


SELECT NULL LIKE '%', NULL NOT LIKE '%';

/*
Key rule: ANY comparison with NULL → result is NULL (unknown)
   NULL = 5 → NULL
   NULL > 10 → NULL
   NULL LIKE '%' → NULL

So:
   NULL LIKE '%' = NULL (not TRUE, not FALSE)
   NULL NOT LIKE '%' → this is NOT (NULL LIKE '%') → NOT NULL → still NULL in SQL’s 3-valued logic
   */
   
/*
Pattern match | Substring comparison
  str LIKE 'abc%' | LEFT(str,3) = 'abc'
  str LIKE '%abc' | RIGHT(str,3) = 'abc'
Function value test | Pattern match test
  YEAR(d) = 1975 | d LIKE '1975-%'
  MONTH(d) = 6 | d LIKE '%-06-%'
  DAYOFMONTH(d) = 21| d LIKE '%-21'
*/
   
/*Popular regular expressions
Pattern    What the pattern matches
^          Beginning of string
$          End of string
.          Any single character
[...]      Any character listed between the square brackets
[^...]     Any character not listed between the square brackets
p1|p2|p3   Alternation; matches any of the patterns p1,p2,or p3
*          Zero or more instances of preceding element
+          One or more instances of preceding element
{n}        n instances of preceding element
{m,n}      m through n instances of preceding element

POSIX class What the class matches
[:alnum:] Alphabetic and numeric characters
[:alpha:] Alphabetic characters
[:blank:] Whitespace (space or tab characters)
[:cntrl:] Control characters
[:digit:] Digits
[:graph:] Graphic (nonblank) characters
[:lower:] Lowercase alphabetic characters
[:print:] Graphic or space characters
[:punct:] Punctuation characters
[:space:] Space, tab, newline, carriage return
[:upper:] Uppercase alphabetic characters
[:xdigit:] Hexadecimal digits (0-9,a-f, A-F)
 */

