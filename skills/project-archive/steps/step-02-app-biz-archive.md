# Step 2: 编写 appliaction-archive.md + business-archive.md [强制停止]

## 元信息

- agent: archive-writer
- checkpoint: checkpoints/step-02-archive-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/archive/01-input-summary.md`, `{ARCHIVE}/code-archive.md`, `{DESIGN}/architecture-design.md`, `{DESIGN}/backend-design.md`, `{DESIGN}/frontend-design.md`, `{REQ}/requirement.md`, `{KNOWLEDGE}/application/`, `{KNOWLEDGE}/business/`, `{CUSTOM_KNOWLEDGE}/`（若 `CUSTOM_KNOWLEDGE_STATUS=present`）]
- input_files_subagent: [`{WORKSPACE}/archive/01-input-summary.md`, `{ARCHIVE}/code-archive.md`]
- output_files:
  - `{ARCHIVE}/appliaction-archive.md`
  - `{ARCHIVE}/business-archive.md`
- reference_files: [`references/unified_archive_outputs_standard.md`]

## 执行指令

本步骤分 2 个 Part 顺序执行，产出两份归档文件。

### Part 1：编写 appliaction-archive.md

按 `unified_archive_outputs_standard.md` §2 的章节结构编写。编写时须读取既有 `{KNOWLEDGE}/application/`，避免与历史结论矛盾。

#### 必备章节

1. **归档信息**：需求目录、归档时间、对照/回写知识库路径
2. **应用边界与参与者**：用户/角色列表、系统边界、非目标范围
3. **主业务流程（文字描述）**：正常路径（分步骤描述）、异常与回退
4. **调用链与数据流**：前端→后端表、后端→数据/外部依赖表
5. **非功能与运行约束（应用视角）**：鉴权/会话、幂等与重试、限流/降级
6. **（可选）Mermaid 序列图**：仅作补充，图下必须有概括文字
7. **开放问题（应用层）**

### Part 2：编写 business-archive.md

按 `unified_archive_outputs_standard.md` §3 的章节结构编写。编写时须读取既有 `{KNOWLEDGE}/business/`，避免与历史结论矛盾。

#### 必备章节

1. **归档信息**：需求目录、归档时间、对照/回写知识库路径
2. **业务背景与目标**：背景段落、目标与成功标准表、范围外说明
3. **业务角色与术语**：术语/角色定义表
4. **业务流程**：主流程（文字+步骤列表）、分支与例外表
5. **业务规则与约束**：规则表（规则编号/描述/来源）
6. **前后端职责边界（业务视角）**：后端业务能力列表、前端业务呈现列表
7. **需求追溯矩阵**：需求编号/业务摘要/设计位置/任务拆分位置/状态
8. **开放问题（业务侧）**

### 关键约束

- 必须有连续正文，Mermaid 仅作可选附录
- 面向业务可读性：目标、规则、流程、与需求条目对齐
- 前后端职责分节书写，避免混在一栏
- 读取既有知识库，避免与历史结论矛盾
- 若 `CUSTOM_KNOWLEDGE_STATUS=present`：可只读引用 `{CUSTOM_KNOWLEDGE}/` 作为业务/制度对照；**禁止**将归档内容写入 `{CUSTOM_KNOWLEDGE}/`
