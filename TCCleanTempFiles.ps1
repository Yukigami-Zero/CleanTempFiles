# 清理 TEMP 資料夾，包含系統權限處理
# 改進版 - 確保刪除所有可能的檔案與空資料夾
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

    # 先刪除所有檔案
    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -File -ErrorAction SilentlyContinue
    $FileCount = $Files.Count

    if ($FileCount -eq 0) {
        Write-Output "✅ $FolderName 資料夾無需清理"
    } else {
        $Counter = 0
        foreach ($File in $Files) {
            try {
                Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            } catch {
                Write-Warning "❌ 無法刪除: $($File.FullName)，嘗試取得權限..."
                Take-Ownership -Path $File.FullName
                Start-Sleep -Milliseconds 500
                try {
                    Remove-Item -Path $File.FullName -Force -ErrorAction Stop
                } catch {
                    Write-Warning "⚠ 無法刪除: $($File.FullName)"
                }
            }
            $Counter++
            if ($Counter % 50 -eq 0 -or $Counter -eq $FileCount) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "清理中" -Activity "$Counter / $FileCount 文件已清理"
            }
        }
    }

    # 刪除所有空的目錄
    $Dirs = Get-ChildItem -Path $FolderPath -Recurse -Force -Directory -ErrorAction SilentlyContinue
    $Dirs | Sort-Object -Property FullName -Descending | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            Write-Warning "⚠ 無法刪除資料夾: $($_.FullName)"
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
