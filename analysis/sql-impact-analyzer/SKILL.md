---
name: sql-impact-analyzer
description: |
  数据变更影响分析技能。针对生产数据订正 SQL，自动完成表结构识别、代码链路追踪、字段合理性校验、
  后置功能关联、ER模型影响分析、重复数据风险评估，输出结构化影响分析报告（HTML）+ 验证 SQL 脚本。
  适用场景：用户提供一条或多条生产数据订正 SQL，需要分析下游影响和风险时使用。
  触发词：数订正分析、数据变更影响、数据订正影响分析、SQL 影响分析、生产数据修改影响、data change impact analysis。
---

# 数据变更影响分析

## 何时使用

- 用户提供一条或多条生产数据订正 SQL，需要分析下游影响和风险
- 需要结合代码仓库定位事实源（Mapper XML、Service、EOD Job）
- 需要校验订正字段的合理性（类型、取值范围、字段间依赖）
- 需要分析订正字段变更对关联数据模型的传导影响
- 需要评估重复数据风险并生成人工验证 Check 脚本
- 需要输出可交付的 HTML 格式影响分析报告

## 核心能力

- SQL 解析与业务语义识别
- 订正字段合理性分析（类型/长度/范围/枚举/依赖一致）
- 多仓库代码链路追踪（Entity → Mapper XML → Service → EOD Job）
- ER 模型关联影响全景（目标表 → 关联表字段级影响，橙色标记）
- 后置功能影响分析（触发条件 vs 数据读取）
- 重复数据风险评估（EOD 重复生成/状态回退重复/对账差异）
- 人工验证 Check 脚本生成（订正前检查 + 订正后验证 + 回滚）
- 风险评估与分级（P0/P1/P2）
- 自检校验（通过 subagent 交叉验证）
- 结构化 HTML 报告生成

## 执行原则

- **事实源优先（强制）**：所有结论必须有代码引用支撑，禁止凭经验臆断。引用格式：`文件路径:行号`
- **区分触发 vs 读取**：WHERE/ON 条件中的引用 = 触发影响；SELECT 中的引用 = 展示影响
- **EOD 覆盖风险必查**：任何手动修改的金额/日期字段，必须检查 EOD Job 是否会重新计算覆盖
- **关联传导必查**：订正字段变更必须追踪到所有关联表的对应字段
- **重复风险必评**：每个可能产生重复数据的场景必须明确评估
- **check 脚本必附带**：高风险项必须提供人工验证 SQL 脚本
- **多仓库全覆盖**：工作区内所有代码仓库都要搜索，不得遗漏
- **未找到引用时**：明确标注「未找到代码引用，建议人工确认」

## 规范来源

| 文档 | 用途 |
|------|------|
| `references/report-template.html` | HTML 报告模板（CSS + 结构） |

## 路径与产出约定

- **报告输出位置**：工作区根目录
- **报告命名规则**：`{场景}_data_impact_analysis.html`
  - 场景名从用户提供的上下文或 SQL 涉及的业务场景中提取
- **Check 脚本输出**：`{WORKSPACE}/sql-impact/check_before.sql` / `check_after.sql` / `rollback.sql`

## 执行入口

按以下步骤顺序执行：

---

## Phases

### Phase: analysis

- Step 1: steps/step-01-sql-parsing.md
- Step 2: steps/step-02-code-tracing.md
- Step 3: steps/step-03-field-validation.md
- Step 4: steps/step-04-er-impact.md
- Step 5: steps/step-05-duplicate-check.md
- Step 6: steps/step-06-impact-analysis.md
- Step 7: steps/step-07-risk-assessment.md

### Phase: verification

- Step 8: steps/step-08-quality-check.md

### Phase: output

- Step 9: steps/step-09-report-generation.md

---

## 交付物

- `{场景}_data_impact_analysis.html`（工作区根目录）
- `check_before.sql` / `check_after.sql` / `rollback.sql`（工作区临时目录）

## Agent 职责矩阵

| 步骤 | 执行方式 | 做什么 |
|------|----------|--------|
| Step 1 SQL 解析 | inline | 解析 SQL 提取表名、字段、WHERE 条件、SET 值 |
| Step 2 代码追踪 | subagent: context-gatherer | 搜索代码库定位所有引用 |
| Step 3 字段校验 | inline | 类型/长度/范围/枚举/依赖一致性校验 |
| Step 4 ER 影响 | inline | 构建 ER 模型，标记关联表受影响字段(橙色) |
| Step 5 重复检查 | inline | 重复数据风险 + 生成 check/回滚 SQL 脚本 |
| Step 6 影响分析 | inline | 基于代码引用分析后置功能影响 |
| Step 7 风险评估 | inline | P0/P1/P2 分级 |
| Step 8 质量校验 | subagent: general-task-execution | 交叉校验完整性、事实源、一致性 |
| Step 9 报告生成 | inline | 按 HTML 模板输出报告 |
