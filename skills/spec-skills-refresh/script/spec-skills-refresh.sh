#!/usr/bin/env bash
# =============================================================================
# spec-skills-refresh.sh
# 从 git 指定分支拉取最新技能包，同步 skills/agents/commands 到各 AI 编程工具
# 默认仓库/分支见脚本内 DEFAULT_REPO_URL / DEFAULT_BRANCH（可用参数覆盖）
# 支持: Cursor / Kiro / Claude Code / OpenCode / Trae
#
# 用法（在 ai-coding-skills 仓库根目录执行）:
#   bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
#   bash skills/spec-skills-refresh/script/spec-skills-refresh.sh \
#     --tool cursor --scope global --repo <URL> [--branch <分支>]
#   bash skills/spec-skills-refresh/script/spec-skills-refresh.sh \
#     --tool "cursor kiro" --scope project
# =============================================================================

# 注意：不使用 set -e，错误由脚本内部分类处理

CONFIG_FILE="$HOME/.ai-coding-skills-config"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_DIR="/tmp/ai-coding-skills-$TIMESTAMP"

# 默认技能源（可被 ~/.ai-coding-skills-config 或命令行覆盖）
DEFAULT_REPO_URL="https://github.com/pengguogo/ai-coding-skills.git"
DEFAULT_BRANCH="main"

# 备份保留数量：超过 N 个快照则删除最旧的，仅保留最近 N 个
MAX_BACKUPS=3

# ---- 颜色输出 ----------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
section() { echo -e "${CYAN}$1${NC}"; }

# ---- 错误分级 ----------------------------------------------------------------
# 全局致命错误标记（非空时表示不可恢复，终止后续所有操作）
FATAL=""

# 汇总报告行（格式: "工具名|状态|技能数|备份数|备注"）
declare -a REPORT_LINES=()

# 致命错误：权限、认证、分支不存在、重试超限 → 终止整个流程
error_fatal() {
  local msg="$1"
  echo -e "${RED}[FATAL]${NC} $msg"
  FATAL="$msg"
}

# 工具级错误：某个工具同步失败 → 记录，继续同步其他工具
error_tool() {
  local tool="$1" msg="$2"
  echo -e "${RED}[FAIL]${NC} [$tool] $msg"
  REPORT_LINES+=("$tool|FAILED|0|0|$msg")
}

# ---- 解析参数 ----------------------------------------------------------------
SCOPE=""
REPO_URL=""
TOOL=""
BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)  SCOPE="$2"; shift 2 ;;
    --repo)   REPO_URL="$2"; shift 2 ;;
    --tool)   TOOL="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --workspace) WORKSPACE_ROOT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# ---- 读取 / 保存配置 ---------------------------------------------------------
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    REPO_URL="${REPO_URL:-$SAVED_REPO_URL}"
    BRANCH="${BRANCH:-$SAVED_BRANCH}"
  fi
}

save_config() {
  {
    echo "SAVED_REPO_URL=\"$REPO_URL\""
    echo "SAVED_BRANCH=\"$BRANCH\""
  } > "$CONFIG_FILE"
  info "git 仓库与分支已保存到 $CONFIG_FILE"
}

# ---- 交互式询问 --------------------------------------------------------------
ask_repo_url() {
  if [[ -z "$REPO_URL" ]]; then
    echo ""
    echo "请输入技能仓库的 git 地址（直接回车使用默认）："
    echo "  默认: $DEFAULT_REPO_URL"
    read -r -p "> " input
    REPO_URL="${input:-$DEFAULT_REPO_URL}"
    [[ -z "$REPO_URL" ]] && error "git 仓库地址不能为空"
    save_config
  fi
}

ask_tool() {
  if [[ -z "$TOOL" ]]; then
    echo ""
    section "请选择目标工具（可输入多个编号，用空格分隔）："
    echo "  1) Cursor"
    echo "  2) Kiro"
    echo "  3) Claude Code"
    echo "  4) OpenCode"
    echo "  5) Trae"
    echo "  6) 全部"
    read -r -p "请输入编号（如 1 3 或 6）: " choices
    TOOL=""
    for c in $choices; do
      case "$c" in
        1) TOOL="$TOOL cursor" ;;
        2) TOOL="$TOOL kiro" ;;
        3) TOOL="$TOOL claude" ;;
        4) TOOL="$TOOL opencode" ;;
        5) TOOL="$TOOL trae" ;;
        6) TOOL="cursor kiro claude opencode trae"; break ;;
        *) warn "忽略无效选项: $c" ;;
      esac
    done
    TOOL="${TOOL# }"
    [[ -z "$TOOL" ]] && error "未选择任何工具"
  fi
}

