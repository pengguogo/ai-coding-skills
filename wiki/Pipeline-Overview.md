# 流水线概览

AI Coding Skills 包含 **8 个流水线阶段**，覆盖从技能分发到项目归档的完整生命周期。

---

## 流水线全景图

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

---

## 阶段详解

### 阶段 0：技能分发与同步

**Skill**: `spec-skills-refresh`

**目标**: 从 GitHub 拉取最新技能包到各 AI 工具

**执行方式**:
```bash
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

或在 AI 工具中：
```
/spec-skills-refresh
```

**产出**: 技能包同步到各工具的配置目录

**支持工具**: Cursor / Kiro / Trae / Claude Code / OpenCode

---

### 阶段 1：环境初始化

**Skill**: `workspace-init`

**目标**: 批量 clone 仓库并切换到指定分支

**执行方式**:
1. 创建 `repos.txt` 配置文件
2. 执行 `/workspace-init`

**产出**: 所有仓库按配置初始化完成

---

### 阶段 2：知识还原

**三层知识流水线**：

| 顺序 | Skill | 目标 | 产出 |
|------|-------|------|------|
| 2.1 | `code-knowledge-init` | 还原代码层知识 | `frontend-project.md`, `backend-project.md` |
| 2.2 | `application-knowledge-init` | 还原应用架构知识 | `application-system-architecture.md` |
| 2.3 | `business-knowledge-init` | 还原业务架构知识 | `business-overview-and-planning.md` 等 |

**执行方式**:
```
/code-knowledge-init
/application-knowledge-init
/business-knowledge-init
```

**关键约束**: 必须按顺序执行，后续阶段依赖前序阶段的产出

---

### 阶段 3：需求分析

**Skills**: `prototype-derivation` → `requirement-analysis`

**目标**: 从原型推导到需求结构化

**执行流程**:

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

### 阶段 4：技术方案设计

**Skill**: `fullstack-design`

**目标**: 在同一会话内完成后端设计与前端设计

**执行方式**:
```
/fullstack-design
```

**产出**:
- `design/backend-design.md` — 后端技术方案
- `design/frontend-design.md` — 前端技术方案

**关键约束**: 前端设计必须基于后端设计的接口定义进行字段级对齐

---

### 阶段 5：任务拆分

**Skill**: `task-split`

**目标**: 基于设计文档拆分前后端任务

**执行方式**:
```
/task-split
```

**产出**: `task/task-split.md`
- 后端任务清单（数据库、模块、集成、测试）
- 前端任务清单（路由、组件、状态、联调）
- 任务依赖关系与执行顺序

---

### 阶段 6：代码实现

**Skill**: `fullstack-code-implementation`

**目标**: 基于任务拆分进行前后端编码

**执行方式**:
```
/fullstack-code-implementation
```

**执行流程**:
1. 读取 `task/task-split.md`
2. 按依赖顺序执行后端任务
3. 后端完成后执行前端任务
4. 编译门槛验证（后端编译 + 前端构建）

---

### 阶段 7：代码审查与归档

**Skills**: `fullstack-code-review` → `project-archive`

**目标**: 代码审查 + 统一归档

**执行流程**:

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

## 流水线使用建议

### 完整执行

适用于全新项目，按照阶段 0 → 7 顺序执行。

### 跳跃执行

适用于已有部分产物的场景：

- **已有需求文档**：从阶段 4 开始
- **已有设计文档**：从阶段 5 开始
- **已有代码实现**：从阶段 7 开始

### 循环执行

知识还原阶段（阶段 2）可以在任何时候重新执行，以更新知识库。

---

## 下一步

- 查看 [[技能参考|Skills-Reference]] 了解每个 Skill 的详细用法
- 查看 [[最佳实践|Best-Practices]] 了解使用技巧
