# 清理 TEMP 資料夾，包含系統權限處理
# 作者: Yukigami Zero

function Check-Admin {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $IsAdmin) {
        Write-Warning "⚠ 此腳本需要管理員權限來清理系統 TEMP 資料夾"
        Write-Output "請以系統管理員身份重新運行此腳本！"
        exit 1
    }
}

function Take-Ownership {
    param ([string]$Path)
    try {
        # 取得所有權，避免權限問題
        takeown /F $Path /A /R /D Y | Out-Null
        icacls $Path /grant Administrators:F /T /C /Q | Out-Null
    } catch {
        Write-Warning "❌ 無法變更權限: $($_.Exception.Message)"
    }
}

function Clean-TempFolder {
    param (
        [string]$FolderPath,
        [string]$FolderName
    )

    if (!(Test-Path $FolderPath)) {
        Write-Warning "$FolderName 資料夾不存在：$FolderPath"
        return
    }

    Write-Output "🔍 開始清理 $FolderName 資料夾: $FolderPath"

    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -File -ErrorAction SilentlyContinue
    $FileCount = $Files.Count

    if ($FileCount -eq 0) {
        Write-Output "✅ $FolderName 資料夾無需清理"
        return
    }

    $Counter = 0
    foreach ($File in $Files) {
        try {
            Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            $Counter++
            if ($Counter % 50 -eq 0 -or $Counter -eq $FileCount) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "清理中" -Activity "$Counter / $FileCount 文件已清理"
            }
        } catch {
            Write-Warning "❌ 無法刪除: $($_.Exception.Message)"
            Take-Ownership -Path $File.FullName
        }
    }

    Write-Output "✅ 清理完成: $FolderName 資料夾"
}

# 確保腳本以管理員身份運行
Check-Admin

# 顯示製作者資訊
Write-Output "====================================="
Write-Output "🧹 清理系統和使用者 TEMP 資料夾"
Write-Output "📌 作者: Yukigami Zero"
Write-Output "====================================="

# 執行清理
Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "使用者 TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "系統 TEMP"

Write-Output "🎉 所有清理已完成。"