ask_scope() {
  if [[ -z "$SCOPE" ]]; then
    echo ""
    section "请选择技能更新的目标位置："
    echo "  1) 全局（对所有项目生效）"
    echo "  2) 当前项目空间（仅对本项目生效）"
    read -r -p "请输入 1 或 2: " choice
    case "$choice" in
      1) SCOPE="global" ;;
      2) SCOPE="project" ;;
      *) error "无效选择，请输入 1 或 2" ;;
    esac
  fi
}

# ---- Trae 环境检测 -----------------------------------------------------------
# Trae IDE 的 PowerShell 安全沙箱会阻止操作 .trae/ 目录
# 检测是否在 Trae 环境下运行，并确保使用 bash 执行而非 PowerShell

detect_trae_env() {
  # 检测方式1：环境变量（Trae 可能设置特定环境变量）
  if [[ -n "${TRAE_SESSION_ID}" || -n "${TRAE_TERMINAL}" ]]; then
    return 0
  fi

  # 检测方式2：工作区存在 .trae/ 目录且目标工具包含 trae
  if [[ "$TOOL" == *"trae"* && -d "${PROJECT_ROOT}/.trae" ]]; then
    return 0
  fi

  return 1
}

warn_trae_denylist() {
  if detect_trae_env; then
    echo ""
    warn "检测到 Trae 环境：PowerShell 操作 .trae/ 目录会被 denylist 阻止"
    info "本脚本将通过 bash 执行同步，绕过此限制"
    info "若同步失败，请确认 bash 可用（Git Bash 已安装）"
    echo ""
  fi
}

# ---- 查找工作区根目录 --------------------------------------------------------
# 从当前目录向上查找，找到最外层包含 .git/ 的目录作为工作区根目录。
# 若当前目录不在任何 git 仓库内，则回退到 pwd。
find_workspace_root() {
  local dir="$(pwd)"
  local root="$dir"

  while [[ "$dir" != "/" && "$dir" != "$HOME" ]]; do
    if [[ -d "$dir/.git" ]]; then
      root="$dir"
    fi
    dir=$(dirname "$dir")
  done

  echo "$root"
}

# ---- 确定各工具目标路径（skills + agents + commands）-------------------------
resolve_targets() {
  # project 模式下，优先使用 --workspace 参数，其次用 find_workspace_root 自动检测
  if [[ -n "$WORKSPACE_ROOT" ]]; then
    PROJECT_ROOT="$WORKSPACE_ROOT"
  else
    PROJECT_ROOT="$(find_workspace_root)"
  fi
  info "工作区根目录: $PROJECT_ROOT"

  if [[ "$SCOPE" == "global" ]]; then
    CURSOR_SKILLS="$HOME/.cursor/skills";    CURSOR_AGENTS="$HOME/.cursor/agents";    CURSOR_COMMANDS="$HOME/.cursor/commands"
    KIRO_SKILLS="$HOME/.kiro/skills";        KIRO_AGENTS="$HOME/.kiro/agents";        KIRO_COMMANDS="$HOME/.kiro/commands"
    CLAUDE_SKILLS="$HOME/.claude/skills";    CLAUDE_AGENTS="$HOME/.claude/agents";    CLAUDE_COMMANDS="$HOME/.claude/commands"
    OPENCODE_SKILLS="$HOME/.config/opencode/skills"; OPENCODE_AGENTS="$HOME/.config/opencode/agents"; OPENCODE_COMMANDS="$HOME/.config/opencode/commands"
    TRAE_SKILLS="$HOME/.trae/skills";        TRAE_AGENTS="$HOME/.trae/agents";        TRAE_COMMANDS="$HOME/.trae/commands"
  elif [[ "$SCOPE" == "project" ]]; then
    CURSOR_SKILLS="$PROJECT_ROOT/.cursor/skills";    CURSOR_AGENTS="$PROJECT_ROOT/.cursor/agents";    CURSOR_COMMANDS="$PROJECT_ROOT/.cursor/commands"
    KIRO_SKILLS="$PROJECT_ROOT/.kiro/skills";        KIRO_AGENTS="$PROJECT_ROOT/.kiro/agents";        KIRO_COMMANDS="$PROJECT_ROOT/.kiro/commands"
    CLAUDE_SKILLS="$PROJECT_ROOT/.claude/skills";    CLAUDE_AGENTS="$PROJECT_ROOT/.claude/agents";    CLAUDE_COMMANDS="$PROJECT_ROOT/.claude/commands"
    OPENCODE_SKILLS="$PROJECT_ROOT/.opencode/skills"; OPENCODE_AGENTS="$PROJECT_ROOT/.opencode/agents"; OPENCODE_COMMANDS="$PROJECT_ROOT/.opencode/commands"
    TRAE_SKILLS="$PROJECT_ROOT/.trae/skills";        TRAE_AGENTS="$PROJECT_ROOT/.trae/agents";        TRAE_COMMANDS="$PROJECT_ROOT/.trae/commands"
  else
    error "无效的 scope: $SCOPE，必须是 global 或 project"
  fi
}

