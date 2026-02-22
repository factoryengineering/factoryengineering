# Set up symlinks so .claude/commands and .claude/skills are available in each IDE.
# Run from repository root. See SKILL.md for full workflow.
#
# Usage:
#   .\Setup-Symlinks.ps1 -Detect
#   .\Setup-Symlinks.ps1 -Ide cursor,windsurf,kilocode,antigravity
#   .\Setup-Symlinks.ps1 -Type all -Ide cursor
#   .\Setup-Symlinks.ps1 -Ide cursor -CopyExisting
#   .\Setup-Symlinks.ps1 -RepoRoot C:\path\to\repo -Ide cursor

param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot = (Get-Location).Path,
    [Parameter(Mandatory = $false)]
    [ValidateSet('commands', 'skills', 'all')]
    [string]$Type = 'all',
    [Parameter(Mandatory = $false)]
    [switch]$Detect,
    [Parameter(Mandatory = $false)]
    [string]$Ide,
    [Parameter(Mandatory = $false)]
    [switch]$CopyExisting
)

$ErrorActionPreference = 'Stop'

$canonicalCommands = '.claude/commands'
$canonicalSkills = '.claude/skills'
$targetsCommands = @{
    cursor     = '.cursor/commands'
    windsurf   = '.windsurf/workflows'
    kilocode   = '.kilocode/workflows'
    antigravity = '.agent/workflows'
}
$targetsSkills = @{
    cursor     = '.cursor/skills'
    windsurf   = '.windsurf/skills'
    kilocode   = '.kilocode/skills'
    antigravity = '.agent/skills'
}

function Get-DetectedIdes {
    param([string]$root)
    $detected = @()
    if (Test-Path -LiteralPath (Join-Path $root '.cursor')) { $detected += 'cursor' }
    if (Test-Path -LiteralPath (Join-Path $root '.windsurf')) { $detected += 'windsurf' }
    if (Test-Path -LiteralPath (Join-Path $root '.kilocode')) { $detected += 'kilocode' }
    if (Test-Path -LiteralPath (Join-Path $root '.agent')) { $detected += 'antigravity' }
    return $detected
}

function New-SymlinkForTarget {
    param(
        [string]$root,
        [string]$targetRelativePath,
        [string]$canonicalDir,
        [bool]$copyExisting
    )
    $targetPath = Join-Path $root $targetRelativePath
    $parentDir = Split-Path -Parent $targetPath
    $existingMsg = "Target $targetPath already exists. Use -CopyExisting to copy its contents to $canonicalDir and then create the symlink."

    if (Test-Path -LiteralPath $targetPath -PathType Container) {
        $item = Get-Item -LiteralPath $targetPath -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $linkTarget = $item.Target
            if ($linkTarget -and ($linkTarget -match "\.claude[\\/](commands|skills)$")) {
                Write-Host "Already a symlink: $targetPath"
                return 0
            }
            Write-Error "$targetPath is a symlink but not to $canonicalDir."
        }
        if ($item.PSIsContainer -and -not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            if ($copyExisting) {
                Write-Host "Copying existing $targetPath into $canonicalDir ..."
                $canonicalFull = Join-Path $root $canonicalDir
                if (-not (Test-Path -LiteralPath $canonicalFull)) {
                    New-Item -ItemType Directory -Path $canonicalFull -Force | Out-Null
                }
                Get-ChildItem -LiteralPath $targetPath -Force | Copy-Item -Destination $canonicalFull -Recurse -Force
                Remove-Item -LiteralPath $targetPath -Recurse -Force
            } else {
                Write-Error $existingMsg
            }
        }
    }

    $canonicalFull = Join-Path $root $canonicalDir
    if (-not (Test-Path -LiteralPath $canonicalFull)) {
        New-Item -ItemType Directory -Path $canonicalFull -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    $relativeTarget = '..' + [IO.Path]::DirectorySeparatorChar + $canonicalDir -replace '/', [IO.Path]::DirectorySeparatorChar

    New-Item -ItemType SymbolicLink -Path $targetPath -Target $relativeTarget -Force | Out-Null
    Write-Host "Created: $targetPath -> $relativeTarget"
    return 0
}

$repoFull = (Resolve-Path -LiteralPath $RepoRoot).Path
Set-Location $repoFull

if ($Detect) {
    $detected = Get-DetectedIdes -root $repoFull
    if ($detected.Count -eq 0) {
        Write-Host "No IDE directories (.cursor, .windsurf, .kilocode, .agent) found in $repoFull"
    } else {
        $detected | ForEach-Object { Write-Host $_ }
    }
    exit 0
}

if (-not $Ide) {
    Write-Error "Specify -Ide cursor,windsurf,kilocode,antigravity or run with -Detect first."
}

$ideList = $Ide -split '[,;\s]+' | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ }
$validIdes = @('cursor', 'windsurf', 'kilocode', 'antigravity')
foreach ($ide in $ideList) {
    if ($ide -notin $validIdes) {
        Write-Error "Unknown IDE: $ide. Use cursor, windsurf, kilocode, antigravity."
    }
}

$exitCode = 0
foreach ($ide in $ideList) {
    try {
        if ($Type -eq 'commands' -or $Type -eq 'all') {
            New-SymlinkForTarget -root $repoFull -targetRelativePath $targetsCommands[$ide] -canonicalDir $canonicalCommands -copyExisting $CopyExisting.IsPresent
        }
        if ($Type -eq 'skills' -or $Type -eq 'all') {
            New-SymlinkForTarget -root $repoFull -targetRelativePath $targetsSkills[$ide] -canonicalDir $canonicalSkills -copyExisting $CopyExisting.IsPresent
        }
    } catch {
        Write-Host $_.Exception.Message
        $exitCode = 2
        break
    }
}
exit $exitCode
