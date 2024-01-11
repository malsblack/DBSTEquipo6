CREATE PROCEDURE SP_AgregarPaciente
    @Nombre VARCHAR(50),
    @Ap_Pat VARCHAR(50),
    @Ap_Mat VARCHAR(50),
    @Contacto VARCHAR(50),
    @FechaNac DATE,
    @Sexo CHAR(1),
    @Contrasena VARCHAR(50)
AS
BEGIN
    DECLARE @ID_Paciente VARCHAR(50);
    SET @ID_Paciente = dbo.GenerarIDPaciente(@Nombre, @Ap_Pat, @Ap_Mat, @FechaNac);

    INSERT INTO Paciente (ID_Paciente, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo, Contrasena)
    VALUES (@ID_Paciente, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @FechaNac, @Sexo, @Contrasena);
END;
GO

CREATE PROCEDURE SP_ActualizarPaciente
    @ID_Paciente VARCHAR(50),
    @Nombre VARCHAR(50) = NULL,
    @Ap_Pat VARCHAR(50) = NULL,
    @Ap_Mat VARCHAR(50) = NULL,
    @Contacto VARCHAR(50) = NULL,
    @FechaNac DATE = NULL,
    @Sexo CHAR(1) = NULL,
    @Contrasena VARCHAR(50) = NULL
AS
BEGIN
	
    IF @Nombre IS NOT NULL
        UPDATE Paciente SET Nombre = @Nombre WHERE ID_Paciente = @ID_Paciente;

    IF @Ap_Pat IS NOT NULL
        UPDATE Paciente SET Ap_Pat = @Ap_Pat WHERE ID_Paciente = @ID_Paciente;

    IF @Ap_Mat IS NOT NULL
        UPDATE Paciente SET Ap_Mat = @Ap_Mat WHERE ID_Paciente = @ID_Paciente;

    IF @Contacto IS NOT NULL
        UPDATE Paciente SET Contacto = @Contacto WHERE ID_Paciente = @ID_Paciente;

    IF @FechaNac IS NOT NULL
        UPDATE Paciente SET FechaNac = @FechaNac WHERE ID_Paciente = @ID_Paciente;

    IF @Sexo IS NOT NULL
        UPDATE Paciente SET Sexo = @Sexo WHERE ID_Paciente = @ID_Paciente;

    IF @Contrasena IS NOT NULL
        UPDATE Paciente SET Contrasena = @Contrasena WHERE ID_Paciente = @ID_Paciente;
END;
GO

CREATE PROCEDURE SP_EliminarPaciente
    @ID_Paciente VARCHAR(50)
AS
BEGIN
    
    DELETE FROM Paciente WHERE ID_Paciente = @ID_Paciente;
END;
GO

CREATE PROCEDURE SP_AgregarDoctor
    @Nombre VARCHAR(50),
    @Ap_Pat VARCHAR(50),
    @Ap_Mat VARCHAR(50),
    @Contacto VARCHAR(50),
    @FechaNac DATE,
    @Sexo CHAR(1),
    @Contrasena VARCHAR(50),
    @ID_Consultorio VARCHAR(5),
    @ID_Especialidad INT
AS
BEGIN
    DECLARE @ID_Doctor VARCHAR(50);
    SET @ID_Doctor = dbo.GenerarIDDoctor(@Nombre, @Ap_Pat, @Ap_Mat, @FechaNac, @ID_Especialidad);

    INSERT INTO Doctor (ID_Doctor, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo, Contrasena, ID_Consultorio, ID_Especialidad)
    VALUES (@ID_Doctor, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @FechaNac, @Sexo, @Contrasena, @ID_Consultorio, @ID_Especialidad);
END;
GO

CREATE PROCEDURE SP_ActualizarDoctor 
     @ID_Doctor VARCHAR(50)
,    @Nombre VARCHAR(50) = NULL
,    @Ap_Pat VARCHAR(50) = NULL
,    @Ap_Mat VARCHAR(50) = NULL
,    @Contacto VARCHAR(50) = NULL
,    @FechaNac DATE = NULL
,    @Sexo CHAR(1) = NULL
,    @Contrasena VARCHAR(50) = NULL
,	 @ID_Consultorio VARCHAR(50) = NULL
,	 @ID_Especialidad VARCHAR(50) = NULL
AS
BEGIN
	
    IF @Nombre IS NOT NULL
        UPDATE Doctor SET Nombre = @Nombre WHERE ID_Doctor = @ID_Doctor;

    IF @Ap_Pat IS NOT NULL
        UPDATE Doctor SET Ap_Pat = @Ap_Pat WHERE ID_Doctor = @ID_Doctor;

    IF @Ap_Mat IS NOT NULL
        UPDATE Doctor SET Ap_Mat = @Ap_Mat WHERE ID_Doctor = @ID_Doctor;

    IF @Contacto IS NOT NULL
        UPDATE Doctor SET Contacto = @Contacto WHERE ID_Doctor = @ID_Doctor;

    IF @FechaNac IS NOT NULL
        UPDATE Doctor SET FechaNac = @FechaNac WHERE ID_Doctor = @ID_Doctor;

    IF @Sexo IS NOT NULL
        UPDATE Doctor SET Sexo = @Sexo WHERE ID_Doctor = @ID_Doctor;

    IF @Contrasena IS NOT NULL
        UPDATE Doctor SET Contrasena = @Contrasena WHERE ID_Doctor = @ID_Doctor;

    IF @ID_Consultorio IS NOT NULL
        UPDATE Doctor SET ID_Consultorio = @ID_Consultorio WHERE ID_Doctor = @ID_Doctor;
		
    IF @ID_Especialidad IS NOT NULL
        UPDATE Doctor SET ID_Especialidad = @ID_Especialidad WHERE ID_Doctor = @ID_Doctor;
