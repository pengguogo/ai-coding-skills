# Step 7: 收尾记录与静态因果自证 [最终交付]

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-07-final.md
- checkpoint-level: L2

## 参数

- input_files: [`{WORKSPACE}/bugfix/02-locate-and-impact.md`, `{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`, `{WORKSPACE}/bugfix/04-implement-diff.md`, `{WORKSPACE}/bugfix/build/05-build-verify.md`, `{WORKSPACE}/bugfix/review/06-code-review.md`（L3 时）]
- output_file: `{BASE_DIR}/bug/bug-fix-log.md`（追加式）
- reference_files: [`references/bugfix-log-template.md`]
- domain_context: 产出并核对静态因果自证、追加 bug-fix-log、标记 knowledge 偏离

## 执行指令

本步是 Phase record 末步，`halt-after: true` → 完成后输出最终交付报告。

1. **静态因果自证**（强制）：产出「根因 → 本次修改 → 原触发路径上现象为何消失」三环节，每环引用文件+行号。三环缺一或缺引用 → WARN。

   ```markdown
   ## 静态因果自证
   - 根因：<文件:行号> —— <为何出错>
   - 本次修改：<文件:行号> —— <改了什么>
   - 现象消失：<文件:行号> —— <为何不再复现>
   ```

   > 偶发 bug（Step 1「是否可稳定复现=否」）：「现象消失」环改为论证「原触发条件下的代码路径已修正」，并标注 `[偶发-无法确证消失，待线上观察]`，不因无法复现而判 WARN。

2. **追加 bug-fix-log**（按 `bugfix-log-template.md` 追加到 `{BASE_DIR}/bug/bug-fix-log.md`，不覆盖既有行）：
   - 验证方式列：单测复现转绿 / 静态自证+人工回归点 / `[无测试基建]`
   - 回归审查列：L3 取 `06-code-review.md` 判定；非 L3 标 `N/A(非L3)`
   - knowledge 偏离列：发现代码偏离 knowledge → 标 `是 → 建议 project-archive 更新 <文档>`（不回灌，仅标记）

3. 运行时类 bug：在最终交付报告中呈现人工回归点清单，标注「运行时验证需人工执行」。

4. 终稿不含 STATUS_REPORT 块。

5. **清理延后**：交付报告结尾标注「中间产物 `_workspace/bugfix/` 暂未清理，`bug/` 持久留底保留」并提示用户回归；Halt 后按 SKILL.md 清理说明处理用户回复。

## STATUS_REPORT

因果自证三环齐全且有引用 → `OK`；缺环 → `WARN`。完成后 Scheduler Halt，输出最终交付报告；清理待用户回执「回归通过」后执行。
