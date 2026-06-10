#!/usr/bin/env bash
# =============================================================================
# spec-skills-refresh.sh
# 从 git 指定分支拉取最新技能，同步到各 AI 编程工具的全局或项目空间
# 默认仓库/分支见脚本内 DEFAULT_REPO_URL / DEFAULT_BRANCH（可用参数覆盖）
# 支持: Cursor / Kiro / Claude Code / OpenCode / Trae
#
# 用法（在 ai-coding-skills 仓库根目录执行）:
#   bash e2e/workspace/spec-skills-refresh/script/spec-skills-refresh.sh
#   bash e2e/workspace/spec-skills-refresh/script/spec-skills-refresh.sh --tool cursor --scope global --repo <URL> [--branch <分支>]
#   bash e2e/workspace/spec-skills-refresh/script/spec-skills-refresh.sh --tool "cursor kiro" --scope project
# 便携副本路径：skill-init/spec-skills-refresh/script/spec-skills-refresh.sh
# =============================================================================

set -e

CONFIG_FILE="$HOME/.oc-skills-config"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_DIR="/tmp/ai-coding-skills-$TIMESTAMP"

# 默认技能源（可被 ~/.oc-skills-config 或命令行覆盖）
DEFAULT_REPO_URL="https://github.com/pengguogo/ai-coding-skills.git"
DEFAULT_BRANCH="main"

# 技能源目录（相对于 git 仓库根目录）
SKILL_SOURCE_DIRS=(
  "e2e/knowledge-base"
  "e2e/requirement-implementation"
  "e2e/workspace"
  "tools"
)

# 备份目录与保留数量：与 <parent>/skills 同级为 <parent>/backup-skills/；超过 N 个快照则删除最旧的，仅保留最近 N 个
MAX_SKILL_BACKUPS=3

# ---- 颜色输出 ----------------------------------------------------------------
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
RED='\\033[0;31m'
CYAN='\\033[0;36m'
NC='\\033[0m'

info()    { echo -e "\${GREEN}[INFO]\${NC} $1"; }
warn()    { echo -e "\${YELLOW}[WARN]\${NC} $1"; }
error()   { echo -e "\${RED}[ERROR]\${NC} $1"; exit 1; }
section() { echo -e "\${CYAN}$1\${NC}"; }

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
    *) shift ;;
  esac
done

# ---- 读取 / 保存配置 ---------------------------------------------------------
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    REPO_URL="\${REPO_URL:-$SAVED_REPO_URL}"
    BRANCH="\${BRANCH:-$SAVED_BRANCH}"
  fi
}

