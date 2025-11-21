# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**CRITICAL**

- Always update CLAUDE.md and README.md When changing a feature that requires major work or essential changes to the content of the document. Ignore minor changes.
- Never create branches or make commits autonomously - always ask the user to do it manually
- ⚠️ MANDATORY SKILL LOADING - BEFORE editing files, READ relevant skills:
  - .ts → typescript
  - .tsx → typescript + react
  - .go → golang
  - .test.ts, .spec.ts → typescript-test + typescript
  - .test.go, \_test.go → go-test + golang
  - .graphql, resolvers, schema → graphql + typescript
  - package.json, go.mod → dependency-management
  - Path-based (add as needed): apps/web/** → nextjs, apps/api/** → nestjs
  - Skills path: .claude/skills/{name}/SKILL.md
  - 📚 REQUIRED: Display loaded skills at response END: `📚 Skills loaded: {skill1}, {skill2}, ...`
- If Claude repeats the same mistake, add an explicit ban to CLAUDE.md (Failure-Driven Documentation)
- Respect workspace tooling conventions
  - Always use workspace's package manager (detect from lock files: pnpm-lock.yaml → pnpm, yarn.lock → yarn, package-lock.json → npm)
  - Prefer just commands when task exists in justfile or adding recurring tasks
  - Direct command execution acceptable for one-off operations

**IMPORTANT**

- Avoid unfounded assumptions - verify critical details
  - Don't guess file paths - use Glob/Grep to find them
  - Don't guess API contracts or function signatures - read the actual code
  - Reasonable inference based on patterns is OK
  - When truly uncertain about important decisions, ask the user
- Always gather context before starting work
  - Read related files first (don't work blind)
  - Check existing patterns in codebase
  - Review project conventions (naming, structure, etc.)
- Always assess issue size and scope accurately - avoid over-engineering simple tasks
  - Apply to both implementation and documentation
  - Verbose documentation causes review burden for humans
