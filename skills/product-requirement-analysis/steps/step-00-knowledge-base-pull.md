# Step 0: Intake + 知识库拉取 + 产品头脑风暴 [强制停止]

## 元信息

- agent: requirement-modeler
- checkpoint: checkpoints/step-00-checkpoint.md
- checkpoint-level: L1
- **resume: 支持** — Phase D～F 须多次 Exec + 用户回复 + Resume；**禁止**在一次 Exec 内连问或连写草案
- safety_constraints: [不执行 force push, 不修改 .gitconfig, 不 reset --hard, 不删除目录（Phase A-C）, 不覆盖非 git 目录]

## 参数

- input_params: [`REQUIREMENT_SLUG`, `RAW_MATERIALS`, `KNOWLEDGE_REPO_URL`, `KNOWLEDGE_REPO_BRANCH`, `KNOWLEDGE_REPO_CONFIRM`（可选）, `RELATED_REQUIREMENT`（可选）, `ETA_MIN`（可选）]
- input_files: [`[用户提供的原始需求材料]`, `{KNOWLEDGE}/_workspace/product-req/*`（Phase C 后）, `{KNOWLEDGE}/business/`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/code/`（按需）, `{WORKSPACE}/requirement/00-brainstorm-state.md`（Init 后，若已存在）]
- output_file: `(console)` + Pin 文件 + `{WORKSPACE}/requirement/00-brainstorm.md`（**FINAL_APPROVAL 后** approved）
- reference_files: [`references/product-intake-guide.md`, `references/knowledge-base-pull-guide.md`, `references/knowledge-readiness-standard.md`, `references/product-brainstorm-guide.md`, `references/knowledge-cross-reference-guide.md`, `references/product-intake-guide.md#关联历史需求：只读参照（强制）`, `references/fact-source-standard.md`（§9.1 Brainstorm 推断认领门）]
- status_report_file: `{WORKSPACE}/requirement/00-brainstorm-status-report.md`（Phase D 起；Init 前 NEED_INFO 仅控制台）

## 步骤总览

| 段 | Phase | 内容 | Init |
|----|-------|------|------|
| 拉库 | A～C | Intake → clone/Pin → 就绪度 | **C 完成后 Scheduler 执行 Init** |
| 头脑风暴 | D～F | 推断 → 功能澄清 → 草案 approved | Init 后 `{WORKSPACE}` 可写 |

**本步骤结束条件**：`00-brainstorm.md` 中 `BRAINSTORM_STATUS: approved` → Phase `requirement-analysis`（Step 1）。

---

## Part 1：Intake + 知识库（Phase A～C）

Pin 目录：`{OCSPEC_KB_DIR}/knowledge/_workspace/product-req/`（Phase B 确定 `{OCSPEC_KB_DIR}` 后创建）。

### Phase A：统一产品 Intake

从用户 prompt 提取字段（见 `references/product-intake-guide.md`）：

| 字段 | 必填 | 说明 |
|------|------|------|
| `REQUIREMENT_SLUG` | 否 | 未提供时 Init 从材料推断 |
| `RAW_MATERIALS` | **是** | 附件、@ 引用或粘贴正文 |
| `KNOWLEDGE_REPO_URL` | **是** | 见 intake 指南「知识库地址门禁」 |
| `KNOWLEDGE_REPO_CONFIRM` | 条件 | 用户明确确认本地 `ocspec-*` |
| `KNOWLEDGE_REPO_BRANCH` | **是** | clone/update 后切换分支 |
| `RELATED_REQUIREMENT` | 否 | 历史需求目录（只读参照） |
| `ETA_MIN` | 否 | clone 超时（分钟） |

**判定**：
- `RAW_MATERIALS` 或 `KNOWLEDGE_REPO_BRANCH` 缺失 → NEED_INFO，Halt
- **`KNOWLEDGE_REPO_URL` 与 `KNOWLEDGE_REPO_CONFIRM` 均缺失** → NEED_INFO，禁止进入 B.2
- `REQUIREMENT_SLUG` 不符合 `^[a-z][a-z0-9-]*$` → NEED_INFO
- 本 Phase 不落盘

### Phase B：知识库拉取与结构校验

#### B.0 工作区根扫描（只读）

扫描工作区根，收集 `ocspec-*`（含 `knowledge/`）、其它 Git 仓库（标注非知识库）、其它顶层目录。

**禁止**：因「仅 1 个 `ocspec-*`」跳过用户确认。

#### B.1 确定目标仓库（门禁）

满足 **URL** 或 **本地 CONFIRM + 明确确认语** 方可继续；否则 NEED_INFO Halt。禁止无 URL/CONFIRM 时 clone、mkdir、git init。详见 `product-intake-guide.md`。

本地 CONFIRM 路径：读取 `origin` 写入 Pin，`KB_SOURCE: local-confirmed`。

#### B.2 clone / update 与切换分支

- URL 路径：校验 URL → 推导 `ocspec-*` 目录名 → clone 或 fetch → `checkout` 分支 → `pull --ff-only`
- CONFIRM 路径：仅 fetch / checkout / pull，禁止 clone
- 超时：默认 5min；`ETA_MIN` 放宽
- 鉴权失败 → BLOCKED

#### B.3 结构校验

Git 仓库、`ocspec-` 前缀、`knowledge/` 存在、分支正确、pull 成功。失败 → BLOCKED。

### Phase C：就绪度 + Pin 落盘

1. 创建 `{OCSPEC_KB_DIR}/knowledge/_workspace/product-req/`
2. 按 `knowledge-readiness-standard.md` 写入 `00-kb-readiness.md`
3. 写入 `00-product-intake.md`（Phase A 字段 + `KB_SOURCE` + 材料摘要）
4. 写入 `00-ocspec-pin.md`：

```markdown
# Product Requirement Analysis — Init Pin

OCSPEC_ROOT_PIN: <工作区根>/<ocspec-目录名>
REQUIREMENT_SLUG: <slug>（未提供时写「未提供」）
RELATED_REQUIREMENT: <路径或（无）>
INTAKE_DATE: <yyyymmdd>
KNOWLEDGE_READINESS: ready | partial | minimal
KNOWLEDGE_REPO_URL: <URL 或 origin>
KNOWLEDGE_REPO_CONFIRM: <目录名或（无）>
KB_SOURCE: url-clone | local-confirmed
```

5. 控制台输出（Init 须读取）：

```text
=== 产品需求分析 — Step 0 Part1 完成 ===
OCSPEC_ROOT_PIN: <路径>
REQUIREMENT_SLUG: <slug>
KNOWLEDGE_READINESS: ready | partial | minimal
OCSPEC_KB_DIR: <路径>
OCSPEC_KB_BRANCH: <分支>
校验: ✅ / ❌
```

**Phase C 完成后**：Scheduler **执行 Init**（SKILL.md §Init 覆盖规则），再 **Resume Step 0** 进入 Phase D。

---

## Part 2：产品头脑风暴（Phase D～F）

**路径前置**：Init 已解析 `{BASE_DIR}`、`{WORKSPACE}`。规范见 `references/product-brainstorm-guide.md`。

### 单 Exec 硬约束（Phase D～F）

| 允许动作 | 说明 |
|---------|------|
| `ASK_ONE_QUESTION` | Phase E：一个功能/设计/信息缺口问题 |
| `PRESENT_DRAFT` | Phase F：合并草案确认 |
| `FINAL_APPROVAL` | 写入 `00-brainstorm.md`，`approved` |

- 每 Exec 仅一类动作 → Halt；`total_rounds ≤ 10`
- 更新 `00-brainstorm-state.md`；**禁止** `*log*.md`
- Resume Step 0（非 Step 1）

### Phase D：探索与推断（不 Halt 确认背景）

1. 读取 Pin、readiness、材料；按 readiness 浏览 knowledge
2. `RELATED_REQUIREMENT` 非「无」时只读历史 `requirement.md`
3. 推断背景/用户/价值 → `inferred_context`（**不停轮确认**）
4. 评估 `functional_gaps`；可 skip 时压缩为 `PRESENT_DRAFT` + `FINAL_APPROVAL`
5. → Phase E，或 `functional_gaps` 为空则直接 Phase F

**来源属性标注（强制）**：`inferred_context` 与后续草案中**每一条**结论须标注来源属性，取值见 `references/fact-source-standard.md` §9.1：

| 标注 | 含义 | 级别 |
|------|------|------|
| `[用户确认]` | 用户在对话中明确回答或提供 | F2 |
| `[材料原文]` | 来自 `RAW_MATERIALS` | F1 |
| `[知识库]` | 来自 knowledge 三层，须带锚点 | F3 |
| `[AI推断]` | 本 Phase 推断得出，用户尚未确认 | F5 |

Phase D 推断出的背景/用户/价值默认全部为 `[AI推断]`，**不得**标为 `[用户确认]`。

**禁止**：方案对比；对背景/用户/价值单独停轮；结论不标来源属性。

### Phase E：功能向澄清（0～4 问 / Exec）

仅从 `functional_gaps` **一次一问**；齐备或 `total_rounds ≥ 10` → Phase F。

用户回答的内容改标 `[用户确认]`（F2）；未被问到的推断仍为 `[AI推断]`。

### Phase F：合并草案与落盘

1. `PRESENT_DRAFT` → 用户确认。草案中每条结论**须带来源属性标注**；`[AI推断]` 条目须集中列出，便于用户一次性认领。
2. **推断认领门（强制，见 `fact-source-standard.md` §9.1）**：`FINAL_APPROVAL` 前，草案中所有 `[AI推断]` 条目必须二选一处理完毕——
   - **用户显式认领** → 改标 `[用户确认]`，级别升 F2；
   - **用户未认领** → 移入 brainstorm「待澄清」小节，**不得**进入功能清单（§4）与验收口径（§5）。
3. `FINAL_APPROVAL` → 写 `00-brainstorm.md`，`BRAINSTORM_STATUS: approved`

**approved 硬条件**：`00-brainstorm.md` 中**不得**同时存在 `BRAINSTORM_STATUS: approved` 与未处理的 `[AI推断]` 条目。违反此条时 Step 2 门禁直接判 `FAIL` 并回退本 Phase。

**落盘结构补充**：`00-brainstorm.md` 须含「来源属性汇总」小节，列出各属性条目数与 `[AI推断]` 的处置结果（已认领 / 已移入待澄清）。

### 禁止反模式

- ❌ 方案对比 / 多方案选型停轮
- ❌ 背景类逐段确认 / 一次成稿无交互
- ❌ `total_rounds > 10` 仍提问
- ❌ Init 前写入 `{WORKSPACE}/requirement/`
- ❌ 草案结论不标来源属性
- ❌ 把 Phase D 的推断标为 `[用户确认]`
- ❌ 存在未处理 `[AI推断]` 却写入 `BRAINSTORM_STATUS: approved`
- ❌ 未认领的推断进入功能清单或验收口径

**approved 后** Scheduler 进入 Step 1。
