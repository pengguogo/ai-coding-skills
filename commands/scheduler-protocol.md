# Scheduler Protocol（调度协议）

本协议定义 Skill 中协调 Agent 执行的通用规则。Scheduler（即执行 SKILL.md 的 LLM）按本协议驱动步骤执行。

**本协议是技能无关的。** 不同 skill 的区别仅在于 SKILL.md 中声明的步骤清单不同，编排逻辑完全相同。

---

## 1. 路径变量解析（Init 阶段）

**本节为 OCSPEC 路径布局的唯一权威来源**（含 Agent / Skill 写文件约束）；不再维护独立的 `references/ocspec-path-layout.md`。

Scheduler 在 Init 阶段、读取 SKILL.md 之后、执行第一步之前，必须完成路径变量解析。

### 1.0 Init 强制顺序（写文件前）

**在完成下列步骤之前，禁止创建或写入任何产出文件**（含工作区根目录的 `_workspace/`、`requirements/`、需求子目录）：

> **例外**：仅当 §1.2.1 扫描确认 `OCSPEC_CANDIDATES` 为 0 时，Init 可按 §1.2.2 **兜底新建一个** `ocspec-*` 根及其 `knowledge/`、`requirements/` 骨架；除此以外禁止新建 `ocspec-*`。

1. 解析 `{COMMANDS_ROOT}`、`{AGENTS_ROOT}`（§10）
2. 读取 SKILL.md 的 `base-dir-scope`（未声明时默认为 `requirement`）。**不**从 SKILL 读取固定的 ocspec 目录名（见 §1.2.1）
3. 执行 §1.2.1 **Init 机械扫描**并解析 `{OCSPEC_ROOT}`（扫描非空时**禁止** §1.2.2）
4. 解析 `{BASE_DIR}`（§1.2）
5. 派生 `{WORKSPACE}`、`{REQ}` 等变量（§1.1）
6. 输出 **路径解析摘要**（§1.5）
7. 将步骤参数中的 `{变量名}` 替换为实际路径后，方可进入 Exec

> 临时材料解析（如 docx 转文本）也必须落在 `{WORKSPACE}/input/` 下，不得落在工作区根 `_workspace/`。

### 1.1 变量定义

| 变量 | 含义 | 派生规则 |
|------|------|---------|
| `{OCSPEC_ROOT}` | ocspec 规范包根目录 | 见 §1.2.1（须先于 BASE_DIR 确定） |
| `{BASE_DIR}` | 当前需求根目录 | 见 §1.2 解析规则 |
| `{WORKSPACE}` | 中间产出目录 | 见 §1.1.1（按 `base-dir-scope` 分支，**禁止**与终稿目录混用） |
| `{DESIGN}` | 设计文档目录 | `{BASE_DIR}/design` |
| `{TASK}` | 任务文档目录 | `{BASE_DIR}/task` |
| `{REQ}` | 需求文档目录 | `{BASE_DIR}/requirement` |
| `{ARCHIVE}` | 归档文档目录 | `{BASE_DIR}/archive` |
| `{KNOWLEDGE}` | 知识库根目录 | `{OCSPEC_ROOT}/knowledge` |
| `{CODE_KNOWLEDGE}` | 代码知识库目录 | `{KNOWLEDGE}/code/<项目名>` |
| `{CUSTOM_KNOWLEDGE}` | 用户自定义知识目录（**按需，可选**） | `{KNOWLEDGE}/custom/` |

**目录布局（requirement scope，示意）**：

```text
<工作区根>/
  ocspec-<xxx>/                   ← {OCSPEC_ROOT}（工作区下实际的 ocspec-* 目录名）
    knowledge/                    ← {KNOWLEDGE}
      custom/                     ← {CUSTOM_KNOWLEDGE}（按需创建，见 §1.5.1）
    requirements/
      <需求英文名>_<yyyymmdd>/    ← {BASE_DIR}
        _workspace/               ← {WORKSPACE}（中间产物，交付后删除）
        requirement/              ← {REQ}
        design/                   ← {DESIGN}
        task/                     ← {TASK}
        archive/                  ← {ARCHIVE}
```

#### 1.1.1 {WORKSPACE} 派生（按 scope）

| `base-dir-scope` | `{WORKSPACE}` | 说明 |
|------------------|---------------|------|
| `requirement`（默认） | `{BASE_DIR}/_workspace/` | 单次需求的中间产物 |
| `ocspec-root` | `{KNOWLEDGE}/_workspace/` | 知识库初始化类技能的中间产物，与 `knowledge/` 终稿同级 |

**目录布局（ocspec-root scope，示意）**：

```text
<工作区根>/
  ocspec-<xxx>/                   ← {OCSPEC_ROOT}
    knowledge/                    ← {KNOWLEDGE}
      _workspace/                 ← {WORKSPACE}（code/、app/、biz/ 等子目录）
      code/<项目名>/              ← 终稿 + scan-plan 等
      application/                ← 终稿
      business/                  ← 终稿
      custom/                     ← {CUSTOM_KNOWLEDGE}（按需创建，见 §1.5.1）
    requirements/                 ← requirement scope 使用，本 scope 不写入
```

Init 在确定 `{BASE_DIR}` 与 `{KNOWLEDGE}` 后，按上表设置 `{WORKSPACE}`；**禁止**在 `ocspec-root` scope 下使用 `{OCSPEC_ROOT}/_workspace/`。

### 1.2.1 {OCSPEC_ROOT} 解析规则

**工作区根目录**：当前 Cursor 工作区根路径（通常含 `.cursor/` 或团队约定的 `repos.txt`）。

**Init 机械扫描（强制，先于一切路径决策）**

Scheduler **不得**凭记忆、推断或“工作区里好像没有”填写 `OCSPEC_CANDIDATES`。必须先在工作区根执行下列命令（或等价的 `dir` / `ls`），将**原始输出**写入 `[路径解析]`：

```powershell
# 推荐（可复现）：{COMMANDS_ROOT}/scripts/init-ocspec-scan.ps1 -WorkspaceRoot '<工作区根>'
Get-ChildItem -LiteralPath '<工作区根>' -Directory | Where-Object { $_.Name -like 'ocspec-*' } | Select-Object -ExpandProperty Name
```

| 机械扫描结果 | 允许的操作 |
|--------------|------------|
| 输出含 **≥1** 个目录名 | `OCSPEC_CANDIDATES` = 该列表；走优先级 1～3；**严禁** §1.2.2 兜底新建 |
| 输出为 **空**（无任何行） | 方可执行 §1.2.2 兜底新建 |
| 命令失败或未执行 | **Halt**，禁止兜底新建、禁止写入任何产出 |

