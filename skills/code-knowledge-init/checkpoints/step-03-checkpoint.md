# Checkpoint: Step 3 后端文档扫描与生成

> **审查级别**：L1（轻量审查）— 只检查结构和内容维度，一致性和完整性延迟到步骤 5 的 L2 审查。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。

## 审查时需打开的文件
- `{CODE_KNOWLEDGE}/backend-interface/`（实例 1，含 `index.md` 及分册）
- `{CODE_KNOWLEDGE}/backend-database/`（实例 2，含 `index.md` 及分册）
- `{CODE_KNOWLEDGE}/backend-project.md`（实例 3）
- `{CODE_KNOWLEDGE}/backend-external-dependency.md`（实例 4）
- `{CODE_KNOWLEDGE}/scan-plan.md`

## 合理性检查（所有实例）
- [ ] 每个实例的扫描项均已执行**合理性检查 4 项**（覆盖率 ≥ 0.80 / 类型纯度 ≤ 50% / 字段完整度 ≥ 0.30 / 偏差 ≤ 20%）
- [ ] **修复闭环已执行（最多 2 轮，脚本失败已切换 AI 扫描）**
- [ ] 禁止以 [需人工确认] 替代未完成的修复

## scan-plan 状态
- [ ] scan-plan.md 状态已回写（精确整数，非估算）
- [ ] 每个扫描项的状态为 DONE 或有明确的异常说明

## 文档规范
- [ ] 文档章节结构符合对应 reference 规范（backend-interface.md / backend-database.md / backend-module.md / backend-external-dependency.md）
- [ ] 产出语言为简体中文

## backend-interface 产出目录（实例 1，强制）
- [ ] **已判定输出模式**：入口条目总数与功能模块数已统计；满足 §2.3 条件（入口 > 300 或模块 > 20）时必须为分册模式
- [ ] **目录结构**：存在 `backend-interface/` 目录；入口为 `backend-interface/index.md`；**父目录不存在** `backend-interface.md`
- [ ] **分册模式**：`index.md` 仅含统计概要 + 模块索引表，**不含** `### {Controller}` 级接口表格
- [ ] **分册模式**：索引表列出的每个 `{module}.md` 均位于 `backend-interface/` 目录下，链接可解析（相对 `index.md` 的同目录路径）
- [ ] **分册模式**：父目录**不存在**平铺的 `backend-interface-*.md`
- [ ] **分册模式**：索引表「入口数」之和 = 统计概要条目总数；各分册接口行数之和 = 条目总数（偏差 ≤ 5%）
- [ ] **单文件模式**：全部内容在 `backend-interface/index.md`，除 `index.md` 外无其他分册文件
- [ ] **写入区分**：「每段 ≤ 300 行」为追加写入上限，已落实；不得因分段写入而跳过 §2.3 文件拆分

## backend-database 产出目录（实例 2，强制）
- [ ] **已判定输出模式**：表总数与实体模块数已统计；满足 §2.3 条件（表 > 50 或模块 > 20）时必须为分册模式
- [ ] **目录结构**：存在 `backend-database/` 目录；入口为 `backend-database/index.md`；**父目录不存在** `backend-database.md`
- [ ] **分册模式**：`index.md` 仅含统计概要 + 模块索引表（+ ER 摘要），**不含** `#### 表N:` 级字段表格
- [ ] **分册模式**：索引表列出的每个 `{module}.md` 均位于 `backend-database/` 目录下，链接可解析
- [ ] **分册模式**：父目录**不存在**平铺的 `backend-database-*.md`
- [ ] **分册模式**：索引表「表数量」之和 = 统计概要表总数；各分册 `#### 表N:` 计数之和 = 表总数（偏差 ≤ 5%）
- [ ] **单文件模式**：全部内容在 `backend-database/index.md`，除 `index.md` 外无其他分册文件（`er-diagram.md` / `dict-tables.md` 除外，仅当 ER/字典独立分册时）
- [ ] **写入区分**：「每段 ≤ 300 行」为追加写入上限，已落实；不得因分段写入而跳过 §2.3 文件拆分

## 中间文件清理
- [ ] *-scan-result.md 中间文件已删除
- [ ] scan-plan.md 保留

## 写入规范
- [ ] 分段写入（无超 300 行痕迹）
- [ ] 写入后门禁校验已执行

## Mermaid 图
- [ ] Mermaid 图语法正确
- [ ] 单张 Mermaid 图节点数 ≤ 30，超过时已分拆子图

## [需人工确认] 约束
- [ ] **[需人工确认] 占比不超 20%**（单份文档）
- [ ] 能力范围内（grepSearch 可匹配）的未标注 [需人工确认]

## 占位字段
- [ ] **占位字段已清理**（不存在 TODO/TBD/N/A/- 等占位值）

## DDL 扫描（实例 2）
- [ ] **DDL 扫描策略正确**（Flyway/Liquibase/单文件全量，按实际组织方式选择）
- [ ] **产出决策树路径正确**（存在 DDL 时走**实体 ∪ DDL 并集**，非取其一）

## 数据模型确定性提取与合并（实例 2，强制）
- [ ] **真注解校验**：实体表来自真注解（`@TableName(`/`@Table(`/`@Entity`，剥注释后判断），未把带 @RestController/@Controller/@Service/@Configuration/@Mapper 的类误判为表
- [ ] **无伪字段残留**：文档中不存在 Java 关键字伪字段（`if`/`for`/`constraint` 等）或 `CREATE TABLE IF NOT EXISTS` 误切字段行；无 `[解析异常-非表字段]` 残留行
- [ ] **并集完整**：`db-merge.ps1` 已执行；实体表全部出现在最终分册（无实体表被并集丢失）；仅 DDL 表已按 sql 路径归入对应模块
- [ ] **表名归一化去重**：无同一物理表因大小写/schema 前缀/引号被算成多表；备份表（`_bk`/`_bak`/`_tmp`）已单列且不计入业务表并集
- [ ] **对账门禁**：`reconcile-report.md` 存在；仅实体/仅DDL/双有/疑似备份 四清单齐全；差异已逐项归因
- [ ] **溯源完整**：每张表标题下有 `来源类型: entity/ddl/both` 与 `溯源: 文件:行号`；机读溯源 json（entity-provenance/ddl-provenance/merged-tables）存在于 `{WORKSPACE}/code/`
- [ ] **字段类型优先级正确**：来源含实体（both/仅实体）的表，字段类型以**实体类型**为准；**仅 DDL** 的表才用 DDL 类型；both 表中仅 DDL 有的列保留 DDL 类型
- [ ] **说明来源正确**：both 表说明按 §0.2.1 合并（DDL COMMENT 与实体注释——含行尾 `//`——取首个非空者；不得因一侧无注释丢弃另一侧）
- [ ] **语义补全边界**：子代理仅补 `[需人工确认]` 说明列，未改动字段名/类型/结构/来源/溯源

## 待确认项提取
审查完成后，从产出中提取以下内容作为待确认项：
- 产出正文中所有 [需人工确认] 标记（含位置）
- 状态报告中的 concerns / missing-context
- 合理性检查中不通过的项（含修复记录）
