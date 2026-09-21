# Step 3: 验证同步结果

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-03-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`references/sync-layout.md`]
- output_file: `(console)`
- domain_context: 对照 sync-layout.md 验证文件落点与完整性

## 执行指令

1. 根据 Step 1 确认的工具和范围，确定预期的 skills 目录路径
   - 参照 references/sync-layout.md 中的路径表
2. 对每个目标工具，检查 skills：
   a. skills 目录是否存在
   b. 技能子目录是否已创建（列出目录名和数量）
   c. 核心技能是否存在（至少包含 workspace-init、spec-skills-refresh 等基础技能）
   d. 每个技能子目录是否非空（至少包含 SKILL.md 或等效入口文件）
3. 备份检查（辅助）：
   a. 同级 `backup/` 目录是否存在（若之前有旧数据且发生过备份）
   b. `backup/` 下时间戳子目录与遗留的 `backup-*`（若有）合计数量是否 ≤ 3（迁移完成后通常仅剩 `backup/<时间戳>/`）
   c. 最近一次时间戳子目录内的 skills 子目录情况符合新策略：
      - 仅在本地存在"与远端同名的技能"时才会出现；若本地 skills/ 全部为 DIY 技能（远端均无同名）则该子目录可不存在，**不算异常**
      - 终端日志若打印"跳过备份本地 DIY 技能"，应与 c 的实际目录形态一致
4. 汇总输出：

   | 工具 | skills 路径 | 技能数 | 备份数 | 状态 |
   |------|-----------|--------|--------|------|

5. 若有异常，标注具体问题（如：目录为空、核心技能缺失、路径不匹配等）
6. 产出末尾附加 STATUS_REPORT