**违规即 Init 失败**：机械扫描已列出至少一个 `ocspec-*`，却仍执行兜底新建第二个 `ocspec-*` → 视为严重错误，须删除误建目录并重新 Init。

**扫描候选登记**：

1. 由机械扫描输出得到 `OCSPEC_CANDIDATES`（**禁止**手写 `（无）` 而扫描结果实际非空）。
2. 将 `OCSPEC_SCAN_RAW`（命令原始输出）与 `OCSPEC_CANDIDATES` 写入 `[路径解析]` 摘要。

**绝对禁止（Scheduler / Agent / 步骤均适用）**：

- **禁止**在 `OCSPEC_CANDIDATES` **非空**时新建第二个 `ocspec-*` 目录（须使用已有候选）。
- **禁止**用代码库名、项目名、仓库名拼出 `ocspec-<项目名>`。
- **禁止**用 Cursor 工作区文件夹名拼出 `ocspec-<工作区名>`。
- **禁止**在 Init 之外、或已有 `ocspec-*` 时由 Agent/步骤自行 `mkdir` 新的 ocspec 根。
- 步骤中出现 `ocspec-<xxx>` 仅为**占位示意**，执行时必须替换为 Init 已解析的 `{OCSPEC_ROOT}` 实际路径。

**唯一例外**：`OCSPEC_CANDIDATES` 为 **0** 时，Scheduler 在 Init 阶段可按 **§1.2.2 兜底新建** 创建**一个** ocspec 根（全工作区生命周期内此后不得再建第二个）。

按以下优先级确定 `{OCSPEC_ROOT}`（不得跳过）：

> **使用者无需修改 SKILL 文件。** ocspec 目录名由工作区现状、用户在对话中的指定、或 §1.2.2 兜底规则决定。

| 优先级 | 条件 | 结果 |
|--------|------|------|
| 1 | 用户在 prompt 中指定了 `ocspec-<xxx>`、@ 引用了该目录、或路径中含 `ocspec-<xxx>/` | 从用户输入推导 `{OCSPEC_ROOT}` |
| 2 | `OCSPEC_CANDIDATES` 仅有 **1** 个 | **自动使用该目录**（默认路径，最常见） |
| 3 | `OCSPEC_CANDIDATES` 有 **多个** | **Halt**，列出候选目录，请用户在**本次对话**中指定（不要求改 SKILL） |
| 4 | `OCSPEC_CANDIDATES` 为 **0** | 执行 **§1.2.2 兜底新建**（Init 内允许新建**一个** ocspec 根） |

**已废弃（勿在 SKILL 中使用）**：`ocspec-root-name` frontmatter。若仍存在，Init 时**忽略**，仅作历史兼容说明。

**与自动创建的关系**：仅当 `{OCSPEC_ROOT}` 已按上表或 §1.2.2 确定后，才允许在该目录下创建 `knowledge/`、`requirements/` 或需求子目录；**禁止**在 `{OCSPEC_ROOT}` 之外再新建第二个 `ocspec-*` 目录。

#### 1.2.2 {OCSPEC_ROOT} 兜底新建（仅机械扫描输出为空）

**触发条件（须全部满足）**：

1. `OCSPEC_SCAN_RAW` 为**空**（§1.2.1 命令无任何输出）；且 `OCSPEC_CANDIDATES` 为 0。
2. **反例（绝对禁止）**：`OCSPEC_SCAN_RAW` 非空时，**不得**执行本节，不得再建任何 `ocspec-*`。
3. 当前为 Init 阶段，尚未写入业务产出文件。
4. 优先级 1～3 均未命中。

**目录名确定（按顺序，命中即停）**：

| 顺序 | 条件 | 新建目录名 |
|------|------|------------|
| A | 用户在本次 prompt 中明确给出新建名（如「创建 ocspec-prod」） | 该 `ocspec-<xxx>`（须符合 `ocspec-` 前缀） |
| B | 用户未指定名称 | 使用协议规定的**唯一兜底目录名**（见下「兜底目录名常量」；**不得**改用项目名/仓库名/工作区名） |

**兜底目录名常量**：仅当触发本节时，在工作区根新建**一个**目录，名称为 `ocspec-` + 固定后缀 `default`（全名由 Init 写入 `OCSPEC_ROOT`，不得按业务项目改名）。

**须创建的最小骨架**（在同一 Init 内完成）：

```text
ocspec-<选定名>/
  knowledge/          ← 供 ocspec-root scope 与知识库流水线
  requirements/       ← 供 requirement scope（可为空目录）
```

**Init 摘要须标注**：

```markdown
OCSPEC_ROOT_CREATED: yes（兜底新建，目录名: ocspec-<xxx>）
```

**兜底新建之后**：将该目录作为 `{OCSPEC_ROOT}`，继续 §1.2 BASE_DIR 与 §1.1.1 `{WORKSPACE}` 派生；后续执行**禁止**再建第二个 `ocspec-*`。

### 1.2 BASE_DIR 解析规则

**前置条件**：`{OCSPEC_ROOT}` 已按 §1.2.1 确定。

按以下优先级确定 `{BASE_DIR}`：

1. 用户在 prompt 中指定了**完整需求目录**路径（位于某 `ocspec-*/requirements/` 下）→ 直接作为 `{BASE_DIR}`，并反推 `{OCSPEC_ROOT}`
2. SKILL.md 的 `base-dir-scope` 决定扫描范围（未声明时默认为 `requirement`）：
   - `requirement`：在 `{OCSPEC_ROOT}/requirements/` 下扫描需求目录
   - `ocspec-root`：`{BASE_DIR}` = `{OCSPEC_ROOT}`（用于 knowledge 初始化类技能，见各 SKILL frontmatter）
3. 按 scope 扫描：
   - `requirement` scope：在 `{OCSPEC_ROOT}/requirements/` 下查找需求子目录；**仅 1 个** → 自动使用；**多个** → **Halt** 请用户指定
   - `ocspec-root` scope：`{BASE_DIR}` = `{OCSPEC_ROOT}`（不再扫描 requirements）
4. **需求目录不存在时自动创建**（仅 `requirement` scope，且已确定 `{OCSPEC_ROOT}`）：
   - 若 `{OCSPEC_ROOT}/requirements/` 不存在 → 创建该目录
   - 若其下无任何需求目录，或用户 prompt/材料表明为**新需求** → 创建 `{OCSPEC_ROOT}/requirements/<需求英文名>_<yyyymmdd>/`
   - `<需求英文名>`：从用户 prompt 或原始材料提取（简短英文、连字符分隔）；无法确定 → **Halt** 询问
   - `<yyyymmdd>`：当前日期
   - 创建后将该目录作为 `{BASE_DIR}`
