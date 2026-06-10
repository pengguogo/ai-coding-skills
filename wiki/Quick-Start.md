# 快速开始

本指南将帮助你在 5 分钟内上手 AI Coding Skills。

---

## 前置条件

- 安装 Git
- 安装至少一个支持的 AI 编码工具（Cursor / Kiro / Trae / Claude Code / OpenCode）
- 有 GitHub 账号和访问权限

---

## 第一步：克隆仓库

```bash
git clone https://github.com/your-org/ai-coding-skills.git
cd ai-coding-skills
```

---

## 第二步：同步技能到 AI 工具

将技能包同步到你的 AI 编码工具：

```bash
# 交互式执行
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

或者在 AI 工具中直接调用：

```
/spec-skills-refresh
```

**支持的工具**：Cursor / Kiro / Trae / Claude Code / OpenCode

---

## 第三步：初始化工作空间

1. 在工作区根目录创建 `repos.txt` 文件：

```txt
# name    type    url                                          branch
my-api    app     https://github.com/org/my-api.git            main
my-web    app     https://github.com/org/my-web.git            develop
```

2. 执行初始化：

```
/workspace-init
```

---

## 第四步：开始使用

现在你可以按照流水线顺序执行各个阶段：

```
阶段 0: /spec-skills-refresh        # 技能同步
阶段 1: /workspace-init             # 环境初始化
阶段 2: /code-knowledge-init        # 代码知识还原
        /application-knowledge-init # 应用架构知识
        /business-knowledge-init    # 业务知识
阶段 3: /prototype-derivation       # 原型推导
        /requirement-analysis       # 需求分析
阶段 4: /fullstack-design           # 技术方案设计
阶段 5: /task-split                 # 任务拆分
阶段 6: /fullstack-code-implementation  # 代码实现
阶段 7: /fullstack-code-review      # 代码审查
        /project-archive            # 项目归档
```

---

## 下一步

- 查看 [[流水线概览|Pipeline-Overview]] 了解完整流程
- 查看 [[技能参考|Skills-Reference]] 了解每个 Skill 的详细用法
- 查看 [[最佳实践|Best-Practices]] 了解使用技巧

---

## 常见问题

### Q: 我可以只使用部分阶段吗？

A: 可以！你可以根据需要跳过某些阶段。例如，如果已经有需求文档，可以直接从阶段 4 开始。

### Q: 技能同步后在哪里？

A: 技能会被同步到各 AI 工具的配置目录，例如 Cursor 的 `.cursor/skills/` 目录。

### Q: 如何更新技能？

A: 重新执行 `/spec-skills-refresh` 即可拉取最新版本。
