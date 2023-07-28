# phpRS to WordPress DB Transfer
<h1>🇨🇿 <b>Česky</b></h1>
<p>Převod/přenos příspěvků, uživatelů a tagů z PHPRS do WordPressu (SQL skript)</p>
<b>Vše funguje jednoduše skrze SQL skript.</b>
<br>
<p>Pokud chcete pouze odstranit diakritiku u odkazů, stačí použít skript remove-diacritics.sql (součástí hlavního skriptu)</p>
<p><b>Důležité kroky:</b></p>
<ul>
  <li>název staré PHPRS databáze je "archiv" a nové WordPress databáze je "staryweb"</li>
  <li>pokud se jmenují databáze jinak, pomocí nástroje (př. Visual Studio Code)</li>
  <li>přepiš všechny hodnoty "archiv" a "staryweb" na hodnoty odpovídající potřebám</li>
</ul>
<p>Následně doporučuji použít WordPress plugin "Permalink Manager Lite", který by měl opravit odkazy článků, kdyby se s nimi vycházeli chyby.</p>
<p><b>NUTNO SPUSTIT V NOVÉ DATABÁZI (WORDPRESS)</b></p>
<h1>🇬🇧 <b>English</b></h1>
<p>Convert/transfer posts, users and tags from PHPRS to WordPress (SQL script)</p>
<b>Everything works simply through an SQL script:</b>
<br>
<p>If you only want to remove diacritics from links, just use the remove-diacritics.sql script (part of the main script)</p>
<p><b>Essential steps:</b></p>
<ul>
  <li>the name of the old PHPRS database is "archive" and the new WordPress database is "staryweb"</li>
  <li>if the database is named differently, using a tool (e.g. Visual Studio Code)</li>
  <li>rewrite all "archive" and "staryweb" values to values corresponding to needs</li>
</ul>
<p>Next, I recommend using the WordPress plugin "Permalink Manager Lite", which should fix the article links if there are any errors.</p>
<p><b>MUST BE RUN IN A NEW DATABASE (WORDPRESS)</b></p>
