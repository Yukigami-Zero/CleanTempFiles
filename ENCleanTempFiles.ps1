<#
    .SYNOPSIS
    Cleans system and user TEMP folders, including ownership handling.

    .DESCRIPTION
    This script cleans TEMP folders and takes ownership of files or folders if needed.
    No logging functionality, focusing on stability and clear output.

    .AUTHOR
    Yukigami Zero

    .EXAMPLE
    .\CleanTemp.ps1
#>

# Check for administrative privileges
function Test-AdminPrivilege {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning "⚠ Administrative privileges required. Please run as Administrator!"
        exit 1
    }
    Write-Output "✅ Confirmed running with admin privileges"
}

# Take ownership of a file or folder
function Set-FolderOwnership {
    param ([Parameter(Mandatory)][string]$Path)
    try {
        takeown /F $Path /A /R /D Y | Out-Null
        icacls $Path /grant Administrators:F /T /C /Q | Out-Null
        Write-Output "✅ Ownership taken for $Path"
        $true
    } catch {
        Write-Warning "❌ Failed to change permissions for $Path - $($_.Exception.Message)"
        $false
    }
}

# Clean a specified TEMP folder
function Clear-TempFolder {
    param (
        [Parameter(Mandatory)][string]$FolderPath,
        [Parameter(Mandatory)][string]$FolderName
    )

    if (-not (Test-Path $FolderPath)) {
        Write-Warning "⚠ $FolderName folder does not exist: $FolderPath"
        return
    }

    Write-Output "🔍 Starting cleanup of $FolderName folder: $FolderPath"

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
                Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                Write-Output "✅ Deleted: $itemPath"
            } catch {
                Write-Warning "❌ Failed to delete: $itemPath, attempting to take ownership..."
                if (-not (Set-FolderOwnership -Path $itemPath)) {
                    Write-Warning "⚠ Unable to take ownership: $itemPath"
                    continue
                }
                Start-Sleep -Milliseconds 50
                Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                Write-Output "✅ Successfully deleted: $itemPath"
            }

            if ($counter % 10 -eq 0 -or $counter -eq $total) {
                Write-Progress -Activity "Cleaning $FolderName" -Status "$counter/$total items processed" -PercentComplete (($counter / $total) * 100)
            }
        }

        Write-Output "✅ Cleanup completed for $FolderName folder"
    } catch {
        Write-Warning "🔴 Error occurred during cleanup - $($_.Exception.Message)"
    } finally {
        Write-Progress -Activity "Cleanup of $FolderName completed" -Completed
    }
}

# Main execution
Test-AdminPrivilege

Write-Output "====================================="
Write-Output "🧹 TEMP Folder Cleanup Tool"
Write-Output "📌 Author: Yukigami Zero"
Write-Output "====================================="

Clear-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clear-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "🎉 All cleanup tasks completed!"