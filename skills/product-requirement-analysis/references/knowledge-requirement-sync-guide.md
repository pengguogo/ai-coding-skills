# 需求终稿同步知识库规范（Step 4）

Step 3 成稿并经用户审查通过后，**必须**进入 Step 4：**强制提示同步** → 用户确认 → **清理过程产出** → `git commit` / `push` 终稿与事实源归档到 `ocspec-*` 仓库。

## 目标

| 项 | 说明 |
|----|------|
| **同步对象** | `{REQ}/requirement.md` 与 `{BASE_DIR}/sources/`（事实源归档 `fact-source.md`，含可选 `media/`） |
| **同步方式** | 在 `{OCSPEC_ROOT}` git 仓库内 add / commit / push 至 Step 0 指定的 `KNOWLEDGE_REPO_BRANCH` |
| **禁止入库** | 任何 `_workspace/`、status report、brainstorm / intake / modeling / fact-source 中间副本 / verify-report、Pin 会话文件 |

> **持久产出与过程产出的边界**：`{BASE_DIR}/sources/` 是**持久交付物**，须一并入库、**不属于**清理范围。漏提交会导致终稿 §1.1「事实源索引」指向不存在的文件。

## 强制提示（Phase A，必须 Halt）

Step 4 **首次 Exec 仅输出同步提示**，`status: NEED_INFO`，**禁止**在本轮执行清理或 git 操作。

```text
=== 需求已完成 — 请确认是否同步到知识库仓库 ===

终稿路径：
  {REQ}/requirement.md

事实源归档：
  {BASE_DIR}/sources/fact-source.md

目标仓库：
  {OCSPEC_ROOT}
  分支：{KNOWLEDGE_REPO_BRANCH}

确认「同步」后将依次执行：
  1. 强制清理全部过程产出（见下清单，提交前完成）
  2. git add 持久产出（requirement.md + sources/）
  3. git commit
  4. git push origin {KNOWLEDGE_REPO_BRANCH}

过程产出清理清单（同步/跳过同步均执行，确保勿残留）：
  - {BASE_DIR}/_workspace/
  - {KNOWLEDGE}/_workspace/product-req/

保留不删（持久交付物）：
  - {BASE_DIR}/requirement/
  - {BASE_DIR}/sources/

（若 Step 3 有 [知识库待补充] 主题，在此列出供后续补充知识库参考）

回复示例：
  - 「确认同步」→ 清理 + commit + push
  - 「暂不同步」→ 仅清理过程产出，不 push
```

**禁止**跳过本提示直接 push；**禁止**在用户未回复时假定同意。

## 用户确认语义

| 用户回复 | 行为 |
|---------|------|
| 确认同步 / 同步 / 确认 push / yes | `SYNC_MODE: push` → Phase B 清理 → Phase C commit + push |
| 暂不同步 / 跳过同步 / 仅清理 | `SYNC_MODE: skip-push` → Phase B 清理 → 结束（不 commit） |
| 其它 | 再次 NEED_INFO，重申选项 |

## 强制清理（Phase B，提交前必做）

**顺序：先清理，后 git add**（push 模式下）。

### 清理范围

| 路径 | 说明 |
|------|------|
| `{BASE_DIR}/_workspace/` | Step 0 / 1 / 2 / 3 中间产出（brainstorm、intake、modeling、fact-source 中间副本、verify-report、status report 等） |
| `{KNOWLEDGE}/_workspace/product-req/` | Step 0 Intake / Pin / 就绪度会话文件 |

### 清理规则

1. **递归删除**上述目录；若目录不存在则跳过
2. 删除后 **验证**：上述路径不得存在；`{BASE_DIR}/` 下除 `requirement/` 与 `sources/` 外不得留过程目录
3. 控制台输出 **已删除路径清单**
4. **禁止**删除 `{REQ}/requirement.md` 及 `{BASE_DIR}/requirement/` 目录
5. **禁止**删除 `{BASE_DIR}/sources/`（含 `fact-source.md`、`media/`）——持久交付物，须入库
6. **禁止**删除 `{KNOWLEDGE}/business|application|code/` 等正式知识库内容
7. 若 `{KNOWLEDGE}/_workspace/` 清空后为空目录，可删除该空目录
8. 删除前确认待删路径以 `_workspace` 结尾，避免误伤持久目录

### 残留扫描（清理后）

在 `{OCSPEC_ROOT}` 下检查本次 `{BASE_DIR}` 相关路径，**不得**存在：

- `*_status-report.md`、`00-brainstorm-state.md`、`00-brainstorm.md`、`01-intake.md`、`01-modeling.md`、`01-fact-source.md`、`02-verify-report.md`
- 任意 `_workspace/` 目录（在本次需求 `{BASE_DIR}` 下）

**同时须确认持久产出仍存在**（防误删）：

- `{REQ}/requirement.md`
- `{BASE_DIR}/sources/fact-source.md`

发现残留 → 继续删除直至通过；持久产出缺失 → BLOCKED；无法安全删除 → BLOCKED。

## Git 同步（Phase C，仅 `SYNC_MODE: push`）

**前置**：Phase B 清理验证通过；Pin 或 Step 0 记录中有 `KNOWLEDGE_REPO_BRANCH`。

```bash
git -C {OCSPEC_ROOT} status
git -C {OCSPEC_ROOT} add requirements/<slug>_<date>/requirement/requirement.md
git -C {OCSPEC_ROOT} add requirements/<slug>_<date>/sources/
git -C {OCSPEC_ROOT} status   # 确认 staged 仅终稿 + sources/，无 _workspace
git -C {OCSPEC_ROOT} commit -m "docs(requirements): add <slug> requirement"
git -C {OCSPEC_ROOT} push origin {KNOWLEDGE_REPO_BRANCH}
```

### 安全边界

- **禁止** `git add` 整个 `{BASE_DIR}` 或 `_workspace`
- **禁止** `git add .`（须逐条 add 持久产出）
- **禁止** `git push --force`
- **禁止** `git reset --hard`、修改 `.gitconfig`
- staged 含 `_workspace` 或中间稿 → **中止 commit**，回到 Phase B
- staged **缺** `sources/` → 补 add；漏提交会使终稿事实源索引断链
- push 前 `git pull --ff-only`（若远程有更新）

### Commit 信息模板

```
docs(requirements): add <REQUIREMENT_SLUG> requirement spec

Product requirement analysis deliverable.
Path: requirements/<slug>_<date>/requirement/requirement.md
Fact source: requirements/<slug>_<date>/sources/fact-source.md
```

## 控制台完成摘要

```text
=== Step 4 完成 ===
SYNC_MODE: push | skip-push
CLEANUP: ok
DELETED:
  - ...
RETAINED:
  - requirements/<slug>_<date>/requirement/requirement.md
  - requirements/<slug>_<date>/sources/
GIT_COMMIT: <hash> | (skipped)
GIT_PUSH: ok | (skipped)
REQUIREMENT_PATH: requirements/<slug>_<date>/requirement/requirement.md
FACT_SOURCE_PATH: requirements/<slug>_<date>/sources/fact-source.md
KB_GAPS: <[知识库待补充] 主题清单 或 （无）>
```

## 与 scheduler-protocol §9.1 的关系

本技能 **Step 4 替代** 通用「用户确认后立即删除 `{WORKSPACE}`」的时机：

- Step 3 交付 Halt 后 **不得**提前删除 `{BASE_DIR}/_workspace/`
- **Step 4 Phase B** 统一清理；清理完成前 **不得** commit
- 清理**不含** `{BASE_DIR}/sources/`——该目录与 `requirement/` 同为持久交付物
