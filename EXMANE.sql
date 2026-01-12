-- DML -- 

update paises set nombre = upper(nombre) where id_pais in(
select 
		a.id_pais
	from atletas a
	join resultados r on r.id_atleta = a.id_atleta
	where r.medalla is not null
	group by a.id_pais
	having count(distinct (r.id_deporte)) > 5
);


with pais_honorifico as (
	insert into paises(id_pais, nombre, codigo_pais, continente)
	values ('999', 'Olimpicos', '999', 'Olimpia')
	returning id_pais
)
update atletas 
set id_pais = (select id_pais from pais_honorifico)
where id_atleta in (
	select id_atleta
	from atletas a
	join resultados r on r.id_atleta = a.id_atleta
	where r.medalla is not null
	group by a.id_atleta
	having count(r.medalla) >= 2
);

UPDATE resultados r
SET medalla = 'oro'
FROM atletas a -- Aquí "unimos" la tabla de atletas
WHERE r.id_atleta = a.id_atleta -- Condición de unión
  AND r.medalla = 'plata' -- Solo las de plata
  and extract(year from age(r.fecha_evento, a.fecha_nacimiento)) < 30;


update atletas
set apellido = apellido || ' - Doble'
where id_atleta in (
select a.id_atleta
from atletas a
join resultados r on r.id_atleta = a.id_atleta
where r.medalla is not null
group by a.id_atleta
having count(r.medalla) > 1
);

with conteo_oros as(
	select a.id_pais, count(r.medalla)
	from atletas a 
	join resultados r on r.id_atleta = a.id_atleta
	join paises p on p.id_pais = a.id_pais 
	where r.medalla = 'oro'
	group by p.id_pais
)
update paises p
set nombre = nombre || repeat('*', co.conteo_oros)
from conteo_oros co
where p.id_pais = co.id_pais


-- PLPGSQL -- 


CREATE OR REPLACE FUNCTION contar_medallas (p_nombre_pais)
RETURNS 
    v_total_medallas INT;
AS $$
DECLARE
BEGIN

END;
$$ LANGUAGE PLPGSQL;