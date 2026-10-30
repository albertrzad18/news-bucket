# Uploads the release signing key to the GitHub repository secrets used by
# .github/workflows/release.yml. Run from the repository root:
#
#   powershell -ExecutionPolicy Bypass -File tool/set_release_secrets.ps1
#
# Reads android/key.properties (never committed) and the keystore it points
# to. Values go to `gh secret set` through stdin, so they don't end up in the
# shell history or process list.
$ErrorActionPreference = 'Stop'

$props = @{}
Get-Content 'android/key.properties' | ForEach-Object {
    $key, $value = $_ -split '=', 2
    if ($key) { $props[$key.Trim()] = $value.Trim() }
}

$keystore = $props['storeFile']
if (-not (Test-Path $keystore)) { throw "Keystore not found: $keystore" }

[Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) | gh secret set KEYSTORE_BASE64
$props['storePassword'] | gh secret set KEYSTORE_PASSWORD
$props['keyAlias'] | gh secret set KEY_ALIAS
$props['keyPassword'] | gh secret set KEY_PASSWORD

gh secret list
