# 贡献指南

感谢你对 AI Coding Skills 的关注！我们欢迎各种形式的贡献。

---

## 如何贡献

### 报告问题

如果你发现了 bug 或有改进建议，请提交 [Issue](https://github.com/pengguogo/ai-coding-skills/issues)。

提交 Issue 时请包含：
- 问题描述
- 复现步骤
- 期望行为
- 实际行为
- 环境信息（AI 工具版本、操作系统等）

### 提交代码

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/my-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送分支：`git push origin feature/my-feature`
5. 提交 Pull Request

### 改进文档

文档改进同样重要！如果你发现文档有误或不清晰，欢迎提交 PR。

---

## 开发规范

### Skill 文件结构

每个 Skill 必须包含：

```
skill-name/
├── SKILL.md              # 技能定义
└── references/           # 参考文档
    └── *.md
```

### SKILL.md 规范

`SKILL.md` 必须包含以下部分：

1. **触发条件** — 何时触发该技能
2. **执行流程** — 详细的执行步骤
3. **输出交付物** — 产出文件列表
4. **执行红线** — 不可违反的约束

### 命名规范

- 目录名：小写字母 + 连字符（如 `code-knowledge-init`）
- 文件名：小写字母 + 连字符（如 `backend-design.md`）
- 命令名：以 `/` 开头（如 `/code-knowledge-init`）

---

## 代码风格

- Markdown 文件使用统一的格式
- 代码块标注语言类型
- 表格对齐整齐
- 中文与英文/数字之间加空格

---

## 提交规范

Commit message 格式：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具变更

**示例**:
```
feat(skill): add business-knowledge-init skill

Add a new skill for business architecture knowledge restoration.
Supports business overview, domain orchestration, and process analysis.

Closes #42
```

---

## 下一步

- 查看 [Home](Home) 返回首页
- 提交 [Issue](https://github.com/pengguogo/ai-coding-skills/issues) 反馈问题
