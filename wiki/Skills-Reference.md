# 技能参考

本仓库包含 **12 个 Skills**（另有 2 个质量保障技能在 `fullstack-code-review` 中体现），分为 **8 个流水线阶段**。

---

## 技能总览

| 阶段 | Skill | 说明 | 触发命令 |
|------|-------|------|----------|
| 0 | [[spec-skills-refresh\|Skills/spec-skills-refresh]] | 技能分发与同步 | `/spec-skills-refresh` |
| 1 | [[workspace-init\|Skills/workspace-init]] | 环境初始化 | `/workspace-init` |
| 2 | [[code-knowledge-init\|Skills/code-knowledge-init]] | 代码知识还原 | `/code-knowledge-init` |
| 2 | [[application-knowledge-init\|Skills/application-knowledge-init]] | 应用架构知识 | `/application-knowledge-init` |
| 2 | [[business-knowledge-init\|Skills/business-knowledge-init]] | 业务架构知识 | `/business-knowledge-init` |
| 3 | [[prototype-derivation\|Skills/prototype-derivation]] | 原型推导 | `/prototype-derivation` |
| 3 | [[requirement-analysis\|Skills/requirement-analysis]] | 需求分析 | `/requirement-analysis` |
| 4 | [[fullstack-design\|Skills/fullstack-design]] | 技术方案设计 | `/fullstack-design` |
| 5 | [[task-split\|Skills/task-split]] | 任务拆分 | `/task-split` |
| 6 | [[fullstack-code-implementation\|Skills/fullstack-code-implementation]] | 代码实现 | `/fullstack-code-implementation` |
| 7 | [[fullstack-code-review\|Skills/fullstack-code-review]] | 代码审查 | `/fullstack-code-review` |
| 7 | [[project-archive\|Skills/project-archive]] | 项目归档 | `/project-archive` |

---

## 阶段 0：技能分发与同步

### spec-skills-refresh

**目标**: 从 GitHub 拉取最新技能包到各 AI 工具

**触发方式**:
```bash
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

或在 AI 工具中：
```
/spec-skills-refresh
```

**支持工具**: Cursor / Kiro / Trae / Claude Code / OpenCode

**产出**: 技能包同步到各工具的配置目录

**详细文档**: [[Skills/spec-skills-refresh]]

---

## 阶段 1：环境初始化

### workspace-init

**目标**: 批量 clone 仓库并切换到指定分支

**触发方式**:
```
/workspace-init
```

**前置条件**: 在工作区根目录创建 `repos.txt` 文件

**配置格式**:
```txt
# name    type    url                                          branch
my-api    app     https://github.com/org/my-api.git            main
my-web    app     https://github.com/org/my-web.git            develop
```

**产出**: 所有仓库按配置初始化完成

**详细文档**: [[Skills/workspace-init]]

---

## 阶段 2：知识还原

### code-knowledge-init

**目标**: 还原代码层知识，生成项目结构文档

**触发方式**:
```
/code-knowledge-init
```

**产出**:
- `frontend-project.md` — 前端项目结构
- `backend-project.md` — 后端项目结构
- 其他项目相关文档

**详细文档**: [[Skills/code-knowledge-init]]

---

### application-knowledge-init

**目标**: 还原应用架构知识

**触发方式**:
```
/application-knowledge-init
```

**产出**:
- `application-system-architecture.md` — 系统架构文档
- 其他应用层文档

**详细文档**: [[Skills/application-knowledge-init]]

---

### business-knowledge-init

**目标**: 还原业务架构知识

**触发方式**:
```
/business-knowledge-init
```

**产出**:
- `business-overview-and-planning.md` — 业务概览与规划
- `business-domain-and-orchestration.md` — 业务领域与编排
- 其他业务层文档

**详细文档**: [[Skills/business-knowledge-init]]

---

## 阶段 3：需求分析

### prototype-derivation

**目标**: 从 Axure/Figma 原型推导需求

**触发方式**:
```
/prototype-derivation
```

**前置条件**: 提供原型文件或原型链接

**产出**:
- 推导索引表
- 推导明细
- 冲突日志

**详细文档**: [[Skills/prototype-derivation]]

---

### requirement-analysis

**目标**: 需求结构化分析

**触发方式**:
```
/requirement-analysis
```

**产出**: `requirement/requirement.md`

**详细文档**: [[Skills/requirement-analysis]]

---

## 阶段 4：技术方案设计

### fullstack-design

**目标**: 在同一会话内完成后端设计与前端设计

**触发方式**:
```
/fullstack-design
```

**产出**:
- `design/backend-design.md` — 后端技术方案
- `design/frontend-design.md` — 前端技术方案

**关键约束**: 前端设计必须基于后端设计的接口定义进行字段级对齐

**详细文档**: [[Skills/fullstack-design]]

---

## 阶段 5：任务拆分

### task-split

**目标**: 基于设计文档拆分前后端任务

**触发方式**:
```
/task-split
```

**产出**: `task/task-split.md`

**内容包括**:
- 后端任务清单（数据库、模块、集成、测试）
- 前端任务清单（路由、组件、状态、联调）
- 任务依赖关系与执行顺序

**详细文档**: [[Skills/task-split]]

---

## 阶段 6：代码实现

### fullstack-code-implementation

**目标**: 基于任务拆分进行前后端编码

**触发方式**:
```
/fullstack-code-implementation
```

**执行流程**:
1. 读取 `task/task-split.md`
2. 按依赖顺序执行后端任务
3. 后端完成后执行前端任务
4. 编译门槛验证（后端编译 + 前端构建）

**详细文档**: [[Skills/fullstack-code-implementation]]

---

## 阶段 7：代码审查与归档

### fullstack-code-review

**目标**: 代码质量审查

**触发方式**:
```
/fullstack-code-review
```

**产出**: `review/code-review-report.md`

**详细文档**: [[Skills/fullstack-code-review]]

---

### project-archive

**目标**: 统一归档项目产物

**触发方式**:
```
/project-archive
```

**产出**:
- `archive/code-archive.md` — 代码归档
- `archive/application-archive.md` — 应用层归档
- `archive/business-archive.md` — 业务层归档

**详细文档**: [[Skills/project-archive]]

---

## 技能结构

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

## 下一步

- 查看 [[最佳实践|Best-Practices]] 了解使用技巧
- 查看 [[常见问题|FAQ]] 解答常见问题
