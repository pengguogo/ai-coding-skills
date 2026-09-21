# Step 4: 知识库同步与过程产出清理 [强制停止]

## 元信息

- agent: ops-executor
- checkpoint: checkpoints/step-04-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{REQ}/requirement.md`, `{BASE_DIR}/sources/fact-source.md`, `{KNOWLEDGE}/_workspace/product-req/00-ocspec-pin.md`, `{KNOWLEDGE}/_workspace/product-req/00-product-intake.md`]
- output_file: `(console)`
- reference_files: [`references/knowledge-requirement-sync-guide.md`, `references/knowledge-base-pull-guide.md`]
- status_report_file: `{BASE_DIR}/_workspace/requirement/04-sync-status-report.md`（Phase A 写入；Phase B 清理时随 `_workspace` 删除）

## 前置条件（Scheduler 强制）

- Step 3 已完成，`{REQ}/requirement.md` 存在且已通过 L2 审查
- `{BASE_DIR}/sources/fact-source.md` 存在（Step 3 §5.5 归档产出）
- 用户已对 Step 3 交付报告确认（或明确要求进入同步）
- **禁止**在 Step 3 完成时自动 push 或自动清理 `{BASE_DIR}/_workspace/`

## 执行指令

分 Phase A → B → (C) 顺序执行。完整规范见 `references/knowledge-requirement-sync-guide.md`。

### Phase A：强制同步提示（首次 Exec 或尚未收到用户确认时）

1. 读取 Pin / intake 中的 `KNOWLEDGE_REPO_BRANCH`、`REQUIREMENT_SLUG`、`OCSPEC_ROOT_PIN`
2. 输出 `knowledge-requirement-sync-guide.md` 中的**同步提示模板**（含终稿路径、事实源归档路径、分支、清理清单）
3. 若 Step 3 状态报告中有 `[知识库待补充]` 主题汇总，在提示中一并列出，供用户判断是否需要后续补充知识库
4. `status: NEED_INFO`，**Halt**；**禁止**本轮清理或 git 操作
5. 将 `SYNC_PROMPT_SHOWN: yes` 写入 `04-sync-status-report.md`

**Resume 后**根据用户回复设置 `SYNC_MODE`：

- 确认同步 → `push`
- 暂不同步 → `skip-push`
- 无法识别 → 再次 Phase A 提示

### Phase B：强制清理过程产出（用户回复后，commit 前必做）

**无论 `SYNC_MODE` 为 push 或 skip-push，均须执行。**

1. 删除 `{BASE_DIR}/_workspace/`（整目录）
2. 删除 `{KNOWLEDGE}/_workspace/product-req/`（整目录）
3. 若 `{KNOWLEDGE}/_workspace/` 已空，删除空目录
4. 执行残留扫描（见 sync 指南）；不通过则继续删或 BLOCKED
5. 控制台输出 `DELETED:` 清单与 `CLEANUP: ok`

**清理范围硬边界**：**禁止**删除 `{BASE_DIR}/requirement/` 与 `{BASE_DIR}/sources/`（含 `fact-source.md`、`media/`）——两者均为持久交付物。清理前须确认待删路径以 `_workspace` 结尾。

**禁止**在清理完成前 `git add` / `commit` / `push`。

### Phase C：Git 同步（仅 `SYNC_MODE: push`）

1. `git -C {OCSPEC_ROOT} pull --ff-only`（失败则 BLOCKED，提示用户处理）
2. 添加**持久产出**（仅这两类，逐条 add，不用 `add .`）：
   - `git -C {OCSPEC_ROOT} add requirements/<slug>_<date>/requirement/requirement.md`（终稿）
   - `git -C {OCSPEC_ROOT} add requirements/<slug>_<date>/sources/`（事实源归档 `fact-source.md`；若有图片归档则含 `media/`）
3. `git status` — staged **不得**含 `_workspace`、brainstorm、intake、modeling、fact-source 中间副本、verify-report、status-report
4. `git commit`（消息见 sync 指南）
5. `git push origin {KNOWLEDGE_REPO_BRANCH}`
6. 输出 Step 4 完成摘要；`status: OK`

### `SYNC_MODE: skip-push`

- Phase B 完成后输出摘要，`GIT_COMMIT: skipped`，`GIT_PUSH: skipped`，`status: OK`
- 仍须确认过程产出已清理

### 关键约束

- **强制提示**：未展示 Phase A 模板并获用户回复前，不得 push
- **先清理后提交**：push 模式下 commit 前 `_workspace` 必须已不存在
- **勿残留**：Step 4 结束时 `{BASE_DIR}` 下仅保留 `requirement/requirement.md` 与 `sources/`（事实源归档，含可选 `media/`）
- **勿误删 sources**：`{BASE_DIR}/sources/` 是持久产出，**不属于**清理范围；Phase B 只删 `_workspace/` 与 Pin 会话目录

**Step 4 完成后**，本技能流程结束；终稿与事实源归档已在仓库本地路径，push 模式下已同步远程。
