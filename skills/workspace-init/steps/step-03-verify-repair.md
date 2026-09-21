# Step 3: 校验 + 自动修复 + 手动清单

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`repos.txt`]
- output_file: `(console)`
- safety_constraints: [不自动 merge, 不写入 token]
- domain_context: 初始化后的结果校验与安全范围内的自动修复

## 执行指令

**独立读取 repos.txt**（不依赖 Step 2 的输出），逐条执行 5 项校验：

| 序号 | 检查项 | 通过条件 |
|------|--------|---------|
| 1 | 目录存在 | `<name>` 存在且为目录 |
| 2 | 是 git 仓库 | `git -C <name> rev-parse --is-inside-work-tree` 为 true |
| 3 | 远端 URL | `git -C <name> remote get-url origin` 与清单 url 一致（规范化比较：末尾 .git 可有可无） |
| 4 | 当前分支 | `git -C <name> rev-parse --abbrev-ref HEAD` 等于期望分支 |
| 5 | 与远端同步 | `git -C <name> pull --ff-only` 成功或已 up-to-date |

### 自动修复（安全范围内，按顺序尝试）

1. 目录不存在或不完整（无 .git）→ 重新 clone
2. origin URL 不一致 → set-url + fetch + checkout + pull
3. 不在目标分支 → 重试切换分支
4. pull --ff-only 因需 merge 失败 → **不自动 merge**，标记为需人工

### 手动清单（控制台输出）

对仍未通过的条目，输出结构化清单：

```text
=== 需手动处理：<name> ===
原因：<一句话>
建议步骤：
1. <可复制的 git 命令>
2. ...
```

清单必备元素：name、url、branch（或默认分支说明）、失败原因、可复制的 git 命令。

### 最终汇总
按仓库汇总：通过 N / 已修复 N / 失败 N
