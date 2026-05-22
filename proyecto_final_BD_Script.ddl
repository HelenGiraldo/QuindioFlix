-------------------------------------------------------------------
-- PROYECTO: QuindioFlix - Sistema de Gestión de Streaming
-- AUTORES: Helen Xiomara Giraldo Libreros y Valentina Porras Salazar
-- FECHA: Mayo 2026
-- DESCRIPCIÓN: Script de creación de objetos (DDL)
-------------------------------------------------------------------
-------------------------------------------------------
-- 0. ELIMINACIÓN DE OBJETOS EXISTENTES (LIMPIEZA TOTAL)
-------------------------------------------------------
-- NOTA: Se eliminan primero las tablas que dependen de otras (FK) 
-- para mantener la integridad referencial del sistema QuindioFlix.

-- 1. Tablas de Interacción y Transacciones (Hijas de Perfil/Usuario/Contenido)
DROP TABLE Reporte CASCADE CONSTRAINTS;
DROP TABLE Reproduccion CASCADE CONSTRAINTS;
DROP TABLE Favorito CASCADE CONSTRAINTS;
DROP TABLE Calificacion CASCADE CONSTRAINTS;
DROP TABLE Pago CASCADE CONSTRAINTS;

-- 2. Tablas de Acceso y Perfiles
DROP TABLE Perfil CASCADE CONSTRAINTS;
DROP TABLE suscripcion CASCADE CONSTRAINTS;

-- 3. Estructura de Contenido Específico (Series y Episodios)
DROP TABLE Episodio CASCADE CONSTRAINTS;
DROP TABLE Temporada CASCADE CONSTRAINTS;

-- 4. Especializaciones de Contenido (Subtipos)
DROP TABLE serie CASCADE CONSTRAINTS;
DROP TABLE Podcast CASCADE CONSTRAINTS;
DROP TABLE pelicula CASCADE CONSTRAINTS;
DROP TABLE Musica CASCADE CONSTRAINTS;
DROP TABLE documental CASCADE CONSTRAINTS;

-- 5. Tablas Maestras y de Infraestructura (Las que no dependen de nadie)
DROP TABLE contenido CASCADE CONSTRAINTS;
DROP TABLE Empleado CASCADE CONSTRAINTS;
DROP TABLE Departamento CASCADE CONSTRAINTS;
DROP TABLE Usuario CASCADE CONSTRAINTS;
DROP TABLE genero CASCADE CONSTRAINTS;
DROP TABLE tipo_genero CASCADE CONSTRAINTS;
DROP TABLE Plan_suscripcion CASCADE CONSTRAINTS;

COMMIT;

-------------------------------------------------------
-- fin de la limpieza
-------------------------------------------------------

-------------------------------------------------------
-- 1. CREACIÓN DE TABLAS
-------------------------------------------------------
-- 1.1 Tablas independientes (sin dependencias externas)
-- -------------------------------------------------------

CREATE TABLE Plan_suscripcion 
    ( 
     id_plan       INTEGER  NOT NULL , 
     nombre        VARCHAR2 (20 CHAR)  NOT NULL , 
     costo         NUMBER (10,2)  NOT NULL , 
     num_pantallas INTEGER  NOT NULL , 
     calidad       VARCHAR2 (2 CHAR)  NOT NULL 
    ) 
;

CREATE TABLE genero 
    ( 
     id_genero   INTEGER  NOT NULL , 
     nombre      VARCHAR2 (50 CHAR)  NOT NULL , 
     descripcion VARCHAR2 (255 CHAR) 
    ) 
;

CREATE TABLE Usuario 
    ( 
     id_usuario           INTEGER  NOT NULL , 
     nombre               VARCHAR2 (50 CHAR)  NOT NULL , 
     email                VARCHAR2 (100 CHAR)  NOT NULL , 
     telefono             VARCHAR2 (15 CHAR)  NOT NULL , 
     fecha_nacimiento     DATE  NOT NULL , 
     ciudad_residencia    VARCHAR2 (80 CHAR)  NOT NULL , 
     Usuario_id_referido  INTEGER  NOT NULL , 
     estado_cuenta_activa VARCHAR2 (12 CHAR)  NOT NULL 
    ) 
;

-- 1.2 Tablas que dependen de Empleado/Departamento (circular resuelto por orden)
-- -------------------------------------------------------

CREATE TABLE Departamento 
    ( 
     nombre               VARCHAR2 (50 CHAR)  NOT NULL , 
     id_departamento      INTEGER  NOT NULL , 
     Empleado_id_empleado INTEGER  NOT NULL 
    ) 
;

CREATE UNIQUE INDEX Departamento__IDX ON Departamento 
    ( 
     Empleado_id_empleado ASC 
    ) 
;

CREATE TABLE Empleado 
    ( 
     nombre                       VARCHAR2 (100 CHAR) , 
     email                        VARCHAR2 (100 CHAR) , 
     cargo                        VARCHAR2 (30 CHAR) , 
     id_empleado                  INTEGER  NOT NULL , 
     fecha_contratación           DATE , 
     Empleado_id_empleado         INTEGER  NOT NULL , 
     Departamento_id_departamento INTEGER  NOT NULL 
    ) 
;

-- 1.3 Tabla principal de contenido
-- -------------------------------------------------------

CREATE TABLE contenido 
    ( 
     titulo                   VARCHAR2 (200 CHAR)  NOT NULL , 
     anio_lanzamiento         NUMBER (4)  NOT NULL , 
     sinopsis                 VARCHAR2 (4000 CHAR)  NOT NULL , 
     clasificacion_edad       VARCHAR2 (4 CHAR)  NOT NULL , 
     fecha_agregado           DATE  NOT NULL , 
     id_contenido             INTEGER  NOT NULL , 
     duracion                 NUMBER (8)  NOT NULL , 
     es_original              NUMBER  NOT NULL , 
     contenido_id_relacionado INTEGER  NOT NULL , 
     Empleado_id_empleado     INTEGER  NOT NULL , 
     descripcion              VARCHAR2 (2000 CHAR) , 
     tipo_contenido           VARCHAR2 (12 CHAR)  NOT NULL 
    ) 
;

CREATE UNIQUE INDEX contenido__IDX ON contenido 
    ( 
     contenido_id_relacionado ASC 
    ) 
;

-- 1.4 Subtipos de contenido (heredan de contenido)
-- -------------------------------------------------------

CREATE TABLE documental 
    ( 
     director     VARCHAR2 (100 CHAR) , 
     id_contenido INTEGER  NOT NULL 
    ) 
;

CREATE TABLE Musica 
    ( 
     artista      VARCHAR2 (100 CHAR) , 
     album        VARCHAR2 (100 CHAR) , 
     id_contenido INTEGER  NOT NULL 
    ) 
;

CREATE TABLE pelicula 
    ( 
     director     VARCHAR2 (100 CHAR) , 
     id_contenido INTEGER  NOT NULL 
    ) 
;

CREATE TABLE Podcast 
    ( 
     anfitrion    VARCHAR2 (100 CHAR) , 
     tematica     VARCHAR2 (100 CHAR) , 
     id_contenido INTEGER  NOT NULL 
    ) 
;

CREATE TABLE serie 
    ( 
     creador      VARCHAR2 (100 CHAR) , 
     id_contenido INTEGER  NOT NULL 
    ) 
;

-- 1.5 Estructura de series y podcasts (temporadas y episodios)
-- -------------------------------------------------------

CREATE TABLE Temporada 
    ( 
     id_temporada         INTEGER  NOT NULL , 
     cantidad_temporadas  NUMBER (3)  NOT NULL , 
     serie_id_contenido   INTEGER , 
     titulo               VARCHAR2 (200 CHAR)  NOT NULL , 
     Podcast_id_contenido INTEGER 
    ) 
;

CREATE TABLE Episodio 
    ( 
     id_episodio            INTEGER  NOT NULL , 
     Temporada_id_temporada INTEGER  NOT NULL , 
     titulo                 VARCHAR2 (200 CHAR)  NOT NULL , 
     duracion               NUMBER (8)  NOT NULL , 
     numero_episodio        NUMBER (3) 
    ) 
;

-- 1.6 Tablas de usuarios y perfiles
-- -------------------------------------------------------

CREATE TABLE Perfil 
    ( 
     id_perfil          INTEGER  NOT NULL , 
     Usuario_id_usuario INTEGER  NOT NULL , 
     nombre             VARCHAR2 (50 CHAR)  NOT NULL , 
     avatar             VARCHAR2 (500 CHAR)  NOT NULL , 
     tipo               VARCHAR2 (255 CHAR)  NOT NULL 
    ) 
;

-- 1.7 Tablas de suscripciones y pagos
-- -------------------------------------------------------

CREATE TABLE suscripcion 
    ( 
     fecha_inicio             DATE  NOT NULL , 
     fecha_vencimiento        DATE , 
     estado                   VARCHAR2 (12 CHAR)  NOT NULL , 
     Usuario_id_usuario       INTEGER  NOT NULL , 
     Plan_suscripcion_id_plan INTEGER  NOT NULL , 
     id_suscripcion           INTEGER  NOT NULL 
    ) 
;

CREATE TABLE Pago 
    ( 
     fecha_pago                 DATE  NOT NULL , 
     monto                      NUMBER (10,2)  NOT NULL , 
     metodo_pago                VARCHAR2 (20 CHAR)  NOT NULL , 
     estado_pago                VARCHAR2 (12 CHAR)  NOT NULL , 
     valor_descuento            NUMBER (10,2) , 
     id_pago                    INTEGER  NOT NULL , 
     suscripcion_id_suscripcion INTEGER  NOT NULL 
    ) 
;

-- 1.8 Tablas de interacción usuario-contenido
-- -------------------------------------------------------

CREATE TABLE Calificacion 
    ( 
     reseña                 VARCHAR2 (2000 CHAR) , 
     id_calificacion        INTEGER  NOT NULL , 
     estrellas              NUMBER (1)  NOT NULL , 
     Perfil_id_perfil       INTEGER  NOT NULL , 
     contenido_id_contenido INTEGER  NOT NULL 
    ) 
;

CREATE TABLE Favorito 
    ( 
     Perfil_id_perfil       INTEGER  NOT NULL , 
     contenido_id_contenido INTEGER  NOT NULL , 
     id_favorito            INTEGER  NOT NULL , 
     fecha_agregado         DATE 
    ) 
;

CREATE TABLE Reproduccion 
    ( 
     fecha_inicio           TIMESTAMP (0)  NOT NULL , 
     fecha_fin              TIMESTAMP (0) , 
     dispositivo            VARCHAR2 (12 CHAR)  NOT NULL , 
     id_reproduccion        INTEGER  NOT NULL , 
     porcentaje_avance      NUMBER (5,2)  NOT NULL , 
     Perfil_id_perfil       INTEGER  NOT NULL , 
     contenido_id_contenido INTEGER  NOT NULL , 
     Episodio_id_episodio   INTEGER  NOT NULL 
    ) 
;

-- 1.9 Tablas de clasificación y soporte
-- -------------------------------------------------------

CREATE TABLE tipo_genero 
    ( 
     contenido_id_contenido INTEGER  NOT NULL , 
     genero_id_genero       INTEGER  NOT NULL 
    ) 
;

CREATE TABLE Reporte 
    ( 
     id_reporte             INTEGER  NOT NULL , 
     motivo                 VARCHAR2 (2000 CHAR)  NOT NULL , 
     fecha_reporte          DATE  NOT NULL , 
     estado                 VARCHAR2 (12 CHAR)  NOT NULL , 
     fecha_resolucion       DATE  NOT NULL , 
     contenido_id_contenido INTEGER  NOT NULL , 
     Empleado_id_empleado   INTEGER  NOT NULL , 
     Perfil_id_perfil       INTEGER  NOT NULL 
    ) 
;


-------------------------------------------------------
-- 2. PRIMARY KEYS
-------------------------------------------------------

ALTER TABLE Plan_suscripcion 
    ADD CONSTRAINT Plan_suscripcion_PK PRIMARY KEY ( id_plan ) ;

ALTER TABLE genero 
    ADD CONSTRAINT genero_PK PRIMARY KEY ( id_genero ) ;

ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_PK PRIMARY KEY ( id_usuario ) ;

ALTER TABLE Departamento 
    ADD CONSTRAINT Departamento_PK PRIMARY KEY ( id_departamento ) ;

ALTER TABLE Empleado 
    ADD CONSTRAINT Empleado_PK PRIMARY KEY ( id_empleado ) ;

ALTER TABLE contenido 
    ADD CONSTRAINT contenido_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE documental 
    ADD CONSTRAINT documental_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE Musica 
    ADD CONSTRAINT Musica_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE pelicula 
    ADD CONSTRAINT pelicula_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE Podcast 
    ADD CONSTRAINT Podcast_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE serie 
    ADD CONSTRAINT serie_PK PRIMARY KEY ( id_contenido ) ;

ALTER TABLE Temporada 
    ADD CONSTRAINT Temporada_PK PRIMARY KEY ( id_temporada ) ;

ALTER TABLE Episodio 
    ADD CONSTRAINT Episodio_PK PRIMARY KEY ( id_episodio ) ;

ALTER TABLE Perfil 
    ADD CONSTRAINT Perfil_PK PRIMARY KEY ( id_perfil ) ;

ALTER TABLE suscripcion 
    ADD CONSTRAINT suscripcion_PK PRIMARY KEY ( id_suscripcion ) ;

ALTER TABLE Pago 
    ADD CONSTRAINT Pago_PK PRIMARY KEY ( id_pago ) ;

ALTER TABLE Calificacion 
    ADD CONSTRAINT CALIFICACION_PK PRIMARY KEY ( id_calificacion ) ;

ALTER TABLE Favorito 
    ADD CONSTRAINT FAVORITO_PK PRIMARY KEY ( id_favorito ) ;

ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_PK PRIMARY KEY ( id_reproduccion ) ;

ALTER TABLE tipo_genero 
    ADD CONSTRAINT tipo_genero_PK PRIMARY KEY ( contenido_id_contenido, genero_id_genero ) ;

ALTER TABLE Reporte 
    ADD CONSTRAINT Reporte_PK PRIMARY KEY ( id_reporte ) ;


-------------------------------------------------------
-- 3. CHECK CONSTRAINTS
-------------------------------------------------------

-- Plan_suscripcion
ALTER TABLE Plan_suscripcion 
    ADD 
    CHECK (nombre IN ('Básico', 'Estandar', 'Premium')) 
;

ALTER TABLE Plan_suscripcion 
    ADD 
    CHECK (costo IN (14900, 24900, 34900)) 
;

ALTER TABLE Plan_suscripcion 
    ADD 
    CHECK (num_pantallas IN (1, 2, 4)) 
;

ALTER TABLE Plan_suscripcion 
    ADD 
    CHECK (calidad IN ('4K', 'HD', 'SD')) 
;

-- Usuario
ALTER TABLE Usuario 
    ADD 
    CHECK (estado_cuenta_activa IN ('Activa', 'Inactiva', 'Suspendida')) 
;

-- Departamento
ALTER TABLE Departamento 
    ADD 
    CHECK (nombre IN ('Contenido', 'Finanzas', 'Marketing', 'Soporte', 'Tecnología')) 
;

-- Empleado
ALTER TABLE Empleado 
    ADD 
    CHECK (cargo IN ('Empleado', 'Jefe', 'Supervisor')) 
;

-- contenido
ALTER TABLE contenido 
    ADD 
    CHECK (clasificacion_edad IN ('+13', '+16', '+18', '+7', 'TP')) 
