# Parâmetros
param (
    [string]$folderPath = (Get-Location).Path, # Caminho da pasta onde iniciar a busca
    [string]$preparationFolderPath = "./preparacao" # Caminho da pasta onde os arquivos serão colados
)

$scriptName = $MyInvocation.MyCommand.Name # Nome do script sendo executado

# Função para encontrar o arquivo mais recente
function Get-NewestFile {
    param (
        [string]$Path,
        [string]$ExcludeFile
    )

    # Obtem o arquivo mais recente em todas as subpastas, excluindo o próprio script
    Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.Name -ne $ExcludeFile } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

# Obtem o arquivo mais recente
$newestFile = Get-NewestFile -Path $folderPath -ExcludeFile $scriptName

if ($null -eq $newestFile) {
    Write-Host "Nenhum arquivo encontrado na pasta especificada." -ForegroundColor Yellow
    return
}

# Data de modificação do arquivo mais recente
$newestFileDate = $newestFile.LastWriteTime
Write-Host "Arquivo mais recente: $($newestFile.FullName)"
Write-Host "Data de modificação: $newestFileDate"

# Intervalo de busca: mesma data ou 10 minutos antes
$startDate = $newestFileDate.AddMinutes(-10)

# Busca arquivos no intervalo de tempo especificado
$filesInTimeRange = Get-ChildItem -Path $folderPath -File -Recurse | Where-Object {
    $_.LastWriteTime -ge $startDate -and $_.LastWriteTime -le $newestFileDate -and $_.Name -ne $scriptName
}

# Resultados
if ($filesInTimeRange.Count -eq 0) {
    Write-Host "Nenhum arquivo encontrado no intervalo especificado." -ForegroundColor Yellow
} else {
    Write-Host "Arquivos encontrados no intervalo de tempo especificado:"
    $filesInTimeRange | ForEach-Object {
        Write-Host "Arquivo: $($_.FullName), Data de Modificação: $($_.LastWriteTime)"
    }

    # Copia os arquivos para a pasta de preparação mantendo a estrutura de pastas relativa
    foreach ($file in $filesInTimeRange) {
        $relativePath = $file.FullName.Substring($folderPath.Length).TrimStart('/')
        $destinationPath = Join-Path -Path $preparationFolderPath -ChildPath $relativePath
        $destinationDir = [System.IO.Path]::GetDirectoryName($destinationPath)

        # Cria a estrutura de pastas no destino, caso não exista
        if (-not (Test-Path -Path $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir | Out-Null
        }

        # Copia o arquivo para o destino
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force
        Write-Host "Arquivo copiado: $($file.FullName) para $destinationPath"
    }
}

# Solicita que o usuário aperte um botão para fechar
Write-Host "Pressione qualquer tecla para fechar..."
[System.Console]::ReadKey() | Out-Null
