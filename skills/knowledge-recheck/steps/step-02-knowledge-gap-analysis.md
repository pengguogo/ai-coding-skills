# Step 2: 知识库覆盖与缺口分析

## 元信息

- agent: input-analyzer
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{WORKSPACE}/knowledge-recheck/01-intake-and-scope.md`, `{WORKSPACE}/knowledge-recheck/summaries/01-intake-and-scope.summary.md`, `[Step 1 确定的需求文档路径]`, `[Step 1 确定的代码范围路径]`, `{CODE_KNOWLEDGE}/`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/business/`, `{DESIGN}/`, `{TASK}/`, `{ARCHIVE}/`（若存在）, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- input_files_subagent: [`{WORKSPACE}/knowledge-recheck/summaries/01-intake-and-scope.summary.md`, `{CODE_KNOWLEDGE}/`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/business/`]
- output_file: `{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`
- reference_files: [`references/knowledge-coverage-checklist.md`, `references/pipeline-readiness-checklist.md`, `../code-knowledge-init/references/backend-knowledge-layout-compat.md`]
- domain_context: 对照需求项与代码范围，分别检查 knowledge 下 code、application、business 三层沉淀完整性、三层一致性、流水线完成度与归档就绪情况，产出结构化缺口清单

## Summary 配置

- output: `{WORKSPACE}/knowledge-recheck/summaries/02-knowledge-gap-analysis.summary.md`
- must-include:
  - 覆盖统计（需求项矩阵、代码反查、检查清单是否 100%）
  - 知识库**三层**覆盖结论（code / application / business 分别 complete/partial/missing/outdated）
  - 三层一致性摘要（术语/边界/流程是否 cross-layer 对齐）
  - 未归档需求提示（archive 三件套缺失或不全，**逐条**）
  - 知识库未更新功能清单（**逐需求项/功能**）
  - 建议后续动作（project-archive / knowledge-init / 无需动作）
- max-length: 1200
- must-exclude:
  - 完整需求/知识库原文
  - 最终质检报告组装
  - 追溯矩阵全表（Step 3 须读 Step 2 完整产出 `{WORKSPACE}/knowledge-recheck/02-knowledge-gap-analysis.md`）

## 产出结构（extraction_schema）

```markdown
# 知识库覆盖与缺口分析

## 1. 分析范围摘要
- 复检模式：
- 需求项数量：
- 代码范围：（若有）

## 2. 流水线阶段完成度
| 阶段 | 产出 | 状态 | 证据路径 | 缺口说明 |
|------|------|------|---------|---------|
| 需求成稿 | requirement.md | | | |
| 系统设计 | backend/frontend design | | | |
| 任务拆分 | task-split.md | | | |
| 代码实现 | 代码变更 | | | |
| 代码评审 | review-log.md | | | |
| 统一归档 | archive 三件套 | | | |

## 3. knowledge/code 覆盖（{CODE_KNOWLEDGE}）
| 检查项 | 状态 | 证据 | 缺口 |
|--------|------|------|------|
| backend-project.md | | | |
| backend-interface（目录或 `backend-interface.md`） | | | |
| backend-database（目录或 `backend-database.md`） | | | |
| frontend-project.md | | | |
| ... | | | |

## 4. knowledge/application 覆盖（`{KNOWLEDGE}/application/`，须逐项打开文档）

| 检查项 | 状态 | 证据 | 缺口 |
|--------|------|------|------|
| （按 knowledge-coverage-checklist AK-* 及实际文件填写，不得留空壳） |

## 5. knowledge/business 覆盖（`{KNOWLEDGE}/business/`，须逐项打开文档）

| 检查项 | 状态 | 证据 | 缺口 |
|--------|------|------|------|
| （按 knowledge-coverage-checklist BK-* 及实际文件填写，不得留空壳） |

## 5.1 知识库三层一致性（code ↔ application ↔ business）

| 对照维度 | code 层 | application 层 | business 层 | 是否一致 | 缺口说明 |
|---------|---------|----------------|-------------|---------|---------|
| 应用/系统命名 | | | | | |
| 模块/组件边界 | | | | | |
| 业务流程/用例 | | | | | |
| （按需求项扩展行） | | | | | |

## 6. 需求项 × 知识库追溯矩阵（须 100% 覆盖 Step 1 全部需求项，一行一项，禁止省略）

| 需求项 | 设计覆盖 | 任务覆盖 | 代码/实现证据 | code 知识 | app 知识 | biz 知识 | 综合状态 |
|--------|---------|---------|--------------|----------|----------|----------|---------|

## 6.1 追溯矩阵覆盖统计
| 应检需求项数 | 矩阵行数 | 是否 100% |
|-------------|---------|----------|

## 7. 检查清单逐项结论（须覆盖 references 中全部 CK/AK/BK/PR 检查项 ID，禁止跳过）

| 检查项 ID | 状态 | 证据 | 缺口 |
|-----------|------|------|------|

## 8. 未归档项清单
| 序号 | 对象 | 类型 | 说明 | 建议动作 |
|------|------|------|------|---------|

## 9. 知识库未更新功能清单
| 序号 | 功能/需求项 | 缺失层级（code / application / business，可多选） | 说明 | 建议动作 |
|------|------------|--------------------------------------------------|------|---------|

## 10. 代码范围反查（code-scope / hybrid，须 100% 覆盖 Step 1 代码范围索引，一行一项）

| 代码路径/模块 | 推断功能 | 需求文档是否覆盖 | code 知识 | app 知识 | biz 知识 | 备注 |
|--------------|---------|----------------|----------|----------|----------|------|

## 10.1 代码范围覆盖统计
| 应检条目数 | 反查表行数 | 是否 100% |
|-----------|-----------|----------|

## 11. 待确认项
```

## 执行指令

1. 读取 Step 1 产出与 reference 检查清单，确认分析范围；记录 Step 1「覆盖统计」中的应检数量，作为本步骤**覆盖率分母**
2. **流水线完成度**：按 `pipeline-readiness-checklist.md` **逐项**检查全部 PR-* 检查项（不得跳过任一行）
3. **knowledge 三层完整性（分别执行，禁止只检 code）**：
   - **code 层**：打开 `{CODE_KNOWLEDGE}/` 下全部终稿，按 CK-* 检查，结论写入 §3 与 §7；接口/库表须先按 `backend-knowledge-layout-compat.md` 判定布局（目录或存量单文件），**两种均视为 present**
   - **application 层**：打开 `{KNOWLEDGE}/application/` 下全部 `.md`，按 AK-* 检查，结论写入 §4 与 §7；目录 absent/empty → 整层标 `missing`，写入未更新清单
   - **business 层**：打开 `{KNOWLEDGE}/business/` 下全部 `.md`，按 BK-* 检查，结论写入 §5 与 §7；目录 absent/empty → 整层标 `missing`，写入未更新清单
   - §7 检查清单表须包含**全部** CK/AK/BK/PR（及 CU，若 applicable）ID，**每个 ID 一行**
4. **三层一致性（§5.1）**：对 Step 1 各需求项，交叉比对 code 中的模块/接口、application 中的系统/组件、business 中的流程/规则是否同名同义；不一致 → 写入未更新清单或待确认项，并标注冲突层级
5. **需求项追溯矩阵（100% 覆盖）**：
   - Step 1 需求项索引中的**每一条**需求项须在 §6 矩阵中占**恰好一行**
   - 矩阵行数须等于 Step 1「覆盖统计」中的应检需求项数；不等 → **BLOCKED**，回到 Step 1 补全
   - 逐行判定设计/任务/实现/**code / app / biz 三列知识**覆盖状态，不得合并多需求项为一行，**禁止**三列留空或仅填 code
6. **归档就绪**：
   - `{ARCHIVE}/code-archive.md`、`appliaction-archive.md`、`business-archive.md` 三件套**均 present** → 归档阶段标记 complete
   - 对**每个**已在 design/task/代码中有实现证据的需求项，若 archive 未覆盖 → 写入「未归档项清单」（逐条列出，禁止合并为「等多项」）
7. **知识库同步（按层标注）**：
   - 对**每个**需求项，分别在 code、application、business 三层**独立**检索；任一层未找到对应条目 → 「知识库未更新功能清单」**一行一项**，**缺失层级**列须写 `code` / `application` / `business`（可多选，不得笼统写「知识库」）
8. **code-scope 反查（100% 覆盖）**：Step 1 代码范围索引**每一行**须在 §10 反查表中有对应行；**code / app / biz 知识**列分别填写，不得合并为一列「知识库是否更新」
9. 填写 §6.1、§10.1 覆盖统计；任一项非 100% → 本步骤判定不通过，不得进入 Step 3
10. 综合状态取值：`complete` / `partial` / `missing` / `outdated` / `not-applicable`；每条须有证据路径
11. **只读**：禁止修改 knowledge、代码、需求目录终稿；禁止写入 `{CUSTOM_KNOWLEDGE}/`
