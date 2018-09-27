<# 
.Synopsis
    INTEGRANTES:
                - Schafer Federico
                - Sapaya Nicolas
                - Secchi Lucas
                - Ramos Micaela
                - Miller Lucas
.DESCRIPTION
    Muestra el porcentaje de ocurrencia de cada carácter en un archivo cuya ruta será pasada por parámetro.

.EXAMPLE
    .\Ejercicio2.ps1 -pathArch Palabras.txt
#>

Param
(
    [parameter(Mandatory = $True, position = 1)][string] $pathArch = $(Join-path $pwd "Palabras")
)

if( $(test-path $pathArch) -eq $false){
    Write-Error "Ruta de palabras inexistente"
}
If ( $(Get-Content $pathArch) -eq $Null) {
    Write-Error "ARCHIVO DE ENTRADA VACIO"
}
else{
    $lineas = $(Get-Content $pathArch).count
    $archivo = Get-Content $pathArch
    $archivo = $archivo.ToCharArray()
    $hash = @{}

    foreach ($letra in $archivo){
        
        if ($letra -eq "`t"){
                $letra = "TAB"
        }
        else{
                if ($letra -eq " "){
                    $letra = "ESPACIO"
                }
            }

        if( $hash.ContainsKey($letra)){
            $hash[$letra] += 1
        }
        else{
             $hash.Add($letra, 1)
             }
        $contador += 1
    }
    
    if( $lineas -gt 1){
            $hash.add("ENTER",$lineas -1)
            $contador += $lineas -1
    }
    
    $hashP = @{}
    foreach ($keys in $hash.Keys){
        $valorHash = $(($hash.item($keys)/$contador)*100)
        $valorHash = [math]::Ceiling($valorHash)
        $str = " %"
        $valorHash = -join ($valorHash,$str)
        $hashP.Add($keys, $valorHash)
    }

    $hashP.Keys | select @{l='CARACTER';e={$_}},@{l='PORCENTAJE';e={$hashP.$_}} | Format-Table -AutoSize
}
