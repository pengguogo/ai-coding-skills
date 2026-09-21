# Step 0: 解析评审批次（后端 / 前端各自独立）

## 元信息

- agent: backend-coder
- execution-mode: inline
- checkpoint: checkpoints/step-00-checkpoint.md
- checkpoint-level: L1
- type: static

## 参数

- input_files: [`{TASK}/task-split.md`]
- output_file: `{WORKSPACE}/code/00-task-groups.md`
- progress_file: `{WORKSPACE}/code/section-review-progress.tsv`
- progress_template: `references/section-review-progress-template.tsv`
- review_log_file: `{WORKSPACE}/review/review-log.md`
- review_log_template: `skills/fullstack-code-review/references/common/review-log-template.md`

## 执行指令

从 `task-split.md` 的**后端任务清单**、**前端(PC Web)任务清单**以及各移动端任务清单（**iOS / Android / HMOS / H5**，仅存在时）分别解析主分类，各自 1 个 `N` = 1 个评审批次。各端设计来源指向对应分端设计文件（`frontend-web.md` / `frontend-ios.md` / `frontend-android.md` / `frontend-hmos.md` / `frontend-h5.md`，经入口 `frontend-design.md` 定位）。**禁止**将各端任务跨端合并。

### 1. 后端主分类（独立）

1. 定位「后端任务清单」章节（至「前端任务」章节之前）。
2. 提取所有 `## {N}. {标题}`（`N` 为正整数）→ 批次 ID **`BE-{N}`**。
3. 收集该主分类下子任务 `{N}.{M}` 及描述。
4. **禁止**将 `{N}.{M}` 当作独立批次；**禁止**在本步骤解析前端章节。

### 2. 前端主分类（独立）

1. 定位「前端任务清单」章节。
2. 按下列标题模式提取主分类（`N` 为正整数）→ 批次 ID **`FE-{N}`**：
   - `## 功能点 {N}:` / `## 功能点{N}:`
   - 若前端也使用 `## {N}. {标题}`，同样视为 `FE-{N}`
3. 收集该功能点/主分类下的全部任务条目（含 File/Work 结构或列表项）。
4. **`## 共享资源任务`**（或等价标题）→ 批次 ID **`FE-shared`**，`category_id` 填 `shared`。
5. **禁止**将前端任务归入 `BE-{N}`。

### 3. iOS 主分类（独立）

1. 定位「iOS 任务清单」章节（若存在）。
2. 按标题模式提取主分类（`N` 为正整数）→ 批次 ID **`iOS-{N}`**：
   - `## 功能点 {N}:` / `## {N}. {标题}`
3. 收集该功能点/主分类下的全部任务条目。
4. **禁止**将 iOS 任务归入 `BE-{N}` 或 `FE-{N}`。

### 4. Android 主分类（独立）

1. 定位「Android 任务清单」章节（若存在）。
2. 按标题模式提取主分类（`N` 为正整数）→ 批次 ID **`Android-{N}`**：
   - `## 功能点 {N}:` / `## {N}. {标题}`
3. 收集该功能点/主分类下的全部任务条目。
4. **禁止**将 Android 任务归入 `BE-{N}` 或 `FE-{N}` 或 `iOS-{N}`。

### 5. HMOS 主分类（独立）

1. 定位「HMOS 任务清单」章节（若存在）。
2. 按标题模式提取主分类（`N` 为正整数）→ 批次 ID **`HMOS-{N}`**：
   - `## 功能点 {N}:` / `## {N}. {标题}`
3. 收集该功能点/主分类下的全部任务条目。
4. **禁止**将 HMOS 任务归入 `BE-{N}` 或 `FE-{N}` 或 `iOS-{N}` 或 `Android-{N}`。

### 6. H5 主分类（独立）

1. 定位「H5 任务清单」章节（若存在）。
2. 按标题模式提取主分类（`N` 为正整数）→ 批次 ID **`H5-{N}`**：
   - `## 功能点 {N}:` / `## {N}. {标题}`
3. 收集该功能点/主分类下的全部任务条目。
4. **禁止**将 H5 任务归入 `BE-{N}` 或 `FE-{N}` 或 `iOS-{N}` 或 `Android-{N}` 或 `HMOS-{N}`。

### 7. 设计文件（按端分别填写，指向分端设计文件）

