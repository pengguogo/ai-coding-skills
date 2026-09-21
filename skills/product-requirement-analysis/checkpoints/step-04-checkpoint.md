# Checkpoint: Step 4 知识库同步与过程产出清理

> **审查级别**：L1 — 确认已提示同步、过程产出已清理、持久产出未被误删；push 模式下确认 git 已提交终稿与事实源归档。
> **强制停止点**：Phase `kb-sync` 的 halt-after；首次须展示同步提示并等待用户确认。

## 审查时需打开的文件 / 命令

- `{REQ}/requirement.md`（须仍存在）
- `{BASE_DIR}/sources/fact-source.md`（须仍存在）
- Pin / intake（清理前快照或控制台中的分支信息）
- 文件系统：确认清理路径不存在、持久路径仍存在
- （push 模式）`git -C {OCSPEC_ROOT} log -1 --oneline` 与 `git status`

## Phase A — 同步提示

- [ ] 已向用户展示同步提示（终稿路径、事实源归档路径、分支、清理清单、确认/暂不同步选项）
- [ ] 若 Step 3 有 `[知识库待补充]` 主题汇总，已在提示中列出
- [ ] 用户未确认前 **未** 执行 git push / commit
- [ ] 用户回复已解析为 `SYNC_MODE: push` 或 `skip-push`

## Phase B — 过程产出清理（强制）

- [ ] `{BASE_DIR}/_workspace/` **不存在**
- [ ] `{KNOWLEDGE}/_workspace/product-req/` **不存在**
- [ ] `{BASE_DIR}/` 下无 brainstorm / intake / modeling / fact-source 中间副本 / verify-report / status-report 残留
- [ ] 控制台或 status 含 `CLEANUP: ok` 与删除清单

## 持久产出保留检查（强制，防误删）

- [ ] `{REQ}/requirement.md` **仍存在**
- [ ] `{BASE_DIR}/sources/fact-source.md` **仍存在**
- [ ] `{BASE_DIR}/sources/media/`（若 Step 3 有图片归档）**仍存在**
- [ ] 终稿 §1.1「事实源索引」行指向的相对路径 `../sources/fact-source.md` 可解析（未因清理断链）

## Phase C — Git 同步（push 模式）

- [ ] `git status` staged 含 `requirements/.../requirement/requirement.md`
- [ ] `git status` staged 含 `requirements/.../sources/`（事实源归档，含可选 `media/`）
- [ ] staged **不含** `_workspace`、brainstorm、intake、modeling、verify-report、status-report
- [ ] 未使用 `git add .`（逐条 add 持久产出）
- [ ] commit 已创建；push 至 `KNOWLEDGE_REPO_BRANCH` 成功

## skip-push 模式

- [ ] 清理已完成（同 Phase B）
- [ ] 持久产出保留检查通过
- [ ] **未** 误执行 push

## 反模式扫描

- [ ] 未提示同步即 push
- [ ] commit 含 `_workspace/` 或过程产出
- [ ] **误删 `{BASE_DIR}/sources/` 或 `{BASE_DIR}/requirement/`**
- [ ] 漏提交 `sources/`（终稿事实源索引指向不存在的文件）
- [ ] Step 4 结束后过程文件仍残留
- [ ] `git push --force`

## 待确认项提取

- CLEANUP 未通过
- 持久产出保留检查未通过（尤其 `sources/` 缺失）
- push 失败 / 鉴权失败
- 用户未回复同步意图（仍在 NEED_INFO）
- Step 3 交接的 `[知识库待补充]` 主题（供后续知识库补充，不阻塞）