5. 解析成功后，派生 §1.1 中其余变量；按 §1.1.1 根据 `base-dir-scope` 设置 `{WORKSPACE}`
6. 将所有步骤参数中的 `{变量名}` 替换为实际路径

### 1.3 落盘禁令（违反即视为 Init 失败）

| 禁止 | 必须 |
|------|------|
| `<工作区根>/_workspace/` | 按 scope 的 `{WORKSPACE}`（§1.1.1） |
| `{OCSPEC_ROOT}/_workspace/`（`ocspec-root` scope） | `{KNOWLEDGE}/_workspace/` |
| `<工作区根>/requirements/` | `{OCSPEC_ROOT}/requirements/` |
| `<工作区根>/knowledge/` | `{OCSPEC_ROOT}/knowledge/` |
| `<工作区根>/requirement/*.md` | `{REQ}/` 下 |
| 新建 `ocspec-<工作区文件夹名>/` 等未在 §1.2.1 选定的 ocspec 根 | 使用 §1.2.1 确定的 `{OCSPEC_ROOT}` |
| 在已选定 `{OCSPEC_ROOT}` 后再建第二个并行 `ocspec-*` 根 | 在既有 `{OCSPEC_ROOT}` 下扩展 `requirements/` |

### 1.4 路径解析摘要（Init 必须输出）

Init 完成后，Scheduler 在向用户说明或开始 Exec 前，须输出：

```markdown
[路径解析]
OCSPEC_SCAN_RAW: <机械扫描命令的原始输出，逐行列出目录名；空则写（空）>
OCSPEC_CANDIDATES: <与 SCAN_RAW 一致；禁止与 RAW 矛盾>
OCSPEC_ROOT_CREATED: <yes|no>（仅当 SCAN_RAW 为空时可为 yes）
OCSPEC_ROOT: <绝对或相对路径>
BASE_DIR:    <路径>
WORKSPACE:   <路径>
REQ:         <路径>
（若适用）KNOWLEDGE: <路径>
（若适用）CODE_KNOWLEDGE: <路径>
CUSTOM_KNOWLEDGE: <路径>
CUSTOM_KNOWLEDGE_STATUS: present | absent
```

若路径与 §1.3 禁令冲突，须先修正目录或 **Halt**，不得继续写入。

### 1.5 KNOWLEDGE 和 CODE_KNOWLEDGE 解析

- `{KNOWLEDGE}` 取 `{OCSPEC_ROOT}/knowledge/`（`requirement` scope 时 `{BASE_DIR}` 必位于 `{OCSPEC_ROOT}` 下）
- `{CODE_KNOWLEDGE}` 需要确定项目名：
  - 扫描 `{KNOWLEDGE}/code/` 下的子目录
  - 只有一个项目 → 自动使用
  - 有多个 → 从 SKILL.md 的上下文或用户 prompt 中推断
  - 无法确定 → 标注 `[项目上下文缺失]`，不阻塞执行

### 1.5.1 {CUSTOM_KNOWLEDGE} 解析（按需，可选）

**`custom/` 为项目按需使用的补充知识目录，不是必建目录。**

- `{CUSTOM_KNOWLEDGE}` = `{KNOWLEDGE}/custom/`
- **存在判定**（Init 须写入 `CUSTOM_KNOWLEDGE_STATUS`）：
  - `present`：目录存在，且其下（含子目录）至少有一个 `.md` 文件
  - `absent`：目录不存在、为空、或无可读 `.md` 文件
- **`absent` 时的行为**：
  - 步骤中声明的 `{CUSTOM_KNOWLEDGE}/` 引用**一律跳过**，**禁止 Halt**
  - Init **禁止**自动创建 `custom/`（含 §1.2.2 兜底新建骨架）
- **`present` 时的行为**：
  - 步骤须先读 `{CUSTOM_KNOWLEDGE}/README.md`（若存在）获取索引，再按需读取相关子目录
  - 所有技能对 `{CUSTOM_KNOWLEDGE}` **只读引用**，**禁止**写入、修改或融合更新
- **优先级**（与 `code/`、`application/`、`business/` 冲突时）：
  - 代码结构、接口、架构拓扑等事实 → 以技能产出的三层知识为准
  - 制度、术语、对接规范、历史说明等补充信息 → 以 `{CUSTOM_KNOWLEDGE}` 为准
- **融合隔离**：`project-archive` / `knowledge-fuser` 的 `target_files` **不得**包含 `{CUSTOM_KNOWLEDGE}/` 下任何路径

### 1.6 路径布局快速对照（Agent / Skill 共用）

供 Agent 与 Skill 在写文件前快速核对；解析规则、禁令与 Init 摘要格式仍以 §1.0~§1.5 为准。

#### requirement scope（需求 / 设计 / 任务 / 归档 / 编码 / 评审）

`base-dir-scope: requirement`（SKILL.md 未声明时默认为本 scope）。

| 变量 | 路径 |
|------|------|
| `{OCSPEC_ROOT}` | `<工作区根>/ocspec-<xxx>/`（§1.2.1 自动解析或用户在对话中指定） |
| `{BASE_DIR}` | `{OCSPEC_ROOT}/requirements/<需求英文名>_<yyyymmdd>/` |
| `{WORKSPACE}` | `{BASE_DIR}/_workspace/` |
| `{REQ}` | `{BASE_DIR}/requirement/` |
| `{DESIGN}` | `{BASE_DIR}/design/` |
| `{TASK}` | `{BASE_DIR}/task/` |
| `{ARCHIVE}` | `{BASE_DIR}/archive/` |
| `{KNOWLEDGE}` | `{OCSPEC_ROOT}/knowledge/` |
| `{CUSTOM_KNOWLEDGE}` | `{KNOWLEDGE}/custom/`（按需；`CUSTOM_KNOWLEDGE_STATUS=absent` 时跳过） |

**中间产物子目录（示例）**：`{WORKSPACE}/requirement/`、`design/`、`code/`、`review/`、`prototype/`、`input/` 等，由各 Skill 步骤声明，均须在 `{WORKSPACE}` 下。

**编码批次门禁（`fullstack-code-implementation` + `halt-policy: per-batch-mandatory`）**：产物路径与步骤见 `skills/fullstack-code-implementation/references/batch-gate-protocol.md`；停轮语义见 **§12**。

