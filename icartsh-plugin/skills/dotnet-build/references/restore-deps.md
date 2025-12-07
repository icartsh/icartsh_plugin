# Restore Dependencies - Detailed Procedure

## Overview

This guide covers NuGet package restoration for the PigeonPea solution, including how to restore packages, troubleshoot issues, configure package sources, and manage dependencies.

## What is Package Restoration?

Downloads and installs NuGet packages (direct refs, transitive deps, tools, analyzers).

## When to Restore

After cloning, after pulling changes, package not found errors, switching branches, clearing cache, updating packages.

## Prerequisites

.NET SDK 9.0+, internet connection, proper network config (if behind proxy)

## Standard Restore Procedure

### Step 1: Navigate to Solution Directory

```bash
cd ./dotnet
```

### Step 2: Restore All Packages

```bash
dotnet restore PigeonPea.sln
```

Creates `obj/project.assets.json` (lock file), `obj/project.nuget.cache`, and MSBuild files.

## Package Sources

```bash
dotnet nuget list source                     # View sources
dotnet nuget add source <url> --name <name>  # Add source
dotnet nuget remove source <name>            # Remove source
dotnet nuget enable/disable source <name>    # Enable/disable
```

## NuGet Configuration

Config hierarchy: project-level (`nuget.config`), user-level (`~/.nuget/NuGet/NuGet.Config`), computer-level.

Sample `nuget.config`: Add package sources, credentials, and global packages folder.

## Restore Options

```bash
dotnet restore --force                    # Re-download everything
dotnet restore --no-cache                 # Don't use HTTP cache
dotnet restore --source <url>             # Specific source
dotnet restore --disable-parallel         # For debugging
dotnet restore --verbosity detailed       # Verbose output
dotnet restore --runtime linux-x64        # Specific runtime
```

## Common Errors and Solutions

### Error: NU1301 - Service index unavailable

**Causes:** No internet, NuGet.org down, firewall, proxy needed, DNS issues

**Solutions:**

- Check connection: `ping api.nuget.org`
- Check status: https://status.nuget.org/
- Configure proxy: `export HTTP_PROXY=http://proxy:8080`
- Clear cache: `dotnet nuget locals http-cache --clear`

### Error: NU1100 - Unable to resolve package

**Causes:** Package doesn't exist, version doesn't exist, private feed, typo

**Solutions:**

- Verify on nuget.org: https://www.nuget.org/packages/{PackageName}
- Check package versions on nuget.org
- Fix typos in `.csproj`
- Add private feed if needed

### Error: NU1101 - Package not found

**Fix:** Search on nuget.org, fix name in `.csproj`, check if renamed

### Error: NU1102 - Version not found

**Fix:** Check available versions on nuget.org, update `.csproj`, or use `--include-prerelease` if the desired version is a pre-release.

### Error: NU1107 - Version conflict

**Fix:** Unify versions, add explicit reference, or use `Directory.Build.props`

### Error: NU1605 - Downgrade detected

**Fix:** Update to higher version in `.csproj`

### Error: Assets file not found

**Fix:** Run `dotnet restore`, or clean and restore if persists

## Package Cache Management

**Cache locations:** `~/.nuget/packages` (global), `~/.local/share/NuGet/v3-cache` (HTTP), temp

```bash
dotnet nuget locals all --list              # View locations
dotnet nuget locals http-cache --clear      # Clear HTTP cache
dotnet nuget locals global-packages --clear # Clear global (slow!)
dotnet nuget locals all --clear             # Clear all
```

**When to clear:** Corrupt package, debugging, network changes, disk space

**Warning:** Clearing global cache requires re-downloading all packages.

## Dependency Management

```bash
dotnet list package              # View all dependencies
dotnet list package --outdated   # Check for updates
dotnet list package --vulnerable # Security vulnerabilities
```

Update: Edit `.csproj` package version, then `dotnet restore`

## Performance Optimization

1. Don't clear cache unnecessarily
2. Parallel restore enabled by default
3. Separate restore and build: `dotnet restore` then `dotnet build --no-restore`
4. CI/CD: Cache `~/.nuget/packages`, use `--locked-mode` for deterministic builds

## Advanced Scenarios

**Restore specific project:** `dotnet restore console-app/PigeonPea.Console.csproj`

**Lock file (reproducible):** `dotnet restore --use-lock-file` creates `packages.lock.json`

**Private feeds:** Add with credentials (use credential providers, not clear text)

**Offline restore:** `dotnet restore --no-http-cache` (if packages cached)

**Fallback folders:** Configure in `nuget.config` for offline scenarios

## Verification

1. No errors in output
2. `obj/project.assets.json` exists for each project
3. Packages in `~/.nuget/packages`
4. No missing package warnings

## Troubleshooting Checklist

- [ ] Internet connection
- [ ] NuGet.org accessible (status.nuget.org)
- [ ] Sources configured correctly
- [ ] Proxy settings (if behind firewall)
- [ ] Package names/versions correct in `.csproj`
- [ ] Cache not corrupted
- [ ] .NET SDK compatible

## Related Procedures

- **Build after restore:** See [`build-solution.md`](build-solution.md)
- **Configure NuGet in CI/CD:** Check project documentation
- **Manage package versions:** Use Directory.Build.props

## Quick Reference

```bash
# Standard restore
dotnet restore PigeonPea.sln

# Force full restore
dotnet restore PigeonPea.sln --force

# Clear cache and restore
dotnet nuget locals all --clear
dotnet restore PigeonPea.sln

# Restore with verbose output for troubleshooting
dotnet restore --verbosity detailed

# View package sources
dotnet nuget list source

# View package cache locations
dotnet nuget locals all --list
```