前端设计以入口索引 `frontend-design.md` 定位各分端设计文件；各批次 `design_section` 指向对应的**分端设计文件**及功能点，而非 `frontend-design.md` 内嵌章节。

| 批次 | design_section |
|------|----------------|
| `BE-{N}` | `backend-design.md` 对应章节锚点 |
| `FE-{N}` / `FE-shared` | `frontend-web.md` 对应功能点锚点 |
| `iOS-{N}` | `frontend-ios.md` 对应功能点锚点 |
| `Android-{N}` | `frontend-android.md` 对应功能点锚点 |
| `HMOS-{N}` | `frontend-hmos.md` 对应功能点锚点 |
| `H5-{N}` | `frontend-h5.md` 对应功能点锚点 |

> 某目标端未生成分端设计文件（对应任务清单章节缺失）时，不为该端解析批次。

### 8. 执行队列（全局顺序）

生成 `#执行队列` 表，每行对应 Step 1/2 的一个 template 实例：

**默认顺序（无依赖表覆盖时）**：

1. 所有后端批次按 `N` 升序：`BE-1` → `BE-2` → … → `BE-{max}`
2. 所有前端批次：`FE-1` → `FE-2` → … → `FE-{max}` → `FE-shared`（若有）
3. 所有 iOS 批次：`iOS-1` → `iOS-2` → … → `iOS-{max}`（若有）
4. 所有 Android 批次：`Android-1` → `Android-2` → … → `Android-{max}`（若有）
5. 所有 HMOS 批次：`HMOS-1` → `HMOS-2` → … → `HMOS-{max}`（若有）
6. 所有 H5 批次：`H5-1` → `H5-2` → … → `H5-{max}`（若有）

**依赖表覆盖**（`task-split.md`「依赖关系」存在时）：

- 若某 `FE-{N}` 的前置含 `BE-{M}.x`，则 `FE-{N}` 必须排在对应 `BE-{M}` **之后**（可仍在全部后端批次之后，或紧接该 `BE-M` 之后，以不违反任一前置为准）。
- 不得在 `BE-{M}` 之前执行依赖其接口的 `FE-{N}`。
- 重排后写入 `执行队列` 的 `seq` 列（1..总批次数）。

### 9. 初始化进度与评审日志

1. 从 `progress_template` 复制表头，为**执行队列每一行**写一行（`batch_id`、`side`、`category_id`、`name`、`tasks`、`gate_status=PENDING`）。
2. 若 `review_log_file` 不存在，按 `review_log_template` 创建初始结构。

### 产出结构（00-task-groups.md）

```markdown
# 评审批次清单（后端 / 前端各自独立）

## 解析摘要
- 后端主分类数：{count_be}（BE-1 … BE-{max}）
- 前端主分类数：{count_fe}（含 FE-shared）
- 执行队列总批次数：{total}
- 来源：{TASK}/task-split.md

## 后端主分类表

| batch_id | category_id | 名称 | 子任务 |
|----------|-------------|------|--------|
| BE-1 | 1 | ... | 1.1, 1.2 |

## 前端主分类表

| batch_id | category_id | 名称 | 任务摘要 |
|----------|-------------|------|----------|
| FE-1 | 1 | ... | ... |

## iOS 主分类表（若有）

| batch_id | category_id | 名称 | 任务摘要 |
|----------|-------------|------|----------|
| iOS-1 | 1 | ... | ... |

## Android 主分类表（若有）

| batch_id | category_id | 名称 | 任务摘要 |
|----------|-------------|------|----------|
| Android-1 | 1 | ... | ... |

## HMOS 主分类表（若有）

| batch_id | category_id | 名称 | 任务摘要 |
|----------|-------------|------|----------|
| HMOS-1 | 1 | ... | ... |

## H5 主分类表（若有）

| batch_id | category_id | 名称 | 任务摘要 |
|----------|-------------|------|----------|
| H5-1 | 1 | ... | ... |

## 执行队列

| seq | batch_id | side | 名称 | 说明 |
|-----|----------|------|------|------|
| 1 | BE-1 | backend | ... | 仅本批次后端子任务 |
| 2 | BE-2 | backend | ... | |
| 3 | FE-1 | frontend | ... | 仅本批次前端任务 |

## 依赖重排说明（如有）
```

### 关键约束

- 本步骤**不编写业务代码**。
- 完成后 Scheduler 按执行队列 `seq=1` 的 `batch_id` 启动 Step 1 首实例（通常为 `BE-1`）。
