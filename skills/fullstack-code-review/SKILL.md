---
name: fullstack-code-review
description: 设计驱动的全栈实现质量审查技能。对照设计文档（backend-design.md / frontend-design.md）、任务拆分（task/task-split.md）与编码规范，对 fullstack-code-implementation 产出的代码进行结构化审查，输出分级审查报告。审查覆盖四大维度：编码规范合规（BE-*/FE-*/CC-*）、后端业务实现质量（BQ-*）、前端业务实现质量（FQ-*）、改动影响分析（IA-*）。
---

# 前后端代码审查

## 文档职责边界

- 本文件（\`SKILL.md\`）负责：审查流程、输入输出、分流机制、结论判定、协作关系。
- 审查检查项细则统一放 \`references/\`，本文件不展开具体检查项内容。
- 审查报告模板放 \`references/common/review-report-template.md\`，本文件仅说明报告产出规则。
- 如与项目既有规范冲突，以项目规范为准并显式说明差异。

## 角色定位

- 在 e2e 流程中位于 \`fullstack-code-implementation\` 之后、\`project-archive\` 之前。
- 负责对已完成编码的前后端代码做质量审查，输出结构化审查报告。
- **不修改代码**：仅输出发现与建议，由 implementation 技能或人工执行修复。
- **不执行编译/构建/测试**：编译闸门由 implementation 技能负责，本技能在阶段 0 确认其状态。

## 何时使用

- \`fullstack-code-implementation\` 编码完成且编译闸门通过后，需要对代码做质量审查。
- 开发者修复审查问题后，需要增量复审确认修复效果。
- 用户说"审查代码""code review""CR""review 一下"等。

## 前置输入

- **设计文档**：\`design/backend-design.md\` 和/或 \`design/frontend-design.md\`。
- **任务拆分**：\`task/task-split.md\`（确认审查范围与任务完成状态）。
- **变更产物**：fullstack-code-implementation 产出的代码变更（新增/修改文件清单）。
- **编码规范**（按需加载，位于 fullstack-code-implementation/references/ 下）：
  - 后端：\`coding-standard.md\`
  - 前端：\`coding_standard.md\`
- **项目知识**（若存在）：\`knowledge/code/<项目名>/frontend-project.md\` 或 \`backend-project.md\`。

## 执行流程

### 步骤 0：前置校验

- **目标**：确认审查前置条件满足。
- **动作**：
  1. 确认编译闸门已通过（从 implementation 执行日志或变更概要中读取后端编译 + 前端构建状态）。
  2. 确认设计文档可达（\`backend-design.md\` 和/或 \`frontend-design.md\` 存在）。
  3. 确认 \`task/task-split.md\` 存在且任务状态为已完成。
  4. 收集变更文件清单（从变更概要或仓库 diff 获取）。
- **检查点**：若前置条件不满足，输出阻断说明并终止，列明缺失项。

### 步骤 1：上下文收集与分流

- **目标**：建立审查上下文，将变更文件分流到对应审查集。
- **动作**：
  1. 读取设计文档，提取设计契约清单（接口列表、模型列表、组件列表、路由列表等）。
  2. 读取 \`task/task-split.md\`，提取后端/前端任务清单及状态。
  3. 从 \`backend-design.md\` 提取业务质量审查基线：
     - §3.1.3 状态机定义（状态、转换规则）
     - §3.2 各功能的幂等要求（系统侧/业务侧）
     - §3.2 各功能的异常处理策略（重试/阻断/丢弃）
     - §3.2 各功能的依赖接口（URL、超时、异常处理）
     - §3.2 各功能的时序图（调用链顺序）
     - §4 稳定性评估（限流/降级/熔断/监控/告警）
     - §2.2 技术选型（缓存/MQ/分布式锁）
  4. 从 \`frontend-design.md\` 提取前端质量审查基线：
     - 接口对齐表（前后端字段级对齐）
     - 错误处理章节（错误码→前端处理策略）
     - 权限设计（按钮级/路由级）
  5. 从 \`task/task-split.md\` 提取改动影响分析基线：
     - 任务清单与完成状态
     - 依赖关系与开放问题
  6. 按文件后缀和路径分流变更文件：

  | 分类 | 匹配规则 | 适用检查项 |
  |------|----------|-----------|
  | 后端 | \`.java\`, \`.xml\`（MyBatis）, \`.yml\`/\`.yaml\`（Spring）, \`.properties\`, \`.sql\` | BE-* + BQ-* + CC-* |
  | 前端 | \`.vue\`, \`.tsx\`, \`.jsx\`, \`.ts\`（前端目录）, \`.js\`（前端目录）, \`.css\`, \`.scss\`, \`.less\` | FE-* + FQ-* + CC-* |
  | 通用 | \`.md\`, \`.json\`, \`Dockerfile\`, \`.sh\` 等 | CC-* + IA-* |

  7. 按需加载对应 references 检查项文档（后端集非空加载 BE-* + BQ-*，前端集非空加载 FE-* + FQ-*，CC-* 和 IA-* 始终加载）。
  8. 若存在 \`frontend-project.md\` 或 \`backend-project.md\`，读取项目约定作为审查基准。
- **检查点**：分流结果中无法判断归属的文件标记为 \`[需人工确认]\`。

### 步骤 2：高层审查（设计合规 + 架构 + 业务质量 + 影响分析）

- **目标**：从设计合规、架构、业务实现质量和改动影响四个层面发现系统性问题。
- **动作**：
  1. **设计实现一致性**：将步骤 1 的设计契约清单与代码变更交叉比对。
     - 设计中有但代码中无 → blocking："设计要求的 [xxx] 未实现"。
     - 代码中有但设计中无 → suggestion："[xxx] 超出设计范围，是否必要？"
  2. **架构合规**：检查分层、依赖方向、模块边界（对照 \`references/common/cross-cutting-review.md\` CC-ARCH-* 检查项）。
  3. **存量路径一致性**：新增文件路径是否与仓库现有同类文件并列（后端 §3.3.1、前端目录约定）。
  4. **任务完整性**：\`task-split.md\` 中状态为 Done 的任务是否都有对应代码变更。
  5. **后端业务实现质量审查**：对照 \`backend-design.md\` 中的设计基线，按 \`references/backend/business-quality-checklist.md\` 中 BQ-* 检查项审查核心业务逻辑（幂等/事务/一致性/并发/重试/状态机/异常处理）。
  6. **前端业务实现质量审查**：对照 \`frontend-design.md\` 中的设计基线，按 \`references/frontend/frontend-quality-checklist.md\` 中 FQ-* 检查项审查前端交互健壮性（状态一致性/竞态/接口健壮性/操作防护/权限/数据安全）。
  7. **改动影响分析**：对照 \`task/task-split.md\` 的任务依赖关系，按 \`references/common/impact-analysis-checklist.md\` 中 IA-* 检查项评估改动的影响范围、兼容性和回滚方案。
- **检查点**：高层审查发现的 blocking 问题优先记录，可能影响后续逐文件审查的判断。

### 步骤 3：逐文件审查（规范合规 + 代码质量）

- **目标**：对每个变更文件做规范合规和代码质量检查。
- **动作**：
  1. 遍历后端审查集，按 \`references/backend/backend-review-checklist.md\` 中 BE-* 检查项逐项检查。
  2. 遍历前端审查集，按 \`references/frontend/frontend-review-checklist.md\` 中 FE-* 检查项逐项检查。
  3. 对所有文件按 \`references/common/cross-cutting-review.md\` 中 CC-* 检查项检查横切关注点。
  4. 每个发现标注：检查项编号、文件路径与行号、严重性等级、问题描述（协作式提问风格）、修复建议、规范来源。
  5. 对值得肯定的实现给出 praise。
- **检查点**：blocking 和 important 级别发现必须有明确的修复建议和规范来源引用。

### 步骤 4：总结与决策

- **目标**：汇总审查结果，给出结论，输出报告。
- **动作**：
  1. 汇总所有发现，按严重性分组统计。
  2. 按判定规则（见下文）给出审查结论。
  3. 按 \`references/common/review-report-template.md\` 模板生成审查报告。
  4. 向用户说明审查结论和后续建议。
- **检查点**：
  - 通过 → 可进入 \`project-archive\`。
  - 有条件通过 → 列出需修复的 important 项，修复后复审。
  - 不通过 → 列出 blocking 项，修复后复审。

## 严重性分级

| 级别 | 标识 | 含义 | 是否阻断 |
|------|------|------|---------|
| S1 | \`blocking\` | 必须修复：功能缺陷、安全漏洞、设计未实现、严重违规 | ✅ 阻断 |
| S2 | \`important\` | 强烈建议修复：违反核心编码规范、AI 标记缺失、异常处理不完整 | ⚠️ 累计 ≥5 阻断 |
| S3 | \`suggestion\` | 建议优化：可提升可读性或可维护性 | ❌ |
| S4 | \`nit\` | 细微瑕疵：格式或风格偏好 | ❌ |
| S5 | \`learning\` | 知识分享：介绍更优实践或设计模式 | ❌ |
| S6 | \`praise\` | 值得肯定的优秀实践 | ❌ |

## 审查结论判定规则

| 结论 | 条件 |
|------|------|
| ✅ 通过 | 无 blocking，important ≤ 2 |
| ⚠️ 有条件通过 | 无 blocking，important 3~4 |
| ❌ 不通过 | 存在 blocking，或 important ≥ 5 |

## 复审机制

修复后可重新触发本技能进行增量复审：
1. 读取上一次审查报告。
2. 仅针对上次 blocking 和 important 发现进行定向复查。
3. 确认修复是否引入新问题。
4. 输出增量审查报告，标注每条发现的状态变更（\`fixed\` / \`partially-fixed\` / \`not-fixed\` / \`new\`）。

## 反馈风格

采用**协作式反馈**：用"是否考虑…？"替代"必须改为…"；说明原因而非仅指出问题；规范硬性要求标注来源，个人建议标注"个人偏好"。详见 \`references/common/review-report-template.md\` 中的反馈示例。

## 输出与交付物

- **产出文件**：\`review/code-review-report.md\`（存放在需求目录下）。
- **产出格式**：按 \`references/common/review-report-template.md\` 模板输出 Markdown。
- **更新策略**：首次审查全量输出；复审增量输出，引用原报告编号。

## 规范引用（单一来源）

- 后端编码规范审查检查项：\`references/backend/backend-review-checklist.md\`
- 后端业务质量审查检查项：\`references/backend/business-quality-checklist.md\`
- 前端编码规范审查检查项：\`references/frontend/frontend-review-checklist.md\`
- 前端业务质量审查检查项：\`references/frontend/frontend-quality-checklist.md\`
- 横切关注点检查项：\`references/common/cross-cutting-review.md\`
- 改动影响分析检查项：\`references/common/impact-analysis-checklist.md\`
- 审查报告模板：\`references/common/review-report-template.md\`
- 后端编码规范（上游源，位于 fullstack-code-implementation/references/backend/）：\`coding-standard.md\`
- 前端编码规范（上游源，位于 fullstack-code-implementation/references/frontend/）：\`coding_standard.md\`

## 执行红线

1. 不直接修改源代码，仅输出审查发现与建议。
2. 不在 \`SKILL.md\` 重复维护检查项细则，统一引用 \`references/\`。
3. 不绕过项目既有约束（技术栈、目录结构、接口规范等）。
4. 不忽略不确定项，需明确标记 \`[需人工确认]\`。
5. 不臆造设计文档中不存在的审查基线。
6. blocking 和 important 发现必须引用具体规范条款，不凭主观判断。