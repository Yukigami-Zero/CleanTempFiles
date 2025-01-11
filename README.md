# CleanTempFolder

A PowerShell script to clean system and user TEMP folders, ensuring optimal system performance by removing unnecessary temporary files.

## Features
- Cleans both user and system TEMP directories.
- Displays progress during cleaning.
- Ignores files that cannot be deleted.

## Usage
1. Download the script file:
   - English version: `ENCleanTempFiles.ps1`
   - Traditional Chinese version: `TCCleanTempFiles.ps1`

2. Open PowerShell as an administrator.

### Option 1: Manual Execution via Path
1. Navigate to the directory containing the script.
2. Run the following command:
   ```
   .\ENCleanTempFiles.ps1
   ```

### Option 2: Execute Directly with Full Path
1. Use the following command:
   ```
   powershell.exe -File "<full path to the script>\ENCleanTempFiles.ps1"
   ```

## Setting Up Automatic Cleanup
To enable automatic cleanup at system startup, follow these steps:

### Option 1: Task Scheduler
1. Open Task Scheduler on your Windows system.
2. Create a new task.
3. In the **General** tab, provide a name like "CleanTempOnStartup" and select "Run with highest privileges."
4. In the **Triggers** tab, add a new trigger set to "At startup."
5. In the **Actions** tab, add a new action:
   - Action: Start a Program
   - Program/script: `powershell.exe`
   - Add arguments: `-File "<full path>\ENCleanTempFiles.ps1"` or `-File "<full path>\TCCleanTempFiles.ps1"`
6. Save and enable the task.

### Option 2: Startup Folder
1. Press `Win + R`, type `shell:startup`, and press Enter.
2. Create a shortcut to PowerShell in the startup folder.
3. Edit the shortcut properties to include:
   ```
   powershell.exe -File "<full path>\ENCleanTempFiles.ps1"
   ```
   or
   ```
   powershell.exe -File "<full path>\TCCleanTempFiles.ps1"
   ```

## README Language Switch
- [繁體中文說明](README_TC.md)

## Author
**Yukigami Zero**

GitHub Profile: [Yukigami-Zero](https://github.com/Yukigami-Zero)

---

"CleanTempFolder" is an open-source project. Contributions are welcome!

