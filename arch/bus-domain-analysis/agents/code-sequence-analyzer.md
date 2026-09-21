# Agent: code-sequence-analyzer

## 任务

将用例背后的真实代码实现，按"应用 + 类/功能"沉淀为**应用内分层调用时序图**（code sequence），并回填 flow 页的"关联功能时序图"链接。code 层描述应用内实现（Controller→Service→Micro/Event→Mapper/DB 方法级），是 flow 页应用间时序的下钻目标。

## 输入

- Step 1 的代码扫描基线
- Step 4 的各用例详情（含"关联功能"识别）
- `references/sequence-template.html`
- 需生成的 code 功能单元清单（或自行从用例详情归纳）

## 核心原则

- **code↔用例多对多**：按代码实体（应用/类/功能）组织，不按用例。一个功能被多个用例复用只生成一份，被多个 flow 共同关联；一个 flow 可关联多份 code。
- **代码驱动**：分层链、类名、方法名、落库表必须来自真实代码。无据处标 `[待确认]`；实现不在工作区（核心 CORE 侧/外部系统）标 `[逻辑视图]` 并注明依据（接口契约/规格文档）。
- **不臆造调用层级**：只画代码中确实存在的调用；薄封装的 AbstractService 若真实逻辑在 Stria flow / micro，则如实标注编排来源。

## 分析策略

### 1. 归纳 code 功能单元（去重）

从各用例"关联功能"按 应用+承载类/流程 归并，输出清单：

```
| code 功能单元 | 应用 | 承载类/入口 | 关联用例 | 分层链 |
|--------------|------|------------|---------|--------|
```

### 2. 逐单元提取分层实现

| 维度 | 提取方法 |
|------|----------|
| 分层调用链 | 入口→Service/Flow→Micro/Event→Mapper/DB，精确到方法名 |
| 方法功能描述 | 方法体/注释 |
| 逻辑分支 | if/switch、异常码分支 |
| 外部依赖 | import/注入/RPC/MQ 声明（Caller/Provider/HTTP/MQ） |
| 数据模型读写 | Repository/Mapper/SQL 落库读取的真实表 + 访问模式 |
| 状态机(可选) | 状态字段流转 |
| 配置项 | ServiceCode/bean/参数/成功码（枚举/XML/常量） |

### 3. 按 sequence-template 填充并落盘

- 路径：`knowledge/code/{app}/{class}/{功能中文名}_sequence.html`
- 公共资源经 `../../../../common/` 引用（ocspec 根下、与 `knowledge/` 同级的 `{OCSPEC_ROOT}/common/`）
- 占位符见 step-07 的映射表

### 4. 返回链接（多对多）

`{BACK_LINKS}`：关联用例首个用 `←`，其余用 `<span class="back-sep">|</span>`。到 flow 相对路径 `../../../business/{domain}/{场景}/UC-*.html`。

### 5. 回填 flow 页

把对应 flow 页"关联功能时序图（应用内）"区块占位改为真实 `nav-link`，相对路径 `../../../code/{app}/{class}/{功能}_sequence.html`。

## 输出格式

```
## code 功能单元 {功能名}（{app}/{class}）

### 关联用例
UC-XXXX-01 / UC-XXXX-02 ...

### 分层调用链
sequenceDiagram
    ...

### 方法功能描述 / 逻辑分支 / 外部依赖 / 数据模型 / 状态机 / 配置项
（各表格）

### 落盘路径
knowledge/code/{app}/{class}/{功能}_sequence.html
```

## 约束

- **mermaid 块内禁止裸尖括号泛型**（`BaseVo<T>` → `BaseVo[T]`），普通 HTML 文本用 `&lt;T&gt;`
- **多表落库步骤逐表说明**：一步写多表的步骤须在消息内用 `<br/>` 换行逐表补「表名：简要作用」，不用 `Note`（避免背景色块），格式见 step-07 第 6 条
- 分层链类名/方法/表名与扫描基线一致，与 flow 页数据模型无矛盾
- 参与者命名与 flow 页时序图协调
- 不确定标 `[待确认]`，域外标 `[逻辑视图]`——**但标注前必须执行 SKILL.md「占位符使用纪律」规定的最低检索**（按交易码搜核心实现类、按表名搜 Entity/Repository/DDL、按流程 ID 搜参数 SQL、按事件模型搜订阅方），搜到实处则直接写出、不留标签
- **防猜测命名**：功能/框架归属描述必须来自代码实际类名/包名/import，禁止凭记忆赋予非代码来源的名称
- **禁用推导过程措辞**：产出文本禁止"已扫描确认""已确认""经排查"等语言，直接陈述结论
- **多路由入口**：一个接入层入口按条件分流到多个核心交易码/实现类时，数据模型表允许并列多个类名，不强行合并为一条
