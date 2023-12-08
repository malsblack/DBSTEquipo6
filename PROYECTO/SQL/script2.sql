CREATE DATABASE ProyectoDBST

USE ProyectoDBST

---Tablas que son principales

CREATE TABLE Recepcion(
	ID_Recepcion nvarchar(50) primary key
,	Nombre nvarchar(50)
,	Ap_Pat nvarchar(50)
,	Ap_Mat nvarchar(50)
,	Contacto nvarchar(50)
,	Contraseña nvarchar(50)
);

CREATE TABLE Paciente(
	ID_Paciente nvarchar(50) primary key
,	Nombre nvarchar(50)
,	Ap_Pat nvarchar(50)
,	Ap_Mat nvarchar(50)
,	Contacto nvarchar(50)
,	FechaNac date
,	Sexo char (1)
,	Contraseña nvarchar(50)
);

CREATE TABLE Especialidad(
	ID_Especialidad int primary key
,	Nombre nvarchar(50)
);

CREATE TABLE Medico(
	ID_Medico nvarchar(50) primary key
,	Nombre nvarchar(50)
,	Ap_Pat nvarchar(50)
,	Ap_Mat nvarchar(50)
,	Contacto nvarchar(50)
,	Cosnultorio int
,	Contraseña nvarchar(50)
,	ID_Especialidad int
	FOREIGN KEY (ID_Especialidad) REFERENCES Especialidad(ID_Especialidad)
);

CREATE TABLE Cita(
	ID_Cita int primary key
,	FechaAtencion date
,	HoraAtencion time
,	Estatus nvarchar(50)
,	Costo int
,	ID_Recepcion nvarchar(50)
,	ID_Paciente nvarchar(50)
,	ID_Medico nvarchar(50)
	FOREIGN KEY (ID_Recepcion) REFERENCES Recepcion(ID_Recepcion)
,	FOREIGN KEY (ID_Paciente) REFERENCES Paciente(ID_Paciente)
,	FOREIGN KEY (ID_Medico) REFERENCES Medico(ID_Medico)
);

---Tablas que son dependientes

CREATE TABLE MenuServicios(
	ID_Servicios int primary key
,	NombreServicio varchar (50)
,	Costo int
,	ID_Recepcion nvarchar(50)
	FOREIGN KEY (ID_Recepcion) REFERENCES Recepcion(ID_Recepcion)
);

CREATE TABLE Receta(
	ID_Receta int primary key
,	Diagnostico nvarchar (500)
,	FechaEmision date
,	ID_Medico nvarchar(50)
	FOREIGN KEY (ID_Medico) REFERENCES Medico(ID_Medico)
);

CREATE TABLE DetalleReceta(
	NombreMedicamento nvarchar(50)
,	Dosis nvarchar(50)
,	ID_Receta int
	FOREIGN KEY (ID_Receta) REFERENCES Receta(ID_Receta)
);

CREATE TABLE HistorialClinico(
	ID_Historial int primary key
,	FechaRegistro date
,	ID_Cita int
	FOREIGN KEY (ID_Cita) REFERENCES Cita(ID_Cita)
);

CREATE TABLE Farmacia(
	ID_TransacFarmacia int primary key
,	Total int
,	ID_Cita int
	FOREIGN KEY (ID_Cita) REFERENCES Cita(ID_Cita)
);

CREATE TRIGGER ActualizarHistorialClinico
ON Cita
AFTER INSERT
AS
BEGIN
    INSERT INTO HistorialClinico (FechaRegistro, ID_Cita)
    SELECT GETDATE(), ID_Cita
    FROM INSERTED;
END;

