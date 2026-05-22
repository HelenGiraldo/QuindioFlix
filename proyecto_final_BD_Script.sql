-------------------------------------------------------------------
-- PROYECTO: QuindioFlix - Sistema de Gestión de Streaming
-- AUTORES: Helen Xiomara Giraldo Libreros y Valentina Porras Salazar
-- FECHA: Mayo 2026
-- DESCRIPCIÓN: Script de creación de objetos (DDL)
-------------------------------------------------------------------
-- Verificammos en qué contenedor estamos
SELECT SYS_CONTEXT('USERENV','CON_NAME') FROM dual;

-- Si dice CDB$ROOT, cambiamos al PDB:
ALTER SESSION SET CONTAINER = XEPDB1;


SELECT table_name
FROM user_tables
ORDER BY table_name;
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
    nombre                       VARCHAR2 (100 CHAR) NOT NULL,
    email                        VARCHAR2 (100 CHAR) NOT NULL,
    cargo                        VARCHAR2 (30 CHAR) NOT NULL,
    id_empleado                  INTEGER  NOT NULL ,
    fecha_contratación           DATE NOT NULL,
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
    creador      VARCHAR2 (100 CHAR),
    cantidad_temporadas  NUMBER (3)  NOT NULL,
    id_contenido INTEGER  NOT NULL
)
;

-- 1.5 Estructura de series y podcasts (temporadas y episodios)
-- -------------------------------------------------------

CREATE TABLE Temporada
(
    id_temporada         INTEGER  NOT NULL ,
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
ALTER TABLE Serie
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

--------------------------------------------------------
-- Correcciones, restricción unique
--------------------------------------------------------

ALTER TABLE CALIFICACION
    ADD CONSTRAINT unq_perfil_contenido_calif UNIQUE (Perfil_id_perfil, Contenido_id_contenido);

ALTER TABLE FAVORITO
    ADD CONSTRAINT unq_perfil_contenido_fav UNIQUE (Perfil_id_perfil, Contenido_id_contenido);


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
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (13, 'Luis Ernesto Fonseca', 3);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (14, 'María Camila Soto', 1);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (15, 'Iván Darío Mejía', 5);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (16, 'Paola Andrea Ríos', 2);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (17, 'Germán Augusto Peña', 4);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (18, 'Daniela Cárdenas', 1);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (19, 'Ricardo Salazar', 2);
INSERT INTO serie (id_contenido, creador, cantidad_temporadas) VALUES (20, 'Natalia Herrera', 6);

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
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (1, 13, 'Imperio del Sur - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (2, 13, 'Imperio del Sur - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (3, 13, 'Imperio del Sur - Temporada 3', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (4, 14, 'Los Detectives del Café - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (5, 14, 'Los Detectives del Café - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (6, 15, 'Futuros Posibles - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (7, 15, 'Futuros Posibles - Temporada 2', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (8, 16, 'Casa Mágica - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (9, 17, 'El Médico Rural - Temporada 1', NULL);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (10, 17, 'El Médico Rural - Temporada 2', NULL);

-- Podcasts
-- Podcasts (Se eliminó el valor de cantidad_temporadas)
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (11, NULL, 'Economía Para Todos - Temporada 1', 35);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (12, NULL, 'Economía Para Todos - Temporada 2', 35);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (13, NULL, 'Crímenes Reales Colombia - Temporada 1', 36);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (14, NULL, 'Historia Sin Filtros - Temporada 1', 39);
INSERT INTO Temporada (id_temporada, serie_id_contenido, titulo, Podcast_id_contenido)
VALUES (15, NULL, 'Mindfulness en el Caos - Temporada 1', 40);

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
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido) VALUES (50, 4, 'Pequeños Héroes llena el vacío que hay de contenido infantil colombiano.', 47, 10);

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


-------------------------------------------------------
-- SECCIÓN 3: ESQUEMA DE ALMACENAMIENTO - QuindioFlix
-- AUTORES: Helen Xiomara Giraldo Libreros
--          Valentina Porras Salazar
-- FECHA: Mayo 2026
-------------------------------------------------------

-------------------------------------------------------
-- 3.2 CREACIÓN DE TABLAS CON ASIGNACIÓN A TABLESPACE
-------------------------------------------------------

-- ============================================================
-- TABLA PARTICIONADA REPRODUCCION
-- Distribución física por fecha usando tablespaces dedicados
-- ============================================================

-- Limpiar tabla temporal si quedó de ejecuciones anteriores

SET SERVEROUTPUT ON;

BEGIN
    EXECUTE IMMEDIATE
    'DROP TABLE Reproduccion_Part CASCADE CONSTRAINTS';

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE Reproduccion_Part
(
    id_reproduccion        INTEGER       NOT NULL,
    fecha_inicio           TIMESTAMP(0)  NOT NULL,
    fecha_fin              TIMESTAMP(0),
    dispositivo            VARCHAR2(12),
    porcentaje_avance      NUMBER(5,2),
    Perfil_id_perfil       INTEGER,
    contenido_id_contenido INTEGER,
    Episodio_id_episodio   INTEGER
)

PARTITION BY RANGE (fecha_inicio)
(
    PARTITION repro_2024
        VALUES LESS THAN
        (TIMESTAMP '2025-01-01 00:00:00')
        TABLESPACE TS_REPRO_2024,

    PARTITION repro_2025
        VALUES LESS THAN
        (TIMESTAMP '2026-01-01 00:00:00')
        TABLESPACE TS_REPRO_2025,

    PARTITION repro_futuro
        VALUES LESS THAN
        (MAXVALUE)
        TABLESPACE TS_TRANSACCIONES
);

-------------------------------------------------------
-- Migrar datos SIN SELECT *
-------------------------------------------------------

INSERT INTO Reproduccion_Part
(
id_reproduccion,
fecha_inicio,
fecha_fin,
dispositivo,
porcentaje_avance,
Perfil_id_perfil,
contenido_id_contenido,
Episodio_id_episodio
)

SELECT
id_reproduccion,
fecha_inicio,
fecha_fin,
dispositivo,
porcentaje_avance,
Perfil_id_perfil,
contenido_id_contenido,
Episodio_id_episodio

FROM Reproduccion;

COMMIT;

-------------------------------------------------------
-- Validaciones
-------------------------------------------------------

SELECT
table_name,
partitioned
FROM user_tables
WHERE table_name='REPRODUCCION_PART';

SELECT
partition_name,
tablespace_name,
high_value
FROM user_tab_partitions
WHERE table_name='REPRODUCCION_PART';

SELECT COUNT(*) total_registros
FROM Reproduccion_Part;

-- ==========================================
-- TABLESPACE: TS_RRHH
-- ==========================================

-- Departamento: estructura organizacional de la empresa.
ALTER TABLE Departamento
    MOVE TABLESPACE TS_RRHH;

-- Empleado: personal de QuindioFlix con jerarquía de supervisión.
ALTER TABLE Empleado
    MOVE TABLESPACE TS_RRHH;


-- ==========================================
-- TABLESPACE: TS_USUARIOS
-- ==========================================

-- Plan_suscripcion: catálogo de planes disponibles (Básico/Estándar/Premium).
ALTER TABLE Plan_suscripcion
    MOVE TABLESPACE TS_USUARIOS;

-- Usuario: titulares de cuenta con datos personales y referidos.

ALTER TABLE Usuario
    MOVE TABLESPACE TS_USUARIOS;

-- Perfil: perfiles de consumo vinculados a un usuario (adulto/infantil).
ALTER TABLE Perfil
    MOVE TABLESPACE TS_USUARIOS;

-- suscripcion: vínculo activo entre un usuario y su plan contratado.
ALTER TABLE suscripcion
    MOVE TABLESPACE TS_USUARIOS;


-- ==========================================
-- TABLESPACE: TS_CATALOGO
-- ==========================================

-- genero: clasificación temática del contenido.

ALTER TABLE genero
    MOVE TABLESPACE TS_CATALOGO;

-- contenido: entidad central del catálogo multimedia.
ALTER TABLE contenido
    MOVE TABLESPACE TS_CATALOGO;

-- tipo_genero: tabla intermedia N:M entre contenido y género.
ALTER TABLE tipo_genero
    MOVE TABLESPACE TS_CATALOGO;

-- pelicula: especialización de contenido para películas.

ALTER TABLE pelicula
    MOVE TABLESPACE TS_CATALOGO;

-- serie: especialización de contenido para series.
ALTER TABLE serie
    MOVE TABLESPACE TS_CATALOGO;

-- documental: especialización de contenido para documentales.

ALTER TABLE documental
    MOVE TABLESPACE TS_CATALOGO;

-- Musica: especialización de contenido para música.

ALTER TABLE Musica
    MOVE TABLESPACE TS_CATALOGO;

-- Podcast: especialización de contenido para podcasts.

ALTER TABLE Podcast
    MOVE TABLESPACE TS_CATALOGO;

-- Temporada: agrupa episodios de una serie o podcast.
ALTER TABLE Temporada
    MOVE TABLESPACE TS_CATALOGO;

-- Episodio: unidad mínima de consumo en series y podcasts.

ALTER TABLE Episodio
    MOVE TABLESPACE TS_CATALOGO;

-- ==========================================
-- TABLESPACE: TS_TRANSACCIONES
-- ==========================================

-- Pago: historial de pagos mensuales de cada suscripción.

ALTER TABLE Pago
    MOVE TABLESPACE TS_TRANSACCIONES;

-- Favorito: lista de contenido marcado como favorito por cada perfil.

ALTER TABLE Favorito
    MOVE TABLESPACE TS_TRANSACCIONES;

-- Calificacion: valoración (1-5 estrellas) y reseña opcional por perfil.

ALTER TABLE Calificacion
    MOVE TABLESPACE TS_TRANSACCIONES;

-- Reporte: incidencias de contenido inapropiado gestionadas por Soporte.

ALTER TABLE Reporte
    MOVE TABLESPACE TS_TRANSACCIONES;

SELECT tablespace_name, status
FROM dba_tablespaces
WHERE tablespace_name LIKE 'TS_%';

SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS contenedor,
       SYS_CONTEXT('USERENV', 'SESSION_USER') AS usuario
FROM dual;

COMMIT;

---------------------------------------------------------
-- 3.3 Prueba del modelo, conteo de registros por tabla
---------------------------------------------------------

SELECT 'Plan_suscripcion' AS tabla, COUNT(*) AS registros FROM Plan_suscripcion UNION ALL
SELECT 'genero',          COUNT(*) FROM genero UNION ALL
SELECT 'Departamento',    COUNT(*) FROM Departamento UNION ALL
SELECT 'Empleado',        COUNT(*) FROM Empleado UNION ALL
SELECT 'Usuario',         COUNT(*) FROM Usuario UNION ALL
SELECT 'suscripcion',     COUNT(*) FROM suscripcion UNION ALL
SELECT 'Perfil',          COUNT(*) FROM Perfil UNION ALL
SELECT 'contenido',       COUNT(*) FROM contenido UNION ALL
SELECT 'pelicula',        COUNT(*) FROM pelicula UNION ALL
SELECT 'serie',           COUNT(*) FROM serie UNION ALL
SELECT 'documental',      COUNT(*) FROM documental UNION ALL
SELECT 'Musica',          COUNT(*) FROM Musica UNION ALL
SELECT 'Podcast',         COUNT(*) FROM Podcast UNION ALL
SELECT 'Temporada',       COUNT(*) FROM Temporada UNION ALL
SELECT 'Episodio',        COUNT(*) FROM Episodio UNION ALL
SELECT 'Pago',            COUNT(*) FROM Pago UNION ALL
SELECT 'Reproduccion',    COUNT(*) FROM Reproduccion UNION ALL
SELECT 'Calificacion',    COUNT(*) FROM Calificacion UNION ALL
SELECT 'Favorito',        COUNT(*) FROM Favorito UNION ALL
SELECT 'tipo_genero',     COUNT(*) FROM tipo_genero UNION ALL
SELECT 'Reporte',         COUNT(*) FROM Reporte;

-----------------------------------------------------------------------------------------------------------
-- Verificar que no haya correos mal formados (sin @) - de nuevo solo para mantener el orden del documento
-----------------------------------------------------------------------------------------------------------

SELECT nombre, email
FROM Usuario
WHERE email NOT LIKE '%@%';

-----------------------------------------------------------------------------------------------------------
-- Verificar fechas de suscripción coherentes - de nuevo solo para mantener el orden del documento
-----------------------------------------------------------------------------------------------------------

SELECT id_suscripcion, Usuario_id_usuario
FROM suscripcion
WHERE fecha_vencimiento <= fecha_inicio;

-----------------------------------------------------------------------------------------------------------
-- Verificar tipos de contenido registrados
-----------------------------------------------------------------------------------------------------------

SELECT tipo_contenido, COUNT(*) AS cantidad
FROM contenido
GROUP BY tipo_contenido
ORDER BY cantidad DESC;

-----------------------------------------------------------------------
-- PROYECTO  : QuindioFlix - Sistema de Gestión de Streaming
-- AUTORES   : Helen Xiomara Giraldo Libreros
--             Valentina Porras Salazar
-- FECHA     : Mayo 2026
-- SECCIÓN   : 4. ANÁLISIS DE VISTAS (CRUD)
--
-- OBJETIVO
-- Implementar vistas para:
--   • Ocultar información sensible
--   • Simplificar consultas complejas
--   • Aplicar principio de mínimo privilegio
--
-- CARACTERÍSTICAS
--   • Reejecutable
--   • Idempotente
--   • Reporta acciones
--   • Manejo controlado de errores
-----------------------------------------------------------------------

SET SERVEROUTPUT ON;

-----------------------------------------------------------------------
-- PASO 0 — LIMPIEZA CONTROLADA
-----------------------------------------------------------------------

DECLARE

PROCEDURE drop_view_if_exists
(
    p_view VARCHAR2
)

IS

BEGIN

EXECUTE IMMEDIATE
'DROP VIEW '||p_view;

DBMS_OUTPUT.PUT_LINE(
'✓ Vista eliminada: '||p_view
);

EXCEPTION

WHEN OTHERS THEN

CASE

WHEN SQLCODE=-942 THEN

DBMS_OUTPUT.PUT_LINE(
'→ Vista inexistente: '||p_view
);

ELSE

RAISE_APPLICATION_ERROR
(
-20001,
'Error eliminando '
||p_view
||' → '
||SQLERRM
);

END CASE;

END;

BEGIN

drop_view_if_exists('VW_CATALOGO_PUBLICO');
drop_view_if_exists('VW_USUARIO_SEGURO');
drop_view_if_exists('VW_REPORTE_SUSCRIPCIONES');
drop_view_if_exists('VW_HISTORIAL_REPRODUCCIONES');
drop_view_if_exists('VW_REPORTE_PAGOS');

END;
/

-----------------------------------------------------------------------
-- PASO 1 — VW_CATALOGO_PUBLICO
--
-- Oculta columnas técnicas del catálogo
-----------------------------------------------------------------------

BEGIN

EXECUTE IMMEDIATE q'[

CREATE OR REPLACE VIEW VW_CATALOGO_PUBLICO AS

SELECT

c.titulo,
c.tipo_contenido,
c.anio_lanzamiento,
c.duracion,
c.sinopsis,
c.clasificacion_edad,
c.fecha_agregado,

CASE

WHEN c.es_original='S'
THEN 'Original QuindioFlix'

ELSE 'Contenido externo'

END origen,

(
SELECT
LISTAGG(
g.nombre,
', '
)
WITHIN GROUP
(
ORDER BY g.nombre
)

FROM tipo_genero tg

JOIN genero g

ON tg.genero_id_genero=
g.id_genero

WHERE
tg.contenido_id_contenido=
c.id_contenido

)

AS generos

FROM contenido c

WHERE c.tipo_contenido IN
(
'PELICULA',
'SERIE',
'DOCUMENTAL',
'MUSICA',
'PODCAST'
)

]';

DBMS_OUTPUT.PUT_LINE(
'✓ VW_CATALOGO_PUBLICO creada'
);

EXCEPTION

WHEN OTHERS THEN

RAISE_APPLICATION_ERROR
(
-20002,
'Error creando VW_CATALOGO_PUBLICO → '
||SQLERRM
);

END;
/

GRANT SELECT
ON VW_CATALOGO_PUBLICO
TO ROL_ANALISTA;

GRANT SELECT
ON VW_CATALOGO_PUBLICO
TO ROL_CONTENIDO;

-----------------------------------------------------------------------
-- PASO 2 — VW_USUARIO_SEGURO
--
-- Enmascara información sensible
-----------------------------------------------------------------------

BEGIN

EXECUTE IMMEDIATE q'[

CREATE OR REPLACE VIEW
VW_USUARIO_SEGURO

AS

SELECT

u.id_usuario,

u.nombre,

SUBSTR(
u.email,
1,
3
)
||
'***@'
||
SUBSTR
(
u.email,
INSTR(
u.email,
'@'
)+1
)

AS email_parcial,

'***-***-'
||
SUBSTR(
u.telefono,
-4
)

AS telefono_parcial,

u.ciudad_residencia,

u.estado_cuenta_activa,

FLOOR
(
MONTHS_BETWEEN
(
SYSDATE,
u.fecha_nacimiento
)
/12
)

AS edad

FROM Usuario u

]';

DBMS_OUTPUT.PUT_LINE(
'✓ VW_USUARIO_SEGURO creada'
);

EXCEPTION

WHEN OTHERS THEN

RAISE_APPLICATION_ERROR
(
-20003,
'Error creando VW_USUARIO_SEGURO → '
||SQLERRM
);

END;
/

GRANT SELECT
ON VW_USUARIO_SEGURO
TO ROL_ANALISTA;

GRANT SELECT
ON VW_USUARIO_SEGURO
TO ROL_SOPORTE;

-----------------------------------------------------------------------
-- PASO 3 — VW_REPORTE_SUSCRIPCIONES
-----------------------------------------------------------------------

BEGIN

EXECUTE IMMEDIATE q'[

CREATE OR REPLACE VIEW
VW_REPORTE_SUSCRIPCIONES

AS

SELECT

u.nombre usuario,

ps.nombre plan,

s.fecha_inicio,

s.fecha_vencimiento,

s.estado,

TRUNC
(
s.fecha_vencimiento
-
SYSDATE
)

AS dias_para_vencer

FROM Usuario u

JOIN suscripcion s

ON
s.Usuario_id_usuario=
u.id_usuario

JOIN Plan_suscripcion ps

ON
ps.id_plan=
s.Plan_suscripcion_id_plan

WHERE
s.estado='Activa'

]';

DBMS_OUTPUT.PUT_LINE(
'✓ VW_REPORTE_SUSCRIPCIONES creada'
);

EXCEPTION

WHEN OTHERS THEN

RAISE_APPLICATION_ERROR
(
-20004,
'Error creando VW_REPORTE_SUSCRIPCIONES → '
||SQLERRM
);

END;
/

GRANT SELECT
ON VW_REPORTE_SUSCRIPCIONES
TO ROL_ANALISTA;

GRANT SELECT
ON VW_REPORTE_SUSCRIPCIONES
TO ROL_SOPORTE;

-----------------------------------------------------------------------
-- PASO 4 — VW_HISTORIAL_REPRODUCCIONES
-----------------------------------------------------------------------

BEGIN

EXECUTE IMMEDIATE q'[

CREATE OR REPLACE VIEW
VW_HISTORIAL_REPRODUCCIONES

AS

SELECT

u.nombre usuario,

p.nombre perfil,

c.titulo contenido,

r.dispositivo,

r.fecha_inicio,

r.fecha_fin,

r.porcentaje_avance

FROM Reproduccion r

JOIN Perfil p
ON r.Perfil_id_perfil=
p.id_perfil

JOIN Usuario u
ON p.Usuario_id_usuario=
u.id_usuario

JOIN contenido c
ON r.contenido_id_contenido=
c.id_contenido

]';

