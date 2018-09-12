<#
.SYNOPSIS
    Sistema de monitoreo de archivos.
.DESCRIPTION
    Se ingresa por parámetro el Path que sera monitoreado y el tipo de archivo que se desea monitorear.
    Luego se listarán en la consola y un archivo de logs si se realiza una alta, modificacion o un borrado de los archivos.
    Si se ingresase .*, monitoreara todos los archivos sin discriminar el tipo.
    
.PARAMETER PathMonitoring
    Ubicacion de los archivos a monitorear. [OBLIGATORIO].
.PARAMETER FileType
    Tipo de archivo a monitorear. [OBLIGATORIO]. 


.NOTES
Nombre del Script: Ejercicio5.ps1
Trabajo Práctico Nro. 1 - Ejercicio 5
Integrantes:
            Miller, Lucas            39353278
            Ramos, Micaela           39266928
            Schafer, Federico        39336856
            Sapaya, Nicolás Martín   38319489
            Secchi, Lucas            39267345
Instancia de Entrega: Primera Entrega
#>


Param(
        [string][Parameter(Mandatory=$True)]$PathMonitoring,
        [String][Parameter(Mandatory=$True)]$FileType
)

If ($FileType="*")
{
$FileType=".*"
}


$filter = "*$FileType"
                          
$fsw = New-Object IO.fileSystemWatcher $PathMonitoring, $filter  

New-Item -ItemType directory -Path .\ArchivoLog

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action { 
$name = $Event.SourceEventArgs.Name 
$timeStamp = $Event.TimeGenerated 
Write-Host "El archivo '$name' fue creado a las $timeStamp" -fore green 
Out-File -FilePath .\ArchivoLog\outlog.txt -Append -InputObject "El archivo '$name' fue creado a las $timeStamp"} 
 
Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action { 
$name = $Event.SourceEventArgs.Name 
$timeStamp = $Event.TimeGenerated 
Write-Host "El archivo '$name' fue eliminado a las $timeStamp" -fore red 
Out-File -FilePath .\ArchivoLog\outlog.txt -Append -InputObject "El archivo '$name' fue eliminado a las $timeStamp"} 
 
Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action { 
$name = $Event.SourceEventArgs.Name 
$timeStamp = $Event.TimeGenerated 
Write-Host "El archivo '$name' fue modificado a las $timeStamp" -fore white 
Out-File -FilePath .\ArchivoLog\outlog.txt -Append -InputObject "El archivo '$name' fue modificado a las $timeStamp"} 