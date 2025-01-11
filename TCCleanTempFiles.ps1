# 清理系統和使用者 TEMP 資料夾
# 作者: Yukigami Zero

# 清理使用者 TEMP 資料夾
function Clean-TempFolder {
    param (
        [string]$FolderPath,
        [string]$FolderName
    )
    Write-Output "正在清理 $FolderName 資料夾： $FolderPath"

    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue
    $FileCount = $Files.Count
    $Counter = 0

    $Files | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            $Counter++
            if ($Counter % 10 -eq 0) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "清理中" -Activity "$Counter / $FileCount 文件已清理"
            }
        } catch {
            # 忽略刪除失敗的文件
        }
    }
    Write-Output "清理完成：$FolderName 資料夾"
}

# 顯示製作者資訊
Write-Output "====================================="
Write-Output "清理系統和使用者 TEMP 資料夾"
Write-Output "作者: Yukigami Zero"
Write-Output "====================================="

# 執行清理
Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "使用者 TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "系統 TEMP"

Write-Output "所有清理已完成。"
