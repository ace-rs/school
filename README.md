# ACE Home

The first school for [ACE](https://github.com/prod9/ace) — the foundation that every
other school inherits from.

## What is this?

A **school** in ACE is a git repo of shared skills, conventions, and session prompts
that your team's AI coding sessions all start from. ACE Home is the *base* school: it
ships the core `ace-` prefixed skills (school management, configuration, etc.) that
every ACE setup needs.

When you run `ace school init` to create your own team school, ACE imports ACE Home by
default — so you inherit the basics for free and can focus on adding skills specific
to your team.

## Setting up your own school

Inside the new school repo:

```sh
ace school init               # scaffold a new school repo (imports ACE Home by default)
ace setup .                   # self-import: writes school = "." into ace.toml so the
                              # school's own skills load when you're editing it
ace import <owner/repo>       # pull in additional skills from other schools
```

Then push the school to a git remote your team has access to.

In each *project* repo that should use the school:

```sh
ace setup <your-org>/<your-school>
```

This clones your school, symlinks its skills into the project, and configures the
AI coding session.

Then just run:

```sh
ace
```

to start coding. ACE launches your configured backend (Claude Code by default) with
the school's skills, session prompt, and MCP servers wired in.

## What lives here

ACE Home intentionally stays minimal. It contains only the foundational `ace-` skills
required for ACE itself to operate (e.g. `ace-school` for managing schools). Anything
team- or project-specific belongs in **your** school, not here.

To extend your team's coding environment:

1. Create your school with `ace school init`.
2. Author skills under `skills/<name>/SKILL.md` in that repo.
3. Use `ace import` to bring in skills published by other teams or the community.

## Contributing

ACE Home is meant to stay small and broadly applicable. Skill PRs should be generic
enough to benefit every ACE user. Team- or domain-specific skills belong in your own
school — import them from there instead.
