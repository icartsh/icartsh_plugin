# Dependency Vulnerability Check - Detailed Procedure

## Overview

This guide provides step-by-step instructions for checking NuGet package dependencies for known vulnerabilities and security issues in the PigeonPea .NET solution.

## Prerequisites

- **.NET SDK 9.0** or later (check: `dotnet --version`)
- Solution file: `./dotnet/PigeonPea.sln`
- Internet connection (to query vulnerability databases)
- Dependencies restored: `dotnet restore PigeonPea.sln`

## Dependency Vulnerability Tools

### 1. dotnet list package --vulnerable

Built-in .NET CLI command that checks NuGet packages against known vulnerability databases.

**Data Sources:**

- GitHub Advisory Database
- National Vulnerability Database (NVD)
- NuGet Advisory Database

**What it detects:**

- Known CVEs (Common Vulnerabilities and Exposures)
- Security advisories for NuGet packages
- Vulnerable transitive dependencies

### 2. dotnet list package --outdated

Checks for newer versions of installed packages (not security-specific but useful for maintenance).

## Standard Dependency Check Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

All dependency commands should be run from the `./dotnet` directory.

### Step 2: Check for Vulnerable Packages

```bash
dotnet list package --vulnerable
```

This scans all projects in the solution for vulnerable packages.

### Step 3: Include Transitive Dependencies

```bash
dotnet list package --vulnerable --include-transitive
```

This includes indirect dependencies that might have vulnerabilities.

### Step 4: Check Specific Project

```bash
dotnet list console-app/PigeonPea.Console.csproj package --vulnerable --include-transitive
```

### Step 5: Check for Outdated Packages

```bash
dotnet list package --outdated
```

This shows available updates (not just security fixes).

## Command Options

```bash
# Usage: dotnet list [PROJECT|SOLUTION] package [options]

# Vulnerability scanning
--vulnerable                            # Show only vulnerable packages
--include-transitive                    # Include transitive (indirect) dependencies

# Version checking
--outdated                             # Show packages with newer versions
--highest-patch                        # Show highest patch version
--highest-minor                        # Show highest minor version

# Formatting
--format <console|json>                # Output format
--output <file>                        # Write output to file

# Filtering
--include-prerelease                   # Include pre-release versions
--framework <tfm>                      # Filter by target framework
--source <source>                      # NuGet source to check
```

## Understanding Vulnerability Output

### Clean Report (No Vulnerabilities)

```bash
$ dotnet list package --vulnerable --include-transitive

Project 'PigeonPea.Console' has no vulnerable packages.
Project 'PigeonPea.Shared' has no vulnerable packages.
Project 'PigeonPea.Windows' has no vulnerable packages.
```

✅ No known vulnerabilities in dependencies.

### Vulnerable Package Detected

```bash
$ dotnet list package --vulnerable --include-transitive

The following sources were used:
   https://api.nuget.org/v3/index.json

Project `PigeonPea.Console` has the following vulnerable packages
   [net9.0]:
   Top-level Package         Requested   Resolved   Severity   Advisory URL
   > Newtonsoft.Json         12.0.1      12.0.1     High       https://github.com/advisories/GHSA-5crp-9r3c-p9vr

   Transitive Package        Resolved   Severity   Advisory URL
   > System.Text.Json        6.0.0      Critical   https://github.com/advisories/GHSA-8g4q-xg66-9fp4
```

❌ **Action Required:** Update vulnerable packages.

### Vulnerability Details

**Fields:**

- **Package**: Name of vulnerable package
- **Requested**: Version specified in `.csproj`
- **Resolved**: Version actually used
- **Severity**: Low, Moderate, High, Critical
- **Advisory URL**: Link to detailed vulnerability information

## Vulnerability Severity Levels

1. **Critical**: Immediate action required, exploitable with severe impact
2. **High**: Urgent action required, significant security risk
3. **Moderate**: Schedule fix soon, moderate security risk
4. **Low**: Address in next maintenance cycle, minor risk

## Fixing Vulnerable Dependencies

### Method 1: Update Package (Direct Dependency)

For packages directly referenced in `.csproj`:

```bash
# Update to latest version
dotnet add console-app/PigeonPea.Console.csproj package Newtonsoft.Json

# Update to specific version
dotnet add console-app/PigeonPea.Console.csproj package Newtonsoft.Json --version 13.0.3
```

Or edit `.csproj` directly:

```xml
<ItemGroup>
  <!-- Before: Vulnerable -->
  <PackageReference Include="Newtonsoft.Json" Version="12.0.1" />

  <!-- After: Fixed -->
  <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
</ItemGroup>
```

### Method 2: Update Transitive Dependency

For indirect (transitive) dependencies:

**Option A:** Update parent package that depends on it

```bash
dotnet add package ParentPackage --version <newer-version>
```

**Option B:** Add explicit reference to fixed version

```xml
<ItemGroup>
  <!-- Force specific version of transitive dependency -->
  <PackageReference Include="System.Text.Json" Version="8.0.0" />
</ItemGroup>
```

**Option C:** Use PackageReference with VersionOverride (Central Package Management)

```xml
<ItemGroup>
  <PackageVersion Include="System.Text.Json" Version="8.0.0" />
</ItemGroup>
```

### Method 3: Verify Fix

After updating:

```bash
# Restore with updated packages
dotnet restore PigeonPea.sln

# Verify vulnerability resolved
dotnet list package --vulnerable --include-transitive

# Build to ensure compatibility
dotnet build PigeonPea.sln
```

## Outdated Package Management

### Check for Updates

```bash
# All outdated packages
dotnet list package --outdated

# Include pre-release
dotnet list package --outdated --include-prerelease

# Show highest patch version only
dotnet list package --outdated --highest-patch

# Show highest minor version
dotnet list package --outdated --highest-minor
```

### Sample Outdated Output

```bash
$ dotnet list package --outdated

Project `PigeonPea.Console` has the following updates to its packages
   [net9.0]:
   Top-level Package         Requested   Resolved   Latest
   > Terminal.Gui            2.0.0       2.0.0      2.1.3
   > System.CommandLine      2.0.0-rc.2  2.0.0-rc.2 2.0.0-rc.3
```

### Selective Updates

**Update only patch versions** (safest):

```bash
dotnet add package Terminal.Gui --version 2.0.3
```

**Update to minor version** (review breaking changes):

```bash
dotnet add package Terminal.Gui --version 2.1.3
```

**Update to major version** (expect breaking changes):

```bash
dotnet add package Terminal.Gui --version 3.0.0
```

## Advanced Scenarios

<!-- Trimmed for size: See SKILL.md for overview and common commands. -->
