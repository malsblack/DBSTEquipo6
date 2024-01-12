CREATE DATABASE PROYECTODBST1
USE PROYECTODBST1

CREATE TABLE Paciente (
  ID_Paciente VARCHAR(50) PRIMARY KEY,
  Nombre VARCHAR(50),
  Ap_Pat VARCHAR(50),
  Ap_Mat VARCHAR(50),
  Contacto VARCHAR(50),
  FechaNac DATE,
  Sexo CHAR(1),
  Contrasena VARCHAR(50)
);

CREATE TABLE Farmacia (
  ID_Medicamento INT PRIMARY KEY,
  Precio INT,
  Existencia INT,
  Nombre VARCHAR(100)
);

CREATE TABLE Especialidad (
  ID_Especialidad INT PRIMARY KEY,
  Nombre VARCHAR(50)
);

CREATE TABLE Recepcion (
  ID_Recepcion VARCHAR(50) PRIMARY KEY,
  Nombre VARCHAR(50),
  Ap_Pat VARCHAR(50),
  Ap_Mat VARCHAR(50),
  Contacto VARCHAR(50),
  FechaNac DATE,
  Sexo CHAR(1),
  Contrasena VARCHAR(50)
);

----Crear estas tablas despu�s

CREATE TABLE Doctor (
  ID_Doctor VARCHAR(50) PRIMARY KEY,
  Nombre VARCHAR(50),
  Ap_Pat VARCHAR(50),
  Ap_Mat VARCHAR(50),
  Contacto VARCHAR(50),
  FechaNac DATE,
  Sexo CHAR(1),
  Contrasena VARCHAR(50),
  ID_Consultorio VARCHAR(5),
  ID_Especialidad INT REFERENCES Especialidad(ID_Especialidad)
);

CREATE TABLE Cita (
  ID_Cita VARCHAR(27) PRIMARY KEY,
  ID_Paciente VARCHAR(50) REFERENCES Paciente(ID_Paciente),
  ID_Doctor VARCHAR(50) REFERENCES Doctor(ID_Doctor),
  ID_Recepcion VARCHAR(50) REFERENCES Recepcion(ID_Recepcion),
  FechaAtencion DATE,
  HoraAtencion TIME,
  Estatus CHAR(1),
  Costo INT,
  desc_servicio VARCHAR(50)
);

CREATE TABLE Servicios (
  ID_Servicios INT PRIMARY KEY,
  ID_Especialidad INT REFERENCES Especialidad(ID_Especialidad),
  Nombre VARCHAR(50),
  Costo INT
);

CREATE TABLE Receta (
  ID_Receta VARCHAR(28) PRIMARY KEY,
  ID_Cita VARCHAR(27) REFERENCES Cita(ID_Cita),
  ID_DetalleReceta VARCHAR(29),
  Diagnostico VARCHAR(100),
  Tratamiento VARCHAR(1000),
  FechaEmision DATE
);

CREATE TABLE DetalleReceta (
  ID_DetalleReceta VARCHAR(29) PRIMARY KEY,
  ID_Receta VARCHAR(28) REFERENCES Receta(ID_Receta),
  ID_Medicamento INT REFERENCES Farmacia(ID_Medicamento),
  Cantidad INT,
  PrecioUnitario INT,
  Subtotal INT
);

----Funciones

----Crear una funci�n para el ID del paciente

