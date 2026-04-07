
## SQL - Funkcje okna (Window functions) <br> Lab 2

---

**Imiona i nazwiska:**

---

Celem ćwiczenia jest zapoznanie się z działaniem funkcji okna (window functions) w SQL, analiza wydajności zapytań i porównanie z rozwiązaniami przy wykorzystaniu "tradycyjnych" konstrukcji SQL

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---
> Wyniki:

```sql
--  ...
```

---

### Ważne/wymagane są komentarze

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
- Skonfiguruj połączenie  z bazą Northwind na lokalnym serwerze MS SQL

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

Wykonaj polecenie, zaobserwuj wynik. Porównaj funkcje row_number(), rank(), dense_rank().  Skomentuj wyniki.

Spróbuj uzyskać ten sam wynik bez użycia funkcji okna

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite.

---
> Wyniki:

```sql
--  ...
```

---

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

```sql
--  ...
```

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

Do analizy użyj wybranego systemu/bazy danych (wybierz MS SQLserver, Postgres lub SQLite).

---
> Wyniki:

Początek wyniku:
![alt-text](media/ex3-1.png)

Koniec wyniku:
![alt-text](media/ex3-2.png)

Według sygnatury z [dokumentacji](https://www.postgresql.org/docs/current/functions-window.html) `PostgreSQL` funkcja `lag()` zwraca wartość z poprzedniego wiersza co do offsetu, a `lead()` zwraca wartość z następnego wiersza co do offsetu. W przpadku braku takiego wiersza zwracana jest wartość domyślna. W naszym przypadku (brak podania offsetu i wartości domyślnej) offset jest równy 1, a wartość domyślna jest równa NULL. Oznacza to, że funkcja `lag()` zwraca cenę produktu z poprzedniego dnia, a `lead()` zwraca cenę produktu z następnego dnia. W przypadku pierwszego wiersza (brak poprzedniego dnia) funkcja `lag()` zwraca NULL, a w przypadku ostatniego wiersza (brak następnego dnia) funkcja `lead()` zwraca NULL.

Podejście bez funkcji okna:
```sql
-- podzapytanie
select ph.productid,
       ph.productname,
       ph.categoryid,
       ph.date,
       ph.unitprice,
       (select ph2.unitprice
        from product_history ph2
        where ph2.productid = ph.productid
          and ph2.date < ph.date
          and extract(year from date) = 2022
        order by ph2.date desc
        limit 1) as previousprodprice,
       (select ph3.unitprice
        from product_history ph3
        where ph3.productid = ph.productid
          and ph3.date > ph.date
          and extract(year from date) = 2022
        order by ph3.date
        limit 1) as nextprodprice
from product_history ph
where ph.productid = 1
  and extract(year from ph.date) = 2022
order by ph.date;
```

```sql
-- joiny
select ph.productid,
       ph.productname,
       ph.categoryid,
       ph.date,
       ph.unitprice,
       ph_prev.unitprice as previousprodprice,
       ph_next.unitprice as nextprodprice
from product_history ph
         left join product_history ph_prev on ph.productid = ph_prev.productid
    and ph_prev.date = (select max(date)
                        from product_history
                        where productid = ph.productid
                          and date < ph.date
                          and extract(year from date) = 2022)
         left join product_history ph_next on ph.productid = ph_next.productid
    and ph_next.date = (select min(date)
                        from product_history
                        where productid = ph.productid
                          and date > ph.date
                          and extract(year from date) = 2022)
where ph.productid = 1
  and extract(year from ph.date) = 2022
order by ph.date;
```

Porównanie wyników klazulą `except` w obie strony dało pusty zbiór wynikowy, co oznacza, że wyniki są takie same dla wszystkich trzech podejść.

Porównanie planów wykonania dla różnych podejść:

- funkcje okna:
![alt-text](media/ex3-3.png)

- podzapytanie:
![alt-text](media/ex3-4.png)

- joiny:
![alt-text](media/ex3-5.png)

Wnioski:
- podejście z funkcjami okna jest znacznie szybsze niż podzapytanie i joiny, co widać po czasie wykonania i kosztach
- funkcja okna wykonuje jeden skan tabeli `product_history`, natomiast podzapytanie i joiny wykonują wiele skanów tej tabeli (po jednym dla każdego wiersza), co jest przyczyną dłuższego czasu wykonania

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

Do analizy użyj wybranego systemu/bazy danych - wybierz MS SQLserver, Postgres lub SQLite.

---
> Wyniki:

```sql
-- PostgreSQL
with ordersummary as (select c.companyname,
                             o.orderid,
                             o.orderdate,
                             sum(od.unitprice * od.quantity * (1 - od.discount)) + o.freight as ordertotal
                      from orders o
                               join customers c on o.customerid = c.customerid
                               join orderdetails od on o.orderid = od.orderid
                      group by c.companyname, o.orderid, o.orderdate, o.freight)
select companyname,
       orderid,
       orderdate,
       ordertotal,
       lag(orderid) over (partition by companyname order by orderdate, orderid)    as prevorderid,
       lag(orderdate) over (partition by companyname order by orderdate, orderid)  as prevorderdate,
       lag(ordertotal) over (partition by companyname order by orderdate, orderid) as prevordertotal
from ordersummary
order by companyname, orderdate;
```

![alt-text](media/ex4-1.png)

Dla każdego klienta widzimy jego zamówienia wraz z informacjami o poprzednim zamówieniu. W przypadku pierwszego zamówienia danego klienta, kolumny dotyczące poprzedniego zamówienia będą zawierały wartość `NULL`.

Podejścia bez funkcji okna:

```sql
-- podzapytanie
with ordersummary as (select c.companyname,
                             o.customerid,
                             o.orderid,
                             o.orderdate,
                             sum(od.unitprice * od.quantity * (1 - od.discount)) + o.freight as ordertotal
                      from orders o
                               join customers c on o.customerid = c.customerid
                               join orderdetails od on o.orderid = od.orderid
                      group by c.companyname, o.customerid, o.orderid, o.orderdate, o.freight)
select t1.companyname,
       t1.orderid,
       t1.orderdate,
       t1.ordertotal,
       (select t2.orderid
        from ordersummary t2
        where t2.customerid = t1.customerid
          and (t2.orderdate < t1.orderdate or (t2.orderdate = t1.orderdate and t2.orderid < t1.orderid))
        order by t2.orderdate desc, t2.orderid desc
        limit 1) as prevorderid,
       (select t2.orderdate
        from ordersummary t2
        where t2.customerid = t1.customerid
          and (t2.orderdate < t1.orderdate or (t2.orderdate = t1.orderdate and t2.orderid < t1.orderid))
        order by t2.orderdate desc, t2.orderid desc
        limit 1) as prevorderdate,
       (select t2.ordertotal
        from ordersummary t2
        where t2.customerid = t1.customerid
          and (t2.orderdate < t1.orderdate or (t2.orderdate = t1.orderdate and t2.orderid < t1.orderid))
        order by t2.orderdate desc, t2.orderid desc
        limit 1) as prevordertotal
from ordersummary t1
order by t1.companyname, t1.orderdate, t1.orderid;
```

```sql
-- joiny
with ordersummary as (select c.companyname,
                             o.customerid,
                             o.orderid,
                             o.orderdate,
                             sum(od.unitprice * od.quantity * (1 - od.discount)) + o.freight as ordertotal
                      from orders o
                               join customers c on o.customerid = c.customerid
                               join orderdetails od on o.orderid = od.orderid
                      group by c.companyname, o.customerid, o.orderid, o.orderdate, o.freight),
     ordermapping as (select t1.orderid,
                             (select t2.orderid
                              from ordersummary t2
                              where t2.customerid = t1.customerid
                                and (t2.orderdate < t1.orderdate or
                                     (t2.orderdate = t1.orderdate and t2.orderid < t1.orderid))
                              order by t2.orderdate desc, t2.orderid desc
                              limit 1) as previd
                      from ordersummary t1)
select curr.companyname,
       curr.orderid,
       curr.orderdate,
       curr.ordertotal,
       prev.orderid    as prevorderid,
       prev.orderdate  as prevorderdate,
       prev.ordertotal as prevordertotal
from ordersummary curr
         join ordermapping m on curr.orderid = m.orderid
         left join ordersummary prev on m.previd = prev.orderid
order by curr.companyname, curr.orderdate, curr.orderid;
```

Porównanie wyników klazulą `except` w obie strony dało pusty zbiór wynikowy, co oznacza, że wyniki są takie same dla wszystkich trzech podejść.

Porównanie planów wykonania dla różnych podejść:

- funkcje okna:
![alt-text](media/ex4-2.png)

- podzapytanie:
![alt-text](media/ex4-3.png)

- joiny:
![alt-text](media/ex4-4.png)

Wnioski:
- w przypadku funkcji okna konieczne było, aby grupować dane po orderdate i orderid, aby dobrze obsłużyć kolejność zamówień, co spowodowało, że próba otrzymania tego samego wyniku bez funkcji okna okazała się trudna do napisania
- kod z funkcjami okna jest znacznie bardziej czytelny, łatwiejszy oraz zwięzły do napisania niż kod z podzapytaniem i joinami, co jest dodatkową zaletą funkcji okna
- czasy wykonania są bardzo małe (<1s), ale warto zwrócic uwagę na koszty, które są znacznie większe dla podejścia z podzapytaniem i joinami niż dla podejścia z funkcjami okna

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

```sql
--  ...
```

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

```sql
--  ...
```

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