**终稿示例**：`{REQ}/requirement.md`、`{DESIGN}/backend-design.md`、`{TASK}/task-split.md`、`{ARCHIVE}/code-archive.md`。

#### ocspec-root scope（知识库初始化）

`base-dir-scope: ocspec-root`（如 `code-knowledge-init`、`application-knowledge-init`、`business-knowledge-init`）。

| 变量 | 路径 |
|------|------|
| `{OCSPEC_ROOT}` | `<工作区根>/ocspec-<xxx>/`（同上） |
| `{BASE_DIR}` | `{OCSPEC_ROOT}`（不扫描 `requirements/`） |
| `{WORKSPACE}` | `{KNOWLEDGE}/_workspace/` |
| `{KNOWLEDGE}` | `{OCSPEC_ROOT}/knowledge/` |
| `{CODE_KNOWLEDGE}` | `{KNOWLEDGE}/code/<项目名>/` |
| `{CUSTOM_KNOWLEDGE}` | `{KNOWLEDGE}/custom/`（按需；`CUSTOM_KNOWLEDGE_STATUS=absent` 时跳过） |

**中间产物子目录（示例）**：`{WORKSPACE}/code/`、`app/`、`biz/` 及其 `summaries/`。

**终稿示例**：`{KNOWLEDGE}/code/<项目名>/backend-project.md`、`{KNOWLEDGE}/application/`、`{KNOWLEDGE}/business/` 下各文档（以各 Skill 交付物为准）；`{CUSTOM_KNOWLEDGE}/` 为用户按需维护的补充文档（只读引用，非技能产出）。

#### 兜底新建（快速核对）

- `OCSPEC_CANDIDATES` 为 **0** → Init 可按 §1.2.2 新建**一个** `ocspec-*`（使用协议兜底目录名 + `knowledge/` + `requirements/`）
- `OCSPEC_CANDIDATES` **≥ 1** → **禁止**再建第二个 ocspec 根

#### 禁止（快速核对）

与 §1.3 一致，写文件前须确认未落入下列路径：

- 工作区根 `_workspace/`、工作区根 `requirements/`（应位于 `{OCSPEC_ROOT}` 下）
- 用项目名/仓库名/工作区文件夹名拼 `ocspec-<任意名>/`
- 在已选定 `{OCSPEC_ROOT}` 后再建并行 `ocspec-*`

#### Agent 写文件前（强制）

- 仅写入 Scheduler 在 Init 后注入并已替换变量的 `output_file`、`intake_output_file`、`status_report_file` 等路径。
- `requirement` scope：终稿须在 `{BASE_DIR}` 下对应子目录（`requirement/`、`design/`、`task/`、`archive/` 等）；中间产物须在 `{WORKSPACE}/` 下。
- `ocspec-root` scope：终稿须在 `{KNOWLEDGE}/` 约定路径下；中间产物须在 `{KNOWLEDGE}/_workspace/` 下（**禁止** `{OCSPEC_ROOT}/_workspace/`）。
- 若实际路径不在上述约定下，返回 **WARN**，说明应使用的路径及对应协议章节（§1.2 / §1.3 / §1.6），**不得**自行写入工作区根或其它 `ocspec-*` 目录。

---

## 2. 执行状态机

```
Init → Exec → Check → (决策分支)
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
            Next        Halt       Retry
              │           │           │
              ▼           ▼           ▼
            Exec      等待用户      Exec
                          │
                          ▼
                        Exec
```

## 3. 状态转移规则

| 当前状态 | 条件 | 下一状态 |
|----------|------|---------|
| Init | 读取 SKILL.md 的 phases/steps + 解析路径变量（§1.0~§1.4，输出 `[路径解析]`） | Exec（第一步） |
| Exec | Agent 返回 OK | Check |
| Exec | Agent 返回 WARN | Check（concerns 记入 pending） |
| Exec | Agent 返回 NEED_INFO | Halt |
| Exec | Agent 返回 BLOCKED | Halt |
| Check | 审查通过 + 无待确认项 | Next |
| Check | 审查通过 + 有待确认项 | 待确认项记入 pending-items |
| Next | `halt-policy: per-batch-mandatory` 且当前批次 Step 3 未完成或未获用户确认 | 见 §12.2（不得自动进入下一实例/批次） |
| Next | 当前步骤 `gate-mode: per-instance` 且 `halt-policy` 未声明或为 `phase-end` | 按步骤/phase 默认规则；多实例须逐步执行 |
| Next | 当前 phase 的 halt-after=true 且是 phase 最后一步 | Halt（输出交付报告） |
| Next | 还有下一步 | Exec |
| Next | 所有步骤完成 | 输出交付报告，结束 |
| Halt | 用户回复 | 根据回复修正 → Exec 或 Retry |

## 4. 步骤执行规则

### 4.1 读取步骤声明

支持两种模式，根据 SKILL.md 中步骤条目的格式自动判断：

**外置模式**（步骤条目以 `steps/` 开头）：
1. 从 SKILL.md 的当前 phase 中，获取当前步骤的文件路径（如 `steps/step-01-input-analysis.md`）
2. 读取该步骤文件，解析以下信息：
   - `agent`：要调用的 Agent 角色名（从"元信息"章节获取）
   - `checkpoint`：校验规则文件路径（从"元信息"章节获取）
   - `checkpoint-level`：审查级别（从"元信息"章节获取）
   - `type`：static 或 template（从"元信息"章节获取，默认 static）
   - `execution-mode`：agent 或 inline（从"元信息"章节获取，默认 agent）
   - 参数（从"参数"章节获取）：传递给 Agent 的所有参数
   - 执行指令（从"执行指令"章节获取）：作为 params.instructions 传递给 Agent
   - Summary 配置（从"Summary 配置"章节获取，若有）：摘要生成规则

**内联模式**（步骤条目直接包含 agent/params 等字段）：
从 SKILL.md 的 `phases[].steps[]` 中直接读取当前步骤的：
- `agent`：要调用的 Agent 角色名
- `params`：传递给 Agent 的参数
- `checkpoint`：校验规则文件路径
- `checkpoint-level`：审查级别（默认 L1，交付步骤用 L2）

### 4.2 执行步骤

Scheduler 根据步骤声明中的 `execution-mode` 选择执行路径（默认 `agent`）：

**`execution-mode: inline`（当前 session 内执行）**：

不经过 L2 Agent 层，Scheduler 直接在当前 session 中执行步骤指令：

