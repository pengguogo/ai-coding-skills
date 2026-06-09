# AI Coding Skills

端到端 AI 辅助编码技能体系 —— 规范化 · 可追溯 · 质量内建

---

## 概述

本仓库包含一套完整的 **E2E AI Coding Skills** 体系，覆盖从技能分发、环境初始化、知识还原、需求分析、技术方案设计、任务拆分、代码实现到项目归档的完整端到端 AI 编码流程。

> 本技能体系从 E2E AI Coding 全流程报告提取并还原，保留了原始的目录结构和文件组织方式。

---

## 核心理念

| 理念 | 说明 |
|------|------|
| **🔧 规范化** | 每个阶段严格遵循标准化流程与规范引用，确保产出物结构一致、可审计 |
| **🔗 可追溯** | 从需求到代码的全链路可追溯：REQ 编号 → 设计文档 → 任务拆分 → 代码实现 → 归档 |
| **✅ 质量内建** | 质量不是事后检查，而是内建于每个阶段，贯穿全流程的质量保障 Skills |

---

## 技能体系总览

共 **23 个 Skills**，分为 **8 个流水线阶段** + **6 个质量保障技能**：

### 流水线阶段

| 阶段 | 名称 | Skills |
|------|------|--------|
| 0 | 技能分发与同步 | `spec-skills-refresh` |
| 1 | 环境初始化 | `workspace-init`, `using-git-worktrees` |
| 2 | 知识还原 | `code-knowledge-init`, `application-knowledge-init`, `business-knowledge-init` |
| 3 | 需求分析 | `prototype-derivation`, `requirement-analysis` |
| 4 | 技术方案设计 | `fullstack-design` |
| 5 | 任务拆分 | `task-split` |
| 6 | 代码实现 | `fullstack-code-implementation` |
| 7 | 项目归档 | `project-archive` |

### 质量保障技能（横切能力）

`test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `dispatching-parallel-agents`

### 通用实现路径

`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`

---

## 目录结构

```
skills/
├── spec-skills-refresh/          # 规范技能刷新
│   ├── SKILL.md
│   ├── references/
│   └── script/
├── workspace-init/               # 工作空间初始化
│   ├── SKILL.md
│   └── references/
├── code-knowledge-init/          # 代码知识还原
│   ├── SKILL.md
│   ├── backend/
│   ├── frontend/
│   ├── references/
│   └── script/
├── application-knowledge-init/   # 应用架构知识生成
│   ├── SKILL.md
│   └── references/
├── business-knowledge-init/      # 业务架构知识生成
│   ├── SKILL.md
│   └── references/
├── prototype-derivation/         # 原型→需求推导
│   ├── SKILL.md
│   └── references/
├── requirement-analysis/         # 需求分析
│   ├── SKILL.md
│   └── references/
├── fullstack-design/             # 前后端技术方案设计
│   ├── SKILL.md
│   └── references/
├── task-split/                   # 任务拆分
│   ├── SKILL.md
│   └── references/
├── fullstack-code-implementation/ # 代码实现
│   ├── SKILL.md
│   ├── backend/
│   ├── frontend/
│   └── templates/
├── fullstack-code-review/        # 代码审查
│   ├── SKILL.md
│   ├── backend/
│   ├── common/
│   └── frontend/
└── project-archive/              # 项目归档
    ├── SKILL.md
    └── references/
```

---

## 使用方式

### 1. 技能刷新（spec-skills-refresh）

从 GitLab 中央仓库拉取最新技能包，同步到各 AI 编码工具：

```bash
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

支持工具：Cursor / Kiro / Trae / Claude Code / OpenCode

### 2. 按流水线执行

标准执行顺序：

```
workspace-init → code-knowledge-init → application-knowledge-init / business-knowledge-init
→ prototype-derivation → requirement-analysis → fullstack-design → task-split
→ fullstack-code-implementation → project-archive
```

### 3. 质量保障技能

在任何阶段均可激活质量保障技能：
- **TDD**: `test-driven-development`
- **调试**: `systematic-debugging`
- **验证**: `verification-before-completion`
- **审查**: `requesting-code-review`, `receiving-code-review`
- **并行**: `dispatching-parallel-agents`

---

## 每个 Skill 的结构

每个 Skill 遵循统一的母版结构：

```
skill-name/
├── SKILL.md              # 技能定义（触发条件、执行流程、输出交付物、执行红线）
└── references/           # 参考文档（规范、模板、检查清单）
    └── *.md
```

部分 Skill 还包含：
- `script/` — 可执行脚本（如扫描脚本、同步脚本）
- `templates/` — 代码模板（如 Vue 组件模板、API 服务模板）
- `backend/` / `frontend/` / `common/` — 分类文档

---

## 来源

本技能体系从 **E2E AI Coding 全流程报告** 提取并还原，保留了原始的目录结构和文件组织方式。

---

## License

MIT
