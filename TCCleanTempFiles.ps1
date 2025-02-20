<#
    .SYNOPSIS
    清理系統與使用者 TEMP 資料夾，包含權限處理功能。

    .DESCRIPTION
    此腳本用於清理 TEMP 資料夾，並在必要時取得檔案或資料夾的所有權。
    無日誌功能，注重穩定性與清晰的輸出。

    .AUTHOR
    Yukigami Zero

    .EXAMPLE
    .\CleanTemp.ps1
#>

# 檢查管理員權限
function Test-AdminPrivilege {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning "⚠ 需要管理員權限，請以系統管理員身份重新運行！"
        exit 1
    }
    Write-Output "✅ 已確認管理員身份"
}

# 取得檔案或資料夾的所有權
function Set-FolderOwnership {
    param ([Parameter(Mandatory)][string]$Path)
    try {
        takeown /F $Path /A /R /D Y | Out-Null
        icacls $Path /grant Administrators:F /T /C /Q | Out-Null
        Write-Output "✅ 已取得 $Path 的所有權"
        $true
    } catch {
        Write-Warning "❌ 無法變更 $Path 的權限: $($_.Exception.Message)"
        $false
    }
}

# 清理指定 TEMP 資料夾
function Clear-TempFolder {
    param (
        [Parameter(Mandatory)][string]$FolderPath,
        [Parameter(Mandatory)][string]$FolderName
    )

    if (-not (Test-Path $FolderPath)) {
        Write-Warning "⚠ $FolderName 資料夾不存在: $FolderPath"
        return
    }

    Write-Output "🔍 開始清理 $FolderName 資料夾: $FolderPath"

    try {
        $items = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction Stop
        $total = $items.Count
        if ($total -eq 0) {
            Write-Output "✅ $FolderName 資料夾已無內容"
            return
        }

        $counter = 0
        foreach ($item in $items) {
            $counter++
            $itemPath = $item.FullName
            Write-Output "處理中: $counter/$total - $itemPath"

            try {
                Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                Write-Output "✅ 已刪除: $itemPath"
            } catch {
                Write-Warning "❌ 無法刪除: $itemPath，嘗試取得權限..."
                if (-not (Set-FolderOwnership -Path $itemPath)) {
                    Write-Warning "⚠ 無法取得權限: $itemPath"
                    continue
                }
                Start-Sleep -Milliseconds 50
                Remove-Item -Path $itemPath -Force -Recurse -ErrorAction Stop
                Write-Output "✅ 最終成功刪除: $itemPath"
            }

            if ($counter % 10 -eq 0 -or $counter -eq $total) {
                Write-Progress -Activity "$FolderName 清理中" -Status "$counter/$total 項已處理" -PercentComplete (($counter / $total) * 100)
            }
        }

        Write-Output "✅ $FolderName 清理完成"
    } catch {
        Write-Warning "🔴 清理過程中發生錯誤: $($_.Exception.Message)"
    } finally {
        Write-Progress -Activity "$FolderName 清理完成" -Completed
    }
}

# 主程序
Test-AdminPrivilege

Write-Output "====================================="
Write-Output "🧹 TEMP 資料夾清理工具"
Write-Output "📌 作者: Yukigami Zero"
Write-Output "====================================="

Clear-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "使用者 TEMP"
Clear-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "系統 TEMP"

Write-Output "🎉 清理任務全部完成！"