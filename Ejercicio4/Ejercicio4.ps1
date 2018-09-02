<#
.SYNOPSIS
    Sistema de reserva de pasajes de micros a larga distancia.
.DESCRIPTION
    Se ingresa por parámetro la ciudad de origen y la de destino y opcionalmente el valor del cambio del euro.
    Luego se listarán los pasajes disponibles con sus fechas horarios y asientos libres.
    El usuario deberá elegir el pasaje y se actualizará el archivo.
    Parámetro opcional valor del euro.
    
.PARAMETER ciudadOrigen
    Ciudad de origen del pasaje. [OBLIGATORIO].
.PARAMETER ciudadDestino
    Ciudad destino del pasaje. [OBLIGATORIO]. 
.PARAMETER cambio
    Valor de un euro en leks. [OPCIONAL].
    
.NOTES
Nombre del Script: Ejercicio4.ps1
Trabajo Práctico Nro. 1 - Ejercicio 4
Integrantes:
            Miller, Lucas            39353278
            Ramos, Micaela           39266928
            Schafer, Federico        39336856
            Sapaya, Nicolás Martín   38319489
            Secchi, Lucas            39267345
Instancia de Entrega: Primera Entrega
#>

Param (
    [Parameter(Position = 1, Mandatory = $true)][Alias("Desde")][String] $ciudadOrigen,
    [Parameter(Position = 2, Mandatory = $true)][Alias("Hasta")][String] $ciudadDestino,
    [Parameter(Position = 3, Mandatory = $false)][Alias("Euro")][double] $cambio
)

#### Leer archivo csv ####
$csv = Import-Csv .\bd.csv -Delimiter ";"
$pasajes = @()

$csv | foreach-object {
    $pasaje = [PSCustomObject]@{
        desde = $_.desde;
        fechaHoraDesde = $_.fechaHoraDesde;
        hasta = $_.hasta;
        fechaHoraHasta= $_.fechaHoraHasta;
        precio = $_.precio;
        asientosLibres = $_.asientosLibres;
    }
   $pasajes += $pasaje;
}
#### Termino de leer el archivo ####

$i = 1
$hayPasajes = $false
foreach($pasaje in $pasajes) {
    if(($pasaje.asientosLibres -gt 0) -and (($pasaje.desde -eq $ciudadOrigen) -or ($pasaje.desde -Like $ciudadOrigen+"*")) -and (($pasaje.hasta -eq $ciudadDestino) -or ($pasaje.hasta -Like $ciudadDestino+"*"))) {
        Write-Host "$i)  Origen:" $pasaje.desde
        Write-Host "    Destino:" $pasaje.hasta
        Write-Host "    Fecha y hora salida:" $pasaje.fechaHoraDesde
        Write-Host "    Fecha y hora llegada:" $pasaje.fechaHoraHasta
        if($cambio) {
            Write-Host "    Precio:" ($pasaje.precio / $cambio) "euros"
        } else {
            Write-Host "    Precio:" $pasaje.precio "leks"
        }
        Write-Host "    Asientos libres:" $pasaje.asientosLibres
        Write-Host " "
        $hayPasajes = $true
    }
    $i++
}

if($hayPasajes -eq $false) {
    Write-Host "No se encontraron pasajes que cumplan con esos criterios de busqueda"
    Write-Host " "
} else { ## Quise encontrar una forma de terminar el script adentro del if para no meter todo adentro
    ## de un else pero no encontre

    $nroPasaje = Read-Host -Prompt "Ingrese el numero de pasaje que desea"
    ## ME FALTA VALIDAR EL NUMERO DE PASAJE, que sea verdaderamente el que se muestra en pantalla

    $cantAsientos = Read-Host -Prompt "Ingrese la cantidad de asientos que necesita"

    while($pasajes[$nroPasaje - 1].asientosLibres -lt $cantAsientos) {
        Write-Host " "
        Write-Host "La cantidad de asientos ingresada es mayor a los asientos disponibles."
        Write-Host "Por favor ingrese los datos nuevamente."
        Write-Host " "
        $nroPasaje = Read-Host -Prompt "Numero de pasaje que desea "
        $cantAsientos = Read-Host -Prompt "Cantidad de asientos que necesita"
    }

    $pasajes[$nroPasaje - 1].asientosLibres -= $cantAsientos

    Write-Host " "
    Write-Host "Gracias por su compra."

    $pasajes | Export-Csv .\bd.csv -Delimiter ";" -NoTypeInformation
}