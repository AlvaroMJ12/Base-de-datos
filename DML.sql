-- Queremos actualizar los nombres de los países a mayúsculas, para aquellos países que han ganado medallas en más de 5 deportes diferentes --
SELECT  p.id_pais
FROM atletas a
JOIN paises p on a.id_pais = p.id_pais
JOIN resultados r on a.id_atleta = r.id_atleta
JOIN deportes d on r.id_deporte = d.id_deporte
WHERE r.medalla IS NOT NULL
GROUP BY p.id_pais
HAVING COUNT(DISTINCT(d.id_deporte)) > 5

UPDATE paises SET nombre = UPPER(nombre) WHERE id_pais IN (

    SELECT  p.id_pais
    FROM atletas a
    JOIN paises p on a.id_pais = p.id_pais
    JOIN resultados r on a.id_atleta = r.id_atleta
    JOIN deportes d on r.id_deporte = d.id_deporte
    WHERE r.medalla IS NOT NULL
    GROUP BY p.id_pais
    HAVING COUNT(DISTINCT(d.id_deporte)) > 5

)