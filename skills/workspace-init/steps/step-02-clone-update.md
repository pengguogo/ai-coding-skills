# Step 2: 执行 clone/更新/切分支

## 元信息

- agent: ops-executor
- checkpoint: checkpoints/step-02-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`repos.txt`]
- output_file: `(console)`
- safety_constraints: [不执行 force push, 不修改 .gitconfig]
- domain_context: 按 repos.txt 逐行执行 git 操作，在工作区根目录创建/更新仓库目录

## 执行指令

对 repos.txt 中每一有效数据行，在工作区根目录执行：

### 目录不存在时
git clone <url> <name>

### 目录存在且是 git 仓库时
git -C <name> remote set-url origin <url>
git -C <name> fetch --prune origin

### 切换分支
- branch 非空：git -C <name> checkout <branch>
  - 本地无该分支：git -C <name> checkout -b <branch> origin/<branch>
- branch 为空（默认分支策略）：依次尝试 main / master
  - 两者都不存在：标记失败，列出远端分支供用户选择

### 更新
git -C <name> pull --ff-only

### 超时处理
- 若 eta_min 存在：shell 超时设为 eta_min × 60 + 60 秒缓冲
- 若 eta_min 不存在：使用默认超时（5 分钟）
- 超时后：标记该行为失败（原因：超时），继续处理下一行

### 错误恢复策略
- 某一行失败后：记录失败原因，**继续处理下一行**（不中断整个流程）
- 网络超时：不自动重试（由 Step 3 的自动修复处理）
- 鉴权失败（401/403）：标记失败，提示用户检查凭据

### 控制台输出
每行处理后输出：
<序号>/<总数> <name> → ✅ 成功 / ⚠️ 警告（附原因）/ ❌ 失败（附原因）

处理完毕后汇总：成功 N / 警告 N / 失败 N
