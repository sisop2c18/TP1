<# 
.Synopsis
    INTEGRANTES:
                - Schafer Federico
                - Sapaya Nicolas
                - Secchi Lucas
                - Ramos Micaela
                - Miller Lucas
.DESCRIPTION
    A partir de un archivo .zip pasado por parámetro indica la relación de compresión de cada uno de los archivos que contiene.

.EXAMPLE
    .\Ejercicio6.ps1 -pathZip Test.zip
#>

Param
(
    [parameter(Mandatory = $True, position = 1)][ValidateNotNullOrEmpty()][string] $pathZip
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
    $primero = 0
    $RawFiles = [System.IO.Compression.ZipFile]::OpenRead($(Join-path $pwd $pathZip)).Entries
    foreach($RawFile in $RawFiles) {
        $var = [String]$RawFile
        $var = $var.Substring($var.length-1)
        if($var -ne "/"){
            $object = New-Object -TypeName PSObject            
            $Object | Add-Member -MemberType NoteProperty -Name NombreArchivo -Value $RawFile.Name                        
            $Object | Add-Member -MemberType NoteProperty -Name TamañoComprimido -Value ($RawFile.CompressedLength/1MB).ToString("0.000")           
            $Object | Add-Member -MemberType NoteProperty -Name TamañoOriginal -Value ($RawFile.Length/1MB).ToString("0.000")
            $Object | Add-Member -MemberType NoteProperty -Name Relacion -Value (($RawFile.CompressedLength).Tostring("00")/($RawFile.Length)).Tostring("0.000")
            if($primero -eq 0){
                $Object | Format-Table -AutoSize
                $primero = 1
            }
            else{
                $Object | Format-Table -AutoSize -HideTableHeaders
                }
        }
    }
