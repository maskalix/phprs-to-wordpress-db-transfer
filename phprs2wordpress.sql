--                              _         _ _      
--    ____                     | |       | (_)     
--   / __ \ _ __ ___   __ _ ___| | ____ _| |___  __
--  / / _` | '_ ` _ \ / _` / __| |/ / _` | | \ \/ /
-- | | (_| | | | | | | (_| \__ \   < (_| | | |>  < 
--  \ \__,_|_| |_| |_|\__,_|___/_|\_\__,_|_|_/_/\_\
--   \____/                                        

-- Název staré PHPRS databáze je "phprs" a nové WordPress databáze je "archiv"
-- pokud se jmenují databáze jinak, pomocí nástroje (př. Visual Studio Code) přepiš všechny hodnoty "phprs" a "archiv" na hodnoty odpovídající potřebám
-- Co chceš přenést? (nespouštět skript na několikrát, vždy na čistou instalaci/stylem jednou a víckrát ne :D)
-- (1 = ano, 0 = ne)
SET @import_users = 1;      -- Uživatelé 
SET @import_posts = 1;      -- Články 
SET @import_tags = 1;       -- Štítky 
SET @import_comments = 0;   -- Komentáře 
SET @import_files = 1;      -- Soubory (nutno nainstalovat také plugin "phpRS Soubory")

SET SQL_MODE = '';
ALTER TABLE `wp_posts` CHANGE `post_date` `post_date` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_date_gmt` `post_date_gmt` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_modified` `post_modified` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_modified_gmt` `post_modified_gmt` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';

ALTER TABLE `wp_posts` CHANGE COLUMN to_ping to_ping VARCHAR(255) DEFAULT NULL;
ALTER TABLE `wp_posts` CHANGE COLUMN pinged pinged VARCHAR(255) DEFAULT NULL;
ALTER TABLE `wp_posts` CHANGE COLUMN post_content_filtered post_content_filtered LONGTEXT DEFAULT NULL;
ALTER TABLE `wp_term_taxonomy` CHANGE COLUMN description description VARCHAR(255) DEFAULT NULL;

-- Step 1: Import data from "phprs.rs_user" to "archiv.wp_users" (user information).
INSERT IGNORE INTO archiv.wp_users (user_login, user_email, display_name)
SELECT rs_user.user AS user_login, rs_user.email AS user_email, rs_user.jmeno AS display_name
FROM phprs.rs_user AS rs_user
WHERE @import_users = 1;

-- Step 2: Import data from "phprs.rs_clanky" and "phprs.rs_user" to "archiv.wp_posts" (posts and post authors).
INSERT INTO archiv.wp_posts (post_date, post_date_gmt, post_author, post_content, post_title, post_excerpt, post_name)
SELECT 
    DATE_SUB(datum, INTERVAL 2 HOUR) AS post_date,
    DATE_SUB(datum, INTERVAL 2 HOUR) AS post_date_gmt,
    wp_users.ID AS post_author,
    CONCAT(uvod, '\n', text) AS post_content,
    titulek AS post_title,
    uvod AS post_excerpt,
    titulek AS post_name
FROM phprs.rs_clanky
JOIN phprs.rs_user ON phprs.rs_clanky.autor = phprs.rs_user.idu
JOIN archiv.wp_users AS wp_users ON rs_user.jmeno = wp_users.display_name
WHERE @import_posts = 1;

-- Step 3: Handle tags (insert new terms and allow duplicates in "archiv.wp_term_taxonomy").
INSERT IGNORE INTO archiv.wp_terms (name, slug)
SELECT DISTINCT
    rs_topic.nazev AS name,
    LOWER(REPLACE(rs_topic.nazev, ' ', '-')) AS slug
FROM phprs.rs_topic
WHERE @import_tags = 1;

INSERT IGNORE INTO archiv.wp_term_taxonomy (term_id, taxonomy)
SELECT 
    term_id,
    'post_tag' AS taxonomy
FROM archiv.wp_terms
WHERE @import_tags = 1;

-- Step 4: Assign tags to posts in "archiv.wp_term_relationships" (disallow duplicates).
INSERT IGNORE INTO archiv.wp_term_relationships (object_id, term_taxonomy_id)
SELECT 
    archiv.wp_posts.ID AS object_id,
    archiv.wp_term_taxonomy.term_taxonomy_id AS term_taxonomy_id
FROM archiv.wp_posts
JOIN phprs.rs_clanky ON archiv.wp_posts.post_title = phprs.rs_clanky.titulek
JOIN phprs.rs_topic ON phprs.rs_clanky.tema = phprs.rs_topic.idt
JOIN archiv.wp_terms ON archiv.wp_terms.name = phprs.rs_topic.nazev
JOIN archiv.wp_term_taxonomy ON archiv.wp_terms.term_id = archiv.wp_term_taxonomy.term_id
WHERE archiv.wp_term_taxonomy.taxonomy = 'post_tag'
AND @import_tags = 1;

-- Step 5: Import comments from "phprs.rs_komentare" to "archiv.wp_comments" (only if @import_comments is set to 1).
INSERT INTO archiv.wp_comments (comment_post_ID, comment_author, comment_date, comment_content, comment_parent)
SELECT
    wp_posts.ID AS comment_post_ID,
    rs_komentare.od AS comment_author,
    DATE_SUB(rs_komentare.datum, INTERVAL 2 HOUR) AS comment_date,
    rs_komentare.obsah AS comment_content,
    0 AS comment_parent
FROM phprs.rs_komentare
JOIN phprs.rs_clanky ON rs_komentare.clanek = phprs.rs_clanky.link
JOIN archiv.wp_posts AS wp_posts ON phprs.rs_clanky.titulek = wp_posts.post_title
WHERE @import_comments = 1;

-- Files
-- Step 6: Create the new table in "archiv" database
CREATE TABLE IF NOT EXISTS archiv.wp_files (
    id INT(11) NOT NULL AUTO_INCREMENT,
    nazev VARCHAR(255) NOT NULL,
    datum DATETIME NOT NULL,
    koncovka VARCHAR(10) DEFAULT '.txt',
    id_vlastnika INT(11) NOT NULL,
    mime VARCHAR(255) DEFAULT 'text/plain',
    PRIMARY KEY (id)
);

-- Step 7: Import data from "phprs.rs_spravce_souboru" to "archiv.wp_files" if @import_files is ON
INSERT INTO archiv.wp_files (nazev, datum, koncovka, id_vlastnika, mime)
SELECT
    IF(s_skut_nazev IS NULL OR s_skut_nazev = '', nazev, s_skut_nazev) AS nazev,
    datum,
    koncovka,
    id_vlastnika,
    IF(s_mime IS NULL OR s_mime = '', 'text/plain', s_mime) AS mime
FROM phprs.rs_spravce_souboru
WHERE koncovka <> '-' AND @import_files = 1;

-- Reset the AUTO_INCREMENT value to start from 1
ALTER TABLE archiv.wp_files AUTO_INCREMENT = 1;


-- Step 8: Rewrite without diacritics
-- Drop the existing function (if it already exists)
DROP FUNCTION IF EXISTS RemoveDiacritics;

-- Create the updated function
DELIMITER //
CREATE FUNCTION RemoveDiacritics(inputText VARCHAR(255)) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    SET @outputText = inputText;
    SET @diacritics = 'ÁÄČĎÉĚÍĹĽŇÓÖŘŠŤÚŮÝŽáäčďéěíĺľňóöřšťúůýž';
    SET @replaceChars = 'AACDEEILLNOORSTUUYZaacdeeillnoorstuuyz';
    SET @diacriticIndex = 1;
    SET @diacriticCount = CHAR_LENGTH(@diacritics);

    WHILE @diacriticIndex <= @diacriticCount DO
        SET @diacriticChar = SUBSTRING(@diacritics, @diacriticIndex, 1);
        SET @replaceChar = SUBSTRING(@replaceChars, @diacriticIndex, 1);
        SET @outputText = REPLACE(@outputText, @diacriticChar, @replaceChar);
        SET @diacriticIndex = @diacriticIndex + 1;
    END WHILE;

    SET @outputText = REPLACE(@outputText, ' ', '-'); -- Replace spaces with "-"

    RETURN LOWER(@outputText); -- Convert the output to lowercase
END//
DELIMITER ;


-- Step 11: Use the function to update the "slug" column in "wp_terms" table
UPDATE wp_terms SET slug = RemoveDiacritics(slug);
UPDATE wp_posts SET post_name = RemoveDiacritics(post_name);
-- Created by Martin J Skalicky, 2023
-- https://github.com/maskalix/phprs-to-wordpress-db-transfer/