DBMS_OUTPUT.PUT_LINE(
'✓ VW_HISTORIAL_REPRODUCCIONES creada'
);

EXCEPTION

WHEN OTHERS THEN

RAISE_APPLICATION_ERROR
(
-20005,
'Error creando VW_HISTORIAL_REPRODUCCIONES → '
||SQLERRM
);

END;
/

GRANT SELECT
ON VW_HISTORIAL_REPRODUCCIONES
TO ROL_ANALISTA;

GRANT SELECT
ON VW_HISTORIAL_REPRODUCCIONES
TO ROL_CONTENIDO;

-----------------------------------------------------------------------
-- PASO 5 — VW_REPORTE_PAGOS
-----------------------------------------------------------------------

BEGIN

EXECUTE IMMEDIATE q'[

CREATE OR REPLACE VIEW
VW_REPORTE_PAGOS

AS

SELECT

u.nombre,

ps.nombre plan,

p.fecha_pago,

p.monto,

NVL
(
p.valor_descuento,
0
)

AS descuento,

p.estado_pago

FROM Pago p

JOIN suscripcion s

ON
p.suscripcion_id_suscripcion=
s.id_suscripcion

JOIN Usuario u

ON
s.Usuario_id_usuario=
u.id_usuario

JOIN Plan_suscripcion ps

ON
s.Plan_suscripcion_id_plan=
ps.id_plan

]';

DBMS_OUTPUT.PUT_LINE(
'✓ VW_REPORTE_PAGOS creada'
);

EXCEPTION

WHEN OTHERS THEN

RAISE_APPLICATION_ERROR
(
-20006,
'Error creando VW_REPORTE_PAGOS → '
||SQLERRM
);

END;
/

GRANT SELECT
ON VW_REPORTE_PAGOS
TO ROL_ANALISTA;

-----------------------------------------------------------------------
-- PASO 6 — VERIFICACIÓN
-----------------------------------------------------------------------

PROMPT ===== VISTAS CREADAS =====

SELECT
view_name
FROM user_views
WHERE view_name LIKE 'VW_%'
ORDER BY view_name;

PROMPT ===== PRIVILEGIOS =====

SELECT
table_name,
grantee,
privilege
FROM dba_tab_privs
WHERE table_name LIKE 'VW_%'
ORDER BY
table_name,
grantee;

COMMIT;



--====================================================================
-- SECCIÓN   : 4.3.1.4  Vistas Materializadas
-- MOTOR     : Oracle Database (SQL*Plus / SQL Developer)
--====================================================================
-----------------------------------------------------------------------
-- DESCRIPCIÓN GENERAL
-- Las vistas materializadas (Materialized Views) almacenan físicamente
-- el resultado de una consulta compleja. A diferencia de las vistas
-- normales, no se recalculan en cada consulta sino que leen datos ya
-- precalculados, reduciendo drásticamente el tiempo de respuesta en
-- reportes analíticos de alto costo computacional.
--
-- Todas las vistas usan:
--   BUILD IMMEDIATE   → se populan al momento de su creación.
--   REFRESH COMPLETE  → en cada refresco se descarta y recalcula todo.
--   ON DEMAND         → el refresco se ejecuta manualmente o con el
--                       scheduler; no hay overhead en cada DML.
-- Se incluye también un JOB de Oracle Scheduler que las refresca
-- automáticamente cada noche a las 02:00 am.
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- LIMPIEZA PREVIA (ejecutar si ya existen versiones anteriores)
-----------------------------------------------------------------------


BEGIN
EXECUTE IMMEDIATE
    'DROP MATERIALIZED VIEW MV_POPULARIDAD_CONTENIDO';
EXCEPTION
WHEN OTHERS THEN NULL;
END;
/

BEGIN
EXECUTE IMMEDIATE
    'DROP MATERIALIZED VIEW MV_INGRESOS_MENSUALES';
EXCEPTION
WHEN OTHERS THEN NULL;
END;
/

BEGIN
EXECUTE IMMEDIATE
    'DROP MATERIALIZED VIEW MV_RENDIMIENTO_EMPLEADOS';
EXCEPTION
WHEN OTHERS THEN NULL;
END;
/

BEGIN
EXECUTE IMMEDIATE
    'DROP MATERIALIZED VIEW MV_CONSUMO_DISPOSITIVO';
EXCEPTION
WHEN OTHERS THEN NULL;
END;
/


-----------------------------------------------------------------------
-- MV 1 — MV_POPULARIDAD_CONTENIDO
-- Base para el reporte: "Contenido Más Popular"
--
-- JUSTIFICACIÓN:
-- El reporte de popularidad debe cruzar tres tablas de alto volumen
-- (Reproduccion: 200+ filas, Calificacion: 60+ filas, Favorito: 40+
-- filas) contra la tabla contenido. Sin precálculo, cada consulta del
-- dashboard gerencial realiza tres full-scans y tres JOINs. Con la
-- vista materializada, el resultado (una fila por contenido) ya está
-- listo y la consulta de reporte es instantánea.
--
-- COLUMNAS PRECALCULADAS:
--   total_reproducciones  → veces que el contenido fue reproducido
--   perfiles_unicos       → cuántos perfiles distintos lo vieron
--   calificacion_promedio → media de estrellas (1-5)
--   total_calificaciones  → cantidad de reseñas recibidas
--   total_favoritos       → cuántos perfiles lo marcaron como favorito
--   promedio_avance_pct   → % promedio de reproducción completada
--   score_popularidad     → índice combinado para ranking rápido
-----------------------------------------------------------------------

CREATE MATERIALIZED VIEW MV_POPULARIDAD_CONTENIDO
    BUILD IMMEDIATE
    REFRESH COMPLETE ON DEMAND
AS
SELECT
    c.id_contenido,
    c.titulo,
    c.tipo_contenido,
    c.clasificacion_edad,
    c.anio_lanzamiento,
    c.es_original,

    -- Métricas de reproducción
    COUNT(DISTINCT r.id_reproduccion) AS total_reproducciones,
    COUNT(DISTINCT r.Perfil_id_perfil) AS perfiles_unicos,
    ROUND(AVG(r.porcentaje_avance), 2)  AS promedio_avance_pct,

    -- Métricas de calificación
    ROUND(AVG(cal.estrellas), 2)   AS calificacion_promedio,
    COUNT(DISTINCT cal.id_calificacion)  AS total_calificaciones,

    -- Favoritos
    COUNT(DISTINCT f.id_favorito) AS total_favoritos,

    -- Score combinado de popularidad:
    -- (reproducciones * 1) + (favoritos * 2) + (calificacion * 10)
    -- Ponderación: favoritos y calificaciones tienen más peso porque
    -- son acciones intencionales del usuario.
    ROUND(
            NVL(COUNT(DISTINCT r.id_reproduccion), 0) * 1 +
            NVL(COUNT(DISTINCT f.id_favorito), 0) * 2 +
            NVL(AVG(cal.estrellas), 0) * 10,2) AS score_popularidad

FROM contenido c
         LEFT JOIN Reproduccion r   ON c.id_contenido = r.contenido_id_contenido
         LEFT JOIN Calificacion cal ON c.id_contenido = cal.contenido_id_contenido
         LEFT JOIN Favorito     f   ON c.id_contenido = f.contenido_id_contenido

GROUP BY
    c.id_contenido,
    c.titulo,
    c.tipo_contenido,
    c.clasificacion_edad,
    c.anio_lanzamiento,
    c.es_original;

-- Índice sobre la MV para acelerar ordenamientos por popularidad
CREATE INDEX IDX_MV_POP_SCORE ON MV_POPULARIDAD_CONTENIDO (score_popularidad DESC);
CREATE INDEX IDX_MV_POP_TIPO  ON MV_POPULARIDAD_CONTENIDO (tipo_contenido);

-- ---- Verificación / consulta de uso --------------------------------
-- Top 10 contenidos más populares de toda la plataforma:
SELECT titulo, tipo_contenido, total_reproducciones,
       calificacion_promedio, total_favoritos, score_popularidad
FROM   MV_POPULARIDAD_CONTENIDO
ORDER  BY score_popularidad DESC
    FETCH  FIRST 10 ROWS ONLY;

-- Top 5 películas con mejor calificación:
SELECT titulo, calificacion_promedio, total_calificaciones,
       total_reproducciones
FROM   MV_POPULARIDAD_CONTENIDO
WHERE  tipo_contenido    = 'PELICULA'
  AND  total_calificaciones > 0
ORDER  BY calificacion_promedio DESC, total_reproducciones DESC
    FETCH  FIRST 5 ROWS ONLY;


-----------------------------------------------------------------------
-- MV 2 — MV_INGRESOS_MENSUALES
-- Base para el reporte: "Reporte Financiero Mensual"
--
-- JUSTIFICACIÓN:
-- El área de Finanzas consulta diariamente los ingresos agrupados por
-- ciudad y plan. Sin precálculo, la consulta une Pago, suscripcion,
-- Usuario y Plan_suscripcion, filtra por estado_pago = 'Exitoso' y
-- aplica GROUP BY con cuatro niveles. Con 80+ pagos actuales (y
-- crecimiento mensual), este costo crece con el tiempo. La MV reduce
-- la consulta del reporte financiero a un simple SELECT sobre una
-- tabla ya agregada por año/mes/ciudad/plan.
--
-- COLUMNAS PRECALCULADAS:
--   anio, mes              → período del pago
--   ciudad_residencia      → ciudad del titular de la cuenta
--   plan, calidad          → plan y calidad de video contratado
--   costo_plan             → precio oficial del plan (sin descuento)
--   total_pagos_exitosos   → conteo de pagos en estado 'Exitoso'
--   ingreso_bruto          → suma de montos antes de descontar
--   total_descuentos       → suma de todos los descuentos aplicados
--   ingreso_neto           → ingreso real recibido (bruto - desc.)
--   usuarios_facturados    → usuarios únicos con pago exitoso
--   pagos_fallidos         → cantidad de pagos fallidos en el período
--   pagos_pendientes       → pagos aún pendientes de cobro
-----------------------------------------------------------------------

CREATE MATERIALIZED VIEW MV_INGRESOS_MENSUALES
    BUILD IMMEDIATE
    REFRESH COMPLETE ON DEMAND
AS
SELECT
    EXTRACT(YEAR  FROM p.fecha_pago)           AS anio,
    EXTRACT(MONTH FROM p.fecha_pago)           AS mes,
    TO_CHAR(p.fecha_pago, 'MM/YYYY')           AS periodo,
    u.ciudad_residencia,
    ps.nombre                                  AS plan,
    ps.calidad,
    ps.costo                                   AS costo_plan,

    -- Pagos exitosos
    COUNT(CASE WHEN p.estado_pago = 'Exitoso'
        THEN p.id_pago END) AS total_pagos_exitosos,

    SUM(CASE WHEN p.estado_pago = 'Exitoso'
        THEN p.monto       ELSE 0 END) AS ingreso_bruto,

    SUM(CASE WHEN p.estado_pago = 'Exitoso'
        THEN NVL(p.valor_descuento, 0)
        ELSE 0 END) AS total_descuentos,

    SUM(CASE WHEN p.estado_pago = 'Exitoso'
        THEN p.monto - NVL(p.valor_descuento, 0)
        ELSE 0 END) AS ingreso_neto,

    COUNT(DISTINCT CASE WHEN p.estado_pago = 'Exitoso'THEN u.id_usuario END) AS usuarios_facturados,

    -- Pagos no exitosos (útil para reportes de morosidad)
    COUNT(CASE WHEN p.estado_pago = 'Fallido'
        THEN p.id_pago END)             AS pagos_fallidos,

    COUNT(CASE WHEN p.estado_pago = 'Pendiente'
        THEN p.id_pago END)             AS pagos_pendientes,

    COUNT(CASE WHEN p.estado_pago = 'Reembolsado'
        THEN p.id_pago END)             AS pagos_reembolsados

FROM Pago p
JOIN suscripcion    s   ON p.suscripcion_id_suscripcion = s.id_suscripcion
JOIN Usuario        u   ON s.Usuario_id_usuario          = u.id_usuario
JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan   = ps.id_plan