save_config() {
  {
    echo "SAVED_REPO_URL=\\"$REPO_URL\\""
    echo "SAVED_BRANCH=\\"$BRANCH\\""
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
    REPO_URL="\${input:-$DEFAULT_REPO_URL}"
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
    TOOL="\${TOOL# }"  # 去掉开头空格
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

# ---- 确定各工具目标路径 ------------------------------------------------------
resolve_targets() {
  PROJECT_ROOT="$(pwd)"

  if [[ "$SCOPE" == "global" ]]; then
    CURSOR_TARGET="$HOME/.cursor/skills"
    KIRO_TARGET="$HOME/.kiro/skills"
    CLAUDE_TARGET="$HOME/.claude/skills"
    OPENCODE_TARGET="$HOME/.config/opencode/skills"
    TRAE_TARGET="$HOME/.trae/skills"
  elif [[ "$SCOPE" == "project" ]]; then
    CURSOR_TARGET="$PROJECT_ROOT/.cursor/skills"
    KIRO_TARGET="$PROJECT_ROOT/.kiro/skills"
    CLAUDE_TARGET="$PROJECT_ROOT/.claude/skills"
    OPENCODE_TARGET="$PROJECT_ROOT/.opencode/skills"
    TRAE_TARGET="$PROJECT_ROOT/.trae/skills"
  else
    error "无效的 scope: $SCOPE，必须是 global 或 project"
  fi
}

# ---- 判断是否同步某工具 ------------------------------------------------------
has_tool() {
  [[ " $TOOL " == *" $1 "* ]]
}

# ---- 备份现有技能 ------------------------------------------------------------
# 备份写入 dirname(skills)/backup-skills/backup-<时间戳>/，与 skills 同级；超过 MAX_SKILL_BACKUPS 则删除最旧快照。
prune_skill_backups() {
  local backup_root="$1"
  local keep="$MAX_SKILL_BACKUPS"
  [[ -d "$backup_root" ]] || return 0

  local -a items=()
  local f
  shopt -s nullglob
  for f in "$backup_root"/backup-*; do
    [[ -d "$f" ]] && items+=("$f")
  done
  shopt -u nullglob

  local n=\${#items[@]}
  (( n <= keep )) && return 0

  # 按目录名升序 = 时间戳从早到晚，先删列表前若干项即最旧备份
  mapfile -t sorted < <(printf '%s\\n' "\${items[@]}" | LC_ALL=C sort)
  local remove=$((n - keep))
  local i
  for ((i = 0; i < remove; i++)); do
    info "  删除最旧备份: \${sorted[$i]}"
    rm -rf "\${sorted[$i]}"
  done
}

backup_existing() {
  local target="$1"
  [[ -d "$target" && "$(ls -A "$target" 2>/dev/null)" ]] || return 0

  local parent backup_root backup_dir
  parent=$(dirname -- "$target")
  backup_root="\${parent}/backup-skills"
  backup_dir="\${backup_root}/backup-\${TIMESTAMP}"

  mkdir -p "$backup_dir"
  cp -r "$target"/. "$backup_dir/"
  # 历史版本曾把备份放在 skills 内的 .skills-backup-*，快照中不再保留这些目录
  rm -rf "$backup_dir"/.skills-backup-* 2>/dev/null || true

  info "  已备份到: $backup_dir"
  prune_skill_backups "$backup_root"
}

# ---- 从 git 拉取最新技能 -----------------------------------------------------
clone_repo() {
  info "正在从 git 拉取最新技能..."
  info "仓库: $REPO_URL"
  info "分支: $BRANCH"
  git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" \\
    || error "git clone 失败，请检查仓库地址、分支名和网络连接"
  info "拉取完成"
}

# ---- 通用：技能平铺（Cursor / Kiro / Trae）-----------------------------------
# 仅从各 SKILL_SOURCE_DIRS 下的一级子目录同步到 $target/<技能名>/，不保留 e2e/knowledge-base 等父级路径。
# 备份完成后先删除本地需要同步的技能目录，再从远端全量复制，确保本地不残留远端已删除的文件。
sync_flat() {
  local target="$1"
  local label="$2"
  declare -A SEEN_SKILL

  section "→ 同步到 $label: $target"
  mkdir -p "$target"
  backup_existing "$target"

  # ---- 第一遍：收集远端所有技能名，并删除本地同名目录 ----
  for dir in "\${SKILL_SOURCE_DIRS[@]}"; do
    local src="$TEMP_DIR/$dir"
    [[ -d "$src" ]] || continue
    for skill_dir in "$src"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      if [[ -d "$target/$skill_name" ]]; then
        rm -rf "$target/$skill_name"
        info "  已删除本地旧技能: $skill_name"
      fi
    done
  done

  # ---- 第二遍：从远端复制技能 ----
  for dir in "\${SKILL_SOURCE_DIRS[@]}"; do
    local src="$TEMP_DIR/$dir"
    if [[ ! -d "$src" ]]; then
      warn "  源目录不存在，跳过: $dir"
      continue
    fi
    for skill_dir in "$src"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      local dest="$target/$skill_name"
      if [[ -n "\${SEEN_SKILL[$skill_name]+x}" ]]; then
        warn "  技能名冲突，将合并写入: $skill_name （来源 $dir）"
      fi
      SEEN_SKILL[$skill_name]=1
      mkdir -p "$dest"
      cp -r "$skill_dir"/. "$dest/"
      info "  ✓ $skill_name ← $dir"
    done
  done
}

# ---- Claude Code / OpenCode：每个技能子目录需含 SKILL.md --------------------
# 备份完成后先删除本地需要同步的技能目录，再从远端全量复制，确保本地不残留远端已删除的文件。
sync_skill_dirs() {
  local target="$1"
  local label="$2"
  declare -A SEEN_SKILL

  section "→ 同步到 $label: $target"
  mkdir -p "$target"
  backup_existing "$target"

  # ---- 第一遍：收集远端所有技能名，并删除本地同名目录 ----
  for dir in "\${SKILL_SOURCE_DIRS[@]}"; do
    local src="$TEMP_DIR/$dir"
    [[ -d "$src" ]] || continue
    for skill_dir in "$src"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      if [[ -d "$target/$skill_name" ]]; then
        rm -rf "$target/$skill_name"
        info "  已删除本地旧技能: $skill_name"
      fi
    done
  done

  # ---- 第二遍：从远端复制技能 ----
  for dir in "\${SKILL_SOURCE_DIRS[@]}"; do
    local src="$TEMP_DIR/$dir"
    if [[ -d "$src" ]]; then
      for skill_dir in "$src"/*/; do
        [[ -d "$skill_dir" ]] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        local dest="$target/$skill_name"
        if [[ -n "\${SEEN_SKILL[$skill_name]+x}" ]]; then
          warn "  技能名冲突，将合并写入: $skill_name （来源 $dir）"
        fi
        SEEN_SKILL[$skill_name]=1
        mkdir -p "$dest"
        cp -r "$skill_dir"/. "$dest/"
        # 如果子目录内没有 SKILL.md，自动生成一个最小占位
        if [[ ! -f "$dest/SKILL.md" ]]; then
          printf -- "---\\nname: %s\\ndescription: %s skill from ai-coding-skills\\n---\\n" \\
            "$skill_name" "$skill_name" > "$dest/SKILL.md"
        fi
        info "  ✓ $skill_name ← $dir"
      done
    else
      warn "  源目录不存在，跳过: $dir"
    fi
  done
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
  has_tool cursor   && info "  Cursor    → $CURSOR_TARGET"
  has_tool kiro     && info "  Kiro      → $KIRO_TARGET"
  has_tool claude   && info "  Claude    → $CLAUDE_TARGET"
  has_tool opencode && info "  OpenCode  → $OPENCODE_TARGET"
  has_tool trae     && info "  Trae      → $TRAE_TARGET"
  echo ""
}

# ---- 主流程 ------------------------------------------------------------------
main() {
  echo ""
  echo "============================================"
  echo "  AI Coding Skills 技能自动更新工具"
  echo "============================================"

  load_config
  BRANCH="\${BRANCH:-$DEFAULT_BRANCH}"
  ask_repo_url
  ask_tool
  ask_scope
  resolve_targets
  print_targets

  clone_repo
  echo ""

  has_tool cursor   && sync_flat      "$CURSOR_TARGET"   "Cursor"
  has_tool kiro     && sync_flat      "$KIRO_TARGET"     "Kiro"
  has_tool claude   && sync_skill_dirs "$CLAUDE_TARGET"  "Claude Code"
  has_tool opencode && sync_skill_dirs "$OPENCODE_TARGET" "OpenCode"
  has_tool trae     && sync_flat      "$TRAE_TARGET"     "Trae"

  cleanup

  echo ""
  echo "============================================"
  info "技能更新完成 ✓"
  echo "============================================"
  echo ""
}

main