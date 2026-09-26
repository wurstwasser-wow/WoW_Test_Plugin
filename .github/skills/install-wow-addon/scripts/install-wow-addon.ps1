#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
param(
    [string]$WowRoot = "C:\Program Files (x86)\World of Warcraft",
    [string]$Flavor = "_retail_",
    [string]$AddonSource = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\.."))
)

$tocFile = Get-ChildItem -LiteralPath $AddonSource -Filter "*.toc" -File | Select-Object -First 1
if ($null -eq $tocFile) {
    throw "No addon TOC file was found in $AddonSource."
}

$tocLines = Get-Content -LiteralPath $tocFile.FullName
$manifestFiles = @($tocLines | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("##") -and -not $line.StartsWith("#")) {
        $line
    }
})

$addonDestination = Join-Path $WowRoot "$Flavor\Interface\AddOns\$($tocFile.BaseName)"
if (-not (Test-Path -LiteralPath (Split-Path $addonDestination -Parent))) {
    throw "WoW AddOns directory was not found: $(Split-Path $addonDestination -Parent)"
}

if ($PSCmdlet.ShouldProcess($addonDestination, "Install $($tocFile.BaseName)")) {
    New-Item -ItemType Directory -Path $addonDestination -Force | Out-Null
    Copy-Item -LiteralPath $tocFile.FullName -Destination (Join-Path $addonDestination $tocFile.Name) -Force

    foreach ($manifestFile in $manifestFiles) {
        $sourceFile = Join-Path $AddonSource $manifestFile
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            throw "Manifest file was not found: $manifestFile"
        }

        $destinationFile = Join-Path $addonDestination $manifestFile
        New-Item -ItemType Directory -Path (Split-Path $destinationFile -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $sourceFile -Destination $destinationFile -Force
    }
}

Write-Output "Addon package: $($tocFile.BaseName)"
Write-Output "Destination: $addonDestination"
Write-Output "Manifest files: $($manifestFiles.Count)"