GROUP BY
    EXTRACT(YEAR  FROM p.fecha_pago),
    EXTRACT(MONTH FROM p.fecha_pago),
    TO_CHAR(p.fecha_pago, 'MM/YYYY'),
    u.ciudad_residencia,
    ps.nombre,
    ps.calidad,
    ps.costo;

-- Índices para consultas financieras frecuentes
CREATE INDEX IDX_MV_ING_PERIODO ON MV_INGRESOS_MENSUALES (anio, mes);
CREATE INDEX IDX_MV_ING_CIUDAD  ON MV_INGRESOS_MENSUALES (ciudad_residencia);
CREATE INDEX IDX_MV_ING_PLAN    ON MV_INGRESOS_MENSUALES (plan);

-- ---- Verificación / consulta de uso --------------------------------
-- Ingresos netos totales por ciudad en todos los períodos:

SELECT ciudad_residencia,
       SUM(ingreso_neto) AS ingreso_neto_total,
       SUM(total_pagos_exitosos) AS pagos_realizados
FROM   MV_INGRESOS_MENSUALES
GROUP  BY ciudad_residencia
ORDER  BY ingreso_neto_total DESC;

-- Ingresos mensuales por plan (tabla resumen financiera):
SELECT periodo, plan, ingreso_neto, usuarios_facturados,
       pagos_fallidos, pagos_pendientes
FROM   MV_INGRESOS_MENSUALES
ORDER  BY anio, mes, ingreso_neto DESC;

-- Comparativo ciudad × plan usando la MV como fuente del PIVOT
-- (mucho más rápido que hacer el PIVOT sobre las tablas base):
SELECT *
FROM (
SELECT ciudad_residencia, plan, ingreso_neto
FROM   MV_INGRESOS_MENSUALES
     )
PIVOT (
SUM(ingreso_neto)
FOR plan IN (
'Básico'   AS "BASICO",
'Estandar' AS "ESTANDAR",
'Premium'  AS "PREMIUM"
    )
        )
ORDER BY ciudad_residencia;


-----------------------------------------------------------------------
-- MV 3 — MV_RENDIMIENTO_EMPLEADOS
-- Base para el reporte: "Rendimiento del Equipo de Trabajo"
--
-- JUSTIFICACIÓN:
-- La gerencia necesita evaluar periódicamente cuánto contenido ha
-- publicado cada empleado del área de Contenido y cuántos reportes ha
-- resuelto cada moderador de Soporte. Estas métricas cruzan Empleado,
-- contenido, Reporte y Departamento. La MV las entrega listas, sin
-- que el sistema recalcule los JOINs en cada consulta gerencial.
--
-- COLUMNAS PRECALCULADAS:
--   contenido_publicado   → títulos bajo su responsabilidad
--   reportes_asignados    → reportes recibidos como moderador
--   reportes_resueltos    → reportes con estado 'Resuelto'
--   reportes_pendientes   → reportes aún sin resolver
--   tasa_resolucion_pct   → % de resolución (eficiencia)
-----------------------------------------------------------------------

CREATE MATERIALIZED VIEW MV_RENDIMIENTO_EMPLEADOS
    BUILD IMMEDIATE
    REFRESH COMPLETE ON DEMAND
AS
SELECT
    e.id_empleado,
    e.nombre AS empleado,
    e.cargo,
    d.nombre AS departamento,

-- Contenido que publicó (solo aplica a dpto. Contenido)
COUNT(DISTINCT c.id_contenido) AS contenido_publicado,

 -- Gestión de reportes como moderador (solo dpto. Soporte)
COUNT(DISTINCT rep.id_reporte) AS reportes_asignados,

COUNT(DISTINCT CASE WHEN rep.estado = 'Resuelto'
THEN rep.id_reporte END) AS reportes_resueltos,

 COUNT(DISTINCT CASE WHEN rep.estado = 'Pendiente'
THEN rep.id_reporte END) AS reportes_pendientes,

COUNT(DISTINCT CASE WHEN rep.estado = 'En revisión'
THEN rep.id_reporte END) AS reportes_en_revision,

 -- Tasa de resolución: 0 si no tiene reportes asignados
CASE
WHEN COUNT(DISTINCT rep.id_reporte) = 0 THEN NULL
ELSE ROUND(
COUNT(DISTINCT CASE WHEN rep.estado = 'Resuelto'
THEN rep.id_reporte END)
/ COUNT(DISTINCT rep.id_reporte) * 100, 2)
END AS tasa_resolucion_pct

FROM Empleado     e
JOIN Departamento d   ON e.Departamento_id_departamento = d.id_departamento
LEFT JOIN contenido c ON e.id_empleado = c.Empleado_id_empleado
LEFT JOIN Reporte rep ON e.id_empleado = rep.Empleado_id_empleado

GROUP BY
    e.id_empleado,
    e.nombre,
    e.cargo,
    d.nombre;

-- ---- Verificación / consulta de uso --------------------------------
-- Ranking de empleados de Contenido por títulos publicados:

SELECT empleado, cargo, contenido_publicado
FROM   MV_RENDIMIENTO_EMPLEADOS
WHERE  departamento = 'Contenido'
ORDER  BY contenido_publicado DESC;

-- Ranking de moderadores por tasa de resolución:
SELECT empleado, reportes_asignados, reportes_resueltos,
       reportes_pendientes, tasa_resolucion_pct
FROM   MV_RENDIMIENTO_EMPLEADOS
WHERE  departamento    = 'Soporte'
  AND  reportes_asignados > 0
ORDER  BY tasa_resolucion_pct DESC NULLS LAST;


-----------------------------------------------------------------------
-- MV 4 — MV_CONSUMO_DISPOSITIVO
-- Base para el reporte: "Consumo por Dispositivo y Categoría"
--
-- JUSTIFICACIÓN:
-- El área de Tecnología y Marketing necesita entender desde qué
-- dispositivos se consume cada tipo de contenido y en qué ciudades.
-- Esta agregación sobre Reproduccion (200+ filas, de alto crecimiento)
-- cruzada con Perfil, Usuario y contenido es costosa si se recalcula
-- en tiempo real. La MV la sirve precalculada para dashboards y
-- reportes de uso de plataforma.
--
-- COLUMNAS PRECALCULADAS:
--   dispositivo          → Celular / Tablet / TV / Computador
--   tipo_contenido       → PELICULA / SERIE / DOCUMENTAL / etc.
--   ciudad_residencia    → ciudad del usuario que reprodujo
--   total_reproducciones → conteo de sesiones
--   perfiles_unicos      → alcance (usuarios únicos por dispositivo)
--   promedio_avance_pct  → completitud promedio por dispositivo
--   reproducciones_completas → sesiones con avance >= 90 %
-----------------------------------------------------------------------

CREATE MATERIALIZED VIEW MV_CONSUMO_DISPOSITIVO
    BUILD IMMEDIATE
    REFRESH COMPLETE ON DEMAND
AS
SELECT
    r.dispositivo,
    c.tipo_contenido,
    u.ciudad_residencia,

    COUNT(r.id_reproduccion) AS total_reproducciones,
    COUNT(DISTINCT r.Perfil_id_perfil) AS perfiles_unicos,
    ROUND(AVG(r.porcentaje_avance), 2) AS promedio_avance_pct,

    -- Reproducciones prácticamente completadas (≥ 90 %)
    COUNT(CASE WHEN r.porcentaje_avance >= 90
 THEN r.id_reproduccion END) AS reproducciones_completas,

    -- Reproducciones abandonadas temprano (< 25 %)
    COUNT(CASE WHEN r.porcentaje_avance < 25
 THEN r.id_reproduccion END) AS reproducciones_abandonadas,

    ROUND(
COUNT(CASE WHEN r.porcentaje_avance >= 90
THEN r.id_reproduccion END)
/ NULLIF(COUNT(r.id_reproduccion), 0) * 100, 2) AS tasa_completitud_pct

FROM Reproduccion r
         JOIN Perfil    p ON r.Perfil_id_perfil       = p.id_perfil
         JOIN Usuario   u ON p.Usuario_id_usuario     = u.id_usuario
         JOIN contenido c ON r.contenido_id_contenido = c.id_contenido

GROUP BY
    r.dispositivo,
    c.tipo_contenido,
    u.ciudad_residencia;

-- Índice para filtros frecuentes por dispositivo o ciudad
CREATE INDEX IDX_MV_CD_DISP   ON MV_CONSUMO_DISPOSITIVO (dispositivo);
CREATE INDEX IDX_MV_CD_CIUDAD ON MV_CONSUMO_DISPOSITIVO (ciudad_residencia);

-- ---- Verificación / consulta de uso --------------------------------
-- Distribución de reproducciones por dispositivo (global):

SELECT dispositivo,
       SUM(total_reproducciones)   AS total,
       ROUND(AVG(promedio_avance_pct), 2) AS avance_promedio,
       SUM(reproducciones_completas)      AS completadas
FROM   MV_CONSUMO_DISPOSITIVO
GROUP  BY dispositivo
ORDER  BY total DESC;

-- ¿Desde qué dispositivo se ven más series en Bogotá?
SELECT dispositivo, total_reproducciones, tasa_completitud_pct
FROM   MV_CONSUMO_DISPOSITIVO
WHERE  tipo_contenido    = 'SERIE'
  AND  ciudad_residencia = 'Bogotá'
ORDER  BY total_reproducciones DESC;


-----------------------------------------------------------------------
-- REFRESCO MANUAL DE TODAS LAS VISTAS MATERIALIZADAS
-- Ejecutar después de cargas masivas de datos o al inicio del día.
-----------------------------------------------------------------------

BEGIN
    DBMS_MVIEW.REFRESH('MV_POPULARIDAD_CONTENIDO',  'C');
    DBMS_MVIEW.REFRESH('MV_INGRESOS_MENSUALES',      'C');
    DBMS_MVIEW.REFRESH('MV_RENDIMIENTO_EMPLEADOS',   'C');
    DBMS_MVIEW.REFRESH('MV_CONSUMO_DISPOSITIVO',     'C');
    DBMS_OUTPUT.PUT_LINE('✓ Todas las vistas materializadas fueron refrescadas.');
END;
/


