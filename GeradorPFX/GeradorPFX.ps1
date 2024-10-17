# Script criado por: Wellington Nascimento
# Codificação UTF-8 para garantir compatibilidade de caracteres especiais

function Start-OpenSslProcess {
    param (
        [string]$opensslPath,
        [string]$pfxOutput,
        [string]$keyFile,
        [string]$crtFile,
        [string]$bundleFile,
        [securestring]$pfxPassword
    )

    $passwordPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pfxPassword))
    $arguments = @("pkcs12", "-export", "-out", "$pfxOutput", "-inkey", "$keyFile", "-in", "$crtFile", "-passout", "pass:$passwordPlainText")
    
    if ($bundleFile) {
        $arguments += ("-certfile", "$bundleFile")
    }
    
    & $opensslPath @arguments
}

$opensslPath = ".\openssl\openssl-3.0\x64\bin\openssl.exe"
if (-not (Test-Path -Path $opensslPath)) {
    Write-Output "OpenSSL não encontrado na pasta local. Baixando e instalando..."
    $opensslUrl = "https://download.firedaemon.com/FireDaemon-OpenSSL/openssl-3.0.15.zip"
    $opensslZip = ".\openssl.zip"
    $opensslExtractPath = ".\openssl"

    Invoke-WebRequest -Uri $opensslUrl -OutFile $opensslZip
    
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($opensslZip, $opensslExtractPath)
    
    Remove-Item $opensslZip -Force
    
    Write-Output "OpenSSL instalado com sucesso."
}

Write-Output "Buscando certificado para gerar"

Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta onde estão localizados o arquivo .key, .crt e *bundle.crt (opcional)"
$folderBrowser.SelectedPath = (Get-Location).Path
$folderBrowser.TopMost = $true

$dialogResult = $folderBrowser.ShowDialog()


if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $folderPath = $folderBrowser.SelectedPath
} else {
    Write-Warning "Nenhuma pasta foi selecionada."
    Read-Host -Prompt "Pressione qualquer tecla para sair..."
    Exit
}

$keyFile = Get-ChildItem -Path $folderPath -Filter "*key*" -ErrorAction SilentlyContinue
$crtFile = Get-ChildItem -Path $folderPath -Filter "*crt*" -ErrorAction SilentlyContinue
$bundleFile = Get-ChildItem -Path $folderPath -Filter "*bundle*" -ErrorAction SilentlyContinue

if (-not $keyFile -or -not $crtFile) {
    Write-Warning "Não foram encontrados arquivos .key e/ou .crt na pasta especificada."
    Read-Host -Prompt "Pressione qualquer tecla para sair..."
    Exit
}

if (-not $keyFile -or -not $crtFile) {
    Write-Warning "Não foram encontrados arquivos .key e/ou .crt na pasta especificada."
    Read-Host -Prompt "Pressione qualquer tecla para sair..."
    Exit
}

$pfxPassword = Read-Host -AsSecureString "Digite a senha para o certificado PFX"

$pfxOutput = "$folderPath\certificado.pfx"

Write-Output "Convertendo arquivos .key e .crt em um certificado .pfx..."
Start-OpenSslProcess -opensslPath $opensslPath -pfxOutput $pfxOutput -keyFile $keyFile.FullName -crtFile $crtFile.FullName -bundleFile $bundleFile.FullName -pfxPassword $pfxPassword
Write-Output "Certificado gerado com sucesso em: $pfxOutput"
Read-Host -Prompt "Pressione qualquer tecla para sair..."