;

ALTER TABLE contenido 
    ADD 
    CHECK (duracion >= 1) 
;

ALTER TABLE contenido 
    ADD 
    CHECK (es_original IN ('0', '1')) 
;

ALTER TABLE contenido 
    ADD 
    CHECK (tipo_contenido IN ('DOCUMENTAL', 'MUSICA', 'PELICULA', 'PODCAST', 'SERIE')) 
;

-- Temporada
ALTER TABLE Temporada 
    ADD 
    CHECK (cantidad_temporadas >= 1) 
;

-- Episodio
ALTER TABLE Episodio 
    ADD 
    CHECK (duracion >=1) 
;

ALTER TABLE Episodio 
    ADD 
    CHECK (numero_episodio >=1) 
;

-- suscripcion
ALTER TABLE suscripcion 
    ADD 
    CHECK (estado IN ('Activa', 'Inactiva', 'Suspendida')) 
;

-- Pago
ALTER TABLE Pago 
    ADD 
    CHECK (monto > 0) 
;

ALTER TABLE Pago 
    ADD 
    CHECK (metodo_pago IN ('Daviplata', 'Nequi', 'PSE', 'Tarjeta crédito', 'Tarjeta débito')) 
;

ALTER TABLE Pago 
    ADD 
    CHECK (estado_pago IN ('Exitoso', 'Fallido', 'Pendiente', 'Reembolsado')) 
;

ALTER TABLE Pago 
    ADD 
    CHECK (valor_descuento >= 0 AND valor_descuento <= monto) 
;

COMMENT ON COLUMN Pago.valor_descuento IS 'Regla de Negocio: El valor_descuento debe ser menor o igual al monto (valor_descuento <= monto)' 
;

-- Calificacion
ALTER TABLE Calificacion 
    ADD 
    CHECK (estrellas BETWEEN 1 AND 5) 
;

-- Reproduccion
ALTER TABLE Reproduccion 
    ADD 
    CHECK (dispositivo IN ('Celular', 'Computador', 'TV', 'Tablet')) 
;

ALTER TABLE Reproduccion 
    ADD 
    CHECK (porcentaje_avance BETWEEN 0 AND 100) 
;

-- Reporte
ALTER TABLE Reporte 
    ADD 
    CHECK (estado IN ('Desestimado', 'En revisión', 'Pendiente', 'Resuelto')) 
;


-------------------------------------------------------
-- 4. FOREIGN KEYS
-------------------------------------------------------

-- Usuario (autoreferencia)
ALTER TABLE Usuario 
    ADD CONSTRAINT Usuario_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_id_referido
    ) 
    REFERENCES Usuario 
    ( 
     id_usuario
    ) 
;

-- Departamento -> Empleado
ALTER TABLE Departamento 
    ADD CONSTRAINT Departamento_Empleado_FK FOREIGN KEY 
    ( 
     Empleado_id_empleado
    ) 
    REFERENCES Empleado 
    ( 
     id_empleado
    ) 
;

-- Empleado -> Departamento, Empleado (supervisor)
ALTER TABLE Empleado 
    ADD CONSTRAINT Empleado_Departamento_FK FOREIGN KEY 
    ( 
     Departamento_id_departamento
    ) 
    REFERENCES Departamento 
    ( 
     id_departamento
    ) 
;

ALTER TABLE Empleado 
    ADD CONSTRAINT Empleado_Empleado_FK FOREIGN KEY 
    ( 
     Empleado_id_empleado
    ) 
    REFERENCES Empleado 
    ( 
     id_empleado
    ) 
;

-- contenido -> contenido (relacionado), Empleado
ALTER TABLE contenido 
    ADD CONSTRAINT contenido_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_relacionado
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE contenido 
    ADD CONSTRAINT contenido_Empleado_FK FOREIGN KEY 
    ( 
     Empleado_id_empleado
    ) 
    REFERENCES Empleado 
    ( 
     id_empleado
    ) 
;

