<#
    dos-launch.ps1
    Lancador inteligente de programas DOS/16-bit via otvdm.

    Chamado pelo menu de contexto "Executar no DOS (otvdm)" registrado por
    install-menu.ps1. Recebe o caminho completo do arquivo clicado, detecta
    se ele e realmente um programa DOS/16-bit lendo o cabecalho binario, e
    so entao chama o otvdm. Se o arquivo for um programa Windows normal
    (PE 32/64-bit), avisa o usuario em vez de tentar executa-lo.

    by Jair Lima
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$AlvoPath
)

# Caminho do otvdmw.exe (interface grafica do otvdm). Ajuste aqui se mover a pasta.
$OtvdmExe = Join-Path $PSScriptRoot "otvdm\otvdmw.exe"

function Show-Aviso {
    param([string]$Mensagem, [string]$Titulo = "Executar no DOS")
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($Mensagem, $Titulo,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
}

# --- Validacoes basicas -----------------------------------------------------

if (-not (Test-Path -LiteralPath $AlvoPath)) {
    Show-Aviso "Arquivo nao encontrado:`n$AlvoPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $OtvdmExe)) {
    Show-Aviso "otvdm nao encontrado em:`n$OtvdmExe`n`nReinstale o DosLauncher."
    exit 1
}

$item = Get-Item -LiteralPath $AlvoPath
$ext = $item.Extension.ToLowerInvariant()

# --- Deteccao de tipo de executavel ------------------------------------------
# Le o cabecalho binario para decidir se e DOS puro, 16-bit Windows (NE) ou
# um programa Windows normal (PE 32/64-bit).
#
# Layout relevante do cabecalho MZ:
#   offset 0x00: assinatura "MZ" (0x4D 0x5A)
#   offset 0x3C: e_lfanew (DWORD) -> offset do cabecalho estendido (PE/NE)
#
# Em e_lfanew:
#   "PE\0\0" -> programa Windows moderno (32/64-bit)
#   "NE"     -> programa Windows de 16-bit (roda no otvdm)
#   qualquer outra coisa / offset invalido -> tratamos como DOS MZ puro

function Get-TipoExecutavel {
    param([string]$Caminho)

    $tamanho = (Get-Item -LiteralPath $Caminho).Length
    if ($tamanho -lt 0x40) {
        return "DESCONHECIDO"
    }

    $fs = [System.IO.File]::OpenRead($Caminho)
    try {
        $buffer = New-Object byte[] 2
        $fs.Read($buffer, 0, 2) | Out-Null
        if ($buffer[0] -ne 0x4D -or $buffer[1] -ne 0x5A) {
            return "NAO_EXECUTAVEL"   # nao comeca com "MZ"
        }

        $fs.Seek(0x3C, [System.IO.SeekOrigin]::Begin) | Out-Null
        $lfanewBytes = New-Object byte[] 4
        $fs.Read($lfanewBytes, 0, 4) | Out-Null
        $lfanew = [System.BitConverter]::ToUInt32($lfanewBytes, 0)

        if ($lfanew -eq 0 -or $lfanew -ge $tamanho - 1) {
            return "DOS"   # sem cabecalho estendido valido -> MZ puro
        }

        $fs.Seek($lfanew, [System.IO.SeekOrigin]::Begin) | Out-Null
        $sig = New-Object byte[] 4
        $lidos = $fs.Read($sig, 0, 4)

        if ($lidos -ge 4 -and $sig[0] -eq 0x50 -and $sig[1] -eq 0x45 -and $sig[2] -eq 0x00 -and $sig[3] -eq 0x00) {
            return "PE"    # "PE\0\0" -> programa Windows 32/64-bit
        }
        if ($lidos -ge 2 -and $sig[0] -eq 0x4E -and $sig[1] -eq 0x45) {
            return "NE"    # "NE" -> programa Windows 16-bit
        }

        # offset aponta para algo que nao e nem PE nem NE valido
        return "DOS"
    }
    finally {
        $fs.Close()
    }
}

# --- Decisao ------------------------------------------------------------

$deveExecutar = $false

if ($ext -eq ".com") {
    # .COM nao tem cabecalho de formato: e sempre DOS puro.
    $deveExecutar = $true
}
elseif ($ext -eq ".exe") {
    $tipo = Get-TipoExecutavel -Caminho $AlvoPath
    switch ($tipo) {
        "DOS" { $deveExecutar = $true }
        "NE"  { $deveExecutar = $true }
        "PE" {
            Show-Aviso "`"$($item.Name)`" e um programa Windows normal (32/64-bit),`nnao um programa DOS/16-bit. Ele nao sera executado no otvdm.`n`nExecute-o normalmente com duplo-clique."
            exit 0
        }
        "NAO_EXECUTAVEL" {
            Show-Aviso "`"$($item.Name)`" nao parece ser um executavel valido (sem assinatura MZ)."
            exit 1
        }
        default {
            Show-Aviso "Nao foi possivel determinar o tipo de `"$($item.Name)`"."
            exit 1
        }
    }
}
else {
    Show-Aviso "Extensao `"$ext`" nao suportada por este lancador."
    exit 1
}

# --- Execucao -------------------------------------------------------------

if ($deveExecutar) {
    # Programas DOS costumam esperar seus arquivos de dados no diretorio atual.
    Set-Location -LiteralPath $item.DirectoryName
    Start-Process -FilePath $OtvdmExe -ArgumentList "`"$($item.FullName)`"" -WorkingDirectory $item.DirectoryName
}
