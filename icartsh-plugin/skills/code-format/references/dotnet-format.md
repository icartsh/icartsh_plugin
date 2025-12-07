# Format .NET Code - Detailed Procedure

## Overview

This guide provides step-by-step instructions for formatting C# code using `dotnet format`. The tool applies code style rules defined in `.editorconfig` and enforces consistent formatting across the PigeonPea .NET solution.

## Prerequisites

- **.NET SDK 9.0** or later (check: `dotnet --version`)
- Solution file: `./dotnet/PigeonPea.sln`
- `.editorconfig` file at repository root (defines formatting rules)
- Projects: console-app, shared-app, windows-app (+ test projects)

## Standard Format Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

All format commands should be run from the `./dotnet` directory.

### Step 2: Format Entire Solution

```bash
dotnet format PigeonPea.sln
```

Applies formatting rules to all C# files (.cs) in the solution. Modifies files in-place.

### Step 3: Verify Format (Check-Only Mode)

```bash
dotnet format PigeonPea.sln --verify-no-changes
```

Checks if code is formatted correctly without modifying files. Returns:

- Exit code 0: All files properly formatted
- Exit code non-zero: Formatting violations found

## Format Options

```bash
# Usage: dotnet format <SOLUTION|PROJECT> [options]

# Common flags
--verify-no-changes              # Check-only mode (no modifications)
--no-restore                     # Skip restore before format
--include <file>                 # Format specific files
--exclude <file>                 # Exclude specific files
--verbosity <level>              # Verbosity: q[uiet], m[inimal], n[ormal], d[etailed], diag[nostic]

# Format styles
--diagnostics <id>               # Format specific diagnostic IDs only
--severity <level>               # Format issues of specific severity (info, warn, error)
```

## Common Use Cases

### Format Entire Solution

```bash
cd ./dotnet
dotnet format PigeonPea.sln
```

Formats all C# files in all projects.

### Format Specific Project

```bash
cd ./dotnet
dotnet format console-app/PigeonPea.Console.csproj
```

Formats only files in the console-app project.

### Format Specific Files

```bash
cd ./dotnet
dotnet format --include ./console-app/Program.cs
dotnet format --include ./shared-app/Services/*.cs
```

Formats only specified files or patterns.

### Verify Without Modifying

```bash
cd ./dotnet
dotnet format PigeonPea.sln --verify-no-changes
```

Checks formatting without making changes. Useful for CI/CD pipelines.

### Format with Verbosity

```bash
cd ./dotnet
dotnet format PigeonPea.sln --verbosity detailed
```

Shows detailed information about what's being formatted.

### Exclude Files from Format

```bash
cd ./dotnet
dotnet format PigeonPea.sln --exclude ./console-app/Generated/*.cs
```

Skips specific files or patterns.

## What Gets Formatted

`dotnet format` applies rules from `.editorconfig`:

- **Indentation**: Spaces (4 for C#, 2 for project files)
- **Line endings**: LF (Unix-style)
- **Charset**: UTF-8
- **Trailing whitespace**: Removed
- **Final newline**: Added
- **Code style**: Namespace declarations, using statements, expression bodies, etc.

## Common Errors and Solutions

### Error: Could not find a MSBuild project file

**Full error:**

```
Could not find a MSBuild project file in '/path'. Specify which to use with the <workspace> argument.
```

**Cause:** Running from wrong directory or solution file not found.

**Fix:**

```bash
cd ./dotnet
dotnet format PigeonPea.sln
```

### Error: One or more format violations found

**Full error:**

```
Error: One or more format violations found
```

**Cause:** Files have formatting violations (when using --verify-no-changes).

**Fix:** Run without --verify-no-changes to apply fixes:

```bash
dotnet format PigeonPea.sln
```

### Error: Unable to restore packages

**Cause:** Network issues or NuGet source unreachable.

**Fix:** Restore first, then format:

```bash
dotnet restore PigeonPea.sln
dotnet format PigeonPea.sln --no-restore
```

### Warning: Files modified

**Not an error**: This is normal output showing which files were formatted.

**Example:**

```
Formatted code file '/path/to/Program.cs'.
```

### Error: Access denied / File in use

**Cause:** Files locked by IDE or another process.

**Fix:** Close IDE/editor, ensure no builds running, then format again.

## Integration with .editorconfig

The `.editorconfig` file at repository root defines formatting rules:

```ini
# C# files
[*.cs]
indent_size = 4
indent_style = space
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
```

`dotnet format` automatically applies these rules. No additional configuration needed.

## Integration with Pre-commit Hooks

The `.pre-commit-config.yaml` includes dotnet format:

```yaml
- repo: local
  hooks:
    - id: dotnet-format
      name: dotnet format
      entry: dotnet
      args: ['format', 'dotnet/PigeonPea.sln', '--no-restore']
      language: system
      types: [c#]
      pass_filenames: false
```

**Automatic formatting on commit:**

```bash
# Setup pre-commit (one-time)
./setup-pre-commit.sh

# Commit triggers auto-format
git add .
git commit -m "Your message"
# dotnet format runs automatically
```

## CI/CD Integration

In CI pipelines, use verify mode to enforce formatting:

```bash
# Fail build if code not formatted
dotnet format PigeonPea.sln --verify-no-changes
```

Exit code non-zero = formatting violations = build failure.

## Performance Tips

1. **Skip restore if already done**: Run after restore to avoid duplicate work
2. **Format specific projects**: Target only changed projects
3. **Skip restore**: Use `--no-restore` if packages already restored
4. **IDE formatting**: Configure IDE to format on save (reduces manual runs)

## Advanced Scenarios

### Format Only Specific Severity

```bash
dotnet format PigeonPea.sln --severity error
```

Formats only error-level issues, ignoring warnings and info.

### Format Specific Diagnostics

```bash
dotnet format PigeonPea.sln --diagnostics IDE0005
```

Formats only specific diagnostic IDs (e.g., remove unnecessary usings).

### Format from Repository Root

```bash
dotnet format ./dotnet/PigeonPea.sln
```

Run from any directory by specifying full path to solution.

## Verification Steps

1. **Check exit code**: `echo $?` (should be 0)
2. **Review output**: Look for "Format complete" message
3. **Check git diff**: `git diff` to see what changed
4. **Verify pre-commit**: `pre-commit run dotnet-format --all-files`

## Before Commit Checklist

- [ ] Format code: `dotnet format PigeonPea.sln`
- [ ] Review changes: `git diff`
- [ ] Stage files: `git add .`
- [ ] Pre-commit runs automatically on commit
- [ ] If pre-commit fails, fix issues and re-commit

## Related Procedures

- **Format non-.NET files**: See [`prettier-format.md`](prettier-format.md)
- **Format everything**: See [`fix-all.md`](fix-all.md)
- **Build after format**: Use `dotnet-build` skill
- **Configuration**: See `.editorconfig` in repository root

## Quick Reference

```bash
# Standard format workflow
cd ./dotnet
dotnet format PigeonPea.sln

# Verify only (CI/CD)
dotnet format PigeonPea.sln --verify-no-changes

# Format specific project
dotnet format console-app/PigeonPea.Console.csproj
```
