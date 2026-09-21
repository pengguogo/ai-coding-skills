# 知识库拉取规范

面向产品人员单独使用 `product-requirement-analysis` 时，Step 0 在需求分析前先完成**统一 Intake**、拉取知识库、评估就绪度并写入 **Init Pin**。

## 知识库门禁（最高优先级）

| 规则 | 说明 |
|------|------|
| **URL 默认必填** | 未提供 `KNOWLEDGE_REPO_URL` → **必须 Halt**，不 clone、不 Pin |
| **本地须确认** | 根目录已有 `ocspec-*` 时，**禁止**自动选用；须用户明确确认或提供 URL |
| **禁止擅自新建** | 无 URL、无确认时，禁止 `git clone` / `mkdir ocspec-*` / `git init` |
| **新建许可** | 仅当用户提供 Git 地址（可含「新建知识库」语义）时方可 clone |

完整 Halt 模板与 `KNOWLEDGE_REPO_CONFIRM` 见 `product-intake-guide.md`。

## 统一 Intake（Phase A，先于 clone）

| 参数 | 必填 | 示例 |
|------|------|------|
| 原始材料 `RAW_MATERIALS` | **是** | Word/PDF/正文 |
| 分支 `KNOWLEDGE_REPO_BRANCH` | **是** | `develop` |
| 知识库地址 `KNOWLEDGE_REPO_URL` | **是** | `https://example.com/group/ocspec-compass.git` |
| 本地确认 `KNOWLEDGE_REPO_CONFIRM` | 条件 | `ocspec-compass`（须用户明确确认） |
| 需求名称 `REQUIREMENT_SLUG` | 否 | `compass-claim-upload` |
| 关联历史需求 | 否 | `compass-claim-v1_20250301` |

## 触发示例

```text
产品需求分析
知识库：https://example.com/group/ocspec-compass.git
分支：develop

[附上需求 Word 或粘贴正文]
```

## 分支策略

- **分支为必填项**；无论新 clone 还是使用已有本地 `ocspec-*`，均须切换至指定分支并 `pull --ff-only`
- 本地无该分支时：`git checkout -b <branch> origin/<branch>`

## 目录与命名

- 知识库 clone 到**工作区根目录**，目录名由 URL 推导（如 `ocspec-compass`）
- 目录名**必须以 `ocspec-` 为前缀**
- 有效知识库须含 `knowledge/` 子目录

## Init Pin（Phase C）

Step 0 完成后在 `{KNOWLEDGE}/_workspace/product-req/` 落盘：

| 文件 | 用途 |
|------|------|
| `00-ocspec-pin.md` | `OCSPEC_ROOT_PIN` + `KNOWLEDGE_REPO_URL` / `KB_SOURCE` → 绑定 Init |
| `00-kb-readiness.md` | 四层就绪度 → 供 Step 1 对照 |
| `00-product-intake.md` | Intake 字段存档 |

后续 Init **须优先**使用 Pin 中的 `OCSPEC_ROOT_PIN`；`REQUIREMENT_SLUG` 仅在 Pin 中非「未提供」时用于 `{BASE_DIR}`。

## 场景决策表

| 场景 | 行为 |
|------|------|
| 用户提供 URL + 分支 | 校验 → clone 或 update → Pin |
| 根目录有 1 个 `ocspec-*`，无 URL | **Halt**，列出 origin，请确认或补 URL |
| 根目录有多个 `ocspec-*` | **Halt**，请用户确认目录名或提供 URL |
| 根目录有非 `ocspec-*` 代码库 | 列出并标注「非知识库」；**Halt** 直至 URL 或 CONFIRM |
| 无 `ocspec-*`、无 URL | **Halt**，请提供 Git 地址；**禁止**新建 |
| 用户「确认使用本地 ocspec-xxx」 | `KNOWLEDGE_REPO_CONFIRM` + 展示 origin → update 分支 |
| 用户「新建知识库」但无 URL | **Halt**，请补充 Git 地址 |

## 鉴权失败指引

HTTPS 401/403 或 SSH Permission denied 时：

1. 确认已连接 VPN（内网 GitLab）
2. HTTPS：配置 Personal Access Token（read_repository 权限）
3. SSH：确认公钥已添加到 Git 平台
4. 仍失败：向研发获取**只读** clone 地址与 guest 账号

## 安全边界

与 `workspace-init` 一致：不 reset --hard、不删目录、不覆盖非 git 目录、不自动 merge、不写入凭据。

## 校验失败时的手动修复模板

```text
=== 需手动处理：<name> ===
原因：<一句话>
建议步骤：
1. git -C <name> fetch --prune origin
2. git -C <name> checkout <branch>
3. git -C <name> pull --ff-only
```
