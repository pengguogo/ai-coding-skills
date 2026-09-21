# Step 5: 最小编译验证

## 元信息

- agent: build-verifier
- checkpoint: checkpoints/step-05-checkpoint.md
- checkpoint-level: L1.5

## 参数

- backend_repo: `[Step 1 涉及的后端仓库根路径，若有]`
- frontend_repo: `[Step 1 涉及的前端仓库根路径，若有]`
- output_file: `{WORKSPACE}/bugfix/build/05-build-verify.md`
- instructions: 见下

## 执行指令

注入 `build-verifier` 角色定义，instructions 只注入编译范围与轻量编译命令，不含测试命令（单测已在 Step 4 执行）：

> 编译范围 = `<Step 3 受影响模块>`；命令 = `<Step 3 建议的轻量编译命令>`；跳过耗时测试与集成/端到端测试；只验证本次变更不引入编译/构建错误。

前端无构建环境 → 按 build-verifier 既有规则 SKIP 并标注。

> 路径说明：`output_file` 落 `{WORKSPACE}/bugfix/build/` 是 bug-fix 的命名空间（与其他技能的 `{WORKSPACE}/code/` 隔离，便于交付后只清理 `{WORKSPACE}/bugfix/`），属本技能注入的合规路径，不触发 §1.6 WARN。

## STATUS_REPORT

由 build-verifier 产出（`backend-result` / `frontend-result`：PASS | FAIL | SKIP）。编译失败 → `BLOCKED`。
