# 目录结构

本文档说明 AI Coding Skills 项目的目录结构以及需求实现过程中的产物目录组织方式。

---

## 项目目录结构

```
ai-coding-skills/
├── README.md                           # 项目说明
├── wiki/                               # Wiki 文档
│   ├── Home.md
│   ├── Quick-Start.md
│   ├── Pipeline-Overview.md
│   ├── Skills-Reference.md
│   ├── Directory-Structure.md
│   ├── Best-Practices.md
│   ├── Contributing.md
│   └── _Sidebar.md
└── skills/                             # 技能包目录
    ├── spec-skills-refresh/            # 阶段0: 规范技能刷新
    │   ├── SKILL.md                    # 技能定义
    │   ├── references/                 # 参考文档
    │   │   └── *.md
    │   └── script/                     # 可执行脚本
    │       └── spec-skills-refresh.sh
    │
    ├── workspace-init/                 # 阶段1: 工作空间初始化
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── code-knowledge-init/            # 阶段2: 代码知识还原
    │   ├── SKILL.md
    │   ├── backend/                    # 后端知识文档
    │   │   └── *.md
    │   ├── frontend/                   # 前端知识文档
    │   │   └── *.md
    │   ├── references/                 # 参考文档
    │   │   └── *.md
    │   └── script/                     # 可执行脚本
    │       └── *.sh
    │
    ├── application-knowledge-init/     # 阶段2: 应用架构知识
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── business-knowledge-init/        # 阶段2: 业务架构知识
    │   ├── SKILL.md
    │   └── references/
    │       ├── business-overview-and-planning-spec.md
    │       ├── business-domain-and-orchestration-spec.md
    │       ├── business-process-and-use-cases-spec.md
    │       ├── business-domain-task-template.md
    │       ├── business-domain-knowledge-standard.md
    │       └── business-capability-and-appendices-spec.md
    │
    ├── prototype-derivation/           # 阶段3: 原型推导
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── requirement-analysis/           # 阶段3: 需求分析
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── fullstack-design/               # 阶段4: 技术方案设计
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── task-split/                     # 阶段5: 任务拆分
    │   ├── SKILL.md
    │   └── references/
    │       └── *.md
    │
    ├── fullstack-code-implementation/  # 阶段6: 代码实现
    │   ├── SKILL.md
    │   ├── backend/                    # 后端实现指南
    │   │   └── *.md
    │   ├── frontend/                   # 前端实现指南
    │   │   ├── component-patterns.md
    │   │   └── *.md
    │   └── templates/                  # 代码模板
    │       ├── vue-component.vue
    │       ├── api-service.ts
    │       └── *.template
    │
    ├── fullstack-code-review/          # 阶段7: 代码审查
    │   ├── SKILL.md
    │   ├── backend/                    # 后端审查清单
    │   │   └── *.md
    │   ├── frontend/                   # 前端审查清单
    │   │   └── *.md
    │   └── common/                     # 通用审查清单
    │       └── *.md
    │
    └── project-archive/                # 阶段7: 项目归档
        ├── SKILL.md
        └── references/
            └── *.md
```

---

## 数据产物目录

需求实现过程中的产物按以下目录组织：

```
ocspec-<xxx>/                           # 项目根目录
├── knowledge/                          # 知识库（持续积累）
│   ├── code/                           # 代码知识
│   │   ├── <项目名>/                   # 特定项目的代码知识
│   │   │   ├── frontend-project.md    # 前端项目结构
│   │   │   ├── backend-project.md     # 后端项目结构
│   │   │   └── *.md
│   │   └── ...
│   ├── application/                    # 应用架构知识
│   │   ├── application-system-architecture.md
│   │   └── *.md
│   └── business/                       # 业务知识
│       ├── business-overview-and-planning.md
│       ├── business-domain-and-orchestration.md
│       ├── business-process-and-use-cases.md
│       └── *.md
│
└── requirements/                       # 需求目录
    └── <需求英文名>_<yyyymmdd>/        # 特定需求（如 user-auth_20260610）
        ├── requirement/                # 需求文档
        │   ├── requirement.md          # 需求结构化文档
        │   ├── prototype-index.md      # 原型推导索引
        │   ├── prototype-details.md    # 原型推导明细
        │   └── conflict-log.md         # 冲突日志
        │
        ├── design/                     # 设计文档
        │   ├── backend-design.md       # 后端技术方案
        │   └── frontend-design.md      # 前端技术方案
        │
        ├── task/                       # 任务拆分
        │   └── task-split.md           # 任务清单与依赖关系
        │
        ├── review/                     # 代码审查
        │   └── code-review-report.md   # 代码审查报告
        │
        └── archive/                    # 归档文档
            ├── code-archive.md         # 代码归档
            ├── application-archive.md  # 应用层归档
            └── business-archive.md     # 业务层归档
```

---

## 目录说明

### skills/ 目录

存放所有技能包，每个技能包包含：
- `SKILL.md` — 技能定义（触发条件、执行流程、输出交付物、执行红线）
- `references/` — 参考文档（规范、模板、检查清单）
- 可选的 `script/`、`templates/`、`backend/`、`frontend/`、`common/` 目录

### knowledge/ 目录

知识库目录，用于存放通过知识还原阶段（阶段 2）生成的文档：
- `code/` — 代码层知识，按项目名分类
- `application/` — 应用架构知识
- `business/` — 业务架构知识

**特点**: 知识库是持续积累的，可以在任何时候重新执行知识还原阶段来更新。

### requirements/ 目录

需求目录，按 `需求英文名_日期` 格式组织：
- 每个需求包含完整的生命周期文档
- 从需求分析到归档的所有产物都在对应需求目录下
- 便于追溯和管理

---

## 目录命名规范

### 需求目录命名

格式：`<需求英文名>_<yyyymmdd>`

示例：
- `user-auth_20260610` — 用户认证需求，2026年6月10日
- `payment-gateway_20260615` — 支付网关需求，2026年6月15日

### 文档命名

- 使用小写字母和连字符
- 例如：`backend-design.md`、`task-split.md`

---

## 下一步

- 查看 [[最佳实践|Best-Practices]] 了解目录组织的最佳实践
- 查看 [[常见问题|FAQ]] 解答常见问题
