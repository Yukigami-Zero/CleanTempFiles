# CleanTempFolder

A PowerShell script to clean system and user TEMP folders, ensuring optimal system performance by removing unnecessary temporary files.

## Features
- Cleans both user and system TEMP directories.
- Displays progress during cleaning.
- Ignores files that cannot be deleted.

## Usage
1. Download the script file `CleanTempFolder.ps1`.
2. Open PowerShell as an administrator.
3. Navigate to the directory containing the script.
4. Run the script using the command:
   ```
   .\CleanTempFolder.ps1
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
   - Add arguments: `-File "<path to CleanTempFolder.ps1>"`
6. Save and enable the task.

### Option 2: Startup Folder
1. Press `Win + R`, type `shell:startup`, and press Enter.
2. Create a shortcut to PowerShell in the startup folder.
3. Edit the shortcut properties to include:
   ```
   powershell.exe -File "<path to CleanTempFolder.ps1>"
   ```

## README Language Switch
- [繁體中文說明](README_TC.md)

## Author
**Yukigami Zero**

GitHub Profile: [Yukigami-Zero](https://github.com/Yukigami-Zero)

---

"CleanTempFolder" is an open-source project. Contributions are welcome!

