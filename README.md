# phpRS to WordPress

## Popis:
Tento skript usnadňuje migraci dat ze staré databáze PHPRS do nové databáze WordPress. Umožňuje selektivní přenos uživatelů, příspěvků, ětítků, komentářů a souborů. Proces je určen pro čerstvou instalaci systému WordPress.

## Jak používat: V případě potřeby je možné použít tento postup:

1. **Předpoklady:**
   - Připravte si čistou instalaci WordPressu s prázdnou databází.
   - Volitelně nainstalujte plugin "phpRS Soubory" pro import souborů.
   - Přejmenujte názvy DB:
     - Wordpress DB = "archiv"
     - phpRS DB = "phprs"

2. **Nastavení proměnných:**
   - Otevřete soubor "phprs_to_wp_migration.sql" ve svém SQL klientu (např. Visual Studio Code, phpMyAdmin).
   - Podle potřeby upravte proměnné (1 = zapnuto, 0 = vypnuto):
     - `@import_users`
     - `@import_posts`
     - `@import_tags`
     - `@import_comments`
     - `@import_files` vyžaduje plugin "phpRS Soubory" - **soubory nahrát do složky** `wp-content/storage`
     - `@import_gallery` vyžaduje plugin "phpRS Galerie" - **soubory nahrát do složky** `wp-content/gallery`

3. **Provedení migrace:**
   - Zkopírujte obsah skriptu.
   - Vložte jej do klienta SQL připojeného k nové databázi WordPressu.
   - Spusťte dotaz pro zahájení procesu migrace.

4. **Kroky po migraci:**
   - Skript zpracovává přenos článků, ětítků, uživatelů, souborů a komentářů, pokud jsou zvoleny.
   - Volitelné: "RemoveDiacritics" zajistí správné generování slugů.
   - Volitelně: nainstalujte zásuvný plugin "Permalink Manager Lite" a použijte nástroj pro opravu odkazů u příspěvků.

## Důležité poznámky:
- Před spuštěním migračního skriptu zálohujte databázi WordPress, abyste zabránili ztrátě dat.
- Ujistěte se, že práva SQL vašeho serveru umožňují vytváření funkcí a provádění dotazů.

## Autor:
Vytvořil Martin J Skalický v roce 2023.
GitHub: [maskalix/phprs-to-wordpress-db-transfer](https://github.com/maskalix/phprs-to-wordpress-db-transfer/)

## Odmítnutí odpovědnosti:
Tento skript je poskytován tak, jak je, a bez záruky. Používáte jej na vlastní nebezpečí. Autor a přispěvatelé nenesou odpovědnost za ztrátu nebo poškození dat. Nejprve otestujte ve vývojovém prostředí.