1. 不读取 `{AGENTS_ROOT}/<agent>.md` 文件
2. 不构造 subagent prompt
3. 将步骤声明中的 `执行指令` 作为直接指令执行
4. `domain_context` 参数（若有）作为执行约束参考
5. 产出写入 `output_file`（console 类型仅在控制台输出）
6. 产出末尾仍需附加 STATUS_REPORT（格式见 §11），供状态机决策

**`execution-mode: agent`（委派 Agent 执行，默认模式）**：

1. 读取 `{AGENTS_ROOT}/<agent>.md` 获取角色定义
2. 将步骤声明中的 `params` 作为参数传递
3. 执行方式取决于环境（见 §6 环境适配）

### 4.3 读取状态报告

Agent 产出完成后，读取产出文件末尾的 STATUS_REPORT（格式见 §10 状态报告规范）。

### 4.4 Template 步骤执行（动态实例化）

当步骤声明中 `type: template` 时，Scheduler 不直接执行该 Agent，而是根据条目数据量和复杂度动态实例化为 N 个子执行单元。

#### 4.4.1 Step 文件中的 Template 声明字段

除 static 步骤的标准字段外，template 步骤需额外声明：

| 字段 | 说明 | 示例 |
|------|------|------|
| `type` | 固定为 `template` | `template` |
| `instance-by` | 按什么维度实例化 | `feature` |
| `instance-source` | 条目数据源（文件路径#章节锚点） | `{WORKSPACE}/design/01-input-summary.md#功能清单` |
| `context-budget` | 每个实例的上下文预算（字） | `2000` |
| `complexity-estimate` | 各复杂度等级的预估上下文消耗 | `{ simple: 400, medium: 800, complex: 1500, default: 800 }` |
| `output_file_per_instance` | 每个实例的产出路径模板 | `{WORKSPACE}/design/04-function-design-${instance-id}.md` |

#### 4.4.2 复杂度标注规则

条目的复杂度由上游步骤（通常是 Step 1 输入分析）在功能清单中标注。判断标准：

| 复杂度 | 判断条件 |
|--------|---------|
| simple | 单接口、无外部依赖、无状态流转 |
| medium | 2-3 个接口，或有简单状态流转，或有缓存 |
| complex | 涉及外部系统调用、异步/消息、状态机、多表事务 |

上游步骤产出的功能清单表格须包含复杂度和依赖列：

```markdown
| 序号 | 需求项 ID | 名称 | 模块 | 优先级 | 复杂度 | 依赖功能 | 摘要 |
|------|----------|------|------|--------|--------|---------|------|
| 1 | REQ-001 | 创建用户 | 用户管理 | P0 | simple | 无 | 单接口 CRUD |
| 2 | REQ-002 | 订单支付 | 订单 | P0 | complex | REQ-001(调用接口) | 外部支付系统+状态机+异步回调 |
```

#### 4.4.3 动态实例化 10 步流程

当 Scheduler 执行到 `type: template` 的步骤时，按以下流程执行：

**第 1 步：读取数据源**
从 `instance-source` 指定的文件和章节中提取条目列表，获取每个条目的复杂度标注和依赖功能标注。

**第 2 步：估算上下文消耗**
按 `complexity-estimate` 将每个条目映射为预估字数。未标注复杂度的条目使用 `default` 值。

**第 3 步：依赖感知分组**（在贪心装箱之前）
- 从功能清单的"依赖功能"列中构建依赖图
- 将有直接依赖关系的功能标记为"优先同组"
- 贪心装箱时，优先将"优先同组"的功能放入同一实例
- 如果依赖功能的复杂度之和超过 `context-budget`，无法放在同一实例，则在每个实例的 prompt 中注入被依赖功能的接口摘要：

```markdown
## 跨功能依赖（只读，不由本实例设计）
| 功能 | 接口 URL（预期） | HTTP 方法 | 说明 |
|------|----------------|----------|------|
```

**第 4 步：贪心装箱分组**
依次将条目放入当前实例，累计消耗超过 `context-budget` 时开新实例。若单个条目的预估消耗已超过预算，该条目独占一个实例。

**聚合优先原则**：若步骤声明中有 `grouping-strategy`，按其策略执行。核心思想是尽量减少实例数——多个 simple 功能应聚合到同一实例，而非每个功能一个实例。典型效果：
- 5~7 个 simple 功能 → 1 个实例
- 2~3 个 medium 功能 → 1 个实例
- 1 个 complex 功能 → 1 个实例
- 全部功能总消耗 ≤ context-budget → 不实例化，作为普通 static 步骤执行

**第 5 步：判断是否实例化**
- 分组结果只有 1 组 → 不实例化，作为普通 static 步骤执行
- 多组 → 触发实例化

**第 6 步：注入分配信息**
每个实例的 prompt 开头注入其负责的条目范围：

```markdown
你是 {agent-name} 的第 {M} 个实例（共 {N} 个）。
你负责处理以下功能的设计：[{功能名(复杂度)}, ...]。
其他功能由其他实例处理，你不需要关心。
产出章节编号从 §{起始编号} 开始。
```

**第 7 步：构造实例 prompt**
每个实例的完整 prompt 由以下部分组成：
1. 分配信息（第 6 步生成）
2. Agent 角色定义（从 `{AGENTS_ROOT}/<agent>.md` 读取）
3. 步骤声明中的执行指令
4. 输入文件内容（subagent 模式读 `input_files_subagent`，同 session 模式读 `input_files`）
5. Reference 片段（按 `reference_sections` 精确引用）
6. 跨功能依赖摘要（第 3 步中无法同组时生成）

**第 8 步：执行所有实例**
- subagent 模式（Kiro / Claude Code / Cursor / Trae SOLO）：每个实例通过 subagent 原语执行，上下文隔离；Trae SOLO 可多实例并行
- 同 session 模式（含 Trae 普通 Agent 模式）：串行执行，每个实例执行前明确声明"现在执行实例 M/N"
- 每个实例产出写入 `output_file_per_instance`（如 `04-function-design-1.md`）

**第 9 步：合并实例产出**
- 按原始条目顺序拼接各实例产出
- 调整章节编号使其连续（如 §3.2.1, §3.2.2, ...）
- 剥离每个实例产出中的 STATUS_REPORT
- 写入步骤声明中的 `output_file`（合并后的完整文件）
- 在合并后的文件末尾附加一个汇总的 STATUS_REPORT：
  - 如果所有实例都是 OK → 汇总为 OK
  - 如果任一实例是 WARN → 汇总为 WARN，合并所有 concerns
  - 如果任一实例是 NEED_INFO 或 BLOCKED → 汇总为对应状态码，合并所有缺失项/阻塞项

