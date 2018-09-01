<#
.SYNOPSIS
    Juego orientado a la rapidez de escritura del jugador.
.DESCRIPTION
    Se ingresan por parametro al menos la cantidad de palabras a escribir y el orden en que se quiere que aparezcan las palabras a escribir.
    Luego se muestra una palabra, se escribe lo más rápido que se pueda, y así sucesivamente, al finalizar la cantidad de palabras ingresadas se muestran las estadísticas.
    Parametros opcionales: pathPalabras y pathPuntajes
    
.PARAMETER cantPalabras
Cantidad de palabras a escribir. [OBLIGATORIO].

.PARAMETER pathPalabras

Path del archivo de palabras. [OPCIONAL]. 
   
.PARAMETER pathPuntajes

Path del archivo de puntajes. [OPCIONAL].

.PARAMETER aleatoria
Switch, el orden en el que serán mostradas las palabras será ALEATORIA [OBLIGATORIO].

.PARAMETER ascendente
Switch, el orden en el que serán mostradas las palabras será ASCENDENTE [OBLIGATORIO].

.PARAMETER descendente
Switch, el orden en el que serán mostradas las palabras será DESCENDENTE [OBLIGATORIO].
    
.NOTES
Nombre del Script: Ejercicio3.ps1
Trabajo Práctico Nro. 1 - Ejercicio 3
Integrantes:
            Miller, Lucas            39353278
            Ramos, Micaela           39266928
            Schafer, Federico        39336856
            Sapaya, Nicolás Martín   38319489
            Secchi, Lucas            39267345
Instancia de Entrega: Primera Entrega
#>

Param([Parameter(Mandatory=$true)][ValidateRange(2,10)][int]$cantPalabras,
      [Parameter(Mandatory=$false)][string]$pathPalabras = 'palabras.txt',
      [Parameter(Mandatory=$false)][string]$pathPuntajes,
      [Parameter(Mandatory=$true,ParameterSetName="setRandom")][switch]$aleatoria,
      [Parameter(Mandatory=$true,ParameterSetName="setAsc")][switch]$ascendente,
      [Parameter(Mandatory=$true,ParameterSetName="setDes")][switch]$descendente
)

############################################################################################################################################################

function leerTeclado {
    <#
    .SYNOPSIS
    Lee teclado tecla por tecla.

    .DESCRIPTION
    Lee teclado tecla por tecla y devuelve la cantidad de teclas presionadas.
    
    .PARAMETER word
    Palabra a escribir por el jugador

    .PARAMETER string
    Palabra escrita por el jugador
    #>

    Param (
        [Parameter(Mandatory = $true)][string]$word,
        [Parameter(Mandatory = $true)][ref]$string
    );
    
    $cantTeclas = 0
    $fullString='';
    $key = '';
    $result = $false

    Write-Host "Ingrese la palabra $word : " -NoNewline
    while ($result -eq $false){
        if ($host.ui.RawUI.KeyAvailable){
            $key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp").Character;          
            Write-Host $key -NoNewline
            if ([System.Text.Encoding]::ASCII.GetBytes($key.ToString())[0] -eq 13){
                Clear-Host
                break;
            }
            if ([System.Text.Encoding]::ASCII.GetBytes($key.ToString())[0] -ne 8){
                $fullString += $key;
                $cantTeclas++
            }else{
                $fullString = $fullString.Remove(($fullString.Length)-1)
                Clear-Host
                Write-Host "Ingrese la palabra $word : $fullString" -NoNewline
                $cantTeclas++
            }
        }
        Start-Sleep -Milliseconds 50;        
    }

    $string.Value = $fullString

    return $cantTeclas
}

