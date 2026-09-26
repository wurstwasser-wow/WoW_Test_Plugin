#requires -Version 5.1

[CmdletBinding()]
param(
    [string]$LogPath = "C:\Program Files (x86)\World of Warcraft\_retail_\Logs",
    [string]$PluginName = "WoW_Test_Plugin",
    [string]$OutputDirectory = (Join-Path (Get-Location) "artifacts\wow-log-analysis")
)

if (-not (Test-Path -LiteralPath $LogPath -PathType Container)) {
    throw "WoW log directory was not found: $LogPath"
}

$logFiles = @(Get-ChildItem -LiteralPath $LogPath -File -Recurse | Where-Object { $_.Extension -in @(".txt", ".log") })
if ($logFiles.Count -eq 0) {
    throw "No .txt or .log files were found under $LogPath"
}

$matchingLines = New-Object System.Collections.Generic.List[object]
foreach ($logFile in $logFiles) {
    $lineNumber = 0
    foreach ($line in (Get-Content -LiteralPath $logFile.FullName -ErrorAction Stop)) {
        $lineNumber++
        if ($line.IndexOf($PluginName, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $matchingLines.Add([pscustomobject]@{
                File = $logFile.FullName
                Line = $lineNumber
                Text = $line
            })
        }
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$filteredPath = Join-Path $OutputDirectory "filtered.log"
$analysisPath = Join-Path $OutputDirectory "analysis.md"
$summaryPath = Join-Path $OutputDirectory "summary.json"

$filteredContent = foreach ($match in $matchingLines) {
    "[{0}:{1}] {2}" -f $match.File, $match.Line, $match.Text
}
Set-Content -LiteralPath $filteredPath -Value $filteredContent -Encoding UTF8

$errorPatterns = [ordered]@{
    "attempt to" = "Check the value used at the reported line. A WoW API may have returned nil, or an object may not exist in the current lifecycle state. Add a nil/state guard and verify the API return contract."
    "bad argument" = "Compare the argument types and order with the current WoW API. Validate optional values before calling the function."
    "stack traceback" = "Start at the first addon source line in the traceback, then inspect the callers and the event or slash-command path that triggered it."
    "interface\\addons" = "Confirm the file is listed in the TOC, the path and filename match exactly, and the failing line is compatible with client interface 120100."
    "taint" = "Check secure frame and protected-action usage. Avoid modifying protected attributes or calling restricted APIs during combat."
    "load.*failed|couldn't load" = "Check the TOC filename, manifest order, dependencies, and missing files. Reload after correcting the package."
    "nil value|nil" = "Guard initialization and event data. Confirm ADDON_LOADED or PLAYER_LOGIN has run before reading addon state."
    "unknown event|event.*does not exist" = "Verify the event name against the current WoW API and unregister obsolete events."
    "syntax error|unexpected symbol" = "Inspect the reported Lua line and the preceding lines for an unclosed string, table, function, or mismatched delimiter."
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# WoW Log Analysis")
$report.Add("")
$report.Add(('- Plugin filter: `{0}`' -f $PluginName))
$report.Add(('- Log directory: `{0}`' -f $LogPath))
$report.Add("- Log files scanned: $($logFiles.Count)")
$report.Add("- Matching lines: $($matchingLines.Count)")
$report.Add("")

if ($matchingLines.Count -eq 0) {
    $report.Add("## Result")
    $report.Add("")
    $report.Add("No lines containing the plugin filter were found. Enable Lua error display or relevant WoW logging, reproduce the issue, and run the analysis again.")
} else {
    $report.Add("## Matching Files")
    $report.Add("")
    $matchingLines | Group-Object File | ForEach-Object {
        $report.Add(('- `{0}`: {1} matching line(s)' -f $_.Name, $_.Count))
    }
    $report.Add("")
    $report.Add("## Findings and Suggested Fixes")
    $report.Add("")

    $allText = ($matchingLines.Text -join "`n")
    $foundFinding = $false
    foreach ($pattern in $errorPatterns.Keys) {
        if ($allText -match $pattern) {
            $foundFinding = $true
            $report.Add("### $pattern")
            $report.Add("")
            $report.Add($errorPatterns[$pattern])
            $report.Add("")
        }
    }

    if (-not $foundFinding) {
        $report.Add("No known error signature matched the filtered lines. Review `filtered.log` and correlate each line with the addon source and client state.")
        $report.Add("")
    }

    $report.Add("## Relevant Output")
    $report.Add("")
    foreach ($match in $matchingLines | Select-Object -First 50) {
        $report.Add(('- `{0}:{1}` {2}' -f $match.File, $match.Line, $match.Text))
    }
}

Set-Content -LiteralPath $analysisPath -Value $report -Encoding UTF8

$summary = [pscustomobject]@{
    PluginName = $PluginName
    LogPath = (Resolve-Path $LogPath).Path
    LogFilesScanned = $logFiles.Count
    MatchingLines = $matchingLines.Count
    FilteredOutput = (Resolve-Path $filteredPath).Path
    AnalysisOutput = (Resolve-Path $analysisPath).Path
}
$summary | ConvertTo-Json | Set-Content -LiteralPath $summaryPath -Encoding UTF8

Write-Output "Log files scanned: $($logFiles.Count)"
Write-Output "Matching lines: $($matchingLines.Count)"
Write-Output "Filtered output: $filteredPath"
Write-Output "Analysis report: $analysisPath"
Write-Output "Summary: $summaryPath"