**第 10 步：生成 Summary + 运行 Checkpoint**
- 如果步骤声明中有 Summary 配置，对合并后的完整文件按配置提取 Summary
- 对合并后的文件执行 checkpoint 校验（含跨功能引用一致性检查）

#### 4.4.4 分组示例

以 `context-budget: 3000`、含依赖感知为例：

```
功能清单：
  REQ-001 创建用户    simple   → 400 字  依赖: 无
  REQ-002 查询用户    simple   → 400 字  依赖: 无
  REQ-003 用户审批    medium   → 1000 字 依赖: REQ-002(调用接口)
  REQ-004 订单支付    complex  → 2500 字 依赖: REQ-001(调用接口)
  REQ-005 订单退款    complex  → 2500 字 依赖: REQ-004(读取状态)
  REQ-006 数据导出    medium   → 1000 字 依赖: 无

依赖感知分组：
  REQ-002 + REQ-003 优先同组（REQ-003 依赖 REQ-002）
  REQ-004 + REQ-005 优先同组（REQ-005 依赖 REQ-004）
    → 但 2500+2500=5000 > 3000，无法同组
    → REQ-005 的 prompt 中注入 REQ-004 的接口摘要

最终分组（聚合优先）：
  实例 1：REQ-001(400) + REQ-002(400) + REQ-003(1000) + REQ-006(1000) = 2800 ≤ 3000 ✓
    （4 个 simple/medium 功能聚合，REQ-002 和 REQ-003 有依赖优先同组）
  实例 2：REQ-004(2500) = 2500 ≤ 3000 ✓
    （complex 独占）
  实例 3：REQ-005(2500) = 2500 ≤ 3000 ✓
    （complex 独占，注入 REQ-004 的接口摘要）

→ 6 个功能只产生 3 个实例，而非 6 个
```

#### 4.4.5 与状态机的衔接

Template 步骤在状态机中的行为：

```
Exec（template 步骤）
  ├→ 第 1~8 步：分组 + 逐实例执行
  ├→ 第 9 步：合并 → 生成汇总 STATUS_REPORT
  ├→ 第 10 步：Summary + Checkpoint
  └→ 进入 Check 状态（与 static 步骤相同）
```

从状态机视角看，template 步骤的 Exec 阶段内部包含了实例化、执行、合并的全过程，但对外仍然表现为一个步骤。Checkpoint 审查和后续逻辑与 static 步骤完全一致。

#### 4.4.6 固定实例模式（instance-mode: fixed）

当 Step 文件的元信息中声明 `instance-mode: fixed` 时，表示实例数量和分配在设计时已确定（如按文档类型固定 3/4/7 个实例），不需要动态分组。

**执行流程**：跳过 §4.4.3 的第 1~5 步（读取数据源 → 估算消耗 → 依赖感知分组 → 贪心装箱 → 判断是否实例化），直接从第 6 步开始：

| 步骤 | 操作 | 说明 |
|------|------|------|
| 第 6 步 | 注入分配信息 | 每个实例的 prompt 开头注入其负责的文档类型/知识库文件 |
| 第 7 步 | 构造实例 prompt | 分配信息 + Agent 定义 + 执行指令 + 输入文件 + Reference |
| 第 8 步 | 执行所有实例 | subagent 模式隔离执行 / 同 session 串行执行 |
| 第 9 步 | 汇总 STATUS_REPORT | 合并所有实例的状态码（规则同 §4.4.4） |
| 第 10 步 | Checkpoint | 对汇总后的产出执行 checkpoint 校验 |

**与动态模式的差异**：

| 维度 | 动态模式（默认） | 固定模式（instance-mode: fixed） |
|------|----------------|-------------------------------|
| 实例数 | 运行时由贪心装箱决定 | 设计时在 instance-source 中固定 |
| 分组逻辑 | 第 1~5 步完整执行 | 跳过第 1~5 步 |
| complexity-estimate 键名 | 标准等级（simple/medium/complex） | 允许使用实例名（如 backend-interface: 1500） |
| 合并产出 | 第 9 步按原始顺序拼接 + 调整章节编号 | 每个实例直接写入最终路径，第 9 步仅汇总 STATUS_REPORT |
| output_file | 合并后的完整文件 | 仅用于汇总 STATUS_REPORT（如 status-summary.md） |

**条件性实例**：固定模式下部分实例可能是条件性的（如 project-archive Step 5 的后端 3 个文件）。条件性实例通过 instructions 中的条件判断逻辑控制——先检查是否需要更新，不需要则直接返回 OK。条件性跳过的实例返回 OK（不是 SKIPPED），与汇总 STATUS_REPORT 规则兼容。

**适用场景**：
- 知识库文档生成（application Step 3 固定 3 实例、business Step 5 固定 4 实例）
- 代码扫描文档生成（code Step 3 固定 4 实例）
- 知识库融合更新（project-archive Step 5 固定 ≤7 实例，含条件性实例）

## 5. Checkpoint 审查

### 5.1 审查分级

| 级别 | 适用条件 | 审查维度 |
|------|---------|---------|
| L1 | 步骤声明中 checkpoint-level 为 L1 或未声明 | 结构 + 内容（非空、格式） |
| L1.5 | 步骤声明中 checkpoint-level 为 L1.5 | 按步骤 checkpoint 与技能 references（如 batch-gate-protocol §8、§12） |
| L2 | 步骤声明中 checkpoint-level 为 L2 | 全维度（结构 + 内容 + 一致性 + 完整性） |

### 5.2 对抗性审查

执行 checkpoint 时切换到审查者角色：
- 重新打开产出文件逐项核对，不凭记忆
- 对每项给出 ✅ 或 ❌
- 可自动修正的直接修正，不可修正的记入 pending-items

### 5.3 审查输出

L1：`审查(L1): X/Y 通过`（一行摘要）
L2：完整审查报告表格（维度 / 检查项 / 结果 / 说明）

## 6. 步骤摘要卡片

每步完成后输出：

```
<!-- STEP_SUMMARY: {step-index} -->
产出: {output_file} (已写入)
审查: X/Y 通过 ({L1|L2})
待确认项: N 条
状态: {status} → {自动继续|停下来}
<!-- /STEP_SUMMARY -->
```

## 7. 环境适配

### 7.1 执行模式总览