function saveTable{
    <#
    .SYNOPSIS
        Guarda la tabla.
         
    .DESCRIPTION
        Se encarga de guardar los puntajes y comparar si el nuevo puntaje es un nuevo record o no.
    
    .PARAMETER pathPuntajes
    Es el path del archivo de los puntajes

    .PARAMETER tiempo
    Es el tiempo que tardo el jugador ahora.

    .PARAMETER nombre
    Es el nombre del jugador.
    #>

    Param([Parameter(Mandatory = $true)][string]$pathPuntajes,
          [Parameter(Mandatory = $true)][decimal]$tiempo,
          [Parameter(Mandatory = $true)][string]$nombre
    )

    Write-Host "Mejores Tiempos:"

    #Creo Arrays donde almaceno Nombres y Puntajes.
    $arrayNombre = @()
    $arrayTiempo = @()

    #Importo los puntajes.
    $puntajes = Get-Content $puntajesFullPath

    #Creo una tabla.
    $tableNew = New-Object system.Data.DataTable

    #Defino columnas.
    $colString = New-Object system.Data.DataColumn Nombre,([string])
    $colDec = New-Object system.Data.DataColumn Tiempo,([decimal])

    #Agrego columnas.
    $tableNew.columns.add($colString)
    $tableNew.columns.add($colDec)

    if($puntajes.Length -eq 3){
        #Uso los arrays para despues guardar todo en la tabla. (Si el tiempo nuevo supera alguno de los otros, lo inserto)
        forEach($item in $puntajes){
            $splitedPunt = $item.ToString().Split(' ')
            if([decimal]$($splitedPunt[1]) -le $tiempo){
                $arrayNombre += $($splitedPunt[0])
                $arrayTiempo += [decimal]$($splitedPunt[1])
            }else{
                $arrayNombre += $nombre
                $arrayTiempo += $tiempo
                $nombre = $($splitedPunt[0])
                $tiempo = [decimal]$($splitedPunt[1])
            }
        }
        for($i=0;$i -lt 3;$i++){
            $tableNew.Rows.Add($arrayNombre[$i],$arrayTiempo[$i])
        }
    }else{
        #Si no hay 3 cargados, comparo y lo cargo directo
        $contador = 1
        forEach($item in $puntajes){
            $splitedPunt = $item.ToString().Split(' ')
            if([decimal]$($splitedPunt[1]) -le $tiempo){
                $arrayNombre += $($splitedPunt[0])
                $arrayTiempo += [decimal]$($splitedPunt[1])
            }else{
                $arrayNombre += $nombre
                $arrayTiempo += $tiempo
                $nombre = $($splitedPunt[0])
                $tiempo = [decimal]$($splitedPunt[1])
            }
            $contador++
        }
        $arrayNombre += $nombre
        $arrayTiempo += $tiempo

        for($i=0;$i -lt $contador;$i++){
            $tableNew.Rows.Add($arrayNombre[$i],$arrayTiempo[$i])
        }

    }

    #Guardo en archivo
    for($i = 0; $i -lt $arrayNombre.Length; $i++){
        $string = "$($arrayNombre[$i]) $($arrayTiempo[$i])"
        if($i -eq 0){
            $string | Set-Content $pathPuntajes
        }else{
            $string | Add-Content $pathPuntajes
        }
    }
}

