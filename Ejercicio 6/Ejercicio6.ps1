<# 
.DESCRIPTION
    A partir de un archivo .zip pasado por parámetro indica la relación de compresión de cada uno de los archivos que contiene.

.EXAMPLE
    .\Ejercicio6.ps1 -pathZip Test.zip
	
.NOTES
Nombre del Script: Ejercicio6.ps1
Trabajo Práctico Nro. 1 - Ejercicio 6
Integrantes:
            Miller, Lucas            39353278
            Ramos, Micaela           39266928
            Schafer, Federico        39336856
            Sapaya, Nicolás Martín   38319489
            Secchi, Lucas            39267345
Instancia de Entrega: Segunda Re Entrega
#>

Param(
		[parameter(Mandatory = $True, position = 1)][ValidateNotNullOrEmpty()][string] $pathZip
)

function saveTable{
    <#
    .SYNOPSIS
        Guarda la tabla y la muestra.
         
    .DESCRIPTION
        Se encarga de guardar en una tabla todos los archivos del zip y mostrarla por pantalla.
    
    .PARAMETER RawFiles
		Todos los archivos adentro del zip.
    #>

    Param([Parameter(Mandatory = $true)]$RawFiles
    )

    #Creo Arrays donde almaceno.
    $arrayNombre = @()
    $arrayTComp = @()
	$arrayTReal = @()
    $arrayRelacion = @()

    #Creo una tabla.
    $tableNew = New-Object system.Data.DataTable

    #Defino columnas.
    $colString = New-Object system.Data.DataColumn Nombre,([string])
    $colString1 = New-Object system.Data.DataColumn TamañoComprimido,([string])
	$colString2 = New-Object system.Data.DataColumn TamañoOriginal,([string])
	$colString3 = New-Object system.Data.DataColumn Relacion,([string])

    #Agrego columnas.
    $tableNew.columns.add($colString)
    $tableNew.columns.add($colString1)
	$tableNew.columns.add($colString2)
	$tableNew.columns.add($colString3)
	
	foreach($RawFile in $RawFiles) {
        $var = [String]$RawFile
        $var = $var.Substring($var.length-1)
        if($var -ne "/"){
			$arrayNombre += $RawFile.Name
			$arrayTComp += ([math]::Round($($RawFile.CompressedLength/1MB),4)).ToString()
			$arrayTReal += ([math]::Round($($RawFile.Length/1MB),4)).ToString()
			$arrayRelacion += ([math]::Round((($RawFile.CompressedLength)/($RawFile.Length)),4)).ToString()
		}
	}
	
	for($i=0;$i -lt $arrayNombre.length;$i++){
		$tableNew.Rows.Add($arrayNombre[$i],$arrayTComp[$i],$arrayTReal[$i],$arrayRelacion[$i]) >$null 2>&1
	}
	
	$tableNew | Format-Table -AutoSize
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$RawFiles = [System.IO.Compression.ZipFile]::OpenRead($(Join-path $pwd $pathZip)).Entries
saveTable -RawFiles $RawFiles