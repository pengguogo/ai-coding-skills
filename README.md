# AI Coding Skills

> [简体中文](README.zh.md) | **English**

An end-to-end, scheduler-driven skill system for AI coding assistants. It covers workspace setup, knowledge extraction, requirements, architecture and full-stack design, implementation, review, bug fixing, delivery auditing, archiving, specialized analysis, and document processing.

## Repository layout

| Directory | Purpose | Inventory |
| --- | --- | ---: |
| `skills/` | Main pipelines, cross-cutting quality workflows, and document tools | 19 |
| `analysis/` | Code constraints, defect root-cause, and SQL impact analysis | 3 |
| `arch/` | Business-domain architecture visualization | 1 |
| `tools/` | Meta-skills for designing new skills | 1 |
| `agents/` | Shared execution roles | 24 |
| `commands/` | Shared scheduler protocol and initialization scripts | 1 protocol |

## Main pipelines

```text
workspace-init
  -> code-knowledge-init
  -> application-knowledge-init
  -> business-knowledge-init

prototype-derivation (optional)
  -> requirement-analysis | product-requirement-analysis
  -> fullstack-design
  -> task-split
  -> fullstack-code-implementation
  -> fullstack-code-review
  -> project-archive
```

Cross-cutting workflows include `knowledge-recheck` and `bug-fix`. Specialized, self-contained skills live under `analysis/`, `arch/`, and `tools/`. Document helpers support PDF, DOCX, XLSX, and PPTX files.

## Quick start

```bash
git clone https://github.com/pengguogo/ai-coding-skills.git
cd ai-coding-skills
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

The refresh script defaults to this GitHub repository and the `main` branch. It uses sparse checkout to distribute `skills/`, `agents/`, and `commands/` to Cursor, Kiro, Claude Code, OpenCode, or Trae in global or project scope.

## Architecture

The shared runtime is organized into four execution layers plus a scheduler:

- L4 Goal: each skill's `SKILL.md`
- L3 Step: ordered declarations under `steps/`
- L2 Agent: shared or skill-private role definitions
- L1 Primitive: editor tools for files, search, and shell execution
- Scheduler: `commands/scheduler-protocol.md`

See the [Chinese overview](README.zh.md) for the complete skill catalog, workflow details, path variables, checkpoints, and delivery model. Additional guides are available in the [Wiki](wiki/Home.md).

## License and third-party content

Check individual skill directories for their own license files and upstream notices. Document-processing skills may contain third-party assets with separate terms.