function mostrarPalabra{
    <#
    .SYNOPSIS
        Selecciona la palabra a escribir.
         
    .DESCRIPTION
        Esta función va pasando las palabras a la función leerTeclado, cuando sucede esto se comienza un cronometro, 
        lo que devuelve esta función se lo compara con la palabra que se selecciono previamente,
        si la comparación es satisfactoria se detiene el cronometro y se continúa con las siguientes palabras,
        por último se muestran las estadísticas de la partida.
    
    .PARAMETER arrayWords
    Contiene todas las palabras del archivo de palabras.
    
    .PARAMETER cantPalabras
    Cantidad de palabras a escribir.

    .PARAMETER nombre
    Es el nombre del jugador.

    .PARAMETER pathPuntajes
    Es el path del archivo de los puntajes

    #>

    Param(
          [Parameter(Mandatory = $true)][validateNotNullorEmpty()]$arrayWords,
          [Parameter(Mandatory = $true)][int]$cantPalabras,
          [Parameter(Mandatory = $false)][string]$nombre,
          [Parameter(Mandatory = $false)][string]$pathPuntajes
    )

    $hash = @{}
    $segundos = 0
    $cantTeclas = 0
    $tiempoTotal = 0
    $teclasTotales = 0
    $string = ''

    #Muestra la/s palabra/s a escribir, almacenadas en el array.
    Clear-Host

    for($i = 0; $i -lt $cantPalabras; $i++){
        $word = $arrayWords[$i].ToString()
        $chrono = [System.Diagnostics.Stopwatch]::StartNew()
        do{
            $cantTeclas += leerTeclado -word $word -string ([ref]$string)
        }while(-not $word.Equals($string))
        $chrono.Stop()
        $segundos = $chrono.Elapsed.TotalSeconds
        $hash[$arrayWords[$i]] = @()
        $hash[$arrayWords[$i]] += [math]::Round($segundos,2)
        $hash[$arrayWords[$i]] += $cantTeclas
        $tiempoTotal += $segundos
        $teclasTotales += $cantTeclas
        $cantTeclas = 0
    }

    $tiempoTotal = [math]::Round($tiempoTotal,2)
    $tiempoProm = [math]::Round($tiempoTotal/$cantPalabras,2)
    $teclasXSeg = [math]::Round($tiempoTotal/$teclasTotales,2)

    $hash.Keys | Select @{l='PALABRA';e={$_}},@{l='TIEMPO Y CANT DE TECLAS';e={$hash.$_}} | Format-Table -AutoSize
    Write-Host "Tiempo Total: $tiempoTotal"
    Write-Host "Tiempo Promedio: $tiempoProm"
    Write-Host "Teclas por Segundo: $teclasXSeg"
    Write-Host ""

    if($pathPuntajes -ne ''){
        saveTable -pathPuntajes $puntajesFullPath -tiempo $tiempoProm -nombre $nombre
    }   
}

############################################################################################################################################################

#Guarda la direccion absoluta del documento
$palabrasFullPath = (Get-ChildItem $pathPalabras).fullName

#Testeo si el/los path/s ingresado/s es/son correcto/s.
if (-not (Test-Path $pathPalabras)){
    Write-Error 'El path de palabras es erroneo. cantPalabras, [pathPalabras], [pathPuntajes], orden, siendo este último: aleatoria, ascendente o descendente'
    return;
}

if($pathPuntajes -ne ""){
    if (-not (Test-Path $pathPuntajes)){
        Write-Error 'El path de puntajes es erroneo. cantPalabras, [pathPalabras], [pathPuntajes], orden, siendo este último: aleatoria, ascendente o descendente'
        return;
    }else{
        $puntajesFullPath = (Get-ChildItem $pathPuntajes).fullName 
        $nombrePlayer = Read-Host -Prompt "Ingrese Nombre del Jugador"
    }
}

$allWords = Get-Content $pathPalabras

if($cantPalabras -gt $allWords.Length){
    Write-Error 'La cantidad de palabras ingresada es mayor a las que posee el archivo de palabras.'
    return;
}

#Se evalua la interaccion a llevar a cabo teniendo en cuenta el parametro de tipo switch
switch ($PSCmdlet.ParameterSetName){
    'setRandom'{
        $orderWords = $allWords | Sort-Object { Get-Random }
    }
    'setAsc'{
        $orderWords = $allWords | Sort-Object
    }
    'setDes'{     
        $orderWords = $allWords | Sort-Object -Descending       
    }
}

if ($pathPuntajes -ne ""){
    mostrarPalabra -arrayWords $orderWords -cantPalabras $cantPalabras -nombre $nombrePlayer -pathPuntajes $puntajesFullPath
}else{
    mostrarPalabra -arrayWords $orderWords -cantPalabras $cantPalabras
}