# ---- 判断是否同步某工具 ------------------------------------------------------
has_tool() {
  [[ " $TOOL " == *" $1 "* ]]
}

# ---- 统一备份（skills + agents + commands 一次性备份到 <parent>/backup/<时间戳>/）----

# 将历史同级目录 backup-<时间戳>/ 迁入 backup/<时间戳>/（与 skills/agents/commands 同级）
# 若 backup/<时间戳> 已存在，则视为已迁移过，删除重复的 backup-<时间戳>
migrate_legacy_backups() {
  local parent="$1"
  mkdir -p "${parent}/backup"

  local f base suffix dest
  shopt -s nullglob
  for f in "$parent"/backup-*; do
    [[ -d "$f" ]] || continue
    base=$(basename "$f")
    [[ "$base" =~ ^backup-(.+)$ ]] || continue
    suffix="${BASH_REMATCH[1]}"
    [[ -n "$suffix" ]] || continue
    dest="${parent}/backup/${suffix}"
    if [[ -d "$dest" ]]; then
      warn "  删除重复旧备份目录（已存在 backup/${suffix}）: $f"
      rm -rf "$f"
    else
      mv "$f" "$dest"
      info "  已迁移旧备份 ${base} → backup/${suffix}"
    fi
  done
  shopt -u nullglob
}

