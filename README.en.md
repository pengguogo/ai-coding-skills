# AI Coding Skills

End-to-End AI-Assisted Coding Skill System — Standardized · Traceable · Quality Built-in

---

## Overview

This repository contains a complete **E2E AI Coding Skills** system covering the full end-to-end AI coding pipeline: skill distribution, environment initialization, knowledge restoration, requirement analysis, technical design, task splitting, code implementation, and project archiving.

> This skill system is extracted and restored from the E2E AI Coding full-process report, preserving the original directory structure and file organization.

---

## Core Principles

| Principle | Description |
|------------|-------------|
| **Standardized** | Each stage strictly follows standardized workflows and specification references, ensuring consistent and auditable deliverables |
| **Traceable** | Full-chain traceability from requirements to code: REQ ID → Design Document → Task Split → Code Implementation → Archive |
| **Quality Built-in** | Quality is not an afterthought but built into every stage, with quality assurance skills running throughout the entire pipeline |

---

## Supported AI Tools

This skill system supports the following AI coding tools:

- Cursor
- Kiro
- Trae
- Claude Code
- OpenCode

---

## Pipeline Overview

The system includes **12 Skills** organized into **8 pipeline stages**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          E2E AI Coding Pipeline                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Stage 0: spec-skills-refresh                                              │
│     ↓                                                                       │
│  Stage 1: workspace-init                                                   │
│     ↓                                                                       │
│  Stage 2: code-knowledge-init → application-knowledge-init                  │
│                                → business-knowledge-init                    │
│     ↓                                                                       │
│  Stage 3: prototype-derivation → requirement-analysis                      │
│     ↓                                                                       │
│  Stage 4: fullstack-design (Backend Design → Frontend Design)              │
│     ↓                                                                       │
│  Stage 5: task-split                                                       │
│     ↓                                                                       │
│  Stage 6: fullstack-code-implementation                                    │
│     ↓                                                                       │
│  Stage 7: fullstack-code-review → project-archive                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Stage Summary

| Stage | Name | Skills | Description |
|-------|------|--------|-------------|
| 0 | Skill Distribution & Sync | `spec-skills-refresh` | Pull latest skill packages from GitHub to each AI tool |
| 1 | Environment Initialization | `workspace-init` | Batch clone repositories and switch branches |
| 2 | Knowledge Restoration | `code-knowledge-init`<br>`application-knowledge-init`<br>`business-knowledge-init` | Three-layer knowledge pipeline: Code → Application → Business |
| 3 | Requirement Analysis | `prototype-derivation`<br>`requirement-analysis` | Prototype derivation → Requirement structuring |
| 4 | Technical Design | `fullstack-design` | Backend design → Frontend design (completed in the same session) |
| 5 | Task Splitting | `task-split` | Split frontend and backend tasks, dependency analysis |
| 6 | Code Implementation | `fullstack-code-implementation` | Frontend and backend coding |
| 7 | Project Archiving | `project-archive`<br>`fullstack-code-review` | Code review → Unified archiving |

---

## Quick Start

### Prerequisites

- Git installed
- At least one supported AI coding tool installed (Cursor / Kiro / Trae / Claude Code / OpenCode)
- GitHub account with access permissions

### Step 1: Clone the Repository

```bash
git clone https://github.com/pengguogo/ai-coding-skills.git
cd ai-coding-skills
```

### Step 2: Sync Skills to Your AI Tool

```bash
# Interactive execution
bash skills/spec-skills-refresh/script/spec-skills-refresh.sh
```

Or invoke directly in your AI tool:

```
/spec-skills-refresh
```

### Step 3: Initialize Your Workspace

1. Create a `repos.txt` file in your workspace root:

```txt
# name    type    url                                          branch
my-api    app     https://github.com/org/my-api.git            main
my-web    app     https://github.com/org/my-web.git            develop
```

2. Run the initialization:

```
/workspace-init
```

### Step 4: Execute the Pipeline

```
Stage 0: /spec-skills-refresh        # Skill sync
Stage 1: /workspace-init             # Environment initialization
Stage 2: /code-knowledge-init        # Code knowledge restoration
         /application-knowledge-init # Application architecture knowledge
         /business-knowledge-init    # Business knowledge
Stage 3: /prototype-derivation       # Prototype derivation
         /requirement-analysis       # Requirement analysis
Stage 4: /fullstack-design           # Technical design
Stage 5: /task-split                 # Task splitting
Stage 6: /fullstack-code-implementation  # Code implementation
Stage 7: /fullstack-code-review      # Code review
         /project-archive            # Project archiving
```

> You don't have to run every stage. For example, if you already have requirement documents, you can start directly from Stage 4.

---

## Skill Reference

