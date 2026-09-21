# Step 5: 自检与路径校验 [强制停止]

## 元信息

- agent: assembler
- checkpoint: checkpoints/step-05-final.md
- checkpoint-level: L2

## 参数

- source_files:
  - `{CODE_KNOWLEDGE}/backend-project.md`（若后端）
  - `{CODE_KNOWLEDGE}/backend-database/`（若后端，含 index.md）
  - `{CODE_KNOWLEDGE}/backend-interface/`（若后端，含 index.md）
  - `{CODE_KNOWLEDGE}/backend-external-dependency.md`（若后端）
  - `{CODE_KNOWLEDGE}/frontend-project.md`（若前端）
  - `{CODE_KNOWLEDGE}/scan-plan.md`
- output_file: `{WORKSPACE}/code/05-verification-report.md`
- assembly_template: skip（文档已在 Step 3/4 直接写入最终路径，本步骤仅执行校验）
- consistency_rules: |
    ## 输出路径自检
    - 终稿仅在 `{CODE_KNOWLEDGE}/`（Init 解析的 `{OCSPEC_ROOT}/knowledge/code/<项目名>/`），不在工作区根
    - 工作区根下无新建的并行 `ocspec-*`（除 `[路径解析]` 中的 `OCSPEC_ROOT` 外）
    - 文件名符合约定

    ## 内容自检（9 项）
    - 产出语言为简体中文
    - 模块、接口、目录、配置、版本等信息来自实际代码与配置
    - 不确定项明确标注 [需人工确认]
    - *-scan-result.md 中间文件已删除（scan-plan.md 保留）
    - 核心业务流程基于全量代码扫描产出
    - 每条核心业务流程附带 Mermaid 时序图或流程图
    - 入口层完整性自检已执行
    - 不得在文档末尾添加任何降级说明

    ## 跨文档一致性
    - backend-project.md 的模块划分与 backend-interface/index.md（及 `backend-interface/` 分册，若存在）的接口分组一致
    - backend-project.md 引用的数据模型与 backend-database/index.md（及 `backend-database/` 分册，若存在）的表结构一致
    - backend-external-dependency.md 的外部依赖在 backend-project.md 中有体现

    ## 扫描特有校验（第二轮新增）
    - scan-plan.md 所有扫描项状态为 DONE，实际产出数已填写（精确整数）
    - 合理性检查 4 项均已执行且通过（覆盖率/类型纯度/字段完整度/偏差）
    - 扫描覆盖率：产出条目数 / 探针命中数 ≥ 0.80
    - [需人工确认] 占比：单份文档不超 20%
    - 占位字段检查：不存在 TODO/TBD/N/A/- 等占位值
    - 中间文件清理：无残留 *-scan-result.md 文件
    - 门禁校验：Step 3/4 写入时已执行门禁校验（条目数偏差 ≤ 5%），本步骤验证 scan-plan.md 中各扫描项的"实际产出数"与文档中的实际条目数一致

    ## backend-interface 产出目录（若后端）
    - 入口为 backend-interface/index.md；父目录不得存在 backend-interface.md
    - 分册模式：index.md 仅含统计 + 模块索引；backend-interface/{module}.md 与索引表一一对应（偏差 ≤ 5%）
    - 单文件模式：backend-interface/ 内以 index.md 承载全文

    ## backend-database 产出目录（若后端）
    - 入口为 backend-database/index.md；父目录不得存在 backend-database.md
    - 分册模式：index.md 仅含统计 + 模块索引；backend-database/{module}.md 与索引表一一对应（偏差 ≤ 5%）
    - 单文件模式：backend-database/ 内以 index.md 承载全文

    ## 输出范围一致性
    - 输出范围与项目识别结果一致
    - 一体化项目同时覆盖前后端
    - 分离项目不强行补齐不属于当前工程的一端文档
- status_report_file: `{WORKSPACE}/code/05-status-report.md`
- upstream_compare: [`{WORKSPACE}/code/02-tech-detect.md`]

## 执行指令

本步骤跳过合并（文档已在 Step 3/4 直接写入最终路径），直接执行全局自检。

