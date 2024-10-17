
# Para que serve este script?
# - Renovação do Certificado Local: Principalmente para resolver problemas de certificados expirados ou inválidos usados para desenvolvimento HTTPS em localhost.
# - Ambiente de Desenvolvimento Limpo: Garante que as aplicações que estão sendo desenvolvidas no Visual Studio e que usam HTTPS não enfrentem erros relacionados a certificados não confiáveis.
# - Redução de Problemas de Conexão Segura: Ideal para desenvolvedores que frequentemente enfrentam avisos de segurança dos navegadores ao testar localmente suas aplicações ASP.NET Core, pois assegura que o certificado instalado esteja sempre atualizado e confiável.

function Stop-ProcessIfRunning {
    param (
        [string]$processName
    )
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Name $processName -Force
    }
}

Stop-ProcessIfRunning -processName "devenv"
Stop-ProcessIfRunning -processName "msedge"
Stop-ProcessIfRunning -processName "MSBuild"

dotnet dev-certs https --clean

$httpsPath = "${env:APPDATA}\ASP.NET\https"

if (Test-Path -Path $httpsPath) {
    Remove-Item -LiteralPath $httpsPath -Recurse -Force
}

dotnet dev-certs https --trust
