# phpRS to WordPress

## Description:
This script facilitates migrating data from an old PHPRS database to a new WordPress database. It allows selective transfer of users, posts, tags, comments, and files. The process is designed for a fresh WordPress installation.

## How to Use:

1. **Prerequisites:**
   - Prepare a clean WordPress installation with an empty database.
   - Optionally, install the "phpRS Soubory" plugin for file imports.
   - Rename the DB names:
     - Wordpress DB = "archiv"
     - phpRS DB = "phprs"

2. **Setting Variables:**
   - Open "phprs_to_wp_migration.sql" in your SQL client (e.g., Visual Studio Code, phpMyAdmin).
   - Modify the variables as needed (1 = on, 0 = off):
     - `@import_users`
     - `@import_posts`
     - `@import_tags`
     - `@import_comments`
     - `@import_files` requires "phpRS Soubory" plugin - put the files into `wp-content/storage`
     - `@import_gallery` requires the plugin "phpRS Gallery" - **upload files to folder** `wp-content/gallery`

3. **Executing the Migration:**
   - Copy the script content.
   - Paste it into your SQL client connected to the new WordPress database.
   - Execute the query to begin the migration process.

4. **Post-Migration Steps:**
   - The script handles data transformations, importing tags and comments if selected.
   - Users, posts, and files from the old PHPRS database will be available in the new WordPress database.
   - The custom function "RemoveDiacritics" ensures proper slug generation.
   - Optional: install plugin "Permalink Manager Lite" and use repair tool to repair post links

## Important Notes:
- Backup your WordPress database before running the migration script to prevent data loss.
- Ensure your server's SQL privileges allow function creation and query execution.

## Author:
Created by Martin J Skalicky in 2023.
GitHub: [maskalix/phprs-to-wordpress-db-transfer](https://github.com/maskalix/phprs-to-wordpress-db-transfer/)

## Disclaimer:
This script is provided as-is and without warranty. Use at your own risk. The author and contributors are not liable for data loss or damage. Test in a development environment first.