CREATE FUNCTION GenerarIDPaciente(
	@Nombre VARCHAR (50)
,	@Ap_Pat VARCHAR (50)
,	@Ap_Mat VARCHAR (50)
,	@FechaNac DATE
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @Iniciales VARCHAR(3), @Fecha VARCHAR(4), @Distintivo VARCHAR(10), @DistintivoTabla INT

	----Primera parte: Agarra las Iniciales del Nombre, Apellido paterno y Apellido materno
	SET @Iniciales = LEFT(@Nombre, 1) + LEFT(@Ap_Pat, 1) + LEFT(@Ap_Mat, 1)

	----Segunda parte: Agarra el d�a y el mes de la fecha de nacimiento
	SET @Fecha = FORMAT(@FechaNac, 'ddMM')

	----Tercera parte: En primero valida si despues de la primera y segunda parte hay duplicidad y sino hay otro elemento igual se genera el primer registro o se incrementa en uno a los registros que ya esta en la tabla
	SELECT @DistintivoTabla = (COALESCE(MAX(CAST(RIGHT(ID_Paciente, LEN(ID_Paciente) - 7) AS INT)), 0) + 1)
	FROM Paciente WHERE LEFT(ID_Paciente, 7) = @Iniciales + @Fecha
	SET @Distintivo = CAST (@DistintivoTabla AS VARCHAR(43))

	----Junta todo, la primera, segunda y tercera parte
	SET @ID = @Iniciales + @Fecha + @Distintivo

	RETURN @ID
END;

----Crear una funci�n para el ID Doctor

CREATE FUNCTION GenerarIDDoctor(
	@Nombre VARCHAR (50)
,	@Ap_Pat VARCHAR (50)
,	@Ap_Mat VARCHAR (50)
,	@FechaNac DATE
,	@Especialidad INT
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @Iniciales VARCHAR(3), @Fecha VARCHAR(4), @ID_Especialidad VARCHAR(2), @Distintivo VARCHAR(10), @DistintivoTabla INT

	----Primera parte: Agarra las Iniciales del Nombre, Apellido paterno y Apellido materno
	SET @Iniciales = LEFT(@Nombre, 1) + LEFT(@Ap_Pat, 1) + LEFT(@Ap_Mat, 1)

	----Segunda parte: Agarra el a�o de la fecha de nacimiento
	SET @Fecha = FORMAT(@FechaNac, 'yyyy')

	----Tercera parte: Se valida el ID que tiene la especialidad y se guarda en la variable 
	SELECT @ID_Especialidad = @Especialidad
	FROM Especialidad WHERE Especialidad.ID_Especialidad	 = @Especialidad
	SET @ID_Especialidad = CAST (@ID_Especialidad AS VARCHAR(2))
		
	----Cuarta parte: En primero valida si despues de la primera, segunda y tercera parte hay duplicidad y sino hay otro elemento igual se genera el primer registro o se incrementa en uno a los registros que ya esta en la tabla
	SELECT @DistintivoTabla = (COALESCE(MAX(CAST(RIGHT(ID_Doctor, LEN(ID_Doctor) - 9) AS INT)), 0) + 1)
	FROM Doctor WHERE LEFT(ID_Doctor, 9) = @Iniciales + @Fecha
	SET @Distintivo = CAST (@DistintivoTabla AS VARCHAR(41))

	----Juntar todo
	SET @ID = @Iniciales + @Fecha + @ID_Especialidad + @Distintivo

	RETURN @ID
END;

----Crear una funci�n para el ID Recepcion

CREATE FUNCTION GenerarIDRecepcion(
	@Nombre VARCHAR (50)
,	@Ap_Pat VARCHAR (50)
,	@Ap_Mat VARCHAR (50)
,	@FechaNac DATE
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @Iniciales VARCHAR(3), @Fecha VARCHAR(4), @Distintivo VARCHAR(10), @DistintivoTabla INT

	----Primera parte: Agarra las Iniciales del Nombre, Apellido paterno y Apellido materno
	SET @Iniciales = LEFT(@Nombre, 1) + LEFT(@Ap_Pat, 1) + LEFT(@Ap_Mat, 1)

	----Segunda parte: Agarra el a�o de la fecha de nacimiento
	SET @Fecha = FORMAT(@FechaNac, 'yyyy')
		
	----Cuarta parte: En primero valida si despues de la primera, segunda y tercera parte hay duplicidad y sino hay otro elemento igual se genera el primer registro o se incrementa en uno a los registros que ya esta en la tabla
	SELECT @DistintivoTabla = (COALESCE(MAX(CAST(RIGHT(ID_Recepcion, LEN(ID_Recepcion) - 9) AS INT)), 0) + 1)
	FROM Recepcion WHERE LEFT(ID_Recepcion, 9) = 'RC' + @Iniciales + @Fecha
	SET @Distintivo = CAST (@DistintivoTabla AS VARCHAR(41))

	----Juntar todo
	SET @ID = 'RC' + @Iniciales + @Fecha + @Distintivo

	RETURN @ID
END;

----Crear una funci�n para el ID Cita

CREATE FUNCTION GenerarIDCita(
	@FechaAtencion DATE
,	@HoraAtencion TIME
,	@ID_Paciente VARCHAR (50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @Fecha VARCHAR(8), @Hora VARCHAR(2)

	----Primera parte: Ajusta el formato de a�o, mes y d�a de la cita 
	SET @Fecha = FORMAT(@FechaAtencion, 'yyyyMMdd')
	
	----Segunda parte: Extrae la hora de la cita
	SET @Hora = DATEPART(HOUR, @HoraAtencion);

	----Juntar todo
	SET @ID = @Fecha + @Hora + @ID_Paciente

	RETURN @ID
END;

----Crear una funci�n para el ID Receta

CREATE FUNCTION GenerarIDReceta(
	@ID_Cita VARCHAR (50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50)
	----Juntar todo
	SET @ID = 'R' + @ID_Cita

	RETURN @ID
END;

----Crear una funci�n para el ID Detalle Receta

CREATE FUNCTION GenerarIDDetalleReceta(
	@ID_Cita VARCHAR (50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50)
	----Juntar todo
	SET @ID = 'RE' + @ID_Cita

	RETURN @ID
END;

----Bitacora con triggers

CREATE TABLE Bitacora (
  ID_Bitacora INT PRIMARY KEY IDENTITY(1,1),
  Fecha DATE,
  Hora TIME,
  ID_Usuario VARCHAR(50),
  Accion VARCHAR(50),
  TablaAfectada VARCHAR(50),
  Descripcion VARCHAR(1000)
);

----Trigger AgregarPaciente
CREATE TRIGGER AgregarPaciente
ON Paciente
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Agregar', 'Paciente', 'Se agrego el paciente con ID: ' + ID_Paciente
  FROM INSERTED 
END;

----Trigger ActualizarPaciente
CREATE TRIGGER ActualizarPaciente
ON Paciente
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Actualizar', 'Paciente'
  FROM INSERTED 
END;

----Trigger BorrarPaciente
CREATE TRIGGER BorrarPaciente
ON Paciente
FOR DELETE 
AS
BEGIN
  ---SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Borrar', 'Paciente', 'Se borro el paciente con ID: ' + ID_Paciente
  FROM DELETED 
END;

----Trigger AgregarDoctor
CREATE TRIGGER AgregarDoctor
ON Doctor
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Agregar', 'Doctor', 'Se agrego el Doctor con ID: ' + ID_Doctor
  FROM INSERTED 
END;

----Trigger ActualizarDoctor
CREATE TRIGGER ActualizarDoctor
ON Doctor
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Actualizar', 'Doctor'
  FROM INSERTED 
END;

----Trigger BorrarDoctor
CREATE TRIGGER BorrarDoctor
ON Doctor
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Borrar', 'Doctor', 'Se borro el Doctor con ID: ' + ID_Doctor
  FROM DELETED 
END;

----Trigger AgregarRecepci�n
CREATE TRIGGER AgregarRecepcion
ON Recepcion
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Agregar', 'Recepcion', 'Se agrego el Recepcionista con ID: ' + ID_Recepcion
  FROM INSERTED 
END;

----Trigger ActualizarRecepci�n
CREATE TRIGGER ActualizarRecepcion
ON Recepcion
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Actualizar', 'Recepcion'
  FROM INSERTED 
END;

----Trigger BorrarRecepci�n
CREATE TRIGGER BorrarRecepci�n
ON Recepcion
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Bitacora (Fecha, Hora, ID_Usuario, Accion, TablaAfectada, Descripcion)
  SELECT CAST(GETDATE() AS date), CAST(GETDATE() AS time), 'MGL20052', 'Borrar', 'Recepcion', 'Se borro el Recepcionista con ID: ' + ID_Recepcion
  FROM DELETED 
END;
