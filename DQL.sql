-- Queremos listar el nombre completo de todos los atletas que han ganado alguna medalla, mostrando también el nombre de su país. -- 
SELECT a.nombre || ' ' || a.apellido as nombre_completo, r.medalla, p.nombre as nombre_pais
FROM atletas a
JOIN resultados r on a.id_atleta = r.id_atleta
JOIN paises p on a.id_pais = p.id_pais

/* AgregaciónFunciones como COUNT(), SUM(), AVG(), MAX(), MIN().
Se usan en el SELECT para calcular un valor único para un grupo de filas.
- GROUP BY Agrupa filas con valores idénticos en columnas específicas.
    Cuando usas una función de agregación, cualquier columna en el SELECT que no sea una función de agregación debe aparecer aquí.
- HAVING Filtra los resultados de la agregación.
    Se usa después del GROUP BY para aplicar condiciones sobre los totales (ej., "solo grupos con COUNT > 10").
- WHERE Filtra las filas antes de la agregación.
    Se usa antes del GROUP BY para descartar filas individuales (ej., "solo medallas = 'oro'"). */


-- Queremos listar el nombre de los países que han ganado más de 10 medallas de oro en total, mostrando el número de oros. --
SELECT p.nombre, COUNT(r.medalla) as oros
FROM atletas a
JOIN paises p on a.id_pais= p.id_pais
JOIN resultados r on a.id_atleta=r.id_atleta
WHERE r.medalla = 'oro'
GROUP BY p.nombre
HAVING COUNT(r.medalla) > 10

-- Queremos obtener un listado de los deportes en los que se han entregado medallas, pero solo aquellos deportes donde se hayan dado más de 2 medallas de plata en total. --
SELECT d.nomnbre, COUNT(r.medalla)
FROM atletas a
JOIN resultados r on a.id_atleta = r.id_atleta
JOIN deportes d on r.id_deporte = d.id_deporte
WHERE r.medalla = 'plata'
GROUP BY d.nombre
HAVING COUNT(r.medalla) > 2

-- Enunciado del Ejercicio 6: "Queremos un informe que muestre el número total de medallas ganadas por continente. Además, incluiremos un ranking." -
SELECT p.continente, COUNT(r.medalla) as medallas, RANK() OVER (ORDER BY COUNT(r.medalla) DESC) as ranking
FROM atletas a
JOIN paises p on a.id_pais = p.id_pais
JOIN resultados r on a.id_atleta = r.id_atleta
GROUP BY p.continente

-- Queremos un listado por país, pero en lugar de una sola columna con el total, queremos ver tres columnas separadas: una con la cantidad de Oros, otra con la de Platas y otra con la de Bronces. --
SELECT p.nombre, 
    SUM(CASE WHEN r.medalla = 'oro' THEN 1 ELSE 0 END) as oros,
    SUM(CASE WHEN r.medalla = 'plata' THEN 1 ELSE 0 END) as platas, 
    SUM(CASE WHEN r.medalla = 'bronce' THEN 1 ELSE 0 END) as bronces
FROM atletas a 
JOIN paises p on a.id_pais = p.id_pais
JOIN resultados r on a.id_atleta = r.id_atleta
GROUP BY p.nombre
ORDER BY oros DESC, platas DESC, bronces DESC
