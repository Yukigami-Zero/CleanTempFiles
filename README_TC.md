# 清理TEMP資料夾

這是一個PowerShell腳本，用於清理系統和使用者的TEMP資料夾，透過移除不必要的暫存檔案來提升系統效能。

## 功能特色
- 清理使用者和系統的TEMP目錄。
- 執行清理時顯示進度。
- 自動略過無法刪除的檔案。

## 使用方式
1. 下載腳本檔案：
   - 英文版本：`ENCleanTempFiles.ps1`
   - 繁體中文版本：`TCCleanTempFiles.ps1`

2. 以系統管理員身份開啟PowerShell。

### 方法一：透過路徑手動執行
1. 導覽到腳本所在的目錄。
2. 執行以下指令：
   ```
   .\TCCleanTempFiles.ps1
   ```

### 方法二：直接指定完整路徑執行
1. 使用以下指令：
   ```
   powershell.exe -File "<腳本完整路徑>\TCCleanTempFiles.ps1"
   ```

## 設定開機自動清理
若想讓系統在每次啟動時自動清理TEMP資料夾，可以按照以下步驟設定：

### 方法一：使用工作排程器
1. 開啟Windows的工作排程器。
2. 建立一個新工作。
3. 在 **一般** 分頁中，輸入名稱（例如："CleanTempOnStartup"），並選擇 "以最高權限執行"。
4. 在 **觸發條件** 分頁中，新增一個觸發條件，設定為 "在啟動時"。
5. 在 **動作** 分頁中，新增一個動作：
   - 動作：啟動程式
   - 程式/指令碼：`powershell.exe`
   - 新增引數：`-File "<完整路徑>\TCCleanTempFiles.ps1"` 或 `-File "<完整路徑>\ENCleanTempFiles.ps1"`
6. 儲存並啟用此工作。

### 方法二：使用啟動資料夾
1. 按下 `Win + R`，輸入 `shell:startup`，然後按下 Enter。
2. 在啟動資料夾中建立一個PowerShell的捷徑。
3. 編輯捷徑屬性，新增以下內容：
   ```
   powershell.exe -File "<完整路徑>\TCCleanTempFiles.ps1"
   ```
   或
   ```
   powershell.exe -File "<完整路徑>\ENCleanTempFiles.ps1"
   ```

## README 語言切換
- [English Version](README.md)

## 作者
**Yukigami Zero**

GitHub 頁面: [Yukigami-Zero](https://github.com/Yukigami-Zero)

---

"CleanTempFolder" 是一個開源專案，歡迎大家貢獻！

