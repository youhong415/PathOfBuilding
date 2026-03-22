# Path of Building Community
## Welcome to Path of Building, an offline build planner for Path of Exile!

---

## 🤖 AI Summary Extractor (AI 摘要萃取工具)

本專案內含強大的 AI 摘要萃取腳本 (`AI_Scripts/SummaryGenerator.lua`)，專門用來將 Path of Building 中匯出的角色 XML 檔轉換成人類與 AI 都能輕鬆閱讀的純文字格式。有了這份文字檔，您就能完美對接諸如 Gemini 的大型語言模型，進行深度的流派健檢與優化！

### 如何安裝執行環境 (Windows 必備)
由於我們的萃取工具直接調用了 PoB 內部的無頭運算引擎 (Headless Mode)，因此**必須依賴 LuaJIT** 才能順利執行。您可以利用微軟推薦的 `scoop` 工具來一鍵安裝。

請開啟您的 PowerShell 終端機並依序執行以下指令：
```powershell
# 1. 允許執行外部腳本
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. 安裝 Scoop (若您的電腦尚未安裝過)
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 3. 透過 Scoop 一鍵安裝 LuaJIT
scoop install luajit
```

### 如何產出角色文字摘要
當 `luajit` 安裝完畢後，請將您的角色 XML 設定檔放入 `Builds\` 資料夾中，並依照以下步驟執行：

1. 開啟一個**全新**的終端機視窗 (PowerShell / cmd 皆可)，確保新的 `luajit` 變數已生效。
2. 執行以下兩行指令：
```powershell
# 第一步：一定要將路徑切換至 src/ 資料夾內，如此一來腳本才能正確吃到 PoB 的所有核心依賴
cd src

# 第二步：使用 luajit 執行萃取腳本，後方空一格加上您的流派檔案名稱 (不需要加 .xml 後綴)
~\scoop\shims\luajit.exe ..\AI_Scripts\SummaryGenerator.lua AMa_PoisonSRS
```
執行成功後，您的文字摘要就會自動產出並存放在 `Builds/AMa_PoisonSRS_Summary.txt`！

---

<p float="middle">
  <img alt="Tree tab" src="https://github.com/user-attachments/assets/0826b7ab-84ba-440f-be52-2f216f13e75c" width="48%" />
  <img alt="Items tab" src="https://github.com/user-attachments/assets/e5af1326-7e22-43d8-ab12-aa5500da611a" width="48%" />
</p>

### Features
* Comprehensive offence + defence calculations:
  * Calculate your skill DPS, damage over time, life/mana/ES totals and much more!
  * Can factor in auras, buffs, charges, curses, monster resistances and more, to estimate your effective DPS
  * Also calculates life/mana reservations
  * Shows a summary of character stats in the side bar, as well as a detailed calculations breakdown tab which can show you how the stats were derived
  * Supports all skills and support gems, and most passives and item modifiers
    * Throughout the program, supported modifiers will show in blue and unsupported ones in red
  * Full support for minions
  * Support for party play and support builds
* Passive skill tree planner:
  * Support for jewels including most radius/conversion and timeless jewels
  * Features alternate path tracing (mouse over a sequence of nodes while holding shift, then click to allocate them all)
  * Fully integrated with the offence/defence calculations; see exactly how each node will affect your character!
  * Can import PathOfExile.com and PoEPlanner.com passive tree links; links shortened with PoEURL.com also work
* Skill planner:
  * Add any number of main or supporting skills to your build
  * Supporting skills (auras, curses, buffs) can be toggled on and off
  * Automatically applies Socketed Gem modifiers from the item a skill is socketed into
  * Automatically applies support gems granted by items
* Item planner:
  * Add items from in game by copying and pasting them straight into the program!
  * Automatically adds quality to non-corrupted items
  * Search the trade site for the most impactful items
  * Fully integrated with the offence/defence calculations; see exactly how much of an upgrade a given item is!
  * Contains a searchable database of all uniques that are currently in game (and some that aren't yet!)
    * You can choose the modifier rolls when you add a unique to your build
    * Includes all league-specific items and legacy variants
  * Features an item crafting system:
    * You can select from any of the game's base item types
    * You can select prefix/suffix modifiers from lists
    * Custom modifiers can be added, with Master and Essence modifiers available
  * Also contains a database of rare item templates:
    * Allows you to create rare items for your build to approximate the gear you will be using
    * Choose which modifiers appear on each item, and the rolls for each modifier, to suit your needs
    * Has templates that should cover the majority of builds
* Other features:
  * You can import passive tree, items, and skills from existing characters
  * Share builds with other users by generating a share code
  * Automatic updating; most updates will only take a couple of seconds to apply

## Download
Head over to the [Releases](https://github.com/PathOfBuildingCommunity/PathOfBuilding/releases) page to download the install wizard or portable zip.

## Changelog
You can find the full version history [here](CHANGELOG.md).

## Contribute
You can find instructions on how to contribute code and bug reports [here](CONTRIBUTING.md).

## Licence
[MIT](https://opensource.org/licenses/MIT)

For 3rd-party licences, see [LICENSE](LICENSE.md).
The licencing information is considered to be part of the documentation.
