create database Docentes;
use docentes;

CREATE TABLE Docentes (
    docenteDni INT PRIMARY KEY,
    docenteNombre VARCHAR(100) NOT NULL,
    docenteApellido VARCHAR(100) NOT NULL,
    docenteSexo VARCHAR(10),
    docenteCuit BIGINT NOT NULL,
    docenteNacionalidad VARCHAR(50),
    docenteFecha_nac DATE,
    docenteEstado_civil VARCHAR(20)
);
-- creo las percepciones pasivas
CREATE TABLE PercepcionesPasivas (
    pasivosCausa VARCHAR(100),
    pasivosEstado VARCHAR(50),
    pasivosRegimen VARCHAR(100) ,
    pasivosCaja VARCHAR(100) ,
    PRIMARY KEY( pasivosCausa, pasivosRegimen, pasivosCaja )
);
-- creo intereses pasivos
CREATE TABLE Intereses_pasivos (
    intPasivosDni INT,
    intPasivosCausa VARCHAR(100),
    intPasivosRegimen VARCHAR(100),
    intPasivosCaja VARCHAR(100),
    intPasivosDesde DATE NOT NULL,
    PRIMARY KEY (intPasivosDni, intPasivosCausa, intPasivosRegimen, intPasivosCaja),
    FOREIGN KEY (intPasivosDni) REFERENCES Docentes(docenteDni),
    FOREIGN KEY (intPasivosCausa, intPasivosRegimen, intPasivosCaja) REFERENCES PercepcionesPasivas(pasivosCausa, pasivosRegimen, pasivosCaja)
);
-- creo contactos
CREATE TABLE Contactos (
    contactosNumDir VARCHAR(100) PRIMARY KEY,
    contactosTipo VARCHAR(50) NOT NULL,
    contactosMedio VARCHAR(50),
    contactosDni INT,
    FOREIGN KEY (contactosDni) REFERENCES Docentes(docenteDni)
);
-- creo certificaciones extra
CREATE TABLE Certificaciones_extras (
    certificacionesExtrasIdce INT PRIMARY KEY,
    certificacionesExtrasDesde DATE NOT NULL,
    certificacionesExtrasHasta DATE NOT NULL
);
-- creo cursos, investigacion y extension
CREATE TABLE Cursos (
    cursosIdce INT PRIMARY KEY,
    cursosNombre VARCHAR(100) NOT NULL,
    cursosDescripcion TEXT,
    FOREIGN KEY (cursosIdce) REFERENCES Certificaciones_extras(certificacionesExtrasIdce)
);
CREATE TABLE Investigacion (
    investigacionIdce INT PRIMARY KEY,
    investigacionCategoria VARCHAR(50),
    investigacioAreappal VARCHAR(100) NOT NULL,
    investigacionDescrip TEXT,
    FOREIGN KEY (investigacionIdce) REFERENCES Certificaciones_extras(certificacionesExtrasIdce)
);
CREATE TABLE Extension_universitaria (
    extensionIdce INT PRIMARY KEY,
    extensionAcciones TEXT,
    extensionDedicacion REAL NOT NULL,
    FOREIGN KEY (extensionIdce) REFERENCES Certificaciones_extras(certificacionesExtrasIdce)
);
-- creo se certifico ext
CREATE TABLE Se_certifico_Ext (
    seCertExtdni INT,
    seCertExtidce INT,
    PRIMARY KEY (seCertExtdni, seCertExtidce),
    FOREIGN KEY (seCertExtdni) REFERENCES Docentes(docenteDni),
    FOREIGN KEY (seCertExtidce) REFERENCES Certificaciones_extras(certificacionesExtrasIdce)
);
-- creo certificaciones personales
CREATE TABLE Certificaciones_profesionales (
    certificacionesProfIdcp INT PRIMARY KEY,
    certificacionesProfNivel VARCHAR(50),
    certificacionesProfTitulo VARCHAR(100)
);
-- Creo titulos e idiomas
CREATE TABLE Idiomas (
    idiomasIdcp INT,
    idiomasIdioma VARCHAR(50) NOT NULL,
    PRIMARY KEY (idiomasIdcp),
    FOREIGN KEY (idiomasIdcp) REFERENCES Certificaciones_profesionales(certificacionesProfIdcp)
);
CREATE TABLE Titulos (
    titulosIdcp INT,
    titulosDesde DATE NOT NULL,
    titulosHasta DATE NOT NULL,
    PRIMARY KEY (titulosIdcp),
    FOREIGN KEY (titulosIdcp) REFERENCES Certificaciones_profesionales(certificacionesProfIdcp)
);
-- creo la tabla se_certifico_prof
CREATE TABLE Se_certifico_prof (
    seCertificoProfdni INT,
    seCertificoProfidcp INT,
    PRIMARY KEY (seCertificoProfdni,seCertificoProfidcp),
    FOREIGN KEY (seCertificoProfdni) REFERENCES Docentes(docenteDni),
    FOREIGN KEY (seCertificoProfidcp) REFERENCES Certificaciones_profesionales(certificacionesProfIdcp)
);
-- creo la tabla creaciones
CREATE TABLE Creaciones (
    creacionesFecha DATE PRIMARY KEY,
    creacionesTitulo VARCHAR(100) NOT NULL
);
-- creo las tablas publicaciones y reuniones cientificas
CREATE TABLE Publicaciones (
    publicacionesFecha DATE,
    publicacionesAutores VARCHAR(255) NOT NULL,
    publicacionesReferencias TEXT,
    PRIMARY KEY (publicacionesFecha),
    FOREIGN KEY (publicacionesFecha) REFERENCES Creaciones(creacionesFecha)
);
CREATE TABLE Reuniones_cientificas (
    reunionesCientificacasFecha DATE,
    reunionesCientificasParticion VARCHAR(255),
    PRIMARY KEY (reunionesCientificacasFecha),
    FOREIGN KEY (reunionesCientificacasFecha) REFERENCES Creaciones(creacionesFecha)
);
-- creo la tabla autor_de
CREATE TABLE Autor_de (
    autorDeDni INT,
    autorDeFecha DATE,
    PRIMARY KEY (autorDeDni, autorDeFecha),
    FOREIGN KEY (autorDeDni) REFERENCES Docentes(docenteDni),
    FOREIGN KEY (autorDeFecha) REFERENCES Creaciones(creacionesFecha)
);
-- ahora la parte mas complicada
-- creo la tabla declaracion_jurada (debil del docente)
CREATE TABLE Declaracion_jurada (
    declaracionJuradaAño DATE,
    declaracionJuradaDni INT,
    PRIMARY KEY (declaracionJuradaAño,declaracionJuradaDni),
    FOREIGN KEY (declaracionJuradaDni) REFERENCES Docentes(docenteDni) ON DELETE CASCADE
);
-- creo actividades no estatales
CREATE TABLE Actividades_No_Estatales (
    actividadesNoEstatalesIda INT PRIMARY KEY,
    actividadesNoEstatalesTipo VARCHAR(100),
    actividadesNoEstatalesCargo VARCHAR(100) NOT NULL,
    actividadesNoEstatalesEmpresa VARCHAR(100)
);
-- creo declaracion_ane
CREATE TABLE Declaracion_ane (
    declaracionAneIda INT,
    declaracionAneAño DATE,
    declaracionAneHasta DATE,
    declaracionAneFechaIng DATE,
    declaracionAneLugar VARCHAR(100),
    declaracionAneDni INT,
    PRIMARY KEY (declaracionAneIda, declaracionAneAño, declaracionAneDni),
    FOREIGN KEY (declaracionAneIda) REFERENCES Actividades_No_Estatales(actividadesNoEstatalesIda),
    FOREIGN KEY (declaracionAneAño, declaracionAneDni) REFERENCES Declaracion_jurada(declaracionJuradaAño,declaracionJuradaDni)
);
-- Aca hay muchas referencias con clave foranea. Por lo que hay que tener cuidado a la hora de cargar.
-- creo Instituciones
CREATE TABLE Instituciones (
    institucionesIdi INT PRIMARY KEY,
    institucionesNombre VARCHAR(100) NOT NULL
);
-- creo dependencias(debil de instituciones)
CREATE TABLE Dependencias (
    dependenciasIdi INT,
    dependenciasNombre VARCHAR(100),
    PRIMARY KEY (dependenciasIdi, dependenciasNombre),
    FOREIGN KEY (dependenciasIdi) REFERENCES Instituciones(institucionesIdi) ON DELETE CASCADE
);
-- creo la tabla cargos
CREATE TABLE Cargos (
    cargosIdc INT PRIMARY KEY,
    cargosNombre VARCHAR(100) NOT NULL,
    cargosCatedra VARCHAR(100),
    cargosDedicacion REAL NOT NULL,
    cargosTiempo REAL,
    cargosCaracter VARCHAR(50),
    cargosUnidadacad VARCHAR(100),
    cargosNombredep VARCHAR(100),
    cargosNombredepIdi INT,
    FOREIGN KEY (cargosNombredepIdi, cargosNombre) REFERENCES Dependencias(dependenciasIdi, dependenciasNombre)
);
-- creo horarios (debil de cargos)
CREATE TABLE Horarios (
    horariosDia DATE,
    horariosHora TIME,
    horariosIdc INT,
    PRIMARY KEY (horariosDia, horariosHora, horariosIdc),
    FOREIGN KEY (horariosIdc) REFERENCES Cargos(cargosIdc) ON DELETE CASCADE
);
-- creo la tabla trabajo
CREATE TABLE Trabajo (
    trabajoIdc INT,
    trabajoAño DATE,
    trabajoFechaIng DATE,
    trabajoHasta DATE,
    trabajoObservaciones TEXT,
    trabajoDni INT,
    PRIMARY KEY (trabajoIdc, trabajoAño, trabajoDni),
    FOREIGN KEY (trabajoIdc) REFERENCES Cargos(cargosIdc),
    FOREIGN KEY (trabajoAño, trabajoDni) REFERENCES Declaracion_jurada(declaracionJuradaAño, declaracionJuradaDni)
);
-- creo localidad
CREATE TABLE Localidad (
    localidadCodPostal INT PRIMARY KEY,
    localidadNombre VARCHAR(100) NOT NULL,
    localidadProvincia VARCHAR(100) NOT NULL
);
-- creo direcciones(debil de localidad)
CREATE TABLE Direcciones (
    direccionesCalle VARCHAR(100),
    direccionesNumero INT,
    direccionesPiso INT,
    direccionesDpto INT,
    direccionesTipo VARCHAR(50),
    direccionesBarrio VARCHAR(100),
    direccionesCodPostal INT,
    direccionesNombreDependencia VARCHAR(100),
    direccionesIdi INT,
    PRIMARY KEY (direccionesCodPostal, direccionesCalle, direccionesNumero),
    FOREIGN KEY (direccionesCodPostal) REFERENCES Localidad(localidadCodPostal) ON DELETE CASCADE,
    FOREIGN KEY (direccionesIdi, direccionesNombredependencia) REFERENCES Dependencias(dependenciasIdi, dependenciasNombre)
);
-- creo ubicacion_docences
CREATE TABLE Ubicacion_docentes (
    UbicacionDocentesDni INT,
    UbicacionDocentesCalle VARCHAR(100),
    UbicacionDocentesNumero INT,
    UbicacionDocentesCodPostal INT,
    PRIMARY KEY (UbicacionDocentesDni, ubicacionDocentesCalle, ubicacionDocentesNumero, ubicacionDocentesCodPostal),
    FOREIGN KEY (	UbicacionDocentesDni) REFERENCES Docentes(docenteDni),
    FOREIGN KEY (UbicacionDocentesCodPostal, UbicacionDocentesCalle, ubicacionDocentesNumero) REFERENCES Direcciones(direccionesCodPostal, direccionesCalle, direccionesNumero)
);
-- creo la tabla familiares (debil de docentes)
CREATE TABLE Familiares (
    familiaresTipDoc VARCHAR(10),
    familiaresDni INT,
    familiaresFechaNac DATE NOT NULL,
    familiaresParentesco VARCHAR(50),
    familiaresNombre VARCHAR(100) NOT NULL,
    familiaresApellido VARCHAR(100) NOT NULL,
    familiaresPorcentaje INT,
    familiaresDdni INT,
    PRIMARY KEY (familiaresTipDoc, familiaresDni, familiaresDdni),
    FOREIGN KEY (familiaresDdni) REFERENCES Docentes(docenteDni) ON DELETE CASCADE
);
-- creo la tabla ubicacion_familiares
CREATE TABLE Ubicacion_familiares (
    UbicacionFamiliaresTipDoc VARCHAR(10),
    UbicacionFamiliaresDni INT,
    UbicacionFamiliaresCalle VARCHAR(100),
    UbicacionFamiliaresNumero INT ,
    UbicacionFamiliaresDdni INT,
    UbicacionFamiliaresCodPostal INT,
    PRIMARY KEY (UbicacionFamiliaresTipDoc, UbicacionFamiliaresDni, UbicacionFamiliaresCalle, UbicacionFamiliaresNumero, UbicacionFamiliaresDdni, UbicacionFamiliaresCodPostal),
    FOREIGN KEY (UbicacionFamiliaresTipDoc, UbicacionFamiliaresDni, UbicacionFamiliaresDdni) REFERENCES Familiares(familiaresTipDoc, familiaresDni, familiaresDdni),
    FOREIGN KEY (UbicacionFamiliaresCodPostal, UbicacionFamiliaresCalle, UbicacionFamiliaresNumero) REFERENCES Direcciones(direccionesCodPostal, direccionesCalle, direccionesNumero)
);
-- creo la tabla seguros
CREATE TABLE Seguros (
    segurosNombre VARCHAR(100),
    segurosTipo VARCHAR(50),
    segurosdescripcion TEXT,
    segurosDni INT,
    PRIMARY KEY (segurosNombre, segurosTipo),
    FOREIGN KEY (segurosDni) REFERENCES Docentes(docenteDni)
);
-- creo la tabla es_beneficiario
CREATE TABLE Es_beneficiario (
    esBeneficiarioTipDoc VARCHAR(10),
    esBeneficiarioFdoc INT,
    esBeneficiarioNombre VARCHAR(100),
    esBeneficiarioStipo VARCHAR(50),
    esBeneficiarioDdni INT,
    PRIMARY KEY (esBeneficiarioTipDoc, esBeneficiarioFdoc, esBeneficiarioDdni, esbeneficiarioNombre, esbeneficiarioStipo),
    FOREIGN KEY (esBeneficiarioTipDoc, esBeneficiarioFdoc, esBeneficiarioDdni) REFERENCES Familiares(familiaresTipDoc, familiaresDni, familiaresDdni),
    FOREIGN KEY (esBeneficiarioNombre, esBeneficiarioStipo) REFERENCES Seguros(segurosNombre, segurosTipo)
);
-- creo la tabla seguros_dep
CREATE TABLE Seguros_dep (
    segurosDepSnombre VARCHAR(100),
    segurosDepDnombre VARCHAR(100),
    segurosDepIdi INT,
    segurosDepStipo VARCHAR(50),
    PRIMARY KEY (segurosDepSnombre, segurosDepDnombre, segurosDepIdi, segurosDepStipo),
    FOREIGN KEY (segurosDepSnombre, segurosDepStipo) REFERENCES Seguros(segurosNombre, segurosTipo),
    FOREIGN KEY (segurosDepIdi, segurosDepDnombre) REFERENCES Dependencias(dependenciasIdi, dependenciasNombre)
);
-- creo la tabla obra social
CREATE TABLE Obra_social (
    obraSocialNombre VARCHAR(100) PRIMARY KEY,
    obraSocialTipoPlan CHAR(1) NOT NULL
);
-- creo las polizas obra social
CREATE TABLE Polizas_obra_social (
    polizasObraSocialDdni INT,
    polizasObraSocialNombre VARCHAR(100),
    polizasObrasocialNropoliza INT PRIMARY KEY,
    polizasObraSocialDescripcion TEXT,
    FOREIGN KEY (polizasObraSocialDdni) REFERENCES Docentes (docenteDni),
    FOREIGN KEY (polizasObraSocialNombre) REFERENCES Obra_social(obraSocialNombre)
);
-- creo la tabla oscargo
CREATE TABLE Os_cargo (
    osCargoIdc INT,
    osCargoNropoliza INT,
    PRIMARY KEY (OsCargoIdc, OsCargoNropoliza),
    FOREIGN KEY (OsCargoIdc) REFERENCES Cargos(cargosIdc),
    FOREIGN KEY (OsCargoNropoliza) REFERENCES Polizas_obra_social(polizasObraSocialNropoliza)
);
-- creo la tabla de os_fam
CREATE TABLE Os_fam(
    osFamNropoliza INT,
    osFamTdoc VARCHAR(10),
    osFamFdoc INT,
    osFamDdni INT,
    PRIMARY KEY(osFamNropoliza, osFamTdoc, osFamFdoc, osFamDdni),
    FOREIGN KEY(OsFamNropoliza) REFERENCES Polizas_obra_social(polizasObraSocialNropoliza),
    FOREIGN KEY(osFamTdoc, osFamFdoc, osFamDdni) REFERENCES Familiares(familiaresTipDoc, familiaresDni, familiaresDdni)
);

