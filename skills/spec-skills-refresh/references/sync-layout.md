# 技能同步布局与路径（单一细则来源）

本文档为 \`spec-skills-refresh\` 的路径映射、来源目录与环境说明的**唯一维护处**；\`SKILL.md\` 仅引用本节，不重复粘贴大表。

## 技能来源目录（相对仓库根）


| 目录                                | 说明        |
| --------------------------------- | --------- |
| \`e2e/knowledge-base/\`             | 知识库相关技能   |
| \`e2e/requirement-implementation/\` | 需求实现相关技能  |
| \`e2e/workspace/\`                  | 工作空间初始化技能 |
| \`tools/\`                          | 工具类技能     |


## 各工具目标路径与同步方式

所有工具均**不保留**源仓库中的父级路径（如 \`e2e/knowledge-base/\`）：只把各源目录下的**一级子目录**当作一个技能，同步到 \`<目标 skills>/<技能名>/\`。备份完成后，先**删除**本地 skills 中与远端同名的技能目录，再从远端全量复制，确保本地不残留远端已删除的文件。

| 工具          | 全局路径                                | 项目路径                       | 同步方式 |
| ----------- | ----------------------------------- | -------------------------- | ---- |
| Cursor      | \`~/.cursor/skills/<技能名>/\`          | \`.cursor/skills/<技能名>/\` | 先删后写，技能平铺 |
| Kiro        | \`~/.kiro/skills/<技能名>/\`            | \`.kiro/skills/<技能名>/\`   | 同上 |
| Trae        | \`~/.trae/skills/<技能名>/\`            | \`.trae/skills/<技能名>/\`   | 同上 |
| Claude Code | \`~/.claude/skills/<技能名>/\`          | \`.claude/skills/<技能名>/\` | 同上；缺 \`SKILL.md\` 时脚本生成占位 |
| OpenCode    | \`~/.config/opencode/skills/<技能名>/\` | \`.opencode/skills/<技能名>/\` | 同上 |

## 备份目录（与 skills 同级）

更新前若 \`skills\` 非空，会先整体快照到 **\`<parent>/backup-skills/backup-<时间戳>/\`**（与 \`skills\` 同级，不在 \`skills\` 目录内）。每个 \`backup-skills\` 下若 \`backup-*\` 超过 3 个，则**按目录名（时间戳）删除最旧的**，只保留最新的 3 个。

| 工具        | skills 路径示例 | 备份根目录示例 |
| ----------- | -------------- | -------------- |
| Cursor      | \`~/.cursor/skills/\` | \`~/.cursor/backup-skills/\` |
| Kiro        | \`~/.kiro/skills/\` | \`~/.kiro/backup-skills/\` |
| Trae        | \`~/.trae/skills/\` | \`~/.trae/backup-skills/\` |
| Claude Code | \`~/.claude/skills/\` | \`~/.claude/backup-skills/\` |
| OpenCode    | \`~/.config/opencode/skills/\` | \`~/.config/opencode/backup-skills/\` |

项目范围时同理：\`.cursor/skills\` → \`.cursor/backup-skills\`。

## 环境与行为说明

- **默认仓库**：\`https://gitlab.jryzt.com/ocss-public/oc-coding-spec.git\`（HTTPS 克隆建议带 \`.git\` 后缀）。
- **默认分支**：\`aicode_e2e\`。脚本使用 \`git clone --depth=1 --branch <分支>\`；可用参数 \`--branch\` 覆盖；交互时仓库地址可直接回车采用默认 URL。
- **备份**：见上文「备份目录」；快照目录名 \`backup-YYYYMMDD_HHMMSS\`；超过 \`MAX_SKILL_BACKUPS\`（默认 3）时删除**最旧**快照。
- **配置持久化**：\`~/.oc-skills-config\` 可保存 \`SAVED_REPO_URL\` 与 \`SAVED_BRANCH\`，后续可免填（仍可用命令行覆盖）。
- **依赖**：本机需已安装 \`git\`；Bash 环境用于执行 \`script/spec-skills-refresh.sh\`（Git Bash / WSL / macOS / Linux）。
- **同名技能**：同一轮同步中，若多个源根目录下出现同名一级子目录（如 \`e2e/knowledge-base/foo\` 与 \`tools/foo\`），后处理的源会**合并写入**同一 \`<技能名>/\`，日志中会输出冲突提示。

## 脚本位置（仓库内）

- 相对仓库根：\`e2e/workspace/spec-skills-refresh/script/spec-skills-refresh.sh\`（便携副本：\`skill-init/spec-skills-refresh/script/spec-skills-refresh.sh\`）
- 在仓库根目录执行：\`bash e2e/workspace/spec-skills-refresh/script/spec-skills-refresh.sh\`