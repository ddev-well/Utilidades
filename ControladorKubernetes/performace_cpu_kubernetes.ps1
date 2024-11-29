# Script PowerShell para criar um menu com comandos Kubernetes

function Show-Menu {
    Clear-Host
    Write-Host "============================="
    Write-Host "   Kubernetes Command Menu   "
    Write-Host "============================="
    Write-Host "1. Listar namespaces"
    Write-Host "2. Selecionar um namespace"
    Write-Host "3. Usar K9s"
    Write-Host "4. Sair"
    Write-Host "============================="
}

function Show-DeploymentMenu {
    Clear-Host
    Write-Host "============================="
    Write-Host "Namespace Selecionado: $namespace"
    Write-Host "   Deployment Operations    "
    Write-Host "============================="
    Write-Host "1. Listar todos os deployments"
    Write-Host "2. Selecionar um deployment para operações"
    Write-Host "3. Voltar ao menu principal"
    Write-Host "============================="
}

function Show-DeploymentActionsMenu {
    Clear-Host
    Write-Host "============================="
    Write-Host "Namespace Selecionado: $namespace"
    Write-Host "Deployment Selecionado: $deployment"
    Write-Host "   Ações de Deployment    "
    Write-Host "============================="
    Write-Host "1. Editar limits e requests de um deployment"
    Write-Host "2. Reiniciar um deployment"
    Write-Host "3. Voltar ao menu de deployments"
    Write-Host "============================="
}

function Execute-Option {
    param ([int]$option)
    switch ($option) {
        1 {
            Write-Host "Executando: kubectl get namespaces"
            $namespaces = kubectl get namespaces -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            $namespaceList = $namespaces -split "`n"

            for ($i = 0; $i -lt $namespaceList.Length; $i++) {
                Write-Host "$($i + 1). $($namespaceList[$i])"
            }
        }
        2 {
            Write-Host "Executando: kubectl get namespaces"
            $namespaces = kubectl get namespaces -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            $namespaceList = $namespaces -split "`n"

            for ($i = 0; $i -lt $namespaceList.Length; $i++) {
                Write-Host "$($i + 1). $($namespaceList[$i])"
            }

            $namespaceSelection = Read-Host "Selecione o namespace pelo número ou informe o nome diretamente"

            if ($namespaceSelection -match '^[0-9]+$') {
                $namespaceIndex = [int]$namespaceSelection - 1
                if ($namespaceIndex -ge 0 -and $namespaceIndex -lt $namespaceList.Length) {
                    $namespace = $namespaceList[$namespaceIndex]
                } else {
                    Write-Host "Seleção inválida."
                    return
                }
            } else {
                $namespace = $namespaceSelection
            }

            if (-not [string]::IsNullOrEmpty($namespace)) {
                while ($true) {
                    Show-DeploymentMenu
                    $deploymentOption = Read-Host "Selecione uma opção"
                    Execute-DeploymentOption -option $deploymentOption -namespace $namespace
                    if ($deploymentOption -eq 3) { break }
                    Write-Host "Pressione qualquer tecla para continuar..."
                    [void][System.Console]::ReadKey($true)
                }
            } else {
                Write-Host "Namespace não pode ser vazio."
            }
        }
        3 {
            Write-Host "Executando K9s..."
            try {
                Start-Process k9s
            } catch {
                Write-Host "Erro ao executar K9s. Abrindo site de instalação..."
                Start-Process "https://k9scli.io/topics/install/"
            }
        }
        4 {
            Write-Host "Saindo do script..."
            exit
        }
        Default {
            Write-Host "Opção inválida, por favor, tente novamente."
        }
    }
}

function Execute-DeploymentOption {
    param (
        [int]$option,
        [string]$namespace
    )
    switch ($option) {
        1 {
            Write-Host "Executando: kubectl get deployments -n $namespace -o=jsonpath='{range .items[*]}{.metadata.name}{\n}'"
            $deployments = kubectl get deployments -n $namespace -o=jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            $deploymentList = $deployments -split "`n"

            for ($i = 0; $i -lt $deploymentList.Length; $i++) {
                Write-Host "$($i + 1). $($deploymentList[$i])"
            }
        }
        2 {
            $deployments = kubectl get deployments -n $namespace -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            $deploymentList = $deployments -split "`n"

            for ($i = 0; $i -lt $deploymentList.Length; $i++) {
                Write-Host "$($i + 1). $($deploymentList[$i])"
            }

            $deploymentSelection = Read-Host "Selecione o deployment pelo número ou informe o nome diretamente"

            if ($deploymentSelection -match '^[0-9]+$') {
                $deploymentIndex = [int]$deploymentSelection - 1
                if ($deploymentIndex -ge 0 -and $deploymentIndex -lt $deploymentList.Length) {
                    $deployment = $deploymentList[$deploymentIndex]
                } else {
                    Write-Host "Seleção inválida."
                    return
                }
            } else {
                $deployment = $deploymentSelection
            }

            if (-not [string]::IsNullOrEmpty($deployment)) {
                while ($true) {
                    Show-DeploymentActionsMenu
                    $actionOption = Read-Host "Selecione uma ação"
                    Execute-DeploymentActions -option $actionOption -namespace $namespace -deployment $deployment
                    if ($actionOption -eq 3) { break }
                    Write-Host "Pressione qualquer tecla para continuar..."
                    [void][System.Console]::ReadKey($true)
                }
            } else {
                Write-Host "Deployment não pode ser vazio."
            }
        }
        3 {
            Write-Host "Voltando ao menu principal..."
        }
        Default {
            Write-Host "Opção inválida, por favor, tente novamente."
        }
    }
}

function Execute-DeploymentActions {
    param (
        [int]$option,
        [string]$namespace,
        [string]$deployment
    )
    switch ($option) {
        1 {
            Write-Host "Obtendo os limits e requests atuais..."
            $limitsCpu = kubectl get deployment $deployment -n $namespace -o=jsonpath="{.spec.template.spec.containers[*].resources.limits.cpu}"
            $requestsCpu = kubectl get deployment $deployment -n $namespace -o=jsonpath="{.spec.template.spec.containers[*].resources.requests.cpu}"
            Write-Host "Limits atuais (CPU): $limitsCpu"
            Write-Host "Requests atuais (CPU): $requestsCpu"
            $newLimitsCpu = Read-Host "Informe os novos limits de CPU (deixe em branco para manter o atual)"
            $newRequestsCpu = Read-Host "Informe os novos requests de CPU (deixe em branco para manter o atual)"
            if (-not [string]::IsNullOrEmpty($newLimitsCpu)) {
                $limitsCpu = $newLimitsCpu
            }
            if (-not [string]::IsNullOrEmpty($newRequestsCpu)) {
                $requestsCpu = $newRequestsCpu
            }
            Write-Host "Atualizando o deployment..."
            kubectl patch deployment $deployment -n $namespace --patch "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"$deployment\",\"resources\":{\"limits\":{\"cpu\":\"$limitsCpu\"},\"requests\":{\"cpu\":\"$requestsCpu\"}}}]}}}"
        }
        2 {
            Write-Host "Reiniciando o deployment..."
            kubectl rollout restart deployment $deployment -n $namespace
        }
        3 {
            Write-Host "Voltando ao menu de deployments..."
        }
        Default {
            Write-Host "Opção inválida, por favor, tente novamente."
        }
    }
}

# Loop do menu
while ($true) {
    Show-Menu
    $userInput = Read-Host "Selecione uma opção"
    Execute-Option -option $userInput
    Write-Host "Pressione qualquer tecla para continuar..."
    [void][System.Console]::ReadKey($true)
}
