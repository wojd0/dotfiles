<#
.SYNOPSIS
  Sync the AI agent configuration (rules, skills, sub-agents, MCP) from this repository into the home directory on Windows.

.DESCRIPTION
  Links the contents of .agents and custom-skills into ~/.agents, ~/.claude, and ~/.codex.
  It installs the skills from skills-lock.json with Bun first.
  It does not install packages and does not touch the shell, git, local, or cron packages.
  Directories become junctions and files become hard links, so no administrator rights are needed.
  Hard links break when git replaces a file, so run this script again after each pull.

.PARAMETER NoPull
  Do not pull the repository before the sync.
#>
param([switch]$NoPull)

$ErrorActionPreference = 'Stop'

$Repo = Split-Path -Parent $PSScriptRoot
$Agents = Join-Path $Repo '.agents'
$HomeAgents = Join-Path $HOME '.agents'
$Manifest = Join-Path $HomeAgents '.dotfiles-sync'
$Stamp = Get-Date -Format 'yyyyMMddHHmmss'

$managed = @()
if (Test-Path $Manifest) { $managed = @(Get-Content $Manifest) }
$newManaged = New-Object System.Collections.Generic.List[string]

function Get-LinkTarget($path) {
  $item = Get-Item -Force $path
  if ($item.LinkType -in 'Junction', 'SymbolicLink') { return ([string]$item.Target).TrimEnd('\') }
  return $null
}

function Test-InRepo($path) {
  return $path -and $path.StartsWith($Repo, [StringComparison]::OrdinalIgnoreCase)
}

function Sync-File($src, $dst) {
  if (Test-Path -LiteralPath $dst) {
    $known = ($managed -contains $dst) -or
      ((Get-FileHash $dst).Hash -eq (Get-FileHash $src).Hash)
    if (-not $known) {
      Move-Item -LiteralPath $dst "$dst.bak-$Stamp"
      Write-Host "backup $dst -> $dst.bak-$Stamp"
    } else {
      Remove-Item -LiteralPath $dst -Force
    }
  }
  try { New-Item -ItemType HardLink -Path $dst -Target $src | Out-Null }
  catch { Copy-Item -LiteralPath $src $dst }
  $newManaged.Add($dst)
}

function Sync-Item($src, $dst) {
  if (-not (Test-Path -LiteralPath $src -PathType Container)) { return Sync-File $src $dst }

  if (-not (Test-Path -LiteralPath $dst)) {
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    Write-Host "link $dst"
    return
  }

  $target = Get-LinkTarget $dst
  if ($target) {
    if ($target -ieq $src) { return }
    if (Test-InRepo $target) {
      (Get-Item -Force $dst).Delete()
      New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
      Write-Host "relink $dst"
    } else {
      Write-Warning "skip $dst (links to $target)"
    }
    return
  }

  if (Test-Path -LiteralPath $dst -PathType Leaf) {
    Write-Warning "skip $dst (is a file)"
    return
  }

  foreach ($child in Get-ChildItem -Force $src) {
    Sync-Item $child.FullName (Join-Path $dst $child.Name)
  }
}

# Remove junctions into the repository whose target no longer exists.
function Remove-StaleLinks($dir) {
  foreach ($item in Get-ChildItem -Force $dir) {
    $target = Get-LinkTarget $item.FullName
    if ((Test-InRepo $target) -and -not (Test-Path -LiteralPath $target)) {
      $item.Delete()
      Write-Host "remove stale $($item.FullName)"
    }
  }
}

function Sync-Skills($dst) {
  New-Item -ItemType Directory -Force $dst | Out-Null
  foreach ($skill in $skills) {
    $path = Join-Path $dst $skill.Name
    # A real skill directory belongs to another installer, such as the global skills CLI.
    if ((Test-Path -LiteralPath $path) -and -not (Get-LinkTarget $path)) {
      Write-Warning "skip $path (not managed by dotfiles)"
      continue
    }
    Sync-Item $skill.FullName $path
  }
  Remove-StaleLinks $dst
}

if (-not $NoPull) {
  if (git -C $Repo status --porcelain) {
    Write-Warning 'the working tree has local changes; skip the pull'
  } else {
    git -C $Repo pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw 'git pull --ff-only failed' }
  }
}

function Install-LockedSkills {
  $bun = (Get-Command bun -ErrorAction SilentlyContinue).Source
  if (-not $bun) { $bun = Join-Path $HOME '.bun\bin\bun.exe' }
  if (-not (Test-Path $bun)) { throw 'bun is required; run: winget install Oven-sh.Bun' }

  Push-Location $Repo
  try {
    & $bun x skills experimental_install
    $code = $LASTEXITCODE
    git restore --worktree -- .agents skills-lock.json
  } finally { Pop-Location }
  if ($code -ne 0) { throw 'skills install from skills-lock.json failed' }

  $lock = Get-Content (Join-Path $Repo 'skills-lock.json') -Raw | ConvertFrom-Json
  foreach ($name in $lock.skills.PSObject.Properties.Name) {
    if (-not (Test-Path (Join-Path $Agents "skills\$name\SKILL.md"))) {
      throw "lock-managed skill '$name' was not restored"
    }
  }
}

Install-LockedSkills

# Lock-managed skills are real directories in .agents/skills. With core.symlinks=false,
# the custom-skill links there are plain files, so custom skills come from custom-skills/.
$skills = @(Get-ChildItem -Directory (Join-Path $Agents 'skills')) +
  @(Get-ChildItem -Directory (Join-Path $Repo 'custom-skills'))

$claude = Join-Path $HOME '.claude'
$codex = Join-Path $HOME '.codex'
New-Item -ItemType Directory -Force $HomeAgents, $claude, $codex | Out-Null

foreach ($entry in Get-ChildItem -Force $Agents) {
  if ($entry.Name -eq 'skills') { continue }
  Sync-Item $entry.FullName (Join-Path $HomeAgents $entry.Name)
}
Sync-Skills (Join-Path $HomeAgents 'skills')

Sync-Item (Join-Path $Agents 'rules') (Join-Path $claude 'rules')
Sync-Item (Join-Path $Agents 'agents') (Join-Path $claude 'agents')
Sync-Item (Join-Path $Agents 'AGENTS.md') (Join-Path $claude 'CLAUDE.md')
Sync-Skills (Join-Path $claude 'skills')

Sync-Item (Join-Path $Agents 'agents') (Join-Path $codex 'agents')

Set-Content -Path $Manifest -Value $newManaged -Encoding utf8
Write-Host 'Agent sync complete.'
