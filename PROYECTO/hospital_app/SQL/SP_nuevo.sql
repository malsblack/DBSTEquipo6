USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActualizarDoctor]    Script Date: 16/01/2024 07:21:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ActualizarDoctor] 
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


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActualizarPaciente]    Script Date: 16/01/2024 07:22:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ActualizarPaciente]
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


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActualizarRecepcion]    Script Date: 16/01/2024 07:23:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ActualizarRecepcion]
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


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_AgregarCita]    Script Date: 16/01/2024 07:23:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_AgregarCita]
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


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_AgregarConsultorio]    Script Date: 16/01/2024 07:23:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_AgregarConsultorio]
    @ID_Doctor VARCHAR(50),
    @Piso VARCHAR(50)
AS
BEGIN
    DECLARE @ID_Consultorio VARCHAR(50), @NumConsultorio INT;

    -- Genera el ID del Consultorio
    SET @ID_Consultorio = dbo.GenerarIDConsultorio(@ID_Doctor, @Piso);

    -- Encuentra el número máximo de consultorio en el piso dado y le suma 1 para el nuevo consultorio
    SELECT @NumConsultorio = ISNULL(MAX(CAST(RIGHT(ID_Consultorio, LEN(ID_Consultorio) - 1) AS INT)), 0) + 1
    FROM Consultorio
    WHERE Piso = @Piso;

    -- Inserta el nuevo consultorio con el número consecutivo
    INSERT INTO Consultorio (ID_Consultorio, ID_Doctor, Piso, NumConsultorio)
    VALUES (@ID_Consultorio, @ID_Doctor, @Piso, @NumConsultorio);
END;



USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_AgregarDoctor]    Script Date: 16/01/2024 07:23:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_AgregarDoctor]
    @Nombre VARCHAR(50),
    @Ap_Pat VARCHAR(50),
    @Ap_Mat VARCHAR(50),
    @Contacto VARCHAR(50),
    @FechaNac DATE,
    @Sexo CHAR(1),
    @Contrasena VARCHAR(50),
    @ID_Consultorio VARCHAR(50),
    @ID_Especialidad INT
AS
BEGIN
    DECLARE @ID_Doctor VARCHAR(50);
    SET @ID_Doctor = dbo.GenerarIDDoctor(@Nombre, @Ap_Pat, @Ap_Mat, @FechaNac, @ID_Especialidad);

    INSERT INTO Doctor (ID_Doctor, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo, Contrasena, ID_Consultorio, ID_Especialidad)
    VALUES (@ID_Doctor, @Nombre, @Ap_Pat, @Ap_Mat, @Contacto, @FechaNac, @Sexo, @Contrasena, @ID_Consultorio, @ID_Especialidad);
END;


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_AgregarPaciente]    Script Date: 16/01/2024 07:24:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_AgregarPaciente]
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


USE [PROYECTODBST]
GO
/****** Object:  StoredProcedure [dbo].[SP_EliminarDoctor]    Script Date: 16/01/2024 07:24:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_EliminarDoctor]
    @ID_Doctor VARCHAR(50)
AS
BEGIN
    
    DELETE FROM Doctor WHERE ID_Doctor = @ID_Doctor;
END;


-------------------------------------------------------------------------------


USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDCita]    Script Date: 16/01/2024 07:25:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDCita](
	@FechaAtencion DATE
,	@HoraAtencion TIME
,	@ID_Paciente VARCHAR (50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @Fecha VARCHAR(8), @Hora VARCHAR(2)

	----Primera parte: Ajusta el formato de año, mes y día de la cita 
	SET @Fecha = FORMAT(@FechaAtencion, 'yyyyMMdd')
	
	----Segunda parte: Extrae la hora de la cita
	SET @Hora = DATEPART(HOUR, @HoraAtencion);

	----Juntar todo
	SET @ID = @Fecha + @Hora + @ID_Paciente

	RETURN @ID
END;




USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDConsultorio]    Script Date: 16/01/2024 07:25:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDConsultorio](
	@ID_Doctor VARCHAR (50)
,	@Piso INT
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE	@ID VARCHAR(50), @ID_Especialidad VARCHAR (50), @DistintivoTabla VARCHAR (50)

	----Primera parte: Se extrae el ID de la especialidad del Médico 
	SELECT @ID_Especialidad = ID_Especialidad
    FROM Doctor
    WHERE ID_Doctor = @ID_Doctor;

	SELECT @DistintivoTabla = COALESCE(MAX(CAST(RIGHT(ID_Consultorio, LEN(ID_Consultorio) - 2) AS INT)), 0) + 1
    FROM Consultorio
    WHERE LEFT(ID_Consultorio, 2) = CAST(@Piso AS VARCHAR(2));
	
	----Juntar todo
	SET @ID = CAST (@Piso AS VARCHAR(2)) + CAST (@DistintivoTabla AS VARCHAR(2)) + CAST (@ID_Especialidad AS VARCHAR(2))

	RETURN @ID
END;



USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDDetalleReceta]    Script Date: 16/01/2024 07:26:02 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDDetalleReceta](
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


USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDDoctor]    Script Date: 16/01/2024 07:26:15 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDDoctor](
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

	----Segunda parte: Agarra el año de la fecha de nacimiento
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



USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDPaciente]    Script Date: 16/01/2024 07:26:25 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDPaciente](
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

	----Segunda parte: Agarra el día y el mes de la fecha de nacimiento
	SET @Fecha = FORMAT(@FechaNac, 'ddMM')

	----Tercera parte: En primero valida si despues de la primera y segunda parte hay duplicidad y sino hay otro elemento igual se genera el primer registro o se incrementa en uno a los registros que ya esta en la tabla
	SELECT @DistintivoTabla = (COALESCE(MAX(CAST(RIGHT(ID_Paciente, LEN(ID_Paciente) - 7) AS INT)), 0) + 1)
	FROM Paciente WHERE LEFT(ID_Paciente, 7) = @Iniciales + @Fecha
	SET @Distintivo = CAST (@DistintivoTabla AS VARCHAR(43))

	----Junta todo, la primera, segunda y tercera parte
	SET @ID = @Iniciales + @Fecha + @Distintivo

	RETURN @ID
END;


USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDRecepcion]    Script Date: 16/01/2024 07:26:41 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDRecepcion](
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

	----Segunda parte: Agarra el año de la fecha de nacimiento
	SET @Fecha = FORMAT(@FechaNac, 'yyyy')
		
	----Cuarta parte: En primero valida si despues de la primera, segunda y tercera parte hay duplicidad y sino hay otro elemento igual se genera el primer registro o se incrementa en uno a los registros que ya esta en la tabla
	SELECT @DistintivoTabla = (COALESCE(MAX(CAST(RIGHT(ID_Recepcion, LEN(ID_Recepcion) - 9) AS INT)), 0) + 1)
	FROM Recepcion WHERE LEFT(ID_Recepcion, 9) = 'RC' + @Iniciales + @Fecha
	SET @Distintivo = CAST (@DistintivoTabla AS VARCHAR(41))

	----Juntar todo
	SET @ID = 'RC' + @Iniciales + @Fecha + @Distintivo

	RETURN @ID
END;


USE [PROYECTODBST]
GO
/****** Object:  UserDefinedFunction [dbo].[GenerarIDReceta]    Script Date: 16/01/2024 07:26:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GenerarIDReceta](
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