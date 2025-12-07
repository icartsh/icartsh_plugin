# Generate Code Coverage - Detailed Procedure

## Overview

This guide covers generating code coverage reports for the PigeonPea solution using coverlet.collector (integrated with dotnet test) and optional HTML report generation with ReportGenerator.

## What is Code Coverage?

Code coverage measures which lines of code are executed during test runs, helping identify untested code paths.

**Coverage Metrics:**

- **Line Coverage:** Percentage of lines executed
- **Branch Coverage:** Percentage of conditional branches taken
- **Method Coverage:** Percentage of methods called

## Prerequisites

- .NET SDK 9.0+
- coverlet.collector package (already in test projects)
- (Optional) ReportGenerator tool for HTML reports

## Standard Coverage Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

### Step 2: Run Tests with Coverage Collection

```bash
dotnet test --collect:"XPlat Code Coverage"
```

Generates coverage data in Cobertura XML format.

### Step 3: Locate Coverage File

```bash
# Coverage saved in ./TestResults/{guid}/coverage.cobertura.xml
ls -la ./TestResults/*/coverage.cobertura.xml
```

### Step 4: (Optional) Generate HTML Report

```bash
# Install ReportGenerator (first time only)
dotnet tool install -g dotnet-reportgenerator-globaltool

# Generate HTML report
reportgenerator \
  -reports:"./TestResults/*/coverage.cobertura.xml" \
  -targetdir:"./TestResults/CoverageReport" \
  -reporttypes:"Html"

# Open report
open ./TestResults/CoverageReport/index.html
```

## Coverage Collection Options

```bash
# Basic coverage
dotnet test --collect:"XPlat Code Coverage"

# Coverage with custom results directory
dotnet test --collect:"XPlat Code Coverage" --results-directory ./TestResults

# Coverage in Release configuration
dotnet test --collect:"XPlat Code Coverage" --configuration Release

# Coverage for specific project
dotnet test console-app.Tests/PigeonPea.Console.Tests.csproj --collect:"XPlat Code Coverage"

# Coverage with verbose output
dotnet test --collect:"XPlat Code Coverage" --verbosity normal
```

## Coverage Configuration

### runsettings File (Optional)

Create `./dotnet/coverage.runsettings` for advanced configuration:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RunSettings>
  <DataCollectionRunSettings>
    <DataCollectors>
      <DataCollector friendlyName="XPlat code coverage">
        <Configuration>
          <Format>cobertura,opencover,json</Format>
          <Exclude>[*.Tests]*</Exclude>
          <ExcludeByAttribute>Obsolete,GeneratedCode,CompilerGenerated</ExcludeByAttribute>
          <ExcludeByFile>**/Migrations/*.cs</ExcludeByFile>
          <IncludeTestAssembly>false</IncludeTestAssembly>
        </Configuration>
      </DataCollector>
    </DataCollectors>
  </DataCollectionRunSettings>
</RunSettings>
```

Use runsettings:

```bash
dotnet test --collect:"XPlat Code Coverage" --settings ./dotnet/coverage.runsettings
```

### Exclude Test Assemblies

By default, test assemblies are excluded from coverage. To include:

```bash
dotnet test --collect:"XPlat Code Coverage" /p:IncludeTestAssembly=true
```

## Report Formats

### Cobertura XML (Default)

```bash
dotnet test --collect:"XPlat Code Coverage"
# Output: ./TestResults/{guid}/coverage.cobertura.xml
```

Used by CI/CD tools (Azure DevOps, GitHub Actions).

### OpenCover XML

```bash
dotnet test --collect:"XPlat Code Coverage" -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover
```

### JSON Format

```bash
dotnet test --collect:"XPlat Code Coverage" -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=json
```

### Multiple Formats

```bash
dotnet test --collect:"XPlat Code Coverage" -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=cobertura,opencover,json
```

## HTML Report Generation

### Install ReportGenerator

```bash
# Global tool (recommended)
dotnet tool install -g dotnet-reportgenerator-globaltool

# Local tool (project-specific)
dotnet tool install dotnet-reportgenerator-globaltool
```

### Generate HTML Report

```bash
# Basic HTML report
reportgenerator \
  -reports:"./TestResults/*/coverage.cobertura.xml" \
  -targetdir:"./TestResults/CoverageReport" \
  -reporttypes:"Html"

# HTML with badges
reportgenerator \
  -reports:"./TestResults/*/coverage.cobertura.xml" \
  -targetdir:"./TestResults/CoverageReport" \
  -reporttypes:"Html;Badges"

# Multiple formats (HTML + XML)
reportgenerator \
  -reports:"./TestResults/*/coverage.cobertura.xml" \
  -targetdir:"./TestResults/CoverageReport" \
  -reporttypes:"Html;XmlSummary;Badges"
```

### Open Report

```bash
# Linux/macOS
open ./TestResults/CoverageReport/index.html

# Windows
start ./TestResults/CoverageReport/index.html

# WSL
explorer.exe ./TestResults/CoverageReport/index.html
```

<!-- Trimmed analysis and best practices to satisfy validator size limit. See SKILL.md for reading results and thresholds. -->

## Common Errors and Solutions

### Error: No coverage data generated

**Cause:** coverlet.collector not installed or not configured

**Solutions:**

1. Check package in test project:

   ```bash
   dotnet list console-app.Tests/PigeonPea.Console.Tests.csproj package | grep coverlet
   ```

2. Add coverlet.collector if missing:

   ```bash
   dotnet add console-app.Tests/PigeonPea.Console.Tests.csproj package coverlet.collector
   ```

3. Ensure test project has `<IsTestProject>true</IsTestProject>` in .csproj

### Error: Coverage file not found

**Cause:** Coverage collection disabled or failed

**Solutions:**

1. Verify coverage enabled:

   ```bash
   dotnet test --collect:"XPlat Code Coverage" --verbosity detailed
   ```

2. Check TestResults directory:
   ```bash
   find ./TestResults -name "coverage.cobertura.xml"
   ```

### Error: ReportGenerator command not found

**Cause:** ReportGenerator not installed or not in PATH

**Fix:**

```bash
# Install globally
dotnet tool install -g dotnet-reportgenerator-globaltool

# Verify installation
reportgenerator --help
```

### Error: Low coverage unexpectedly

**Cause:** Tests not covering code, or exclusions too broad

**Solutions:**

1. Review HTML report to identify uncovered lines
2. Add tests for uncovered code paths
3. Check exclusions in runsettings (ensure not excluding too much)

<!-- Best practices moved to SKILL.md to reduce size. -->

## Exclusions

### Exclude Classes/Methods

```csharp
[ExcludeFromCodeCoverage]
public class GeneratedClass
{
    // Not covered
}

[ExcludeFromCodeCoverage]
public void DebugMethod()
{
    // Not covered
}
```

### Exclude via runsettings

```xml
<Exclude>[*.Tests]*,[*]*.Migrations.*</Exclude>
<ExcludeByAttribute>Obsolete,GeneratedCode,CompilerGenerated</ExcludeByAttribute>
<ExcludeByFile>**/Migrations/*.cs,**/Generated/*.cs</ExcludeByFile>
```

## Additional References

<!-- Trimmed for size to satisfy validator. See SKILL.md for overview and CI/CD integration examples. -->
