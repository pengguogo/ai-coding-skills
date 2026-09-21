# Step 1: 复检范围与输入盘点

## 元信息

- agent: input-analyzer
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`[用户指定的需求文档路径或 {REQ}/requirement.md]`, `[用户指定的代码范围说明或路径列表]`, `{CODE_KNOWLEDGE}/`（若存在）, `{KNOWLEDGE}/application/`（若存在）, `{KNOWLEDGE}/business/`（若存在）, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/knowledge-recheck/01-intake-and-scope.md`
- domain_context: 为需求复检建立输入模式、需求项索引与流水线产出存在性清单，不写质检结论
- extraction_schema: |
    # 复检范围与输入盘点

    ## 1. 复检模式
    - 模式：requirement-doc | code-scope | hybrid
    - 说明：[如何确定模式]

    ## 2. 输入清单
    | 类型 | 路径/范围 | 是否存在 | 备注 |
    |------|----------|---------|------|
    | 需求文档 | | | |
    | 代码范围 | | | |
    | 设计文档 | | | |
    | 任务拆分 | | | |
    | 评审记录 | | | |
    | 归档文档 | | | |

    ## 3. 需求项索引（来自需求文档，须 100% 覆盖）
    | 序号 | 需求项 ID/名称 | 所属模块 | 优先级 | 简要说明 |
    |------|---------------|---------|--------|---------|
    （行数 = 需求文档中全部需求项，禁止省略）

    ## 4. 代码范围索引（code-scope / hybrid 时填写，须 100% 覆盖）
    | 序号 | 仓库/路径 | 类型 | 关联需求项（若能推断） | 备注 |
    |------|----------|------|---------------------|------|
    （行数 = 指定范围内全部待检路径/文件，禁止仅列示例）

    ## 4.1 覆盖统计
    | 维度 | 应检数量 | 已列入索引数量 | 是否 100% |
    |------|---------|---------------|----------|
    | 需求项 | | | |
    | 代码范围条目 | | | |

    ## 5. 流水线产出存在性
    | 产出 | 路径 | 状态 | 说明 |
    |------|------|------|------|
    | requirement.md | | present/absent | |
    | backend-design.md | | | |
    | frontend-design.md | | | |
    | task-split.md | | | |
    | review-log.md | | | |
    | code-archive.md | | | |
    | application-archive.md | | | |
    | business-archive.md | | | |

    ## 6. 知识库三层入口索引（须分别列出，禁止仅写 code）
    | 层级 | 路径 | 状态 | 主要 Markdown 文件（逐文件列出） |
    |------|------|------|-------------------------------|
    | code | {CODE_KNOWLEDGE}/ | present/absent/empty | |
    | application | {KNOWLEDGE}/application/ | present/absent/empty | |
    | business | {KNOWLEDGE}/business/ | present/absent/empty | |
    | custom | {CUSTOM_KNOWLEDGE}/ | present/absent/skipped | |

    ## 7. 待确认项
    | 序号 | 问题 | 影响 |
    |------|------|------|

## Summary 配置

- output: `{WORKSPACE}/knowledge-recheck/summaries/01-intake-and-scope.summary.md`
- must-include:
  - 复检模式（requirement-doc / code-scope / hybrid）
  - 需求项索引表（**全部**序号、名称、模块；行数）
  - 代码范围索引行数（若有）
  - 覆盖统计（应检 vs 已检是否 100%）
  - 流水线产出存在性摘要（各产出 present/absent）
  - 知识库三层入口状态（code / application / business 分别 present/absent/empty 及文件数）
  - 待确认项清单
- must-exclude:
  - 需求/设计原文大段摘录
  - 质检结论与建议
- max-length: 600

## 执行指令

**路径前置**：Init 已完成 `[路径解析]`；本步骤仅写入 `{WORKSPACE}/knowledge-recheck/`。

1. **确定复检模式**：
   - 用户 @ 或指定了完整需求文档路径 → `requirement-doc`（若同时指定代码范围 → `hybrid`）
   - 用户仅指定代码路径/模块/文件列表 → `code-scope`
   - 均未指定 → 默认读取 `{REQ}/requirement.md`；若不存在 → **NEEDS_CONTEXT**，列出待确认项
2. 读取需求文档，**穷尽提取**全部需求项写入索引（§2.1 需求内容清单或等价章节每一行均须对应索引一行）；无标准结构时按大标题/功能点**逐条**提取并标注 `[非标准结构]`；**禁止**仅摘录部分需求项
3. **code-scope / hybrid**：对用户指定范围内的**全部**路径/模块/文件建立清单（目录则递归列出待检源码文件，排除 `node_modules`、`target`、`dist` 等构建产物）；清单行数须与实际范围一致；**禁止**修改代码、**禁止**仅列举示例文件
4. 扫描 `{BASE_DIR}` 下 `requirement/`、`design/`、`task/`、`review/`、`archive/`、`recheck/`，填写流水线产出存在性表（present = 文件存在且非空）
5. **分别扫描**知识库三层并填写 §6 索引（每层独立，禁止合并描述）：
   - `{CODE_KNOWLEDGE}/`：列出 backend-project；接口清单（目录 `backend-interface/` 或存量 `backend-interface.md`，标注 `[布局: …]`）；数据模型（目录 `backend-database/` 或存量 `backend-database.md`）；frontend-project、scan-plan 等
   - `{KNOWLEDGE}/application/`：列出 application-system-architecture、applications-and-domains、application-components 等（以实际文件为准）
   - `{KNOWLEDGE}/business/`：列出 business 目录下全部 `.md` 终稿
   - 目录不存在或无可读 `.md` → 状态标 `absent` 或 `empty`，**不得**因 code 层存在而省略 application/business 行
6. 若 `CUSTOM_KNOWLEDGE_STATUS=present`：先读 `{CUSTOM_KNOWLEDGE}/README.md`（若存在）获取索引摘要；**禁止**写入 custom
7. 汇总无法自动判定的项到待确认清单；不写质检结论、不写归档/更新建议
