# Clean TEMP folders (User & System)
# Author: Yukigami Zero

function Check-Admin {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $IsAdmin) {
        Write-Warning "⚠ This script requires administrator privileges to clean the system TEMP folder."
        Write-Output "Please restart this script as an Administrator!"
        exit 1
    }
}

function Take-Ownership {
    param ([string]$Path)
    try {
        # Take ownership to avoid permission issues
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

    Write-Output "🔍 Starting cleanup for $FolderName folder: $FolderPath"

    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -File -ErrorAction SilentlyContinue
    $FileCount = $Files.Count

    if ($FileCount -eq 0) {
        Write-Output "✅ No cleanup required for $FolderName folder."
        return
    }

    $Counter = 0
    foreach ($File in $Files) {
        try {
            Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            $Counter++
            if ($Counter % 50 -eq 0 -or $Counter -eq $FileCount) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "Cleaning in progress" -Activity "$Counter / $FileCount files cleaned"
            }
        } catch {
            Write-Warning "❌ Unable to delete: $($_.Exception.Message)"
            Take-Ownership -Path $File.FullName
        }
    }

    Write-Output "✅ Cleanup completed for: $FolderName folder."
}

# Ensure the script is running as Administrator
Check-Admin

# Display script information
Write-Output "====================================="
Write-Output "🧹 System & User TEMP Folder Cleanup"
Write-Output "📌 Author: Yukigami Zero"
Write-Output "====================================="

# Execute cleanup
Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "🎉 All cleanup tasks completed."