### 1. 输出路径自检
- 核对 `[路径解析]` 中的 `OCSPEC_ROOT` 与 `OCSPEC_CANDIDATES`（不得另建 `ocspec-<项目名>`）
- 确认终稿路径为 `{CODE_KNOWLEDGE}/`（即 `{OCSPEC_ROOT}/knowledge/code/<项目名>/`）
- 确认中间产物仅在 `{WORKSPACE}/`（即 `{KNOWLEDGE}/_workspace/code/`）
- 若 `[路径解析]` 中 `OCSPEC_ROOT_CREATED: yes` 但 `OCSPEC_SCAN_RAW` 非空 → 判定 **不通过**（Init 违规兜底新建）
- 若工作区根存在多个 `ocspec-*` 且与 `OCSPEC_ROOT` 不一致 → 判定 **不通过**，删除误建目录后重跑
- 禁止在工作区根目录新建 `knowledge/` 或第二个 `ocspec-*`

### 2. 内容自检（9 项）
1. 产出路径与文件名符合约定
2. 产出语言为简体中文
3. 模块、接口、目录、配置、版本等信息来自实际代码与配置
4. 不确定项明确标注 [需人工确认]
5. *-scan-result.md 中间文件已删除（scan-plan.md 保留）
6. 核心业务流程基于全量代码扫描产出，覆盖所有入口层识别到的业务流程
7. 每条核心业务流程附带 Mermaid 时序图或流程图
8. 入口层完整性自检已执行（根包扫描、启动类追踪、配置文件追踪），核心业务流程已覆盖入口层中的所有入口类
9. 不得在文档末尾添加任何降级说明

### 3. 跨文档一致性校验
- backend-project.md 的模块划分与 backend-interface/index.md（及 `backend-interface/` 分册，若存在）的接口分组一致
- backend-project.md 引用的数据模型与 backend-database/index.md（及 `backend-database/` 分册，若存在）的表结构一致
- backend-external-dependency.md 的外部依赖在 backend-project.md 中有体现

### 4. 扫描特有校验（第二轮新增，code-knowledge-init 独有）
1. **scan-plan 完成度**：scan-plan.md 的所有扫描项状态为 DONE，实际产出数已填写（精确整数，非估算）
2. **合理性检查结果**：每个扫描项的 4 项合理性检查（覆盖率/类型纯度/字段完整度/偏差）均已执行且通过
3. **扫描覆盖率**：每个扫描项的产出条目数 / 探针命中数 ≥ 0.80
4. **[需人工确认] 占比**：单份文档中 [需人工确认] 标注占比不超 20%
5. **占位字段检查**：扫描所有产出文档，不存在 TODO/TBD/N/A/- 等占位值（附录 §A8 定义）
6. **中间文件清理**：产出目录中无残留 *-scan-result.md 文件
7. **门禁校验**：验证 scan-plan.md 中各扫描项的"实际产出数"与文档中的实际条目数一致（门禁校验在 Step 3/4 写入时已执行，本步骤做二次确认）
8. **DDL 覆盖**：若 Step 2 发现 DDL 路径，`backend-database/index.md` 或分册中须有对应的表结构
9. **backend-interface 产出目录**（若后端）：按 backend-interface.md §2 校验；入口为 `backend-interface/index.md`；父目录无 `backend-interface.md`；分册完整性
10. **backend-database 产出目录**（若后端）：按 backend-database.md §2 校验；入口为 `backend-database/index.md`；父目录无 `backend-database.md`；分册完整性

### 5. 自动修正
- 可自动修正的不一致（格式差异、编号大小写）：直接修正文档
- 不可修正的：标注 [需人工确认]

### 6. 待确认项清零检查
扫描所有产出文档全文，搜索残留的 [需人工确认]、[待补充]、<!-- STATUS_REPORT --> 块。

### 关键约束
- 不新增内容，只做校验、修正格式
- 状态报告写入 status_report_file，不写入交付文档
- 交付文档中不得包含任何 STATUS_REPORT 块
- 用户确认后，由 Scheduler 统一清理 `{WORKSPACE}` 目录（见 scheduler-protocol §9.1）
