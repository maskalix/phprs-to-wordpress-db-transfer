-- Název staré PHPRS databáze je "archiv" a nové WordPress databáze je "staryweb"
-- pokud se jmenují databáze jinak, pomocí nástroje (př. Visual Studio Code) přepiš všechny hodnoty "archiv" a "staryweb" na hodnoty odpovídající potřebám

SET SQL_MODE = '';
ALTER TABLE `wp_posts` CHANGE `post_date` `post_date` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_date_gmt` `post_date_gmt` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_modified` `post_modified` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';
ALTER TABLE `wp_posts` CHANGE `post_modified_gmt` `post_modified_gmt` DATETIME  NOT NULL  DEFAULT '1970-01-01 00:00:00';

ALTER TABLE `wp_posts` CHANGE COLUMN to_ping to_ping VARCHAR(255) DEFAULT NULL;
ALTER TABLE `wp_posts` CHANGE COLUMN pinged pinged VARCHAR(255) DEFAULT NULL;
ALTER TABLE `wp_posts` CHANGE COLUMN post_content_filtered post_content_filtered LONGTEXT DEFAULT NULL;
ALTER TABLE `wp_term_taxonomy` CHANGE COLUMN description description VARCHAR(255) DEFAULT NULL;

-- Step 1: Import data from "archiv.rs_user" to "staryweb.wp_users" (user information).
INSERT IGNORE INTO staryweb.wp_users (user_login, user_email, display_name)
SELECT 
    rs_user.user AS user_login,
    rs_user.email AS user_email,
    rs_user.jmeno AS display_name
FROM archiv.rs_user AS rs_user;

-- Step 2: Import data from "archiv.rs_clanky" and "archiv.rs_user" to "staryweb.wp_posts" (posts and post authors).
INSERT INTO staryweb.wp_posts (post_date, post_date_gmt, post_author, post_content, post_title, post_excerpt, post_name)
SELECT 
    DATE_SUB(datum, INTERVAL 2 HOUR) AS post_date,
    DATE_SUB(datum, INTERVAL 2 HOUR) AS post_date_gmt,
    wp_users.ID AS post_author,
    CONCAT(uvod, '\n', text) AS post_content,
    titulek AS post_title,
    uvod AS post_excerpt,
    titulek AS post_name
FROM archiv.rs_clanky
JOIN archiv.rs_user ON archiv.rs_clanky.autor = archiv.rs_user.idu
JOIN staryweb.wp_users AS wp_users ON rs_user.jmeno = wp_users.display_name;

-- Step 3: Handle tags (insert new terms and allow duplicates in "staryweb.wp_term_taxonomy").
INSERT IGNORE INTO staryweb.wp_terms (name, slug)
SELECT DISTINCT
    rs_topic.nazev AS name,
    LOWER(REPLACE(rs_topic.nazev, ' ', '-')) AS slug
FROM archiv.rs_topic;

INSERT IGNORE INTO staryweb.wp_term_taxonomy (term_id, taxonomy)
SELECT 
    term_id,
    'post_tag' AS taxonomy
FROM staryweb.wp_terms;

-- Step 4: Assign tags to posts in "staryweb.wp_term_relationships" (disallow duplicates).
INSERT IGNORE INTO staryweb.wp_term_relationships (object_id, term_taxonomy_id)
SELECT 
    staryweb.wp_posts.ID AS object_id,
    staryweb.wp_term_taxonomy.term_taxonomy_id AS term_taxonomy_id
FROM staryweb.wp_posts
JOIN archiv.rs_clanky ON staryweb.wp_posts.post_title = archiv.rs_clanky.titulek
JOIN archiv.rs_topic ON archiv.rs_clanky.tema = archiv.rs_topic.idt
JOIN staryweb.wp_terms ON staryweb.wp_terms.name = archiv.rs_topic.nazev
JOIN staryweb.wp_term_taxonomy ON staryweb.wp_terms.term_id = staryweb.wp_term_taxonomy.term_id
WHERE staryweb.wp_term_taxonomy.taxonomy = 'post_tag';


-- Rewrite without diacritics
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


-- Step 2: Use the function to update the "slug" column in "wp_terms" table
UPDATE wp_terms SET slug = RemoveDiacritics(slug);
UPDATE wp_posts SET post_name = RemoveDiacritics(post_name);
-- Created by Martin J Skalicky, 2023
-- https://github.com/maskalix/phprs-to-wordpress-db-transfer/
