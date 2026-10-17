<#
    install-menu.ps1
    Registra o menu de contexto "Executar no DOS (otvdm)" para arquivos
    .exe e .com, em HKCU (sem exigir administrador) e escopado por
    extensao especifica (nunca sob a chave "*", para nao afetar todos
    os tipos de arquivo).

    Nao altera o handler padrao de .exe (exefile\shell\open\command):
    o duplo-clique continua funcionando normalmente para qualquer
    programa Windows.

    by Jair Lima
#>

$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$LauncherScript = Join-Path $ScriptDir "dos-launch.ps1"
$OtvdmExe = Join-Path $ScriptDir "otvdm\otvdmw.exe"

if (-not (Test-Path -LiteralPath $LauncherScript)) {
    throw "Nao encontrei dos-launch.ps1 em $ScriptDir"
}
if (-not (Test-Path -LiteralPath $OtvdmExe)) {
    throw "Nao encontrei otvdmw.exe em $OtvdmExe. Extraia o otvdm nessa pasta antes de instalar."
}

$MenuLabel = "Executar no DOS (otvdm)"
$CommandLine = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$LauncherScript`" `"%1`""

$Extensoes = @(".exe", ".com")

foreach ($ext in $Extensoes) {
    $base = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\ExecutarNoDOS"
    $cmdKey = Join-Path $base "command"

    New-Item -Path $base -Force | Out-Null
    Set-ItemProperty -Path $base -Name "(default)" -Value $MenuLabel
    Set-ItemProperty -Path $base -Name "Icon" -Value $OtvdmExe

    New-Item -Path $cmdKey -Force | Out-Null
    Set-ItemProperty -Path $cmdKey -Name "(default)" -Value $CommandLine

    Write-Output "Registrado menu de contexto para '$ext' -> $base"
}

Write-Output ""
Write-Output "Instalacao concluida. Botao direito em um .exe ou .com DOS -> '$MenuLabel'."
Write-Output "O handler padrao de duplo-clique NAO foi alterado."
