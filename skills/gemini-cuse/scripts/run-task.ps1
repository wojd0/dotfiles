param(
    [Parameter(Mandatory = $true)][string]$Task,
    [Parameter(Mandatory = $true)][string]$Success,
    [int]$TimeoutSec = 900,
    [string]$Model = 'gemini-3.8-flash-medium',
    [string]$Conversation = '',
    [string]$RunRoot = (Join-Path $env:LOCALAPPDATA 'gemini-cuse\runs')
)

$ErrorActionPreference = 'Stop'
$skillDir = Split-Path -Parent $PSScriptRoot
$runDir = Join-Path $RunRoot (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
New-Item -ItemType Directory -Force $runDir | Out-Null

$brief = Get-Content -Raw (Join-Path $skillDir 'references\worker-brief.md')
$brief = $brief.Replace('{{TASK}}', $Task).Replace('{{SUCCESS}}', $Success).Replace('{{RUN_DIR}}', $runDir)
Set-Content -Encoding utf8 -Path (Join-Path $runDir 'TASK.md') -Value $brief

Copy-Item (Join-Path $skillDir 'references\result-schema.json') (Join-Path $runDir 'result-schema.json')
$settings = @{ permissions = @{ allow = @('mcp(cua-driver/*)') } } | ConvertTo-Json -Depth 5
Set-Content -Encoding ascii -Path (Join-Path $runDir 'session-settings.json') -Value $settings

$agyArgs = @(
    '-p', 'Read the file TASK.md in the current directory. Do the task that it describes. Nobody else can see or control this computer, so you own the task from start to end.',
    '--model', $Model,
    '--output-format', 'json',
    '--json-schema', (Join-Path $runDir 'result-schema.json'),
    '--settings', (Join-Path $runDir 'session-settings.json'),
    '--print-timeout', "$($TimeoutSec)s"
)
if ($Conversation) { $agyArgs += @('--conversation', $Conversation) }

Push-Location $runDir
try {
    $out = & agy @agyArgs 2> (Join-Path $runDir 'agy-stderr.log')
    $code = $LASTEXITCODE
}
finally {
    Pop-Location
}
$out | Set-Content -Encoding utf8 -Path (Join-Path $runDir 'output.json')

[pscustomobject]@{
    run_dir     = $runDir
    exit_code   = $code
    output_file = Join-Path $runDir 'output.json'
    screenshot  = Join-Path $runDir 'final.png'
    has_screenshot = Test-Path (Join-Path $runDir 'final.png')
} | ConvertTo-Json
"----- agy output -----"
$out