-----------------------------------------------------------------------
-- JOB AUTOMÁTICO CON ORACLE SCHEDULER
-- Refresca las cuatro MVs cada día a las 02:00 am (hora de menor
-- actividad), garantizando que los reportes del día usen datos
-- actualizados sin impacto en el horario pico de la plataforma.
-----------------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_REFRESH_MVS_QUINDIOFLIX',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            BEGIN
                DBMS_MVIEW.REFRESH(''MV_POPULARIDAD_CONTENIDO'',  ''C'');
                DBMS_MVIEW.REFRESH(''MV_INGRESOS_MENSUALES'',      ''C'');
                DBMS_MVIEW.REFRESH(''MV_RENDIMIENTO_EMPLEADOS'',   ''C'');
                DBMS_MVIEW.REFRESH(''MV_CONSUMO_DISPOSITIVO'',     ''C'');
            END;',
        start_date      => TRUNC(SYSDATE + 1) + 2/24,
        repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Refresco nocturno diario de todas las MVs de QuindioFlix'
    );
    DBMS_OUTPUT.PUT_LINE('✓ Job de refresco automático creado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -27477 THEN
            DBMS_OUTPUT.PUT_LINE('⚠ El job JOB_REFRESH_MVS_QUINDIOFLIX ya existe, no se creó de nuevo.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Verificar que el job quedó activo
SELECT job_name, state, last_run_duration, next_run_date
FROM   user_scheduler_jobs
WHERE  job_name = 'JOB_REFRESH_MVS_QUINDIOFLIX';

-----------------------------------------------------------------------
-- VERIFICACIÓN DE CREACIÓN DE VISTAS MATERIALIZADAS
-- Permite validar que todas quedaron creadas correctamente.
-----------------------------------------------------------------------

SELECT
    mview_name,
    refresh_mode,
    refresh_method,
    staleness,
    compile_state,
    last_refresh_type
FROM user_mviews
ORDER BY mview_name;

-----------------------------------------------------------------------
-- VERIFICACIÓN DE REGISTROS MATERIALIZADOS
-- Cantidad de filas almacenadas físicamente en cada MV.
-----------------------------------------------------------------------

SELECT 'MV_POPULARIDAD_CONTENIDO' AS vista, COUNT(*) AS registros FROM MV_POPULARIDAD_CONTENIDO UNION ALL

SELECT 'MV_INGRESOS_MENSUALES', COUNT(*) FROM MV_INGRESOS_MENSUALES UNION ALL

SELECT 'MV_RENDIMIENTO_EMPLEADOS', COUNT(*) FROM MV_RENDIMIENTO_EMPLEADOS UNION ALL

SELECT 'MV_CONSUMO_DISPOSITIVO', COUNT(*) FROM MV_CONSUMO_DISPOSITIVO;

-----------------------------------------------------------------------
-- VERIFICACIÓN DE ÍNDICES CREADOS SOBRE LAS MVs
-----------------------------------------------------------------------

SELECT
    index_name,
    table_name,
    status
FROM user_indexes
WHERE table_name IN (
'MV_POPULARIDAD_CONTENIDO',
'MV_INGRESOS_MENSUALES',
'MV_CONSUMO_DISPOSITIVO'
    )
ORDER BY table_name;


COMMIT;

-----------------------------------------------------------------------
-- SECCIÓN 3.5 — NÚCLEO 5
-- ADMINISTRACIÓN DE ACCESO A BASE DE DATOS
--
-- PROYECTO: QUINDIOFLIX
--
-- IMPLEMENTA:
--   • Roles
--   • Privilegios de sistema
--   • Privilegios de objeto
--   • Usuarios Oracle
--
-- CARACTERÍSTICAS
--   • Reejecutable
--   • Idempotente
--   • Reporta acciones
--   • No oculta errores inesperados
-----------------------------------------------------------------------

SET SERVEROUTPUT ON;

-----------------------------------------------------------------------
-- PASO 0 — LIMPIEZA DE USUARIOS
-----------------------------------------------------------------------

DECLARE

PROCEDURE drop_user_if_exists
(
    p_user VARCHAR2
)
IS
BEGIN

    EXECUTE IMMEDIATE
    'DROP USER '||p_user||' CASCADE';

    DBMS_OUTPUT.PUT_LINE(
        '✓ Eliminado usuario '||p_user
    );

EXCEPTION

WHEN OTHERS THEN

    IF SQLCODE=-1918 THEN

        DBMS_OUTPUT.PUT_LINE(
            '→ Usuario inexistente '||p_user
        );

    ELSE
        RAISE;
    END IF;

END;

BEGIN

drop_user_if_exists('USR_ADMIN_QF');
drop_user_if_exists('USR_ANALISTA_QF');
drop_user_if_exists('USR_SOPORTE_QF');
drop_user_if_exists('USR_CONTENIDO_QF');

END;
/

-----------------------------------------------------------------------
-- PASO 1 — CREACIÓN DE ROLES
-----------------------------------------------------------------------

DECLARE

PROCEDURE create_role_if_missing
(
    p_role VARCHAR2
)
IS

v_count NUMBER;

BEGIN

SELECT COUNT(*)
INTO v_count
FROM dba_roles
WHERE role=p_role;

IF v_count=0 THEN

EXECUTE IMMEDIATE
'CREATE ROLE '||p_role||' NOT IDENTIFIED';

DBMS_OUTPUT.PUT_LINE(
'✓ Rol creado '||p_role
);

ELSE

DBMS_OUTPUT.PUT_LINE(
'→ Rol existente '||p_role
);

END IF;

END;

BEGIN

create_role_if_missing('ROL_ADMIN');
create_role_if_missing('ROL_ANALISTA');
create_role_if_missing('ROL_SOPORTE');
create_role_if_missing('ROL_CONTENIDO');

END;
/

-----------------------------------------------------------------------
-- PASO 2 — PRIVILEGIOS DE SISTEMA
-----------------------------------------------------------------------

PROMPT ===== PRIVILEGIOS SISTEMA =====

GRANT CREATE SESSION TO ROL_ADMIN;

GRANT CREATE USER TO ROL_ADMIN;
GRANT DROP USER TO ROL_ADMIN;
GRANT ALTER USER TO ROL_ADMIN;

GRANT CREATE ROLE TO ROL_ADMIN;

GRANT CREATE ANY TABLE TO ROL_ADMIN;
GRANT DROP ANY TABLE TO ROL_ADMIN;

GRANT CREATE ANY VIEW TO ROL_ADMIN;

GRANT CREATE ANY PROCEDURE TO ROL_ADMIN;

GRANT CREATE ANY TRIGGER TO ROL_ADMIN;

GRANT SELECT ANY TABLE TO ROL_ADMIN;
GRANT INSERT ANY TABLE TO ROL_ADMIN;
GRANT UPDATE ANY TABLE TO ROL_ADMIN;
GRANT DELETE ANY TABLE TO ROL_ADMIN;

GRANT CREATE SESSION TO ROL_ANALISTA;

GRANT CREATE SESSION TO ROL_SOPORTE;

GRANT CREATE SESSION TO ROL_CONTENIDO;

-----------------------------------------------------------------------
-- PASO 3 — PRIVILEGIOS DE OBJETO
--
-- PRECONDICIÓN:
-- TABLAS Y VISTAS MATERIALIZADAS EXISTEN
-----------------------------------------------------------------------

PROMPT ===== PRIVILEGIOS OBJETO =====

------------- ADMIN -------------

GRANT SELECT ON MV_POPULARIDAD_CONTENIDO TO ROL_ADMIN;

------------- ANALISTA -------------

GRANT SELECT ON PLAN_SUSCRIPCION TO ROL_ANALISTA;
GRANT SELECT ON CONTENIDO TO ROL_ANALISTA;
GRANT SELECT ON USUARIO TO ROL_ANALISTA;

GRANT SELECT ON SUSCRIPCION TO ROL_ANALISTA;

GRANT SELECT ON PAGO TO ROL_ANALISTA;

GRANT SELECT ON REPRODUCCION TO ROL_ANALISTA;

GRANT SELECT ON MV_POPULARIDAD_CONTENIDO
TO ROL_ANALISTA;

------------- SOPORTE -------------

GRANT SELECT
ON USUARIO
TO ROL_SOPORTE;

GRANT SELECT
ON PERFIL
TO ROL_SOPORTE;

GRANT SELECT
ON SUSCRIPCION
TO ROL_SOPORTE;

GRANT SELECT
ON PAGO
TO ROL_SOPORTE;

GRANT INSERT
ON PAGO
TO ROL_SOPORTE;

GRANT UPDATE
ON PAGO
TO ROL_SOPORTE;

------------- CONTENIDO -------------

GRANT
SELECT,
INSERT,
UPDATE,
DELETE
ON CONTENIDO
TO ROL_CONTENIDO;

GRANT
SELECT,
INSERT,
UPDATE,
DELETE
ON TEMPORADA
TO ROL_CONTENIDO;

GRANT
SELECT,
INSERT,
UPDATE,
DELETE
ON EPISODIO
TO ROL_CONTENIDO;

GRANT
SELECT,
INSERT,
UPDATE,
DELETE
ON GENERO
TO ROL_CONTENIDO;

GRANT
SELECT
ON REPRODUCCION
TO ROL_CONTENIDO;

GRANT
SELECT
ON CALIFICACION
TO ROL_CONTENIDO;

-----------------------------------------------------------------------
-- IMPORTANTE
--
-- EJECUTAR DESPUÉS DE CREAR PROCEDIMIENTOS
--
-- GRANT EXECUTE ON SP_CAMBIAR_PLAN TO ROL_SOPORTE;
-- GRANT EXECUTE ON SP_CAMBIAR_PLAN TO ROL_ADMIN;
--
-- GRANT EXECUTE ON SP_REPORTE_CONSUMO TO ROL_ANALISTA;
-- GRANT EXECUTE ON SP_REPORTE_CONSUMO TO ROL_ADMIN;
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- PASO 4 — CREACIÓN DE USUARIOS
-----------------------------------------------------------------------

DECLARE

PROCEDURE create_user_if_missing
(
p_user VARCHAR2,
p_password VARCHAR2,
p_tablespace VARCHAR2,
p_quota VARCHAR2,
p_role VARCHAR2
)

IS

v_count NUMBER;

BEGIN

SELECT COUNT(*)
INTO v_count
FROM dba_users
WHERE username=p_user;

IF v_count=0 THEN

EXECUTE IMMEDIATE
'
CREATE USER '||p_user||'
IDENTIFIED BY "'||p_password||'"
DEFAULT TABLESPACE '||p_tablespace||'
TEMPORARY TABLESPACE TEMP
'||p_quota||'
ACCOUNT UNLOCK
';

DBMS_OUTPUT.PUT_LINE(
'✓ Usuario creado '||p_user
);

ELSE

DBMS_OUTPUT.PUT_LINE(
'→ Usuario existente '||p_user
);

END IF;

EXECUTE IMMEDIATE
'GRANT '||p_role||' TO '||p_user;

DBMS_OUTPUT.PUT_LINE(
'✓ Rol asignado '
||p_role
||' → '
||p_user
);

EXCEPTION

WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE(
'✗ Error usuario '
||p_user
||' → '
||SQLERRM
);

RAISE;

END;

BEGIN

create_user_if_missing(
'USR_ADMIN_QF',
'Admin_QF#2026',
'TS_USUARIOS',
'QUOTA UNLIMITED ON TS_USUARIOS',
'ROL_ADMIN'
);

create_user_if_missing(
'USR_ANALISTA_QF',
'Analista_QF#2026',
'TS_USUARIOS',
'',
'ROL_ANALISTA'
);

create_user_if_missing(
'USR_SOPORTE_QF',
'Soporte_QF#2026',
'TS_TRANSACCIONES',
'QUOTA 10M ON TS_TRANSACCIONES',
'ROL_SOPORTE'
);

create_user_if_missing(
'USR_CONTENIDO_QF',
'Contenido_QF#2026',
'TS_CATALOGO',
'QUOTA 500M ON TS_CATALOGO',
'ROL_CONTENIDO'
);

END;
/

-----------------------------------------------------------------------
-- PASO 5 — VERIFICACIÓN
-----------------------------------------------------------------------

PROMPT ===== USUARIOS =====

SELECT
username,
account_status,
default_tablespace
FROM dba_users
WHERE username LIKE 'USR_%';

PROMPT ===== ROLES =====

SELECT
grantee,
granted_role
FROM dba_role_privs
WHERE grantee LIKE 'USR_%';

PROMPT ===== PRIVILEGIOS =====

SELECT
grantee,
table_name,
privilege
FROM dba_tab_privs
WHERE grantee LIKE 'ROL_%'
ORDER BY
grantee,
table_name;

COMMIT;


-----------------------------------------------------------------------
-- PASO 6 — PRUEBAS DE RESTRICCIÓN
--
-- INSTRUCCIONES:
-- Estas pruebas deben ejecutarse en SQL Developer abriendo una
-- conexión separada por cada usuario. No se pueden ejecutar en
-- un solo script porque SQL Developer no soporta CONNECT entre bloques.
--
-- Para cada prueba:
--   1. En SQL Developer → Nueva Conexión
--   2. Usuario y contraseña indicados en cada sección
--   3. Hostname/Puerto/SID igual que la conexión principal
--   4. Ejecutar el bloque correspondiente
-----------------------------------------------------------------------
SELECT name, network_name 
FROM v$services 
WHERE name NOT LIKE '%SYS%';
-----------------------------------------------------------------------
-- PRUEBA 1 — ROL_ANALISTA no puede crear tablas
-- Conectar como: USR_ANALISTA_QF / Analista_QF#2026
-----------------------------------------------------------------------

SET SERVEROUTPUT ON;

BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE TABLE TEST_ANALISTA (ID NUMBER)';
        DBMS_OUTPUT.PUT_LINE('ERROR — ANALISTA pudo crear tablas');
        EXECUTE IMMEDIATE 'DROP TABLE TEST_ANALISTA';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1031 THEN
                DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 1 PASADA — CREATE TABLE bloqueado correctamente');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Error inesperado → ' || SQLERRM);
            END IF;
    END;
END;
/

-----------------------------------------------------------------------
-- PRUEBA 2 — ROL_SOPORTE no puede crear usuarios
-- Conectar como: USR_SOPORTE_QF / Soporte_QF#2026
-----------------------------------------------------------------------

SET SERVEROUTPUT ON;

BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER TEST_X IDENTIFIED BY "Test123#"';
        DBMS_OUTPUT.PUT_LINE('✗ ERROR — SOPORTE pudo crear usuarios');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1031 THEN
                DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 2 PASADA — CREATE USER bloqueado correctamente');
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ Error inesperado → ' || SQLERRM);
            END IF;
    END;
END;
/

-----------------------------------------------------------------------
-- PRUEBA 3 — ROL_CONTENIDO no puede crear roles
-- Conectar como: USR_CONTENIDO_QF / Contenido_QF#2026
-----------------------------------------------------------------------

SET SERVEROUTPUT ON;

BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE TEST_ROLE';
        DBMS_OUTPUT.PUT_LINE('✗ ERROR — CONTENIDO pudo crear roles');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1031 THEN
                DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 3 PASADA — CREATE ROLE bloqueado correctamente');
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ Error inesperado → ' || SQLERRM);
            END IF;
    END;
END;
/

-----------------------------------------------------------------------
-- PRUEBA 4 — ROL_ADMIN
-- 4A: Operación PERMITIDA — crear y eliminar tabla
-- 4B: Operación NO PERMITIDA — DROP DATABASE (nadie puede esto)
-- Conectar como: USR_ADMIN_QF / Admin_QF#2026
-----------------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
    -- Prueba positiva
    BEGIN
        EXECUTE IMMEDIATE 'CREATE TABLE TEST_ADMIN (ID NUMBER)';
        DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 4A — CREATE TABLE permitido');
        EXECUTE IMMEDIATE 'DROP TABLE TEST_ADMIN';
        DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 4A — DROP TABLE permitido');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ ADMIN sin permisos → ' || SQLERRM);
    END;
    -- Prueba negativa
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLESPACE TS_USUARIOS INCLUDING CONTENTS AND DATAFILES';
        DBMS_OUTPUT.PUT_LINE('✗ ERROR — ADMIN pudo dropear tablespace');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✓ PRUEBA 4B — DROP TABLESPACE bloqueado: ' || SQLERRM);
    END;
END;
/

-----------------------------------------------------------------------
-- PERFILES DE RECURSO (PROFILE)
-- Oracle XE tiene una restricción específica: no permite CREATE PROFILE
-- desde un PDB (ORA-65066: The specified changes must apply to all
-- containers) porque en XE los perfiles se gestionan únicamente a
-- nivel de CDB$ROOT.
-- En Oracle Database Enterprise Edition esta restricción no existe
-- y los perfiles se crean normalmente dentro del PDB.
--
-- En un ambiente Oracle Enterprise la implementación sería:
--
-- CREATE PROFILE PERFIL_ESTANDAR LIMIT
--     SESSIONS_PER_USER     2
--     IDLE_TIME             30
--     FAILED_LOGIN_ATTEMPTS 5
--     PASSWORD_LOCK_TIME    1/24
--     PASSWORD_LIFE_TIME    90;
--
-- CREATE PROFILE PERFIL_PRIVILEGIADO LIMIT
--     SESSIONS_PER_USER     4
--     IDLE_TIME             60
--     FAILED_LOGIN_ATTEMPTS 3
--     PASSWORD_LOCK_TIME    2/24
--     PASSWORD_LIFE_TIME    60;
--
-- Y se asignarían a los usuarios así:
-- ALTER USER USR_ANALISTA_QF  PROFILE PERFIL_ESTANDAR;
-- ALTER USER USR_CONTENIDO_QF PROFILE PERFIL_ESTANDAR;
-- ALTER USER USR_SOPORTE_QF   PROFILE PERFIL_ESTANDAR;
-- ALTER USER USR_ADMIN_QF     PROFILE PERFIL_PRIVILEGIADO;
-----------------------------------------------------------------------


-- =====================================================================
-- 6. CONSULTAS PARA REPORTES
--====================================================================
-- 6.1 CONSULTAS PARAMETRIZADAS (mínimo 3)
--     Usan variables de sustitución (&, &&, DEFINE)
-- =====================================================================
-- a) CONSULTA PARAMETRIZADA 1:
-- Top 10 de contenido más reproducido en una ciudad dada
-- Uso: Ingresar ciudad al ejecutar (ej: Bogotá, Medellín, Cali, Armenia)
-- =====================================================================

DEFINE ciudad = '&ciudad'

SELECT *
FROM (
         SELECT
             c.titulo,
             c.tipo_contenido,
             u.ciudad_residencia,
             COUNT(r.id_reproduccion)        AS total_reproducciones,
             ROUND(AVG(r.porcentaje_avance), 2) AS promedio_avance_pct
         FROM Reproduccion r
                  JOIN Perfil      p  ON r.Perfil_id_perfil       = p.id_perfil
                  JOIN Usuario     u  ON p.Usuario_id_usuario      = u.id_usuario
                  JOIN contenido   c  ON r.contenido_id_contenido  = c.id_contenido
         WHERE UPPER(u.ciudad_residencia) = UPPER('&&ciudad')
         GROUP BY c.titulo, c.tipo_contenido, u.ciudad_residencia
         ORDER BY total_reproducciones DESC
     )
WHERE ROWNUM <= 10;

UNDEFINE ciudad

-- =====================================================================
-- b) CONSULTA PARAMETRIZADA 2:
-- Ingresos por plan de suscripción en un mes y año específicos
-- Uso: Ingresar mes (1-12) y año al ejecutar (ej: mes=3, anio=2025)
-- =====================================================================

DEFINE mes  = '&mes'
DEFINE anio = '&anio'

SELECT
    ps.nombre                        AS plan,
    TO_CHAR(pg.fecha_pago, 'MM/YYYY') AS periodo,
    COUNT(pg.id_pago)                AS cantidad_pagos,
    SUM(pg.monto)                    AS ingreso_bruto,
    SUM(NVL(pg.valor_descuento, 0))  AS total_descuentos,
    SUM(pg.monto) - SUM(NVL(pg.valor_descuento, 0)) AS ingreso_neto
FROM Pago        pg
         JOIN suscripcion s  ON pg.suscripcion_id_suscripcion = s.id_suscripcion
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
WHERE pg.estado_pago    = 'Exitoso'
  AND EXTRACT(MONTH FROM pg.fecha_pago) = &&mes
  AND EXTRACT(YEAR  FROM pg.fecha_pago) = &&anio
GROUP BY ps.nombre, TO_CHAR(pg.fecha_pago, 'MM/YYYY')
ORDER BY ingreso_neto DESC;

UNDEFINE mes
UNDEFINE anio

-- =====================================================================
-- c) CONSULTA PARAMETRIZADA 3:
-- Calificación promedio por categoría (tipo_contenido) para un género
-- Uso: Ingresar nombre de género (ej: Drama, Acción, Terror, Romance)
-- =====================================================================

DEFINE genero_nombre = '&genero_nombre'

SELECT
    c.tipo_contenido                   AS categoria,
    g.nombre                           AS genero,
    COUNT(DISTINCT c.id_contenido)     AS cantidad_titulos,
    COUNT(cal.id_calificacion)         AS total_calificaciones,
    ROUND(AVG(cal.estrellas), 2)       AS calificacion_promedio,
    MIN(cal.estrellas)                 AS calificacion_minima,
    MAX(cal.estrellas)                 AS calificacion_maxima
FROM contenido     c
         JOIN tipo_genero   tg  ON c.id_contenido       = tg.contenido_id_contenido
         JOIN genero        g   ON tg.genero_id_genero  = g.id_genero
         LEFT JOIN Calificacion cal ON c.id_contenido   = cal.contenido_id_contenido
WHERE UPPER(g.nombre) = UPPER('&&genero_nombre')
GROUP BY c.tipo_contenido, g.nombre
ORDER BY calificacion_promedio DESC NULLS LAST;

UNDEFINE genero_nombre