CREATE FUNCTION GenerarID
(
    @Tabla varchar(50),
    @Apellido nvarchar(50)
)
RETURNS varchar(50) 
AS
BEGIN
    DECLARE @Prefix nvarchar(3);
    SET @Prefix = SUBSTRING(@Tabla, 1, 3);
    
    DECLARE @ID nvarchar(50);

    SELECT @ID = 
        @Prefix +
        CASE 
            WHEN @Tabla = 'Paciente' THEN  CAST((SELECT COUNT(*) + 1 FROM Paciente) AS nvarchar)
            WHEN @Tabla = 'Medico' THEN  CAST((SELECT COUNT(*) + 1 FROM Medico) AS nvarchar)
            WHEN @Tabla = 'Recepcion' THEN  CAST((SELECT COUNT(*) + 1 FROM Recepcion) AS nvarchar)
        
        END +
        @Apellido;

    RETURN @ID;
END;










CREATE PROCEDURE InsertarDatos
    @Nombre nvarchar(50),
    @Ap_Pat nvarchar(50),
    @Ap_Mat nvarchar(50),
    @Contacto nvarchar(50),
    @FechaNac date,
    @Sexo char(1),
    @Contraseña nvarchar(50),
    @TipoTabla nvarchar(50)
AS
BEGIN
    DECLARE @ID nvarchar(50);

    -- Generar ID alfanumérico
    SET @ID = dbo.GenerarID(@TipoTabla, @Ap_Pat);

    -- Insertar en la tabla correspondiente
    IF @TipoTabla = 'Paciente'
        INSERT INTO Paciente (ID_Paciente, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo, Contraseña)
        VALUES (@ID, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @FechaNac, @Sexo, @Contraseña);
    ELSE IF @TipoTabla = 'Medico'
        INSERT INTO Medico (ID_Medico, Nombre, Ap_Pat, Ap_Mat, Contacto, Contraseña)
        VALUES (@ID, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @Contraseña);
    ELSE IF @TipoTabla = 'Recepcion'
        INSERT INTO Recepcion (ID_Recepcion, Nombre, Ap_Pat, Ap_Mat, Contacto, Contraseña)
        VALUES (@ID, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @Contraseña);
END;

CREATE PROCEDURE EditarDatos
    @ID nvarchar(50),
    @NuevoNombre nvarchar(50),
    @NuevoAp_Pat nvarchar(50),
    @NuevoAp_Mat nvarchar(50),
    @NuevoContacto nvarchar(50),
    @NuevoContraseña nvarchar(50),
    @TipoTabla nvarchar(50)
AS
BEGIN
    -- Actualizar en la tabla correspondiente
    IF @TipoTabla = 'Paciente'
        UPDATE Paciente
        SET Nombre = @NuevoNombre, Ap_Pat = @NuevoAp_Pat, Ap_Mat = @NuevoAp_Mat, Contacto = @NuevoContacto, Contraseña = @NuevoContraseña
        WHERE ID_Paciente = @ID;
    ELSE IF @TipoTabla = 'Medico'
        UPDATE Medico
        SET Nombre = @NuevoNombre, Ap_Pat = @NuevoAp_Pat, Ap_Mat = @NuevoAp_Mat, Contacto = @NuevoContacto, Contraseña = @NuevoContraseña
        WHERE ID_Medico = @ID;
    ELSE IF @TipoTabla = 'Recepcion'
        UPDATE Recepcion
        SET Nombre = @NuevoNombre, Ap_Pat = @NuevoAp_Pat, Ap_Mat = @NuevoAp_Mat, Contacto = @NuevoContacto, Contraseña = @NuevoContraseña
        WHERE ID_Recepcion = @ID;
END;

CREATE PROCEDURE BorrarDatos
    @ID nvarchar(50),
    @TipoTabla nvarchar(50)
AS
BEGIN
    -- Eliminar de la tabla correspondiente
    IF @TipoTabla = 'Paciente'
        DELETE FROM Paciente WHERE ID_Paciente = @ID;
    ELSE IF @TipoTabla = 'Medico'
        DELETE FROM Medico WHERE ID_Medico = @ID;
    ELSE IF @TipoTabla = 'Recepcion'
        DELETE FROM Recepcion WHERE ID_Recepcion = @ID;
