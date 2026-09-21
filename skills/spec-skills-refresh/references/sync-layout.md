# 技能同步布局与路径（单一细则来源）

本文档为 `spec-skills-refresh` 的路径映射、来源目录与环境说明的**唯一维护处**；`SKILL.md` 仅引用本节，不重复粘贴大表。

## 仓库源目录结构（相对仓库根）

| 目录 | 说明 |
| --- | --- |
| `skills/` | 技能目录，每个一级子目录为一个独立技能 |

## 各工具目标路径与同步方式

同步时将仓库中的 `skills/` 目录映射到各 IDE 工具配置目录下。

### skills 同步

skills 目录下的每个**一级子目录**视为一个独立技能，同步到 `<目标>/skills/<技能名>/`。备份完成后，先**删除**本地 skills 中与远端同名的技能目录，再从远端全量复制，确保本地不残留远端已删除的文件。

| 工具 | 全局路径 | 项目路径 | 同步方式 |
| --- | --- | --- | --- |
| Cursor | `~/.cursor/skills/<技能名>/` | `.cursor/skills/<技能名>/` | 先删后写，技能平铺 |
| Kiro | `~/.kiro/skills/<技能名>/` | `.kiro/skills/<技能名>/` | 同上 |
| Trae | `~/.trae/skills/<技能名>/` | `.trae/skills/<技能名>/` | 同上 |
| Claude Code | `~/.claude/skills/<技能名>/` | `.claude/skills/<技能名>/` | 同上；缺 `SKILL.md` 时脚本生成占位 |
| OpenCode | `~/.config/opencode/skills/<技能名>/` | `.opencode/skills/<技能名>/` | 同上；缺 `SKILL.md` 时脚本生成占位 |

> **agents / commands 同步路径**：与 skills 同级，分别写入上表「全局路径 / 项目路径」的父目录下的 `agents/`、`commands/`（如 OpenCode 全局为 `~/.config/opencode/agents/`、项目级为 `.opencode/agents/`）。Scheduler 通过 `commands/scheduler-protocol.md` §10 三级回退解析这些路径；仅做 `--scope global` 同步时，Tier 3 全局目录即可供 Skill 编排使用。

## 备份目录

更新前若有内容需要备份，会先快照到同级的 `backup/<时间戳>/` 目录中（`时间戳` 为 `YYYYMMDD_HHMMSS`）。`backup` 与 `skills/` 同级存放。

**备份策略**：

- **仅备份"与远端同名"的子目录**：即本次同步会先删后写覆盖的技能；本地 DIY 创建、远端不存在的技能 **不进入备份**，且同步阶段也 **不会触碰** 它们（`sync_skills_flat` / `sync_skills_with_placeholder` 仅对与远端同名的子目录执行删除与覆盖）

> 这一策略的两层保障：
> 1. **DIY 技能不被破坏**：同步函数只动与远端同名的子目录，本地自定义技能在原位保留。
> 2. **DIY 技能不被冗余备份**：避免 `backup/<时间戳>/skills/` 被无关副本撑大；脚本仅快照"将被覆盖"的部分，备份与回滚意图严格对齐。

若本地 skills/ 中的所有子目录都是 DIY 技能（远端均无同名），则本次不会创建 `backup/<时间戳>/`（无可备份内容）；终端会输出"跳过备份本地 DIY 技能"的提示，便于审计。

**旧版目录兼容**：若同级仍存在历史命名 `backup-<时间戳>/`（单层目录名），每次备份前会先迁移为 `backup/<时间戳>/`（内容不变）。若 `backup/<时间戳>/` 已存在，则删除重复的 `backup-<时间戳>/`，避免双份。

**保留数量**：`backup/` 下的时间戳子目录与尚未迁移的 `backup-*` **一并计入**总数；超过 `MAX_BACKUPS`（默认 3）时按时间戳（目录名）排序，删除**最旧**的一份（不论在新目录结构还是旧命名下）。

示例（Kiro 项目级）：
```
.kiro/
├── skills/
│   ├── workspace-init/         # 远端同名 → 同步覆盖；旧版本进入 backup
│   ├── spec-skills-refresh/    # 远端同名 → 同上
│   └── my-diy-skill/           # 本地 DIY → 不备份、不被同步触碰
└── backup/
    └── 20260424_142738/
        └── skills/             # 仅含与远端同名的子目录（不含 my-diy-skill）
            ├── workspace-init/
            └── spec-skills-refresh/
```

## 环境与行为说明

- **默认仓库**：`https://github.com/pengguogo/ai-coding-skills.git`（HTTPS 克隆建议带 `.git` 后缀）。
- **默认分支**：`main`。脚本使用 `git sparse-checkout` 拉取 `skills/`、`agents/`、`commands/`，再通过 `fetch --depth=1` 浅克隆减少传输量；可用参数 `--branch` 覆盖；交互时仓库地址可直接回车采用默认 URL。
- **Trae 环境限制**：Trae IDE 的 PowerShell 安全沙箱（denylist）会阻止 AI 操作 `.trae/`、`.vscode/`、`.git/` 目录。脚本会自动检测 Trae 环境并通过 bash 执行同步，绕过此限制。若同步失败，请确认 Git Bash 已正确安装。
- **备份**：见上文「备份目录」；快照路径为 `backup/YYYYMMDD_HHMMSS`；仅快照"与远端同名"的 skills 子目录（DIY 技能跳过）；旧版 `backup-<时间戳>/` 会先迁移；保留策略对 `backup/*` 与遗留 `backup-*` 合并计数，超过 `MAX_BACKUPS`（默认 3）时删除最旧快照。
- **配置持久化**：`~/.ai-coding-skills-config` 可保存 `SAVED_REPO_URL` 与 `SAVED_BRANCH`，后续可免填（仍可用命令行覆盖）。
- **依赖**：本机需已安装 `git`；Bash 环境用于执行 `script/spec-skills-refresh.sh`（Git Bash / WSL / macOS / Linux）。
- **项目模式路径检测**：`--scope project` 时，脚本会从当前目录向上查找最外层包含 `.git/` 的目录作为工作区根目录，确保技能放在多个代码库的上一级（如 `工作区根/.kiro/skills/`），而非某个子仓库内部。

## 脚本位置（仓库内）

- 相对仓库根：`skills/spec-skills-refresh/script/spec-skills-refresh.sh`
- 在仓库根目录执行：`bash skills/spec-skills-refresh/script/spec-skills-refresh.sh`