-- =====================================================================
-- 6.2 TABLAS DE REFERENCIAS CRUZADAS — PIVOT y UNPIVOT (mínimo 2 de cada
-- una)
-- =====================================================================
-- a) PIVOT 1:
-- Usuarios activos por ciudad (filas) y plan de suscripción (columnas)
-- =====================================================================

SELECT *
FROM (
         SELECT
             u.ciudad_residencia AS ciudad,
             ps.nombre           AS plan,
             u.id_usuario
         FROM Usuario      u
                  JOIN suscripcion  s   ON u.id_usuario              = s.Usuario_id_usuario
                  JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
         WHERE u.estado_cuenta_activa = 'Activa'
           AND s.estado               = 'Activa'
     )
         PIVOT (
                COUNT(id_usuario)
    FOR plan IN (
        'Básico'   AS "BASICO",
        'Estandar' AS "ESTANDAR",
        'Premium'  AS "PREMIUM"
    )
        )
ORDER BY ciudad;

-- =====================================================================
-- b) PIVOT 2:
-- Total de reproducciones por tipo de contenido (filas) y dispositivo (columnas)
-- =====================================================================

SELECT *
FROM (
    SELECT *
    FROM (
        SELECT
            c.tipo_contenido AS categoria,
            r.dispositivo,
            r.id_reproduccion
        FROM Reproduccion r
            JOIN contenido c ON r.contenido_id_contenido = c.id_contenido
    )
    PIVOT (
        COUNT(id_reproduccion)
        FOR dispositivo IN (
            'Celular'    AS "CELULAR",
            'Tablet'     AS "TABLET",
            'TV'         AS "TV",
            'Computador' AS "COMPUTADOR"
        )
    )
)
ORDER BY categoria;

-- =====================================================================
-- c) UNPIVOT 1:
-- Convertir el reporte PIVOT de usuarios por plan (tabla de resumen)
-- de vuelta a filas para análisis detallado por ciudad
-- =====================================================================

-- Primero creamos la tabla de resumen pivoteada como vista temporal
WITH pivot_usuarios AS (
    SELECT *
    FROM (
             SELECT
                 u.ciudad_residencia AS ciudad,
                 ps.nombre           AS plan,
                 u.id_usuario
             FROM Usuario      u
                      JOIN suscripcion  s   ON u.id_usuario              = s.Usuario_id_usuario
                      JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
             WHERE u.estado_cuenta_activa = 'Activa'
               AND s.estado               = 'Activa'
         )
             PIVOT (
                    COUNT(id_usuario)
        FOR plan IN (
            'Básico'   AS "BASICO",
            'Estandar' AS "ESTANDAR",
            'Premium'  AS "PREMIUM"
        )
            )
)
SELECT ciudad, plan, usuarios_activos
FROM pivot_usuarios
         UNPIVOT (
                  usuarios_activos
                      FOR plan IN (
        "BASICO"   AS 'Plan Básico',
        "ESTANDAR" AS 'Plan Estándar',
        "PREMIUM"  AS 'Plan Premium'
    )
        )
ORDER BY ciudad, plan;

-- =====================================================================
-- d) UNPIVOT 2:
-- Convertir tabla de ingresos mensuales (columnas por mes) a filas
-- Simula un reporte financiero pivotado (ene, feb, mar) → filas individuales
-- =====================================================================

-- Creamos el resumen pivoteado de ingresos por plan y mes (primer trimestre 2024)
WITH ingresos_pivot AS (
    SELECT *
    FROM (
             SELECT
                 ps.nombre           AS plan,
                 TO_CHAR(pg.fecha_pago, 'MON_YYYY') AS mes_periodo,
                 pg.monto
             FROM Pago        pg
                      JOIN suscripcion s   ON pg.suscripcion_id_suscripcion = s.id_suscripcion
                      JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
             WHERE pg.estado_pago = 'Exitoso'
               AND EXTRACT(YEAR FROM pg.fecha_pago) = 2024
               AND EXTRACT(MONTH FROM pg.fecha_pago) IN (1, 2, 3)
         )
             PIVOT (
                    SUM(monto)
        FOR mes_periodo IN (
            'JAN_2024' AS "ENERO_2024",
            'FEB_2024' AS "FEBRERO_2024",
            'MAR_2024' AS "MARZO_2024"
        )
            )
)
SELECT plan, mes, ingreso
FROM ingresos_pivot
         UNPIVOT (
                  ingreso
                      FOR mes IN (
        "ENERO_2024"   AS 'Enero 2024',
        "FEBRERO_2024" AS 'Febrero 2024',
        "MARZO_2024"   AS 'Marzo 2024'
    )
        )
ORDER BY plan, mes;

-- =====================================================================
-- 6.3 FUNCIONES AVANZADAS DEL GROUP BY— PIVOT y UNPIVOT (mínimo 4)
-- =====================================================================
-- a) ROLLUP:
-- Ingresos por ciudad y plan con subtotales por ciudad y gran total
-- =====================================================================

SELECT
    NVL(u.ciudad_residencia, '*** GRAN TOTAL ***') AS ciudad,
    NVL(ps.nombre, '--- SUBTOTAL CIUDAD ---')       AS plan,
    COUNT(pg.id_pago)                               AS cantidad_pagos,
    SUM(pg.monto)                                   AS ingreso_bruto,
    ROUND(AVG(pg.monto), 2)                         AS ticket_promedio
FROM Pago        pg
         JOIN suscripcion s   ON pg.suscripcion_id_suscripcion = s.id_suscripcion
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
         JOIN Usuario     u   ON s.Usuario_id_usuario          = u.id_usuario
WHERE pg.estado_pago = 'Exitoso'
GROUP BY ROLLUP(u.ciudad_residencia, ps.nombre)
ORDER BY u.ciudad_residencia NULLS LAST, ps.nombre NULLS LAST;

-- =====================================================================
-- b) CUBE:
-- Reproducciones por tipo de contenido y dispositivo
-- con TODAS las combinaciones posibles de subtotales
-- =====================================================================

SELECT
    NVL(c.tipo_contenido, '=== TOTAL GENERAL ===') AS tipo_contenido,
    NVL(r.dispositivo,    '--- TODOS LOS DISP ---') AS dispositivo,
    COUNT(r.id_reproduccion)                         AS total_reproducciones,
    ROUND(AVG(r.porcentaje_avance), 2)               AS promedio_avance_pct
FROM Reproduccion r
         JOIN contenido    c ON r.contenido_id_contenido = c.id_contenido
GROUP BY CUBE(c.tipo_contenido, r.dispositivo)
ORDER BY
    c.tipo_contenido NULLS LAST,
    r.dispositivo    NULLS LAST;

-- =====================================================================
-- c) GROUPING():
-- Reemplaza NULLs de ROLLUP con etiquetas legibles
-- usando GROUPING() para distinguir NULLs de datos reales vs. subtotales
-- =====================================================================

SELECT
    CASE
        WHEN GROUPING(u.ciudad_residencia) = 1 AND GROUPING(ps.nombre) = 1
            THEN '*** GRAN TOTAL PLATAFORMA ***'
        WHEN GROUPING(ps.nombre) = 1
            THEN 'SUBTOTAL - ' || u.ciudad_residencia
        ELSE u.ciudad_residencia
        END AS ciudad,
    CASE
        WHEN GROUPING(ps.nombre) = 1 THEN '(Todos los planes)'
        ELSE ps.nombre
        END AS plan,
    GROUPING(u.ciudad_residencia) AS es_subtotal_ciudad,  -- 1 si es fila de subtotal
    GROUPING(ps.nombre)           AS es_subtotal_plan,    -- 1 si es fila de subtotal
    COUNT(pg.id_pago)             AS cantidad_pagos,
    SUM(pg.monto)                 AS ingreso_total,
    SUM(NVL(pg.valor_descuento,0))AS descuentos_aplicados
FROM Pago        pg
         JOIN suscripcion s   ON pg.suscripcion_id_suscripcion = s.id_suscripcion
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
         JOIN Usuario     u   ON s.Usuario_id_usuario          = u.id_usuario
WHERE pg.estado_pago = 'Exitoso'
GROUP BY ROLLUP(u.ciudad_residencia, ps.nombre)
ORDER BY u.ciudad_residencia NULLS LAST, ps.nombre NULLS LAST;

-- =====================================================================
-- d) GROUPING SETS:
-- Reporte que muestra SOLO totales por tipo_contenido
-- y por ciudad, SIN el detalle cruzado entre ambos
-- =====================================================================

SELECT
    NVL(c.tipo_contenido,    '--- (Agrupado por ciudad) ---') AS tipo_contenido,
    NVL(u.ciudad_residencia, '--- (Agrupado por tipo)   ---') AS ciudad,
    COUNT(r.id_reproduccion)                                   AS total_reproducciones,
    ROUND(AVG(r.porcentaje_avance), 2)                         AS promedio_avance
FROM Reproduccion r
         JOIN contenido    c ON r.contenido_id_contenido = c.id_contenido
         JOIN Perfil       p ON r.Perfil_id_perfil       = p.id_perfil
         JOIN Usuario      u ON p.Usuario_id_usuario     = u.id_usuario
GROUP BY GROUPING SETS (
    (c.tipo_contenido),    -- Total de reproducciones por cada tipo de contenido
    (u.ciudad_residencia)  -- Total de reproducciones por cada ciudad
    )
ORDER BY c.tipo_contenido NULLS LAST, u.ciudad_residencia NULLS LAST;

-- =====================================================================
-- 7. MÉTODOS FUNCIONES, PROCEDIMIENTOS Y DISPARADORES IMPLEMENTADOS
-- =====================================================================
-- 7.1  CURSORES (mínimo 2)
-- =====================================================================
-- a) CURSOR 1:
-- Recorre usuarios con suscripción vencida (>30 días sin pago exitoso)
-- Genera reporte con nombre, email, plan, días de mora y monto adeudado
-- =====================================================================

DECLARE
-- Cursor explícito con parámetro de días de corte
CURSOR cur_morosos (p_dias_corte NUMBER DEFAULT 30) IS
SELECT
    u.id_usuario,
    u.nombre,
    u.email,
    ps.nombre                                    AS plan,
    ps.costo                                     AS monto_mensual,
    s.fecha_vencimiento,
    TRUNC(SYSDATE - s.fecha_vencimiento)         AS dias_mora,

    -- Estimación del monto adeudado según meses vencidos
    ROUND(
            CEIL(TRUNC(SYSDATE - s.fecha_vencimiento) / 30) * ps.costo
        , 2)                                         AS estimado_adeudado

FROM Usuario      u
         JOIN suscripcion  s  ON u.id_usuario = s.Usuario_id_usuario
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan

WHERE s.estado IN ('Activa', 'Suspendida')
  AND s.fecha_vencimiento < SYSDATE - p_dias_corte

  AND NOT EXISTS (
    -- Que no tengan un pago exitoso después del vencimiento
    SELECT 1
    FROM Pago pg
    WHERE pg.suscripcion_id_suscripcion = s.id_suscripcion
      AND pg.estado_pago = 'Exitoso'
      AND pg.fecha_pago > s.fecha_vencimiento
)

ORDER BY dias_mora DESC;

-- Variables de trabajo
v_registro  cur_morosos%ROWTYPE;
    v_contador  NUMBER := 0;
    v_total_adeudado NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('   REPORTE DE USUARIOS MOROSOS - QuindioFlix');
    DBMS_OUTPUT.PUT_LINE('   Generado: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('======================================================');

    DBMS_OUTPUT.PUT_LINE(
        RPAD('NOMBRE', 25) ||
        RPAD('EMAIL', 30) ||
        RPAD('PLAN', 12) ||
        RPAD('DÍAS MORA', 15) ||
        'MONTO ADEUDADO'
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

OPEN cur_morosos(30);

LOOP
FETCH cur_morosos INTO v_registro;

        EXIT WHEN cur_morosos%NOTFOUND;

        v_contador := v_contador + 1;

        v_total_adeudado :=
            v_total_adeudado +
            NVL(v_registro.estimado_adeudado, v_registro.monto_mensual);

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_registro.nombre, 25) ||
            RPAD(v_registro.email, 30) ||
            RPAD(v_registro.plan, 12) ||
            RPAD(v_registro.dias_mora || ' días', 15) ||
            '$ ' || TO_CHAR(
                NVL(v_registro.estimado_adeudado,
                    v_registro.monto_mensual),
                'FM999,990.00'
            )
        );

END LOOP;

CLOSE cur_morosos;

DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

    DBMS_OUTPUT.PUT_LINE('Total usuarios morosos : ' || v_contador);

    DBMS_OUTPUT.PUT_LINE(
        'Total estimado adeudado: $ ' ||
        TO_CHAR(v_total_adeudado, 'FM9,999,990.00')
    );

    DBMS_OUTPUT.PUT_LINE('======================================================');

EXCEPTION
    WHEN OTHERS THEN

        IF cur_morosos%ISOPEN THEN
            CLOSE cur_morosos;
END IF;

        DBMS_OUTPUT.PUT_LINE(
            'ERROR en cursor morosos: ' || SQLERRM
        );

        RAISE;
END;
/

-- =====================================================================
-- b) CURSOR 2:
-- Recorre el catálogo, calcula reproducciones completas (>=90%)
-- por contenido y actualiza la popularidad
-- (Se simula con una tabla de resumen en MV_CONTENIDO_POPULAR)
-- =====================================================================

DECLARE
    -- Cursor que recorre todos los contenidos con sus métricas
CURSOR cur_catalogo IS
SELECT
    c.id_contenido,
    c.titulo,
    c.tipo_contenido,
    COUNT(r.id_reproduccion)                                     AS total_reprod,
    COUNT(CASE WHEN r.porcentaje_avance >= 90 THEN 1 END)        AS reprod_completas,
    ROUND(
            COUNT(CASE WHEN r.porcentaje_avance >= 90 THEN 1 END) * 100.0 /
            NULLIF(COUNT(r.id_reproduccion), 0)
        , 2)                                                         AS pct_completitud
FROM contenido     c
         LEFT JOIN Reproduccion r ON c.id_contenido = r.contenido_id_contenido
GROUP BY c.id_contenido, c.titulo, c.tipo_contenido
ORDER BY reprod_completas DESC;

v_reg        cur_catalogo%ROWTYPE;
    v_nivel      VARCHAR2(20);
    v_procesados NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('   REPORTE DE POPULARIDAD DEL CATÁLOGO - QuindioFlix');
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('TÍTULO', 35) || RPAD('TIPO', 12) ||
                         RPAD('TOTAL', 8) || RPAD('COMPLETAS', 12) ||
                         RPAD('% COMPLETITUD', 16) || 'NIVEL');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));

FOR v_reg IN cur_catalogo LOOP
        v_procesados := v_procesados + 1;

        -- Calcular nivel de popularidad basado en reproducciones completas
        v_nivel := CASE
            WHEN v_reg.reprod_completas >= 10 THEN 'VIRAL'
            WHEN v_reg.reprod_completas >= 5  THEN 'POPULAR'
            WHEN v_reg.reprod_completas >= 2  THEN 'NORMAL'
            WHEN v_reg.reprod_completas >= 1  THEN 'BAJO'
            ELSE                                   'SIN VISTAS'
END;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(v_reg.titulo, 1, 33), 35) ||
            RPAD(v_reg.tipo_contenido, 12) ||
            RPAD(NVL(v_reg.total_reprod, 0), 8) ||
            RPAD(NVL(v_reg.reprod_completas, 0), 12) ||
            RPAD(NVL(v_reg.pct_completitud, 0) || '%', 16) ||
            v_nivel
        );

        -- En un sistema real, aquí se actualizaría un campo popularidad
        -- UPDATE contenido SET popularidad = v_nivel WHERE id_contenido = v_reg.id_contenido;
END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));
    DBMS_OUTPUT.PUT_LINE('Total de contenidos procesados: ' || v_procesados);
    -- COMMIT; -- Descomentar si se hace UPDATE real

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en cursor catálogo: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================================
-- 7.2 PROCEDIMIENTOS ALMACENADOS (mínimo 3)
-- =====================================================================
-- a) SP 1: SP_REGISTRAR_USUARIO
-- Recibe datos del usuario y plan elegido, valida email único,
-- crea cuenta, crea perfil predeterminado y registra el primer pago
-- =====================================================================

