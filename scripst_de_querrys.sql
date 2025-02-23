-- 1) ) Listado de docentes que viven en una provincia distinta de aquella en la que trabajan

select distinct d.docenteDni, d.docenteNombre, d.docenteApellido   
from docentes d natural join ubicacion_docentes u natural join  direcciones di natural join localidad l
where l.provincia not exists (select 
                            l1.provincia 
                            from localidad l1 natural join direcciones di1 natural join dependencias dep natural join cargos c natural join natural join trabajo t natural join declaracion_jurada de natural join docentes d2
                            where t.hasta = null and de.declaracionAño(year) = 2024
                            );
                            
-- 2) Listado de docentes que poseen títulos de posgrado y no realizan tareas de investigación.
select *
from docentes
where docentedni in
(select seCertificoProfdni
from Se_certifico_prof s inner join Certificaciones_profesionales c on s.seCertificoProfidcp=c.certificacionesProfIdcp
where c.certificacionesProfNivel = 'Posgrado');
except 
(select seCertExtdni
from Investigacion i inner join Se_certifico_ext s on s.seCertExtidce=i.investigacionIdce);

-- 3) Informar promedio de edad de los docentes que poseen más de 10 años de antecedentes como docentes.

WITH TotalDocenteExperiencia AS (
    SELECT t.trabajoDni,  SUM(DATEDIFF(YEAR, t.trabajoFechaIng, GETDATE())) AS años_experiencia
    FROM Trabajo t
    GROUP BY t.trabajoDni
),
DocenteEdad AS (
    SELECT d.docenteDni, DATEDIFF(YEAR, d.docenteFecha_nac, GETDATE()) AS edad
    FROM Docentes d
)
SELECT AVG(de.edad) AS promedio_edad
FROM TotalDocenteExperiencia dexp  JOIN DocenteEdad de ON dexp.trabajoDni = de.docenteDni
WHERE dexp.años_experiencia > 10;

-- 4) Listar DNI y nombre de los docentes que presentaron más de un cargo docente en las declaraciones juradas de los últimos 3 años
select trabajoDni
from Trabajo
where trabajoAño = YEAR(CURRENT_DATE)
group by trabajoDni
having count(idc) > 1;
intersect
select trabajoDni
from Trabajo
where trabajoAño = (YEAR(CURRENT_DATE) - 1)
group by trabajoDni
having count(idc) > 1;
intersect
select trabajoDni
from Trabajo
where trabajoAño = (YEAR(CURRENT_DATE) - 2)
group by trabajoDni
having count(idc) > 1;

-- 5) Listado de docentes cuya carga horaria superan las 20 horas semanales, en función de la última declaración jurada presentada
SELECT 
    chpd.docenteApellido,
    chpd.docenteNombre,
    chpd.cargaHorariaSemanal
FROM 
    (
    SELECT 
        d.docenteDni,
        d.docenteApellido,
        d.docenteNombre,
        SUM(c.cargosTiempo) AS cargaHorariaSemanal
    FROM 
        Docentes d
        JOIN Declaracion_jurada dj ON d.docenteDni = dj.declaracionJuradaDni
        JOIN Trabajo t ON dj.declaracionJuradaAño = t.trabajoAño AND dj.declaracionJuradaDni = t.trabajoDni
        JOIN Cargos c ON t.trabajoIdc = c.cargosIdc
    WHERE 
        t.trabajoHasta IS NULL OR t.trabajoHasta > CURRENT_DATE()
    GROUP BY 
        d.docenteDni, d.docenteApellido, d.docenteNombre
) AS CargaHorariaPorDocente
WHERE 
    chpd.cargaHorariaSemanal > 20;
    
-- 6) Apellido y nombre de aquellos docentes que poseen la máxima cantidad de cargos docentes actualmente.
SELECT 
    cpd.docenteApellido,
    cpd.docenteNombre,
    cpd.cantidadCargos
FROM 
    (   SELECT 
            d.docenteDni,
            d.docenteApellido,
            d.docenteNombre,
            COUNT(t.trabajoIdc) AS cantidadCargos
        FROM 
            Docentes d
            JOIN Declaracion_jurada dj ON d.docenteDni = dj.declaracionJuradaDni
            JOIN Trabajo t ON dj.declaracionJuradaAño = t.trabajoAño AND dj.declaracionJuradaDni = t.trabajoDni
        WHERE 
            t.trabajoHasta IS NULL OR t.trabajoHasta > CURRENT_DATE()
        GROUP BY 
            d.docenteDni, d.docenteApellido, d.docenteNombre
            ) AS cdp
    NATURAL JOIN  (
                        SELECT  MAX(cantidadCargos2) AS maxCantidad
                            FROM (   SELECT 
                                    d.docenteDni,
                                    d.docenteApellido,
                                    d.docenteNombre,
                                    COUNT(t.trabajoIdc) AS cantidadCargos2
                                FROM 
                                    Docentes d
                                    JOIN Declaracion_jurada dj ON d.docenteDni = dj.declaracionJuradaDni
                                    JOIN Trabajo t ON dj.declaracionJuradaAño = t.trabajoAño AND dj.declaracionJuradaDni = t.trabajoDni
                                WHERE 
                                    t.trabajoHasta IS NULL OR t.trabajoHasta > CURRENT_DATE()
                                GROUP BY 
                                    d.docenteDni, d.docenteApellido, d.docenteNombre
                                    ) AS cdp2
                        )

