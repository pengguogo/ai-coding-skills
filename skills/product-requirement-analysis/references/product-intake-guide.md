# 产品统一 Intake 规范



Step 0 Phase A 一次性收集输入；**功能向澄清在 Step 0 Phase D～F 完成**（与拉库同一步骤）。



## 必填与可选字段



| 字段 | 参数名 | 必填 | 说明 | 示例 |

|------|--------|------|------|------|

| 需求名称 | `REQUIREMENT_SLUG` | 否 | 英文短名，连字符分隔；未提供时 Init 从原始材料推断 | `compass-claim-upload` |

| 原始材料 | `RAW_MATERIALS` | **是** | 附件、粘贴正文、或 @ 引用的文件 | Word/PDF/会议纪要 |

| 分支 | `KNOWLEDGE_REPO_BRANCH` | **是** | 知识库目标分支；clone 或更新后须切换到此分支 | `develop` |

| 知识库地址 | `KNOWLEDGE_REPO_URL` | **是** | Git 远程地址；**默认必填**，见下节例外 | `https://.../ocspec-compass.git` |

| 本地知识库确认 | `KNOWLEDGE_REPO_CONFIRM` | 条件 | 用户**明确确认**使用工作区根已有目录时填写目录名 | `ocspec-compass` |

| 关联历史需求 | `RELATED_REQUIREMENT` | 否 | 已有需求目录名或相对路径；**仅只读参照**增强对照，见下节 | `compass-claim-v1_20250301` |

| 预估拉取耗时 | `ETA_MIN` | 否 | 大仓库 clone 超时放宽（分钟） | `5` |



## 知识库地址门禁（强制）



### 默认规则



- **未提供 `KNOWLEDGE_REPO_URL` → 必须 Halt（NEED_INFO）**，不进入 clone / 更新 / Pin

- **禁止**在未同时满足 URL 或经确认的本地目录时，假定工作区根任意目录为知识库



### 唯一例外：用户明确确认本地已有知识库



同时满足以下**全部**条件时，可**暂缺 URL**、以 `KNOWLEDGE_REPO_CONFIRM` 继续 Phase B：



1. 用户在本轮或上一轮对话中**明确确认**（如「确认使用本地 `ocspec-compass` 作为知识库」）

2. `KNOWLEDGE_REPO_CONFIRM` 为工作区根下**已存在**的目录名，且以 `ocspec-` 开头、含 `knowledge/`

3. Agent 已在 Halt 模板中展示该目录的 `git remote get-url origin` 与当前分支，供用户核对



**仍禁止**：仅凭「根目录只有一个 `ocspec-*`」就自动采用，**必须**经用户确认或提供 URL。



### 禁止主动新建



在**未提供** `KNOWLEDGE_REPO_URL` 且**未**经用户**明确指定新建**时，**禁止**：



- `git clone` 到工作区根

- `mkdir` 创建 `ocspec-*` 或空 `knowledge/` 目录

- `git init` 初始化新知识库仓库

- 从模板/scaffold 生成知识库目录结构



**允许新建 clone 的条件**（须同时满足）：



1. 用户提供了合法的 `KNOWLEDGE_REPO_URL`

2. 目标目录尚不存在，或用户明确允许覆盖 remote 并 update 已有 git 目录

3. 若用户写「新建知识库」但未给 URL → 仍 Halt，请补充地址



## 缺失时的 Halt 模板



当 `RAW_MATERIALS` 或 `KNOWLEDGE_REPO_BRANCH` 缺失时，输出：



```text

=== 请补充以下信息后继续 ===



1. 原始需求材料（附件或正文）【必填】

2. 分支名【必填，如 develop / main】

3. 知识库 Git 地址【必填】

4. 需求名称（英文，连字符）【可选；未提供时从材料推断】

5. 关联历史需求目录名（可选，迭代场景填写）

```



当 **`KNOWLEDGE_REPO_URL` 缺失**时，输出（**须扫描工作区根**后定制）：



