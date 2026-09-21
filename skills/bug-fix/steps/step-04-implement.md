# Step 4: 实施修复（含单测复现）

## 元信息

- execution-mode: inline
- checkpoint: checkpoints/step-04-checkpoint.md
- checkpoint-level: L1

## 参数

- input_files: [`{BASE_DIR}/bug/<id>-<slug>-fix-plan.md`, `{WORKSPACE}/bugfix/02-locate-and-impact.md`]
- output_file: `{WORKSPACE}/bugfix/04-implement-diff.md`
- domain_context: 按已确认方案小范围改码，纯逻辑 bug 内置写并执行最小单测，逐仓比对影响面

## 执行指令

用户确认改前门禁后执行。

1. 按方案小范围改码：仅改 `<id>-<slug>-fix-plan.md` 允许清单内文件，所有改动处标注 `@AI-Generate`。
2. 纯逻辑 bug（`root-cause-pure-logic=是` 且有测试框架）：先写复现 bug 的最小单测（改前断言失败），改后转绿；由本 inline 步骤直接执行单测命令（`mvn test -Dtest=xxx` / `jest <file>`），结果写入 `{WORKSPACE}/bugfix/unit-test-result.md`。无测试框架则跳过，记 `[无测试基建]`。
3. 逐仓比对：对 `repo_paths` 每个仓库执行 `git -C <repo> diff --name-only HEAD`，用 `(仓库, 路径)` 复合键与允许清单比对，超出 → 待确认项 + WARN。

## 产出结构

```markdown
# 实施修复（<id> <slug>）

## 1. 实际改动清单
| 仓库 | 文件路径 | @AI-Generate | 说明 |

## 2. 逐仓 git diff 比对
| 仓库 | diff 文件数 | 是否 ⊆ 允许清单 | 超出项 |

## 3. 单测复现（纯逻辑 bug）
- 单测文件 / 改前断言失败 / 改后执行结果（转绿 或 [无测试基建]）
```

## STATUS_REPORT

改动超出允许清单 → `WARN`；否则 `OK`。
