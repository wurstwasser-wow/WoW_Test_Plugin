#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
param(
    [string]$WowRoot = "C:\Program Files (x86)\World of Warcraft",
    [string]$Flavor = "_retail_",
    [string]$AddonName
)

if ([string]::IsNullOrWhiteSpace($AddonName)) {
    $sourceRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")
    $tocFile = Get-ChildItem -LiteralPath $sourceRoot -Filter "*.toc" -File | Select-Object -First 1
    if ($null -eq $tocFile) {
        throw "No addon TOC file was found in $sourceRoot."
    }

    $AddonName = $tocFile.BaseName
}

$addonDestination = Join-Path $WowRoot "$Flavor\Interface\AddOns\$AddonName"

if (-not (Test-Path -LiteralPath $addonDestination -PathType Container)) {
    Write-Warning "Addon folder was not found: $addonDestination"
    return
}

if ($PSCmdlet.ShouldProcess($addonDestination, "Remove addon $AddonName")) {
    Remove-Item -LiteralPath $addonDestination -Recurse -Force
}

Write-Output "Removed addon: $AddonName"
Write-Output "Destination: $addonDestination"
