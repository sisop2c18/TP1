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
Instancia de Entrega: Primera Re Entrega
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
$date = Get-Date
$pasajesValidos = @()

foreach($pasaje in $pasajes) {
    $datePasaje = Get-Date ($pasaje.fechaHoraDesde)
    if(($pasaje.asientosLibres -gt 0) -and ($datePasaje  -gt $date) -and (($pasaje.desde -eq $ciudadOrigen) -or ($pasaje.desde -Like $ciudadOrigen+"*")) -and (($pasaje.hasta -eq $ciudadDestino) -or ($pasaje.hasta -Like $ciudadDestino+"*"))) {
        $hayPasajes = $true
        $pasajeVal = [PSCustomObject]@{
            desde = $pasaje.desde
            fechaHoraDesde = $pasaje.fechaHoraDesde
            hasta = $pasaje.hasta
            fechaHoraHasta= $pasaje.fechaHoraHasta
            precio = $pasaje.precio
            asientosLibres = $pasaje.asientosLibres
            indice = $i 
        }
       $pasajesValidos += $pasajeVal;
    }
    $i++
}
if($hayPasajes -eq $false) {
    Write-Host "No se encontraron pasajes que cumplan con esos criterios de busqueda"
    Write-Host " "
} else {
    $i = 1 
    Write-Host " "
    foreach( $pasaje in $pasajesValidos) {
        Write-Host "$i)  Numero de pasaje:" $i
        Write-Host "    Origen:" $pasaje.desde
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
        $i++
    }

     ## Valido que el numero de pasaje ingresado sea un numero
   do {
    try {
            $numOk = $true
            [int]$nroPasaje = Read-host "Ingrese el numero de pasaje que desee"
                ## Valido que el numero de pasaje ingresado por pantalla pertenezca a la lista de pasajes
            while($pasajesValidos[$nroPasaje - 1] -eq $Null -or $nroPasaje -eq "") {
                Write-Host " "
                Write-Host "Ingreso un numero de pasaje que no existe, verifique los datos ingresados"
                Write-Host " "
                $nroPasaje = Read-Host -Prompt "Ingrese el numero de pasaje nuevamente"
            }
        } 
        catch {
            $numOK = $false
            Write-Host " "
            Write-Host "Numero de pasaje invalido"
            Write-Host " "
        }
    }    ## mientras no sea numero saldra por el catch y volvera a pedir el reingreso de un pasaje
    until ($numOK)

    do {
        try {
               $numOk = $true
               Write-Host " "
               [int]$cantAsientos = Read-host "Cantidad de asientos que necesita"
               while(([int]($pasajesValidos[$nroPasaje - 1].asientosLibres) -lt $cantAsientos) -or ($cantAsientos -eq 0)) {
				Write-Host " "
                Write-Host "La cantidad de asientos ingresada es mayor a los asientos disponibles o es 0."
                Write-Host " "

                $cantAsientos = Read-Host -Prompt "Por favor, ingrese la cantidad nuevamente"
            }
           } 
        catch {
            $numOK = $false
            Write-Host " "
            Write-Host "Cantidad invalida"
        }
       }    ## mientras no sea numero saldra por el catch y volvera a pedir el reingreso de un pasaje
       until ($numOK)
       
       $indice = $pasajesValidos[$nroPasaje - 1].indice - 1
       $pasajes[$indice].asientosLibres -= $cantAsientos
       Write-Host " "
       Write-Host "Gracias por su compra."

    $pasajes | Export-Csv .\bd.csv -Delimiter ";" -NoTypeInformation
}