CREATE OR REPLACE PROCEDURE SP_REGISTRAR_USUARIO (
    p_nombre          IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_telefono        IN VARCHAR2,
    p_fecha_nac       IN DATE,
    p_ciudad          IN VARCHAR2,
    p_id_plan         IN NUMBER,
    p_metodo_pago     IN VARCHAR2,
    p_id_referido     IN NUMBER DEFAULT NULL,   -- NULL si no viene referido
    p_id_usuario_out  OUT NUMBER                -- ID generado del nuevo usuario
)
AS
    -- Excepciones personalizadas
    ex_email_duplicado  EXCEPTION;
    ex_plan_invalido    EXCEPTION;
    ex_mayor_edad       EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_email_duplicado, -20001);
    PRAGMA EXCEPTION_INIT(ex_plan_invalido,   -20002);
    PRAGMA EXCEPTION_INIT(ex_mayor_edad,      -20003);

    v_nuevo_id     NUMBER;
    v_nuevo_sus_id NUMBER;
    v_costo_plan   NUMBER;
    v_nombre_plan  VARCHAR2(20);
    v_email_count  NUMBER;
    v_edad         NUMBER;

BEGIN
    -- VALIDACIÓN 1: El email no debe existir ya
SELECT COUNT(*) INTO v_email_count
FROM Usuario WHERE UPPER(email) = UPPER(p_email);

IF v_email_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'El email ' || p_email || ' ya está registrado en QuindioFlix.');
END IF;

    -- VALIDACIÓN 2: El plan debe existir
BEGIN
SELECT costo, nombre INTO v_costo_plan, v_nombre_plan
FROM Plan_suscripcion
WHERE id_plan = p_id_plan;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,
                'El plan con ID ' || p_id_plan || ' no existe.');
END;

    -- VALIDACIÓN 3: El titular debe ser mayor de 18 años
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, p_fecha_nac) / 12);
    IF v_edad < 18 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'El titular debe ser mayor de 18 años. Edad calculada: ' || v_edad);
END IF;

    -- PASO 1: Obtener nuevo ID de usuario
SELECT NVL(MAX(id_usuario), 0) + 1 INTO v_nuevo_id FROM Usuario;

-- PASO 2: Crear el usuario
INSERT INTO Usuario (
    id_usuario, nombre, email, telefono,
    fecha_nacimiento, ciudad_residencia,
    Usuario_id_referido, estado_cuenta_activa
) VALUES (
             v_nuevo_id, p_nombre, p_email, p_telefono,
             p_fecha_nac, p_ciudad,
             NVL(p_id_referido, v_nuevo_id),   -- Si no tiene referido, se auto-referencia
             'Activa'
         );

-- PASO 3: Crear la suscripción
SELECT NVL(MAX(id_suscripcion), 0) + 1 INTO v_nuevo_sus_id FROM suscripcion;

INSERT INTO suscripcion (
    id_suscripcion, fecha_inicio, fecha_vencimiento,
    estado, Usuario_id_usuario, Plan_suscripcion_id_plan
) VALUES (
             v_nuevo_sus_id,
             SYSDATE,
             ADD_MONTHS(SYSDATE, 1),   -- Vence en 1 mes
             'Activa',
             v_nuevo_id,
             p_id_plan
         );

-- PASO 4: Crear perfil predeterminado tipo Adulto
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo)
VALUES (
           (SELECT NVL(MAX(id_perfil), 0) + 1 FROM Perfil),
           v_nuevo_id,
           p_nombre,               -- El perfil principal lleva el nombre del usuario
           'avatar_default.png',
           'Adulto'                -- REGLA: el primer perfil siempre es Adulto
       );

-- PASO 5: Registrar el primer pago
INSERT INTO Pago (
    id_pago, fecha_pago, monto, metodo_pago,
    estado_pago, valor_descuento, suscripcion_id_suscripcion
) VALUES (
             (SELECT NVL(MAX(id_pago), 0) + 1 FROM Pago),
             SYSDATE,
             v_costo_plan,
             p_metodo_pago,
             'Exitoso',
             0,
             v_nuevo_sus_id
         );

p_id_usuario_out := v_nuevo_id;

COMMIT;

DBMS_OUTPUT.PUT_LINE('✓ Usuario registrado exitosamente.');
    DBMS_OUTPUT.PUT_LINE('  ID      : ' || v_nuevo_id);
    DBMS_OUTPUT.PUT_LINE('  Nombre  : ' || p_nombre);
    DBMS_OUTPUT.PUT_LINE('  Plan    : ' || v_nombre_plan || ' ($' || v_costo_plan || '/mes)');

EXCEPTION
    WHEN ex_email_duplicado THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
WHEN ex_plan_invalido THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
WHEN ex_mayor_edad THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR inesperado en SP_REGISTRAR_USUARIO: ' || SQLERRM);
        RAISE;
END SP_REGISTRAR_USUARIO;
/

-- Prueba de SP_REGISTRAR_USUARIO
DECLARE
v_nuevo_id NUMBER;
BEGIN
    SP_REGISTRAR_USUARIO(
        p_nombre      => 'Carlos Tester',
        p_email       => 'carlos.test@email.com',
        p_telefono    => '3001234000',
        p_fecha_nac   => DATE '1995-06-15',
        p_ciudad      => 'Bogotá',
        p_id_plan     => 2,
        p_metodo_pago => 'Nequi',
        p_id_referido => 1,
        p_id_usuario_out => v_nuevo_id
    );
    DBMS_OUTPUT.PUT_LINE('  ID asignado: ' || v_nuevo_id);
END;
/

-- =====================================================================
-- b) SP 2: SP_CAMBIAR_PLAN
-- Recibe id_usuario y nuevo plan, valida que no baje de plan si tiene
-- más perfiles de los permitidos, actualiza plan y registra cambio
-- =====================================================================

CREATE OR REPLACE PROCEDURE SP_CAMBIAR_PLAN (
    p_id_usuario  IN NUMBER,
    p_nuevo_plan  IN NUMBER
)
AS
    ex_plan_invalido    EXCEPTION;
    ex_perfiles_exceden EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_plan_invalido,    -20010);
    PRAGMA EXCEPTION_INIT(ex_perfiles_exceden, -20011);

    v_plan_actual_id    NUMBER;
    v_plan_actual_pant  NUMBER;
    v_nuevo_pantallas   NUMBER;
    v_nuevo_nombre      VARCHAR2(20);
    v_nuevo_costo       NUMBER;
    v_perfiles_actuales NUMBER;
    v_id_suscripcion    NUMBER;

BEGIN
    -- VALIDACIÓN 1: El nuevo plan existe
BEGIN
SELECT num_pantallas, nombre, costo
INTO v_nuevo_pantallas, v_nuevo_nombre, v_nuevo_costo
FROM Plan_suscripcion
WHERE id_plan = p_nuevo_plan;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010,
                'El plan ID ' || p_nuevo_plan || ' no existe.');
END;

    -- Obtener suscripción activa del usuario
SELECT id_suscripcion, Plan_suscripcion_id_plan
INTO v_id_suscripcion, v_plan_actual_id
FROM suscripcion
WHERE Usuario_id_usuario = p_id_usuario
  AND estado = 'Activa'
  AND ROWNUM = 1;

-- Pantallas del plan actual
SELECT num_pantallas INTO v_plan_actual_pant
FROM Plan_suscripcion WHERE id_plan = v_plan_actual_id;

-- VALIDACIÓN 2: Si baja de plan, no puede tener más perfiles de los permitidos
SELECT COUNT(*) INTO v_perfiles_actuales
FROM Perfil WHERE Usuario_id_usuario = p_id_usuario;

IF v_nuevo_pantallas < v_plan_actual_pant
       AND v_perfiles_actuales > v_nuevo_pantallas THEN
        RAISE_APPLICATION_ERROR(-20011,
            'No puede bajar al plan ' || v_nuevo_nombre ||
            ' (max ' || v_nuevo_pantallas || ' perfil(es)). ' ||
            'Tiene ' || v_perfiles_actuales || ' perfiles activos. ' ||
            'Elimine ' || (v_perfiles_actuales - v_nuevo_pantallas) ||
            ' perfil(es) primero.');
END IF;

    -- CAMBIO DE PLAN: Actualizar suscripción
UPDATE suscripcion
SET Plan_suscripcion_id_plan = p_nuevo_plan,
    fecha_vencimiento        = ADD_MONTHS(SYSDATE, 1)
WHERE id_suscripcion = v_id_suscripcion;

-- Registrar el nuevo pago por el cambio de plan
INSERT INTO Pago (
    id_pago, fecha_pago, monto, metodo_pago,
    estado_pago, valor_descuento, suscripcion_id_suscripcion
) VALUES (
             (SELECT NVL(MAX(id_pago), 0) + 1 FROM Pago),
             SYSDATE,
             v_nuevo_costo,
             'Tarjeta crédito',
             'Exitoso',
             0,
             v_id_suscripcion
         );

COMMIT;

DBMS_OUTPUT.PUT_LINE('✓ Plan actualizado correctamente.');
    DBMS_OUTPUT.PUT_LINE('  Usuario ID  : ' || p_id_usuario);
    DBMS_OUTPUT.PUT_LINE('  Nuevo plan  : ' || v_nuevo_nombre);
    DBMS_OUTPUT.PUT_LINE('  Nuevo costo : $' || v_nuevo_costo || '/mes');

EXCEPTION
    WHEN ex_plan_invalido THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
WHEN ex_perfiles_exceden THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró suscripción activa para el usuario ' || p_id_usuario);
        RAISE;
WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR inesperado en SP_CAMBIAR_PLAN: ' || SQLERRM);
        RAISE;
END SP_CAMBIAR_PLAN;
/

-- Prueba 1 — Caso inválido: bajar de Premium (4 perfiles) a Básico (1 perfil)
-- Usuario 1 tiene 4 perfiles activos, no puede bajar a Básico
BEGIN
    SP_CAMBIAR_PLAN(p_id_usuario => 1, p_nuevo_plan => 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado capturado: ' || SQLERRM);
END;
/



-- Prueba 2 — Caso válido: subir de Básico a Estándar
-- Usuario 30 tiene plan Básico con 1 perfil, puede subir a Estándar
BEGIN
    SP_CAMBIAR_PLAN(p_id_usuario => 30, p_nuevo_plan => 3);
END;
/

-- =====================================================================
-- c) SP 3: SP_REPORTE_CONSUMO
-- Recibe id_usuario y rango de fechas, genera reporte detallado
-- de reproducciones por perfil, agrupadas por categoría
-- =====================================================================

CREATE OR REPLACE PROCEDURE SP_REPORTE_CONSUMO (
    p_id_usuario   IN NUMBER,
    p_fecha_inicio IN DATE,
    p_fecha_fin    IN DATE
)
AS
    CURSOR cur_consumo IS
SELECT
    p.nombre              AS perfil,
    p.tipo                AS tipo_perfil,
    c.tipo_contenido      AS categoria,
    c.titulo,
    r.dispositivo,

    -- Duración en minutos de la reproducción
    ROUND(
            (CAST(r.fecha_fin AS DATE) -
             CAST(r.fecha_inicio AS DATE)) * 1440,
            2) AS minutos,

    r.porcentaje_avance,
    CAST(r.fecha_inicio AS DATE) AS fecha

FROM Reproduccion r
         JOIN Perfil       p  ON r.Perfil_id_perfil       = p.id_perfil
         JOIN contenido    c  ON r.contenido_id_contenido = c.id_contenido

WHERE p.Usuario_id_usuario = p_id_usuario
  AND CAST(r.fecha_inicio AS DATE)
    BETWEEN p_fecha_inicio AND p_fecha_fin

ORDER BY p.nombre, c.tipo_contenido, r.fecha_inicio;

v_perfil_actual   VARCHAR2(50) := '';
    v_cat_actual      VARCHAR2(20) := '';
    v_min_perfil      NUMBER := 0;
    v_min_categoria   NUMBER := 0;
    v_min_total       NUMBER := 0;
    v_titulos_cat     NUMBER := 0;
    v_nombre_usuario  VARCHAR2(50);

BEGIN
    -- Obtener nombre del usuario
SELECT nombre
INTO v_nombre_usuario
FROM Usuario
WHERE id_usuario = p_id_usuario;

DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('   REPORTE DE CONSUMO - QuindioFlix');
    DBMS_OUTPUT.PUT_LINE('   Usuario : ' || v_nombre_usuario ||
                         ' (ID: ' || p_id_usuario || ')');

    DBMS_OUTPUT.PUT_LINE('   Período : ' ||
                         TO_CHAR(p_fecha_inicio,'DD/MM/YYYY') ||
                         ' al ' ||
                         TO_CHAR(p_fecha_fin,'DD/MM/YYYY'));

    DBMS_OUTPUT.PUT_LINE('======================================================');

FOR v_reg IN cur_consumo LOOP

        -- Cambio de perfil
        IF v_reg.perfil <> v_perfil_actual THEN

            -- Cerrar categoría anterior
            IF v_cat_actual <> '' THEN
                DBMS_OUTPUT.PUT_LINE(
                    '      └─ Subtotal ' || v_cat_actual ||
                    ': ' || v_titulos_cat || ' títulos | ' ||
                    ROUND(v_min_categoria / 60, 1) || ' hrs'
                );
END IF;

            -- Cerrar perfil anterior
            IF v_perfil_actual <> '' THEN
                DBMS_OUTPUT.PUT_LINE(
                    '   TOTAL PERFIL ' || v_perfil_actual ||
                    ': ' || ROUND(v_min_perfil / 60, 1) || ' hrs'
                );

                DBMS_OUTPUT.PUT_LINE(
                    '   ' || RPAD('-', 55, '-')
                );
END IF;

            v_perfil_actual := v_reg.perfil;
            v_cat_actual    := '';
            v_min_perfil    := 0;

            DBMS_OUTPUT.PUT_LINE(
                '► PERFIL: ' || v_reg.perfil ||
                ' [' || v_reg.tipo_perfil || ']'
            );
END IF;

        -- Cambio de categoría
        IF v_reg.categoria <> v_cat_actual THEN

            IF v_cat_actual <> '' THEN
                DBMS_OUTPUT.PUT_LINE(
                    '      └─ Subtotal ' || v_cat_actual ||
                    ': ' || v_titulos_cat || ' títulos | ' ||
                    ROUND(v_min_categoria / 60, 1) || ' hrs'
                );
END IF;

            v_cat_actual    := v_reg.categoria;
            v_min_categoria := 0;
            v_titulos_cat   := 0;

            DBMS_OUTPUT.PUT_LINE(
                '   ▸ Categoría: ' || v_reg.categoria
            );
END IF;

        -- Acumuladores
        v_titulos_cat   := v_titulos_cat + 1;
        v_min_categoria := v_min_categoria + NVL(v_reg.minutos, 0);
        v_min_perfil    := v_min_perfil    + NVL(v_reg.minutos, 0);
        v_min_total     := v_min_total     + NVL(v_reg.minutos, 0);

        -- Detalle
        DBMS_OUTPUT.PUT_LINE(
            '      • ' ||
            RPAD(SUBSTR(v_reg.titulo, 1, 30), 32) ||
            ' | ' || v_reg.dispositivo ||
            ' | ' || v_reg.porcentaje_avance || '%' ||
            ' | ' || TO_CHAR(v_reg.fecha, 'DD/MM')
        );

END LOOP;

    -- Cerrar última categoría
    IF v_cat_actual <> '' THEN
        DBMS_OUTPUT.PUT_LINE(
            '      └─ Subtotal ' || v_cat_actual ||
            ': ' || v_titulos_cat || ' títulos | ' ||
            ROUND(v_min_categoria / 60, 1) || ' hrs'
        );
END IF;

    -- Cerrar último perfil
    IF v_perfil_actual <> '' THEN
        DBMS_OUTPUT.PUT_LINE(
            '   TOTAL PERFIL ' || v_perfil_actual ||
            ': ' || ROUND(v_min_perfil / 60, 1) || ' hrs'
        );
