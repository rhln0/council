$ErrorActionPreference = 'Stop'
try {
 Write-Host 'Council setup — keep your existing extension folder to preserve local conversation history.'
 $root = Read-Host 'Full path to your Council extension folder, or its parent (Enter uses this extracted folder)'
 if (-not $root) { $root = $PSScriptRoot }
 $root = [IO.Path]::GetFullPath($root.Trim('"'))
 New-Item -ItemType Directory $root -Force | Out-Null
 $repo = Read-Host 'Update repository owner/name (Enter uses rhln0/council)'
 if (-not $repo) { $repo = 'rhln0/council' }
 if ($repo -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Use owner/repository format.' }
 if (Test-Path (Join-Path $root 'manifest.json')) { $target = $root } else { $target = Join-Path $root 'council' }
 if (-not (Test-Path (Join-Path $target 'manifest.json'))) {
  Copy-Item (Join-Path $PSScriptRoot 'council') $root -Recurse -Force
 }
 foreach ($name in @('Update-Council.ps1','Update-Council.cmd')) {
  $source = Join-Path $PSScriptRoot $name
  $dest = Join-Path $root $name
  if ([IO.Path]::GetFullPath($source) -ne [IO.Path]::GetFullPath($dest)) { Copy-Item $source $dest -Force }
 }
 @{repository=$repo;branch='main'} | ConvertTo-Json | Set-Content (Join-Path $root 'council-updater.json') -Encoding UTF8
 Write-Host "Updater installed in $root."
 Write-Host 'After the repository is published, double-click Update-Council.cmd whenever an update is ready.'
 Write-Host "For a new installation: Load unpacked in Chrome and select $target."
} catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 1 }
