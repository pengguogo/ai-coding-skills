# Step 1: 单批次编码实现（template，按执行队列）

## 元信息

- agent: backend-coder
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1
- type: template
- instance-by: task-batch
- instance-source: `{WORKSPACE}/code/00-task-groups.md#执行队列`
- gate-mode: per-instance
- context-budget: 4000
- complexity-estimate: { simple: 800, medium: 2000, complex: 3500, default: 2000 }

## 参数

- input_files: [`{WORKSPACE}/code/00-task-groups.md`, `{TASK}/task-split.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{CODE_KNOWLEDGE}/backend-project.md`, `{CODE_KNOWLEDGE}/frontend-project.md`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- output_file: `{WORKSPACE}/code/01-task-group-execution-log.md`
- output_file_per_instance: `{WORKSPACE}/code/01-task-group-log-${instance-id}.md`
- reference_files: [`references/backend/coding-standard.md`, `references/frontend/coding_standard.md`, `references/frontend/component-patterns.md`, `references/frontend/api-integration.md`, `references/iOS/ios-coding-guideline.md`, `references/Android/android-coding-standard.md`, `references/HMOS/hmos-coding-standard.md`]
- task_scope: 当前批次 `${instance-id}`（`BE-{N}` / `FE-{N}` / `FE-shared` / `iOS-{N}` / `Android-{N}` / `HMOS-{N}` / `H5-{N}`）下的**单端**任务

## 执行指令

每个 template 实例 = 执行队列中的一行。`${instance-id}` 即 `batch_id`（如 `BE-2`、`FE-1`）。

### 0. 判定端与 Agent

| batch_id 前缀 | 端 | 实现 Agent | 规范 | 设计来源 |
|---------------|-----|------------|------|----------|
| `BE-` | backend | `backend-coder` | coding-standard.md | `backend-design.md` |
| `FE-` | frontend (PC Web) | `frontend-coder` | coding_standard.md 等 | `frontend-web.md` |
| `iOS-` | iOS | `ios-coder` | ios-coding-guideline.md 等 | `frontend-ios.md` |
| `Android-` | Android | `android-coder` | android-coding-standard.md 等 | `frontend-android.md` |
| `HMOS-` | HMOS（鸿蒙） | `hmos-coder` | hmos-coding-standard.md 等 | `frontend-hmos.md` |
| `H5-` | H5 | `frontend-coder` | coding_standard.md 等 | `frontend-h5.md` |

> 前端设计来源均经入口索引 `frontend-design.md` 定位到对应分端设计文件。Scheduler 委派时：前端(PC Web)/H5 批次使用 `frontend-coder` 角色；iOS 批次使用 `ios-coder` 角色；Android 批次使用 `android-coder` 角色；HMOS 批次使用 `hmos-coder` 角色。

### Phase A：实例上下文

1. 从 `00-task-groups.md` 读取 `${instance-id}`：`side`、`category_id`、名称、`tasks`、设计章节。
2. 从 `task-split.md` 仅展开**本端、本主分类**的任务详情。
3. 扫描仓库现状（后端包结构或前端组件/API 模式）。
4. **禁止**在本实例实现其他 `batch_id` 的任务。

### Phase B：后端批次（仅 `BE-{N}`）

对子任务 `{N}.{M}` 逐条实现：

- 参照 `references/backend/coding-standard.md`
- AI 标注 §6.5
- 记录 Done/Failed 与涉及文件

### Phase C：前端(PC Web)批次（仅 `FE-{N}` / `FE-shared`）

对该功能点/共享区下**全部**前端任务逐条实现：

- 参照前端 reference 与 `frontend-web.md` 对应功能点章节（经入口 `frontend-design.md` 定位）
- AI 标注 §2.3.5
- 记录 Done/Failed 与涉及文件

### Phase D：iOS 批次（仅 `iOS-{N}`）

对该功能点下**全部** iOS 任务逐条实现：

- 参照 `references/iOS/ios-coding-guideline.md` 及其按需加载的 reference（architecture.md、design-patterns.md、swift-objc-style.md、security-performance.md）
- 参照 `frontend-ios.md` 对应功能点章节（经入口 `frontend-design.md` 定位）
- 使用项目既有代码风格（ObjC/Swift，架构模式，前缀命名等）
- AI 标注 `// AI-Generate`
- 记录 Done/Failed 与涉及文件

### Phase E：Android 批次（仅 `Android-{N}`）

对该功能点下**全部** Android 任务逐条实现：

- 参照 `references/Android/android-coding-standard.md` 及其按需加载的 reference（official-android-architecture.md、design-patterns-examples.md、official-kotlin-style.md、official-android-java-style.md）
- 参照 `frontend-android.md` 对应功能点章节（经入口 `frontend-design.md` 定位）
- 使用项目既有代码风格（Java/Kotlin，架构模式，包结构等）
- AI 标注 `// AI-Generate`（Java/Kotlin）或 `<!-- AI-Generate -->`（XML）
- 记录 Done/Failed 与涉及文件

### Phase F：HMOS（鸿蒙）批次（仅 `HMOS-{N}`）

对该功能点下**全部** HMOS 任务逐条实现：

- 参照 `references/HMOS/hmos-coding-standard.md` 及其按需加载的 reference（architecture.md、reference.md、design-patterns.md、security-performance.md）
- 参照 `frontend-hmos.md` 对应功能点章节（经入口 `frontend-design.md` 定位）
- 使用项目既有 ArkTS/ArkUI 代码风格（Stage 模型、状态装饰器、目录/模块约定）
- AI 标注 `// AI-Generate`
- 记录 Done/Failed 与涉及文件

### Phase G：H5 批次（仅 `H5-{N}`）

对该功能点下**全部** H5 任务逐条实现：

- 参照前端 reference 与 `frontend-h5.md` 对应功能点章节（经入口 `frontend-design.md` 定位）
- 覆盖移动端适配、JSBridge 调用（如涉及）与弱网/性能处理
- AI 标注 §2.3.5
- 记录 Done/Failed 与涉及文件

### 实例产出结构

```markdown
# 批次 ${instance-id} 编码日志 · {名称}（{side}）

## 1. 本批次范围
- batch_id: ${instance-id}
- side: backend | frontend
- category_id: {N}
- 任务列表：...

## 2. 任务执行记录
| 任务 ID / 标题 | 描述 | 状态 | 涉及文件 |

## 3. 文件变更清单
## 4. 失败与待确认
## 5. 下一环节
→ Step 2 小节评审 → Step 3 停轮闸门
```

### 关键约束

- **单端单批次**：每个批次仅实现其所属端的代码，不得跨端（`BE-*` / `FE-*` / `iOS-*` / `Android-*` / `HMOS-*` / `H5-*` 各自互不越界，即某端批次不得写其他端代码）。
- **禁止跨批次**修改。
- 不执行编译/构建（Step 4）。

### 批次边界与闸门（强制，batch-gate-protocol §3）

1. **Step 1 开始前**（inline）：读取 `{WORKSPACE}/code/section-review-progress.tsv` 与 `{WORKSPACE}/code/halt-gate.md`（若存在）。
   - 若 `halt-gate.md` 存在且 `user_confirmed=no` → **停止**，不得执行本步骤；提示用户先确认 `awaiting_batch_id`。
   - 若上一非 skipped 批次 `user_confirmed != yes` 或 `gate_status != CLEARED` → **停止**。
2. 本步骤**只执行 Scheduler 注入的一个** `${instance-id}`，不得自行选择队列中下一批。
3. 本步骤完成后**仅**进入同 `batch_id` 的 Step 2 → Step 3；**禁止**同回合启动下一 batch 的 Step 1。