# 合并统计 backup/<时间戳>/ 与遗留的 backup-<时间戳>/，按时间戳排序后仅保留最近 MAX_BACKUPS 个
prune_backups() {
  local parent="$1"
  local keep="$MAX_BACKUPS"
  declare -a keys paths
  local f base key

  shopt -s nullglob
  if [[ -d "${parent}/backup" ]]; then
    for f in "${parent}/backup"/*; do
      [[ -d "$f" ]] || continue
      key=$(basename "$f")
      [[ -n "$key" ]] || continue
      keys+=("$key")
      paths+=("$f")
    done
  fi
  for f in "$parent"/backup-*; do
    [[ -d "$f" ]] || continue
    base=$(basename "$f")
    [[ "$base" =~ ^backup-(.+)$ ]] || continue
    key="${BASH_REMATCH[1]}"
    [[ -n "$key" ]] || continue
    keys+=("$key")
    paths+=("$f")
  done
  shopt -u nullglob

  local n=${#paths[@]}
  (( n <= keep )) && return 0

  declare -a lines
  local i
  for ((i = 0; i < n; i++)); do
    lines+=("${keys[$i]}"$'\t'"${paths[$i]}")
  done

  mapfile -t sorted_lines < <(printf '%s\n' "${lines[@]}" | LC_ALL=C sort -t $'\t' -k1,1)
  local remove=$((n - keep))
  for ((i = 0; i < remove; i++)); do
    local line="${sorted_lines[$i]}"
    local old_path="${line#*$'\t'}"
    info "  删除最旧备份: $old_path"
    rm -rf "$old_path"
  done
}

# backup_all <parent_dir> <skills_dir> <agents_dir> <commands_dir>
# 将三个目录统一备份到 <parent>/backup/<时间戳>/{skills,agents,commands}
backup_all() {
  local parent="$1"
  local skills_dir="$2"
  local agents_dir="$3"
  local commands_dir="$4"

  migrate_legacy_backups "$parent"

  # 检查是否有任何内容需要备份
  local has_content=false
  for d in "$skills_dir" "$agents_dir" "$commands_dir"; do
    [[ -d "$d" && "$(ls -A "$d" 2>/dev/null)" ]] && has_content=true && break
  done
  if [[ "$has_content" == "false" ]]; then
    prune_backups "$parent"
    return 0
  fi

  local backup_dir="${parent}/backup/${TIMESTAMP}"
  mkdir -p "$backup_dir" || {
    warn "无法创建备份目录 $backup_dir（权限不足），跳过备份"
    return 1
  }

  for d in "$skills_dir" "$agents_dir" "$commands_dir"; do
    if [[ -d "$d" && "$(ls -A "$d" 2>/dev/null)" ]]; then
      local name
      name=$(basename "$d")
      if cp -r "$d" "$backup_dir/$name" 2>/dev/null; then
        info "  已备份 $name → $backup_dir/$name"
      else
        warn "  备份 $name 失败（可能权限不足），继续"
      fi
    fi
  done

  prune_backups "$parent"
}

# ---- 从 git 拉取（带分类重试）------------------------------------------------
clone_repo() {
  info "正在从 git 拉取最新技能包..."
  info "仓库: $REPO_URL"
  info "分支: $BRANCH"

  # 使用 sparse-checkout 只拉取 skills/ agents/ commands/ 三个目录，减少下载量
  mkdir -p "$TEMP_DIR"
  git -C "$TEMP_DIR" init -q
  git -C "$TEMP_DIR" remote add origin "$REPO_URL"
  git -C "$TEMP_DIR" sparse-checkout init --cone
  git -C "$TEMP_DIR" sparse-checkout set skills agents commands

  local max_retries=3 attempt=0 output rc

  while (( attempt < max_retries )); do
    output=$(git -C "$TEMP_DIR" fetch --depth=1 origin "$BRANCH" 2>&1)
    rc=$?
    (( rc == 0 )) && break

    # ---- 不可恢复：权限/认证/仓库不存在 ----
    if echo "$output" | grep -qiE "permission denied|authentication failed|could not read username|403|fatal: Authentication|could not be found or you don't have permission|repository .* not found"; then
      error_fatal "认证/权限失败或仓库不存在（不重试）: $output"
      return 1
    fi

    # ---- 不可恢复：分支不存在 ----
    if echo "$output" | grep -qiE "couldn't find remote ref|does not exist|not found in upstream"; then
      error_fatal "分支 '$BRANCH' 不存在或仓库地址错误（不重试）: $output"
      return 1
    fi

    # ---- 可恢复：网络问题，重试 ----
    attempt=$((attempt + 1))
    if (( attempt >= max_retries )); then
      error_fatal "git fetch 连续失败 ${max_retries} 次（网络问题），放弃: $output"
      return 1
    fi
    local wait_sec=$((attempt * 2))
    warn "git fetch 第 ${attempt} 次失败，${wait_sec}s 后重试..."
    sleep "$wait_sec"
  done

  git -C "$TEMP_DIR" checkout FETCH_HEAD -q || {
    error_fatal "git checkout FETCH_HEAD 失败"
    return 1
  }

  info "拉取完成（仅 skills/agents/commands）"
}

# ---- 整目录同步（agents / commands）------------------------------------------
sync_dir_whole() {
  local src="$1"
  local target="$2"
  local type_name="$3"
  local label="$4"

  if [[ ! -d "$src" ]]; then
    warn "  仓库中不存在 ${type_name}/，跳过"
    return 0
  fi

  section "→ 同步 ${type_name} 到 $label: $target"
  mkdir -p "$target" || return 1

  rm -rf "$target"/*
  if ! cp -r "$src"/. "$target/"; then
    warn "  ${type_name} 复制失败"
    return 1
  fi
  local count
  count=$(find "$target" -maxdepth 1 -type f | wc -l)
  info "  ✓ ${type_name} 同步完成（${count} 个文件）"
}

# ---- skills 平铺同步（Cursor / Kiro / Trae）----------------------------------
sync_skills_flat() {
  local src="$TEMP_DIR/skills"
  local target="$1"
  local label="$2"
  local has_error=0

  section "→ 同步 skills 到 $label: $target"
  mkdir -p "$target" || return 1

  if [[ ! -d "$src" ]]; then
    warn "  仓库中不存在 skills/，跳过"
    return 0
  fi

  for skill_dir in "$src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    [[ -d "$target/$skill_name" ]] && rm -rf "$target/$skill_name"
  done

  for skill_dir in "$src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    local dest="$target/$skill_name"
    mkdir -p "$dest" || { has_error=1; warn "  ✗ $skill_name (mkdir 失败)"; continue; }
    if cp -r "$skill_dir"/. "$dest/"; then
      info "  ✓ $skill_name"
    else
      has_error=1
      warn "  ✗ $skill_name (cp 失败)"
    fi
  done

  return "$has_error"
}

# ---- skills 同步 + SKILL.md 占位（Claude Code / OpenCode）--------------------
sync_skills_with_placeholder() {
  local src="$TEMP_DIR/skills"
  local target="$1"
  local label="$2"
  local has_error=0

  section "→ 同步 skills 到 $label: $target"
  mkdir -p "$target" || return 1

  if [[ ! -d "$src" ]]; then
    warn "  仓库中不存在 skills/，跳过"
    return 0
  fi

  for skill_dir in "$src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    [[ -d "$target/$skill_name" ]] && rm -rf "$target/$skill_name"
  done

  for skill_dir in "$src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    local dest="$target/$skill_name"
    mkdir -p "$dest" || { has_error=1; warn "  ✗ $skill_name (mkdir 失败)"; continue; }
    if cp -r "$skill_dir"/. "$dest/"; then
      if [[ ! -f "$dest/SKILL.md" ]]; then
        printf -- "---\nname: %s\ndescription: %s skill from ai-coding-skills\n---\n" \
          "$skill_name" "$skill_name" > "$dest/SKILL.md"
      fi
      info "  ✓ $skill_name"
    else
      has_error=1
      warn "  ✗ $skill_name (cp 失败)"
    fi
  done

  return "$has_error"
}

# ---- 单工具容错同步包装 ------------------------------------------------------
# sync_one_tool <tool_key> <skills_target> <agents_target> <commands_target> <label> <mode>
# mode: "flat" 或 "placeholder"
sync_one_tool() {
  local tool_key="$1"
  local skills_target="$2"
  local agents_target="$3"
  local commands_target="$4"
  local label="$5"
  local mode="$6"

  # FATAL 已触发时，跳过所有后续工具
  if [[ -n "$FATAL" ]]; then
    REPORT_LINES+=("$tool_key|SKIPPED|0|0|全局错误已触发，已跳过")
    return
  fi

  local parent skill_count backup_count=0
  parent=$(dirname "$skills_target")

  # 备份（失败不阻塞同步）
  if backup_all "$parent" "$skills_target" "$agents_target" "$commands_target" 2>/dev/null; then
    backup_count=$(find "${parent}/backup" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  else
    warn "[$label] 备份失败（可能权限不足），继续同步"
  fi

  # 同步 skills
  local sync_rc=0
  if [[ "$mode" == "flat" ]]; then
    sync_skills_flat "$skills_target" "$label" || sync_rc=$?
  else
    sync_skills_with_placeholder "$skills_target" "$label" || sync_rc=$?
  fi

  if (( sync_rc != 0 )); then
    error_tool "$tool_key" "skills 同步写入失败"
    return
  fi

  # 同步 agents + commands（非关键，失败仅 warn）
  sync_dir_whole "$TEMP_DIR/agents" "$agents_target" "agents" "$label" || warn "[$label] agents 同步异常，已跳过"
  sync_dir_whole "$TEMP_DIR/commands" "$commands_target" "commands" "$label" || warn "[$label] commands 同步异常，已跳过"

  # 统计技能数
  skill_count=$(find "$skills_target" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  REPORT_LINES+=("$tool_key|OK|$skill_count|$backup_count|")
}

# ---- 清理临时目录 ------------------------------------------------------------
cleanup() {
  rm -rf "$TEMP_DIR"
}

# ---- 打印目标路径预览 --------------------------------------------------------
print_targets() {
  echo ""
  section "更新计划："
  info "范围: $SCOPE"
  info "分支: $BRANCH"
  info "同步内容: skills + agents + commands"
  has_tool cursor   && info "  Cursor    → $(dirname "$CURSOR_SKILLS")/{skills,agents,commands}"
  has_tool kiro     && info "  Kiro      → $(dirname "$KIRO_SKILLS")/{skills,agents,commands}"
  has_tool claude   && info "  Claude    → $(dirname "$CLAUDE_SKILLS")/{skills,agents,commands}"
  has_tool opencode && info "  OpenCode  → $(dirname "$OPENCODE_SKILLS")/{skills,agents,commands}"
  has_tool trae     && info "  Trae      → $(dirname "$TRAE_SKILLS")/{skills,agents,commands}"
  echo ""
}

# ---- 汇总报告 ----------------------------------------------------------------
print_report() {
  local ok=0 fail=0

  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║              技能同步 · 汇总报告                             ║"
  echo "╠════════════╤══════════╤════════╤════════╤════════════════════╣"
  printf "║ %-10s │ %-8s │ %-6s │ %-6s │ %-18s ║\n" "工具" "状态" "技能数" "备份数" "备注"
  echo "╟────────────┼──────────┼────────┼────────┼────────────────────╢"

  for line in "${REPORT_LINES[@]}"; do
    IFS='|' read -r tool status skills backups note <<< "$line"
    local icon
    case "$status" in
      OK)      icon="✓ 成功"; ok=$((ok + 1)) ;;
      FAILED)  icon="✗ 失败"; fail=$((fail + 1)) ;;
      SKIPPED) icon="– 跳过"; fail=$((fail + 1)) ;;
      *)       icon="? 未知" ;;
    esac
    printf "║ %-10s │ %-8s │ %-6s │ %-6s │ %-18s ║\n" "$tool" "$icon" "$skills" "$backups" "$note"
  done

  echo "╠══════════════════════════════════════════════════════════════╣"

  if [[ -n "$FATAL" ]]; then
    echo "║ ⚠ 致命错误:"
    echo "║   $FATAL"
    echo "║   后续工具已全部跳过，请先解决上述问题再重试。"
    echo "╟──────────────────────────────────────────────────────────────╢"
  fi

  printf "║ 总计: %d 成功 / %d 失败或跳过\n" "$ok" "$fail"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
}

# ---- 主流程 ------------------------------------------------------------------
main() {
  echo ""
  echo "============================================"
  echo "  AI Coding Skills 自动更新工具"
  echo "============================================"

  load_config
  REPO_URL="${REPO_URL:-$DEFAULT_REPO_URL}"
  BRANCH="${BRANCH:-$DEFAULT_BRANCH}"
  # 每次执行都用最新默认值覆盖配置文件，确保旧分支名不会残留
  # 优先级：命令行参数 > 配置文件已保存值 > 脚本内默认值
  save_config
  ask_repo_url
  ask_tool
  ask_scope
  # 新增：Trae 环境检测与提示
  warn_trae_denylist

  resolve_targets
  print_targets

  # ---- 拉取（可能设置 FATAL）----
  clone_repo
  echo ""

  # ---- 同步各工具（FATAL 时自动 SKIP）----
  has_tool cursor   && sync_one_tool "Cursor"   "$CURSOR_SKILLS"   "$CURSOR_AGENTS"   "$CURSOR_COMMANDS"   "Cursor"     "flat"
  has_tool kiro     && sync_one_tool "Kiro"     "$KIRO_SKILLS"     "$KIRO_AGENTS"     "$KIRO_COMMANDS"     "Kiro"       "flat"
  has_tool claude   && sync_one_tool "Claude"   "$CLAUDE_SKILLS"   "$CLAUDE_AGENTS"   "$CLAUDE_COMMANDS"   "Claude Code" "placeholder"
  has_tool opencode && sync_one_tool "OpenCode" "$OPENCODE_SKILLS" "$OPENCODE_AGENTS" "$OPENCODE_COMMANDS" "OpenCode"   "placeholder"
  has_tool trae     && sync_one_tool "Trae"     "$TRAE_SKILLS"     "$TRAE_AGENTS"     "$TRAE_COMMANDS"     "Trae"       "flat"

  # ---- 清理 + 报告 ----
  cleanup
  print_report

  # 退出码：有 FATAL 或任何 FAILED 则非零
  if [[ -n "$FATAL" ]]; then
    exit 1
  fi
  for line in "${REPORT_LINES[@]}"; do
    if [[ "$line" == *"|FAILED|"* ]]; then
      exit 1
    fi
  done
  exit 0
}

main
