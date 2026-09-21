# Checkpoint: Step 0 Intake + 知识库 + 产品头脑风暴

> **审查级别**：L1 — 确认拉库/Pin 完整且 brainstorm 已 approved，再进入 Step 1。
> **强制停止点**：Phase `intake-and-brainstorm` 的 halt-after；须用户确认 brainstorm 后再继续。
> **审查原则**：须逐项核对文件系统、git 与产出文件，不能凭记忆判断。

## Part 1 — Intake 与知识库（Phase A～C）

### Intake 与门禁

- [ ] `RAW_MATERIALS`、`KNOWLEDGE_REPO_BRANCH` 已收集
- [ ] **满足其一**：`KNOWLEDGE_REPO_URL`；或 `KNOWLEDGE_REPO_CONFIRM` + 用户明确确认
- [ ] **未**在无 URL 且无 CONFIRM 时进入 clone
- [ ] `REQUIREMENT_SLUG` 合规或未提供（Pin 写「未提供」）

### 知识库拉取

- [ ] 目标 `ocspec-*` 存在，含 `knowledge/`，为 git 仓库
- [ ] `KB_SOURCE` 与操作一致；HEAD = 指定分支
- [ ] `pull --ff-only` 成功或 up-to-date

### 反模式（拉库）

- [ ] 无 URL/CONFIRM 却 clone 或 Pin
- [ ] 唯一 `ocspec-*` 无确认自动绑定
- [ ] 无 URL 时擅自新建 `ocspec-*`

### Pin 与就绪度

- [ ] `00-ocspec-pin.md`、`00-kb-readiness.md`、`00-product-intake.md` 存在
- [ ] Pin 含 `OCSPEC_ROOT_PIN`、`KNOWLEDGE_READINESS`、`KNOWLEDGE_REPO_URL`、`KB_SOURCE`
- [ ] Init 已执行，`{BASE_DIR}` / `{WORKSPACE}` 已解析

## Part 2 — 产品头脑风暴（Phase D～F）

### 审查文件

- `{WORKSPACE}/requirement/00-brainstorm.md`
- `{WORKSPACE}/requirement/00-brainstorm-state.md`
- `{WORKSPACE}/requirement/00-brainstorm-status-report.md`（若有）

### 产出检查

- [ ] `BRAINSTORM_STATUS: approved`
- [ ] 含 §1～§5 及 §6 知识库关系；`TOTAL_ROUNDS ≤ 10`
- [ ] 功能清单 ≥1 行，GWT ≥1 行
- [ ] 无方案对比章节；无代码/接口/库表设计
- [ ] 未产出 `*log*.md`

### 推断认领门（强制，见 fact-source-standard.md §9.1）

- [ ] 每条结论均标注来源属性（`[用户确认]` / `[材料原文]` / `[知识库]` / `[AI推断]`）
- [ ] 含「来源属性汇总」小节，列出各属性条目数与 `[AI推断]` 处置结果
- [ ] **`approved` 与未处理的 `[AI推断]` 条目不并存**
- [ ] 每条 `[AI推断]` 已二选一处理完毕：用户认领改标 `[用户确认]`，或移入「待澄清」小节
- [ ] 未认领的推断**未**进入功能清单（§4）与验收口径（§5）
- [ ] Phase D 推断出的背景/用户/价值未被标为 `[用户确认]`
- [ ] `[知识库]` 属性条目带锚点（文件 + 章节），非只写目录名

### 流程质量

- [ ] 未对背景/用户/价值分段停轮确认
- [ ] 对话聚焦功能、边界、存疑
- [ ] 经历 `PRESENT_DRAFT` 或 skip 模式
- [ ] 未出现 `PRESENT_SCHEMES`

### 反模式（头脑风暴）

- [ ] `total_rounds > 10`
- [ ] 零交互即 approved（非 skip）
- [ ] Init 前写入 brainstorm 文件
- [ ] 结论未标来源属性
- [ ] 推断被标为 `[用户确认]`
- [ ] 存在未处理 `[AI推断]` 却已 `approved`

## 待确认项提取

- Intake NEED_INFO 未解决项
- 鉴权/结构校验 BLOCKED
- `BRAINSTORM_STATUS: draft` 或 status report NEED_INFO
- `KNOWLEDGE_READINESS=minimal`（WARN，不阻塞）
- 移入「待澄清」小节的每条未认领 `[AI推断]`