END;

CREATE PROCEDURE InsertarServicio
    @Nombre nvarchar(50),
    @Costo int
AS
BEGIN
    -- Validar si el nombre del servicio ya existe y el costo es mayor a 50
    IF NOT EXISTS (SELECT 1 FROM MenuServicios WHERE NombreServicio = @Nombre) AND @Costo > 50
    BEGIN
        INSERT INTO MenuServicios (NombreServicio, Costo)
        VALUES (@Nombre, @Costo);
    END
    ELSE
    BEGIN
        PRINT 'Error: Nombre de servicio duplicado o costo menor o igual a 50.';
    END
END;

CREATE PROCEDURE ModificarServicio
    @ID_Servicio int,
    @NuevoNombre nvarchar(50),
    @NuevoCosto int
AS
BEGIN
    -- Validar si el nuevo nombre del servicio no existe y el nuevo costo es mayor a 50
    IF NOT EXISTS (SELECT 1 FROM MenuServicios WHERE NombreServicio = @NuevoNombre) AND @NuevoCosto > 50
    BEGIN
        UPDATE MenuServicios
        SET NombreServicio = @NuevoNombre, Costo = @NuevoCosto
        WHERE ID_Servicios = @ID_Servicio;
    END
    ELSE
    BEGIN
        PRINT 'Error: Nuevo nombre de servicio duplicado o nuevo costo menor o igual a 50.';
    END
END;

CREATE PROCEDURE EliminarServicio
    @ID_Servicio int
AS
BEGIN
    DELETE FROM MenuServicios
    WHERE ID_Servicios = @ID_Servicio;
END;

CREATE FUNCTION ValidarNombreCosto
(
    @Nombre nvarchar(50),
    @Costo int
)
RETURNS bit
AS
BEGIN
    DECLARE @Resultado bit;

    -- Validar si el nombre del servicio ya existe y el costo es mayor a 50
    IF NOT EXISTS (SELECT 1 FROM MenuServicios WHERE NombreServicio = @Nombre) AND @Costo > 50
        SET @Resultado = 1; -- Verdadero
    ELSE
        SET @Resultado = 0; -- Falso

    RETURN @Resultado;
END;

CREATE FUNCTION ValidarDisponibilidadCita
(
    @FechaAtencion date,
    @HoraAtencion time,
    @ID_Medico nvarchar(50)
)
RETURNS bit
AS
BEGIN
    DECLARE @Resultado bit;

    -- Validar si la cita está disponible
    IF NOT EXISTS (
        SELECT 1
        FROM Cita
        WHERE FechaAtencion = @FechaAtencion
          AND HoraAtencion = @HoraAtencion
          AND ID_Medico = @ID_Medico
    )
        SET @Resultado = 1; -- Verdadero (disponible)
    ELSE
        SET @Resultado = 0; -- Falso (ocupada)

    RETURN @Resultado;
END;

CREATE PROCEDURE InsertarCita
    @FechaAtencion date,
    @HoraAtencion time,
    @Estatus nvarchar(50),
    @Costo int,
    @ID_Recepcion nvarchar(50),
    @ID_Paciente nvarchar(50),
    @ID_Medico nvarchar(50)
AS
BEGIN
    -- Validar disponibilidad de la cita
    IF dbo.ValidarDisponibilidadCita(@FechaAtencion, @HoraAtencion, @ID_Medico) = 1
    BEGIN
        -- Insertar la cita si está disponible
        INSERT INTO Cita (FechaAtencion, HoraAtencion, Estatus, Costo, ID_Recepcion, ID_Paciente, ID_Medico)
        VALUES (@FechaAtencion, @HoraAtencion, @Estatus, @Costo, @ID_Recepcion, @ID_Paciente, @ID_Medico);
    END
    ELSE
    BEGIN
        PRINT 'Error: La cita ya está ocupada en la fecha y hora especificadas.';
    END
END;
