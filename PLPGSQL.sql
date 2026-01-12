-- Estructura de plpgsql --

CREATE OR REPLACE FUNCTION estado_atleta(p_id_atleta INT) 
RETURNS TEXT AS $$
DECLARE
    v_conteo INTEGER; -- 1. Declaramos la variable para guardar el número
BEGIN
    -- 2. Proceso: Contamos las medallas del atleta específico
    SELECT COUNT(*) 
    INTO v_conteo       -- 👈 ¡Aquí está la clave! Guardamos el valor en v_conteo
    FROM resultados 
    WHERE id_atleta = p_id_atleta AND medalla IS NOT NULL;

    -- 3. Lógica de decisión:
    IF v_conteo > 3 THEN
        RETURN 'Elite';
    ELSIF v_conteo >= 1 THEN
        RETURN 'Promesa';
    ELSE
        RETURN 'Sin medallas';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Crear una función llamada contar_medallas_pais, que reciba el nombre de -- 
-- un país y devuelva el número total de medallas (oro, plata, bronce) que ha ganado. Si el --
-- país no existe o no tiene, devuelve 0. --

CREATE OR REPLACE FUNCTION contar_medallas_pais(p_nombre_pais VARCHAR) 
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN

    SELECT COUNT(r.medalla) AS total INTO total
    FROM atletas a
    JOIN paises p on a.id_pais = p.id_pais
    JOIN resultados r on a.id_atleta = r.id_atleta
    WHERE p.nombre = p_nombre_pais;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Para ejecutar la funcion SELECT--
SELECT contar_medallas_pais('España');


-- Crear un procedimiento llamado registrar_medalla que registre (inserte) --
-- una nueva medalla. Debe verificar que el atleta y el deporte existan, y que la medalla sea --
-- válida ('oro', 'plata', 'bronce'). Si no, debe lanzar un error ("excepción"). --
CREATE OR REPLACE PROCEDURE registrar_medalla(p_id_atleta INT, p_id_deporte INT , p_medalla VARCHAR, fecha_evento DATE)
AS $$
DECLARE
BEGIN
    IF NOT EXISTS(SELECT id_atleta FROM atletas WHERE id_atleta = p_id_atleta) THEN
        RAISE EXCEPTION 'Atleta xx no existe';
    
    ELSIF NOT EXISTS(SELECT id_deporte FROM deporteS WHERE id_deporte = p_id_deporte) THEN 
        RAISE EXCEPTION 'Deporte xx no existe';
    
    ELSIF p_medalla NOT IN ('oro', 'plata', 'bronce') THEN
        RAISE EXCEPTION 'Medalla xx no válida';
        
    ELSE
        INSERT INTO resultados(id_atleta, id_deporte, medalla, fecha_evento) VALUES(p_id_atleta, p_id_deporte, p_medalla, fecha_evento);

    END IF;
END;
$$ LANGUAGE plpgsql;    

-- Para ejecutar el procedimiento CALL --
BEGIN;  -- 1. Abrimos el modo "borrador"

   -- 2. Aquí va tu prueba (el registro exitoso)
   CALL registrar_medalla(1,1,'oro','2001/01/12');

   -- 3. Comprobamos que se ha guardado (debería salir la fila)
   SELECT * FROM resultados WHERE id_atleta = 1;

ROLLBACK;-- 4. ¡Deshacer! Todo vuelve a como estaba antes del BEGIN

-- Ejercicio 17 --
BEGIN;
    CREATE OR REPLACE PROCEDURE reasignar_pais(p_pais_origen INT, p_pais_destino INT)
    AS $$
    DECLARE
    BEGIN
        IF NOT EXISTS (SELECT id_pais FROM paises p WHERE id_pais = p_pais_origen)THEN
            RAISE EXCEPTION 'País origen xx no existe';
        ELSIF NOT EXISTS (SELECT id_pais FROM paises p WHERE id_pais = p_pais_destino) THEN
            RAISE EXCEPTION 'País destino xx no existe';
        ELSE
            INSERT INTO auditoria_pais (id_atleta, pais_origen, pais_destino)
            SELECT id_atleta, id_pais, p_pais_destino 
            FROM atletas a
            WHERE id_pais = p_pais_origen;
            UPDATE atletas SET id_pais = p_pais_destino WHERE id_pais = p_pais_origen;
            
        END IF;
    END;
    $$ LANGUAGE plpgsql;

    CALL reasignar_pais(1, 2);

    SELECT * FROM auditoria_pais;
ROLLBACK;

-- Con bucle for --
BEGIN;
    CREATE OR REPLACE PROCEDURE reasignar_pais(p_pais_origen INT, p_pais_destino INT)
    AS $$
    DECLARE
    p_id_atleta INT;
    BEGIN
        IF NOT EXISTS (SELECT id_pais FROM paises p WHERE id_pais = p_pais_origen)THEN
            RAISE EXCEPTION 'País origen xx no existe';
        ELSIF NOT EXISTS (SELECT id_pais FROM paises p WHERE id_pais = p_pais_destino) THEN
            RAISE EXCEPTION 'País destino xx no existe';
        ELSE

            FOR p_id_atleta IN 
                SELECT id_atleta FROM atletas WHERE id_pais=p_pais_origen
            LOOP
                INSERT INTO auditoria_pais(id_atleta, pais_origen, pais_destino)
                VALUES (p_id_atleta, p_pais_origen, p_pais_destino);
            END LOOP;
            UPDATE atletas SET id_pais = p_pais_destino WHERE id_pais = p_pais_origen;
            
        END IF;
    END;
    $$ LANGUAGE plpgsql;

    CALL reasignar_pais(1, 2);

    SELECT * FROM auditoria_pais;
