# Checkpoint: Step 2 appliaction-archive + business-archive

> **审查级别**：L2（完整审查）— 检查全部维度，含跨文件一致性。
> **审查原则**：你是审查者，不是作者。必须重新打开产出文件逐项核对，不能凭记忆判断。
> **强制停止点**：这是归档阶段交付点。汇总全部待确认项，停下来等待用户确认。

## 审查时需打开的文件
- 产出文件：`{ARCHIVE}/appliaction-archive.md`、`{ARCHIVE}/business-archive.md`
- 上游比对：`{ARCHIVE}/code-archive.md`、`{WORKSPACE}/archive/01-input-summary.md`

## appliaction-archive 章节完整性
- [ ] 包含归档信息
- [ ] 包含应用边界与参与者
- [ ] 包含主业务流程（文字描述，含正常路径和异常回退）
- [ ] 包含调用链与数据流（前端→后端表、后端→数据/外部依赖表）
- [ ] 包含非功能与运行约束
- [ ] 包含开放问题

## business-archive 章节完整性
- [ ] 包含归档信息
- [ ] 包含业务背景与目标
- [ ] 包含业务角色与术语
- [ ] 包含业务流程（主流程 + 分支与例外）
- [ ] 包含业务规则与约束
- [ ] 包含前后端职责边界
- [ ] 包含需求追溯矩阵
- [ ] 包含开放问题

## 跨文件一致性
- [ ] appliaction-archive 调用链中的接口与 code-archive 接口清单一致
- [ ] business-archive 需求追溯矩阵覆盖了输入摘要中的全部需求项
- [ ] 三份归档文件之间模块名/术语一致
- [ ] 必须有连续正文，Mermaid 仅作可选附录

## 待确认项提取
- 两份归档文件中所有 `[需人工确认]` 标记
- 开放问题中的全部条目
- 需求追溯矩阵中状态非"已完成"的条目
- 状态报告中的 concerns
