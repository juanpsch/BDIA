-- Selecciona todos los registros de la tabla Albums.
select * from album;
-- Selecciona todos los géneros únicos de la tabla Genres.
select distinct * from genre;
-- Cuenta el número de pistas por género.
select g.name, count(t.track_id) from genre g
left join track t on g.genre_id = t.genre_id group by g.name;
-- Encuentra la longitud total (en milisegundos) de todas las pistas para cada álbum.
select a.title, sum(t.milliseconds) from album a
left join track t on a.album_id = t.album_id group by a.title;
-- Lista los 10 álbumes con más pistas.
select a.title, count(t.track_id) from album a
left join track t on a.album_id = t.album_id group by a.title
order by count(t.track_id) desc
limit 10;
-- Encuentra la longitud promedio de la pista para cada género.
select g.name, avg(t.milliseconds) from genre g
left join track t on g.genre_id = t.genre_id group by g.name;
-- Para cada cliente, encuentra la cantidad total que han gastado.
select CONCAT(cu.first_name,' ',cu.last_name) Cliente, sum(i.total) from customer cu
left join invoice i on cu.customer_id = i.customer_id
group by cu.customer_id;
-- Para cada país, encuentra la cantidad total gastada por los clientes.
select cu.country, sum(i.total) from customer cu
left join invoice i on cu.customer_id = i.customer_id
group by cu.country;
-- Clasifica a los clientes en cada país por la cantidad total que han gastado.
select cu.country, CASE WHEN sum(i.total)>100 THEN 'ALTO' ELSE 'BAJO' END, sum(i.total) from customer cu
left join invoice i on cu.customer_id = i.customer_id
group by cu.country;
-- Para cada artista, encuentra el álbum con más pistas y clasifica a los artistas por este número.
with q1 as (	
select art.name art_name, alb.title, 
count(trk.track_id) OVER(Partition by alb.album_id) ntracks
from artist art
left join album alb on art.artist_id = alb.artist_id
left join track trk on alb.album_id = trk.album_id
)
select q1.art_name, max(q1.ntracks) max_album_tracks from q1 group by q1.art_name ORDER BY max(q1.ntracks) desc;

-- Selecciona todas las pistas que tienen la palabra "love" en su título.
select name from track where name like '%Love%';
-- Selecciona a todos los clientes cuyo primer nombre comienza con 'A'.
select * from customer where first_name like 'A%';
-- Calcula el porcentaje del total de la factura que representa cada factura.
select invoice_id, total, 100*total/sum(total) over() prc_total from invoice;

-- Calcula el porcentaje de pistas que representa cada género.
select distinct(genre_id), round(100*(count(track_id) over(partition by genre_id) )/(count(track_id) over()),2) tkks_pct
from track
order by tkks_pct desc
;

-- Para cada cliente, compara su gasto total con el del cliente que gastó más.
select c.customer_id
	,sum(i.total) AS total_client
	,max(sum(i.total)) over() AS max_tc
from customer c 
left join invoice i on c.customer_id = i.customer_id
GROUP  BY c.customer_id
ORDER  BY sum(i.total) DESC;
;
-- Para cada factura, calcula la diferencia en el gasto total entre ella y la factura anterior.
select invoice_id, total, LAG (total,1) OVER ( ORDER BY invoice_id ) prev_inv_total
,total - LAG (total,1) OVER ( ORDER BY invoice_id ) total_dif
from invoice
;

-- Para cada factura, calcula la diferencia en el gasto total entre ella y la próxima factura.
select invoice_id, total, LEAD (total,1) OVER ( ORDER BY invoice_id ) prox_inv_total
,total - LEAD (total,1) OVER ( ORDER BY invoice_id ) total_dif
from invoice
;
-- Encuentra al artista con el mayor número de pistas para cada género.
with q1 as(
	select g.genre_id, art.artist_id
	,count(trk.track_id) trk_gen_art
	,max(count(trk.track_id)) over(partition by g.genre_id) max_trk_gen_art
	from artist art
	left join album alb on art.artist_id = alb.artist_id
	left join track trk on alb.album_id = trk.album_id
	left join genre g on trk.genre_id = g.genre_id
	group by g.genre_id, art.artist_id
	order by g.genre_id, trk_gen_art desc
)select g.name genero, a.name artista, q1.trk_gen_art from q1
left join artist a on a.artist_id = q1.artist_id
left join genre g on g.genre_id = q1.genre_id
where trk_gen_art = max_trk_gen_art
;

-- Compara el total de la última factura de cada cliente con el total de su factura anterior.
with q1 as(
select customer_id, max(invoice_id) ultimaFactura
from invoice
group by customer_id
) Select i.invoice_id, i.invoice_id-1 invoice_id_prev, i.total, iprev.total total_prev,
i.total - iprev.total diff
from q1
left join invoice i on q1.ultimaFactura = i.invoice_id
left join invoice iprev on q1.ultimaFactura -1 = iprev.invoice_id
;
-- Encuentra cuántas pistas de más de 3 minutos tiene cada álbum.
select alb.title, count(*) from track trk
left join album alb on trk.album_id = alb.album_id
where milliseconds > 180000
group by alb.title
;