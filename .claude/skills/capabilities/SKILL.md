---
name: capabilities
description: Reference for available Claude Code tools, models, and features. Use when you need to understand what tools or capabilities are available in this environment.
allowed-tools: Read, Grep, Glob
---

# Claude Code Capabilities Reference

## Available Models

| Alias | Model | Best For |
|-------|-------|----------|
| `sonnet` | claude-sonnet-4-5-20250929 | Daily coding, balanced speed/quality |
| `opus` | claude-opus-4-5-20251101 | Complex reasoning, architecture |
| `haiku` | claude-3-5-haiku-20241022 | Fast, simple tasks |
| `opusplan` | Opus planning + Sonnet execution | Large multi-step tasks |

Switch models mid-session: `/model <alias>`

## Built-in Tools

| Tool | Purpose |
|------|---------|
| `Bash` | Execute shell commands |
| `Read` | Read file contents |
| `Write` | Create new files |
| `Edit` | Modify existing files |
| `Grep` | Search file contents (regex) |
| `Glob` | Find files by pattern |
| `WebFetch` | Fetch URL content |
| `WebSearch` | Search the web |
| `Task` | Launch sub-agents |
| `TodoWrite` | Track task progress |
| `AskUserQuestion` | Get user input |

## Sub-agent Types (Task Tool)

| Type | Use Case |
|------|----------|
| `general-purpose` | Complex multi-step research |
| `Explore` | Codebase exploration |
| `Plan` | Architecture/implementation planning |
| `claude-code-guide` | Questions about Claude Code itself |

## Project Configuration

- Project settings: `.claude/settings.json`
- Custom commands: `.claude/commands/`
- Skills: `.claude/skills/`
