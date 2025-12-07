# Build .NET Solution - Detailed Procedure

## Overview

This guide provides step-by-step instructions for building the entire PigeonPea.sln solution, including all projects (console-app, shared-app, windows-app) and their test projects.

## Prerequisites

- **.NET SDK 9.0** or later (check: `dotnet --version`)
- Solution file: `./dotnet/PigeonPea.sln`
- Projects: console-app, shared-app, windows-app (+ test projects, benchmarks)

## Standard Build Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

All build commands should be run from the `./dotnet` directory.

### Step 2: Restore Dependencies (First Time)

```bash
dotnet restore PigeonPea.sln
```

Downloads NuGet packages, restores references, creates `obj/` directories.

### Step 3: Build Solution (Debug)

```bash
dotnet build PigeonPea.sln
```

Compiles C# files, generates assemblies, creates artifacts in `bin/Debug/net9.0/`.

### Step 4: Build Solution (Release)

```bash
dotnet build PigeonPea.sln -c Release --no-restore
```

`-c Release`: Optimized build for production. `--no-restore`: Skip restore (faster).

## Output Locations

Artifacts: `./dotnet/{ProjectName}/bin/{Configuration}/net9.0/`

Example: `./dotnet/console-app/bin/Debug/net9.0/PigeonPea.Console.dll`

**Important:** Never commit `bin/` or `obj/` (excluded in `.gitignore`).

## Build Options

```bash
# Usage: dotnet build <SOLUTION|PROJECT> [options]

# Common flags
--no-restore                       # Skip restore
-m                                 # Parallel build
--verbosity <level>                # Verbosity: q[uiet], m[inimal], n[ormal], d[etailed], diag[nostic]
/p:RunAnalyzers=false              # Skip analyzers
/p:TreatWarningsAsErrors=true      # Warnings as errors

# MSBuild properties
/p:Version=1.2.3                   # Set version
/p:Deterministic=true              # Reproducible builds
```

## Common Errors and Solutions

### Error: NU1301 - Unable to load service index

**Full error:**

```
error NU1301: Unable to load the service index for source https://api.nuget.org/v3/index.json
```

**Cause:** NuGet package source is unreachable (network issue, firewall, proxy)

**Solutions:**

1. Check internet connection
2. Check NuGet sources:

   ```bash
   dotnet nuget list source
   ```

3. Add or update NuGet source:

   ```bash
   dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
   ```

4. Use specific source:

   ```bash
   dotnet restore --source https://api.nuget.org/v3/index.json
   ```

5. Check proxy settings in `nuget.config`

### Error: CS0246 - Type not found

**Cause:** Missing package/project reference

**Fix:** Check `.csproj` for references, run `dotnet restore`

### Error: MSB4018 - Build failed

**Cause:** Corrupted cache

**Fix:** Run `dotnet clean`. If issues persist, manually remove the `bin` and `obj` directories from project folders before rebuilding.

### Error: CSxxxx - Compilation errors

**Cause:** Syntax/type errors

**Fix:** Read error (shows file:line:column), fix code, rebuild

### Error: Circular references

**Cause:** Projects reference each other (A → B → A)

**Fix:** Refactor to break cycle, extract shared code

## Performance Tips

1. Use `--no-restore` after restore: `dotnet build --no-restore`
2. Enable parallel: `dotnet build -m`
3. Skip analyzers: `dotnet build /p:RunAnalyzers=false` (re-enable before commit!)
4. Build specific project: `dotnet build console-app/PigeonPea.Console.csproj`
5. CI/CD: Cache NuGet packages, separate restore and build steps

## Integration with Pre-commit Hooks

Before committing:

```bash
(cd ./dotnet && dotnet build PigeonPea.sln)
pre-commit run --all-files
```

Hooks run dotnet format, security checks, file validation.

## Advanced Scenarios

**Multiple frameworks:** `dotnet build --framework net9.0`

**Custom configuration:** Define in `.csproj`, build with `dotnet build -c Staging`

**Deterministic builds:** `dotnet build /p:Deterministic=true /p:ContinuousIntegrationBuild=true`

**From different directory:** `dotnet build ./dotnet/PigeonPea.sln`

## Verification Steps

1. Check exit code: `echo $?` (should be 0)
2. Output shows "Build succeeded. 0 Warning(s) 0 Error(s)"
3. Artifacts exist: `ls ./dotnet/{ProjectName}/bin/{Configuration}/net9.0/`
4. Review and address any warnings before release

## Related Procedures

- **Restore dependencies only:** See [`restore-deps.md`](restore-deps.md)
- **Run tests after build:** Use `dotnet-test` skill
- **Format code before build:** Use `code-format` skill
- **Analyze code quality:** Use `code-analyze` skill

## Quick Reference

```bash
# Standard build sequence
cd ./dotnet
dotnet restore PigeonPea.sln
dotnet build PigeonPea.sln

# Release build
dotnet build PigeonPea.sln -c Release --no-restore

# Clean and rebuild
dotnet clean PigeonPea.sln
dotnet build PigeonPea.sln

# Verbose build for troubleshooting
dotnet build PigeonPea.sln --verbosity detailed
```
