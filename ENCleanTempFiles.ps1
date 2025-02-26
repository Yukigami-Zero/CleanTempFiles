<#
    .SYNOPSIS
    Cleans system and user TEMP folders, including permission handling.

    .DESCRIPTION
    This script cleans TEMP folders and takes ownership of files or folders if necessary.
    No logging functionality, focuses on stability and clear output.

    .AUTHOR
    Yukigami Zero

    .EXAMPLE
    .\CleanTemp.ps1
#>

# Check for admin privileges
function Test-AdminPrivilege {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning "⚠ Admin privileges required, please run as Administrator!"
        exit 1
    }
    Write-Output "✅ Admin privileges confirmed"
}

# Take ownership of a file or folder
function Set-FolderOwnership {
    param ([Parameter(Mandatory)][string]$Path)
    try {
        if (-not (Test-Path $Path)) {
            Write-Warning "⚠ Path does not exist: $Path"
            return $false
        }
        takeown /F $Path /A /R /D Y | Out-Null
        icacls $Path /grant Administrators:F /T /C /Q | Out-Null
        Write-Output "✅ Ownership of $Path taken"
        $true
    } catch {
        Write-Warning "❌ Unable to change permissions for $Path : $($_.Exception.Message)"
        $false
    }
}

# Clean the specified TEMP folder
function Clear-TempFolder {
    param (
        [Parameter(Mandatory)][string]$FolderPath,
        [Parameter(Mandatory)][string]$FolderName
    )

    if (-not (Test-Path $FolderPath)) {
        Write-Warning "⚠ $FolderName folder does not exist: $FolderPath"
        return
    }

    Write-Output "🔍 Starting to clean $FolderName folder: $FolderPath"

    try {
        $items = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction Stop
        $total = $items.Count
        if ($total -eq 0) {
            Write-Output "✅ $FolderName folder is already empty"
            return
        }

        $counter = 0
        foreach ($item in $items) {
            $counter++
            $itemPath = $item.FullName
            Write-Output "Processing: $counter/$total - $itemPath"

            try {
                if ($item.PSIsContainer) {
                    Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                } else {
                    Remove-Item -Path $itemPath -Force -ErrorAction Stop
                }
                Write-Output "✅ Deleted: $itemPath"
            } catch {
                Write-Warning "❌ Unable to delete: $itemPath, attempting to take ownership..."
                if (-not (Set-FolderOwnership -Path $itemPath)) {
                    Write-Warning "⚠ Unable to take ownership: $itemPath"
                    continue
                }
                Start-Sleep -Milliseconds 50
                try {
                    if ($item.PSIsContainer) {
                        Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                    } else {
                        Remove-Item -Path $itemPath -Force -ErrorAction Stop
                    }
                    Write-Output "✅ Successfully deleted after taking ownership: $itemPath"
                } catch {
                    Write-Warning "❌ Still unable to delete: $itemPath - $($_.Exception.Message)"
                }
            }

            if ($counter % 10 -eq 0 -or $counter -eq $total) {
                Write-Progress -Activity "Cleaning $FolderName" -Status "$counter/$total items processed" -PercentComplete (($counter / $total) * 100)
            }
        }

        Write-Output "✅ $FolderName cleaning completed"
    } catch {
        Write-Warning "🔴 Error occurred during cleaning: $($_.Exception.Message)"
    } finally {
        Write-Progress -Activity "$FolderName cleaning completed" -Completed
    }
}

# Main program
Test-AdminPrivilege

Write-Output "====================================="
Write-Output "🧹 TEMP Folder Cleaning Tool"
Write-Output "📌 Author: Yukigami Zero"
Write-Output "====================================="

Clear-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clear-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "🎉 All cleaning tasks completed!"
