# ICARTSH Plugin

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](releases)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet.svg)](https://claude.ai)
[![Skills](https://img.shields.io/badge/skills-21+-orange.svg)](#available-skills)

A comprehensive Claude Code plugin collection providing specialized skills for software development, from SQL optimization to modern frontend design.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Available Skills](#available-skills)
  - [Database & Backend](#database--backend)
  - [.NET Development](#net-development)
  - [Frontend & Design](#frontend--design)
  - [DevOps & Tools](#devops--tools)
  - [Documentation & Analysis](#documentation--analysis)
- [Usage](#usage)
- [Skill Details](#skill-details)
- [Contributing](#contributing)
- [License](#license)

## Features

- **21+ Specialized Skills**: Production-ready skills covering full-stack development
- **Multi-Language Support**: C#, SQL, JavaScript/TypeScript, and more
- **Best Practices Built-in**: Each skill embeds industry best practices and patterns
- **Reference Documentation**: Comprehensive guides and examples included
- **MCP Integration**: Seamless integration with Model Context Protocol servers

## Installation

### Prerequisites

- Claude Code CLI installed
- Claude Code plugin system enabled

### Quick Start

1. Clone the repository:

```bash
git clone https://github.com/your-username/icartsh-plugin.git
cd icartsh-plugin
```

2. Register with Claude Code marketplace:

```bash
# The plugin is automatically detected from .claude-plugin/marketplace.json
```

3. Start using skills in your Claude Code sessions:

```bash
# Skills are available with the icartsh-plugin: prefix
```

## Available Skills

### Database & Backend

| Skill | Description |
|-------|-------------|
| **sql-expert** | Expert SQL query writing, optimization, and schema design for PostgreSQL, MySQL, SQLite, and SQL Server |
| **api-designer** | Design and document RESTful and GraphQL APIs with OpenAPI/Swagger specifications |

### .NET Development

| Skill | Description |
|-------|-------------|
| **csharp-developer** | Modern .NET development with C# 12+, ASP.NET Core, Blazor, and cloud-native patterns |
| **csharp-async-patterns** | Async/await patterns including Task, ValueTask, async streams, and cancellation |
| **coding-conventions** | .NET/C# coding standards, naming rules, and C# 12/13/14 feature guidelines |
| **dotnet-build** | Build .NET solutions using dotnet CLI |
| **dotnet-test** | Run .NET tests with coverage reports and benchmarks |
| **code-analyze** | Static analysis, security scans, and dependency checks for .NET |
| **code-format** | Format code using dotnet format, prettier, and other tools |

### Frontend & Design

| Skill | Description |
|-------|-------------|
| **frontend-design** | Create distinctive, production-grade frontend interfaces with high design quality |
| **webapp-testing** | Test local web applications using Playwright |
| **web-artifacts-builder** | Build multi-component Claude.ai HTML artifacts with React, Tailwind CSS, and shadcn/ui |

### DevOps & Tools

| Skill | Description |
|-------|-------------|
| **docker-workflow** | Docker containerization with multi-stage builds and docker-compose orchestration |
| **git-advanced** | Advanced Git operations including rebasing, conflict resolution, and branch strategies |
| **mcp-builder** | Guide for creating MCP (Model Context Protocol) servers |
| **skill-creator** | Guide for creating effective Claude Code skills |

### Documentation & Analysis

| Skill | Description |
|-------|-------------|
| **markdown-pro** | Professional Markdown documentation for READMEs, changelogs, and technical docs |
| **error-detective** | Systematic debugging using the TRACE framework |
| **code-reviewer** | Automated code review with security scanning and quality metrics |
| **sequential-thinking** | Structured problem-solving for complex multi-step analysis |

## Usage

### Invoking a Skill

Skills can be invoked using the `icartsh-plugin:` prefix:

```
Use the sql-expert skill to optimize this query
```

Or reference the skill directly:

```
@icartsh-plugin:sql-expert Help me design a database schema for an e-commerce platform
```

### Example Workflows

**Database Design:**

```
1. Use sql-expert to design the schema
2. Use api-designer to create the REST API specification
3. Use csharp-developer to implement the backend
```

**Code Quality:**

```
1. Use code-analyze to run static analysis
2. Use code-reviewer to review changes
3. Use code-format to enforce style consistency
```

**Documentation:**

```
1. Use markdown-pro to create README and documentation
2. Use error-detective for troubleshooting guides
```

## Skill Details

### sql-expert

Expert guidance for writing, optimizing, and managing SQL databases.

**Capabilities:**
- Write complex SQL queries with JOINs, subqueries, CTEs, and window functions
- Optimize slow queries using EXPLAIN plans
- Design database schemas with proper normalization (1NF, 2NF, 3NF, BCNF)
- Create effective indexes for query performance
- Write safe database migrations with rollback support

**Supported Databases:**
- PostgreSQL
- MySQL/MariaDB
- SQLite
- SQL Server

### csharp-developer

Senior-level C# development expertise for modern .NET applications.

**Capabilities:**
- ASP.NET Core with Minimal APIs and Blazor
- Entity Framework Core optimization
- Clean Architecture and CQRS patterns
- Cloud-native development with Azure integration
- Performance optimization with Span<T>, Memory<T>, and AOT compilation

### frontend-design

Create distinctive, production-grade frontend interfaces.

**Design Focus:**
- Bold typography with unique font choices
- Cohesive color themes with CSS variables
- Motion and micro-interactions
- Unexpected layouts with asymmetry and creative composition
- Rich backgrounds and visual details

### sequential-thinking

Structured problem-solving through reflective thinking.

**Use Cases:**
- Breaking down complex problems
- Multi-step analysis with course correction
- Hypothesis generation and verification
- Planning and design with revision capability

## Project Structure

```
icartsh-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin configuration
├── skills/
│   ├── sql-expert/          # SQL expertise skill
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   ├── references/      # Optimization guides, best practices
│   │   └── examples/        # Query examples
│   ├── csharp-developer/    # C# development skill
│   ├── frontend-design/     # UI/UX design skill
│   ├── docker-workflow/     # Docker containerization
│   ├── git-advanced/        # Advanced Git operations
│   ├── markdown-pro/        # Documentation skill
│   └── ...                  # Additional skills
└── README.md
```

## Contributing

We welcome contributions! Here's how to get started:

### Adding a New Skill

1. Create a new directory under `skills/`
2. Add a `SKILL.md` with frontmatter:

```yaml
---
name: your-skill-name
description: "Brief description of the skill"
---
```

3. Include comprehensive documentation and examples
4. Submit a pull request

### Improving Existing Skills

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improve-sql-expert`)
3. Make your changes with clear commit messages
4. Push to the branch (`git push origin feature/improve-sql-expert`)
5. Open a Pull Request

### Guidelines

- Follow existing skill structure patterns
- Include practical examples and references
- Test skills thoroughly before submitting
- Document any new dependencies or requirements

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for [Claude Code](https://claude.ai) by Anthropic
- Inspired by the Claude Code plugin ecosystem
- Community contributions and feedback

---

**Made with care by ICARTSH**
