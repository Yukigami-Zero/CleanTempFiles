# 清理 TEMP 資料夾，包含系統權限處理
# 簡化版 - 無日誌功能，確保穩定性與清晰輸出
# 作者: Yukigami Zero

function Check-Admin {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $IsAdmin) {
        Write-Warning "⚠ 此腳本需要管理員權限來清理系統 TEMP 資料夾"
        Write-Output "請以系統管理員身份重新運行此腳本！"
        exit 1
    }
    Write-Output "✅ 已確認以管理員身份運行"
}

function Take-Ownership {
    param ([string]$Path)
    try {
        $null = takeown /F $Path /A /R /D Y
        $null = icacls $Path /grant Administrators:F /T /C /Q
        Write-Output "✅ 成功取得 $Path 的所有權"
        return $true
    } catch {
        Write-Warning "❌ 無法變更 $Path 的權限: $($_.Exception.Message)"
        return $false
    }
}

function Clean-TempFolder {
    param (
        [Parameter(Mandatory=$true)][string]$FolderPath,
        [Parameter(Mandatory=$true)][string]$FolderName
    )

    if (!(Test-Path $FolderPath)) {
        Write-Warning "$FolderName 資料夾不存在：$FolderPath"
        return
    }

    Write-Output "🔍 開始清理 $FolderName 資料夾: $FolderPath"

    try {
        # 獲取所有檔案與資料夾
        $Items = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction Stop
        $TotalItems = $Items.Count
        $Counter = 0

        if ($TotalItems -eq 0) {
            Write-Output "✅ $FolderName 資料夾無需清理"
            return
        }

        # 串行處理檔案
        foreach ($Item in $Items) {
            $Counter++
            Write-Output "處理中: $Counter / $TotalItems - $($Item.FullName)"

            try {
                if ($Item.PSIsContainer) {
                    # 處理空資料夾
                    if ((Get-ChildItem -Path $Item.FullName -Recurse -Force | Measure-Object).Count -eq 0) {
                        Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                        Write-Output "✅ 成功刪除空資料夾: $($Item.FullName)"
                    }
                } else {
                    # 處理檔案
                    Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                    Write-Output "✅ 成功刪除檔案: $($Item.FullName)"
                }
            } catch {
                Write-Warning "❌ 無法處理: $($Item.FullName)，嘗試取得權限..."
                if (!(Take-Ownership -Path $Item.FullName)) {
                    Write-Warning "⚠ 無法取得權限: $($Item.FullName)"
                    continue
                }
                Start-Sleep -Milliseconds 50  # 縮短等待時間
                try {
                    Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                    Write-Output "✅ 最終成功刪除: $($Item.FullName)"
                } catch {
                    Write-Warning "⚠ 最終無法刪除: $($Item.FullName)"
                }
            }

            # 更新進度
            if ($Counter % 10 -eq 0 -or $Counter -eq $TotalItems) {
                Write-Progress -PercentComplete (($Counter / $TotalItems) * 100) -Status "清理中" -Activity "$Counter / $TotalItems 項已處理"
            }
        }

        # 確保所有空資料夾都被移除（從最深層開始）
        $EmptyDirs = Get-ChildItem -Path $FolderPath -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force | Measure-Object).Count -eq 0 }
        foreach ($Dir in $EmptyDirs | Sort-Object -Property FullName -Descending) {
            try {
                Remove-Item -Path $Dir.FullName -Force -ErrorAction Stop
                Write-Output "✅ 成功刪除空資料夾: $($Dir.FullName)"
            } catch {
                Write-Warning "⚠ 無法刪除資料夾: $($Dir.FullName)"
            }
        }

        Write-Output "✅ 清理完成: $FolderName 資料夾"

    } catch {
        Write-Warning "🔴 清理過程中發生錯誤: $($_.Exception.Message)"
    } finally {
        Write-Progress -Completed -Activity "清理完成"
    }
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