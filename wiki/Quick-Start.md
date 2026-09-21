# 快速开始

## 1. 克隆

```bash
git clone https://github.com/pengguogo/ai-coding-skills.git
cd ai-coding-skills
```

## 2. 分发技能

```bash
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

默认来源为 `https://github.com/pengguogo/ai-coding-skills.git`，默认分支为 `main`。脚本可把 `skills/`、`agents/`、`commands/` 同步到 Cursor、Kiro、Claude Code、OpenCode 或 Trae 的全局/项目目录。

## 3. 启动流水线

按需在 AI 工具中调用技能，例如：

```text
/workspace-init
/code-knowledge-init
/requirement-analysis
/fullstack-design
/task-split
/fullstack-code-implementation
/fullstack-code-review
/project-archive
```

无需机械执行全部阶段；已有可靠上游产物时，可以从对应阶段开始。