ROLLBACK;


-- 18 --
CREATE OR REPLACE FUNCTION actualizar_estadisticas() 
RETURNS TRIGGER 
AS $$
DECLARE 
    v_id_pais INTEGER;
BEGIN
    IF NEW.medalla NOT IN ('oro', 'plata', 'bronce') THEN
        RAISE EXCEPTION 'Medalla incorrecta';
    END IF;
    
    SELECT id_pais INTO v_id_pais
    FROM atletas a
    WHERE id_atleta = NEW.id_atleta;

    IF NEW.medalla = 'oro' THEN
        INSERT INTO estadisticas_pais (id_pais, oros, platas, bronces)
        VALUES (v_id_pais, 1, 0, 0)
        ON CONFLICT (id_pais) DO UPDATE 
        SET oros = estadisticas_pais.oros + 1;-- 2. Si ya existe: ¡Suma 1 al oro actual!

    ELSIF NEW.medalla = 'plata' THEN
        INSERT INTO estadisticas_pais (id_pais, oros, platas, bronces)
        VALUES (v_id_pais, 0, 1, 0)
        ON CONFLICT (id_pais) DO UPDATE 
        SET platas = estadisticas_pais.platas + 1;-- 2. Si ya existe: ¡Suma 1 al oro actual!

    ELSE 
        INSERT INTO estadisticas_pais (id_pais, oros, platas, bronces)
        VALUES (v_id_pais, 0, 0, 1)
        ON CONFLICT (id_pais) DO UPDATE 
        SET bronces = estadisticas_pais.bronces + 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_estadisticas
AFTER INSERT OR UPDATE ON resultados FOR EACH ROW
EXECUTE FUNCTION actualizar_estadisticas();


-- 19 --
CREATE RULE medallas_repetidas AS
ON INSERT TO resultados
WHERE EXISTS(
    SELECT id_resultado
    FROM resultados
    WHERE NEW.id_deporte = id_deporte AND NEW.medalla = medalla AND NEW.fecha_evento = fecha_evento
)
DO INSTEAD(
    INSERT INTO medallas_rechazadas(id_deporte, id_atleta, medalla, fecha_evento, motivo, fecha_rechazo)
    VALUES (NEW.id_deporte, NEW.id_atleta, NEW.medalla, NEW.fecha_evento, 'Medalla duplicada', NEW.fecha_evento)
);


-- Para que practiques la declaración y el uso de SELECT ... INTO, vamos con este enunciado con el estilo que verás en tu examen de DAW:

-- Enunciado: Crea una función llamada obtener_estatus_atleta que reciba como parámetro el identificador de un atleta (id_atleta). La función debe realizar lo siguiente:--

-- Obtener el nombre del atleta y guardarlo.--

-- Contar cuántas medallas tiene registradas ese atleta en la tabla resultados y guardar ese número.--

-- Lógica: Si el atleta tiene 3 o más medallas, la función debe devolver el texto: "Nombre: [nombre] - Estatus: Élite". En caso contrario, debe devolver: "Nombre: [nombre] - Estatus: Promesa".

-- Requisito: Debes utilizar la sentencia SELECT ... INTO para asignar los valores a las variables declaradas. --

CREATE OR REPLACE FUNCTION obtener_estatus_atleta(p_id_atleta INT)
RETURNS TEXT AS $$
DECLARE
    v_nombre_atleta TEXT;
    v_total_medallas INT DEFAULT = 0; -- Para que no sea NULL por defecto y no de fallos --
BEGIN
    SELECT a.nombre, COUNT(r.medalla) as medallas
    INTO v_nombre_atleta, v_total_medallas
    FROM atletas a 
    LEFT JOIN resultados r ON r.id_atleta = a.id_atleta
    WHERE a.id_atleta = p_id_atleta
    GROUP BY a.nombre;

    IF v_total_medallas >= 3 THEN
        RETURN 'Nombre: ' || v_nombre_atleta || ' Estatus: Élite';
    ELSE 
        RETURN 'Nombre: ' || v_nombre_atleta || ' Estatus: Promesa';
    END IF;
END;
$$ LANGUAGE plpgsql;




-- 20 --
CREATE OR REPLACE FUNCTION listar_medallas_pais(p_nombre_pais TEXT)
RETURNS TABLE(nombre_completo TEXT, total_medallas INT) AS $$
DECLARE
cursor_paises CURSOR FOR 
    SELECT a.nombre || ' ' || a.apellido as nombre_completo, 
        COUNT(r.medalla) as total_medallas
    FROM atletas a
    JOIN paises p ON p.id_pais = a.id_pais
    JOIN resultados r ON a.id_atleta = r.id_atleta
    WHERE p.nombre = p_nombre_pais
    GROUP BY p.nombre, a.nombre, a.apellido;
BEGIN
    OPEN cursor_paises;
        LOOP
            FETCH cursor_paises INTO nombre_completo, total_medallas;
            EXIT WHEN NOT FOUND;
            RETURN NEXT;
        END LOOP;
    CLOSE cursor_paises;
    RETURN;
END;
$$ LANGUAGE plpgsql;