END IF;

    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE(
        'TIEMPO TOTAL CONSUMIDO: ' ||
        ROUND(v_min_total / 60, 1) || ' horas'
    );
    DBMS_OUTPUT.PUT_LINE('======================================================');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(
            'No se encontró el usuario con ID: ' || p_id_usuario
        );

WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'ERROR en SP_REPORTE_CONSUMO: ' || SQLERRM
        );
        RAISE;

END SP_REPORTE_CONSUMO;
/

-- Prueba SP_REPORTE_CONSUMO
BEGIN
    SP_REPORTE_CONSUMO(
        p_id_usuario   => 1,
        p_fecha_inicio => DATE '2024-01-01',
        p_fecha_fin    => DATE '2024-06-30'
    );
END;
/

-- =====================================================================
-- 7.3 FUNCIONES (mínimo 2)
-- =====================================================================
-- a) FUNCIÓN 1: FN_CALCULAR_MONTO
-- Retorna el monto a cobrar en el próximo mes considerando
-- el plan actual y descuentos por antigüedad:
-- > 12 meses → 10% descuento | > 24 meses → 15% descuento
-- =====================================================================

CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO (
    p_id_usuario IN NUMBER
) RETURN NUMBER
AS
    v_costo_plan   NUMBER;
    v_meses        NUMBER;
    v_descuento    NUMBER := 0;
    v_monto_final  NUMBER;
    v_nombre_plan  VARCHAR2(20);

BEGIN
    -- Obtener plan actual y fecha de inicio de suscripción
SELECT ps.costo, ps.nombre,
       TRUNC(MONTHS_BETWEEN(SYSDATE, s.fecha_inicio))
INTO v_costo_plan, v_nombre_plan, v_meses
FROM suscripcion     s
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
WHERE s.Usuario_id_usuario = p_id_usuario
  AND s.estado = 'Activa'
  AND ROWNUM = 1;

-- Aplicar descuento por antigüedad
IF v_meses > 24 THEN
        v_descuento := 0.15;  -- 15% para más de 24 meses
    ELSIF v_meses > 12 THEN
        v_descuento := 0.10;  -- 10% para más de 12 meses
ELSE
        v_descuento := 0;     -- Sin descuento para nuevos usuarios
END IF;

    v_monto_final := ROUND(v_costo_plan * (1 - v_descuento), 2);

    DBMS_OUTPUT.PUT_LINE('Plan: ' || v_nombre_plan ||
                         ' | Antigüedad: ' || v_meses || ' meses' ||
                         ' | Descuento: ' || (v_descuento * 100) || '%' ||
                         ' | Monto: $' || v_monto_final);

RETURN v_monto_final;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No hay suscripción activa para el usuario ' || p_id_usuario);
RETURN NULL;
WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en FN_CALCULAR_MONTO: ' || SQLERRM);
RETURN NULL;
END FN_CALCULAR_MONTO;
/

-- Prueba FN_CALCULAR_MONTO
SELECT
    u.id_usuario,
    u.nombre,
    FN_CALCULAR_MONTO(u.id_usuario) AS monto_proximo_mes
FROM Usuario u
WHERE u.estado_cuenta_activa = 'Activa'
  AND ROWNUM <= 5;


-- =====================================================================
-- b) FUNCIÓN 2: FN_CONTENIDO_RECOMENDADO
-- Recibe id_perfil y retorna el título del contenido más afín
-- basándose en los géneros más reproducidos por ese perfil
-- =====================================================================

CREATE OR REPLACE FUNCTION FN_CONTENIDO_RECOMENDADO (
    p_id_perfil IN NUMBER
) RETURN VARCHAR2
AS
    v_titulo_recomendado VARCHAR2(200);
    v_tipo_perfil        VARCHAR2(20);

BEGIN
    SELECT tipo INTO v_tipo_perfil
    FROM Perfil WHERE id_perfil = p_id_perfil;

    SELECT titulo INTO v_titulo_recomendado
    FROM (
        SELECT
            c.id_contenido,
            c.titulo,
            COUNT(tg.genero_id_genero) AS coincidencias_genero
        FROM contenido c
            JOIN tipo_genero tg ON c.id_contenido = tg.contenido_id_contenido
        WHERE tg.genero_id_genero IN (
            SELECT genero_id_genero
            FROM (
                SELECT
                    tg2.genero_id_genero,
                    COUNT(*) total
                FROM Reproduccion r2
                    JOIN contenido c2 ON r2.contenido_id_contenido = c2.id_contenido
                    JOIN tipo_genero tg2 ON c2.id_contenido = tg2.contenido_id_contenido
                WHERE r2.Perfil_id_perfil = p_id_perfil
                GROUP BY tg2.genero_id_genero
                ORDER BY total DESC
            )
            WHERE ROWNUM <= 3
        )
        AND c.id_contenido NOT IN (
            SELECT r3.contenido_id_contenido
            FROM Reproduccion r3
            WHERE r3.Perfil_id_perfil = p_id_perfil
        )
        AND (
            v_tipo_perfil = 'Adulto'
            OR c.clasificacion_edad IN ('TP', '+7', '+13')
        )
        GROUP BY c.id_contenido, c.titulo
        ORDER BY coincidencias_genero DESC, DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM = 1;

    RETURN v_titulo_recomendado;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        BEGIN
            SELECT titulo INTO v_titulo_recomendado
            FROM (
                SELECT titulo, score_popularidad
                FROM MV_POPULARIDAD_CONTENIDO
                WHERE id_contenido NOT IN (
                    SELECT contenido_id_contenido
                    FROM Reproduccion
                    WHERE Perfil_id_perfil = p_id_perfil
                )
                ORDER BY score_popularidad DESC
            )
            WHERE ROWNUM = 1;
            RETURN v_titulo_recomendado;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN 'Imperio del Sur';
        END;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RETURN NULL;
END FN_CONTENIDO_RECOMENDADO;
/


-- Prueba FN_CONTENIDO_RECOMENDADO
SELECT
    p.id_perfil,
    p.nombre     AS perfil,
    p.tipo,
    FN_CONTENIDO_RECOMENDADO(p.id_perfil) AS titulo_recomendado
FROM Perfil p
WHERE p.id_perfil IN (1, 5, 8, 25, 45)
ORDER BY p.id_perfil;

-- =====================================================================
-- 7.3 DISPARADORES (mínimo 4)
-- =====================================================================
-- a) TRIGGER 1 (FILA):
-- En REPRODUCCIONES: verifica que el usuario tenga cuenta ACTIVA
-- antes de insertar. Si no, rechaza la inserción.
-- =====================================================================

CREATE OR REPLACE TRIGGER TRG_REPROD_CUENTA_ACTIVA
BEFORE INSERT ON Reproduccion
FOR EACH ROW
DECLARE
v_estado VARCHAR2(12);
BEGIN
    -- Buscar estado de la cuenta del usuario dueño del perfil
SELECT u.estado_cuenta_activa INTO v_estado
FROM Usuario u
         JOIN Perfil  p ON u.id_usuario = p.Usuario_id_usuario
WHERE p.id_perfil = :NEW.Perfil_id_perfil;

IF v_estado <> 'Activa' THEN
        RAISE_APPLICATION_ERROR(-20100,
            'Reproducción rechazada: La cuenta del usuario no está ACTIVA ' ||
            '(estado actual: ' || v_estado || '). ' ||
            'Regularice su pago para continuar.');
END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20101,
            'Reproducción rechazada: No se encontró el perfil con ID ' ||
            :NEW.Perfil_id_perfil);
WHEN OTHERS THEN
        RAISE;
END TRG_REPROD_CUENTA_ACTIVA;
/

-- Prueba TRG_REPROD_CUENTA_ACTIVA (perfil 17 pertenece a usuario 7, INACTIVA)
BEGIN
INSERT INTO Reproduccion VALUES (
                                    TIMESTAMP '2026-05-01 20:00:00', TIMESTAMP '2026-05-01 22:00:00',
                                    'TV', 9999, 50, 17, 1, 36
                                );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger funcionó: ' || SQLERRM);
END;
/

-- =====================================================================
-- b) TRIGGER 2 (FILA):
-- En PERFILES: al insertar un nuevo perfil, verifica que el usuario
-- no exceda el máximo permitido por su plan.
-- Básico: 1 perfil | Estándar: 2 perfiles | Premium: 4 perfiles
-- =====================================================================

CREATE OR REPLACE TRIGGER TRG_PERFIL_LIMITE_PLAN
BEFORE INSERT ON Perfil
FOR EACH ROW
DECLARE
v_max_pantallas NUMBER;
    v_perfiles_act  NUMBER;
    v_nombre_plan   VARCHAR2(20);
BEGIN
    -- Obtener límite de pantallas del plan activo del usuario
SELECT ps.num_pantallas, ps.nombre
INTO v_max_pantallas, v_nombre_plan
FROM suscripcion     s
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
WHERE s.Usuario_id_usuario = :NEW.Usuario_id_usuario
  AND s.estado = 'Activa'
  AND ROWNUM = 1;

-- Contar perfiles actuales del usuario
SELECT COUNT(*) INTO v_perfiles_act
FROM Perfil
WHERE Usuario_id_usuario = :NEW.Usuario_id_usuario;

IF v_perfiles_act >= v_max_pantallas THEN
        RAISE_APPLICATION_ERROR(-20200,
            'No se puede crear el perfil. ' ||
            'El plan ' || v_nombre_plan ||
            ' permite máximo ' || v_max_pantallas || ' perfil(es). ' ||
            'Actualmente tiene ' || v_perfiles_act || ' perfil(es).');
END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20201,
            'No se encontró suscripción activa para el usuario ' || :NEW.Usuario_id_usuario);
WHEN OTHERS THEN
        RAISE;
END TRG_PERFIL_LIMITE_PLAN;
/

-- Prueba TRG_PERFIL_LIMITE_PLAN (usuario 29 tiene plan Básico = 1 perfil, ya tiene 1)
BEGIN
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo)
VALUES (9998, 22, 'Perfil Extra', 'avatar_x.png', 'Adulto');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger funcionó: ' || SQLERRM);
END;
/

-- =====================================================================
-- c) TRIGGER 3 (FILA):
-- En CALIFICACIONES: verifica que el perfil haya reproducido al menos
-- el 50% del contenido antes de permitir calificar.
-- =====================================================================

CREATE OR REPLACE TRIGGER TRG_CALIF_REQUIERE_AVANCE
BEFORE INSERT ON Calificacion
FOR EACH ROW
DECLARE
v_max_avance NUMBER;
BEGIN
    -- Buscar el mayor porcentaje de avance del perfil en ese contenido
SELECT NVL(MAX(porcentaje_avance), 0) INTO v_max_avance
FROM Reproduccion
WHERE Perfil_id_perfil       = :NEW.Perfil_id_perfil
  AND contenido_id_contenido = :NEW.contenido_id_contenido;

IF v_max_avance < 50 THEN
        RAISE_APPLICATION_ERROR(-20300,
            'No se puede calificar el contenido. ' ||
            'Debe haber reproducido al menos el 50% para opinar. ' ||
            'Su avance máximo registrado es: ' || v_max_avance || '%.');
END IF;
END TRG_CALIF_REQUIERE_AVANCE;
/

-- Prueba TRG_CALIF_REQUIERE_AVANCE (perfil 46 con contenido 13, avance insuficiente)
BEGIN
INSERT INTO Calificacion (id_calificacion, estrellas, reseña, Perfil_id_perfil, contenido_id_contenido)
VALUES (9999, 5, 'Intento calificar sin ver suficiente', 46, 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger funcionó: ' || SQLERRM);
END;
/

-- =====================================================================
-- TRIGGER 4 (FILA):
-- En PAGOS: después de insertar un pago exitoso, actualiza el
-- estado de la cuenta del usuario a 'Activa' y renueva la suscripción
-- =====================================================================

CREATE OR REPLACE TRIGGER TRG_PAGO_ACTIVA_CUENTA
AFTER INSERT ON Pago
FOR EACH ROW
BEGIN
    -- Solo actuar si el pago fue exitoso
    IF :NEW.estado_pago = 'Exitoso' THEN

        -- Activar la cuenta del usuario asociado a la suscripción
UPDATE Usuario
SET estado_cuenta_activa = 'Activa'
WHERE id_usuario = (
    SELECT Usuario_id_usuario
    FROM suscripcion
    WHERE id_suscripcion = :NEW.suscripcion_id_suscripcion
);

-- Reactivar y renovar la suscripción por 1 mes
UPDATE suscripcion
SET estado = 'Activa',
    fecha_vencimiento = ADD_MONTHS(SYSDATE, 1)
WHERE id_suscripcion = :NEW.suscripcion_id_suscripcion;

END IF;
END TRG_PAGO_ACTIVA_CUENTA;
/


-- d)PRUEBA TRG_PAGO_ACTIVA_CUENTA
-- Usuario 7 tiene cuenta inactiva y realizará un pago exitoso


DECLARE
v_estado VARCHAR2(20);
BEGIN
    -- Insertar pago exitoso
INSERT INTO Pago (
    id_pago,
    fecha_pago,
    monto,
    metodo_pago,
    estado_pago,
    valor_descuento,
    suscripcion_id_suscripcion
)
VALUES (
           (SELECT NVL(MAX(id_pago),0)+1 FROM Pago),
           SYSDATE,
           34900,
           'Nequi',
           'Exitoso',
           0,
           7
       );

-- Verificar si el trigger activó la cuenta
SELECT estado_cuenta_activa
INTO v_estado
FROM Usuario
WHERE id_usuario = 7;

DBMS_OUTPUT.PUT_LINE(
        '✓ Trigger funcionó correctamente. Estado actual: ' || v_estado
    );

ROLLBACK; -- Revertir cambios de prueba
END;
/

-- =====================================================================
-- 7.4 TRANSACCIONES
-- R.A.1 — Administrar componentes fundamentales
-- =====================================================================
-- ESPECIFICACIÓN DE TRANSACCIONES (mínimo 3)
-- =====================================================================
-- a) TRANSACCIÓN 1: REGISTRO COMPLETO
-- Crear usuario + perfil + primer pago
-- Si falla cualquier paso → ROLLBACK total (todo o nada)
--
-- ESTADOS:
--   ACTIVA         → Desde el primer INSERT
--   PARCIALMENTE CONFIRMADA → Cuando todos los INSERTs se ejecutaron
--   CONFIRMADA     → Después del COMMIT
--   ABORTADA/FALLIDA → Si hay error → ROLLBACK
-- =====================================================================

BEGIN
    -- ── ESTADO: ACTIVA ────────────────────────────────────────────
    DBMS_OUTPUT.PUT_LINE('=== TRANSACCIÓN 1: REGISTRO COMPLETO ===');
    DBMS_OUTPUT.PUT_LINE('[ACTIVA] Iniciando transacción...');

    -- PASO 1: Insertar el usuario
INSERT INTO Usuario (
    id_usuario, nombre, email, telefono,
    fecha_nacimiento, ciudad_residencia,
    Usuario_id_referido, estado_cuenta_activa
) VALUES (
             100, 'Ana Prueba T1', 'ana.t1@email.com',
             '3001110001', DATE '1998-03-10', 'Cali', 100, 'Activa'
         );
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 1/3: Usuario insertado');

    -- PASO 2: Insertar suscripción
INSERT INTO suscripcion (
    id_suscripcion, fecha_inicio, fecha_vencimiento,
    estado, Usuario_id_usuario, Plan_suscripcion_id_plan
) VALUES (
             100, SYSDATE, ADD_MONTHS(SYSDATE, 1), 'Activa', 100, 1
         );
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 2/3: Suscripción creada');

    -- PASO 3: Crear perfil predeterminado
INSERT INTO Perfil (id_perfil, Usuario_id_usuario, nombre, avatar, tipo)
VALUES (100, 100, 'Ana Prueba T1', 'avatar_new.png', 'Adulto');
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 3/3: Perfil creado');

    -- PASO 4: Primer pago
