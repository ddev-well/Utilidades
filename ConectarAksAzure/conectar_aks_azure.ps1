# Verificar se o Azure CLI está instalado
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI não encontrado. Baixando e instalando..."
    # URL do instalador do Azure CLI
    $installerUrl = "https://aka.ms/installazurecliwindows"
    $installerPath = "$env:TEMP\AzureCLISetup.msi"
    
    # Fazer download do instalador
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    # Instalar o Azure CLI
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    Remove-Item $installerPath

    Write-Host "Azure CLI instalado com sucesso."
}
else {
    Write-Host "Azure CLI já está instalado."
}

# Fazer login no Azure
Write-Host "Efetuando login no Azure..."
az login

# Verificar se o kubectl está instalado
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl não encontrado. Instalando..."
    # Instalar kubectl via Azure CLI
    az aks install-cli
    Write-Host "kubectl instalado com sucesso."
}
else {
    Write-Host "kubectl já está instalado."
}

# Solicitar informações do usuário
$resourceGroupName = Read-Host "Por favor, insira o nome do Resource Group"
$aksClusterName = Read-Host "Por favor, insira o nome do Cluster AKS"

# Conectar ao cluster Kubernetes
Write-Host "Conectando ao cluster AKS..."
az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName

Write-Host "Conexão estabelecida com sucesso. Agora você pode usar o kubectl."
