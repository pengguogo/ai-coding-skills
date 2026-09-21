# Step 2: 事实源与合理性校验（门禁）

## 元信息

- agent: requirement-verifier
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1.5
- type: static
- gate: fact-source

## 参数

- input_files: [`{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`]
- input_files_subagent: [`{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`]
- source_materials: [`[用户提供的原始需求材料]`, `{WORKSPACE}/input/`, `{WORKSPACE}/input/media/`]
- output_file: `{WORKSPACE}/requirement/02-verify-report.md`
- reference_files: [`references/fact-source-standard.md`]
- reference_sections: [`references/fact-source-standard.md`（§二 事实源分级、§四 强制挂溯源的条目、§五 双信号合理性校验、§六 无源断言检测、§七 校验强度、§八 门禁结论）]
- enabled_dimensions: [1, 2, 6]
- status_report_file: `{WORKSPACE}/requirement/02-verify-status-report.md`

## 执行指令

**定位**：本步骤是**门禁**，不产出需求内容，只判定 Step 1 的建模产出是否有据可依。校验规则全部在 `references/fact-source-standard.md`，本文件不重述规则，只声明执行动作与门禁处置。

**路径前置（Scheduler 强制）**：`{WORKSPACE}` 须已由 Init 解析为 `{BASE_DIR}/_workspace`。本步骤**只读**需求正文，产出仅写 `output_file` 与 `status_report_file`。

**前置条件**：`{WORKSPACE}/requirement/01-fact-source.md` 与 `01-modeling.md` 均存在。若事实源表缺失 → `NEED_INFO`，Halt 并提示回退 Step 1 补产出。

### 1. 降级判定（先做，决定执行模式）

满足**全部**下列条件时，本步骤降级为 `execution-mode: inline`（当前 session 内校验，不起 subagent）：

- 需求项数 ≤ 2
- 事实源条目数 ≤ 15
- 无图片、无知识库引用（本技能默认无知识库对照）

否则按默认 `execution-mode: agent` 委派 `requirement-verifier` 执行。

降级判定结果须写入 `output_file` §0 校验范围表。

### 2. 执行校验

按 `enabled_dimensions` 执行维度 **1（事实源真实性）**、**2（无源断言检测）**、**6（内部一致性）**。

维度 3/4/5 为产品版专属（知识库真伪、推断升格、历史需求只读），本技能**不启用**，在报告中写「未启用（本技能无知识库/brainstorm/历史对照）」。

**执行硬约束**：

- 必须逐条打开来源文件按锚点定位核对，**禁止**凭记忆或凭上下文印象判断
- 数字型事实、关键业务规则 **100%** 核验；其余 **≥30%** 抽样且每个需求项至少 1 条
- 用检索工具辅助抓取正文中的数字与接口路径，避免肉眼扫描漏检
- 每个 ❌/⚠️ 结论必须附证据（文件 + 锚点 + 实际读到的原文片段）

### 3. 门禁处置（Scheduler 强制）

读取 `output_file` 末尾的 `GATE_RESULT`，按下表处置：

| GATE_RESULT | Scheduler 动作 |
|-------------|---------------|
| `PASS` | 进入 Step 3 成稿组装 |
| `CONDITIONAL` | 进入 Step 3；报告 §7「待标记项汇总」交由 Step 3 落标记，存疑项带入交付报告待确认项 |
| `FAIL` | **禁止**进入 Step 3。回退 Step 1 按报告 §8「需修正项」修正后**重跑本步骤**；重跑仍 `FAIL` 且原因为材料本身缺失 → Halt 向用户澄清 |

**禁止**：`FAIL` 状态下跳过本步骤直接组装；也**禁止**为了通过门禁而放宽 §8 判定条件。

### 4. 与 Step 3 的衔接

- 本步骤**不改**需求正文；`[事实源存疑]`、`[事实源缺失]`、`[推断待确认]` 标记由 **Step 3** 依据本报告 §7 落到终稿对应位置
- 本步骤**不删**中间产物；`01-fact-source.md` 须保留至 Step 3 归档到 `{BASE_DIR}/sources/fact-source.md`

### 关键约束

- 不修改 `01-intake.md`、`01-modeling.md`、`{REQ}/requirement.md`
- 不补需求内容、不替产品决策
- 不产出可运行代码
- 报告中不得出现无定位的「疑似」「可能」结论