INSERT INTO Pago (
    id_pago, fecha_pago, monto, metodo_pago,
    estado_pago, valor_descuento, suscripcion_id_suscripcion
) VALUES (
             200, SYSDATE, 14900, 'PSE', 'Exitoso', 0, 100
         );
DBMS_OUTPUT.PUT_LINE('[PARCIALMENTE CONFIRMADA] Todos los pasos ejecutados');

    -- ── ESTADO: CONFIRMADA ────────────────────────────────────────
COMMIT;
DBMS_OUTPUT.PUT_LINE('[CONFIRMADA] Transacción confirmada con COMMIT');

EXCEPTION
    WHEN OTHERS THEN
        -- ── ESTADO: FALLIDA/ABORTADA ──────────────────────────────
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[ABORTADA] Error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('[ABORTADA] ROLLBACK ejecutado. Ningún dato fue guardado.');
        RAISE;
END;
/

-- Limpiar datos de prueba de la transacción 1
DELETE FROM Pago        WHERE id_pago          = 200;
DELETE FROM Perfil      WHERE id_perfil         = 100;
DELETE FROM suscripcion WHERE id_suscripcion    = 100;
DELETE FROM Usuario     WHERE id_usuario        = 100;
COMMIT;

-- =====================================================================
-- b) TRANSACCIÓN 2: RENOVACIÓN MENSUAL CON SAVEPOINT
-- Para cada usuario activo: verificar vencimiento, calcular monto,
-- registrar pago y actualizar estado.
-- SAVEPOINT por usuario → si falla uno, se revierte solo ese usuario
-- y continúa con los demás.
-- =====================================================================

DECLARE
CURSOR cur_usuarios_renovar IS
SELECT
    u.id_usuario,
    u.nombre,
    s.id_suscripcion,
    s.fecha_vencimiento,
    ps.costo,
    FN_CALCULAR_MONTO(u.id_usuario) AS monto_cobrar
FROM Usuario       u
         JOIN suscripcion   s  ON u.id_usuario              = s.Usuario_id_usuario
         JOIN Plan_suscripcion ps ON s.Plan_suscripcion_id_plan = ps.id_plan
WHERE s.estado = 'Activa'
  AND s.fecha_vencimiento <= SYSDATE + 400  
  AND u.estado_cuenta_activa = 'Activa'
ORDER BY u.id_usuario;

v_sp_name     VARCHAR2(30);
    v_procesados  NUMBER := 0;
    v_exitosos    NUMBER := 0;
    v_fallidos    NUMBER := 0;
    v_nuevo_pago  NUMBER;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TRANSACCIÓN 2: RENOVACIÓN MENSUAL CON SAVEPOINT ===');
    DBMS_OUTPUT.PUT_LINE('[ACTIVA] Iniciando proceso de renovación masiva...');

FOR v_reg IN cur_usuarios_renovar LOOP
        v_procesados  := v_procesados + 1;
        v_sp_name     := 'SP_USUARIO_' || v_reg.id_usuario;

        -- SAVEPOINT individual por usuario
        -- Si falla este usuario, solo se pierde su renovación
SAVEPOINT sp_usuario_actual;
DBMS_OUTPUT.PUT_LINE('  [SAVEPOINT ' || v_sp_name || '] Usuario: ' || v_reg.nombre);

BEGIN
            -- Obtener nuevo ID de pago
SELECT NVL(MAX(id_pago), 0) + 1 INTO v_nuevo_pago FROM Pago;

-- Registrar el pago de renovación
INSERT INTO Pago (
    id_pago, fecha_pago, monto, metodo_pago,
    estado_pago, valor_descuento, suscripcion_id_suscripcion
) VALUES (
             v_nuevo_pago,
             SYSDATE,
             v_reg.monto_cobrar,
             'Tarjeta crédito',
             'Exitoso',
             v_reg.costo - v_reg.monto_cobrar,  -- Descuento por antigüedad
             v_reg.id_suscripcion
         );

-- Renovar la suscripción
UPDATE suscripcion
SET fecha_vencimiento = ADD_MONTHS(SYSDATE, 1),
    estado            = 'Activa'
WHERE id_suscripcion = v_reg.id_suscripcion;

-- Mantener cuenta activa
UPDATE Usuario
SET estado_cuenta_activa = 'Activa'
WHERE id_usuario = v_reg.id_usuario;

v_exitosos := v_exitosos + 1;
            DBMS_OUTPUT.PUT_LINE('  [OK] ' || v_reg.nombre ||
                                 ' → $' || v_reg.monto_cobrar || ' cobrado');

EXCEPTION
            WHEN OTHERS THEN
                -- Revertir SOLO este usuario, los anteriores quedan guardados
                ROLLBACK TO sp_usuario_actual;
                v_fallidos := v_fallidos + 1;
                DBMS_OUTPUT.PUT_LINE('  [ERROR] ' || v_reg.nombre ||
                                     ' → Revertido: ' || SQLERRM);
END;
END LOOP;

    -- ── CONFIRMAR todos los usuarios que se procesaron bien
COMMIT;
DBMS_OUTPUT.PUT_LINE('[CONFIRMADA] Renovación completada.');
    DBMS_OUTPUT.PUT_LINE('  Procesados : ' || v_procesados);
    DBMS_OUTPUT.PUT_LINE('  Exitosos   : ' || v_exitosos);
    DBMS_OUTPUT.PUT_LINE('  Fallidos   : ' || v_fallidos);
    DBMS_OUTPUT.PUT_LINE('  (Los fallidos fueron revertidos con ROLLBACK TO SAVEPOINT)');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[ABORTADA] Error grave: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================================
-- c) TRANSACCIÓN 3: ELIMINACIÓN DE CUENTA (todo o nada)
-- Elimina: calificaciones, favoritos, reproducciones,
--          perfiles, reportes, pagos, suscripción y usuario
-- Si falla cualquier DELETE → ROLLBACK completo
--
-- NOTA: Se usa con CASCADE habilitado via procedimiento para
--       mantener el historial de pagos según ley → solo se marca Inactiva
-- =====================================================================

DECLARE
p_id_usuario CONSTANT NUMBER := 31; 
    v_count      NUMBER;

BEGIN
    -- Verificar que el usuario existe
SELECT COUNT(*) INTO v_count FROM Usuario WHERE id_usuario = p_id_usuario;

IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Usuario ' || p_id_usuario || ' no existe. Transacción no necesaria.');
        RETURN;
END IF;

    DBMS_OUTPUT.PUT_LINE('=== TRANSACCIÓN 3: ELIMINACIÓN DE CUENTA ===');
    DBMS_OUTPUT.PUT_LINE('[ACTIVA] Iniciando eliminación del usuario ' || p_id_usuario);

    -- PASO 1: Eliminar calificaciones de todos sus perfiles
DELETE FROM Calificacion
WHERE Perfil_id_perfil IN (
    SELECT id_perfil FROM Perfil WHERE Usuario_id_usuario = p_id_usuario
);
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 1: ' || SQL%ROWCOUNT || ' calificación(es) eliminada(s)');

    -- PASO 2: Eliminar favoritos de todos sus perfiles
DELETE FROM Favorito
WHERE Perfil_id_perfil IN (
    SELECT id_perfil FROM Perfil WHERE Usuario_id_usuario = p_id_usuario
);
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 2: ' || SQL%ROWCOUNT || ' favorito(s) eliminado(s)');

    -- PASO 3: Eliminar reportes de sus perfiles
DELETE FROM Reporte
WHERE Perfil_id_perfil IN (
    SELECT id_perfil FROM Perfil WHERE Usuario_id_usuario = p_id_usuario
);
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 3: ' || SQL%ROWCOUNT || ' reporte(s) eliminado(s)');

    -- PASO 4: Eliminar reproducciones de sus perfiles
DELETE FROM Reproduccion
WHERE Perfil_id_perfil IN (
    SELECT id_perfil FROM Perfil WHERE Usuario_id_usuario = p_id_usuario
);
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 4: ' || SQL%ROWCOUNT || ' reproducción(es) eliminada(s)');

    -- PASO 5: Eliminar los perfiles
DELETE FROM Perfil WHERE Usuario_id_usuario = p_id_usuario;
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 5: ' || SQL%ROWCOUNT || ' perfil(es) eliminado(s)');

    -- PASO 6: Marcar pagos históricos como auditados (no se eliminan por ley)
    -- En lugar de DELETE, se registra en logs (aquí solo se documenta la política)
    DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 6: Pagos conservados por política de auditoría financiera');

    -- PASO 7: Marcar la suscripción como inactiva
UPDATE suscripcion
SET estado = 'Inactiva'
WHERE Usuario_id_usuario = p_id_usuario;
DBMS_OUTPUT.PUT_LINE('[ACTIVA] Paso 7: ' || SQL%ROWCOUNT || ' suscripción(es) desactivada(s)');

    -- PASO 8: Marcar la cuenta como inactiva (REGLA: no se borra, solo se desactiva)
UPDATE Usuario
SET estado_cuenta_activa = 'Inactiva'
WHERE id_usuario = p_id_usuario;
DBMS_OUTPUT.PUT_LINE('[PARCIALMENTE CONFIRMADA] Paso 8: Cuenta marcada como Inactiva');

    -- ── CONFIRMAR toda la transacción ─────────────────────────────
COMMIT;
DBMS_OUTPUT.PUT_LINE('[CONFIRMADA] Eliminación de cuenta completada.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[ABORTADA] Error en eliminación: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('[ABORTADA] ROLLBACK: La cuenta permanece intacta.');
        RAISE;
END;
/

-- SESIÓN A (ejecutar primero):
/*

SET SERVEROUTPUT ON;
DECLARE
    v_id_sus NUMBER;
    v_plan NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('SESIÓN A: Iniciando bloqueo usuario 5...');
    
    SELECT id_suscripcion, Plan_suscripcion_id_plan
    INTO v_id_sus, v_plan
    FROM suscripcion
    WHERE Usuario_id_usuario = 3
      AND estado = 'Activa'
    FOR UPDATE;
    
    DBMS_OUTPUT.PUT_LINE('SESIÓN A: Bloqueo adquirido. Esperando 10 segundos...');
    DBMS_LOCK.SLEEP(15);
    
    UPDATE suscripcion
    SET Plan_suscripcion_id_plan = 3
    WHERE Usuario_id_usuario = 3 AND estado = 'Activa';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SESIÓN A: COMMIT realizado. Bloqueo liberado.');
END;
/

SET SERVEROUTPUT ON;

DECLARE
    v_id_sus NUMBER;
    v_plan NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('SESIÓN B: Intentando cambiar plan del mismo usuario 5...');
    
    SELECT id_suscripcion, Plan_suscripcion_id_plan
    INTO v_id_sus, v_plan
    FROM suscripcion
    WHERE Usuario_id_usuario = 3
      AND estado = 'Activa'
    FOR UPDATE NOWAIT;
    
    DBMS_OUTPUT.PUT_LINE('SESIÓN B: Bloqueo obtenido.');
    
    UPDATE suscripcion
    SET Plan_suscripcion_id_plan = 2
    WHERE Usuario_id_usuario = 3 AND estado = 'Activa';
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SESIÓN B ERROR: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Oracle bloqueó la fila. Sesión A tiene el control.');
        DBMS_OUTPUT.PUT_LINE('Resolución: Sesión B debe esperar o reintentar.');
        ROLLBACK;
END;
/
*/

-- ===================================================================
-- 7.5 ÍNDICES
-- Analizar elementos que influyen en la calidad
-- ===================================================================
-- CREACIÓN Y ADMINISTRACIÓN DE ÍNDICES (mínimo 4)
-- ===================================================================
-- ÍNDICE 1: REPRODUCCIONES(id_perfil, fecha_hora_inicio)
-- JUSTIFICACIÓN:
-- La consulta más frecuente del sistema es el historial de reproducciones
-- de un perfil en un rango de fechas (SP_REPORTE_CONSUMO, recomendaciones).
-- Sin índice: Oracle haría un FULL TABLE SCAN sobre 200+ (millones en prod.)
-- Con índice compuesto: acceso directo por perfil y luego ordenado por fecha,
-- lo que permite range scans eficientes y evita sorts adicionales.
-- ==================================================================

DROP INDEX IDX_REPROD_PERFIL_FECHA;

CREATE INDEX IDX_REPROD_PERFIL_FECHA
    ON Reproduccion (Perfil_id_perfil, fecha_inicio);
    
--prueba
EXPLAIN PLAN FOR
SELECT * FROM Reproduccion 
WHERE Perfil_id_perfil = 1 
AND fecha_inicio BETWEEN TIMESTAMP '2024-01-01 00:00:00' AND TIMESTAMP '2024-12-31 00:00:00';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- =====================================================================
-- ÍNDICE 2: USUARIOS(email)
-- JUSTIFICACIÓN:
-- El email es el campo de autenticación principal (login) y también
-- se valida unicidad en SP_REGISTRAR_USUARIO con un SELECT COUNT(*).
-- Sin índice: cada login haría FULL TABLE SCAN sobre toda la tabla de usuarios.
-- Con índice UNIQUE: garantiza unicidad a nivel de BD Y acelera el login
-- al ser una búsqueda de igualdad exacta (B-tree óptimo para esto).
-- =====================================================================

-- Eliminar el constraint previo si existe para reemplazar con índice explícito
-- ALTER TABLE Usuario DROP CONSTRAINT unq_email;  -- Si existía

DROP INDEX IDX_USUARIO_EMAIL;

CREATE UNIQUE INDEX IDX_USUARIO_EMAIL
    ON Usuario (UPPER(email));   -- Función-based: email case-insensitive
    
--prueba 
EXPLAIN PLAN FOR
SELECT * FROM Usuario 
WHERE UPPER(email) = UPPER('andres.m@email.com');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- =====================================================================
-- ÍNDICE 3: CONTENIDO(id_categoria = tipo_contenido, anio_lanzamiento)
-- JUSTIFICACIÓN:
-- El catálogo de QuindioFlix se filtra constantemente por tipo de contenido
-- (Películas, Series, etc.) y año de lanzamiento (contenido nuevo/clásico).
-- Sin índice: cada búsqueda en catálogo escanea los 40 títulos (millones en prod.).
-- Con índice compuesto: las búsquedas como "Películas de 2023" son index range scans.
-- =====================================================================


DROP INDEX IDX_CONTENIDO_TIPO_ANIO;

CREATE INDEX IDX_CONTENIDO_TIPO_ANIO
    ON contenido (tipo_contenido, anio_lanzamiento);
    
EXPLAIN PLAN FOR
SELECT * FROM contenido 
WHERE tipo_contenido = 'PELICULA'
AND anio_lanzamiento = 2023;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- =====================================================================
-- ÍNDICE 4 (elección propia): PAGO(suscripcion_id, estado_pago, fecha_pago)
-- JUSTIFICACIÓN:
-- El reporte financiero mensual (MV_INGRESOS_MENSUALES) y las validaciones
-- de mora consultan pagos filtrando por suscripción + estado + fecha.
-- Sin índice: FULL TABLE SCAN sobre 80+ pagos (millones en producción).
-- Con índice compuesto: permite index range scans para el patrón de consulta
-- más frecuente: "pagos exitosos de la suscripción X en el mes Y".
-- También acelera TRG_PAGO_ACTIVA_CUENTA que busca pagos de hoy.
-- =====================================================================
DROP INDEX IDX_PAGO_SUS_EST_FECHA;


CREATE INDEX IDX_PAGO_SUS_EST_FECHA
    ON Pago (suscripcion_id_suscripcion, estado_pago, fecha_pago DESC);

EXPLAIN PLAN FOR
SELECT * FROM Pago 
WHERE suscripcion_id_suscripcion = 1
AND estado_pago = 'Exitoso'
AND fecha_pago >= DATE '2024-01-01';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-----------------------------------
--Verificación
-----------------------------------

SELECT index_name, table_name, status
FROM user_indexes
WHERE index_name IN (
    'IDX_REPROD_PERFIL_FECHA',
    'IDX_USUARIO_EMAIL',
    'IDX_CONTENIDO_TIPO_ANIO',
    'IDX_PAGO_SUS_EST_FECHA'
)
ORDER BY index_name;



