CREATE VIEW Consultas_Servicios AS
SELECT *
FROM Servicios
WHERE Nombre LIKE '%Consulta%'
   OR Nombre LIKE '%Aplicación%'
   OR Nombre LIKE '%Tratamiento%';