-- 7) Listado de docentes solteros/as (sin esposa/o e/o hijos a cargo en la obra social).
SELECT D.docenteNombre
FROM Docentes D
WHERE D.docenteDni IN (
        SELECT O.osFamDdni
        FROM Os_fam O
            INNER JOIN Familiares F
        WHERE O.osFamTdoc = F.familiaresTipDoc
            AND O.osFamFdoc = F.familiaresDni
            AND O.osFamDdni = F.familiaresDdni
            AND F.familiaresParentesco NOT IN ('esposa', 'esposo', 'hijo', 'hija')
    ) 

-- 8) Cantidad de docentes cuyos hijos a cargo son todos menores de 10 años.
WITH Cant_HijosMenores AS (
    SELECT f.familiaresDni, COUNT(*) AS total_hijos,   SUM(CASE 
                                                        WHEN DATEDIFF(YEAR, f.familiaresFechaNac, GETDATE()) < 10 THEN 1 
                                                        ELSE 0 
														END) AS hijos_menores_10
    FROM Familiares f
    WHERE f.familiaresParentesco = 'Hijo'
    GROUP BY f.familiaresDdni
)
SELECT COUNT(*) AS cantidad_docentes
FROM Cant_HijosMenores
WHERE total_hijos = hijos_menores_10;

-- 9) Informar aquellos docentes que posean alguna persona del grupo familiar a cargo en la obra social que no es beneficiario del seguro de vida obligatorio.

SELECT DISTINCT d.docenteDni, d.docenteNombre, d.docenteApellido 
from docentes d natural join Familiares f 
where f.familiaresDni exists (SELECT
                            f1.familiaresDni
                          FROM
                            familiares f1 natural join os_fam natural join polizas_obra_social p
                            )
    and not exists (SELECT 
                    f2.familiaresDni
                    FROM
                    familiares f2 natural join es_beneficiario e natural join seguros s
                    )

-- 10) Informar Cantidad de individuos asegurados por provincia.
-- EL primer select es para obtener la cantidad de docentes asegurados por provincia
-- falta comprobar dnis repetidos
SELECT l.localidadProvincia,
    count(*) as cantProf
FROM Seguros s
    INNER JOIN Docentes d
    INNER JOIN Ubicacion_docentes u
    INNER JOIN Direcciones dir
    INNER JOIN Localidad l
WHERE s.segurosDni = d.docenteDni
    and d.docenteDni = u.UbicacionDocentesDni
    and u.UbicacionDocentesCodPostal = dir.direccionesCodPostal
    and u.UbicacionDocentesCalle = dir.direccionesCalle
    and u.ubicacionDocentesNumero = dir.direccionesNumero
    and dir.direccionesCodPostal = l.localidadCodPostal
GROUP BY l.localidadProvincia 
--EL primer select es para obtener la cantidad de familiares asegurados por provincia
--falta comprobar dnis repetidos
SELECT l.localidadProvincia,
    count(*) as cantFam
FROM Es_beneficiario ben
    INNER JOIN Familiares F ON ben.esBeneficiarioTipDoc = F.familiaresTipDoc
    and ben.esBeneficiarioFdoc = F.familiaresDni
    and ben.esBeneficiarioDdni = F.familiaresDdni
    INNER JOIN Ubicacion_familiares uf ON uf.UbicacionFamiliaresTipDoc = F.familiaresTipDoc
    and uf.UbicacionFamiliaresDni = F.familiaresDni
    and uf.UbicacionFamiliaresDdni = F.familiaresDdni
    INNER JOIN Direcciones dir ON uf.UbicacionFamiliaresCodPostal = dir.direccionesCodPostal
    and uf.UbicacionFamiliaresCalle = dir.direccionesCalle
    and uf.UbicacionFamiliaresNumero = dir.direccionesNumero
    INNER JOIN Localidad l ON dir.direccionesCodPostal = l.localidadCodPostal
GROUP BY l.localidadProvincia
