## SQL - Funkcje okna (Window functions) <br> Lab 2

---

**Imiona i nazwiska:** Mateusz Lampert, Marek Małek

---

Celem ćwiczenia jest zapoznanie się z działaniem funkcji okna (window functions) w SQL, analiza wydajności zapytań i porównanie z rozwiązaniami przy wykorzystaniu "tradycyjnych" konstrukcji SQL

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---

> Wyniki:

```sql
--  ...
```

---

### Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki, (dołącz kod rozwiązania w formie tekstowej/źródłowej)

Zwróć uwagę na formatowanie kodu

---

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie:

- MS SQL Server - wersja 2019, 2022
- PostgreSQL - wersja 15/16/17
- SQLite
- Narzędzia do komunikacji z bazą danych
  - SSMS - Microsoft SQL Managment Studio
  - DtataGrip lub DBeaver
- Przykładowa baza Northwind/Northwind3
  - W wersji dla każdego z wymienionych serwerów

Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej

## Dokumentacja/Literatura

- Kathi Kellenberger,  Clayton Groom, Ed Pollack, Expert T-SQL Window Functions in SQL Server 2019, Apres 2019
- Itzik Ben-Gan, T-SQL Window Functions: For Data Analysis and Beyond, Microsoft 2020

- Kilka linków do materiałów które mogą być pomocne
   - [https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16)
  - [https://www.sqlservertutorial.net/sql-server-window-functions/](https://www.sqlservertutorial.net/sql-server-window-functions/)
  - [https://www.sqlshack.com/use-window-functions-sql-server/](https://www.sqlshack.com/use-window-functions-sql-server/)
  - [https://www.postgresql.org/docs/current/tutorial-window.html](https://www.postgresql.org/docs/current/tutorial-window.html)
  - [https://www.postgresqltutorial.com/postgresql-window-function/](https://www.postgresqltutorial.com/postgresql-window-function/)
  - [https://www.sqlite.org/windowfunctions.html](https://www.sqlite.org/windowfunctions.html)
  - [https://www.sqlitetutorial.net/sqlite-window-functions/](https://www.sqlitetutorial.net/sqlite-window-functions/)

- W razie potrzeby - opis Ikonek używanych w graficznej prezentacji planu zapytania w SSMS jest tutaj:
  - [https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference](https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference)

## Przygotowanie

Uruchom SSMS
- Skonfiguruj połączenie z bazą Northwind na lokalnym serwerze MS SQL 

Uruchom DataGrip (lub Dbeaver)

- Skonfiguruj połączenia z bazą Northwind3
  - na lokalnym serwerze MS SQL
  - na lokalnym serwerze PostgreSQL
  - z lokalną bazą SQLite

Można też skorzystać z innych narzędzi klienckich (wg własnego uznania)

Oryginalna baza Northwind jest bardzo mała. Warto zaobserwować działanie na nieco większym zbiorze danych.

Korzystamy ze "zmodyfikowanej wersji" bazy northwind

Baza Northwind3 zawiera dodatkową tabelę product_history

- 2,2 mln wierszy

Bazę Northwind3 można pobrać z moodle (zakładka - Backupy baz danych)

# Zadanie 1

Funkcje rankingu, `row_number()`, `rank()`, `dense_rank()`

```sql
select productid, productname, unitprice, categoryid,
    row_number() over(partition by categoryid order by unitprice desc) as rowno,
    rank() over(partition by categoryid order by unitprice desc) as rankprice,
    dense_rank() over(partition by categoryid order by unitprice desc) as denserankprice
from products;
```

Wykonaj polecenie, zaobserwuj wynik. Porównaj funkcje row_number(), rank(), dense_rank(). Skomentuj wyniki.

Spróbuj uzyskać ten sam wynik bez użycia funkcji okna

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

---

> Wyniki:

Wynik zapytania z polecenia:

![alt text](image-1.png)

Komentarz:

- `row_number` to numer danego wiersza wewnątrz okna, zgodnie z zadaną kolejnością (tutaj: `unitprice desc`, natomiast zgodnie z [dokumentacją oracle](https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions137.htm), funkcja `row_number` nie jest deterministyczna w przypadku remisów). W przypadku `row_number` nie ma remisów w wartościach, zawsze dostajemy wartości `1..<ilosc wierszy w oknie>`.
- `rank` to ranga danego wiersza wewnątrz okna, zgodnie z zadaną kolejnością (tutaj: `unitprice desc`). W przypadku remisów, wszystkie wiersze o tej samej wartości dostają tę samą rangę `r`, natomiast wiersze o następnej w kolejności wartości dostają rangę `r+k`, gdzie `k`-ilość remisujących wierszy. `rank` zawsze przyjmowało wartości `1..<ilosc wierszy w oknie>`.
- `dense_rank` działa podobnie jak `rank`, natomiast w przypadku remisów, wszystkie wiersze o tej samej wartości dostają tę samą rangę `r`, a wiersze o następnej w kolejności wartości dostają rangę `r+1` (nie przeskakujemy wartości).

Te same wyniki można także uzyskać nie korzystając z funkcji okna, z wykorzystaniem podzapytań lub instrukcji `join`:

- `row_number`:

```sql
--  row_number() z inner-join
select p1.productid, p1.productname, p1.unitprice, p1.categoryid, count(p2.productid) + 1 as rowno_custom
from products p1
         left join products p2
              on p2.categoryid = p1.categoryid and
                 (p2.unitprice > p1.unitprice or (p2.unitprice = p1.unitprice and p2.productid < p1.productid))
group by p1.productid, p1.productname, p1.unitprice, p1.categoryid
order by p1.categoryid, rowno_custom;

-- row_number() z subquery
select productid, productname, unitprice, categoryid,
    (
        select count(*) + 1
        from products p2
        where p2.categoryid = p1.categoryid
            and (
                p2.unitprice > p1.unitprice
                or (p2.unitprice = p1.unitprice and p2.productid < p1.productid)
            )
    ) as rowno_custom
from products p1
order by p1.categoryid, rowno_custom;
```

- `rank`:

```sql
-- rank() z inner-join
select p1.productid, p1.productname, p1.unitprice, p1.categoryid, count(p2.productid) + 1 as rankprice_custom
from products p1
         left join products p2
                   on p2.categoryid = p1.categoryid and p2.unitprice > p1.unitprice
group by p1.productid, p1.productname, p1.unitprice, p1.categoryid
order by p1.categoryid, rankprice_custom;

-- rank() z subquery
select productid, productname, unitprice, categoryid,
    (
        select count(*) + 1
        from products p2
        where p2.unitprice > p1.unitprice and p2.categoryid = p1.categoryid
    ) as rankprice_custom
from products p1
order by p1.categoryid, rankprice_custom;
```

- `dense_rank`:

```sql
-- dense_rank() z inner-join
select p1.productid, p1.productname, p1.unitprice, p1.categoryid, count(distinct p2.unitprice) + 1 as denserankprice_custom
from products p1
         left join products p2
                   on p2.categoryid = p1.categoryid and p2.unitprice > p1.unitprice
group by p1.productid, p1.productname, p1.unitprice, p1.categoryid
order by p1.categoryid, denserankprice_custom;

-- dense_rank() z subquery
select productid, productname, unitprice, categoryid,
    (
        select count(distinct p2.unitprice) + 1
        from products p2
        where p2.unitprice > p1.unitprice and p2.categoryid = p1.categoryid
    ) as denserankprice_custom
from products p1
order by p1.categoryid, denserankprice_custom;
```

W celu porównania wyników uruchamiamy zapytanie łączące wszystkie te zapytania:

```sql
with custom_rn as (select p1.productid,
                          count(p2.productid) + 1 as rowno_custom
                   from products p1
                            left join products p2
                                      on p2.categoryid = p1.categoryid and
                                         (p2.unitprice > p1.unitprice or
                                          (p2.unitprice = p1.unitprice and p2.productid < p1.productid))
                   group by p1.productid),
     custom_rk as (select p1.productid,
                          count(p2.productid) + 1 as rankprice_custom
                   from products p1
                            left join products p2
                                      on p2.categoryid = p1.categoryid and
                                         p2.unitprice > p1.unitprice
                   group by p1.productid),
     custom_dk as (select p1.productid,
                          count(distinct p2.unitprice) + 1 as denserankprice_custom
                   from products p1
                            left join products p2
                                      on p2.categoryid = p1.categoryid and
                                         p2.unitprice > p1.unitprice
                   group by p1.productid)
select p.productid,
       p.productname,
       p.unitprice,
       p.categoryid,
       custom_rn.rowno_custom,
       row_number() over (partition by categoryid order by p.unitprice desc, p.productid) as rowno,
       custom_rk.rankprice_custom,
       rank() over (partition by categoryid order by p.unitprice desc)                    as rankprice,
       custom_dk.denserankprice_custom,
       dense_rank() over (partition by categoryid order by p.unitprice desc)              as denserankprice
from products p
         join custom_rn on custom_rn.productid = p.productid
         join custom_rk on custom_rk.productid = p.productid
         join custom_dk on custom_dk.productid = p.productid
order by p.categoryid, custom_rn.rowno_custom;
```

![alt text](image-2.png)

W celu upewnienia się, że wszystkie wartości naszych odpowiedników są identyczne jak te z zapytań korzystających z funkcji okna, korzystamy z dwukierunkowego zapytania `except` (dzięki temu możemy sprawdzić czy w wyniku dostajemy identyczne wiersze, czy istnieją jakieś różnice):

```sql
with q1 as (with custom_rn as (select p1.productid,
                                      count(p2.productid) + 1 as rowno
                               from products p1
                                        left join products p2
                                                  on p2.categoryid = p1.categoryid and
                                                     (p2.unitprice > p1.unitprice or
                                                      (p2.unitprice = p1.unitprice and p2.productid < p1.productid))
                               group by p1.productid),
                 custom_rk as (select p1.productid,
                                      count(p2.productid) + 1 as rankprice
                               from products p1
                                        left join products p2
                                                  on p2.categoryid = p1.categoryid and
                                                     p2.unitprice > p1.unitprice
                               group by p1.productid),
                 custom_dk as (select p1.productid,
                                      count(distinct p2.unitprice) + 1 as denserankprice
                               from products p1
                                        left join products p2
                                                  on p2.categoryid = p1.categoryid and
                                                     p2.unitprice > p1.unitprice
                               group by p1.productid)
            select p.productid,
                   p.productname,
                   p.unitprice,
                   p.categoryid,
                   custom_rn.rowno,
                   custom_rk.rankprice,
                   custom_dk.denserankprice
            from products p
                     join custom_rn on custom_rn.productid = p.productid
                     join custom_rk on custom_rk.productid = p.productid
                     join custom_dk on custom_dk.productid = p.productid
            order by p.categoryid, custom_rn.rowno),
     q2 as (select p.productid,
                   p.productname,
                   p.unitprice,
                   p.categoryid,
                   row_number() over (partition by categoryid order by p.unitprice desc, p.productid) as rowno,
                   rank() over (partition by categoryid order by p.unitprice desc)                    as rankprice,
                   dense_rank() over (partition by categoryid order by p.unitprice desc)              as denserankprice
            from products p
            order by p.categoryid)
(select * from q1 except select * from q2)
union all
(select * from q2 except select * from q1);
```

Wynik:
![alt text](image-26.png)

Jak widać na załączonym zrzucie ekranu, wszystkie funkcje oraz nasze customowe odpowiedniki dają identyczne rezultaty (zapytanie zwraca 0 wierszy, co oznacza, wynikowy zbiór jest identyczny dla obu zapytań).

Ze względu na różnicę w wydajności podzapytania względem `inner-joina`, w dalszej części konspektu będziemy korzystać z metody wykorzystującej `inner-joina` (porównanie wykonane dla silnika Postgres oraz funkcji `row_number`, wydajność pozostałych funkcji ma podobną charakterystykę):

- funkcja okna:
  ![alt text](image-3.png)

- `inner-join`:
  ![alt text](image-4.png)

- podzapytanie:
  ![alt text](image-5.png)

# Zadanie 2

Baza: Northwind, tabela product_history

Dla każdego produktu, podaj 4 najwyższe ceny tego produktu w danym roku. Zbiór wynikowy powinien zawierać:

- rok
- id produktu
- nazwę produktu
- cenę
- datę (datę uzyskania przez produkt takiej ceny)
- pozycję w rankingu

- Uporządkuj wynik wg roku, nr produktu, pozycji w rankingu

W przypadku długiego czasu wykonania ogranicz zbiór wynikowy.

Spróbuj uzyskać ten sam wynik bez użycia funkcji okna, porównaj wyniki, czasy i plany zapytań (koszty).

Przetestuj działanie w różnych SZBD (MS SQL Server, PostgreSql, SQLite)

---

> Wyniki:

W przypadku zapytania wykorzystującego funkcję okna, korzystamy z funkcji `dense_rank`, a następnie wybieramy unikalne unikalne wartości `(rok, productid, cena)` z `denserankprice < 4` - w rezultacie uzyskamy 4 najwyższe ceny, bez względu na występujące remisy. Ze względu na długi czas wykonania `explain analyse` (w przypadku zapytania z `inner-join`, zapytanie z funkcją okna działa bardzo szybko), zbiór wynikowy został ograniczony jedynie do produktów o `productid < 10`.

```sql
-- zapytanie wykorzystujące dense_rank()

with t as (select distinct on (extract(year from date), productid, unitprice) extract(year from date) as year,
                                                                              productid,
                                                                              productname,
                                                                              unitprice,
                                                                              date,
                                                                              dense_rank() over (
                                                                                  partition by extract(year from date), productid
                                                                                  order by unitprice desc
                                                                                  )                   as denserankprice
           from product_history p)
select *
from t
where t.denserankprice <= 4 and t.productid < 10
order by year, productid, unitprice desc;

-- zapytanie bez funkcji okna (inner-join)

with t as (select distinct on (extract(year from date), productid, unitprice) extract(year from date) as year,
                                                                              productid,
                                                                              productname,
                                                                              unitprice,
                                                                              date
           from product_history),
     dr as (select p1.year,
                   p1.productid,
                   p1.productname,
                   p1.unitprice,
                   p1.date,
                   count(distinct p2.unitprice) + 1 as denserankprice
            from t p1
                     left join t p2 on p2.year = p1.year and p2.productid = p1.productid and p2.unitprice > p1.unitprice
            group by p1.year, p1.productid, p1.productname, p1.unitprice, p1.date)
select *
from dr
where denserankprice <= 4 and productid < 10
order by year, productid, unitprice desc;
```

Rezultaty:

- z funkcją okna:
  ![alt text](image-10.png)

- z `inner-join`:
  ![alt text](image-11.png)

W celu zweryfikowania poprawności zapytania niekorzystającego z funkcji okna, tworzymy zapytanie korzystające z dwukierunkowego `except`. Ze względu na fakt, że ceny o danej randze mogły zostać zaobserwowane w różnych dniach, a zadanie nie specyfikowała, która data powinna być zawarta w zbiorze wynikowym, data nie jest brana pod uwagę przy porównywaniu dwóch zbiorów wynikowych:

```sql
with q1 as (with t
                     as (select distinct on (extract(year from date), productid, unitprice) extract(year from date) as year,
                                                                                            productid,
                                                                                            productname,
                                                                                            unitprice,
                                                                                            date,
                                                                                            dense_rank() over (
                                                                                                partition by extract(year from date), productid
                                                                                                order by unitprice desc
                                                                                                )                   as denserankprice
                         from product_history p)
            select *
            from t
            where t.denserankprice <= 4
              and t.productid < 10
            order by year, productid, unitprice desc),
     q2 as (with t
                     as (select distinct on (extract(year from date), productid, unitprice) extract(year from date) as year,
                                                                                            productid,
                                                                                            productname,
                                                                                            unitprice,
                                                                                            date
                         from product_history),
                 dr as (select p1.year,
                               p1.productid,
                               p1.productname,
                               p1.unitprice,
                               p1.date,
                               count(distinct p2.unitprice) + 1 as denserankprice
                        from t p1
                                 left join t p2 on p2.year = p1.year and p2.productid = p1.productid and
                                                   p2.unitprice > p1.unitprice
                        group by p1.year, p1.productid, p1.productname, p1.unitprice, p1.date)
            select *
            from dr
            where denserankprice <= 4
              and productid < 10
            order by year, productid, unitprice desc)
    (select year, productid, productname, unitprice, denserankprice
     from q1
     except
     select year, productid, productname, unitprice, denserankprice
     from q2)
union all
(select year, productid, productname, unitprice, denserankprice
 from q2
 except
 select year, productid, productname, unitprice, denserankprice
 from q1);
```

Wyniki:
![alt text](image-27.png)

W przypadku uwzględnienia daty w zapytaniu porównującym te dwa podejścia, obserwujemy pewne różnice (natomiast dla każdego produktu, ceny o danej randze są identyczne, wiersze różnią się wyłącznie datą wystąpienia):

![alt text](image-28.png)

Zapytania dla MSSQL oraz SQLite są generalnie identyczne, z dokładnością do wyciągania roku z daty:

```sql
-- postgres
extract(year from date) as year

-- mssql
year(date) as year

-- sqlite
strftime('%Y', date) as year
```

Porównanie planów zapytań (Postgres):

- zapytanie z `dense_rank`
  ![alt text](image-7.png)

- zapytanie z `inner-join`
  ![alt text](image-6.png)

Wnioski:

- zapytanie wykorzystujące funkcję okna (`dense_rank`), charakteryzuje się ponad 4-krotnie niższym kosztem (`total cost`)
- faktyczny czas wykonania zapytania jest ~50 razy krótszy (`actual total time`)
- wiersze w zapytaniu z `inner-join` musiały się zmaterializować, w rezultacie tworzonych jest 85 milionów wierszy pośrednich
- oczekiwana liczba wierszy (`rows`) jest mocno niedoszacowana względem faktycznej liczby wierszy (`actual rows`), co może skutkować złym wyborem planu wykonania zapytania.

Alternatywne zapytanie korzystające z subquery nie wykonało się w rozsądnym czasie, nawet na ograniczonym zbiorze danych.

Porównanie planów zapytań - MSSQL:

- zapytanie z `dense_rank`
  ![alt text](image-9.png)

- zapytanie z `inner-join`
  ![alt text](image-8.png)

Wnioski:

- dla ograniczonego zapytania, całkowity koszt zapytania z funkcją okna jest około 2,5 raza niższy względem zapytania z `joinem`, a faktyczny czas zapytania jest ~90 razy niższy.
- zapytanie jest zdecydowanie szybsze w porównaniu do Postgresa (~7 razy dla funkcji okna oraz ~4 razy dla zapytania z `joinem`)
- zapytanie na nieograniczonym zbiorze wykonało się w rozsądnym czasie zarówno dla zapytania z funkcją okna oraz `joinem` (~200 razy niższy całkowity koszt zapytania, zapytanie z funkcją okna wykonywało się około 400ms, zapytaniem z `joinem` około 1,5 minuty)

Porównanie wydajności i planów zapytań - SQLite:

- z funkcją `dense_rank`:
  ![alt text](image-13.png)

- z `inner-join`:
  ![alt text](image-12.png)

Wnioski:

- zapytanie korzystające z funkcji okna dla ograniczonego zbioru danych wykonuje się poniżej 1 sekundy, w przypadku zapytania z `joinem` czas wykonania zapytania wynosi około 1 minuty (nie są to jednak dokładne wyniki ze względu na paginację, a SQLite nie posiada opcji `explain analyse` z dokładną informacją odnośnie faktycznego czasu wykonania zapytania)
- w planie zapytania z `inner-joinem` widzimy, że dane muszą się faktycznie zmaterializować

---

# Zadanie 3

Funkcje `lag()`, `lead()`

Wykonaj polecenia, zaobserwuj wynik. Jak działają funkcje `lag()`, `lead()`

```sql
select productid, productname, categoryid, date, unitprice,
       lag(unitprice) over (partition by productid order by date)
as previousprodprice,
       lead(unitprice) over (partition by productid order by date)
as nextprodprice
from product_history
where productid = 1 and year(date) = 2022
order by date;

with t as (select productid, productname, categoryid, date, unitprice,
                  lag(unitprice) over (partition by productid
order by date) as previousprodprice,
                  lead(unitprice) over (partition by productid
order by date) as nextprodprice
           from product_history
           )
select * from t
where productid = 1 and year(date) = 2022
order by date;
```

Jak działają funkcje `lag()`, `lead()`?

Spróbuj uzyskać ten sam wynik bez użycia funkcji okna

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

---

> Wyniki:

```sql
--  ...
```

---

# Zadanie 4

Baza: Northwind, tabele customers, orders, order details

Napisz polecenie które wyświetla inf. o zamówieniach

Zbiór wynikowy powinien zawierać:

- nazwę klienta, nr zamówienia,
- datę zamówienia,
- wartość zamówienia (wraz z opłatą za przesyłkę),
- nr poprzedniego zamówienia danego klienta,
- datę poprzedniego zamówienia danego klienta,
- wartość poprzedniego zamówienia danego klienta.

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

---

> Wyniki:

```sql
--  ...
```

---

# Zadanie 5

Funkcje `first_value()`, `last_value()`

Baza: Northwind, tabele customers, orders, order details

Wykonaj polecenia, zaobserwuj wynik. Jak działają funkcje `first_value()`, `last_value()`.

Skomentuj uzyskane wyniki. Czy funkcja `first_value` pokazuje w tym przypadku najdroższy produkt w danej kategorii, czy funkcja `last_value()` pokazuje najtańszy produkt?

Co jest przyczyną takiego działania funkcji `last_value`.

Co trzeba zmienić żeby funkcja last_value pokazywała najtańszy produkt w danej kategorii?

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

```sql
select productid, productname, unitprice, categoryid,
    first_value(productname) over (partition by categoryid
order by unitprice desc) first,
    last_value(productname) over (partition by categoryid
order by unitprice desc) last
from products
order by categoryid, unitprice desc;
```

---

> Wyniki:

![alt text](image-14.png)

Funkcja `first_value()` zwraca pierwszą wartość w danym oknie zgodnie z zadaną kolejnością, funkcja `last_value()` zwraca ostatnią wartość w danym oknie zgodnie z zadaną kolejnością, przy czym zakres funkcji `last_value` jest od początku do **aktualnego wiersza** (`rows between unbounded preceding and current row`). W naszym przypadku, funkcja `first_value()` faktycznie będzie pokazywała najdroższy produkt w danej kategorii, natomiast funkcja `last_value()` będzie zawsze pokazywała produkt z danego wiersza (bo on jest najtańszy licząc od początku do aktualnego wiersza). W celu wykorzystania funkcji `last_value` do wskazywania najtańszego produktu w danej kategorii, musimy zmienić zakres tej funkcji:

```sql
-- wczesniej, zakres do aktualnego wiersza
last_value(productname) over (partition by categoryid
  order by unitprice desc) last

-- poprawiona wersja, zakres całego okna
last_value(productname) over (partition by categoryid
  order by unitprice desc rows between unbounded preceding and unbounded following) last
```

Rezultaty poprawionego zapytania:
![alt text](image-15.png)

---

# Zadanie 6

Baza: Northwind, tabele orders, order details

Napisz polecenie które wyświetla inf. o zamówieniach

Zbiór wynikowy powinien zawierać:

- Id klienta,
- nr zamówienia,
- datę zamówienia,
- wartość zamówienia (wraz z opłatą za przesyłkę),
- dane zamówienia klienta o najniższej wartości w danym miesiącu
  - nr zamówienia o najniższej wartości w danym miesiącu
  - datę tego zamówienia
  - wartość tego zamówienia
- dane zamówienia klienta o najwyższej wartości w danym miesiącu
  - nr zamówienia o najniższej wartości w danym miesiącu
  - datę tego zamówienia
  - wartość tego zamówienia

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

---

> Wyniki:

```sql
--  ...
```

---

# Zadanie 7

Baza: Northwind, tabela product_history

Napisz polecenie które pokaże wartość sprzedaży każdego produktu narastająco od początku każdego miesiąca. Użyj funkcji okna

Zbiór wynikowy powinien zawierać:

- id pozycji
- id produktu
- datę
- wartość sprzedaży produktu w danym dniu
- wartość sprzedaży produktu narastające od początku miesiąca

Spróbuj uzyskać ten sam wynik bez użycia funkcji okna, porównaj wyniki, czasy i plany zapytań (koszty).

Przetestuj działanie w różnych SZBD (MS SQL Server, PostgreSql, SQLite)

---

> Wyniki:

Zapytanie realizujące opisane zadanie w Postgresie:

```sql
-- z funkcją okna
with t as (select od.orderid                                     as id,
                  od.productid,
                  date_part('month', o.orderdate)                as month,
                  o.orderdate                                    as date,
                  od.unitprice * od.quantity * (1 - od.discount) as total,
                  sum(od.unitprice * od.quantity * (1 - od.discount)) over (
                      partition by od.productid,
                          date_part('year', o.orderdate),
                          date_part('month', o.orderdate)
                      order by od.productid, o.orderdate
                      )                                          as cum_total
           from orderdetails od
                    join orders o on od.orderid = o.orderid)
select t.id,
       t.productid,
       t.month,
       t.date,
       t.total,
       t.cum_total
from t;

-- bez funkcji okna (inner-join)
with t as (select od.orderid                                     as id,
                  od.productid,
                  date_part('month', o.orderdate)                as month,
                  o.orderdate                                    as date,
                  od.unitprice * od.quantity * (1 - od.discount) as total
           from orderdetails od
                    join orders o on od.orderid = o.orderid)
select t.id,
       t.productid,
       t.month,
       t.date,
       t.total,
       sum(t2.total) as cum_total
from t
         left join t t2
                   on t2.productid = t.productid
                       and date_part('year', t2.date) = date_part('year', t.date)
                       and date_part('month', t2.date) = date_part('month', t.date)
                       and (
                          t2.date < t.date
                              or (t2.date = t.date and t2.id <= t.id)
                          )
group by t.id,
         t.productid,
         t.month,
         t.date,
         t.total
order by t.productid,
         t.date;
```

Rezultaty zapytania:

- z funkcją okna:
  ![alt text](image-19.png)

- z `inner-joinem`:
  ![alt text](image-18.png)

Jak widać na załączonych zrzutach ekranu, wartości te są kumulowane w ramach danego miesiąca. W celu upewnienia się, że wyniki są identyczne w przypadku obu zapytań, ponownie korzystamy z dwukierunkowego `except`:

```sql
with q1 as (with t as (select od.orderid                                     as id,
                              od.productid,
                              date_part('month', o.orderdate)                as month,
                              o.orderdate                                    as date,
                              od.unitprice * od.quantity * (1 - od.discount) as total,
                              sum(od.unitprice * od.quantity * (1 - od.discount)) over (
                                  partition by od.productid,
                                      date_part('year', o.orderdate),
                                      date_part('month', o.orderdate)
                                  order by od.productid, o.orderdate
                                  )                                          as cum_total
                       from orderdetails od
                                join orders o on od.orderid = o.orderid)
            select t.id,
                   t.productid,
                   t.month,
                   t.date,
                   t.total,
                   t.cum_total
            from t),
     q2 as (with t as (select od.orderid                                     as id,
                              od.productid,
                              date_part('month', o.orderdate)                as month,
                              o.orderdate                                    as date,
                              od.unitprice * od.quantity * (1 - od.discount) as total,
                              sum(od.unitprice * od.quantity * (1 - od.discount)) over (
                                  partition by od.productid,
                                      date_part('year', o.orderdate),
                                      date_part('month', o.orderdate)
                                  order by od.productid, o.orderdate
                                  )                                          as cum_total
                       from orderdetails od
                                join orders o on od.orderid = o.orderid)
            select t.id,
                   t.productid,
                   t.month,
                   t.date,
                   t.total,
                   t.cum_total
            from t)
        (select * from q1 except select * from q2)
union all
(select * from q2 except select * from q1);
```

W wyniku otrzymujmy pusty zbiór, co oznacza, że zbiory wynikowe są identyczne w przypadku obu zapytań:

![alt text](image-29.png)

Porównanie wydajności i planów zapytań - Postgres:

- zapytanie z funkcją okna:
  ![alt text](image-20.png)

- zapytanie z `inner-joinem`:
  ![alt text](image-21.png)

Wnioski:

- zapytanie z funkcją okna charakteryzuje się około 2 razy niższym kosztem zapytania
- ze względu na mały rozmiar danych (tabele `orders` i `ordershistory`), zapytania są generalnie bardzo szybkie (~30ms), więc nie ma sensu porównywać bezpośrednio czasu zapytań

Zapytania dla MSSQL oraz SQLite są identyczne, z dokładnością do funkcji ekstrahującej miesiąc oraz rok z daty:

```sql
-- postgres
date_part('year', o.orderdate) as year
date_part('month', o.orderdate) as month

-- mssql
year(o.orderdate) as year
month(o.orderdate) as month

-- sqlite
strftime('%Y', o.orderdate) as year
strftime('%m', o.orderdate) as month
```

Porównanie wydajności i planów zapytań - MSSQL:

- z funkcją okna:
  ![alt text](image-22.png)

- z `inner-join`:
  ![alt text](image-23.png)

Wnioski:

- koszt całkowity dla funkcji okna jest ~3 krotnie niższy, natomiast czas wykonania jest bardzo zbliżony (ze względu na małą ilość danych)

Porównanie wydajności i planów zapytań - SQLite:

- z funkcją okna:
  ![alt text](image-25.png)

- z `inner-join`:
  ![alt text](image-24.png)

Wnioski:

- czas wykonania zapytań jest bardzo zbliżony (~400ms) zarówno dla funkcji okna i `inner-joina`, jest to około 20-krotnie dłużej niż to samo zapytanie w Postgres i MSSQL
- ze względu na format daty w tabelach `orders` i `orderhistory` konieczne było niewygodne castowanie daty do odpowiedniego formatu (`cast(substr(o.orderdate, 1, instr(o.orderdate, '/') - 1) as int) as month`)

---

# Zadanie 8

Wykonaj kilka "własnych" przykładowych analiz.

Czy są jeszcze jakieś ciekawe/przydatne funkcje okna (z których nie korzystałeś w ćwiczeniu)? Spróbuj ich użyć w zaprezentowanych przykładach.

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite)

---

> Wyniki:

```sql
--  ...
```

---

Punktacja

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 1   |
| 2       | 2   |
| 3       | 1   |
| 4       | 1   |
| 5       | 1   |
| 6       | 1   |
| 7       | 2   |
| 8       | 2   |
| razem   | 11  |
