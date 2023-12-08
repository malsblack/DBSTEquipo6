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
    @Tabla nvarchar(50),
    @Apellido nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @Prefix nvarchar(3);
    SET @Prefix = SUBSTRING(@Tabla, 1, 3);
    
    DECLARE @ID nvarchar(50);
    SET @ID = @Prefix + CAST((SELECT COUNT(*) + 1 FROM @Tabla) AS nvarchar) + @Apellido;

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
