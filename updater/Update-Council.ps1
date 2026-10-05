param([string]$InstallPath = '')
$ErrorActionPreference = 'Stop'
try {
 if (-not $InstallPath) { $InstallPath = $PSScriptRoot }
 $configPath = Join-Path $InstallPath 'council-updater.json'
 if (-not (Test-Path $configPath)) { throw 'Run Setup-Council.cmd first.' }
 $config = Get-Content $configPath -Raw | ConvertFrom-Json
 if ($config.repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Invalid repository configuration.' }
 $headers = @{ 'User-Agent' = 'Council-Updater'; 'Accept' = 'application/vnd.github+json' }
 if ($env:COUNCIL_GITHUB_TOKEN) { $headers.Authorization = "Bearer $env:COUNCIL_GITHUB_TOKEN" }
 $ref = [Uri]::EscapeDataString($config.branch)
 $commit = Invoke-RestMethod -Uri "https://api.github.com/repos/$($config.repository)/commits/$ref" -Headers $headers
 $sha = $commit.sha
 if ($sha -notmatch '^[a-f0-9]{40}$') { throw 'Invalid release commit.' }
 $base = "https://raw.githubusercontent.com/$($config.repository)/$sha"
 $release = Invoke-RestMethod -Uri "$base/update.json" -Headers $headers
 if ($release.schema -ne 1) { throw 'Unsupported release format.' }
 $allowed = @('manifest.json','background.js','bridge.js','room.html','room.js','style.css','README.md')
 if ($release.files.Count -ne $allowed.Count) { throw 'Incomplete release file list.' }
 $seen = @{}
 foreach ($file in $release.files) {
  if ($file.path -notin $allowed -or $seen.ContainsKey($file.path) -or $file.sha256 -notmatch '^[a-f0-9]{64}$') { throw 'Invalid release file.' }
  $seen[$file.path] = $true
 }
 if (Test-Path (Join-Path $InstallPath 'manifest.json')) { $target = $InstallPath } else { $target = Join-Path $InstallPath 'council' }
 if (-not (Test-Path (Join-Path $target 'manifest.json'))) { throw 'Council installation is missing.' }
 $stamp = Join-Path $InstallPath 'installed-commit.txt'
 if ((Test-Path $stamp) -and (Get-Content $stamp -Raw).Trim() -eq $sha) { Write-Host 'Council is already up to date.'; exit 0 }
 $stage = Join-Path ([IO.Path]::GetTempPath()) ('council-' + [Guid]::NewGuid())
 New-Item -ItemType Directory $stage | Out-Null
 try {
  foreach ($file in $release.files) {
   $dest = Join-Path $stage $file.path
   Invoke-WebRequest -UseBasicParsing -Uri "$base/council/$($file.path)" -Headers $headers -OutFile $dest
   if ((Get-FileHash $dest -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { throw "Checksum mismatch: $($file.path)" }
  }
  $manifest = Get-Content (Join-Path $stage 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($manifest.name -ne ('Council ' + [char]0x2014 + ' AI Group Chat') -or $manifest.manifest_version -ne 3 -or $manifest.version -ne $release.version) { throw 'Invalid Council manifest.' }
  $backup = Join-Path ([IO.Path]::GetDirectoryName($target.TrimEnd([IO.Path]::DirectorySeparatorChar))) 'council-backup'
  if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
  New-Item -ItemType Directory $backup | Out-Null
  foreach ($name in $allowed) { $existing = Join-Path $target $name; if (Test-Path $existing) { Copy-Item $existing (Join-Path $backup $name) } }
  try {
   foreach ($name in $allowed | Where-Object { $_ -ne 'manifest.json' }) { Copy-Item (Join-Path $stage $name) (Join-Path $target $name) -Force }
   Copy-Item (Join-Path $stage 'manifest.json') (Join-Path $target 'manifest.json') -Force
   Set-Content -Path $stamp -Value $sha -Encoding ASCII
  } catch {
   foreach ($name in $allowed) { $prior = Join-Path $backup $name; if (Test-Path $prior) { Copy-Item $prior (Join-Path $target $name) -Force } }
   throw
  }
  Write-Host "Updated Council to $($release.version)."
  Write-Host 'Click Reload for Council in chrome://extensions, then refresh the provider tabs and Council room.'
 } finally { if (Test-Path $stage) { Remove-Item $stage -Recurse -Force } }
} catch { Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }
