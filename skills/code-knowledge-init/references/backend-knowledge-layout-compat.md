# backend-interface / backend-database 产出布局兼容

`code-knowledge-init` 新产出为**目录化**（`backend-interface/`、`backend-database/`，入口 `index.md`）；存量知识库可能仍为**单文件**（`backend-interface.md`、`backend-database.md`）或历史**平铺分册**（`backend-interface-{module}.md`）。下游技能须**按实际存在的路径读取与融合**，不得假定仅有一种布局。

---

## 1. 布局判定（每个 `{CODE_KNOWLEDGE}` 独立判定）

| 文档 | 新布局（优先） | 存量回退 | 存量平铺分册（可选回退） |
|------|---------------|----------|-------------------------|
| 接口清单 | `backend-interface/index.md` 存在 | `backend-interface.md` | `backend-interface-*.md`（父目录） |
| 数据模型 | `backend-database/index.md` 存在 | `backend-database.md` | `backend-database-*.md`（父目录） |

**判定顺序**：目录入口 `*/index.md` → 父目录单文件 `*.md` → 平铺分册 `*-{module}.md`。

产出中须标注实际布局：`[布局: 目录]` / `[布局: 单文件]` / `[布局: 平铺分册]`。

---

## 2. 只读场景

适用：`application-knowledge-init`、`business-knowledge-init`、`knowledge-recheck`、`fullstack-design` 等。

1. 先判定布局，再按对应路径读取；**不得**因存量单文件而 Halt。
2. **接口入口数**：目录 → `index.md` 统计概要；单文件 → 文首统计或表格计数；平铺分册 → 各分册汇总。
3. **接口/表明细**：目录 → `index.md` 索引表 + 按需读 `{module}.md`；单文件 → 读全文；平铺分册 → 按模块文件读取。
4. **只读步骤不得迁移格式**；格式迁移由 `code-knowledge-init` 增量/全量扫描触发。

---

## 3. 融合/写入场景

适用：`project-archive`。

1. **沿用既有布局**：目标子系统当前为何种布局，本期增量写入同一布局（archive 不强制迁移存量）。
2. 目录布局存在 → 融合至 `backend-interface/` / `backend-database/`（`index.md` + 分册，见 code-knowledge-init §2.3）。
3. 仅单文件存在 → 融合至 `backend-interface.md` / `backend-database.md`。
4. **目录与单文件并存** → 以**目录为准**融合；校验报告标注存量单文件 `[需人工确认是否废弃]`。
5. 两种布局均不存在且有变更 → 按 code-knowledge-init **当前规范新建目录布局**。

---

## 4. 质检场景

适用：`knowledge-recheck` CK-03 / CK-04。

- **present**：目录入口或存量单文件任一存在且非空。
- **missing**：两种布局均不存在。
- 检查覆盖范围须与实际布局一致（目录含 index + 相关分册，或单文件全文）。
