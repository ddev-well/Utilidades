# Explicação do script:
# Este script facilita o envio de pacotes NuGet para um servidor específico. 
# Ele faz o download da última versão do NuGet.exe caso ainda não exista, solicita ao usuário os parâmetros necessários (como URL de publicação e Token da API), e envia o pacote selecionado. 
# Além disso, o script salva os parâmetros fornecidos para reutilização futura e utiliza a interface gráfica para facilitar a seleção do arquivo de pacote. 
# Por fim, permite que o usuário continue enviando pacotes sem reiniciar o script manualmente.



$nugetPath = "$PSScriptRoot\nuget.exe"


echo "Baixando a última versão do NuGet.exe..."
if (-not (Test-Path -Path $nugetPath)) {
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetPath
    Write-Host "NuGet.exe baixado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "NuGet.exe já está baixado." -ForegroundColor Yellow
}


$paramsPath = "$PSScriptRoot\publishParams.json"


if (Test-Path -Path $paramsPath) {
    $params = Get-Content -Path $paramsPath | ConvertFrom-Json
} else {
    $params = @{ PublishUrl = ""; ApiKey = "" }
}

if (-not $params.PublishUrl -or -not $params.ApiKey -or ((Read-Host "Deseja usar os parâmetros existentes (S/N)?") -eq "N")) {
    $params.PublishUrl = Read-Host "Informe a URL de publicação"
    $params.ApiKey = Read-Host "Informe o Token da API"
    $params | ConvertTo-Json | Set-Content -Path $paramsPath
}

Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "NuGet Package (*.nupkg)|*.nupkg"
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $packagePath = $openFileDialog.FileName
} else {
    Write-Host "Operação cancelada pelo usuário." -ForegroundColor Red
    exit
}

echo "Enviando pacote..."
& $nugetPath push $packagePath -Source $params.PublishUrl -ApiKey $params.ApiKey

if ((Read-Host "Deseja enviar outro pacote? (S/N)") -eq "S") {
    . $PSCommandPath
} else {
    Write-Host "Operação finalizada." -ForegroundColor Green
}
