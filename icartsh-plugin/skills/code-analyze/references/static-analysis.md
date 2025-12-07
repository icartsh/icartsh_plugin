# Static Code Analysis - Detailed Procedure

## Overview

This guide provides step-by-step instructions for running static code analysis on the PigeonPea .NET solution using Roslyn analyzers, StyleCop, and other code quality tools.

## Prerequisites

- **.NET SDK 9.0** or later (check: `dotnet --version`)
- Solution file: `./dotnet/PigeonPea.sln`
- Projects restored: `dotnet restore PigeonPea.sln`

## Static Analysis Tools

### 1. Roslyn Analyzers (Built-in)

Roslyn analyzers are included with the .NET SDK and analyze code during build.

**Categories:**

- **Code Quality (CAxxxx)**: Best practices, performance, maintainability
- **Design (CA1xxx)**: API design guidelines
- **Reliability (CA2xxx)**: Reliability and correctness
- **Security (CA5xxx)**: Security vulnerabilities
- **Performance (CA18xx)**: Performance issues
- **Style (IDExxx)**: Code style preferences

### 2. StyleCop.Analyzers (Optional)

StyleCop enforces consistent code style and documentation standards.

**To enable:** Add to each `.csproj`:

```xml
<ItemGroup>
  <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556">
    <PrivateAssets>all</PrivateAssets>
    <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
  </PackageReference>
</ItemGroup>
```

### 3. Code Quality Rules

Configured via `.editorconfig` or `.globalconfig` files.

## Standard Analysis Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

All analysis commands should be run from the `./dotnet` directory.

### Step 2: Run Build with Analyzers Enabled

```bash
dotnet build PigeonPea.sln /p:RunAnalyzers=true
```

Analyzers run during build and report diagnostics as warnings or errors.

### Step 3: Treat Warnings as Errors (Strict Mode)

```bash
dotnet build PigeonPea.sln /p:TreatWarningsAsErrors=true
```

This enforces zero-tolerance for code quality issues.

### Step 4: Filter by Severity

```bash
# Errors only (ignore warnings)
dotnet build PigeonPea.sln /p:WarningLevel=0

# Warnings and errors
dotnet build PigeonPea.sln /p:WarningLevel=4
```

## Analysis Options

```bash
# Usage: dotnet build <SOLUTION|PROJECT> [options]

# Analyzer control
/p:RunAnalyzers=true                    # Enable analyzers
/p:RunAnalyzers=false                   # Disable analyzers
/p:TreatWarningsAsErrors=true           # All warnings → errors
/p:WarningsAsErrors=CA1001;CA1031       # Specific warnings → errors
/p:NoWarn=CA1014;CA1062                 # Suppress specific warnings
/p:WarningLevel=<0-4>                   # Warning verbosity (0=none, 4=all)

# Analysis mode
/p:AnalysisMode=AllEnabledByDefault     # Enable all analyzers
/p:AnalysisMode=None                    # Disable analysis
/p:CodeAnalysisRuleSet=custom.ruleset   # Custom ruleset

# Output
--verbosity detailed                     # Show detailed diagnostics
/p:ReportAnalyzer=true                  # Report analyzer performance
```

## Understanding Analysis Output

### Warning Format

```
Path/To/File.cs(42,15): warning CA1001: Type 'MyClass' owns disposable field(s) but is not disposable [Project.csproj]
```

**Breakdown:**

- `Path/To/File.cs`: File path
- `(42,15)`: Line 42, column 15
- `warning CA1001`: Rule ID and severity
- `Type 'MyClass'...`: Diagnostic message
- `[Project.csproj]`: Project context

### Severity Levels

1. **Error**: Build fails (red)
2. **Warning**: Build succeeds but issues reported (yellow)
3. **Suggestion**: IDE hints, not shown in build output
4. **Hidden**: Informational only

## Common Analysis Rules

### Code Quality (CAxxxx)

**CA1001**: Types that own disposable fields should be disposable

```csharp
// Bad
class MyClass { FileStream _stream; }

// Good
class MyClass : IDisposable { FileStream _stream; public void Dispose() => _stream?.Dispose(); }
```

