param(
    [Parameter(Mandatory = $true)][string]$CliPath,
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)]
    [ValidateSet('CheckClean', 'PrepareLegacy', 'UpgradeValidate', 'Stop')][string]$Action
)
$ErrorActionPreference = 'Stop'
$phaseProject = [IO.Path]::GetFullPath($ProjectPath)
$phaseTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
if (-not $phaseProject.StartsWith($phaseTempRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Only a disposable project in the OS temporary directory is allowed.'
}
$phaseConfigPath = Join-Path $phaseProject 'supabase\config.toml'
$phaseConfig = Get-Content -Raw -LiteralPath $phaseConfigPath
$phaseMatch = [regex]::Match($phaseConfig, '(?m)^project_id = "(biletify-phase15-[a-z0-9]+)"\s*$')
if (-not $phaseMatch.Success) { throw 'Not a dedicated Phase 1.5 local test project.' }
$phaseId = $phaseMatch.Groups[1].Value
if (Test-Path -LiteralPath (Join-Path $phaseProject 'supabase\.temp\project-ref')) {
    throw 'Linked projects are forbidden.'
}
$phaseCli = [IO.Path]::GetFullPath($CliPath)
if (-not $phaseCli.StartsWith($phaseTempRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Use the checksum-verified portable CLI in the temporary test directory.'
}
$env:SUPABASE_TELEMETRY_DISABLED = '1'
$env:DO_NOT_TRACK = '1'
# No inherited remote Supabase credentials are used by any child command.
Remove-Item Env:SUPABASE_ACCESS_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:SUPABASE_DB_PASSWORD -ErrorAction SilentlyContinue
$phaseState = Join-Path $phaseProject 'phase15-test-state.json'
$phaseTests = Join-Path $PSScriptRoot 'phase15-local.mjs'
$phaseRepoMigrations = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\migrations'))
foreach ($phaseName in @('20260904000000_initial_schema.sql', '20260905191100_shared_catalog_foundation.sql')) {
    $phaseSourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $phaseRepoMigrations $phaseName)).Hash
    $phaseCopyHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $phaseProject "supabase\migrations\$phaseName")).Hash
    if ($phaseSourceHash -ne $phaseCopyHash) { throw "Migration copy differs: $phaseName" }
}
function Invoke-PhaseCli {
    param([string[]]$CliArguments, [string]$LogName)
    $phaseOut = Join-Path $phaseProject "$LogName.stdout.log"
    $phaseErr = Join-Path $phaseProject "$LogName.stderr.log"
    # Native stderr is kept out of PowerShell's terminating-error pipeline.
    $phaseOldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $phaseCli @CliArguments --workdir $phaseProject --yes 1> $phaseOut 2> $phaseErr
    $phaseExit = $LASTEXITCODE
    $ErrorActionPreference = $phaseOldPreference
    if ($phaseExit -ne 0) { throw "Local CLI operation failed ($phaseExit). Inspect temporary $LogName logs without exposing keys." }
    Write-Output "LOCAL_CLI_OK: $LogName"
}
function Invoke-PhaseHttpTests {
    param([string]$Mode)
    $phaseOldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $phaseRaw = & $phaseCli status --workdir $phaseProject --output json 2> (Join-Path $phaseProject 'status.stderr.log')
    $phaseExit = $LASTEXITCODE
    $ErrorActionPreference = $phaseOldPreference
    if ($phaseExit -ne 0) { throw 'Local CLI status failed.' }
    $phaseStatus = ($phaseRaw -join [Environment]::NewLine) | ConvertFrom-Json
    if ($phaseStatus.API_URL -ne 'http://127.0.0.1:56321') { throw 'Unexpected local API address.' }
    # Status keys are only passed through stdin; no token file or console dump.
    $phaseInput = @{ mode = $Mode; projectId = $phaseId; statePath = $phaseState; status = $phaseStatus } | ConvertTo-Json -Depth 8 -Compress
    $phaseInput | & node $phaseTests
    if ($LASTEXITCODE -ne 0) { throw "Real local Supabase tests failed: $Mode" }
}
switch ($Action) {
    'CheckClean' { Invoke-PhaseHttpTests -Mode 'clean' }
    'PrepareLegacy' {
        # Only this newly created disposable database is reset. No remote flags.
        Invoke-PhaseCli -CliArguments @('db', 'reset', '--local', '--version', '20260904000000', '--no-seed') -LogName 'reset-initial'
        Invoke-PhaseHttpTests -Mode 'legacy-setup'
    }
    'UpgradeValidate' {
        Invoke-PhaseCli -CliArguments @('migration', 'up', '--local') -LogName 'upgrade-phase1'
        Invoke-PhaseHttpTests -Mode 'validate'
    }
    'Stop' {
        # Scoped to the tested project; never --all. Removes only disposable volumes.
        Invoke-PhaseCli -CliArguments @('stop', '--project-id', $phaseId, '--no-backup') -LogName 'stop-local-test'
    }
}
