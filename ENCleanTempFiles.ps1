# Clean system and user TEMP folders
# Author: Yukigami Zero

# Function to clean a TEMP folder
function Clean-TempFolder {
    param (
        [string]$FolderPath,
        [string]$FolderName
    )
    Write-Output "Cleaning $FolderName folder: $FolderPath"

    $Files = Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue
    $FileCount = $Files.Count
    $Counter = 0

    $Files | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            $Counter++
            if ($Counter % 10 -eq 0) {
                Write-Progress -PercentComplete (($Counter / $FileCount) * 100) -Status "Cleaning in progress" -Activity "$Counter / $FileCount files cleaned"
            }
        } catch {
            # Ignore files that fail to delete
        }
    }
    Write-Output "Cleaning completed: $FolderName folder"
}

# Display author information
Write-Output "====================================="
Write-Output "Clean system and user TEMP folders"
Write-Output "Author: Yukigami Zero"
Write-Output "====================================="

# Execute cleaning
Clean-TempFolder -FolderPath ([System.IO.Path]::GetTempPath()) -FolderName "User TEMP"
Clean-TempFolder -FolderPath "C:\Windows\Temp" -FolderName "System TEMP"

Write-Output "All cleaning tasks are completed."
