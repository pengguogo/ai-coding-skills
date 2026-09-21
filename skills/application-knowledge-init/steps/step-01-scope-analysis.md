# Step 1: 扫描基线目录 + 提取子系统摘要

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/app/summaries/01-scope.summary.md`
- must-include:
  - 子系统清单表格（子系统名+类型+基线完整度+模块数+接口入口数）
  - 各子系统模块名+职责索引表
  - 外部服务清单（服务名+调用方式）
  - Business 基线状态（是否存在+S-* 编号清单）
  - Custom 知识状态（是否存在+文档索引摘要）
  - 文档结构决策（扁平/分层）
- must-exclude:
  - 待确认清单的详细问题描述
- max-length: 800

## 参数

- input_files: [`ocspec-<xxx>/knowledge/code/`（目录扫描）, `ocspec-<xxx>/knowledge/business/`（若存在）, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/app/01-scope.md`
- domain_context: 为应用架构知识生成做范围确定和子系统摘要提取
- extraction_schema: |
    # 分析范围

    ## 1. 子系统清单
    | 序号 | 子系统名 | 类型 | 基线路径 | 基线完整度 | 模块数 | 接口入口数 |
    |------|---------|------|---------|-----------|--------|-----------|

    ## 2. 各子系统关键摘要
    ### <子系统名>
    - 模块清单：[模块名+职责，从 backend-project.md 提取]
    - 接口入口数：[按 `../code-knowledge-init/references/backend-knowledge-layout-compat.md` 判定布局后读取；目录→index.md 统计概要，存量→backend-interface.md 文首统计，平铺分册→汇总]
    - 外部依赖：[从 backend-external-dependency.md 提取系统名列表]
    - 前端信息：[从 frontend-project.md 提取模块和路由数]

    ## 3. Business 基线状态
    - 是否存在：[是/否]
    - S-* 编号体系：[若存在，列出 S-* 清单]

    ## 4. Custom 知识状态
    - 是否存在：[是/否]（`CUSTOM_KNOWLEDGE_STATUS`）
    - 文档索引：[若 present，列出 README 索引或扫描到的 .md 文件清单及摘要]

    ## 5. 外部服务清单（无本地基线）
    | 服务名 | 调用方式 | 被哪些子系统引用 |
    |--------|---------|----------------|

    ## 6. 文档结构决策
    - [扁平（子系统 < 5）/ 分层（子系统 >= 5）]

    ## 7. 待确认清单
    | 序号 | 问题 | 影响范围 |
    |------|------|---------|

## 执行指令

1. 扫描 `ocspec-<xxx>/knowledge/code/` 下的实际目录，列出所有子系统（不得凭印象列举）
2. 对每个子系统，只读关键章节提取摘要（backend-project.md 模块清单；接口清单按 compat 规范判定布局后读取——目录 `backend-interface/index.md`（+ 分册）、存量 `backend-interface.md` 或平铺 `backend-interface-*.md`；backend-external-dependency.md 外部依赖；frontend-project.md 模块和路由数）；标注 `[布局: 目录|单文件|平铺分册]`
3. 检查 `ocspec-<xxx>/knowledge/business/` 是否存在，若存在读取 S-* 编号体系
4. 若 `CUSTOM_KNOWLEDGE_STATUS=present`：先读 `{CUSTOM_KNOWLEDGE}/README.md`（若存在），再按需读取相关 `.md` 文件，提取术语、制度、对接规范等补充信息，写入 Custom 知识状态；若 `absent` 则标注「否」并跳过，不 Halt
5. 从各子系统外部依赖中汇总外部服务清单
6. 根据子系统数量决定文档结构（< 5 扁平 / >= 5 分层）
7. 按 extraction_schema 的结构写入 output_file
8. 产出末尾附加 STATUS_REPORT

### 关键约束
- 不读取 references/ 下的规范文档（**例外**：可读 `../code-knowledge-init/references/backend-knowledge-layout-compat.md` 用于接口/库表路径判定）
- 不做架构拓扑分析（由 Step 2 负责）
- **禁止**写入 `{CUSTOM_KNOWLEDGE}/`
