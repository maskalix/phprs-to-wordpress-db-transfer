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
