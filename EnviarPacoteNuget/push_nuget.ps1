# Definir o local para salvar o NuGet.exe
$nugetPath = "$PSScriptRoot\nuget.exe"

# Verificar se o NuGet.exe já foi baixado, senão, fazer o download
echo "Baixando a última versão do NuGet.exe..."
if (-not (Test-Path -Path $nugetPath)) {
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetPath
    Write-Host "NuGet.exe baixado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "NuGet.exe já está baixado." -ForegroundColor Yellow
}

# Caminho para salvar os parâmetros
$paramsPath = "$PSScriptRoot\publishParams.json"

# Carregar parâmetros existentes
if (Test-Path -Path $paramsPath) {
    $params = Get-Content -Path $paramsPath | ConvertFrom-Json
} else {
    $params = @{ PublishUrl = ""; ApiKey = "" }
}

# Solicitar os parâmetros, caso não estejam preenchidos ou se o usuário quiser atualizar
if (-not $params.PublishUrl -or -not $params.ApiKey -or ((Read-Host "Deseja usar os parâmetros existentes (S/N)?") -eq "N")) {
    $params.PublishUrl = Read-Host "Informe a URL de publicação"
    $params.ApiKey = Read-Host "Informe o Token da API"

    # Salvar os parâmetros
    $params | ConvertTo-Json | Set-Content -Path $paramsPath
}

# Solicitar o caminho do pacote a ser enviado
Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "NuGet Package (*.nupkg)|*.nupkg"
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $packagePath = $openFileDialog.FileName
} else {
    Write-Host "Operação cancelada pelo usuário." -ForegroundColor Red
    exit
}

# Executar o comando push
echo "Enviando pacote..."
& $nugetPath push $packagePath -Source $params.PublishUrl -ApiKey $params.ApiKey

# Perguntar ao usuário se deseja continuar
if ((Read-Host "Deseja enviar outro pacote? (S/N)") -eq "S") {
    . $PSCommandPath
} else {
    Write-Host "Operação finalizada." -ForegroundColor Green
}
