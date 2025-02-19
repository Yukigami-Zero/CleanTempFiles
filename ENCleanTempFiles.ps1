# Clean TEMP folders, including system permission handling
# Simplified version - No logging, ensuring stability and clear output
# Author: Yukigami Zero

function Check-Admin {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $IsAdmin) {
        Write-Warning "⚠ This script requires administrator privileges to clean system TEMP folders."
        Write-Output "Please run this script as an administrator!"
        exit 1
    }
    Write-Output "✅ Running with administrator privileges confirmed."
}

function Take-Ownership {
    param ([string]$Path)
    try {
        $null = takeown /F $Path /A /R /D Y
        $null = icacls $Path /grant Administrators:F /T /C /Q
        Write-Output "✅ Ownership taken for: $Path"
        return $true
    } catch {
        Write-Warning "❌ Failed to change permissions for: $Path - $($_.Exception.Message)"
        return $false
    }
}

function Clean-TempFolder {
    param (
        [Parameter(Mandatory=$true)][string]$FolderPath,
        [Parameter(Mandatory=$true)][string]$FolderName
    )

    if (!(Test-Path $FolderPath)) {
        Write-Warning "$FolderName folder does not exist: $FolderPath"
        return
    }

    Write-Output "🔍 Starting cleanup: $FolderName - $FolderPath"

    try {
        $Items = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction Stop
        $TotalItems = $Items.Count
        $Counter = 0

        if ($TotalItems -eq 0) {
            Write-Output "✅ No cleanup needed for: $FolderName"
            return
        }

        foreach ($Item in $Items) {
            $Counter++
            Write-Output "Processing: $Counter / $TotalItems - $($Item.FullName)"

            try {
                if ($Item.PSIsContainer) {
                    if ((Get-ChildItem -Path $Item.FullName -Recurse -Force | Measure-Object).Count -eq 0) {
                        Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                        Write-Output "✅ Deleted empty folder: $($Item.FullName)"
                    }
                } else {
                    Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                    Write-Output "✅ Deleted file: $($Item.FullName)"
                }
            } catch {
                Write-Warning "❌ Unable to process: $($Item.FullName), attempting to take ownership..."
                if (!(Take-Ownership -Path $Item.FullName)) {
                    Write-Warning "⚠ Failed to gain ownership: $($Item.FullName)"
                    continue
                }
                Start-Sleep -Milliseconds 50
                try {
                    Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                    Write-Output "✅ Successfully deleted after ownership change: $($Item.FullName)"
                } catch {
                    Write-Warning "⚠ Final deletion attempt failed: $($Item.FullName)"
                }
            }

            if ($Counter % 10 -eq 0 -or $Counter -eq $TotalItems) {
                Write-Progress -PercentComplete (($Counter / $TotalItems) * 100) -Status "Cleaning in progress" -Activity "$Counter / $TotalItems processed"
            }
        }

        $EmptyDirs = Get-ChildItem -Path $FolderPath -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force | Measure-Object).Count -eq 0 }
        foreach ($Dir in $EmptyDirs | Sort-Object -Property FullName -Descending) {
            try {
                Remove-Item -Path $Dir.FullName -Force -ErrorAction Stop
                Write-Output "✅ Deleted empty folder: $($Dir.FullName)"
            } catch {
                Write-Warning "⚠ Unable to delete folder: $($Dir.FullName)"
            }
        }

        Write-Output "✅ Cleanup completed for: $FolderName"

    } catch {
        Write-Warning "🔴 Error occurred during cleanup: $($_.Exception.Message)"
    } finally {
        Write-Progress -Completed -Activity "Cleanup completed"
    }
}

Check-Admin

Write-Output "====================================="
Write-Output "🧹 Cleaning system and user TEMP folders"
Write-Output "📌 Author: Yukigami Zero"
Write-Output "====================================="

Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "🎉 All cleanup tasks completed."
