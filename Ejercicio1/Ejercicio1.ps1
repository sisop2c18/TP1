<#	
.DESCRIPTION
Escribie en un archivo los procesos activos, e imprime por pantalla los primeros n (siendo n=3 por defecto, o el parámetro cantidad que se pase) con formato Id Nombre.
    
.PARAMETER pathsalida
Path del archivo de salida.[OPCIONAL].
.PARAMETER cantidad
Cantidad de procesos a mostrar por pantalla. [OPCIONAL]. 
    
.NOTES
Nombre del Script: Ejercicio1.ps1
Trabajo Práctico Nro. 1 - Ejercicio 1
Integrantes:
            Miller, Lucas            39353278
            Ramos, Micaela           39266928
            Schafer, Federico        39336856
            Sapaya, Nicolás Martín   38319489
            Secchi, Lucas            39267345
Instancia de Entrega: Primera Entrega
#>

Param([Parameter(Position = 1, Mandatory = $false)][String] $pathsalida = ".\procesos.txt ",
	  [int] $cantidad = 3
)

$existe = Test-Path $pathsalida
if ($existe -eq $true){
	$listaproceso = Get-Process
	foreach ($proceso in $listaproceso){
		$proceso | Format-List -Property Id,Name >> $pathsalida
	}
	for ($i = 0; $i -lt $cantidad ; $i++){
		Write-Host $listaproceso[$i].Name - $listaproceso[$i].Id
	}
}else{
	Write-Host "El path no existe"
}

<#
1- El objetivo del script es escribir en un archivo los procesos activos, e imprimir por pantalla los primeros n (siendo n=3 por defecto, 
o el parámetro cantidad que se pase) con formato Id Nombre.

2- Agregaría como validación del parámetro cantidad, que sea mayor a cero y que no sea mayor a la cantidad de procesos en ejecución.

3- Si el script se ejecuta sin parámetros y el archivo por defecto no existe, mostrará por pantalla  
"El path no existe". De otra forma, si el archivo existe, el script se ejecutará tomando como cantidad de procesos 3
y el archivo a escribir será procesos.txt, y funcionará sin inconvenientes.
#>