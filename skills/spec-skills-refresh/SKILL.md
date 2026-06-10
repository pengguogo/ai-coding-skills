---
name: spec-skills-refresh
description: 从 git 拉取 ai-coding-skills 技能包（默认 GitHub 仓库、main 分支），并按所选工具与范围同步到全局或项目内的 AI 技能目录。
---

# 规范技能刷新（spec-skills-refresh）

## 标准母版结构（复用）

- 建议一级结构：文档职责边界 → 角色定位 → 何时使用 → 前置输入 → 执行流程 → 输出与交付物 → 规范引用（单一来源） → 执行红线。
- 本文件聚焦流程与边界；路径映射、来源目录、环境依赖等细则见 \`references/sync-layout.md\`。
- 新增说明时优先复用上述结构，避免在多处重复维护同一表格。

## 文档职责边界

- **本文件（\`SKILL.md\`）**：何时触发、要问用户什么、如何执行脚本、如何验收结果、红线。
- **\`references/sync-layout.md\`**：技能源目录、各工具目标路径、同步方式、环境/备份等细则。
- **\`script/spec-skills-refresh.sh\`**：实际克隆、复制、合并逻辑；与文档不一致时以脚本为准并回写 \`references/\`。

## 角色定位

- 在链路中的位置：**运维/初始化类工具技能**——把仓库中的标准技能分发到各 AI 工具的配置目录。
- **价值**：统一版本来源（git）、可选全局/项目范围、多工具一次同步。
- **不做**：不修改远程仓库；不替用户解决网络/权限/git 凭据问题（仅提示检查）。

## 何时使用

- 用户希望从远端更新本地技能：\`规范技能刷新\`、\`spec-skills-refresh\`、\`更新技能\`、\`同步最新技能\`、\`从 git 拉取技能\`。
- 英文触发：\`spec skills refresh\`、\`spec-skills-refresh\`、\`update skills\`、\`sync skills from git\`（旧称 \`refresh spec skills\` 仍可作为口语匹配）。
- 新机器或新克隆仓库后，需要把技能刷到 Cursor / Kiro / Claude Code / OpenCode / Trae。

## 前置输入

- **技能仓库 git URL**（默认 \`https://github.com/pengguogo/ai-coding-skills.git\`；交互时回车即用默认。若 \`~/.oc-skills-config\` 中已有 \`SAVED_REPO_URL\` 可复用）。
- **分支**（默认 \`main\`；可用 \`--branch\` 覆盖；可写入配置文件 \`SAVED_BRANCH\`）。
- **目标工具**（可多选）：Cursor、Kiro、Claude Code、OpenCode、Trae，或全部。
- **更新范围**：\`global\`（全局）或 \`project\`（当前仓库为项目根）。
- **环境**：可执行 Bash、\`git\` 可用；在仓库**根目录**执行脚本（项目范围时 \`pwd\` 须为该项目根）。

## 执行流程

### 步骤 1：确认配置

- **目标**：避免同步到错误目录或错误仓库。
- **动作**：若 URL/工具/范围未通过参数传入，按下列项向用户确认（可与脚本交互提问一致）：
  1. git 仓库地址（可直接回车使用脚本内默认 GitHub 地址）；
  2. 目标工具（对应编号 1–6，6 为全部）；
  3. 范围：全局 vs 当前项目。
- **检查点**：仓库 URL、分支策略、工具与范围明确后再执行脚本。

### 步骤 2：执行更新脚本

- **目标**：拉取远端指定分支并同步到所选路径。
- **动作**：在仓库根目录执行：

\`\`\`bash
# 交互模式（推荐；仓库地址回车即默认）
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh

# 非交互示例
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh \
  --tool "cursor kiro claude opencode trae" \
  --scope global \
  --repo https://github.com/pengguogo/ai-coding-skills.git \
  --branch main
\`\`\`

- **检查点**：脚本以 0 退出；日志中出现 \`技能更新完成\`；若有 \`ERROR\` 则停止并向用户说明原因（网络、分支名、权限等）。

### 步骤 3：同步结果说明

- **目标**：用户知道文件落点与如何验证。
- **动作**：根据脚本输出汇总：已同步的源目录、各工具 \`skills\` 路径、以及同级 \`backup-skills\` 下的快照路径（如有）。
- **检查点**：对照 \`references/sync-layout.md\` 中的路径表，确认与用户选择的范围一致。

## 输出与交付物

- **产出**：各工具技能目录下的更新文件。
- **备份**：与 \`<parent>/skills\` 同级的 \`<parent>/backup-skills/backup-<时间戳>/\`；每个 \`backup-skills\` 下超过 3 份时**删除最旧的**，只保留最新 3 份（详见 \`references/sync-layout.md\` 与脚本内 \`MAX_SKILL_BACKUPS\`）。
- **策略**：备份完成后，先删除本地 skills 中与远端同名的技能目录，再从远端全量复制，确保本地不残留远端已删除的文件；各工具均在 \`<skills>/<技能名>/\` 下平铺技能内容，**不保留**源路径中的父级目录；Claude / OpenCode 对缺失的 \`SKILL.md\` 生成占位。

## 规范引用（单一来源）

- 路径与来源目录：\`references/sync-layout.md\`
- 技能包母版结构（新建/维护其他 skill 时）：仓库内 \`skills/\` 下各技能的目录结构

## 执行红线

1. 不在未确认仓库 URL 与范围的情况下执行覆盖式同步。
2. 不在 \`SKILL.md\` 中重复维护路径大表；变更路径约定时只改 \`references/sync-layout.md\` 与脚本。
3. 不臆造用户未提供的仓库地址；默认以脚本内 \`DEFAULT_REPO_URL\` / \`DEFAULT_BRANCH\` 与 \`skills/spec-skills-refresh/script/spec-skills-refresh.sh\` 行为为准（仓库根目录执行）。
4. 对不确定的环境差异须在答复中明确标注，并指向 \`references/sync-layout.md\` 中的说明。