```text

=== 请确认知识库来源后继续 ===



未提供知识库 Git 地址，已停止拉取。请选择其一：



A. 提供知识库 Git 地址（推荐）

   例：知识库：https://example.com/group/ocspec-compass.git



B. 若工作区根已有知识库目录，请明确确认使用哪一个：

   - ocspec-compass  → origin: https://.../ocspec-compass.git （当前分支: develop）

   - ocspec-xxx      → origin: ...



   回复示例：「确认使用本地 ocspec-compass 作为知识库」



C. 若根目录存在其他代码库（非 ocspec-*），它们不是知识库，请勿混淆：

   - my-app → origin: ... （应用代码，非知识库）



【禁止】在未提供地址且未确认前，自动 clone 或新建 ocspec 目录。

【新建】仅当明确说明「新建知识库」并提供 Git 地址时方可 clone。

```



当用户提供了 `REQUIREMENT_SLUG` 但不符合 `^[a-z][a-z0-9-]*$` 时 → NEED_INFO，请用户修正。



## 关联历史需求：只读参照（强制）



`RELATED_REQUIREMENT` **仅用于 Step 1 对照增强**，帮助理解迭代关系、术语延续与范围差异。



| 允许 | 禁止 |

|------|------|

| 只读打开历史目录下 `requirement/requirement.md` 等文件 | **复制**历史需求正文到本次产出 |

| 在 §9 对照表与待澄清清单中引用差异 | **修改**历史需求目录下任何文件 |

| 在成稿 3.1 中文字说明与历史需求的迭代/并行关系 | 以历史需求目录作为本次 `{BASE_DIR}` |

| 标注「相对历史需求的增删改」摘要（基于本次材料） | 在未获用户**明确指定**时，按「在历史需求基础上直接续写/实现」处理 |



**默认模式**：本次始终在新目录 `{OCSPEC_ROOT}/requirements/<slug>_<date>/` 独立成稿；历史需求仅为**只读上下文**。



**例外**：仅当用户在 prompt 中**明确指定**（如「直接基于 xxx 需求目录续写」「在原 requirement.md 上增补」）时，方可偏离上述默认；否则一律 Halt 并确认意图。



## Init 绑定规则（Pin 文件）



Step 0 Phase C 在 `{KNOWLEDGE}/_workspace/product-req/00-ocspec-pin.md` 写入 Pin，Init **须优先读取**：



| Pin 字段 | Init 用途 | 优先级 |

|----------|-----------|--------|

| `OCSPEC_ROOT_PIN` | 确定 `{OCSPEC_ROOT}` | **高于** scheduler-protocol §1.2.1 优先级 1～3 |

| `REQUIREMENT_SLUG` | 确定 `{BASE_DIR}`（**仅当 Pin 中已提供且非「未提供」**） | 高于 §1.2 从材料推断 |

| `RELATED_REQUIREMENT` | 供 Step 1 历史需求**只读**对照；**不得**作为 `{BASE_DIR}` 或写入目标 | 只读传递 |



**Init 摘要须额外输出**：



```markdown

OCSPEC_ROOT_PIN_USED: yes | no

REQUIREMENT_SLUG: <slug>（未提供时写「未提供」）

```



## 触发示例



```text

产品需求分析

知识库：https://example.com/group/ocspec-compass.git

分支：develop



[附上需求 Word 或粘贴正文]



# 可选：

# 需求名称：compass-claim-upload

# 关联历史需求：compass-claim-v1_20250301

```



**使用已存在本地知识库（须明确确认）：**



```text

产品需求分析

分支：develop

确认使用本地 ocspec-compass 作为知识库



[附上需求材料]

```



（Agent 仍应在 Step 0 展示 origin 供核对；Pin 中 `KNOWLEDGE_REPO_URL` 可写「本地确认」并记录 `KNOWLEDGE_REPO_CONFIRM` 与实测 origin。）


