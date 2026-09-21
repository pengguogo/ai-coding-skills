# Checkpoint: Step 5 自检与路径校验 + 交付

> **审查级别**：L2（完整审查）— 检查全部维度，含跨文件一致性。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。这是组装后的全局校验，任何失败项都应暂停供人工决策。
> **强制停止点**：这是唯一的交付点。汇总所有待确认项，停下来等待用户确认。

## 审查时需打开的文件
- `{WORKSPACE}/code/02-tech-detect.md`（比对基准）
- `{CODE_KNOWLEDGE}/backend-project.md`（若后端）
- `{CODE_KNOWLEDGE}/backend-database/`（若后端，含 index.md）
- `{CODE_KNOWLEDGE}/backend-interface/`（若后端，含 index.md）
- `{CODE_KNOWLEDGE}/backend-external-dependency.md`（若后端）
- `{CODE_KNOWLEDGE}/frontend-project.md`（若前端）
- `{CODE_KNOWLEDGE}/scan-plan.md`

## 产出路径与文件名
- [ ] 产出路径正确（{CODE_KNOWLEDGE}/）
- [ ] 文件名符合约定（backend-project.md / backend-database/ [/ index.md + 分册] / backend-interface/ [/ index.md + 分册] / backend-external-dependency.md / frontend-project.md / scan-plan.md）
- [ ] 父目录不存在 `backend-interface.md`（接口清单统一在 `backend-interface/` 目录内）
- [ ] 父目录不存在 `backend-database.md`（数据模型统一在 `backend-database/` 目录内）
- [ ] 未在工作区根目录或其他位置新建 knowledge/ 文件夹

## 产出语言
- [ ] 所有文档仅使用简体中文

## 内容自检（9 项）
- [ ] 产出路径与文件名符合约定
- [ ] 产出语言为简体中文
- [ ] 模块、接口、目录、配置、版本等信息来自实际代码与配置
- [ ] 不确定项明确标注 [需人工确认]
- [ ] *-scan-result.md 中间文件已删除（scan-plan.md 保留）
- [ ] 核心业务流程基于全量代码扫描产出，覆盖所有入口层识别到的业务流程
- [ ] 每条核心业务流程附带 Mermaid 时序图或流程图
- [ ] 入口层完整性自检已执行，核心业务流程已覆盖入口层中的所有入口类
- [ ] 不得在文档末尾添加任何降级说明

## 跨文档一致性
- [ ] backend-project.md 的模块划分与 `backend-interface/index.md`（及分册文件，若存在）的接口分组一致
- [ ] backend-project.md 引用的数据模型与 `backend-database/index.md`（及分册文件，若存在）的表结构一致
- [ ] backend-external-dependency.md 的外部依赖在 backend-project.md 中有体现

## 扫描特有校验（code-knowledge-init 独有）
- [ ] **scan-plan.md 所有扫描项状态为 DONE 且实际产出数为精确整数**
- [ ] **合理性检查 4 项均通过**（覆盖率 ≥ 0.80 / 类型纯度 ≤ 50% / 字段完整度 ≥ 0.30 / 偏差 ≤ 20%）
- [ ] **扫描覆盖率 ≥ 0.80**（每个扫描项的产出条目数 / 探针命中数）
- [ ] **[需人工确认] 占比 ≤ 20%**（单份文档）
- [ ] **无占位字段残留**（不存在 TODO/TBD/N/A/- 等占位值）
- [ ] **中间文件已清理**（产出目录中无残留 *-scan-result.md 文件）
- [ ] **门禁校验通过**（scan-plan.md 中各扫描项的"实际产出数"与文档中的实际条目数一致）
- [ ] **DDL 覆盖完整**（若 Step 2 发现 DDL 路径，`backend-database/index.md` 或分册中须有对应的表结构）

## backend-interface 产出目录（若后端）
- [ ] **目录入口**：`backend-interface/index.md` 存在；父目录无 `backend-interface.md`
- [ ] **输出模式与规模匹配**：入口 > 300 或模块 > 20 时为分册模式；`index.md` 无 Controller 级接口表格
- [ ] **分册完整性**：索引表列出的每个 `{module}.md` 均存在于 `backend-interface/`；分册条目数之和与统计概要一致（偏差 ≤ 5%）
- [ ] **单文件合规**：入口 ≤ 300 且模块 ≤ 20 时，`backend-interface/` 内以 `index.md` 承载全文

## backend-database 产出目录（若后端）
- [ ] **目录入口**：`backend-database/index.md` 存在；父目录无 `backend-database.md`
- [ ] **输出模式与规模匹配**：表 > 50 或模块 > 20 时为分册模式；`index.md` 无 `#### 表N:` 级字段表格
- [ ] **分册完整性**：索引表列出的每个 `{module}.md` 均存在于 `backend-database/`；分册表数之和与统计概要一致（偏差 ≤ 5%）
- [ ] **单文件合规**：表 ≤ 50 且模块 ≤ 20 时，`backend-database/` 内以 `index.md` 承载全文

## 输出范围一致性
- [ ] 输出范围与项目识别结果一致（与 02-tech-detect.md 比对）
- [ ] 一体化项目同时覆盖前后端
- [ ] 分离项目不强行补齐不属于当前工程的一端文档

## 核心业务流程覆盖
- [ ] 核心业务流程覆盖完整（覆盖入口层中的所有入口类）
- [ ] 未覆盖的入口已标注为"非业务入口"并说明理由

## Mermaid 图
- [ ] Mermaid 图语法正确
- [ ] 单张 Mermaid 图节点数 ≤ 30，超过时已分拆子图

## 表格列完整性
- [ ] 所有表格严格遵循规范中定义的表头，无漏列
- [ ] 无数据的列填「-」或「不适用」

## 待确认项清零检查（终稿强制）
- [ ] 所有产出文档全文不包含 `<!-- STATUS_REPORT -->` 块
- [ ] 交付文档中不包含任何 STATUS_REPORT 块
- [ ] 无残留 [待补充] 标记

## 待确认项提取
- 所有产出文档中的 [需人工确认] 标记（含位置）
- 上述审查中不可自动修正的 ❌ 项
- 状态报告中的 corrections-made、manual-review-needed 和 unresolved-items
- scan-plan.md 中状态非 DONE 的扫描项