| 检测条件 | 执行模式 | 隔离级别 |
|----------|---------|---------|
| `execution-mode: inline` | inline 模式（所有编辑器一致）：当前 session 直接执行 | 无隔离 |
| 可使用 `invokeSubAgent` tool | subagent 模式（Kiro）：每步委派子 agent，注入角色定义 + 参数 | 硬隔离（独立上下文） |
| 可使用 `Task` tool | subagent 模式（Claude Code）：同上 | 硬隔离（独立进程） |
| SKILL.md 中显式声明调用 agent（Cursor / Trae SOLO 模式） | subagent 模式：通过 prompt 指令触发内置 subagent；Trae SOLO 可任务拆分 + 多子任务并行 | 半硬隔离（上下文隔离，受 API 用量限制） |
| 无上述条件（含 Trae 普通 Agent 模式：无 subagent 原语） | 同 session 模式：直接读取 agent 文件，在当前对话中执行 | 软隔离（对话历史累积） |

**inline 模式优先于其他模式判断**——当步骤声明 `execution-mode: inline` 时，不进入后续环境检测，直接在当前 session 执行。

### 7.2 subagent 模式的 prompt 构造

适用于 Kiro（invokeSubAgent）、Claude Code（Task）、Cursor、Trae SOLO 模式（显式 agent 调用 / 任务拆分）：

```
你是 {agent-name}。

{agent 文件的完整内容}

请按以下参数执行：
{params 的内容}
```

Cursor / Trae SOLO 注意事项：其 subagent 不是 spawn 新进程，但能隔离上下文。Trae SOLO 模式额外支持任务拆分与多子任务并行执行（适合多实例 / 多目标场景）。当 API 用量达到限制时可能无法触发 subagent，此时自动降级为同 session 模式。

Trae 普通 Agent 模式注意事项：无 subagent / 任务委派原语，按 §7.3 同 session 模式执行（软隔离）；多实例 / 多目标须串行化，并主动控制上下文（大仓库分模块时及时清理中间产物），避免上下文膨胀导致漏扫。

### 7.3 同 session 模式的执行

直接读取 agent 文件获取角色指令，按其中的工作流程执行，参数从步骤声明中获取。

### 7.4 inline 模式的使用指南

**何时使用 inline 模式**：

| 适用场景 | 特征 | 示例 |
|---------|------|------|
| 格式校验 | 确定性规则，无需推理 | 解析 TSV/CSV、检查字段 |
| 命令执行 | 脚本/命令驱动，结果明确 | git clone、bash 脚本 |
| 结果校验 | pass/fail 判定，无中间态 | 检查文件是否存在、验证 URL |

**何时不使用 inline 模式**：

| 不适用场景 | 原因 |
|-----------|------|
| 需要专业领域推理 | 架构分析、领域建模等需要角色化知识 |
| 需要上下文隔离 | template 步骤的大量数据需要分组处理 |
| 产出量大 | 可能撑爆当前 session 上下文的场景 |

**inline 模式与 agent 模式的核心差异**：

| 维度 | inline 模式 | agent 模式 |
|------|------------|-----------|
| 读取 agent 文件 | 不读取 | 读取 `{AGENTS_ROOT}/<agent>.md` |
| 构造 prompt | 直接执行指令 | 角色定义 + 参数 + 输入 + Reference |
| subagent 委派 | 永不委派 | 根据环境决定 |
| 上下文开销 | 最低（仅指令本身） | 较高（角色定义 + 输入注入） |
| Checkpoint 审查 | 仍然执行，与 agent 模式一致 | 仍然执行，与 inline 模式一致 |
| STATUS_REPORT | 仍需输出，与 agent 模式一致 | 仍需输出，与 inline 模式一致 |

## 8. 待确认项处理

### 8.1 来源

| 来源 | 提取内容 |
|------|---------|
| 产出正文 | `[需与产品确认]`、`[需人工确认]` 标记 |
| STATUS_REPORT concerns | WARN 的每条 concern |
| STATUS_REPORT missing-context | NEED_INFO 的每条缺失项 |
| STATUS_REPORT blocker | BLOCKED 的每条阻塞项 |
| checkpoint 失败项 | 不可自动修正的 ❌ 项 |

### 8.2 分类（交付报告中使用）

按优先级排列：
1. **需产品确认**：需求范围、业务规则
2. **需人工确认**：设计决策中存在多种方案
3. **设计存疑**：基于假设完成的部分
4. **开放问题**：与当前阶段直接相关的

已自动修正的不列入。无条目的分类不显示。

## 9. 交付报告

当所有步骤完成或 phase 的 halt-after 触发时，输出交付报告：

```
---
[交付报告] {skill-name} {phase-name} 完成

产出：{delivery files}
步骤审查结果：
  步骤 {N}: X/Y 通过 ({L1|L2})
  ...

## 待确认项
（按 §7.2 分类列出，无则显示"无"）

等待您的确认。
---
```

### 9.1 中间产出清理

用户确认交付后，Scheduler 必须删除 `{WORKSPACE}` 目录及其全部内容。该目录仅用于步骤间传递中间产出，终稿已落盘到正式路径，中间产出不再保留。

清理时机：用户对交付报告回复确认（或 Skill 所有 phase 全部完成且无 halt-after 阻塞）后，立即执行删除。

**误建目录处理**：若发现工作区根下存在误建的 `_workspace/`（不在任何 `{BASE_DIR}` 下），或违反 §1.3 的并行 `ocspec-*` 目录，清理时一并删除或提示用户迁移至 `{OCSPEC_ROOT}/requirements/` 后删除冗余目录。

## 10. 路径检测

Scheduler 在 Init 阶段解析 `{AGENTS_ROOT}` 与 `{COMMANDS_ROOT}`，供 §4 读取 agent 定义、§7 构造 prompt、以及各 Skill 读取本协议自身。

**三级回退策略**：项目级编辑器目录 → 工作区根目录 → 编辑器全局配置目录。三个 tier 按顺序依次检测；**同一 tier 内**按下列顺序检测，**使用第一个存在的目录**。

### 10.1 Tier 1 — 项目级编辑器目录

由 `spec-skills-refresh --scope project` 写入，路径相对于**当前工作区根目录**：

| 资源 | 检测顺序 |
|------|---------|
| `AGENTS_ROOT` | `.kiro/agents/` → `.cursor/agents/` → `.claude/agents/` → `.trae/agents/` → `.opencode/agents/` |
| `COMMANDS_ROOT` | `.kiro/commands/` → `.cursor/commands/` → `.claude/commands/` → `.trae/commands/` → `.opencode/commands/` |

