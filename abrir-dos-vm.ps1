<#
    abrir-dos-vm.ps1
    Abre o DOSBox-X com C:\dos montado como unidade C:, rodando o
    AUTOEXEC.BAT real dessa pasta (jogos, Clipper/dBASE, Norton Commander,
    Windows 3.1).

    by Jair Lima
#>

$ScriptDir = $PSScriptRoot
$DosboxExe = Join-Path $ScriptDir "dosbox-x\bin\x64\Release\dosbox-x.exe"
$Conf = Join-Path $ScriptDir "dos-vm.conf"

if (-not (Test-Path -LiteralPath $DosboxExe)) {
    throw "Nao encontrei dosbox-x.exe em $DosboxExe"
}
if (-not (Test-Path -LiteralPath $Conf)) {
    throw "Nao encontrei dos-vm.conf em $Conf"
}

Start-Process -FilePath $DosboxExe -ArgumentList "-conf `"$Conf`"" -WorkingDirectory (Split-Path $DosboxExe)
