erDiagram
    CATEGORIA ||--o{ EQUIPO : "agrupa"
    EQUIPO ||--o{ JUGADOR : "tiene"
    JUGADOR }o--o{ TUTOR : "parentesco"
    TUTOR ||--o{ CUOTA : "paga"
    JUGADOR ||--o{ CUOTA : "genera"
    EQUIPO }o--o{ CAMPO : "entrena_en"
    DIRECTIVO }o--o{ PROVEEDOR : "firma_con"

    CATEGORIA {
        int id_categoria PK
        string nombre
        string rango_edad
    }
    EQUIPO {
        int id_equipo PK
        string nombre
        string horario
    }
    JUGADOR {
        int id_jugador PK
        string nombre
        string posicion
        date fecha_nacimiento
    }
    CAMPO {
        int id_campo PK
        string nombre
        string ubicacion
    }
    TUTOR {
        int id_tutor PK
        string nombre
        string telefono
    }
    CUOTA {
        int id_pago PK
        float cantidad
        string estado
    }
    DIRECTIVO {
        int id_directivo PK
        string cargo
    }
    PROVEEDOR {
        int id_proveedor PK
        string nombre
        string material
    }