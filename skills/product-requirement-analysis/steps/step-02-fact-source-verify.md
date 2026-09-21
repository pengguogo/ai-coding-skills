# Step 2: 事实源与合理性校验（门禁）

## 元信息

- agent: requirement-verifier
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1.5
- type: static
- gate: fact-source

## 参数

- input_files: [`{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/00-brainstorm.md`]
- input_files_subagent: [`{WORKSPACE}/requirement/01-fact-source.md`, `{WORKSPACE}/requirement/01-intake.md`, `{WORKSPACE}/requirement/01-modeling.md`, `{WORKSPACE}/requirement/00-brainstorm.md`]
- source_materials: [`[用户提供的原始需求材料]`, `{WORKSPACE}/input/`]
- knowledge_paths: [`{KNOWLEDGE}/business/`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/code/`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- brainstorm_file: `{WORKSPACE}/requirement/00-brainstorm.md`
- history_paths: [`{OCSPEC_ROOT}/requirements/`]
- output_file: `{WORKSPACE}/requirement/02-verify-report.md`
- reference_files: [`references/fact-source-standard.md`, `references/knowledge-cross-reference-guide.md`]
- reference_sections: [`references/fact-source-standard.md`（§二 事实源分级、§四 强制挂溯源的条目、§五 双信号合理性校验、§六 无源断言检测、§七 校验强度、§八 门禁结论、**§九 产品版专属规则**）, `references/knowledge-cross-reference-guide.md#8.1 与现有能力对照`]
- enabled_dimensions: [1, 2, 3, 4, 5, 6]
- status_report_file: `{WORKSPACE}/requirement/02-verify-status-report.md`

## 执行指令

**定位**：本步骤是**门禁**，不产出需求内容，只判定 Step 1 的建模产出是否有据可依。校验规则全部在 `references/fact-source-standard.md`（含产品版专属 §9），本文件不重述规则，只声明执行动作与门禁处置。

**路径前置（Scheduler 强制）**：`{WORKSPACE}` 须已由 Init 解析为 `{BASE_DIR}/_workspace`。本步骤**只读**需求正文、知识库与历史需求，产出仅写 `output_file` 与 `status_report_file`。

**前置条件**：
- `{WORKSPACE}/requirement/01-fact-source.md` 与 `01-modeling.md` 均存在；事实源表缺失 → `NEED_INFO`，Halt 并提示回退 Step 1 补产出
- `00-brainstorm.md` 存在且 `BRAINSTORM_STATUS: approved`

### 1. 全维度执行（产品版不降级）

产品版**始终**按 `execution-mode: agent` 委派 `requirement-verifier`，**不启用**降级 inline 模式——知识库真伪与推断升格两个维度需要大量检索与跨文件比对，放在主 session 会挤压上下文并降低核验质量。

### 2. 执行校验

按 `enabled_dimensions` 执行全部 6 个维度：

| 维度 | 内容 | 产品版重点 |
|------|------|-----------|
| 1 | 事实源真实性（正向核验） | F3 条目锚点精度须达标 |
| 2 | 无源断言检测（反向核验） | 数字型事实 100% 覆盖 |
| **3** | **知识库引用真伪** | **接口名检索不到即判臆造 → FAIL** |
| **4** | **推断升格检测** | **approved 与未处理 `[AI推断]` 并存 → FAIL** |
| **5** | **历史需求只读合规** | 未被修改、无大段复制、相似点可指认 |
| 6 | 内部一致性与语义自洽 | 术语须与 business/custom 已有术语对齐 |

**执行硬约束**：

- 必须逐条打开来源文件按锚点定位核对，**禁止**凭记忆或凭上下文印象判断
- 数字型事实、关键业务规则、接口/消息名 **100%** 核验；其余 **≥30%** 抽样且每个需求项至少 1 条
- 维度 3 的知识库引用与接口名必须用**检索工具**验证存在性，不接受「应该有」的推定
- 维度 4 须逐条比对 brainstorm 的 `[AI推断]` 条目在 intake/modeling 中的使用方式
- 维度 5 须实际打开历史文档核对，不接受仅凭目录名推定相似度
- 每个 ❌/⚠️ 结论必须附证据（文件 + 锚点 + 实际读到的原文片段）

### 3. 门禁处置（Scheduler 强制）

读取 `output_file` 末尾的 `GATE_RESULT`，按下表处置：

| GATE_RESULT | Scheduler 动作 |
|-------------|---------------|
| `PASS` | 进入 Step 3 成稿组装 |
| `CONDITIONAL` | 进入 Step 3；报告 §7「待标记项汇总」交由 Step 3 落标记，存疑项带入交付报告待确认项 |
| `FAIL` | **禁止**进入 Step 3。按报告 §8「需修正项」回退修正后**重跑本步骤** |

**FAIL 回退目标（按原因区分）**：

| FAIL 原因 | 回退目标 |
|-----------|---------|
| 数字型事实无 F1/F2 来源 | Step 1 补来源或标记 |
| 知识库引用臆造 / 接口名编造 | Step 1 重做知识库对照 |
| 无源断言未标记 | Step 1 补溯源挂载 |
| `approved` 与未处理 `[AI推断]` 并存 | **回退 Step 0 Phase F**，按 `fact-source-standard.md` §9.1 处理推断认领后重新 approved |
| 历史需求被修改或大段复制 | Step 1 修正，并恢复历史目录 |

**禁止**：`FAIL` 状态下跳过本步骤直接组装；也**禁止**为了通过门禁而放宽 §8 判定条件。

### 4. 与 Step 3 的衔接

- 本步骤**不改**需求正文；`[事实源存疑]`、`[事实源缺失]`、`[推断待确认]` 标记由 **Step 3** 依据本报告 §7 落到终稿对应位置
- 本步骤**不删**中间产物；`01-fact-source.md` 须保留至 Step 3 归档到 `{BASE_DIR}/sources/fact-source.md`
- `[知识库待补充]` 与 `[事实源缺失]` 的区分结论须在报告中写明，供 Step 4 同步知识库时参考

### 关键约束

- 不修改 `01-intake.md`、`01-modeling.md`、`00-brainstorm.md`、`{REQ}/requirement.md`
- **不写入知识库任何路径**（含 `{CUSTOM_KNOWLEDGE}/`）
- **不写入或修改历史需求目录**下任何文件
- 不补需求内容、不替产品决策
- 不产出可运行代码
- 报告中不得出现无定位的「疑似」「可能」结论
