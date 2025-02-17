# Clean TEMP folders, including system permission handling
# Improved Version - Ensures all possible files and empty folders are deleted
# Author: Yukigami Zero

function Check-Admin {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $IsAdmin) {
        Write-Warning "⚠ This script requires administrator privileges to clean system TEMP folders."
        Write-Output "Please run this script as an administrator!"
        exit 1
    }
}

function Take-Ownership {
    param ([string]$Path)
    try {
        takeown /F $Path /A /R /D Y | Out-Null
        icacls $Path /grant Administrators:F /T /C /Q | Out-Null
    } catch {
        Write-Warning "❌ Unable to change permissions: $($_.Exception.Message)"
    }
}

function Clean-TempFolder {
    param (
        [string]$FolderPath,
        [string]$FolderName
    )

    if (!(Test-Path $FolderPath)) {
        Write-Warning "$FolderName folder does not exist: $FolderPath"
        return
    }

    Write-Output "🔍 Starting cleanup of $FolderName folder: $FolderPath"

    # Delete all files first
    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -File -ErrorAction SilentlyContinue
    $FileCount = $Files.Count

    if ($FileCount -eq 0) {
        Write-Output "✅ No cleanup needed for $FolderName folder"
    } else {
        $Counter = 0
        foreach ($File in $Files) {
            try {
                Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            } catch {
                Write-Warning "❌ Unable to delete: $($File.FullName), attempting to take ownership..."
                Take-Ownership -Path $File.FullName
                Start-Sleep -Milliseconds 500
                try {
                    Remove-Item -Path $File.FullName -Force -ErrorAction Stop
                } catch {
                    Write-Warning "⚠ Still unable to delete: $($File.FullName)"
                }
            }
            $Counter++
            if ($Counter % 50 -eq 0 -or $Counter -eq $FileCount) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "Cleaning..." -Activity "$Counter / $FileCount files cleaned"
            }
        }
    }

    # Remove all empty directories
    $Dirs = Get-ChildItem -Path $FolderPath -Recurse -Force -Directory -ErrorAction SilentlyContinue
    $Dirs | Sort-Object -Property FullName -Descending | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            Write-Warning "⚠ Unable to delete folder: $($_.FullName)"
        }
    }

    Write-Output "✅ Cleanup completed for: $FolderName folder"
}

# Ensure script runs as administrator
Check-Admin

# Display author information
Write-Output "====================================="
Write-Output "🧹 Cleaning system and user TEMP folders"
Write-Output "📌 Author: Yukigami Zero"
Write-Output "====================================="

# Execute cleanup
Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "🎉 All cleanups are complete."
