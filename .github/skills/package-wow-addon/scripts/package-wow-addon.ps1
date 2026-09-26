#requires -Version 5.1

[CmdletBinding()]
param(
    [string]$AddonSource = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [string]$OutputDirectory = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")) "dist"),
    [string]$Version
)

$tocFile = Get-ChildItem -LiteralPath $AddonSource -Filter "*.toc" -File | Select-Object -First 1
if ($null -eq $tocFile) {
    throw "No addon TOC file was found in $AddonSource."
}

$tocLines = Get-Content -LiteralPath $tocFile.FullName
$versionLine = $tocLines | Where-Object { $_ -match '^##\s+Version:\s*(.+)$' } | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($Version) -and $versionLine) {
    $Version = $Matches[1].Trim()
}
if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = "unversioned"
}

$safeVersion = $Version -replace '[^A-Za-z0-9._-]', '-'
$addonName = $tocFile.BaseName
$packageName = "$addonName-$safeVersion.zip"
$packagePath = Join-Path $OutputDirectory $packageName
$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("wow-addon-package-" + [guid]::NewGuid().ToString("N"))
$stagingAddon = Join-Path $stagingRoot $addonName

$manifestFiles = @($tocLines | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("##") -and -not $line.StartsWith("#")) {
        $line
    }
})

try {
    New-Item -ItemType Directory -Path $stagingAddon -Force | Out-Null
    Copy-Item -LiteralPath $tocFile.FullName -Destination (Join-Path $stagingAddon $tocFile.Name)

    foreach ($manifestFile in $manifestFiles) {
        if ([System.IO.Path]::IsPathRooted($manifestFile) -or $manifestFile.Contains("..")) {
            throw "Manifest path is outside the addon source: $manifestFile"
        }

        $sourceFile = Join-Path $AddonSource $manifestFile
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            throw "Manifest file was not found: $manifestFile"
        }

        $stagedFile = Join-Path $stagingAddon $manifestFile
        New-Item -ItemType Directory -Path (Split-Path $stagedFile -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $sourceFile -Destination $stagedFile
    }

    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    if (Test-Path -LiteralPath $packagePath) {
        Remove-Item -LiteralPath $packagePath -Force
    }
    Compress-Archive -Path $stagingAddon -DestinationPath $packagePath -CompressionLevel Optimal

    Write-Output "Addon package: $addonName"
    Write-Output "Version: $Version"
    Write-Output "Manifest files: $($manifestFiles.Count)"
    Write-Output "Bundle: $packagePath"
}
finally {
    if (Test-Path -LiteralPath $stagingRoot) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force
    }
}