CREATE VIEW Consultas_Servicios AS
SELECT *
FROM Servicios
WHERE Nombre LIKE '%Consulta%'
   OR Nombre LIKE '%Aplicación%'
   OR Nombre LIKE '%Tratamiento%';

CREATE VIEW VistaDetalleCita AS
SELECT
    Cita.ID_Cita,
    Cita.FechaAtencion,
    Cita.HoraAtencion,
    Cita.Estatus,
    Cita.Costo,
    Cita.desc_servicio,
    Paciente.Nombre AS NombrePaciente,
    Paciente.Ap_Pat AS Apellido_Paterno_Paciente,
    Paciente.Ap_Mat AS Apellido_Materno_Paciente,
    Doctor.Nombre AS NombreDoctor,
    Doctor.Ap_Pat AS Apellido_Paterno_Doctor,
    Doctor.Ap_Mat AS Apellido_Materno_Doctor,
    Doctor.ID_Consultorio AS ID_Consultorio,
    Especialidad.Nombre AS NombreEspecialidad, -- Agregando información de la especialida
    Consultorio.Piso as Piso_consultorio,
    Consultorio.NumConsultorio as Num_consultorio
FROM
    Cita
INNER JOIN
    Paciente ON Cita.ID_Paciente = Paciente.ID_Paciente
INNER JOIN
    Doctor ON Cita.ID_Doctor = Doctor.ID_Doctor
INNER JOIN
    Especialidad ON Doctor.ID_Especialidad = Especialidad.ID_Especialidad -- Uniendo con la tabla Especialidad
INNER JOIN
    Consultorio ON Doctor.ID_Doctor = Consultorio.ID_Doctor