| Stage | Skill | Description | Command |
|-------|-------|-------------|---------|
| 0 | spec-skills-refresh | Skill distribution and sync | `/spec-skills-refresh` |
| 1 | workspace-init | Environment initialization | `/workspace-init` |
| 2 | code-knowledge-init | Code knowledge restoration | `/code-knowledge-init` |
| 2 | application-knowledge-init | Application architecture knowledge | `/application-knowledge-init` |
| 2 | business-knowledge-init | Business architecture knowledge | `/business-knowledge-init` |
| 3 | prototype-derivation | Prototype derivation | `/prototype-derivation` |
| 3 | requirement-analysis | Requirement analysis | `/requirement-analysis` |
| 4 | fullstack-design | Technical design | `/fullstack-design` |
| 5 | task-split | Task splitting | `/task-split` |
| 6 | fullstack-code-implementation | Code implementation | `/fullstack-code-implementation` |
| 7 | fullstack-code-review | Code review | `/fullstack-code-review` |
| 7 | project-archive | Project archiving | `/project-archive` |

---

## Directory Structure

```
ai-coding-skills/
├── README.md                           # Project README
├── wiki/                               # Wiki documentation
│   ├── Home.md
│   ├── Quick-Start.md
│   ├── Pipeline-Overview.md
│   ├── Skills-Reference.md
│   ├── Directory-Structure.md
│   ├── Best-Practices.md
│   ├── Contributing.md
│   └── FAQ.md
└── skills/                             # Skills directory
    ├── spec-skills-refresh/            # Stage 0: Skill refresh
    │   ├── SKILL.md
    │   ├── references/
    │   └── script/
    ├── workspace-init/                 # Stage 1: Workspace initialization
    │   ├── SKILL.md
    │   └── references/
    ├── code-knowledge-init/            # Stage 2: Code knowledge restoration
    │   ├── SKILL.md
    │   ├── backend/
    │   ├── frontend/
    │   ├── references/
    │   └── script/
    ├── application-knowledge-init/     # Stage 2: Application architecture
    │   ├── SKILL.md
    │   └── references/
    ├── business-knowledge-init/        # Stage 2: Business architecture
    │   ├── SKILL.md
    │   └── references/
    ├── prototype-derivation/           # Stage 3: Prototype derivation
    │   ├── SKILL.md
    │   └── references/
    ├── requirement-analysis/           # Stage 3: Requirement analysis
    │   ├── SKILL.md
    │   └── references/
    ├── fullstack-design/               # Stage 4: Technical design
    │   ├── SKILL.md
    │   └── references/
    ├── task-split/                     # Stage 5: Task splitting
    │   ├── SKILL.md
    │   └── references/
    ├── fullstack-code-implementation/  # Stage 6: Code implementation
    │   ├── SKILL.md
    │   ├── backend/
    │   ├── frontend/
    │   └── templates/
    ├── fullstack-code-review/          # Stage 7: Code review
    │   ├── SKILL.md
    │   ├── backend/
    │   ├── common/
    │   └── frontend/
    └── project-archive/                # Stage 7: Project archiving
        ├── SKILL.md
        └── references/
```

### Skill Structure

Each skill follows a unified template structure:

```
skill-name/
├── SKILL.md              # Skill definition (trigger conditions, workflow, deliverables, constraints)
└── references/           # Reference documents (specifications, templates, checklists)
    └── *.md
```

Some skills also include:
- `script/` — Executable scripts (e.g., scanning scripts, sync scripts)
- `templates/` — Code templates (e.g., Vue component templates, API service templates)
- `backend/` / `frontend/` / `common/` — Categorized documents

---

## Data Artifacts Directory

Artifacts produced during requirement implementation are organized as follows:

```
ocspec-<xxx>/
├── knowledge/                    # Knowledge base (continuously accumulated)
│   ├── code/<project-name>/      # Code knowledge
│   ├── application/              # Application architecture knowledge
│   └── business/                 # Business knowledge
└── requirements/
    └── <requirement-name>_<yyyymmdd>/
        ├── requirement/          # Requirement documents
        ├── design/               # Design documents
        ├── task/                 # Task splitting
        ├── review/               # Code review
        └── archive/              # Archive documents
```

---

## Best Practices

### Session Management

Since AI context windows are limited, it is recommended to:

1. Use a separate session for each pipeline stage
2. The three knowledge restoration stages can be combined into one session
3. Backend and frontend design should be in the same session
4. For code implementation with many tasks, split into multiple sessions (by module)
5. Use a separate session for the archiving stage

### Common Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| Skipping knowledge restoration | AI lacks project understanding, low output quality | Always execute Stage 2 |
| Designing backend and frontend separately | Interface misalignment, integration difficulties | Complete in the same session |
| Coding without task splitting | Uncontrollable progress, missed requirements | Run task-split before implementation |
| Archiving without review | Quality issues carried into archive | Review first, then archive |
| Running the full pipeline at once | Context too long, quality degrades | Execute in stages and sessions |

---

## Contributing

We welcome all forms of contribution!

### Report Issues

If you find a bug or have an improvement suggestion, please submit an [Issue](https://github.com/pengguogo/ai-coding-skills/issues).

### Submit Code

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add some feature'`
4. Push the branch: `git push origin feature/my-feature`
5. Submit a Pull Request

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat` (new feature), `fix` (bug fix), `docs` (documentation), `style` (formatting), `refactor` (refactoring), `test` (testing), `chore` (build/tools)

---

## License

MIT
