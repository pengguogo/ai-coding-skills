# Step 1: 环境检查 + 配置预解析

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`~/.ai-coding-skills-config`（若存在）]
- output_file: `(console)`
- reference_sections: [`references/sync-layout.md#环境与行为说明`]
- domain_context: 技能同步的环境前置检查与配置预解析

## 执行指令

### 环境检查（fail-fast）
1. 检查 bash 是否可用，按以下顺序检测：
   a. `which bash` 或 `bash --version`（Linux/macOS/WSL/Git Bash 终端）
   b. 若不可用（Windows PowerShell 环境），检查 Git 安装目录下的 bash：
      - `"C:\Program Files\Git\bin\bash.exe" --version`
      - `"C:\Program Files (x86)\Git\bin\bash.exe" --version`
      - 通过 git 路径推导：`(Get-Command git).Source` → 替换 `cmd\git.exe` 为 `bin\bash.exe`
   c. 找到可用的 bash 后，记录完整路径为 `BASH_PATH`，后续步骤统一使用此路径调用脚本
   - 全部不可用 → STATUS_REPORT: BLOCKED，提示安装 Git Bash（Windows）或检查 PATH
2. 检查 git 是否可用：`git --version`
   - 不可用 → STATUS_REPORT: BLOCKED，提示安装 git

### 配置预解析
4. 检查命令行参数（--tool / --scope / --repo / --branch）
   - `--tool` 允许值：`cursor | kiro | claude | opencode | trae`（可传多个，空格分隔）
5. 检查 ~/.ai-coding-skills-config 是否存在已保存的 SAVED_REPO_URL / SAVED_BRANCH
6. 汇总已确定的参数：

   | 参数 | 值 | 来源 |
   |------|-----|------|
   | 仓库 URL | ... | 命令行 / 配置文件 / 待确认 |
   | 分支 | ... | 命令行 / 配置文件 / 默认 main |
   | 目标工具 | ... | 命令行 / 待确认 |
   | 范围 | ... | 命令行 / 待确认 |

7. 判断执行模式：
   - 所有参数已确定 → Step 2 使用非交互模式
   - 有参数待确认 → Step 2 使用脚本交互模式（由脚本向用户确认）
8. 若范围为 project，确认当前 pwd 为项目根目录
9. 产出末尾附加 STATUS_REPORT
