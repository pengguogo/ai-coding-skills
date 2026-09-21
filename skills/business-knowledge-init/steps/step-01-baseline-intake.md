# Step 1: 分析输入真相源与梳理索引

## 元信息

- agent: input-analyzer
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## Summary 配置

- output: `{WORKSPACE}/biz/summaries/01-baseline.summary.md`
- must-include:
  - 子系统清单表格（子系统名+类型+基线完整度）
  - 各子系统模块清单（模块名+一句话职责）
  - 各子系统 Entity/Domain 类清单索引
  - 各子系统枚举/状态机清单索引
  - Application 基线状态（是否存在+S-* 编号清单+DO-* 清单）
  - Custom 知识状态（是否存在+文档索引摘要）
  - 逆向推导优先级提示表
- must-exclude:
  - 待确认清单的详细问题描述
  - 各子系统模块职责详情
- max-length: 1000

## 参数

- input_files: [`ocspec-<xxx>/knowledge/code/`（目录扫描）, `ocspec-<xxx>/knowledge/application/`（若存在）, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/biz/01-baseline.md`
- domain_context: 为业务架构知识生成做输入材料边界确定，提取代码基线索引和编号体系
- extraction_schema: |
    # 输入真相源与基线索引

    ## 1. 子系统清单
    | 序号 | 子系统名 | 类型 | 基线路径 | 基线完整度 |
    |------|---------|------|---------|-----------|

    ## 2. 各子系统关键摘要
    ### <子系统名>
    - 模块清单：[模块名+职责，从 backend-project.md 提取]
    - Entity/Domain 类清单：[从 backend-project.md 提取]
    - 枚举/状态机清单：[从 backend-project.md 提取]
    - 接口入口数：[按 `../code-knowledge-init/references/backend-knowledge-layout-compat.md` 判定布局后读取；目录→index.md 统计概要，存量→backend-interface.md 文首统计，平铺分册→汇总]
    - 外部依赖：[从 backend-external-dependency.md 提取系统名列表]
    - 前端信息：[从 frontend-project.md 提取模块和路由数]

    ## 3. Application 基线状态
    - 是否存在：[是/否]
    - S-* 编号体系：[若存在，列出 S-* 清单（编号+场景名称）]
    - DO-* 清单：[若存在，列出 DO-* 清单（编号+名称+管理 APP）]
    - APP-*/AG-*/AC-* 清单：[若存在，列出编号清单（仅记录，不定义）]

    ## 4. Custom 知识状态
    - 是否存在：[是/否]（`CUSTOM_KNOWLEDGE_STATUS`）
    - 文档索引：[若 present，列出 README 索引或扫描到的 .md 文件清单及摘要]

    ## 5. 逆向推导优先级提示
    | 子系统 | 枚举/状态机 | MQ/Event | 推导价值 |
    |--------|-----------|---------|---------|

    ## 6. 待确认清单
    | 序号 | 问题 | 影响范围 |
    |------|------|---------|

## 执行指令

1. 扫描 `ocspec-<xxx>/knowledge/code/` 下的实际目录，列出所有子系统（不得凭印象列举）
2. 对每个子系统，只读关键章节提取摘要：
   - backend-project.md：模块清单、Entity/Domain 类清单、枚举/状态机清单
   - 接口清单：按 compat 规范判定布局——目录 `backend-interface/index.md`（+ 分册）、存量 `backend-interface.md` 或平铺 `backend-interface-*.md`；标注 `[布局: 目录|单文件|平铺分册]`
   - backend-external-dependency.md：外部依赖系统名列表
   - frontend-project.md：模块和路由数
3. 检查 `ocspec-<xxx>/knowledge/application/` 是否存在，若存在提取：
   - S-* 编号清单（编号+场景名称）——默认全部复用
   - DO-* 清单（编号+名称+管理 APP）
   - APP-*/AG-*/AC-* 编号清单（仅记录，不定义）
4. 若 `CUSTOM_KNOWLEDGE_STATUS=present`：先读 `{CUSTOM_KNOWLEDGE}/README.md`（若存在），再按需读取相关 `.md` 文件，提取业务规则、术语、制度等补充信息，写入 Custom 知识状态；若 `absent` 则标注「否」并跳过，不 Halt
5. 标注哪些子系统有枚举/状态机可用于推导领域模型
6. 标注哪些子系统有 MQ 生产者/Spring Event/Publisher 可用于推导领域事件
7. 若基线不存在或为空，必须向用户说明，不得凭印象推断

### 关键约束
- 不读取 references/ 下的规范文档（**例外**：可读 `../code-knowledge-init/references/backend-knowledge-layout-compat.md` 用于接口/库表路径判定）
- 不做业务全景分析（由 Step 2 负责）
- 不做领域建模（由 Step 4 负责）
- 不读取子系统基线文档的全文（只读关键章节提取摘要）
- **禁止**写入 `{CUSTOM_KNOWLEDGE}/`
