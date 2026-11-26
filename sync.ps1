<#
.SYNOPSIS
    Sincronizador de Skills Multi-IA para Windows (PowerShell).
.DESCRIPTION
    Vincula as skills deste repositório ao Antigravity, Android Studio, IntelliJ IDEA,
    Claude Code, Cursor e Junie sem exigir privilégios de administrador (via Junctions).
.EXAMPLE
    .\sync.ps1
    .\sync.ps1 -Project "C:\dev\meu-projeto"
#>

param (
    [string]$Project = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "Uso: .\sync.ps1 [OPCOES]"
    Write-Host ""
    Write-Host "Opcoes:"
    Write-Host "  (sem argumentos)       Sincroniza globalmente no usuario (~/.gemini, ~/.android-studio, ~/.agents, IntelliJ, ~/.junie, ~/.claude, ~/.cursor)"
    Write-Host "  -Project <PATH>        Sincroniza dentro do diretorio de um projeto especifico (.agents/skills, .android-studio/skills, .junie/skills, .cursor/rules)"
    Write-Host "  -Help                  Exibe esta mensagem de ajuda"
    exit 0
}

$ErrorActionPreference = "Stop"
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSource = Join-Path $SourceDir "skills"

Write-Host "Sincronizando biblioteca de skills..." -ForegroundColor Cyan
Write-Host "Origem: $SkillsSource"

function Link-SkillDirectory {
    param (
        [string]$TargetRoot
    )
    if (-not (Test-Path $TargetRoot)) {
        New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    }
    Get-ChildItem -Path $SkillsSource -Directory | ForEach-Object {
        $SkillName = $_.Name
        $Dest = Join-Path $TargetRoot $SkillName
        if (Test-Path $Dest) {
            $Item = Get-Item $Dest -Force
            if ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                $Item.Delete()
            } else {
                Remove-Item -Path $Dest -Recurse -Force
            }
        }
        # Junctions funcionam no Windows sem exigir modo Administrador
        New-Item -ItemType Junction -Path $Dest -Target $_.FullName | Out-Null
    }
}

function Link-CursorRules {
    param (
        [string]$TargetRoot
    )
    if (-not (Test-Path $TargetRoot)) {
        New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    }
    Get-ChildItem -Path $SkillsSource -Directory | ForEach-Object {
        $SkillMd = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $SkillMd) {
            $Dest = Join-Path $TargetRoot "$($_.Name).mdc"
            Copy-Item -Path $SkillMd -Destination $Dest -Force
        }
    }
}

# 1. Modo Projeto Especifico
if (-not [string]::IsNullOrWhiteSpace($Project)) {
    if (-not (Test-Path $Project)) {
        Write-Host "Erro: Diretorio do projeto '$Project' nao encontrado." -ForegroundColor Red
        exit 1
    }

    Write-Host "Configurando para o projeto: $Project" -ForegroundColor Yellow

    Link-SkillDirectory (Join-Path $Project ".agents\skills")
    Write-Host "  [OK] Workspace (.agents\skills\) configurado." -ForegroundColor Green

    Link-SkillDirectory (Join-Path $Project ".android-studio\skills")
    Write-Host "  [OK] Android Studio Workspace (.android-studio\skills\) configurado." -ForegroundColor Green

    Link-SkillDirectory (Join-Path $Project ".junie\skills")
    Write-Host "  [OK] IntelliJ / JetBrains (.junie\skills\) configurado." -ForegroundColor Green

    Link-CursorRules (Join-Path $Project ".cursor\rules")
    Write-Host "  [OK] Cursor (.cursor\rules\) configurado." -ForegroundColor Green

    Write-Host "Concluido com sucesso no projeto!" -ForegroundColor Cyan
    exit 0
}

# 2. Modo Global
$UserHome = $env:USERPROFILE

Link-SkillDirectory (Join-Path $UserHome ".gemini\config\skills")
Write-Host "  [OK] Antigravity Global (~\.gemini\config\skills) configurado." -ForegroundColor Green

Link-SkillDirectory (Join-Path $UserHome ".android-studio\skills")
Write-Host "  [OK] Android Studio Global (~\.android-studio\skills) configurado." -ForegroundColor Green

Link-SkillDirectory (Join-Path $UserHome ".agents\skills")
Write-Host "  [OK] Agentes Multi-IDE Global (~\.agents\skills) configurado." -ForegroundColor Green

# JetBrains / IntelliJ IDEA Caches no Windows (%LOCALAPPDATA%\JetBrains\*\aia\agents)
$JetBrainsCache = Join-Path $env:LOCALAPPDATA "JetBrains"
if (Test-Path $JetBrainsCache) {
    Get-ChildItem -Path $JetBrainsCache -Directory | ForEach-Object {
        $AgentsDir = Join-Path $_.FullName "aia\agents"
        if (Test-Path $AgentsDir) {
            Link-SkillDirectory (Join-Path $AgentsDir ".agents\skills")
            Link-SkillDirectory (Join-Path $AgentsDir "views\other\.agents\skills")
            Write-Host "  [OK] IntelliJ IDEA / JetBrains ($($_.Name)) configurado." -ForegroundColor Green
        }
    }
}

Link-SkillDirectory (Join-Path $UserHome ".junie\skills")
Write-Host "  [OK] IntelliJ / JetBrains Junie (~\.junie\skills) configurado." -ForegroundColor Green

Link-SkillDirectory (Join-Path $UserHome ".claude\skills")
Write-Host "  [OK] Claude Code (~\.claude\skills) configurado." -ForegroundColor Green

Link-CursorRules (Join-Path $UserHome ".cursor\rules")
Write-Host "  [OK] Cursor Global (~\.cursor\rules) configurado." -ForegroundColor Green

# 3. Atualizar Catalogo Dinamico no README.md (se Python estiver disponivel)
$CatalogScript = Join-Path $SourceDir "scripts\update-catalog.py"
if ((Test-Path $CatalogScript) -and (Get-Command python -ErrorAction SilentlyContinue)) {
    python $CatalogScript
}

Write-Host ""
Write-Host "Pronto! Todas as skills foram vinculadas." -ForegroundColor Cyan
