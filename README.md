# Proyecto Liquibase - BLSchool SQL

Este proyecto contiene una configuración base para gestionar la evolución de esquemas y datos en una base de datos PostgreSQL utilizando Liquibase con Maven.

## Estructura

```
axum-sql/
├── changelogs/
├── pom.xml
├── docker-compose.yml
├── README.md
```

## Requisitos

- Docker
- PostgreSQL

## Comandos útiles

### Actualizar Base de datos

Cuando se desea actualizar la base de datos de acuerdo a los changelogs especificados se debe ejecutar el siguiente comando:

`mvn -Plocal clean liquibase:update`

### Sincronizar changelogs sin realizar cambios sobre la Base de datos

En caso de que se desee "emular" una actualización de base de datos sin ejecutar los changelogs actuales se debe ejecutar el siguiente comando:

`mvn -Plocal clean liquibase:changelogSync`

### Volver a calcular los checksums de los archivos de changelogs sobre la Base de datos

En caso de realizar algún cambio en un archivo de changelog que ya fue ejecutado en el ambiente indicado de acuerdo al profile, se puede forzar a que liquibase recalcule los checksums con los cuales lleva registro de ejecución. No se recomienda realizar esto ya que se pierde la secuencia exacta de cambios realizados y pueden quedar ambientes sin actualizar lo cual generará un fallo al actualizar la última versión de los changelogs. En caso necesario se puede utilizar el siguiente comando:

`mvn -Plocal clean liquibase:clearCheckSums`

### Desbloquear proceso de actualización sobre la Base de datos

En caso de que una ejecución anterior de liquibase no pueda finalizar se bloqueará la base de datos en la que se estaban aplicando los cambios, para liberar el bloqueo se debe ejecutar el siguiente comando:

`mvn -Plocal clean liquibase:releaseLocks`

### Rollback sobre Base de Datos

En case de necesitar realizar un rollback de la base de datos se puede ejecutar alguno de los siguientes comandos:

1. `mvn -Plocal clean liquibase:rollback "-Dliquibase.rollbackTag=<nombre_tag>"`
2. `mvn -Plocal clean liquibase:rollback "-Dliquibase.rollbackCount=<cantidad_changelogs>"`
3. `mvn -Plocal clean liquibase:rollback "-Dliquibase.rollbackDate=<fecha_iso_date_format>"`

### UpdateRollback

Se recomienda luego de agregar cambios sobre la base de datos testear los mismos ejecutando el siguiente comando:

`liquibase:updateTestingRollback`
