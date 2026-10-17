# DosLauncher by Jair Lima

Scripts para executar programas DOS e Windows de 16 bits no Windows 64 bits, onde o `NTVDM` não existe. Há dois mecanismos independentes.

## 1. Menu de contexto com otvdm

Adiciona "Executar no DOS (otvdm)" ao clicar com o botão direito em `.exe` e `.com`. O `dos-launch.ps1` lê o cabeçalho do arquivo e só chama o otvdm se for realmente um programa DOS ou de 16 bits. Programas Windows normais (32/64 bits) recebem um aviso e não são executados.

1. Baixe o **otvdm** (winevdm) em [github.com/otya128/winevdm](https://github.com/otya128/winevdm) e extraia na pasta `otvdm\` ao lado dos scripts, de modo que exista `otvdm\otvdmw.exe`.
2. Execute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File install-menu.ps1
```

Para remover: `uninstall-menu.ps1`.

## 2. DOSBox-X com uma pasta DOS montada

O `abrir-dos-vm.ps1` abre o DOSBox-X com uma pasta do seu disco montada como unidade C:, usando o `dos-vm.conf`.

1. Baixe o **DOSBox-X** em [dosbox-x.com](https://dosbox-x.com) e coloque em `dosbox-x\bin\x64\Release\dosbox-x.exe`.
2. Edite a linha `mount c C:\dos` do `dos-vm.conf` para apontar para a sua pasta.
3. Execute `abrir-dos-vm.ps1`.

## Observação

Este repositório contém só os scripts. O otvdm e o DOSBox-X são projetos de terceiros, cada um com a sua licença.

## Licença

MIT, veja [LICENSE](LICENSE).