-- Subtipos de contenido -> contenido
ALTER TABLE documental 
    ADD CONSTRAINT documental_contenido_FK FOREIGN KEY 
    ( 
     id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE Musica 
    ADD CONSTRAINT Musica_contenido_FK FOREIGN KEY 
    ( 
     id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE pelicula 
    ADD CONSTRAINT pelicula_contenido_FK FOREIGN KEY 
    ( 
     id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE Podcast 
    ADD CONSTRAINT Podcast_contenido_FK FOREIGN KEY 
    ( 
     id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE serie 
    ADD CONSTRAINT serie_contenido_FK FOREIGN KEY 
    ( 
     id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

-- Temporada -> serie, Podcast
ALTER TABLE Temporada 
    ADD CONSTRAINT Temporada_serie_FK FOREIGN KEY 
    ( 
     serie_id_contenido
    ) 
    REFERENCES serie 
    ( 
     id_contenido
    ) 
;

ALTER TABLE Temporada 
    ADD CONSTRAINT Temporada_Podcast_FK FOREIGN KEY 
    ( 
     Podcast_id_contenido
    ) 
    REFERENCES Podcast 
    ( 
     id_contenido
    ) 
;

-- Episodio -> Temporada
ALTER TABLE Episodio 
    ADD CONSTRAINT Episodio_Temporada_FK FOREIGN KEY 
    ( 
     Temporada_id_temporada
    ) 
    REFERENCES Temporada 
    ( 
     id_temporada
    ) 
;

-- Perfil -> Usuario
ALTER TABLE Perfil 
    ADD CONSTRAINT Perfil_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_id_usuario
    ) 
    REFERENCES Usuario 
    ( 
     id_usuario
    ) 
;

-- suscripcion -> Usuario, Plan_suscripcion
ALTER TABLE suscripcion 
    ADD CONSTRAINT suscripcion_Usuario_FK FOREIGN KEY 
    ( 
     Usuario_id_usuario
    ) 
    REFERENCES Usuario 
    ( 
     id_usuario
    ) 
;

ALTER TABLE suscripcion 
    ADD CONSTRAINT suscripcion_Plan_FK FOREIGN KEY 
    ( 
     Plan_suscripcion_id_plan
    ) 
    REFERENCES Plan_suscripcion 
    ( 
     id_plan
    ) 
;

-- Pago -> suscripcion
ALTER TABLE Pago 
    ADD CONSTRAINT Pago_suscripcion_FK FOREIGN KEY 
    ( 
     suscripcion_id_suscripcion
    ) 
    REFERENCES suscripcion 
    ( 
     id_suscripcion
    ) 
;

-- Calificacion -> Perfil, contenido
ALTER TABLE Calificacion 
    ADD CONSTRAINT Calificación_Perfil_FK FOREIGN KEY 
    ( 
     Perfil_id_perfil
    ) 
    REFERENCES Perfil 
    ( 
     id_perfil
    ) 
;

ALTER TABLE Calificacion 
    ADD CONSTRAINT Calificación_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

-- Favorito -> Perfil, contenido
ALTER TABLE Favorito 
    ADD CONSTRAINT Favortio_Perfil_FK FOREIGN KEY 
    ( 
     Perfil_id_perfil
    ) 
    REFERENCES Perfil 
    ( 
     id_perfil
    ) 
;

ALTER TABLE Favorito 
    ADD CONSTRAINT Favortio_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

-- Reproduccion -> Perfil, contenido, Episodio
ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_Perfil_FK FOREIGN KEY 
    ( 
     Perfil_id_perfil
    ) 
    REFERENCES Perfil 
    ( 
     id_perfil
    ) 
;

ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE Reproduccion 
    ADD CONSTRAINT Reproduccion_Episodio_FK FOREIGN KEY 
    ( 
     Episodio_id_episodio
    ) 
    REFERENCES Episodio 
    ( 
     id_episodio
    ) 
;

-- tipo_genero -> contenido, genero
ALTER TABLE tipo_genero 
    ADD CONSTRAINT tipo_genero_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE tipo_genero 
    ADD CONSTRAINT tipo_genero_genero_FK FOREIGN KEY 
    ( 
     genero_id_genero
    ) 
    REFERENCES genero 
    ( 
     id_genero
    ) 
;

-- Reporte -> contenido, Empleado, Perfil
ALTER TABLE Reporte 
    ADD CONSTRAINT Reporte_contenido_FK FOREIGN KEY 
    ( 
     contenido_id_contenido
    ) 
    REFERENCES contenido 
    ( 
     id_contenido
    ) 
;

ALTER TABLE Reporte 
    ADD CONSTRAINT Reporte_Empleado_FK FOREIGN KEY 
    ( 
     Empleado_id_empleado
    ) 
    REFERENCES Empleado 
    ( 
     id_empleado
    ) 
;

ALTER TABLE Reporte 
    ADD CONSTRAINT Reporte_Perfil_FK FOREIGN KEY 
    ( 
     Perfil_id_perfil
    ) 
    REFERENCES Perfil 
    ( 
     id_perfil
    ) 
;


-------------------------------------------------------
-- 5. TRIGGERS
-------------------------------------------------------

-- 5.1 Triggers de arco (validación de subtipo por discriminador)
-- -------------------------------------------------------

CREATE OR REPLACE TRIGGER ARC_FKArc_1_Podcast 
BEFORE INSERT OR UPDATE OF id_contenido 
ON Podcast 
FOR EACH ROW 
DECLARE 
    d VARCHAR2 (12 CHAR); 
BEGIN 
    SELECT A.tipo_contenido INTO d 
    FROM contenido A 
    WHERE A.id_contenido = :new.id_contenido; 
    IF (d IS NULL OR d <> 'PODCAST') THEN 
        raise_application_error(-20223,'FK Podcast_contenido_FK in Table Podcast violates Arc constraint on Table contenido - discriminator column tipo_contenido doesn''t have value ''PODCAST'''); 
    END IF; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        NULL; 
    WHEN OTHERS THEN 
        RAISE; 
END; 
/

CREATE OR REPLACE TRIGGER ARC_FKArc_1_serie 
BEFORE INSERT OR UPDATE OF id_contenido 
ON serie 
FOR EACH ROW 
DECLARE 
    d VARCHAR2 (12 CHAR); 
BEGIN 
    SELECT A.tipo_contenido INTO d 
    FROM contenido A 
    WHERE A.id_contenido = :new.id_contenido; 
    IF (d IS NULL OR d <> 'SERIE') THEN 
        raise_application_error(-20223,'FK serie_contenido_FK in Table serie violates Arc constraint on Table contenido - discriminator column tipo_contenido doesn''t have value ''SERIE'''); 
    END IF; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        NULL; 
    WHEN OTHERS THEN 
        RAISE; 
END; 
/

CREATE OR REPLACE TRIGGER ARC_FKArc_1_documental 
BEFORE INSERT OR UPDATE OF id_contenido 
ON documental 
FOR EACH ROW 
DECLARE 
    d VARCHAR2 (12 CHAR); 
BEGIN 
    SELECT A.tipo_contenido INTO d 
    FROM contenido A 
    WHERE A.id_contenido = :new.id_contenido; 
    IF (d IS NULL OR d <> 'DOCUMENTAL') THEN 
        raise_application_error(-20223,'FK documental_contenido_FK in Table documental violates Arc constraint on Table contenido - discriminator column tipo_contenido doesn''t have value ''DOCUMENTAL'''); 
    END IF; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        NULL; 
    WHEN OTHERS THEN 
        RAISE; 
END; 
/

CREATE OR REPLACE TRIGGER ARC_FKArc_1_Musica 
BEFORE INSERT OR UPDATE OF id_contenido 
ON Musica 
FOR EACH ROW 
DECLARE 
    d VARCHAR2 (12 CHAR); 
BEGIN 
    SELECT A.tipo_contenido INTO d 
    FROM contenido A 
    WHERE A.id_contenido = :new.id_contenido; 
    IF (d IS NULL OR d <> 'MUSICA') THEN 
        raise_application_error(-20223,'FK Musica_contenido_FK in Table Musica violates Arc constraint on Table contenido - discriminator column tipo_contenido doesn''t have value ''MUSICA'''); 
    END IF; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        NULL; 
    WHEN OTHERS THEN 
        RAISE; 
END; 
/

CREATE OR REPLACE TRIGGER ARC_FKArc_1_pelicula 
BEFORE INSERT OR UPDATE OF id_contenido 
ON pelicula 
FOR EACH ROW 
DECLARE 
    d VARCHAR2 (12 CHAR); 
BEGIN 
    SELECT A.tipo_contenido INTO d 
    FROM contenido A 
    WHERE A.id_contenido = :new.id_contenido; 
    IF (d IS NULL OR d <> 'PELICULA') THEN 
        raise_application_error(-20223,'FK pelicula_contenido_FK in Table pelicula violates Arc constraint on Table contenido - discriminator column tipo_contenido doesn''t have value ''PELICULA'''); 
    END IF; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        NULL; 
    WHEN OTHERS THEN 
        RAISE; 
END; 
/

------------------------------------------------------------
-- 5.2 Trigger de exclusión mutua (Temporada pertenece a Serie o Podcast)
-- -------------------------------------------------------

CREATE OR REPLACE TRIGGER ARC_EXCLUSION_TEMPORADA
BEFORE INSERT OR UPDATE ON Temporada
FOR EACH ROW
BEGIN
    -- Validación: No pueden ser ambos nulos (debe pertenecer a algo)
    IF (:new.serie_id_contenido IS NULL AND :new.Podcast_id_contenido IS NULL) THEN
        raise_application_error(-20001, 'Error en QuindioFlix: La temporada debe estar asociada a una Serie o a un Podcast.');
    END IF;

    -- Validación: No pueden estar ambos llenos (exclusividad)
    IF (:new.serie_id_contenido IS NOT NULL AND :new.Podcast_id_contenido IS NOT NULL) THEN
        raise_application_error(-20002, 'Error en QuindioFlix: Una temporada no puede pertenecer a una Serie y a un Podcast al mismo tiempo.');
    END IF;
END;
/



-------------------------------------------------------
-- 6. FINALIZACIÓN
-------------------------------------------------------

COMMIT;


------------------------------------------------------------------
-- Datos de prueba ( Script de inserción de datos de prueba (DML)
-- NOTA: Los datos son ASIMÉTRICOS para que los reportes con
--       ROLLUP, CUBE y PIVOT muestren diferencias reales.
------------------------------------------------------------------

-------------------------------------------------------
-- 1. PLAN_SUSCRIPCION (3 registros mínimo)
-------------------------------------------------------

INSERT INTO Plan_suscripcion (id_plan, nombre, costo, num_pantallas, calidad)
VALUES (1, 'Básico', 14900, 1, 'SD');

INSERT INTO Plan_suscripcion (id_plan, nombre, costo, num_pantallas, calidad)
VALUES (2, 'Estandar', 24900, 2, 'HD');

INSERT INTO Plan_suscripcion (id_plan, nombre, costo, num_pantallas, calidad)
VALUES (3, 'Premium', 34900, 4, '4K');

select * from Plan_suscripcion;

-------------------------------------------------------
-- 2. GENERO (8 registros mínimo)
-------------------------------------------------------

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (1, 'Acción', 'Contenido con escenas de acción, aventura y adrenalina');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (2, 'Comedia', 'Contenido humorístico pensado para entretener y hacer reír');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (3, 'Drama', 'Narrativas con profundidad emocional y conflictos humanos');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (4, 'Suspenso', 'Contenido que genera tensión e incertidumbre en el espectador');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (5, 'Romance', 'Historias centradas en relaciones amorosas y sentimentales');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (6, 'Ciencia Ficción', 'Contenido basado en ciencia, tecnología y mundos futuristas');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (7, 'Terror', 'Contenido diseñado para causar miedo y tensión psicológica');

INSERT INTO genero (id_genero, nombre, descripcion)
VALUES (8, 'Infantil', 'Contenido apto y pensado para el público infantil');

select * from genero;


-------------------------------------------------------
-- 3. DEPARTAMENTO y EMPLEADO
--    (Dependencia circular: se crean sin FK primero,
--     luego se actualizan referencias)
-------------------------------------------------------

-- A. Desactivamos la restricción de llave foránea para poder insertar
ALTER TABLE Departamento DISABLE CONSTRAINT DEPARTAMENTO_EMPLEADO_FK;

-- 3.1 Insertar departamentos con Empleado_id_empleado temporal (se actualiza después)
INSERT INTO Departamento (id_departamento, nombre, Empleado_id_empleado) VALUES (1, 'Contenido', 1);
INSERT INTO Departamento (id_departamento, nombre, Empleado_id_empleado) VALUES (2, 'Tecnología', 6);
INSERT INTO Departamento (id_departamento, nombre, Empleado_id_empleado) VALUES (3, 'Marketing', 11);
INSERT INTO Departamento (id_departamento, nombre, Empleado_id_empleado) VALUES (4, 'Finanzas', 16);
INSERT INTO Departamento (id_departamento, nombre, Empleado_id_empleado) VALUES (5, 'Soporte', 21);

-- 3.2 Insertar empleados
-- Dpto Contenido
INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (1, 'Laura Ospina', 'laura.ospina@quindioflix.com', 'Jefe', DATE '2020-01-15', 1, 1);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (2, 'Carlos Mejía', 'carlos.mejia@quindioflix.com', 'Supervisor', DATE '2021-03-10', 1, 1);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (3, 'Juliana Ríos', 'juliana.rios@quindioflix.com', 'Empleado', DATE '2022-06-01', 2, 1);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (4, 'Sebastián Torres', 'sebastian.torres@quindioflix.com', 'Empleado', DATE '2022-08-15', 2, 1);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (5, 'Daniela Cruz', 'daniela.cruz@quindioflix.com', 'Empleado', DATE '2023-01-20', 2, 1);

-- Dpto Tecnología
INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (6, 'Andrés Vargas', 'andres.vargas@quindioflix.com', 'Jefe', DATE '2019-09-01', 6, 2);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (7, 'Manuela Gil', 'manuela.gil@quindioflix.com', 'Supervisor', DATE '2021-04-12', 6, 2);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (8, 'Felipe Salcedo', 'felipe.salcedo@quindioflix.com', 'Empleado', DATE '2022-02-28', 7, 2);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (9, 'Valentina Pardo', 'valentina.pardo@quindioflix.com', 'Empleado', DATE '2023-05-10', 7, 2);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (10, 'Santiago Herrera', 'santiago.herrera@quindioflix.com', 'Empleado', DATE '2023-07-01', 7, 2);

-- Dpto Marketing
INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (11, 'Natalia Cárdenas', 'natalia.cardenas@quindioflix.com', 'Jefe', DATE '2020-03-15', 11, 3);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (12, 'Diego Morales', 'diego.morales@quindioflix.com', 'Supervisor', DATE '2021-06-01', 11, 3);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (13, 'Camila Suárez', 'camila.suarez@quindioflix.com', 'Empleado', DATE '2022-09-15', 12, 3);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (14, 'Jhon Castillo', 'jhon.castillo@quindioflix.com', 'Empleado', DATE '2023-02-10', 12, 3);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (15, 'Paola Jiménez', 'paola.jimenez@quindioflix.com', 'Empleado', DATE '2023-08-20', 12, 3);

-- Dpto Finanzas
INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (16, 'Hernán Gómez', 'hernan.gomez@quindioflix.com', 'Jefe', DATE '2019-11-01', 16, 4);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (17, 'Sandra López', 'sandra.lopez@quindioflix.com', 'Supervisor', DATE '2021-01-15', 16, 4);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (18, 'Ricardo Peña', 'ricardo.pena@quindioflix.com', 'Empleado', DATE '2022-04-01', 17, 4);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (19, 'Alejandra Soto', 'alejandra.soto@quindioflix.com', 'Empleado', DATE '2022-10-20', 17, 4);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (20, 'Mauricio Arias', 'mauricio.arias@quindioflix.com', 'Empleado', DATE '2023-03-05', 17, 4);

-- Dpto Soporte
INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (21, 'Gloria Montoya', 'gloria.montoya@quindioflix.com', 'Jefe', DATE '2020-06-01', 21, 5);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (22, 'Ivan Restrepo', 'ivan.restrepo@quindioflix.com', 'Supervisor', DATE '2021-08-10', 21, 5);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (23, 'Lorena Quintero', 'lorena.quintero@quindioflix.com', 'Empleado', DATE '2022-11-01', 22, 5);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (24, 'Esteban Bedoya', 'esteban.bedoya@quindioflix.com', 'Empleado', DATE '2023-01-15', 22, 5);

INSERT INTO Empleado (id_empleado, nombre, email, cargo, fecha_contratación, Empleado_id_empleado, Departamento_id_departamento)
VALUES (25, 'Marcela Zapata', 'marcela.zapata@quindioflix.com', 'Empleado', DATE '2023-09-01', 22, 5);

ALTER TABLE Departamento ENABLE CONSTRAINT DEPARTAMENTO_EMPLEADO_FK;

COMMIT;

-------------------------------------------------------
-- 4. USUARIO (30 registros)
--    Asimétrico: más usuarios en Bogotá, más en Premium,
--    Quibdó tiene pocos usuarios con plan Básico
-------------------------------------------------------

-- Bogotá - Plan Premium (8 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (1, 'Andrés Martínez', 'andres.m@email.com', '3101234567', DATE '1990-05-14', 'Bogotá', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (2, 'Catalina Ruiz', 'catalina.r@email.com', '3112345678', DATE '1992-08-22', 'Bogotá', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (3, 'Juan Pablo Díaz', 'juanpablo.d@email.com', '3123456789', DATE '1985-11-03', 'Bogotá', 2, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (4, 'María Fernanda Leal', 'mariaf.l@email.com', '3134567890', DATE '1995-02-17', 'Bogotá', 2, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (5, 'Rodrigo Espinosa', 'rodrigo.e@email.com', '3145678901', DATE '1988-07-30', 'Bogotá', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (6, 'Isabel Ramírez', 'isabel.r@email.com', '3156789012', DATE '1993-04-09', 'Bogotá', 3, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (7, 'Nicolás Acosta', 'nicolas.a@email.com', '3167890123', DATE '1997-12-25', 'Bogotá', 3, 'Inactiva');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (8, 'Valeria Mendoza', 'valeria.m@email.com', '3178901234', DATE '2000-06-18', 'Bogotá', 4, 'Activa');

-- Bogotá - Plan Estándar (4 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (9, 'Gustavo Pedraza', 'gustavo.p@email.com', '3189012345', DATE '1983-09-05', 'Bogotá', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (10, 'Liliana Torres', 'liliana.t@email.com', '3190123456', DATE '1991-01-28', 'Bogotá', 5, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (11, 'Camilo Ávila', 'camilo.a@email.com', '3201234567', DATE '1996-10-14', 'Bogotá', 5, 'Suspendida');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (12, 'Patricia Guerrero', 'patricia.g@email.com', '3212345678', DATE '1979-03-22', 'Bogotá', 6, 'Activa');

-- Medellín - Plan Premium (4 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (13, 'Jorge Agudelo', 'jorge.ag@email.com', '3223456789', DATE '1987-06-11', 'Medellín', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (14, 'Alejandra Vélez', 'alejandra.v@email.com', '3234567890', DATE '1994-09-27', 'Medellín', 13, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (15, 'David Cano', 'david.c@email.com', '3245678901', DATE '1990-12-08', 'Medellín', 13, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (16, 'Melissa Arango', 'melissa.a@email.com', '3256789012', DATE '1998-04-15', 'Medellín', 14, 'Inactiva');

-- Medellín - Plan Estándar (4 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (17, 'Felipe Correa', 'felipe.c@email.com', '3267890123', DATE '1986-07-19', 'Medellín', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (18, 'Natalia Bedoya', 'natalia.b@email.com', '3278901234', DATE '1993-02-04', 'Medellín', 17, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (19, 'Esteban Jaramillo', 'esteban.j@email.com', '3289012345', DATE '2001-11-30', 'Medellín', 17, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (20, 'Claudia Reyes', 'claudia.r@email.com', '3290123456', DATE '1975-08-23', 'Medellín', 18, 'Activa');

-- Medellín - Plan Básico (2 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (21, 'Oscar Muñoz', 'oscar.m@email.com', '3301234567', DATE '1999-05-07', 'Medellín', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (22, 'Lina Zapata', 'lina.z@email.com', '3312345678', DATE '2002-01-16', 'Medellín', 21, 'Activa');

-- Cali - Plan Estándar (4 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (23, 'Hernando Caicedo', 'hernando.c@email.com', '3323456789', DATE '1984-10-02', 'Cali', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (24, 'Adriana Palacios', 'adriana.p@email.com', '3334567890', DATE '1992-03-19', 'Cali', 23, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (25, 'Gabriel Mosquera', 'gabriel.m@email.com', '3345678901', DATE '1989-06-25', 'Cali', 23, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (26, 'Paola Mina', 'paola.m@email.com', '3356789012', DATE '1997-09-12', 'Cali', 24, 'Suspendida');

-- Cali - Plan Básico (2 usuarios)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (27, 'Luis Fernando Angulo', 'luisf.a@email.com', '3367890123', DATE '2000-12-31', 'Cali', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (28, 'Sandra Hurtado', 'sandra.h@email.com', '3378901234', DATE '1981-04-08', 'Cali', 27, 'Activa');

-- Armenia - Plan Básico (2 usuarios, ciudad local del proyecto)
INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (29, 'Helen Giraldo', 'helen.g@email.com', '3389012345', DATE '2003-07-14', 'Armenia', 1, 'Activa');

INSERT INTO Usuario (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, Usuario_id_referido, estado_cuenta_activa)
VALUES (30, 'Valentina Salazar', 'valentina.s@email.com', '3390123456', DATE '2003-11-22', 'Armenia', 29, 'Activa');


-------------------------------------------------------
-- 5. SUSCRIPCION (una por usuario, plan asimétrico)
-------------------------------------------------------

-- Bogotá Premium (usuarios 1-8)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (1, DATE '2024-01-10', DATE '2025-01-10', 'Activa', 1, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (2, DATE '2024-02-15', DATE '2025-02-15', 'Activa', 2, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (3, DATE '2023-11-01', DATE '2024-11-01', 'Activa', 3, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (4, DATE '2024-03-20', DATE '2025-03-20', 'Activa', 4, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (5, DATE '2024-04-05', DATE '2025-04-05', 'Activa', 5, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (6, DATE '2024-05-01', DATE '2025-05-01', 'Activa', 6, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (7, DATE '2023-08-15', DATE '2024-08-15', 'Inactiva', 7, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (8, DATE '2024-06-10', DATE '2025-06-10', 'Activa', 8, 3);

-- Bogotá Estándar (usuarios 9-12)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (9, DATE '2024-01-20', DATE '2025-01-20', 'Activa', 9, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (10, DATE '2024-02-28', DATE '2025-02-28', 'Activa', 10, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (11, DATE '2023-09-01', DATE '2024-09-01', 'Suspendida', 11, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (12, DATE '2024-07-01', DATE '2025-07-01', 'Activa', 12, 2);

-- Medellín Premium (usuarios 13-16)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (13, DATE '2024-01-05', DATE '2025-01-05', 'Activa', 13, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (14, DATE '2024-03-15', DATE '2025-03-15', 'Activa', 14, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (15, DATE '2024-05-20', DATE '2025-05-20', 'Activa', 15, 3);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (16, DATE '2023-10-10', DATE '2024-10-10', 'Inactiva', 16, 3);

-- Medellín Estándar (usuarios 17-20)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (17, DATE '2024-02-01', DATE '2025-02-01', 'Activa', 17, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (18, DATE '2024-04-10', DATE '2025-04-10', 'Activa', 18, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (19, DATE '2024-06-25', DATE '2025-06-25', 'Activa', 19, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (20, DATE '2024-08-01', DATE '2025-08-01', 'Activa', 20, 2);

-- Medellín Básico (usuarios 21-22)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (21, DATE '2024-09-01', DATE '2025-09-01', 'Activa', 21, 1);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (22, DATE '2024-10-15', DATE '2025-10-15', 'Activa', 22, 1);

-- Cali Estándar (usuarios 23-26)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (23, DATE '2024-01-15', DATE '2025-01-15', 'Activa', 23, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (24, DATE '2024-03-01', DATE '2025-03-01', 'Activa', 24, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (25, DATE '2024-05-10', DATE '2025-05-10', 'Activa', 25, 2);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (26, DATE '2023-12-01', DATE '2024-12-01', 'Suspendida', 26, 2);

-- Cali Básico (usuarios 27-28)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (27, DATE '2024-07-20', DATE '2025-07-20', 'Activa', 27, 1);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (28, DATE '2024-08-15', DATE '2025-08-15', 'Activa', 28, 1);

-- Armenia Básico (usuarios 29-30)
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (29, DATE '2024-09-10', DATE '2025-09-10', 'Activa', 29, 1);
INSERT INTO suscripcion (id_suscripcion, fecha_inicio, fecha_vencimiento, estado, Usuario_id_usuario, Plan_suscripcion_id_plan)
VALUES (30, DATE '2024-10-01', DATE '2025-10-01', 'Activa', 30, 1);


-------------------------------------------------------
-- 6. PERFIL (50 registros)
--    Usuarios Premium tienen hasta 4 perfiles,
--    Estándar hasta 2, Básico solo 1
-------------------------------------------------------

-- Perfiles usuario 1 (Premium - 4 perfiles)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (1, 1, 'Andrés', 'avatar_01.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (2, 1, 'Laura', 'avatar_02.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (3, 1, 'Juanito', 'avatar_kids_01.png', 'Infantil');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (4, 1, 'Abuela Rosa', 'avatar_03.png', 'Adulto');

-- Perfiles usuario 2 (Premium - 3 perfiles)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (5, 2, 'Catalina', 'avatar_04.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (6, 2, 'Miguel', 'avatar_05.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (7, 2, 'Sofi', 'avatar_kids_02.png', 'Infantil');

-- Perfiles usuario 3 (Premium - 2 perfiles)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (8, 3, 'Juan Pablo', 'avatar_06.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (9, 3, 'Trabajo', 'avatar_07.png', 'Adulto');

-- Perfiles usuario 4 (Premium - 4 perfiles)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (10, 4, 'María', 'avatar_08.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (11, 4, 'Esposo', 'avatar_09.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (12, 4, 'Niño1', 'avatar_kids_03.png', 'Infantil');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (13, 4, 'Niño2', 'avatar_kids_04.png', 'Infantil');

-- Perfiles usuarios 5-8 (Premium - 1-2 perfiles c/u)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (14, 5, 'Rodrigo', 'avatar_10.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (15, 5, 'Pareja', 'avatar_11.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (16, 6, 'Isabel', 'avatar_12.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (17, 7, 'Nicolás', 'avatar_13.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (18, 8, 'Valeria', 'avatar_14.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (19, 8, 'Familia', 'avatar_15.png', 'Adulto');

-- Perfiles usuarios 9-12 (Estándar - 1-2 perfiles c/u)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (20, 9, 'Gustavo', 'avatar_16.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (21, 9, 'Invitado', 'avatar_17.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (22, 10, 'Liliana', 'avatar_18.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (23, 11, 'Camilo', 'avatar_19.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (24, 12, 'Patricia', 'avatar_20.png', 'Adulto');

-- Perfiles usuarios 13-16 (Medellín Premium)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (25, 13, 'Jorge', 'avatar_21.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (26, 13, 'Hijos', 'avatar_kids_05.png', 'Infantil');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (27, 14, 'Alejandra', 'avatar_22.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (28, 14, 'Novio', 'avatar_23.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (29, 15, 'David', 'avatar_24.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (30, 16, 'Melissa', 'avatar_25.png', 'Adulto');

-- Perfiles usuarios 17-22 (Medellín Estándar/Básico)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (31, 17, 'Felipe', 'avatar_26.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (32, 17, 'Esposa', 'avatar_27.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (33, 18, 'Natalia', 'avatar_28.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (34, 19, 'Esteban', 'avatar_29.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (35, 20, 'Claudia', 'avatar_30.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (36, 21, 'Oscar', 'avatar_31.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (37, 22, 'Lina', 'avatar_32.png', 'Adulto');

-- Perfiles usuarios 23-28 (Cali Estándar/Básico)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (38, 23, 'Hernando', 'avatar_33.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (39, 23, 'Familia Caicedo', 'avatar_34.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (40, 24, 'Adriana', 'avatar_35.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (41, 25, 'Gabriel', 'avatar_36.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (42, 26, 'Paola', 'avatar_37.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (43, 27, 'Luis', 'avatar_38.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (44, 28, 'Sandra', 'avatar_39.png', 'Adulto');

-- Perfiles usuarios 29-30 (Armenia Básico)
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (45, 29, 'Helen', 'avatar_40.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (46, 30, 'Valentina', 'avatar_41.png', 'Adulto');

-- Perfiles adicionales para completar 50
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (47, 3, 'Niño', 'avatar_kids_06.png', 'Infantil');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (48, 15, 'Trabajo', 'avatar_42.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (49, 20, 'Hija', 'avatar_43.png', 'Adulto');
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo) VALUES (50, 25, 'Invitado', 'avatar_44.png', 'Adulto');


-------------------------------------------------------
-- 7. CONTENIDO (40 registros)
--    Distribuido: 12 Películas, 8 Series, 8 Documentales,
--                 6 Música, 6 Podcasts
--    contenido_id_relacionado -> autoreferencia (mismo id)
-------------------------------------------------------

-- PELÍCULAS (12)
INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (1, 'El Último Vuelo', 2022, 'Un piloto debe salvar a sus pasajeros cuando el avión es secuestrado por terroristas.', '+13', DATE '2023-01-10', 7200, 1, 1, 3, 'Thriller de acción en las alturas', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (2, 'Amor en Cartagena', 2023, 'Dos desconocidos se enamoran durante un crucero por el Caribe colombiano.', 'TP', DATE '2023-02-14', 6600, 0, 2, 3, 'Romántica comedia ambientada en Colombia', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (3, 'La Sombra del Diablo', 2021, 'Un detective investiga una serie de crímenes rituales en una ciudad costera.', '+18', DATE '2023-03-05', 7500, 1, 3, 4, 'Terror y suspenso psicológico', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (4, 'Galaxia Perdida', 2023, 'Una tripulación espacial queda atrapada en una galaxia desconocida y debe encontrar el camino a casa.', '+7', DATE '2023-04-20', 8400, 1, 4, 4, 'Aventura de ciencia ficción familiar', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (5, 'Risas en Familia', 2022, 'Una familia disfuncional se reúne en Navidad con resultados hilarantes.', 'TP', DATE '2023-05-15', 5400, 0, 5, 5, 'Comedia familiar navideña', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (6, 'El Precio del Poder', 2023, 'Un político honesto debe escoger entre sus principios y la corrupción para salvar a su familia.', '+16', DATE '2023-06-10', 7800, 1, 6, 5, 'Drama político de alto impacto', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (7, 'Corazones Rotos', 2022, 'Tras una ruptura dolorosa, una mujer redescubre su identidad viajando por Sudamérica.', '+13', DATE '2023-07-01', 6900, 0, 7, 3, 'Drama romántico de autodescubrimiento', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (8, 'Monstruo de las Aguas', 2023, 'Un biólogo marino descubre una criatura desconocida en las profundidades del Pacífico.', '+13', DATE '2023-08-20', 7200, 1, 8, 4, 'Ciencia ficción y aventura submarina', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (9, 'La Última Batalla', 2021, 'Un general retirado vuelve al campo de batalla cuando su país es invadido.', '+16', DATE '2023-09-05', 9000, 0, 9, 5, 'Épica bélica de acción', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (10, 'Pequeños Héroes', 2023, 'Un grupo de niños descubre poderes mágicos y debe salvar su pueblo de una maldición ancestral.', '+7', DATE '2023-10-01', 5700, 1, 10, 3, 'Aventura infantil con magia', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (11, 'Sin Salida', 2022, 'Cuatro amigos quedan atrapados en una cabaña en el bosque con algo oscuro acechándolos.', '+18', DATE '2023-11-15', 6300, 1, 11, 4, 'Terror puro de supervivencia', 'PELICULA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (12, 'La Gran Estafa', 2023, 'Un grupo de ladrones elaboran el robo perfecto al banco más seguro del país.', '+16', DATE '2023-12-01', 7500, 0, 12, 5, 'Thriller de crimen y astucia', 'PELICULA');

-- SERIES (8)
INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (13, 'Imperio del Sur', 2022, 'Una familia de narcotraficantes lucha por mantener el poder en una Colombia convulsionada.', '+18', DATE '2023-01-20', 2700, 1, 13, 3, 'Drama criminal en múltiples temporadas', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (14, 'Los Detectives del Café', 2023, 'Dos detectives resuelven crímenes en Armenia usando pistas encontradas en cafeterías locales.', '+13', DATE '2023-02-28', 2400, 1, 14, 4, 'Comedia de misterio ambientada en el Quindío', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (15, 'Futuros Posibles', 2022, 'En 2150, los humanos coexisten con inteligencias artificiales en una sociedad utópica que empieza a fracturarse.', '+16', DATE '2023-04-10', 3000, 1, 15, 5, 'Ciencia ficción social y política', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (16, 'Casa Mágica', 2023, 'Una familia se muda a una casa encantada y sus hijos hacen amistad con los fantasmas que la habitan.', '+7', DATE '2023-05-01', 1800, 1, 16, 3, 'Aventura sobrenatural infantil', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (17, 'El Médico Rural', 2021, 'Un médico citadino llega a un pueblo remoto y debe adaptarse a una medicina sin recursos.', 'TP', DATE '2023-06-15', 2700, 0, 17, 4, 'Drama humano sobre la medicina en zonas rurales', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (18, 'Código Rojo', 2023, 'Un equipo de hackers éticos combate ciberataques globales desde una pequeña oficina en Bogotá.', '+16', DATE '2023-07-20', 2400, 1, 18, 5, 'Thriller tecnológico de alta tensión', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (19, 'Barrio Bonito', 2022, 'Las vivencias cómicas de los vecinos de un edificio en Medellín.', 'TP', DATE '2023-08-10', 1800, 0, 19, 3, 'Comedia costumbrista urbana', 'SERIE');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (20, 'Sangre y Flores', 2023, 'La historia de dos familias rivales de floricultores que luchan por el mercado internacional.', '+13', DATE '2023-09-01', 2700, 1, 20, 4, 'Drama familiar y empresarial', 'SERIE');

-- DOCUMENTALES (8)
INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (21, 'Amazonas: El Último Pulmón', 2022, 'Viaje al corazón del Amazonas para documentar la biodiversidad que desaparece.', 'TP', DATE '2023-01-15', 5400, 1, 21, 5, 'Documental ambiental de alto impacto', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (22, 'Cafeteros del Quindío', 2023, 'La vida cotidiana de las familias cafeteras del Eje Cafetero y su lucha por preservar la tradición.', 'TP', DATE '2023-02-20', 4800, 1, 22, 3, 'Documental cultural sobre el café colombiano', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (23, 'La Ruta de la Cocaína', 2021, 'Investigación periodística sobre el narcotrafico desde los cultivos hasta los mercados europeos.', '+18', DATE '2023-03-10', 6000, 0, 23, 4, 'Documental de investigación periodística', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (24, 'Mentes Brillantes', 2022, 'Perfiles de los científicos colombianos más destacados del siglo XXI.', 'TP', DATE '2023-04-25', 5100, 1, 24, 5, 'Documental sobre ciencia e innovación colombiana', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (25, 'Los Olvidados del Chocó', 2023, 'La realidad de las comunidades afrocolombianas marginadas del Chocó y su resiliencia cultural.', '+13', DATE '2023-05-20', 5700, 1, 25, 3, 'Documental social sobre diversidad cultural', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (26, 'Universo Cuántico', 2022, 'Explicación accesible de la mecánica cuántica y sus implicaciones para el futuro tecnológico.', '+13', DATE '2023-06-05', 4800, 0, 26, 4, 'Documental científico divulgativo', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (27, 'Fútbol y Pasión', 2023, 'La historia de los equipos más amados de Colombia y su impacto social en las comunidades.', 'TP', DATE '2023-07-10', 5400, 1, 27, 5, 'Documental deportivo y cultural', 'DOCUMENTAL');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (28, 'Arte Callejero', 2023, 'El movimiento del grafiti y el arte urbano en las principales ciudades latinoamericanas.', '+7', DATE '2023-08-15', 4200, 0, 28, 3, 'Documental sobre arte contemporáneo urbano', 'DOCUMENTAL');

-- MÚSICA (6)
INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (29, 'Cumbia Eterna', 2022, 'Colección de los mejores clásicos de la cumbia colombiana interpretados por artistas actuales.', 'TP', DATE '2023-01-25', 3600, 1, 29, 4, 'Álbum de cumbia clásica colombiana', 'MUSICA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (30, 'Reggaetón Urbano Vol. 1', 2023, 'Los mejores éxitos del género urbano latinoamericano del año.', '+13', DATE '2023-03-01', 3000, 0, 30, 5, 'Compilado de reggaetón contemporáneo', 'MUSICA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (31, 'Vallenato al Alma', 2022, 'Los vallenatos más emblemáticos de Colombia en versión acústica e íntima.', 'TP', DATE '2023-05-10', 4200, 1, 31, 3, 'Álbum de vallenato acústico colombiano', 'MUSICA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (32, 'Rock en Español', 2023, 'Una selección de rock latinoamericano de los 90s a la actualidad.', '+13', DATE '2023-06-20', 3600, 0, 32, 4, 'Compilado de rock en español', 'MUSICA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (33, 'Piano y Café', 2023, 'Melodías de piano para acompañar las mañanas con una taza de café colombiano.', 'TP', DATE '2023-08-01', 5400, 1, 33, 5, 'Álbum instrumental de piano relajante', 'MUSICA');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (34, 'Salsa Caleña', 2022, 'Los ritmos más calientes de la salsa caleña con las orquestas más representativas de la ciudad.', 'TP', DATE '2023-09-10', 3900, 1, 34, 3, 'Álbum de salsa caleña tradicional', 'MUSICA');

-- PODCASTS (6)
INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (35, 'Economía Para Todos', 2022, 'Explicaciones simples y amenas de conceptos económicos que afectan el día a día de los colombianos.', 'TP', DATE '2023-02-05', 3600, 1, 35, 4, 'Podcast educativo de economía', 'PODCAST');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (36, 'Crímenes Reales Colombia', 2023, 'Investigación detallada de los crímenes más impactantes en la historia colombiana.', '+18', DATE '2023-03-15', 4200, 1, 36, 5, 'Podcast de true crime colombiano', 'PODCAST');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (37, 'Startup Stories', 2022, 'Historias de emprendedores colombianos que transformaron sus ideas en negocios exitosos.', 'TP', DATE '2023-04-15', 3000, 0, 37, 3, 'Podcast de emprendimiento e innovación', 'PODCAST');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (38, 'Ciencia y Vida', 2023, 'Debates y entrevistas con científicos sobre los avances más importantes de la biología moderna.', '+13', DATE '2023-06-01', 3600, 1, 38, 4, 'Podcast de divulgación científica', 'PODCAST');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (39, 'Historia Sin Filtros', 2022, 'Los eventos históricos más importantes de Colombia contados sin eufemismos ni censuras.', '+16', DATE '2023-07-25', 4800, 1, 39, 5, 'Podcast de historia colombiana crítica', 'PODCAST');

INSERT INTO contenido (id_contenido, titulo, anio_lanzamiento, sinopsis, clasificacion_edad, fecha_agregado, duracion, es_original, contenido_id_relacionado, Empleado_id_empleado, descripcion, tipo_contenido)
VALUES (40, 'Mindfulness en el Caos', 2023, 'Guías prácticas de meditación y mindfulness para personas con vidas agitadas en la ciudad.', 'TP', DATE '2023-09-20', 2400, 0, 40, 3, 'Podcast de bienestar y meditación', 'PODCAST');


-------------------------------------------------------
-- 8. SUBTIPOS DE CONTENIDO
-------------------------------------------------------

-- 8.1 Películas
INSERT INTO pelicula (id_contenido, director) VALUES (1, 'Alejandro García');
INSERT INTO pelicula (id_contenido, director) VALUES (2, 'Carolina Vélez');
INSERT INTO pelicula (id_contenido, director) VALUES (3, 'Rodrigo Salcedo');
INSERT INTO pelicula (id_contenido, director) VALUES (4, 'Martín Ospina');
INSERT INTO pelicula (id_contenido, director) VALUES (5, 'Ana Lucía Reyes');
INSERT INTO pelicula (id_contenido, director) VALUES (6, 'Hernando Pizarro');
INSERT INTO pelicula (id_contenido, director) VALUES (7, 'Juliana Mora');
INSERT INTO pelicula (id_contenido, director) VALUES (8, 'Carlos Zuluaga');
INSERT INTO pelicula (id_contenido, director) VALUES (9, 'Pedro Arboleda');
INSERT INTO pelicula (id_contenido, director) VALUES (10, 'Sandra Cifuentes');
INSERT INTO pelicula (id_contenido, director) VALUES (11, 'Tomás Guerrero');
INSERT INTO pelicula (id_contenido, director) VALUES (12, 'Diana Quintero');

-- 8.2 Series
INSERT INTO serie (id_contenido, creador) VALUES (13, 'Luis Ernesto Fonseca');
INSERT INTO serie (id_contenido, creador) VALUES (14, 'María Camila Soto');
INSERT INTO serie (id_contenido, creador) VALUES (15, 'Iván Darío Mejía');
INSERT INTO serie (id_contenido, creador) VALUES (16, 'Paola Andrea Ríos');
INSERT INTO serie (id_contenido, creador) VALUES (17, 'Germán Augusto Peña');
INSERT INTO serie (id_contenido, creador) VALUES (18, 'Daniela Cárdenas');
INSERT INTO serie (id_contenido, creador) VALUES (19, 'Ricardo Salazar');
INSERT INTO serie (id_contenido, creador) VALUES (20, 'Natalia Herrera');

-- 8.3 Documentales
INSERT INTO documental (id_contenido, director) VALUES (21, 'Esteban Montoya');
INSERT INTO documental (id_contenido, director) VALUES (22, 'Gloria Patricia Arango');
INSERT INTO documental (id_contenido, director) VALUES (23, 'Felipe Castaño');
INSERT INTO documental (id_contenido, director) VALUES (24, 'Camila Jaramillo');
INSERT INTO documental (id_contenido, director) VALUES (25, 'Alejandro Palacios');
INSERT INTO documental (id_contenido, director) VALUES (26, 'Sofía Vargas');
INSERT INTO documental (id_contenido, director) VALUES (27, 'Mauricio López');
INSERT INTO documental (id_contenido, director) VALUES (28, 'Valentina Cano');

-- 8.4 Música
INSERT INTO Musica (id_contenido, artista, album) VALUES (29, 'Varios Artistas', 'Cumbia Eterna');
INSERT INTO Musica (id_contenido, artista, album) VALUES (30, 'Varios Artistas', 'Reggaetón Urbano Vol. 1');
INSERT INTO Musica (id_contenido, artista, album) VALUES (31, 'Los Clásicos del Vallenato', 'Vallenato al Alma');
INSERT INTO Musica (id_contenido, artista, album) VALUES (32, 'Varios Artistas', 'Rock en Español 90-2023');
INSERT INTO Musica (id_contenido, artista, album) VALUES (33, 'Mauricio Piano', 'Piano y Café Vol. 1');
INSERT INTO Musica (id_contenido, artista, album) VALUES (34, 'Orquestas de Cali', 'Salsa Caleña Pura');

-- 8.5 Podcasts
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (35, 'Dr. Jorge Ramos', 'Economía');
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (36, 'Investigadora Ana Cadavid', 'Criminalidad');
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (37, 'Emprendedora Laura Gil', 'Negocios');
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (38, 'Dra. Marcela Torres', 'Ciencia');
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (39, 'Historiador Ramón Díaz', 'Historia');
INSERT INTO Podcast (id_contenido, anfitrion, tematica) VALUES (40, 'Coach Daniela Paz', 'Bienestar');


-------------------------------------------------------
-- 9. TIPO_GENERO (relación contenido - género)
-------------------------------------------------------

-- Películas
INSERT INTO tipo_genero VALUES (1, 1);  -- El Último Vuelo: Acción
INSERT INTO tipo_genero VALUES (1, 4);  -- El Último Vuelo: Suspenso
INSERT INTO tipo_genero VALUES (2, 5);  -- Amor en Cartagena: Romance
INSERT INTO tipo_genero VALUES (2, 2);  -- Amor en Cartagena: Comedia
INSERT INTO tipo_genero VALUES (3, 7);  -- La Sombra del Diablo: Terror
INSERT INTO tipo_genero VALUES (3, 4);  -- La Sombra del Diablo: Suspenso
INSERT INTO tipo_genero VALUES (4, 6);  -- Galaxia Perdida: Ciencia Ficción
INSERT INTO tipo_genero VALUES (4, 1);  -- Galaxia Perdida: Acción
INSERT INTO tipo_genero VALUES (5, 2);  -- Risas en Familia: Comedia
INSERT INTO tipo_genero VALUES (5, 8);  -- Risas en Familia: Infantil
INSERT INTO tipo_genero VALUES (6, 3);  -- El Precio del Poder: Drama
INSERT INTO tipo_genero VALUES (6, 4);  -- El Precio del Poder: Suspenso
INSERT INTO tipo_genero VALUES (7, 3);  -- Corazones Rotos: Drama
INSERT INTO tipo_genero VALUES (7, 5);  -- Corazones Rotos: Romance
INSERT INTO tipo_genero VALUES (8, 6);  -- Monstruo de las Aguas: Ciencia Ficción
INSERT INTO tipo_genero VALUES (8, 1);  -- Monstruo de las Aguas: Acción
INSERT INTO tipo_genero VALUES (9, 1);  -- La Última Batalla: Acción
INSERT INTO tipo_genero VALUES (9, 3);  -- La Última Batalla: Drama
INSERT INTO tipo_genero VALUES (10, 8); -- Pequeños Héroes: Infantil
INSERT INTO tipo_genero VALUES (10, 1); -- Pequeños Héroes: Acción
INSERT INTO tipo_genero VALUES (11, 7); -- Sin Salida: Terror
INSERT INTO tipo_genero VALUES (12, 4); -- La Gran Estafa: Suspenso
INSERT INTO tipo_genero VALUES (12, 1); -- La Gran Estafa: Acción

-- Series
INSERT INTO tipo_genero VALUES (13, 3); -- Imperio del Sur: Drama
INSERT INTO tipo_genero VALUES (13, 4); -- Imperio del Sur: Suspenso
INSERT INTO tipo_genero VALUES (14, 2); -- Los Detectives del Café: Comedia
INSERT INTO tipo_genero VALUES (14, 4); -- Los Detectives del Café: Suspenso
INSERT INTO tipo_genero VALUES (15, 6); -- Futuros Posibles: Ciencia Ficción
INSERT INTO tipo_genero VALUES (15, 3); -- Futuros Posibles: Drama
INSERT INTO tipo_genero VALUES (16, 8); -- Casa Mágica: Infantil
INSERT INTO tipo_genero VALUES (17, 3); -- El Médico Rural: Drama
INSERT INTO tipo_genero VALUES (18, 6); -- Código Rojo: Ciencia Ficción
INSERT INTO tipo_genero VALUES (18, 4); -- Código Rojo: Suspenso
INSERT INTO tipo_genero VALUES (19, 2); -- Barrio Bonito: Comedia
INSERT INTO tipo_genero VALUES (20, 3); -- Sangre y Flores: Drama
INSERT INTO tipo_genero VALUES (20, 5); -- Sangre y Flores: Romance

-- Documentales
INSERT INTO tipo_genero VALUES (21, 3); -- Amazonas: Drama
INSERT INTO tipo_genero VALUES (22, 3); -- Cafeteros del Quindío: Drama
INSERT INTO tipo_genero VALUES (23, 4); -- La Ruta de la Cocaína: Suspenso
INSERT INTO tipo_genero VALUES (24, 6); -- Mentes Brillantes: Ciencia Ficción
INSERT INTO tipo_genero VALUES (25, 3); -- Los Olvidados del Chocó: Drama
INSERT INTO tipo_genero VALUES (26, 6); -- Universo Cuántico: Ciencia Ficción
INSERT INTO tipo_genero VALUES (27, 3); -- Fútbol y Pasión: Drama
INSERT INTO tipo_genero VALUES (28, 3); -- Arte Callejero: Drama

-- Música
INSERT INTO tipo_genero VALUES (29, 2); -- Cumbia Eterna: Comedia (alegre)
INSERT INTO tipo_genero VALUES (30, 1); -- Reggaetón: Acción (energía)
INSERT INTO tipo_genero VALUES (31, 5); -- Vallenato: Romance
INSERT INTO tipo_genero VALUES (32, 1); -- Rock: Acción
INSERT INTO tipo_genero VALUES (33, 5); -- Piano y Café: Romance
INSERT INTO tipo_genero VALUES (34, 2); -- Salsa Caleña: Comedia (festivo)

-- Podcasts
INSERT INTO tipo_genero VALUES (35, 3); -- Economía: Drama (social)
INSERT INTO tipo_genero VALUES (36, 4); -- Crímenes Reales: Suspenso
INSERT INTO tipo_genero VALUES (37, 3); -- Startup Stories: Drama
INSERT INTO tipo_genero VALUES (38, 6); -- Ciencia y Vida: Ciencia Ficción
INSERT INTO tipo_genero VALUES (39, 3); -- Historia: Drama
INSERT INTO tipo_genero VALUES (40, 5); -- Mindfulness: Romance (bienestar)


-------------------------------------------------------
-- 10. TEMPORADA (15 registros: para series y podcasts)
-------------------------------------------------------

-- Series
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (1, 3, 13, 'Imperio del Sur - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (2, 3, 13, 'Imperio del Sur - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (3, 3, 13, 'Imperio del Sur - Temporada 3', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (4, 2, 14, 'Los Detectives del Café - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (5, 2, 14, 'Los Detectives del Café - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (6, 2, 15, 'Futuros Posibles - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (7, 2, 15, 'Futuros Posibles - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (8, 1, 16, 'Casa Mágica - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (9, 2, 17, 'El Médico Rural - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (10, 2, 17, 'El Médico Rural - Temporada 2', NULL);

-- Podcasts
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (11, 2, NULL, 'Economía Para Todos - Temporada 1', 35);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (12, 2, NULL, 'Economía Para Todos - Temporada 2', 35);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (13, 1, NULL, 'Crímenes Reales Colombia - Temporada 1', 36);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (14, 1, NULL, 'Historia Sin Filtros - Temporada 1', 39);
INSERT INTO Temporada (id_temporada, cantidad_temporadas, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (15, 1, NULL, 'Mindfulness en el Caos - Temporada 1', 40);


-------------------------------------------------------
-- 11. EPISODIO (50 registros)
-------------------------------------------------------

-- Imperio del Sur T1 (10 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (1, 1, 'El Ascenso', 2700, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (2, 1, 'Sangre y Barro', 2700, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (3, 1, 'Alianzas Peligrosas', 2700, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (4, 1, 'La Traición', 2700, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (5, 1, 'El Precio del Silencio', 2700, 5);

-- Imperio del Sur T2 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (6, 2, 'Regreso a las Raíces', 2700, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (7, 2, 'La Red se Cierra', 2700, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (8, 2, 'Familia Primero', 2700, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (9, 2, 'El Pacto', 2700, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (10, 2, 'Caída Libre', 2700, 5);

-- Los Detectives del Café T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (11, 4, 'El Misterio del Café Negro', 2400, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (12, 4, 'Pistas en el Expreso', 2400, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (13, 4, 'El Barista Sospechoso', 2400, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (14, 4, 'La Hacienda Maldita', 2400, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (15, 4, 'Caso Cerrado', 2400, 5);

-- Los Detectives del Café T2 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (16, 5, 'Nueva Temporada, Nuevos Casos', 2400, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (17, 5, 'El Robo del Siglo', 2400, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (18, 5, 'Identidades Falsas', 2400, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (19, 5, 'La Conspiración del Café', 2400, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (20, 5, 'Justicia Servida', 2400, 5);

-- Futuros Posibles T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (21, 6, 'El Despertar', 3000, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (22, 6, 'Utopía Frágil', 3000, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (23, 6, 'Rebelión de Código', 3000, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (24, 6, 'El Protocolo Omega', 3000, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (25, 6, 'Colapso', 3000, 5);

-- Casa Mágica T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (26, 8, 'Bienvenidos a Casa', 1800, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (27, 8, 'El Fantasma del Ático', 1800, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (28, 8, 'La Fiesta de los Espíritus', 1800, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (29, 8, 'Secretos del Sótano', 1800, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (30, 8, 'El Gran Final', 1800, 5);

-- El Médico Rural T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (31, 9, 'Primer Día en el Pueblo', 2700, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (32, 9, 'Medicinas Escasas', 2700, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (33, 9, 'El Brote', 2700, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (34, 9, 'Entre la Vida y la Muerte', 2700, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (35, 9, 'El Milagro', 2700, 5);

-- Podcast Economía Para Todos T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (36, 11, 'Inflación: qué es y cómo nos afecta', 3600, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (37, 11, 'TRM y el dólar: claves para entenderlo', 3600, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (38, 11, 'Pensiones: el sistema que nos espera', 3600, 3);

-- Podcast Crímenes Reales T1 (3 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (39, 13, 'El Cartel de Cali: Origen', 4200, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (40, 13, 'Los Doce Apóstoles', 4200, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (41, 13, 'La Caída del Imperio', 4200, 3);

-- Podcast Historia Sin Filtros T1 (4 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (42, 14, 'La Independencia que no fue', 4800, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (43, 14, 'La Violencia de los 50s', 4800, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (44, 14, 'El Bogotazo: 9 de Abril', 4800, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (45, 14, 'El Frente Nacional', 4800, 4);

-- Podcast Mindfulness T1 (5 episodios)
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (46, 15, 'Respiración Consciente', 2400, 1);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (47, 15, 'Meditación para Principiantes', 2400, 2);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (48, 15, 'Desconectarse para Reconectarse', 2400, 3);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (49, 15, 'El Poder del Silencio', 2400, 4);
INSERT INTO Episodio (id_episodio, Temporada_id_temporada, titulo, duracion, numero_episodio) VALUES (50, 15, 'Vivir el Presente', 2400, 5);


-------------------------------------------------------
-- 12. PAGO (80 registros - varios meses, algunos fallidos)
-------------------------------------------------------

-- Enero 2024
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (1, DATE '2024-01-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (2, DATE '2024-01-15', 24900, 'Nequi', 'Exitoso', 0, 9);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (3, DATE '2024-01-05', 34900, 'PSE', 'Exitoso', 0, 13);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (4, DATE '2024-01-15', 24900, 'Tarjeta débito', 'Exitoso', 0, 23);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (5, DATE '2024-01-20', 24900, 'Daviplata', 'Fallido', 0, 10);

-- Febrero 2024
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (6, DATE '2024-02-10', 34900, 'Tarjeta crédito', 'Exitoso', 3490, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (7, DATE '2024-02-15', 34900, 'Tarjeta crédito', 'Exitoso', 0, 2);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (8, DATE '2024-02-01', 24900, 'Nequi', 'Exitoso', 0, 17);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (9, DATE '2024-02-28', 24900, 'PSE', 'Exitoso', 2490, 10);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (10, DATE '2024-02-15', 34900, 'Tarjeta débito', 'Fallido', 0, 14);

-- Marzo 2024
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (11, DATE '2024-03-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (12, DATE '2024-03-15', 34900, 'PSE', 'Exitoso', 0, 2);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (13, DATE '2024-03-01', 34900, 'Nequi', 'Exitoso', 0, 3);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (14, DATE '2024-03-20', 34900, 'Tarjeta crédito', 'Exitoso', 3490, 4);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (15, DATE '2024-03-15', 34900, 'Daviplata', 'Exitoso', 0, 14);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (16, DATE '2024-03-01', 24900, 'PSE', 'Exitoso', 0, 23);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (17, DATE '2024-03-10', 24900, 'Nequi', 'Fallido', 0, 17);

-- Abril 2024
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (18, DATE '2024-04-05', 34900, 'Tarjeta crédito', 'Exitoso', 0, 5);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (19, DATE '2024-04-10', 24900, 'Nequi', 'Exitoso', 2490, 10);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (20, DATE '2024-04-10', 24900, 'Daviplata', 'Exitoso', 0, 18);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (21, DATE '2024-04-15', 34900, 'Tarjeta crédito', 'Exitoso', 0, 13);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (22, DATE '2024-04-20', 24900, 'PSE', 'Pendiente', 0, 24);

-- Mayo 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (23, DATE '2025-05-01', 34900, 'Tarjeta crédito', 'Exitoso', 0, 6);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (24, DATE '2025-05-10', 34900, 'PSE', 'Exitoso', 3490, 15);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (25, DATE '2025-05-10', 24900, 'Nequi', 'Exitoso', 0, 25);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (26, DATE '2025-05-20', 14900, 'Daviplata', 'Exitoso', 0, 21);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (27, DATE '2025-05-15', 34900, 'Tarjeta crédito', 'Fallido', 0, 4);

-- Junio 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (28, DATE '2025-06-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 8);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (29, DATE '2025-06-15', 24900, 'PSE', 'Exitoso', 0, 12);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (30, DATE '2025-06-25', 24900, 'Nequi', 'Exitoso', 0, 19);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (31, DATE '2025-06-01', 34900, 'Daviplata', 'Exitoso', 3490, 5);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (32, DATE '2025-06-20', 24900, 'Tarjeta débito', 'Exitoso', 0, 20);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (33, DATE '2025-06-10', 14900, 'Nequi', 'Fallido', 0, 22);

-- Julio 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (34, DATE '2025-07-01', 24900, 'PSE', 'Exitoso', 0, 12);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (35, DATE '2025-07-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (36, DATE '2025-07-20', 14900, 'Daviplata', 'Exitoso', 1490, 27);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (37, DATE '2025-07-15', 24900, 'Nequi', 'Exitoso', 0, 17);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (38, DATE '2025-07-05', 34900, 'Tarjeta crédito', 'Fallido', 0, 3);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (39, DATE '2025-07-25', 24900, 'PSE', 'Reembolsado', 0, 9);

-- Agosto 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (40, DATE '2025-08-01', 24900, 'Tarjeta débito', 'Exitoso', 0, 20);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (41, DATE '2025-08-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 2);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (42, DATE '2025-08-15', 14900, 'Nequi', 'Exitoso', 0, 28);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (43, DATE '2025-08-20', 24900, 'PSE', 'Exitoso', 2490, 23);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (44, DATE '2025-08-05', 34900, 'Daviplata', 'Fallido', 0, 13);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (45, DATE '2025-08-25', 34900, 'Tarjeta crédito', 'Exitoso', 0, 6);

-- Septiembre 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (46, DATE '2025-09-01', 14900, 'Daviplata', 'Exitoso', 0, 21);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (47, DATE '2025-09-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 15);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (48, DATE '2025-09-15', 24900, 'Nequi', 'Exitoso', 0, 18);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (49, DATE '2025-09-10', 14900, 'PSE', 'Exitoso', 1490, 29);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (50, DATE '2025-09-20', 24900, 'Tarjeta débito', 'Fallido', 0, 25);

-- Octubre 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (51, DATE '2025-10-01', 34900, 'Tarjeta crédito', 'Exitoso', 0, 8);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (52, DATE '2025-10-10', 24900, 'PSE', 'Exitoso', 0, 19);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (53, DATE '2025-10-15', 14900, 'Nequi', 'Exitoso', 0, 22);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (54, DATE '2025-10-01', 14900, 'Daviplata', 'Exitoso', 0, 30);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (55, DATE '2025-10-20', 34900, 'Tarjeta crédito', 'Pendiente', 0, 4);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (56, DATE '2025-10-25', 24900, 'Nequi', 'Reembolsado', 24900, 20);

-- Noviembre 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (57, DATE '2025-11-01', 34900, 'Tarjeta crédito', 'Exitoso', 3490, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (58, DATE '2025-11-10', 34900, 'PSE', 'Exitoso', 0, 5);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (59, DATE '2025-11-15', 24900, 'Nequi', 'Exitoso', 0, 24);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (60, DATE '2025-11-05', 14900, 'Daviplata', 'Exitoso', 0, 27);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (61, DATE '2025-11-20', 34900, 'Tarjeta débito', 'Fallido', 0, 6);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (62, DATE '2025-11-25', 24900, 'Tarjeta crédito', 'Exitoso', 0, 12);

-- Diciembre 2025
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (63, DATE '2025-12-01', 34900, 'Tarjeta crédito', 'Exitoso', 0, 3);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (64, DATE '2025-12-10', 24900, 'PSE', 'Exitoso', 2490, 9);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (65, DATE '2025-12-15', 14900, 'Nequi', 'Exitoso', 0, 21);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (66, DATE '2025-12-20', 34900, 'Daviplata', 'Exitoso', 0, 13);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (67, DATE '2025-12-05', 24900, 'Tarjeta débito', 'Exitoso', 0, 18);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (68, DATE '2025-12-25', 34900, 'Tarjeta crédito', 'Fallido', 0, 8);

-- Enero-Febrero 2026
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (69, DATE '2026-01-10', 34900, 'Tarjeta crédito', 'Exitoso', 0, 1);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (70, DATE '2026-01-15', 24900, 'PSE', 'Exitoso', 0, 23);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (71, DATE '2026-01-20', 14900, 'Nequi', 'Exitoso', 1490, 29);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (72, DATE '2026-01-05', 34900, 'Tarjeta crédito', 'Exitoso', 0, 15);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (73, DATE '2026-01-25', 24900, 'Daviplata', 'Fallido', 0, 10);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (74, DATE '2026-02-15', 34900, 'Tarjeta crédito', 'Exitoso', 0, 2);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (75, DATE '2026-02-01', 24900, 'Nequi', 'Exitoso', 0, 17);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (76, DATE '2026-02-10', 14900, 'PSE', 'Exitoso', 0, 22);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (77, DATE '2026-02-20', 34900, 'Tarjeta débito', 'Exitoso', 3490, 5);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (78, DATE '2026-02-25', 24900, 'Tarjeta crédito', 'Exitoso', 0, 24);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (79, DATE '2026-02-05', 34900, 'Nequi', 'Fallido', 0, 13);
INSERT INTO Pago (id_pago, fecha_pago, monto, metodo_pago, estado_pago, valor_descuento, suscripcion_id_suscripcion) VALUES (80, DATE '2026-02-28', 24900, 'PSE', 'Reembolsado', 12450, 20);


-------------------------------------------------------
-- 13. REPRODUCCION (200 registros)
--    Asimétrico: usuarios Premium tienen muchas más
--    reproducciones; contenido popular concentra más views
--    Episodio_id_episodio: para películas/docs/música/podcast
--    se usa el episodio 1 del primer podcast (id=36) como placeholder
--    ya que el modelo requiere el campo NOT NULL
-------------------------------------------------------

-- Bloque 1: Reproducciones de perfiles Premium Bogotá (perfiles 1-19)
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-11 20:00:00', TIMESTAMP '2024-01-11 22:00:00', 'TV', 1, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-12 21:00:00', TIMESTAMP '2024-01-12 22:15:00', 'TV', 2, 100, 1, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-15 19:30:00', TIMESTAMP '2024-01-15 21:00:00', 'Computador', 3, 85, 2, 13, 1);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-16 20:00:00', TIMESTAMP '2024-01-16 20:45:00', 'Celular', 4, 100, 5, 14, 11);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-17 22:00:00', TIMESTAMP '2024-01-17 23:30:00', 'TV', 5, 100, 8, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-18 18:00:00', TIMESTAMP '2024-01-18 19:30:00', 'Tablet', 6, 78, 10, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-20 20:30:00', TIMESTAMP '2024-01-20 21:15:00', 'TV', 7, 100, 1, 13, 2);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-21 21:00:00', TIMESTAMP '2024-01-21 23:00:00', 'TV', 8, 100, 14, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-22 19:00:00', TIMESTAMP '2024-01-22 20:30:00', 'Computador', 9, 100, 16, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-23 20:00:00', TIMESTAMP '2024-01-23 21:30:00', 'TV', 10, 55, 18, 15, 21);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-01 21:00:00', TIMESTAMP '2024-02-01 23:00:00', 'TV', 11, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-02 20:30:00', TIMESTAMP '2024-02-02 22:00:00', 'TV', 12, 100, 5, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-03 19:00:00', TIMESTAMP '2024-02-03 20:45:00', 'Computador', 13, 100, 8, 13, 3);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-05 22:00:00', TIMESTAMP '2024-02-05 23:45:00', 'TV', 14, 100, 2, 15, 22);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-07 20:00:00', TIMESTAMP '2024-02-07 21:30:00', 'Celular', 15, 45, 4, 14, 12);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-08 21:30:00', TIMESTAMP '2024-02-08 23:00:00', 'TV', 16, 100, 9, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-10 18:30:00', TIMESTAMP '2024-02-10 20:00:00', 'Tablet', 17, 100, 11, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-12 20:00:00', TIMESTAMP '2024-02-12 21:40:00', 'TV', 18, 100, 15, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-14 21:00:00', TIMESTAMP '2024-02-14 22:50:00', 'TV', 19, 100, 1, 7, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-15 19:00:00', TIMESTAMP '2024-02-15 20:30:00', 'Computador', 20, 70, 6, 13, 4);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-01 20:00:00', TIMESTAMP '2024-03-01 22:00:00', 'TV', 21, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-02 21:00:00', TIMESTAMP '2024-03-02 22:45:00', 'TV', 22, 100, 2, 13, 5);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-05 19:30:00', TIMESTAMP '2024-03-05 21:00:00', 'Computador', 23, 100, 8, 15, 23);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-07 22:00:00', TIMESTAMP '2024-03-07 23:30:00', 'TV', 24, 100, 10, 5, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-10 20:00:00', TIMESTAMP '2024-03-10 21:40:00', 'TV', 25, 100, 14, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-12 18:00:00', TIMESTAMP '2024-03-12 19:30:00', 'Tablet', 26, 80, 3, 21, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-15 21:30:00', TIMESTAMP '2024-03-15 23:00:00', 'TV', 27, 100, 5, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-17 20:00:00', TIMESTAMP '2024-03-17 21:30:00', 'Celular', 28, 60, 7, 30, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-20 19:00:00', TIMESTAMP '2024-03-20 20:50:00', 'TV', 29, 100, 16, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-22 21:00:00', TIMESTAMP '2024-03-22 22:30:00', 'TV', 30, 100, 18, 9, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-01 20:00:00', TIMESTAMP '2024-04-01 22:00:00', 'TV', 31, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-03 21:00:00', TIMESTAMP '2024-04-03 22:40:00', 'TV', 32, 100, 5, 13, 6);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-05 19:00:00', TIMESTAMP '2024-04-05 20:30:00', 'Computador', 33, 100, 8, 14, 13);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-07 22:30:00', TIMESTAMP '2024-04-07 23:45:00', 'TV', 34, 100, 2, 15, 24);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-10 18:00:00', TIMESTAMP '2024-04-10 19:40:00', 'Tablet', 35, 100, 12, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-12 20:00:00', TIMESTAMP '2024-04-12 21:30:00', 'TV', 36, 100, 14, 8, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-15 21:00:00', TIMESTAMP '2024-04-15 22:50:00', 'TV', 37, 100, 4, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-17 19:30:00', TIMESTAMP '2024-04-17 21:00:00', 'Computador', 38, 90, 6, 25, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-20 20:00:00', TIMESTAMP '2024-04-20 21:30:00', 'TV', 39, 100, 16, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-22 21:30:00', TIMESTAMP '2024-04-22 23:00:00', 'TV', 40, 100, 18, 24, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-01 20:00:00', TIMESTAMP '2024-05-01 22:00:00', 'TV', 41, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-03 21:00:00', TIMESTAMP '2024-05-03 23:30:00', 'TV', 42, 100, 5, 9, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-05 19:30:00', TIMESTAMP '2024-05-05 21:00:00', 'Computador', 43, 100, 8, 13, 7);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-07 22:00:00', TIMESTAMP '2024-05-07 23:40:00', 'TV', 44, 100, 2, 14, 14);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-10 18:00:00', TIMESTAMP '2024-05-10 20:00:00', 'TV', 45, 100, 12, 15, 25);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-12 20:00:00', TIMESTAMP '2024-05-12 21:30:00', 'Celular', 46, 55, 14, 35, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-15 21:00:00', TIMESTAMP '2024-05-15 22:45:00', 'TV', 47, 100, 4, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-17 19:00:00', TIMESTAMP '2024-05-17 20:30:00', 'Tablet', 48, 100, 6, 21, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-20 20:00:00', TIMESTAMP '2024-05-20 21:50:00', 'TV', 49, 100, 16, 8, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-22 21:00:00', TIMESTAMP '2024-05-22 22:30:00', 'TV', 50, 75, 18, 18, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-01 20:00:00', TIMESTAMP '2024-06-01 22:00:00', 'TV', 51, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-03 21:30:00', TIMESTAMP '2024-06-03 23:00:00', 'TV', 52, 100, 25, 13, 8);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-05 19:00:00', TIMESTAMP '2024-06-05 20:40:00', 'Computador', 53, 100, 27, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-08 22:00:00', TIMESTAMP '2024-06-08 23:30:00', 'TV', 54, 100, 29, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-10 18:30:00', TIMESTAMP '2024-06-10 20:00:00', 'TV', 55, 100, 31, 14, 15);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-12 20:00:00', TIMESTAMP '2024-06-12 21:30:00', 'Tablet', 56, 80, 33, 33, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-15 21:00:00', TIMESTAMP '2024-06-15 22:45:00', 'TV', 57, 100, 35, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-17 19:30:00', TIMESTAMP '2024-06-17 21:00:00', 'TV', 58, 100, 37, 25, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-20 20:00:00', TIMESTAMP '2024-06-20 21:30:00', 'Computador', 59, 90, 39, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-22 21:00:00', TIMESTAMP '2024-06-22 22:30:00', 'TV', 60, 100, 41, 4, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-01 20:00:00', TIMESTAMP '2024-07-01 22:00:00', 'TV', 61, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-03 21:00:00', TIMESTAMP '2024-07-03 22:45:00', 'TV', 62, 100, 20, 13, 9);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-05 18:30:00', TIMESTAMP '2024-07-05 20:00:00', 'Computador', 63, 100, 22, 15, 26);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-07 22:00:00', TIMESTAMP '2024-07-07 23:30:00', 'TV', 64, 100, 24, 14, 16);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-10 19:00:00', TIMESTAMP '2024-07-10 20:30:00', 'Celular', 65, 65, 26, 35, 37);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-12 20:00:00', TIMESTAMP '2024-07-12 21:40:00', 'TV', 66, 100, 28, 36, 38);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-15 21:00:00', TIMESTAMP '2024-07-15 22:30:00', 'TV', 67, 100, 30, 5, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-17 18:00:00', TIMESTAMP '2024-07-17 19:30:00', 'Tablet', 68, 100, 32, 21, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-20 20:00:00', TIMESTAMP '2024-07-20 21:45:00', 'TV', 69, 100, 34, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-22 21:30:00', TIMESTAMP '2024-07-22 23:00:00', 'TV', 70, 85, 36, 27, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-01 20:00:00', TIMESTAMP '2024-08-01 22:00:00', 'TV', 71, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-03 21:00:00', TIMESTAMP '2024-08-03 22:40:00', 'TV', 72, 100, 5, 13, 10);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-05 19:00:00', TIMESTAMP '2024-08-05 20:30:00', 'Computador', 73, 100, 15, 15, 27);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-07 22:00:00', TIMESTAMP '2024-08-07 23:45:00', 'TV', 74, 100, 17, 17, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-10 18:30:00', TIMESTAMP '2024-08-10 20:00:00', 'TV', 75, 100, 19, 19, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-12 20:00:00', TIMESTAMP '2024-08-12 21:30:00', 'Celular', 76, 50, 21, 36, 39);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-15 21:00:00', TIMESTAMP '2024-08-15 22:45:00', 'TV', 77, 100, 23, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-17 19:30:00', TIMESTAMP '2024-08-17 21:00:00', 'Tablet', 78, 100, 25, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-20 20:00:00', TIMESTAMP '2024-08-20 21:30:00', 'TV', 79, 100, 27, 28, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-22 21:00:00', TIMESTAMP '2024-08-22 22:30:00', 'TV', 80, 90, 29, 24, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-01 20:00:00', TIMESTAMP '2024-09-01 22:00:00', 'TV', 81, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-03 21:30:00', TIMESTAMP '2024-09-03 23:00:00', 'TV', 82, 100, 2, 13, 1);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-05 19:00:00', TIMESTAMP '2024-09-05 20:30:00', 'Computador', 83, 100, 6, 14, 17);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-08 22:00:00', TIMESTAMP '2024-09-08 23:30:00', 'TV', 84, 100, 8, 15, 28);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-10 18:00:00', TIMESTAMP '2024-09-10 19:40:00', 'TV', 85, 100, 10, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-12 20:00:00', TIMESTAMP '2024-09-12 21:30:00', 'Tablet', 86, 75, 12, 36, 40);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-15 21:00:00', TIMESTAMP '2024-09-15 22:45:00', 'TV', 87, 100, 14, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-17 19:30:00', TIMESTAMP '2024-09-17 21:00:00', 'TV', 88, 100, 16, 25, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-20 20:00:00', TIMESTAMP '2024-09-20 21:30:00', 'Computador', 89, 100, 18, 8, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-22 21:00:00', TIMESTAMP '2024-09-22 22:30:00', 'TV', 90, 80, 20, 21, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-01 20:00:00', TIMESTAMP '2024-10-01 22:00:00', 'TV', 91, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-03 21:00:00', TIMESTAMP '2024-10-03 22:40:00', 'TV', 92, 100, 5, 13, 2);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-05 19:00:00', TIMESTAMP '2024-10-05 20:30:00', 'Computador', 93, 100, 8, 14, 18);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-07 22:00:00', TIMESTAMP '2024-10-07 23:30:00', 'TV', 94, 100, 2, 15, 29);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-10 18:30:00', TIMESTAMP '2024-10-10 20:00:00', 'TV', 95, 100, 12, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-12 20:00:00', TIMESTAMP '2024-10-12 21:30:00', 'Celular', 96, 40, 14, 40, 46);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-15 21:00:00', TIMESTAMP '2024-10-15 22:45:00', 'TV', 97, 100, 4, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-17 19:30:00', TIMESTAMP '2024-10-17 21:00:00', 'Tablet', 98, 100, 6, 27, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-20 20:00:00', TIMESTAMP '2024-10-20 21:30:00', 'TV', 99, 100, 16, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-22 21:00:00', TIMESTAMP '2024-10-22 22:30:00', 'TV', 100, 95, 18, 7, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-01 20:00:00', TIMESTAMP '2024-11-01 22:00:00', 'TV', 101, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-02 21:00:00', TIMESTAMP '2024-11-02 22:45:00', 'TV', 102, 100, 5, 13, 3);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-04 19:00:00', TIMESTAMP '2024-11-04 20:30:00', 'Computador', 103, 100, 8, 14, 19);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-06 22:00:00', TIMESTAMP '2024-11-06 23:30:00', 'TV', 104, 100, 2, 15, 30);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-08 18:00:00', TIMESTAMP '2024-11-08 19:40:00', 'TV', 105, 100, 10, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-10 20:00:00', TIMESTAMP '2024-11-10 21:30:00', 'Tablet', 106, 85, 12, 37, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-12 21:00:00', TIMESTAMP '2024-11-12 22:45:00', 'TV', 107, 100, 14, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-15 19:30:00', TIMESTAMP '2024-11-15 21:00:00', 'TV', 108, 100, 16, 23, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-17 20:00:00', TIMESTAMP '2024-11-17 21:30:00', 'Computador', 109, 100, 18, 9, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-20 21:00:00', TIMESTAMP '2024-11-20 22:30:00', 'TV', 110, 70, 20, 24, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-01 20:00:00', TIMESTAMP '2024-12-01 22:00:00', 'TV', 111, 100, 1, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-03 21:30:00', TIMESTAMP '2024-12-03 23:00:00', 'TV', 112, 100, 5, 5, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-05 19:00:00', TIMESTAMP '2024-12-05 20:30:00', 'Computador', 113, 100, 8, 10, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-08 22:00:00', TIMESTAMP '2024-12-08 23:30:00', 'TV', 114, 100, 14, 14, 20);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-10 18:30:00', TIMESTAMP '2024-12-10 20:00:00', 'TV', 115, 100, 16, 13, 4);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-12 20:00:00', TIMESTAMP '2024-12-12 21:30:00', 'Celular', 116, 60, 18, 38, 42);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-15 21:00:00', TIMESTAMP '2024-12-15 22:45:00', 'TV', 117, 100, 20, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-17 19:30:00', TIMESTAMP '2024-12-17 21:00:00', 'Tablet', 118, 100, 22, 23, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-20 20:00:00', TIMESTAMP '2024-12-20 21:30:00', 'TV', 119, 100, 24, 24, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-22 21:00:00', TIMESTAMP '2024-12-22 22:30:00', 'TV', 120, 100, 26, 11, 36);

-- Bloque 2: Reproducciones usuarios Medellín (perfiles 25-37)
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-20 20:00:00', TIMESTAMP '2024-01-20 22:00:00', 'TV', 121, 100, 25, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-25 21:00:00', TIMESTAMP '2024-01-25 22:40:00', 'TV', 122, 100, 27, 13, 5);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-10 19:30:00', TIMESTAMP '2024-02-10 21:00:00', 'Computador', 123, 100, 29, 15, 31);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-20 22:00:00', TIMESTAMP '2024-02-20 23:30:00', 'TV', 124, 100, 31, 18, 33);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-05 20:00:00', TIMESTAMP '2024-03-05 21:30:00', 'Celular', 125, 70, 33, 20, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-15 21:00:00', TIMESTAMP '2024-03-15 22:45:00', 'TV', 126, 100, 35, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-01 18:30:00', TIMESTAMP '2024-04-01 20:00:00', 'Tablet', 127, 100, 36, 9, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-15 20:00:00', TIMESTAMP '2024-04-15 21:30:00', 'TV', 128, 100, 25, 21, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-01 21:00:00', TIMESTAMP '2024-05-01 22:30:00', 'TV', 129, 100, 27, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-20 19:00:00', TIMESTAMP '2024-05-20 20:30:00', 'Computador', 130, 85, 29, 13, 6);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-05 20:00:00', TIMESTAMP '2024-06-05 22:00:00', 'TV', 131, 100, 31, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-15 21:30:00', TIMESTAMP '2024-06-15 23:00:00', 'TV', 132, 100, 33, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-01 19:00:00', TIMESTAMP '2024-07-01 20:30:00', 'Celular', 133, 55, 34, 14, 21);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-20 22:00:00', TIMESTAMP '2024-07-20 23:30:00', 'TV', 134, 100, 36, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-05 20:00:00', TIMESTAMP '2024-08-05 21:40:00', 'TV', 135, 100, 25, 15, 32);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-20 21:00:00', TIMESTAMP '2024-08-20 22:30:00', 'Tablet', 136, 90, 27, 25, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-05 19:30:00', TIMESTAMP '2024-09-05 21:00:00', 'TV', 137, 100, 29, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-20 20:00:00', TIMESTAMP '2024-09-20 21:30:00', 'Computador', 138, 100, 31, 24, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-05 21:00:00', TIMESTAMP '2024-10-05 22:45:00', 'TV', 139, 100, 33, 3, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-20 19:00:00', TIMESTAMP '2024-10-20 20:30:00', 'TV', 140, 80, 35, 13, 7);

-- Bloque 3: Reproducciones usuarios Cali (perfiles 38-44)
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-25 20:00:00', TIMESTAMP '2024-01-25 22:00:00', 'TV', 141, 100, 38, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-15 21:00:00', TIMESTAMP '2024-02-15 22:30:00', 'TV', 142, 100, 40, 34, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-10 19:00:00', TIMESTAMP '2024-03-10 20:30:00', 'Computador', 143, 100, 41, 13, 8);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-05 22:00:00', TIMESTAMP '2024-04-05 23:30:00', 'TV', 144, 100, 43, 19, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-10 20:00:00', TIMESTAMP '2024-05-10 21:30:00', 'Celular', 145, 65, 44, 14, 22);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-01 21:00:00', TIMESTAMP '2024-06-01 22:45:00', 'TV', 146, 100, 38, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-15 18:30:00', TIMESTAMP '2024-07-15 20:00:00', 'Tablet', 147, 100, 40, 26, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-10 20:00:00', TIMESTAMP '2024-08-10 21:30:00', 'TV', 148, 100, 41, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-05 21:00:00', TIMESTAMP '2024-09-05 22:30:00', 'TV', 149, 100, 43, 29, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-01 19:30:00', TIMESTAMP '2024-10-01 21:00:00', 'Computador', 150, 90, 44, 13, 9);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-05 20:00:00', TIMESTAMP '2024-11-05 22:00:00', 'TV', 151, 100, 38, 5, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-20 21:00:00', TIMESTAMP '2024-11-20 22:30:00', 'TV', 152, 100, 40, 21, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-01 19:00:00', TIMESTAMP '2024-12-01 20:30:00', 'Celular', 153, 45, 41, 40, 47);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-15 22:00:00', TIMESTAMP '2024-12-15 23:30:00', 'TV', 154, 100, 43, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-20 20:00:00', TIMESTAMP '2024-12-20 21:30:00', 'TV', 155, 100, 44, 16, 36);

-- Bloque 4: Reproducciones perfiles Armenia (45-46) y más variedad
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-15 20:00:00', TIMESTAMP '2024-10-15 22:00:00', 'Computador', 156, 100, 45, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-20 21:00:00', TIMESTAMP '2024-10-20 22:30:00', 'Celular', 157, 80, 46, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-01 19:00:00', TIMESTAMP '2024-11-01 20:30:00', 'Computador', 158, 100, 45, 14, 23);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-10 20:00:00', TIMESTAMP '2024-11-10 21:30:00', 'Celular', 159, 70, 46, 13, 10);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-01 21:00:00', TIMESTAMP '2024-12-01 22:00:00', 'Computador', 160, 100, 45, 35, 36);

-- Bloque 5: Reproducciones adicionales para llegar a 200 (variedad de contenidos y dispositivos)
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-01-30 20:00:00', TIMESTAMP '2024-01-30 21:30:00', 'TV', 161, 100, 3, 13, 1);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-02-25 21:00:00', TIMESTAMP '2024-02-25 22:30:00', 'TV', 162, 100, 9, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-03-25 19:00:00', TIMESTAMP '2024-03-25 20:30:00', 'Computador', 163, 100, 11, 13, 2);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-04-25 22:00:00', TIMESTAMP '2024-04-25 23:30:00', 'TV', 164, 100, 13, 15, 33);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-05-25 20:00:00', TIMESTAMP '2024-05-25 21:30:00', 'Celular', 165, 55, 19, 14, 24);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-06-25 21:00:00', TIMESTAMP '2024-06-25 22:45:00', 'TV', 166, 100, 21, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-07-25 18:30:00', TIMESTAMP '2024-07-25 20:00:00', 'Tablet', 167, 100, 23, 8, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-08-25 20:00:00', TIMESTAMP '2024-08-25 21:30:00', 'TV', 168, 100, 32, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-09-25 21:00:00', TIMESTAMP '2024-09-25 22:30:00', 'TV', 169, 100, 34, 14, 25);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-10-25 19:30:00', TIMESTAMP '2024-10-25 21:00:00', 'Computador', 170, 90, 38, 13, 3);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-11-25 20:00:00', TIMESTAMP '2024-11-25 22:00:00', 'TV', 171, 100, 1, 9, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2024-12-10 21:00:00', TIMESTAMP '2024-12-10 22:30:00', 'TV', 172, 100, 5, 12, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-01-05 19:00:00', TIMESTAMP '2025-01-05 20:30:00', 'Computador', 173, 100, 8, 13, 4);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-01-15 22:00:00', TIMESTAMP '2025-01-15 23:30:00', 'TV', 174, 100, 14, 15, 34);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-01-25 20:00:00', TIMESTAMP '2025-01-25 21:30:00', 'Celular', 175, 60, 16, 14, 26);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-02-05 21:00:00', TIMESTAMP '2025-02-05 22:45:00', 'TV', 176, 100, 18, 22, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-02-15 18:30:00', TIMESTAMP '2025-02-15 20:00:00', 'Tablet', 177, 100, 20, 8, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-02-25 20:00:00', TIMESTAMP '2025-02-25 21:30:00', 'TV', 178, 100, 22, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-03-05 21:00:00', TIMESTAMP '2025-03-05 22:30:00', 'TV', 179, 100, 24, 13, 5);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-03-15 19:30:00', TIMESTAMP '2025-03-15 21:00:00', 'Computador', 180, 80, 26, 15, 35);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-03-20 20:00:00', TIMESTAMP '2025-03-20 22:00:00', 'TV', 181, 100, 28, 2, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-03-25 21:00:00', TIMESTAMP '2025-03-25 22:40:00', 'TV', 182, 100, 30, 14, 27);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-01 19:00:00', TIMESTAMP '2025-04-01 20:30:00', 'Computador', 183, 100, 33, 13, 6);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-05 22:00:00', TIMESTAMP '2025-04-05 23:30:00', 'TV', 184, 100, 35, 19, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-10 20:00:00', TIMESTAMP '2025-04-10 21:30:00', 'Celular', 185, 75, 37, 14, 28);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-15 21:00:00', TIMESTAMP '2025-04-15 22:45:00', 'TV', 186, 100, 39, 4, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-18 18:30:00', TIMESTAMP '2025-04-18 20:00:00', 'Tablet', 187, 100, 41, 6, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-20 20:00:00', TIMESTAMP '2025-04-20 21:30:00', 'TV', 188, 100, 43, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-22 21:00:00', TIMESTAMP '2025-04-22 22:30:00', 'TV', 189, 100, 45, 13, 7);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-25 19:30:00', TIMESTAMP '2025-04-25 21:00:00', 'Computador', 190, 85, 46, 15, 36);

INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-26 20:00:00', TIMESTAMP '2025-04-26 22:00:00', 'TV', 191, 100, 2, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-27 21:00:00', TIMESTAMP '2025-04-27 22:30:00', 'TV', 192, 100, 4, 13, 8);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-27 19:00:00', TIMESTAMP '2025-04-27 20:30:00', 'Celular', 193, 50, 6, 35, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-28 22:00:00', TIMESTAMP '2025-04-28 23:30:00', 'TV', 194, 100, 10, 15, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-28 20:00:00', TIMESTAMP '2025-04-28 21:30:00', 'Computador', 195, 100, 12, 14, 29);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-29 21:00:00', TIMESTAMP '2025-04-29 22:45:00', 'TV', 196, 100, 16, 5, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-29 18:30:00', TIMESTAMP '2025-04-29 20:00:00', 'Tablet', 197, 100, 22, 27, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-30 20:00:00', TIMESTAMP '2025-04-30 21:30:00', 'TV', 198, 100, 25, 1, 36);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-04-30 21:00:00', TIMESTAMP '2025-04-30 22:30:00', 'TV', 199, 100, 38, 13, 9);
INSERT INTO Reproduccion VALUES (TIMESTAMP '2025-05-01 19:30:00', TIMESTAMP '2025-05-01 21:00:00', 'Computador', 200, 90, 45, 22, 36);


-------------------------------------------------------
-- 14. CALIFICACION (60 registros)
-------------------------------------------------------

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (1, 5, 'Absolutamente impresionante. Una de las mejores producciones que he visto en años.', 1, 1);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (2, 4, 'Muy buena serie, los personajes están muy bien desarrollados.', 5, 13);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (3, 5, 'El documental más completo sobre el Amazonas que he visto.', 8, 21);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (4, 3, 'Entretenida pero predecible. Esperaba más del final.', 10, 2);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (5, 5, 'El terror es genuino. Pasé una noche sin dormir después de verla.', 14, 3);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (6, 4, 'Buena ciencia ficción con un mensaje social poderoso.', 16, 15);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (7, 2, 'No era lo que esperaba. Historia muy lenta y personajes planos.', 20, 7);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (8, 5, 'Una joya del cine de acción colombiano. Orgullo nacional.', 25, 9);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (9, 4, 'Los niños la adoraron. Magia, aventura y valores en un mismo paquete.', 26, 10);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (10, 3, 'Aceptable. Ni muy buena ni muy mala. Buen entretenimiento de fin de semana.', 27, 5);

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (11, 5, 'Imperio del Sur supera a cualquier producción internacional. Magistral.', 1, 13);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (12, 4, 'Los Detectives del Café es fresca y original. Muy colombiana.', 29, 14);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (13, 1, 'Muy aburrida. No pude terminarla.', 31, 17);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (14, 5, 'Cafeteros del Quindío me hizo sentir orgullosa de mis raíces.', 45, 22);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (15, 4, 'El podcast de economía me ha enseñado más que muchos libros.', 20, 35);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (16, 5, 'La Ruta de la Cocaína es periodismo valiente e imprescindible.', 8, 23);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (17, 3, 'Música bien producida pero falta variedad de estilos.', 33, 30);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (18, 4, 'Código Rojo tiene una tensión que no te suelta. Excelente guion.', 2, 18);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (19, 5, 'Sin Salida es el mejor terror que he visto en mucho tiempo.', 5, 11);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (20, 2, 'Barrio Bonito es muy básica. Los chistes no tienen gracia.', 34, 19);

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (21, 4, 'Galaxia Perdida tiene efectos especiales increíbles para ser una producción local.', 12, 4);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (22, 5, 'Crímenes Reales Colombia es adictivo. Escuché toda la temporada en un día.', 36, 36);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (23, 3, 'La Gran Estafa es entretenida pero el final es demasiado predecible.', 38, 12);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (24, 4, 'Piano y Café es perfecto para trabajar y concentrarse.', 40, 33);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (25, 5, 'Mentes Brillantes me inspiró a estudiar ciencias. Increíble producción.', 6, 24);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (26, 4, 'Historia Sin Filtros debería enseñarse en los colegios.', 41, 39);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (27, 1, 'El Último Vuelo tiene muchos clichés del género. Muy predecible.', 43, 1);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (28, 5, 'Vallenato al Alma me recordó mi infancia. Hermoso álbum.', 44, 31);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (29, 4, 'Los Olvidados del Chocó es un grito necesario. Impactante.', 9, 25);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (30, 3, 'Startup Stories es motivador pero muy superficial en los análisis.', 22, 37);

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (31, 5, 'Futuros Posibles es una visión del futuro que asusta y fascina al mismo tiempo.', 15, 15);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (32, 4, 'Arte Callejero muestra un mundo que pocos conocen. Muy revelador.', 28, 28);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (33, 2, 'Risas en Familia tiene humor muy forzado. No me hizo reír.', 32, 5);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (34, 5, 'Sangre y Flores tiene una historia de amor y odio perfectamente equilibrada.', 35, 20);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (35, 4, 'Universo Cuántico explica conceptos complejos de manera accesible. Brillante.', 9, 26);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (36, 3, 'Fútbol y Pasión es interesante pero muy enfocada en Bogotá y Medellín.', 46, 27);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (37, 5, 'Mindfulness en el Caos cambió mi rutina matutina completamente.', 37, 40);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (38, 4, 'Cumbia Eterna es una fiesta de principio a fin.', 39, 29);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (39, 2, 'Rock en Español incluye muy pocas bandas colombianas. Decepcionante.', 21, 32);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (40, 5, 'El Médico Rural es una historia que conmueve y hace reflexionar.', 17, 17);

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (41, 4, 'Ciencia y Vida trae entrevistas con los mejores científicos del país.', 11, 38);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (42, 5, 'El Precio del Poder es crudo, realista y necesario.', 3, 6);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (43, 3, 'Monstruo de las Aguas tiene buenas ideas pero poca profundidad.', 30, 8);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (44, 4, 'Salsa Caleña es el mejor álbum del catálogo para bailar.', 42, 34);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (45, 5, 'Amor en Cartagena es la comedia romántica que Colombia necesitaba.', 7, 2);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (46, 1, 'Corazones Rotos es demasiado lenta y sin sustancia.', 23, 7);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (47, 4, 'Casa Mágica divirtió a toda la familia. Los niños no se querían dormir.', 13, 16);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (48, 5, 'La Última Batalla tiene una épica comparable al cine de Hollywood.', 19, 9);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (49, 3, 'Reggaetón Urbano es un compilado genérico sin mucha personalidad.', 36, 30);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (50, 4, 'Pequeños Héroes llena el vacío que hay de contenido infantil colombiano.', 26, 10);

INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (51, 5, 'Imperio del Sur: la segunda temporada superó a la primera. Obra maestra.', 25, 13);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (52, 2, 'Historia Sin Filtros tiene errores históricos graves.', 18, 39);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (53, 4, 'Amazonas: El Último Pulmón es un llamado urgente a la acción.', 4, 21);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (54, 5, 'Código Rojo: el mejor thriller tecnológico en español.', 48, 18);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (55, 3, 'Ciencia y Vida es interesante pero muy técnico para el público general.', 50, 38);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (56, 4, 'Cafeteros del Quindío me hizo querer visitar el Eje Cafetero.', 46, 22);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (57, 5, 'Los Detectives del Café: original, graciosa y muy bien actuada.', 38, 14);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (58, 1, 'Monstruo de las Aguas: efectos terribles y guion inconsistente.', 43, 8);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (59, 4, 'Piano y Café es el soundtrack perfecto para el trabajo remoto.', 49, 33);
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (60, 5, 'Sin Salida logra un horror genuino sin necesidad de mucha sangre.', 15, 11);


-------------------------------------------------------
-- 15. FAVORITO (40 registros)
-------------------------------------------------------

INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (1, 1, 1, DATE '2024-01-12');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (2, 1, 13, DATE '2024-01-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (3, 1, 21, DATE '2024-02-05');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (4, 2, 2, DATE '2024-01-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (5, 5, 13, DATE '2024-02-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (6, 5, 15, DATE '2024-02-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (7, 8, 21, DATE '2024-03-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (8, 8, 23, DATE '2024-03-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (9, 9, 6, DATE '2024-04-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (10, 10, 4, DATE '2024-04-10');

INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (11, 14, 1, DATE '2024-01-25');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (12, 14, 11, DATE '2024-02-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (13, 15, 9, DATE '2024-03-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (14, 16, 3, DATE '2024-03-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (15, 18, 13, DATE '2024-04-05');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (16, 19, 35, DATE '2024-04-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (17, 25, 13, DATE '2024-01-30');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (18, 25, 22, DATE '2024-02-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (19, 27, 15, DATE '2024-03-05');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (20, 29, 14, DATE '2024-03-25');

INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (21, 31, 18, DATE '2024-04-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (22, 33, 33, DATE '2024-05-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (23, 34, 20, DATE '2024-05-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (24, 35, 17, DATE '2024-06-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (25, 36, 36, DATE '2024-06-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (26, 38, 1, DATE '2024-06-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (27, 38, 14, DATE '2024-07-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (28, 40, 34, DATE '2024-07-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (29, 41, 19, DATE '2024-07-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (30, 43, 13, DATE '2024-08-01');

INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (31, 44, 1, DATE '2024-08-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (32, 45, 22, DATE '2024-10-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (33, 45, 14, DATE '2024-11-05');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (34, 46, 35, DATE '2024-11-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (35, 3, 10, DATE '2024-05-10');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (36, 7, 16, DATE '2024-05-20');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (37, 12, 4, DATE '2024-06-05');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (38, 13, 11, DATE '2024-09-01');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (39, 26, 10, DATE '2024-09-15');
INSERT INTO Favorito (id_favorito, Perfil_id_perfil, contenido_id_contenido, fecha_agregado) VALUES (40, 47, 4, DATE '2024-10-05');


-------------------------------------------------------
-- 16. REPORTE (registros de soporte)
-------------------------------------------------------

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (1, 'El contenido no carga correctamente en televisores Samsung.', DATE '2024-03-15', 'Resuelto', DATE '2024-03-17', 1, 23, 20);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (2, 'El subtítulo en español tiene errores de traducción en varios episodios.', DATE '2024-04-10', 'En revisión', DATE '2024-05-01', 13, 24, 33);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (3, 'Contenido inapropiado para la clasificación +7 indicada. Hay escenas de violencia.', DATE '2024-05-20', 'Pendiente', DATE '2024-06-01', 10, 25, 7);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (4, 'La descripción del documental no corresponde al contenido real del mismo.', DATE '2024-06-01', 'Resuelto', DATE '2024-06-03', 21, 23, 8);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (5, 'El audio del episodio 3 de la temporada 2 está desfasado del video.', DATE '2024-07-15', 'Resuelto', DATE '2024-07-16', 13, 24, 5);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (6, 'El podcast no tiene los créditos correctos de los invitados.', DATE '2024-08-10', 'Desestimado', DATE '2024-08-12', 36, 25, 36);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (7, 'La película aparece como original de QuindioFlix pero no lo es.', DATE '2024-09-05', 'En revisión', DATE '2024-10-01', 9, 23, 25);

INSERT INTO Reporte (id_reporte, motivo, fecha_reporte, estado, fecha_resolucion, contenido_id_contenido, Empleado_id_empleado, Perfil_id_perfil)
VALUES (8, 'El álbum tiene canciones que no corresponden al artista listado.', DATE '2024-10-20', 'Pendiente', DATE '2024-11-15', 29, 24, 44);


-------------------------------------------------------
-- 17. FINALIZACIÓN
-------------------------------------------------------

COMMIT;

-- Fin del script de datos de prueba QuindioFlix




------------------------------------------------------------------
-- Verificación de todas las entidades
------------------------------------------------------------------

------------------------------------------------------------------
-- 1. Verificar Departamentos con su respectivo Jefe
------------------------------------------------------------------

SELECT d.id_departamento, d.nombre AS departamento, e.nombre AS jefe
FROM Departamento d
JOIN Empleado e ON d.Empleado_id_empleado = e.id_empleado;

------------------------------------------------------------------
-- 2. Verificar Empleados y a qué departamento pertenecen
------------------------------------------------------------------

SELECT e.id_empleado, e.nombre, e.cargo, d.nombre AS departamento
FROM Empleado e
JOIN Departamento d ON e.Departamento_id_departamento = d.id_departamento
ORDER BY d.nombre;

------------------------------------------------------------------
-- 3. Verificar Usuarios, sus ciudades y el plan que pagan
------------------------------------------------------------------

SELECT u.nombre, u.ciudad_residencia, p.nombre AS plan, s.estado AS estado_suscripcion
FROM Usuario u
JOIN suscripcion s ON u.id_usuario = s.Usuario_id_usuario
JOIN Plan_suscripcion p ON s.Plan_suscripcion_id_plan = p.id_plan
ORDER BY u.ciudad_residencia;


-------------------------------------------------------------------
-- 4. Verificar todo, ver si las tablas tienen datos
------------------------------------------------------------------

SELECT 'Planes' as tabla, COUNT(*) FROM Plan_suscripcion UNION ALL
SELECT 'Generos', COUNT(*) FROM genero UNION ALL
SELECT 'Departamentos', COUNT(*) FROM Departamento UNION ALL
SELECT 'Empleados', COUNT(*) FROM Empleado UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuario UNION ALL
SELECT 'Suscripciones', COUNT(*) FROM suscripcion UNION ALL
SELECT 'Perfiles', COUNT(*) FROM Perfil UNION ALL
SELECT 'Contenido', COUNT(*) FROM contenido;

------------------------------------------------------------------
-- 5. Verificación de Tipos de Contenido (Herencia)
------------------------------------------------------------------

SELECT tipo_contenido, COUNT(*) as cantidad
FROM contenido
GROUP BY tipo_contenido;

------------------------------------------------------------------
-- 6. Verificar que no haya correos mal formados (sin @)
------------------------------------------------------------------

SELECT nombre, email 
FROM Usuario 
WHERE email NOT LIKE '%@%';


---------------------------------------------------------------------------
-- 7. Verificar que las fechas de vencimiento sean mayores a las de inicio
---------------------------------------------------------------------------

SELECT id_suscripcion, Usuario_id_usuario 
FROM suscripcion 
WHERE fecha_vencimiento <= fecha_inicio;

---------------------------------------------------------------------------
-- 8. Diccionario de datos
---------------------------------------------------------------------------

SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'CONTENIDO' -- Cámbiarlo por la tabla que se quiera revisar (para evitar un script tan extenso)
ORDER BY column_id;



---------------------------------------------------------------------------
-- 9. Verificación de Actividad y Preferencias (Interacción)
---------------------------------------------------------------------------
------------------------------------------------------------------
-- 9.1 Historial de Reproducciones por Perfil
------------------------------------------------------------------
-- Para ver qué está viendo cada perfil y en qué fecha

SELECT 
    p.nombre AS perfil, 
    c.titulo, 
    r.FECHA_INICIO, 
    r.PORCENTAJE_AVANCE || '%' as avance,
    r.DISPOSITIVO
FROM Reproduccion r
JOIN Perfil p ON r.Perfil_id_perfil = p.id_perfil
JOIN contenido c ON r.contenido_id_contenido = c.id_contenido
ORDER BY r.FECHA_INICIO DESC;

------------------------------------------------------------------
-- 9.2 Contenido mejor calificado (Top 5)
------------------------------------------------------------------
-- Para verificar que las calificaciones se están promediando bien

SELECT 
    c.titulo, 
    ROUND(AVG(cal.estrellas), 2) as promedio_estrellas,
    COUNT(cal.id_calificacion) as total_votos
FROM Calificacion cal
JOIN contenido c ON cal.contenido_id_contenido = c.id_contenido
GROUP BY c.titulo
ORDER BY promedio_estrellas DESC;

------------------------------------------------------------------
-- 9.3 Favoritos por Usuario
------------------------------------------------------------------
-- Verifica si la funcionalidad de "Mi Lista" tiene datos
-- Relacionando Usuario -> Perfil -> Favorito -> Contenido

SELECT 
    u.nombre AS usuario_principal, 
    p.nombre AS nombre_perfil, 
    LISTAGG(c.titulo, ' | ') WITHIN GROUP (ORDER BY c.titulo) AS lista_favoritos
FROM Favorito f
JOIN Perfil p ON f.Perfil_id_perfil = p.id_perfil
JOIN Usuario u ON p.Usuario_id_usuario = u.id_usuario
JOIN contenido c ON f.contenido_id_contenido = c.id_contenido
GROUP BY u.nombre, p.nombre;

------------------------------------------------------------------
-- 10. Reportes de fallos y quién los atiende
------------------------------------------------------------------

SELECT 
    rep.id_reporte, 
    rep.motivo, 
    rep.estado, 
    e.nombre AS empleado_asignado
FROM Reporte rep
JOIN Empleado e ON rep.Empleado_id_empleado = e.id_empleado;