**CA1031**: Do not catch general exception types

```csharp
// Bad
try { } catch (Exception) { }

// Good
try { } catch (InvalidOperationException ex) { }
```

**CA1062**: Validate arguments of public methods

```csharp
// Bad
public void Process(string input) { var len = input.Length; }

// Good
public void Process(string input) { ArgumentNullException.ThrowIfNull(input); }
```

**CA1303**: Do not pass literals as localized parameters

```csharp
// Bad
Console.WriteLine("Hello, World!");

// Good (if localization needed)
Console.WriteLine(Resources.HelloWorld);
```

**CA1848**: Use the LoggerMessage delegates

```csharp
// Bad
_logger.LogInformation($"Processing {item}");

// Good
_logger.LogInformation("Processing {Item}", item);
```

### Design Rules (CA10xx)

**CA1014**: Mark assemblies with CLSCompliantAttribute
**CA1024**: Use properties where appropriate
**CA1051**: Do not declare visible instance fields

### Performance Rules (CA18xx)

**CA1802**: Use literals where appropriate
**CA1805**: Do not initialize unnecessarily
**CA1810**: Initialize reference type static fields inline
**CA1822**: Mark members as static
**CA1828**: Do not use CountAsync() when Count() works

### Security Rules (CA5xxx)

See `security-scan.md` for detailed security analysis.

## Configuring Analysis Rules

### Using .editorconfig

Add to root `.editorconfig`:

```ini
[*.cs]
# CA1014: Mark assemblies with CLSCompliant
dotnet_diagnostic.CA1014.severity = none

# CA1062: Validate arguments
dotnet_diagnostic.CA1062.severity = warning

# CA1303: Do not pass literals as localized parameters
dotnet_diagnostic.CA1303.severity = none
```

### Using Global Ruleset

Create `PigeonPea.ruleset`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RuleSet Name="PigeonPea Rules" ToolsVersion="16.0">
  <Rules AnalyzerId="Microsoft.CodeAnalysis.CSharp" RuleNamespace="Microsoft.CodeAnalysis.CSharp">
    <Rule Id="CA1001" Action="Error" />
    <Rule Id="CA1031" Action="Warning" />
    <Rule Id="CA1062" Action="Warning" />
    <Rule Id="CA1303" Action="None" />
  </Rules>
</RuleSet>
```

Reference in `.csproj`:

```xml
<PropertyGroup>
  <CodeAnalysisRuleSet>$(MSBuildThisFileDirectory)../PigeonPea.ruleset</CodeAnalysisRuleSet>
</PropertyGroup>
```

### Suppressing Individual Violations

**In code:**

```csharp
#pragma warning disable CA1062
public void Process(string input) { }
#pragma warning restore CA1062
```

**With attribute:**

```csharp
[System.Diagnostics.CodeAnalysis.SuppressMessage("Design", "CA1062:Validate arguments")]
public void Process(string input) { }
```

## Advanced Scenarios

### Analyze Specific Project

```bash
cd ./dotnet
dotnet build console-app/PigeonPea.Console.csproj /p:RunAnalyzers=true /p:TreatWarningsAsErrors=true
```

### Enable All Rules by Default

```bash
dotnet build PigeonPea.sln /p:AnalysisMode=AllEnabledByDefault
```

### Generate Analysis Report

```bash
dotnet build PigeonPea.sln /p:RunAnalyzers=true --verbosity detailed > analysis-report.txt 2>&1
```

### Analyzer Performance

```bash
dotnet build PigeonPea.sln /p:ReportAnalyzer=true
```

## Interpreting Results

### Clean Build (No Issues)

```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

✅ Code passes all analysis rules.

### Warnings Present

```
Build succeeded.
    12 Warning(s)
    0 Error(s)
```

⚠️ Review warnings, address critical ones, suppress false positives.

### Errors Present

```
Build FAILED.
    5 Warning(s)
    3 Error(s)
```

❌ Fix errors before proceeding. Check output for file/line references.

<!-- Additional references trimmed to satisfy validator. See SKILL.md for links. -->
