param()
$ErrorActionPreference = 'Stop'
# No connection strings, no host port, no project database or named volume.
$phaseRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$phaseImage = 'postgres:17-alpine@sha256:18cfe3ef5e6815560c98237d6216d1e5119702fb0f3894c8785dd58b8bbe5d73'
$phaseContainer = 'biletify-phase1-test-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$phaseStarted = $false
try {
    & docker image inspect $phaseImage --format '{{.Id}}'
    if ($LASTEXITCODE -ne 0) { throw 'Approved PostgreSQL test image is missing. No automatic downloads.' }
    & docker run --detach --rm --name $phaseContainer --label 'biletify.phase1-test=true' --network none --tmpfs '/var/lib/postgresql/data:rw' --mount "type=bind,source=$phaseRoot,target=/workspace,readonly" --env 'POSTGRES_HOST_AUTH_METHOD=trust' $phaseImage
    if ($LASTEXITCODE -ne 0) { throw 'Cannot start isolated test container.' }
    $phaseStarted = $true
    $phaseReady = $false
    for ($phaseTry = 0; $phaseTry -lt 30; $phaseTry++) {
        & docker exec $phaseContainer pg_isready -h 127.0.0.1 -U postgres 2>$null
        if ($LASTEXITCODE -eq 0) { $phaseReady = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $phaseReady) { throw 'Local PostgreSQL did not become ready.' }
    & docker exec $phaseContainer psql -X -U postgres -d postgres -v ON_ERROR_STOP=1 -f /workspace/tests/phase1.sql
    if ($LASTEXITCODE -ne 0) { throw 'Phase 1 SQL validation failed.' }
} finally {
    if ($phaseStarted) {
        $phaseLabelsJson = & docker inspect --format '{{json .Config.Labels}}' $phaseContainer
        if ($LASTEXITCODE -eq 0 -and ($phaseLabelsJson | ConvertFrom-Json).'biletify.phase1-test' -eq 'true') {
            & docker stop --timeout 5 $phaseContainer
            if ($LASTEXITCODE -ne 0) { Write-Warning "Test container cleanup failed: $phaseContainer" }
        }
    }
}
