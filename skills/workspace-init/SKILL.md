---
name: workspace-init
description: 开发空间初始化：读取工作区根目录 repos.txt（TSV：name/type/url/branch），在根目录按 name 自动 clone/更新并切换分支；初始化结束后必须校验各仓库是否就绪，异常时尝试安全修复，无法修复则输出可执行的手动清单。触发词：空间初始化、工作区初始化、初始化环境、一键拉代码、按清单 clone、切换分支、准备开发环境、检查 clone 结果。
---

# Workspace Init（空间初始化）

## 目标

- 从工作区根目录的 \`repos.txt\` 批量 clone 多个仓库到**工作区根目录**（目录名使用 \`name\`），并切换到每行指定的 \`branch\`。
- **初始化完成后**，必须执行**结果校验**：确认每个条目对应的目录存在、为有效 git 仓库、远端与分支符合清单；异常时在安全边界内**自动修复**，修复失败则给出**手动执行清单**。

## 强制约束（必须遵守）

- **自动化 clone 与切换**：按 \`repos.txt\` 逐行执行 clone/更新、\`fetch\`、切分支、\`pull --ff-only\`，无需人工逐步操作。
- **不产出任何其他文件**：除 git 在根目录创建的各 \`<name>\` 仓库目录外，**不得**落盘 \`workspace-init-summary.txt\`、哨兵/标记文件、日志文件或任何辅助脚本；过程、校验与修复结果**仅在控制台输出**。
- **不依赖任何脚本文件**：空间初始化直接使用 git 命令完成 clone / 更新 / 切分支 / 校验。
- **只在工作区根目录**按 \`repos.txt\` 执行；clone 目录固定为 \`.\\<name>\`。
- **不做破坏性操作**：不执行 \`reset --hard\`、不删除目录、不覆盖非 git 目录。

## 清单文件约定（repos.txt）

- **位置**：工作区根目录
- **文件名**：\`repos.txt\`
- **模板/示例**：可参考 \`e2e/workspace/workspace-init/references/repos-template.md\` / \`e2e/workspace/workspace-init/references/repos.txt\`，实际运行时需将内容复制到工作区根目录并命名为 \`repos.txt\`
- **格式**：TSV（Tab 分隔）优先；也允许用多个空格分隔。

### 行格式

\`name<TAB>type<TAB>url<TAB>branch[<TAB>eta_min]\`

- **name**：项目英文名称（也是 clone 目录名），如 \`aiclaim-api\`
- **type**：\`app\` 或 \`kb\`（应用/知识库）
- **url**：git http clone 地址（如 \`https://.../.git\`）
- **branch**：要切换的分支（可为空；为空时走默认分支策略）
- **eta_min（可选）**：预计拉取/更新耗时（分钟）。用于在初始化时放宽网络等待阈值，避免大仓库因耗时较长被误判“卡住”。

### 允许内容

- 空行
- 以 \`#\` 开头的注释行

### 示例（repos.txt）

\`\`\`text
# name<TAB>type<TAB>url<TAB>branch<TAB>eta_min
aiclaim-api	app	https://github.com/ORG/aiclaim-api.git	develop
aiclaim-kb	kb	https://github.com/ORG/aiclaim-kb.git	main	5
\`\`\`

## 默认分支策略

- 若 \`branch\` 为空：先尝试 \`main\`，不存在再尝试 \`master\`；仍不存在则报错并列出远端分支。

## 执行方式（按 repos.txt 直接 clone/更新）

在**工作区根目录**执行初始化逻辑：

### 解析规则

- 跳过空行与 \`#\` 注释行
- 按 Tab 分隔优先；若无 Tab，则按空白分隔
- 列：\`name type url branch [eta_min]\`

### 对每一行的处理逻辑（幂等）

- **目录不存在**：\`git clone <url> <name>\`
- **目录存在且是 git 仓库**：
  - \`git -C <name> remote set-url origin <url>\`（避免仓库 url 变更导致拉取失败）
  - \`git -C <name> fetch --prune origin\`
- **切换分支**：
  - 若 \`branch\` 非空：优先 \`git -C <name> checkout <branch>\`；若本地无该分支，尝试 \`git -C <name> checkout -b <branch> origin/<branch>\`
  - 若 \`branch\` 为空：按默认分支策略尝试 \`main\` / \`master\`（必要时从 \`origin/<branch>\` 创建）
- **更新工作区内容**：
  - 分支切换成功后：\`git -C <name> pull --ff-only\`

### 结果产物

- **仅**各仓库目录 \`.\\<name>\`（由 \`git clone\` 或既有仓库更新得到）；**不**生成 summary、日志或其它任何额外文件；过程与结果仅在控制台输出。

---

## 初始化后校验（必须执行）

在**全部行**按上文完成 clone/更新后，**必须**再按 \`repos.txt\` 逐条校验；若某条失败，先尝试「自动修复」，仍失败则记入「手动清单」。

### 单条校验项（对每一有效数据行）


| 序号  | 检查项         | 通过条件                                                                                                       |
| --- | ----------- | ---------------------------------------------------------------------------------------------------------- |
| 1   | 目录存在        | \`.\\<name>\` 存在且为目录                                                                                          |
| 2   | 是 git 仓库    | \`git -C <name> rev-parse --is-inside-work-tree\` 为 \`true\`                                                   |
| 3   | 远端 URL      | \`git -C <name> remote get-url origin\` 与清单 \`url\` 一致（规范化比较：末尾 \`.git\` 可有可无时以实际可连为准；若不一致但可 \`set-url\` 修正则进入修复）  |
| 4   | 当前分支        | \`git -C <name> rev-parse --abbrev-ref HEAD\` 等于期望分支（\`branch\` 非空时等于该行 \`branch\`；为空时等于解析得到的 \`main\` 或 \`master\`） |
| 5   | 与远端同步（快进可行） | \`git -C <name> status\` 无致命错误；\`git -C <name> pull --ff-only\` 成功或已 up-to-date（若本地有非快进需合并，记为「需人工」不自动 merge）   |


**控制台输出要求**：按仓库汇总「通过 / 已修复 / 失败」，失败项附简要原因（如：目录非 git、鉴权失败、分支不存在、需 merge 等）。

### 自动修复（安全范围内，按顺序尝试）

对**未通过**的条目，在不违反「安全边界」的前提下依次尝试：

1. **目录不存在或 clone 明显不完整**（如无 \`.git\`）：重新执行该行「对每一行的处理逻辑」（等价于再次 \`clone\` 或补全 fetch/checkout/pull）。
2. **origin URL 不一致**：\`git -C <name> remote set-url origin <url>\`，然后 \`fetch --prune origin\`，再按原逻辑切分支并 \`pull --ff-only\`。
3. **本地不在目标分支**：按「切换分支」与「更新工作区」小节重试一次。
4. \`**pull --ff-only\` 因需 merge 失败**：**不**自动 merge；标记为需人工，并在手动清单中写明建议（见下）。

**仍不通过**或**无法在不删除目录的前提下修复**（例如：\`name\` 路径存在但不是 git 仓库、鉴权 401/403、分支在远端不存在）：**不得**为“省事”而 \`reset --hard\` 或删目录；将该项列入「手动执行清单」。

### 无法自动修复时：手动执行清单（交给用户）

在控制台输出结构化清单，每条失败占一块，便于复制执行。**示例格式**（按实际失败原因删减行）：

\`\`\`text
=== 需手动处理：<name> ===
原因：<一句话>
建议步骤：
1. 在工作区根目录检查网络/VPN/ Git 凭据（若曾出现 HTTP 401/403）。
2. 若目录存在但非 git 仓库：备份该目录内重要文件后，删除文件夹 <name>，再执行：git clone <url> <name>
3. 进入仓库后切换分支：git -C <name> checkout <branch>  （若需跟踪远端：git -C <name> checkout -b <branch> origin/<branch>）
4. 若提示需 merge 才能完成 pull：在 <name> 内与负责人确认后执行 merge/rebase（本技能不自动执行）。
5. 完成后可单独对该仓库执行：git -C <name> fetch && git -C <name> pull --ff-only
\`\`\`

**清单必备元素**：\`name\`、\`url\`、\`branch\`（或默认分支说明）、失败原因、**可复制的 git 命令**（单行优先）。

---

## 安全边界

- 不删除目录、不覆盖非 git 目录。
- 不执行破坏性 git 操作（如 \`reset --hard\`）。
- 遇到鉴权失败仅提示用户处理凭据（不自动写入 token）。
- 校验阶段同样遵守：不新增磁盘上的总结文件，所有结论仅在对话/控制台中呈现。