<#
    uninstall-menu.ps1
    Remove o menu de contexto "Executar no DOS (otvdm)" registrado por
    install-menu.ps1, para as extensoes .exe e .com em HKCU.

    O handler padrao de duplo-clique nunca foi tocado, entao nao ha
    nada a restaurar ali.

    by Jair Lima
#>

$Extensoes = @(".exe", ".com")

foreach ($ext in $Extensoes) {
    $base = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\ExecutarNoDOS"
    if (Test-Path -LiteralPath $base) {
        Remove-Item -Path $base -Recurse -Force -Confirm:$false
        Write-Output "Removido menu de contexto de '$ext'."
    }
    else {
        Write-Output "Nada a remover para '$ext' (nao estava instalado)."
    }
}

Write-Output ""
Write-Output "Desinstalacao concluida."
