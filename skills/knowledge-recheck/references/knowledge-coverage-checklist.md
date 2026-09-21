# 知识库覆盖检查清单（`knowledge-recheck`）

对照 Step 1 需求项索引，检查 `{KNOWLEDGE}/` **三层知识**是否覆盖本次需求涉及的功能、接口、业务流程与应用边界。

**三层均为必检范围（强制）**：

| 层级 | 路径 | 检查项前缀 |
|------|------|-----------|
| 代码 | `{CODE_KNOWLEDGE}/` | CK-* |
| 应用 | `{KNOWLEDGE}/application/` | AK-* |
| 业务 | `{KNOWLEDGE}/business/` | BK-* |

**禁止**仅执行 CK-* 后以「知识库已检」结案；application / business 目录 absent 或 empty 须整层标 `missing` 并写入报告。

**执行要求**：下表 **每一个** 检查项 ID 均须在 Step 2 §7「检查清单逐项结论」中占一行并给出状态，**禁止**跳过或合并。

## knowledge/code（`{CODE_KNOWLEDGE}/`）

| 检查项 ID | 检查项 | 通过标准 | 缺口示例 |
|-----------|--------|---------|---------|
| CK-01 | backend-project.md 存在且非空 | 文件 present | missing |
| CK-02 | 模块/包结构与本次需求涉及模块一致 | 需求模块在文档中有对应章节或表项 | partial |
| CK-03 | 接口清单覆盖本次新增/变更接口 | 目录（index+分册）或存量 `backend-interface.md` 任一存在；每个新接口有 URL+方法+说明 | missing/outdated |
| CK-04 | 数据模型覆盖本次表结构变更 | 目录（index+分册）或存量 `backend-database.md` 任一存在；新表/新字段已记录 | missing/outdated |
| CK-05 | backend-external-dependency.md 覆盖本次外部依赖 | 新对接系统在清单中 | missing/outdated |
| CK-06 | frontend-project.md 存在（若含前端） | 有前端需求时文件 present | missing |
| CK-07 | frontend-project.md 路由/页面与需求一致 | 新页面/路由已记录 | outdated |
| CK-08 | scan-plan.md（可选） | 存在则仅作元数据参考 | not-applicable |

**outdated 判定**：design/task/代码中已出现的接口、表、页面，在对应 knowledge 文档中**搜索不到**关键词或条目。

## knowledge/application（`{KNOWLEDGE}/application/`）

| 检查项 ID | 检查项 | 通过标准 |
|-----------|--------|---------|
| AK-01 | 目录下至少 1 份架构文档 present | application-system-architecture 等 |
| AK-02 | 本次需求涉及的应用/系统在 applications-and-domains 或等价文档中有条目 | complete/partial |
| AK-03 | 跨应用调用链在 application-components 或等价文档中可找到 | partial 可接受并标注 |
| AK-04 | 与 code 知识库中模块命名一致 | 术语不一致 → outdated |

## knowledge/business（`{KNOWLEDGE}/business/`）

| 检查项 ID | 检查项 | 通过标准 |
|-----------|--------|---------|
| BK-01 | 目录下业务文档 present（overview/process/domain/capability 等） | 至少核心 2 份 |
| BK-02 | 本次需求业务场景在 process/use-cases 或 domain 文档中有追溯 | complete/partial |
| BK-03 | 新业务规则/术语在 business 文档或 custom/ 中有定义 | missing 若均未覆盖 |
| BK-04 | 与 requirement.md 需求项名称可对齐 | 名称严重偏离 → outdated |

## knowledge/custom（`{CUSTOM_KNOWLEDGE}/`，按需）

| 检查项 ID | 检查项 | 通过标准 |
|-----------|--------|---------|
| CU-01 | `CUSTOM_KNOWLEDGE_STATUS=absent` | 跳过全部 CU 项 |
| CU-02 | 需求涉及的制度/术语/对接规范在 custom 中有条目 | present 时 partial 可接受 |
| CU-03 | custom 与 business/code 冲突 | 标注 `[需人工确认]`，以 code/app/biz 事实为准 |

## 知识库未更新 — 建议动作映射（按缺失层级）

| 缺失层级 | 缺口类型 | 建议动作 |
|---------|---------|---------|
| **code** | 接口/模块/表/前端工程未写入 | `project-archive` 融合 code；或 `code-knowledge-init` |
| **application** | 系统拓扑/应用域/组件未更新 | `project-archive` 融合 application；或 `application-knowledge-init` |
| **business** | 流程/领域/能力未更新 | `project-archive` 融合 business；或 `business-knowledge-init` |
| **多层** | 同时缺 code + app 或 app + biz 等 | 优先 `project-archive` 一次性融合；或按层分别重跑对应 init |

## 三层一致性（Step 2 §5.1）

| 对照项 | 说明 |
|--------|------|
| 命名 | 同一应用/模块在 code / application / business 中名称可对齐 |
| 边界 | application 中系统边界与 code 模块划分不矛盾 |
| 流程 | business 流程用例在 code 接口或 application 调用链中有落点 |
| 规则 | business 规则在 code 实现或 archive 中有追溯 |

不一致时：**分别**标注涉及层级，不得仅修 code 层结论。