### 10.2 Tier 2 — 工作区根目录

Tier 1 均未命中时，检测**当前工作区根目录**下的共享目录：

| 资源 | 检测顺序 |
|------|---------|
| `AGENTS_ROOT` | `agents/` |
| `COMMANDS_ROOT` | `commands/` |

> 适用于规范包源码直接作为工作区根目录、或手动将 `agents/`、`commands/` 放置在工作区根的场景。

### 10.3 Tier 3 — 编辑器全局配置目录

Tier 1、2 均未命中时，检测用户主目录下的编辑器全局配置（由 `spec-skills-refresh --scope global` 写入）。`~` 表示用户主目录（Windows 下通常为 `%USERPROFILE%`）：

| 资源 | 检测顺序 |
|------|---------|
| `AGENTS_ROOT` | `~/.kiro/agents/` → `~/.cursor/agents/` → `~/.claude/agents/` → `~/.trae/agents/` → `~/.config/opencode/agents/` |
| `COMMANDS_ROOT` | `~/.kiro/commands/` → `~/.cursor/commands/` → `~/.claude/commands/` → `~/.trae/commands/` → `~/.config/opencode/commands/` |

> OpenCode 的全局路径为 `~/.config/opencode/`，与其余编辑器的 `~/.xxx/` 命名不同，但 tier 内顺序与其它编辑器一致。

### 10.4 解析失败

若三个 tier 均未命中 `{COMMANDS_ROOT}/scheduler-protocol.md`：

1. 进入 **Halt**，明确提示路径解析失败
2. 建议用户执行 `spec-skills-refresh`（OpenCode 用户：`--tool opencode --scope project` 或 `--scope global`）
3. 不得跳过协议直接执行 Skill 步骤

### 10.5 设计原则

| Tier | 适用场景 | 优先级 |
|------|---------|--------|
| 1 项目级 | 多仓库工作区、团队统一配置、多编辑器并存 | 最高 |
| 2 工作区根目录 | 工作区根存在 `agents/`、`commands/`，或未做编辑器 sync | 中 |
| 3 编辑器全局 | 仅做了 `--scope global`、工作区无 `.xxx/` 且无 `commands/` | 最低 |

**注意**：Tier 内按固定编辑器顺序检测，命中即停止。若工作区同时存在多个编辑器目录（如既有 `.cursor/` 又有 `.opencode/`），会使用顺序靠前的那一个，与当前实际使用的编辑器可能不一致。**推荐**对主要使用的编辑器执行 project 级 sync，并保证其目录在检测顺序中可被正确命中。

## 11. 状态报告规范

### 11.1 格式

每个 Agent 在产出文件末尾附加：

```markdown
---
<!-- STATUS_REPORT -->
status: OK | WARN | NEED_INFO | BLOCKED
concerns:
  - "[WARN 时必填]"
missing-context:
  - "[NEED_INFO 时必填]"
blocker:
  - "[BLOCKED 时必填]"
---
```

### 11.2 状态码定义

| 状态码 | 含义 |
|--------|------|
| `OK` | 产出完成，无疑虑 |
| `WARN` | 产出完成，但有疑虑 |
| `NEED_INFO` | 缺少必要信息，无法完成 |
| `BLOCKED` | 遇到无法解决的问题 |

### 11.3 生命周期

- 中间产出：STATUS_REPORT 附加在文件末尾，供 Scheduler 读取
- 组装 Agent：合并中间产出时必须剥离所有 STATUS_REPORT 块
- 最终交付文档：不得包含任何 STATUS_REPORT
- 组装 Agent 自身的状态报告写入单独文件，不写入交付文档

## 12. Skill 扩展门禁（halt-policy，技能无关语义）

本节定义 **任意 Skill** 可通过 frontmatter 声明的停轮策略，以及 Scheduler 的通用义务。
**业务规则**（批次怎么拆、交付报告模板、评审清单等）须在对应技能的 `references/` 中维护，**不得**写入本节。

### 12.1 SKILL frontmatter 扩展字段（可选）

| 字段 | 示例值 | 含义 |
|------|--------|------|
| `halt-policy` | `none` / `phase-end` / `per-batch-mandatory` | 停轮策略；未声明时等同 `phase-end`（仅 phase `halt-after`） |
| `max-batches-per-turn` | `1` | 一次 user→assistant 回合最多完成的批次数/实例数 |
| `requires-user-confirm-between` | `batch_id` | 用户确认前不得启动下一单元 |

### 12.2 `halt-policy: per-batch-mandatory`（强制加载技能扩展）

当 SKILL.md 声明 `halt-policy: per-batch-mandatory` 时，Scheduler **必须**：

1. 在 Init 后、执行该技能步骤前，读取技能声明的扩展协议路径（推荐：`references/batch-gate-protocol.md`）。
2. 将扩展协议中的 **步骤顺序、产物路径、用户确认表** 与 §2~§9 通用状态机一并执行。
3. 每个批次/实例完成扩展协议规定的 **停轮步骤**（如编码技能的 Step 3）后，状态机 **必须 Halt**，不得 `Next` 到下一批次。
4. 遵守 `max-batches-per-turn: 1`（若声明）：同回合禁止第二个批次的 Exec。

**当前绑定技能**：

| 技能 | 扩展协议路径 |
|------|----------------|
| `fullstack-code-implementation` | `skills/fullstack-code-implementation/references/batch-gate-protocol.md` |

### 12.3 同 session 时的 Scheduler 义务（摘要）

执行 Agent 兼 Scheduler 时（Cursor 等），除 §2~§9 外须遵守：

- **停轮即终止**：完成扩展协议中的停轮步骤后，以该技能规定的交付报告结束本回合；其后禁止业务代码工具调用。
- **禁止自确认**：未获用户明确肯定前，不得将扩展协议中的确认标记（如 `user_confirmed`）置为 `yes`。
- **启动前读闸门**：若扩展协议要求闸门文件（如 `halt-gate.md`）且 `user_confirmed=no`，禁止启动下一单元 Step 1。

细则见各技能 `batch-gate-protocol.md`（如 §3、§9、§10、§12）。

### 12.4 与 §3 状态机的关系

```
… → Exec（当前批次末步，含 halt-after）
  → Check
  → Halt（输出技能扩展协议 §9 类交付报告 + 可选 HALT_GATE 注释）
  → 用户确认（技能扩展协议 §10）
  → Exec（下一批次/实例）…
```

§3 `Next` 在 `halt-policy: per-batch-mandatory` 下 **不得**跳过停轮步骤与 Halt。
