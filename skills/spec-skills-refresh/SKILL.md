---
name: spec-skills-refresh
description: 从 GitHub 拉取 ai-coding-skills 技能包（默认 main 分支），并按所选工具与范围同步 skills/agents/commands 到全局或项目内的 AI 编程工具目录。触发词：规范技能刷新、spec-skills-refresh、更新技能、同步最新技能、从 git 拉取技能、update skills、sync skills from git。
---

# 规范技能刷新（Spec Skills Refresh）

## 何时使用

- 用户希望从远端更新本地 AI 技能包
- 新机器或新克隆仓库后，需要把技能刷到 Cursor / Kiro / Claude Code / OpenCode / Trae
- 触发词：规范技能刷新、spec-skills-refresh、更新技能、同步最新技能、从 git 拉取技能
- 英文触发：spec skills refresh、update skills、sync skills from git

## 核心能力

- 检测 bash、git 和目标工具目录等同步前置条件
- 从远端仓库拉取技能包并按范围同步 skills/agents/commands
- 支持 Cursor、Kiro、Claude Code、OpenCode、Trae 多工具路径映射
- 覆盖前备份已有文件，并输出同步结果报告

## 执行原则

- **确认后执行**：不在未确认仓库 URL 与范围的情况下执行覆盖式同步
- **脚本为准**：实际克隆、复制、合并逻辑以 `script/spec-skills-refresh.sh` 为准
- **路径单一来源**：路径映射、来源目录、环境依赖等细则见 `references/sync-layout.md`，不在 SKILL.md 中重复维护
- **不修改远程仓库**：不替用户解决网络/权限/git 凭据问题（仅提示检查）
- **不臆造配置**：默认以脚本内 DEFAULT_REPO_URL / DEFAULT_BRANCH 为准

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/sync-layout.md` | 技能源目录、各工具目标路径、同步方式、环境/备份细则 |

## 执行入口

**你是这个技能的 Scheduler。** 按以下顺序启动：

1. 读取 `{COMMANDS_ROOT}/scheduler-protocol.md` 获取编排规则
2. 按下方 phases/steps 声明，由编排协议的状态机驱动执行

> `{COMMANDS_ROOT}` 按 scheduler-protocol §10 三级回退策略解析（项目级 `.xxx/` → 工作区根 `commands/` → 编辑器全局 `~/.xxx/commands/`）。

## 与其他技能的关系

- 并行：`workspace-init` 可在 spec-skills-refresh 之前或之后独立执行
- 下游：所有其他 Skill 依赖 spec-skills-refresh 将技能文件同步到编辑器目录

## Phases

### Phase: sync（同步）
halt-after: true

- Step 1: steps/step-01-env-check.md
- Step 2: steps/step-02-execute-sync.md
- Step 3: steps/step-03-verify-result.md

## 交付物

- 各目标工具的 skills/agents/commands 目录下的更新文件（由 references/sync-layout.md 定义路径，持久化）
- 控制台输出：同步报告（工具/路径/技能数/备份数/状态，非持久化）