END;
GO

CREATE PROCEDURE SP_EliminarDoctor
    @ID_Doctor VARCHAR(50)
AS
BEGIN
    
    DELETE FROM Doctor WHERE ID_Doctor = @ID_Doctor;
END;
GO

CREATE PROCEDURE SP_AgregarRecepcion
    @Nombre VARCHAR(50),
    @Ap_Pat VARCHAR(50),
    @Ap_Mat VARCHAR(50),
    @Contacto VARCHAR(50),
    @FechaNac DATE,
    @Sexo CHAR(1),
    @Contrasena VARCHAR(50)
AS
BEGIN
    DECLARE @ID_Recepcion VARCHAR(50);
    SET @ID_Recepcion = dbo.GenerarIDRecepcion(@Nombre, @Ap_Pat, @Ap_Mat, @FechaNac);

    INSERT INTO Recepcion(ID_Recepcion, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo, Contrasena)
    VALUES (@ID_Recepcion, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @FechaNac, @Sexo, @Contrasena);
END;
GO

CREATE PROCEDURE SP_ActualizarRecepcion
    @ID_Recepcion VARCHAR(50),
    @Nombre VARCHAR(50) = NULL,
    @Ap_Pat VARCHAR(50) = NULL,
    @Ap_Mat VARCHAR(50) = NULL,
    @Contacto VARCHAR(50) = NULL,
    @FechaNac DATE = NULL,
    @Sexo CHAR(1) = NULL,
    @Contrasena VARCHAR(50) = NULL
AS
BEGIN
	
    IF @Nombre IS NOT NULL
        UPDATE Recepcion SET Nombre = @Nombre WHERE ID_Recepcion = @ID_Recepcion;

    IF @Ap_Pat IS NOT NULL
        UPDATE Recepcion SET Ap_Pat = @Ap_Pat WHERE ID_Recepcion = @ID_Recepcion;

    IF @Ap_Mat IS NOT NULL
        UPDATE Recepcion SET Ap_Mat = @Ap_Mat WHERE ID_Recepcion = @ID_Recepcion;

    IF @Contacto IS NOT NULL
        UPDATE Recepcion SET Contacto = @Contacto WHERE ID_Recepcion = @ID_Recepcion;

    IF @FechaNac IS NOT NULL
        UPDATE Recepcion SET FechaNac = @FechaNac WHERE ID_Recepcion = @ID_Recepcion;

    IF @Sexo IS NOT NULL
        UPDATE Recepcion SET Sexo = @Sexo WHERE ID_Recepcion = @ID_Recepcion;

    IF @Contrasena IS NOT NULL
        UPDATE Recepcion SET Contrasena = @Contrasena WHERE ID_Recepcion = @ID_Recepcion;
END;
GO

CREATE PROCEDURE SP_EliminarRecepcion
    @ID_Recepcion VARCHAR(50)
AS
BEGIN
    
    DELETE FROM Recepcion WHERE ID_Recepcion = @ID_Recepcion;
END;
GO

CREATE PROCEDURE SP_AgregarCita
    @ID_Paciente VARCHAR(50),
    @ID_Doctor VARCHAR(50),
    @ID_Recepcion VARCHAR(50),
    @FechaAtencion date,
    @HoraAtencion time,
    @Estatus CHAR(1),
    @Costo INT,
    @desc_servicio varchar(50)
AS
BEGIN
    DECLARE @ID_Cita VARCHAR(27);
    SET @ID_Cita = dbo.GenerarIDCita(@FechaAtencion, @HoraAtencion, @ID_Paciente);

    INSERT INTO Cita (ID_Cita, ID_Paciente, ID_Doctor, ID_Recepcion, desc_servicio,FechaAtencion, HoraAtencion, Estatus, Costo)
    VALUES (@ID_Cita, @ID_Paciente, @ID_Doctor, @ID_Recepcion,@desc_servicio ,@FechaAtencion, @HoraAtencion, @Estatus, @Costo);
END;
GO




