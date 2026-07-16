# AI Coding Skills

> **简体中文** | [English](README.en.md)

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

本仓库包含 **12 个 Skills**（另有 2 个质量保障技能在 `fullstack-code-review` 中体现），分为 **8 个流水线阶段**：

### 流水线阶段

| 阶段 | 名称 | Skills | 说明 |
|------|------|--------|------|
| 0 | 技能分发与同步 | `spec-skills-refresh` | 从 GitHub 拉取最新技能包到各 AI 工具 |
| 1 | 环境初始化 | `workspace-init` | 批量 clone 仓库、切换分支 |
| 2 | 知识还原 | `code-knowledge-init`<br>`application-knowledge-init`<br>`business-knowledge-init` | 三层知识流水线：代码 → 应用 → 业务 |
| 3 | 需求分析 | `prototype-derivation`<br>`requirement-analysis` | 原型推导 → 需求结构化 |
| 4 | 技术方案设计 | `fullstack-design` | 后端设计 → 前端设计（同一会话内完成） |
| 5 | 任务拆分 | `task-split` | 拆分前后端任务、依赖关系 |
| 6 | 代码实现 | `fullstack-code-implementation` | 前后端编码实现 |
| 7 | 项目归档 | `project-archive`<br>`fullstack-code-review` | 代码审查 → 统一归档 |

---

## 使用流程

### 完整流水线执行顺序

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              E2E AI Coding 流水线                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  阶段0: spec-skills-refresh                                                │
│     ↓                                                                       │
│  阶段1: workspace-init                                                     │
│     ↓                                                                       │
│  阶段2: code-knowledge-init → application-knowledge-init                   │
│                                → business-knowledge-init                    │
│     ↓                                                                       │
│  阶段3: prototype-derivation → requirement-analysis                        │
│     ↓                                                                       │
│  阶段4: fullstack-design (后端设计 → 前端设计)                              │
│     ↓                                                                       │
│  阶段5: task-split                                                         │
│     ↓                                                                       │
│  阶段6: fullstack-code-implementation                                      │
│     ↓                                                                       │
│  阶段7: fullstack-code-review → project-archive                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 详细使用说明

#### 阶段 0：技能分发与同步

**Skill**: `spec-skills-refresh`

将本仓库的技能包同步到各 AI 编码工具的配置目录。

```bash
# 交互式执行
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh

# 或直接调用技能（在 AI 工具中输入）
/spec-skills-refresh
```

**支持工具**: Cursor / Kiro / Trae / Claude Code / OpenCode

---

#### 阶段 1：环境初始化

**Skill**: `workspace-init`

批量 clone 仓库并切换到指定分支。

1. 在工作区根目录创建 `repos.txt` 文件，格式如下：
   ```
   # name    type    url                                          branch
   my-api    app     https://github.com/org/my-api.git            main
   my-web    app     https://github.com/org/my-web.git            develop
   ```

2. 执行技能：
   ```
   /workspace-init
   ```

---

#### 阶段 2：知识还原

**三层知识流水线**：

| 顺序 | Skill | 产出 |
|------|-------|------|
| 2.1 | `code-knowledge-init` | `frontend-project.md`, `backend-project.md` 等 |
| 2.2 | `application-knowledge-init` | `application-system-architecture.md` 等 |
| 2.3 | `business-knowledge-init` | `business-overview-and-planning.md` 等 |

**执行方式**：
```
/code-knowledge-init
/application-knowledge-init
/business-knowledge-init
```

---

#### 阶段 3：需求分析

**Skills**: `prototype-derivation` → `requirement-analysis`

1. **原型推导**（如有 Axure/Figma 原型）：
   ```
   /prototype-derivation
   ```
   产出：推导索引表、推导明细、冲突日志

2. **需求结构化**：
   ```
   /requirement-analysis
   ```
   产出：`requirement/requirement.md`

---

#### 阶段 4：技术方案设计

**Skill**: `fullstack-design`

在同一会话内完成后端设计与前端设计：

```
/fullstack-design
```

**产出**：
- `design/backend-design.md` — 后端技术方案
- `design/frontend-design.md` — 前端技术方案

**关键约束**：前端设计必须基于后端设计的接口定义进行字段级对齐。

---

#### 阶段 5：任务拆分

**Skill**: `task-split`

基于设计文档拆分前后端任务：

```
/task-split
```

**产出**：`task/task-split.md`
- 后端任务清单（数据库、模块、集成、测试）
- 前端任务清单（路由、组件、状态、联调）
- 任务依赖关系与执行顺序

---

#### 阶段 6：代码实现

**Skill**: `fullstack-code-implementation`

基于任务拆分进行前后端编码：

```
/fullstack-code-implementation
```

**执行流程**：
1. 读取 `task/task-split.md`
2. 按依赖顺序执行后端任务
3. 后端完成后执行前端任务
4. 编译门槛验证（后端编译 + 前端构建）

---

#### 阶段 7：代码审查与归档

**Skills**: `fullstack-code-review` → `project-archive`

1. **代码审查**：
   ```
   /fullstack-code-review
   ```
   产出：`review/code-review-report.md`

2. **项目归档**：
   ```
   /project-archive
   ```
   产出：
   - `archive/code-archive.md` — 代码归档
   - `archive/application-archive.md` — 应用层归档
   - `archive/business-archive.md` — 业务层归档

---



## 目录结构

```
skills/
├── spec-skills-refresh/          # 阶段0: 规范技能刷新
│   ├── SKILL.md
│   ├── references/
│   └── script/
├── workspace-init/               # 阶段1: 工作空间初始化
│   ├── SKILL.md
│   └── references/
├── code-knowledge-init/          # 阶段2: 代码知识还原
│   ├── SKILL.md
│   ├── backend/
│   ├── frontend/
│   ├── references/
│   └── script/
├── application-knowledge-init/   # 阶段2: 应用架构知识
│   ├── SKILL.md
│   └── references/
├── business-knowledge-init/      # 阶段2: 业务架构知识
│   ├── SKILL.md
│   └── references/
├── prototype-derivation/         # 阶段3: 原型推导
│   ├── SKILL.md
│   └── references/
├── requirement-analysis/         # 阶段3: 需求分析
│   ├── SKILL.md
│   └── references/
├── fullstack-design/             # 阶段4: 技术方案设计
│   ├── SKILL.md
│   └── references/
├── task-split/                   # 阶段5: 任务拆分
│   ├── SKILL.md
│   └── references/
├── fullstack-code-implementation/ # 阶段6: 代码实现
│   ├── SKILL.md
│   ├── backend/
│   ├── frontend/
│   └── templates/
├── fullstack-code-review/        # 阶段7: 代码审查
│   ├── SKILL.md
│   ├── backend/
│   ├── common/
│   └── frontend/
└── project-archive/              # 阶段7: 项目归档
    ├── SKILL.md
    └── references/
```

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

## 数据产物目录

需求实现过程中的产物按以下目录组织：

```
ocspec-<xxx>/
├── knowledge/                    # 知识库（持续积累）
│   ├── code/<项目名>/            # 代码知识
│   ├── application/              # 应用架构知识
│   └── business/                 # 业务知识
└── requirements/
    └── <需求英文名>_<yyyymmdd>/
        ├── requirement/          # 需求文档
        ├── design/               # 设计文档
        ├── task/                 # 任务拆分
        ├── review/               # 代码审查
        └── archive/              # 归档文档
```

---



---

## License

MIT
