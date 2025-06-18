--SET 1
/* Q1: Who is the senior most employee based on job title? */

select * from employee
order by levels desc 
limit 1;

/* Q2: Which countries have the most Invoices? */

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc;

/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city as best_cust_city_name, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc
limit 1;

/* Q5: Who is the best customer?
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total_spending
from customer
JOIN invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total_spending desc
limit 1;



--SET 2
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct customer.email, customer.first_name, customer.last_name 
from customer
join invoice on customer.customer_id=invoice.invoice_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
	select track_id 
	from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock')
order by customer.email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

select name,track.milliseconds
from track
where track.milliseconds>(
select avg(track.milliseconds) as avg_track_length
from track
)
order by track.milliseconds desc;



--SET 3
/* Q1a: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

select c.first_name || ' ' || c.last_name as customer_name,
    ar.name as artist_name, sum(il.unit_price * il.quantity) as total_spent
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join album as al on t.album_id = al.album_id
join artist as ar on al.artist_id = ar.artist_id
group by c.customer_id, customer_name, ar.name
order by customer_name, total_spent desc;

/* Q1b: Find how much amount spent by each customer on best selling artist?
Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* Q2: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre.
For countries where the maximum number of purchases is shared return all Genres. */

with popular_genre as 
(
    select count(il.quantity) as purchases, c.country, g.name, g.genre_id, 
	row_number() over(partition by c.country order by count(il.quantity) desc) as rowno 
    from invoice_line as il
	join invoice as i on i.invoice_id = il.invoice_id
	join customer as c on c.customer_id = i.customer_id
	join track as t on t.track_id = il.track_id
	join genre as g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where rowno <= 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as (
		select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as rowno 
		from invoice as i
		join customer as c on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from customer_with_country where rowno <= 1;