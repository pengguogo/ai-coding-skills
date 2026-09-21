# Step 1: 缺陷登记与分级

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-01-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{CODE_KNOWLEDGE}/backend-project.md`（项目上下文）, `{REQ}/requirement.md`（若存在）, `{DESIGN}/`（若存在，判定基线可得性）]
- output_file: `{WORKSPACE}/bugfix/01-intake-and-triage.md`
- reference_files: [`references/bug-triage-standard.md`]
- domain_context: 为本次 bug 建立结构化登记、分级、类型，并判定可用的预期行为基线，不做根因定位
- extraction_schema: |
    # Bug 登记与分级（<id>）

    ## 1. 基本信息
    | 字段 | 内容 |
    |------|------|
    | Bug 编号 | BUG-<yyyymmdd>-<NN> |
    | Bug 标识 slug | <从现象提取的简短描述，≤20 字，连字符分隔，如 审批链推送OA失败> |
    | 现象 | |
    | 复现步骤 | |
    | 是否可稳定复现 | 是 / 否（偶发） |
    | 日志/堆栈 | |
    | 涉及仓库（角色） | |

    ## 2. 分级判定
    | 证据项 | 取值 |
    |--------|------|
    | 涉及仓库数 | 1 个 / 多个 |
    | 预估调用链跨层数 | 0 / ≤1 / >1 |
    | 含 SQL DDL | 是 / 否 |
    | 触及资金/并发/鉴权 | 是 / 否 |
    | 前后端联动 | 是 / 否 |

    - 判定级别：L1 / L2 / L3
    - 缺证据是否 fallback L2：是 / 否
    - 向用户明示：本 bug 判为 L{n}，如需升档请指出

    ## 3. 类型判定
    - 类型：后端逻辑 / 前端逻辑 / 前后端联动 / 数据库 / 前端纯样式
    - 定向方向（供 Step 2）：

    ## 4. 预期行为基线
    | 字段 | 取值 |
    |------|------|
    | 基线来源 | 设计文档 / 知识库领域 / 无设计基线 |
    | 命中基线文件 | <{DESIGN}/backend-design.md / {KNOWLEDGE}/business/... / 无> |
    | 风险标注 | 设计文档→无；知识库领域→[领域级基线，非接口级]；无→[无设计基线，须人工确认预期行为] |

## 执行指令

`<id>` = 本次 bug 编号 `BUG-<yyyymmdd>-<NN>`（当日 log 内自增两位序号，首个为 01）。`<slug>` = 从现象提取的简短标识（≤20 字，连字符分隔，如 `审批链推送OA失败`），用于持久方案文件命名。本步骤仅写入 `{WORKSPACE}/bugfix/`。

1. 收集结构化 bug 信息：现象、复现步骤、是否可稳定复现、日志/堆栈、涉及仓库与角色。关键项缺失 → STATUS_REPORT `NEED_INFO` → Halt 追问。
2. 判级 L1/L2/L3（按 `bug-triage-standard.md`），列出机械证据：仓库数 / 调用链跨层数 / 含 DDL / 触及资金·并发·鉴权 / 前后端联动。缺任一证据 → fallback L2；含 DDL/资金/并发/鉴权/联动任一为「是」→ 至少 L3；并发/安全类 → 强制 L3。AI 不得自我降级；向用户明示分级。
3. 判定 bug 类型（指导 Step 2 定向）。性能按主导症状归并；并发→后端逻辑且 L3；安全→对应端逻辑且 L3。
4. 判定预期行为基线来源：`{DESIGN}/` 有设计文档 → 设计文档基线；否则 `{KNOWLEDGE}/business/`、`application/` 存在 → 知识库领域基线；均无 → 无设计基线（打风险标）。
5. 按 extraction_schema 写入 output_file，附 STATUS_REPORT。

## STATUS_REPORT

bug 信息不足 → `NEED_INFO`；否则 `OK`。
