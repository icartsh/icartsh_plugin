# Run Unit Tests - Detailed Procedure

## Overview

This guide provides step-by-step instructions for running unit tests in the PigeonPea solution, including all test projects (console-app.Tests, shared-app.Tests, windows-app.Tests) using xUnit framework.

## Prerequisites

- **.NET SDK 9.0** or later (check: `dotnet --version`)
- Solution file: `./dotnet/PigeonPea.sln`
- Test projects: console-app.Tests, shared-app.Tests, windows-app.Tests
- xUnit test framework (already configured in test projects)

## Standard Test Flow

### Step 1: Navigate to .NET Directory

```bash
cd ./dotnet
```

All test commands should be run from the `./dotnet` directory.

### Step 2: Build Solution (If Not Already Built)

```bash
dotnet build PigeonPea.sln
```

Tests require compiled code. Build first if you haven't already.

### Step 3: Run All Tests

```bash
dotnet test
```

Discovers and runs all tests in solution, reports pass/fail status.

### Step 4: Run with Verbose Output

```bash
dotnet test --verbosity normal
```

Verbosity levels: `quiet`, `minimal`, `normal`, `detailed`, `diagnostic`

## Output Interpretation

### Successful Test Run

```
Passed!  - Failed:     0, Passed:    42, Skipped:     0, Total:    42, Duration: 2 s
```

- **Failed**: Number of failing tests (should be 0)
- **Passed**: Number of passing tests
- **Skipped**: Tests marked with `[Skip]` attribute
- **Total**: Sum of all tests
- **Duration**: Total execution time

### Failed Test Run

```
Failed!  - Failed:     3, Passed:    39, Skipped:     0, Total:    42, Duration: 2 s
```

Individual failures are listed with stack traces showing assertion errors.

## Test Options

```bash
# Usage: dotnet test [SOLUTION|PROJECT] [options]

# Common flags
--no-build                          # Skip build (faster if already built)
--no-restore                        # Skip restore
--verbosity <level>                 # Verbosity: q[uiet], m[inimal], n[ormal], d[etailed], diag[nostic]
--configuration <config>            # Debug or Release (default: Debug)
--filter <expression>               # Run filtered tests
--logger <logger>                   # Test logger (trx, html, console)
--results-directory <path>          # Output directory for test results
--collect <datacollector>           # Enable data collection (e.g., "XPlat Code Coverage")
```

## Running Specific Tests

### Run Specific Test Project

```bash
dotnet test console-app.Tests/PigeonPea.Console.Tests.csproj
dotnet test shared-app.Tests/PigeonPea.Shared.Tests.csproj
dotnet test windows-app.Tests/PigeonPea.Windows.Tests.csproj
```

### Filter by Test Name

```bash
# Run tests with "Frame" in the name
dotnet test --filter "FullyQualifiedName~Frame"

# Run exact test method
dotnet test --filter "FullyQualifiedName=PigeonPea.Console.Tests.Visual.FrameTests.ShouldCreateFrame"
```

### Filter by Test Category/Trait

```bash
# Run tests with [Trait("Category", "Unit")]
dotnet test --filter "Category=Unit"

# Run tests with [Trait("Category", "Integration")]
dotnet test --filter "Category=Integration"
```

### Filter by Namespace

```bash
dotnet test --filter "FullyQualifiedName~PigeonPea.Console.Tests.Visual"
```

### Combine Filters

```bash
# Run Unit tests in Visual namespace
dotnet test --filter "Category=Unit&FullyQualifiedName~Visual"
```

## Test Execution Strategies

### Quick Test (Skip Build)

```bash
# Build once
dotnet build PigeonPea.sln

# Run tests multiple times without rebuilding
dotnet test --no-build
```

### Release Configuration

```bash
dotnet test --configuration Release
```

Tests run with optimizations enabled. Use for performance testing.

### Parallel Execution

xUnit runs tests in parallel by default. To disable:

```bash
dotnet test -- xUnit.ParallelizeTestCollections=false
```

### Test Results Export

```bash
# TRX format (Visual Studio)
dotnet test --logger "trx;LogFileName=test-results.trx"

# HTML format
dotnet test --logger "html;LogFileName=test-results.html"

# Multiple loggers
dotnet test --logger "trx;LogFileName=test-results.trx" --logger "console;verbosity=detailed"
```

## Common Errors and Solutions

### Error: No test is available

**Cause:** Test project not built, test discovery failed, or no tests in project

**Solutions:**

1. Ensure test project has tests:

   ```bash
   ls -la console-app.Tests/*.cs
   ```

2. Build solution:

   ```bash
   dotnet build PigeonPea.sln
   ```

3. Verify xUnit packages:
   ```bash
   dotnet list console-app.Tests/PigeonPea.Console.Tests.csproj package | grep xunit
   ```

### Error: Test host process crashed

**Cause:** Unhandled exception in test initialization, missing dependencies, or memory issues

**Solutions:**

1. Run with detailed verbosity:

   ```bash
   dotnet test --verbosity detailed
   ```

2. Run tests individually to isolate problem:

   ```bash
   dotnet test --filter "FullyQualifiedName~FrameTests.ShouldCreateFrame"
   ```

3. Check for infinite loops or excessive memory usage in tests

### Error: Test timeout

**Cause:** Test takes too long to execute (default timeout: no limit, but xUnit has 10s warning)

**Solutions:**

1. Increase timeout in test:

   ```csharp
   [Fact(Timeout = 30000)] // 30 seconds
   public void MyTest() { }
   ```

2. Optimize test code to run faster

3. Mock slow dependencies (I/O, network, database)

### Error: Collection fixture error

**Cause:** xUnit collection fixture setup failed

**Fix:** Check `ICollectionFixture<T>` implementation, ensure constructor doesn't throw

### Error: Theory data not found

**Cause:** `[MemberData]` or `[ClassData]` source not found

**Fix:** Verify data source method/property exists and is public static

## Debugging Tests

### Run Single Test with Debugger

```bash
# In VS Code or Visual Studio, set breakpoint and use "Debug Test" button
```

### Output Debug Information

```csharp
[Fact]
public void MyTest()
{
    var result = MyMethod();
    _output.WriteLine($"Result: {result}"); // xUnit ITestOutputHelper
    Assert.Equal(42, result);
}
```

### Conditional Breakpoints

Use `System.Diagnostics.Debugger.Break()` to trigger debugger in specific conditions.

## Performance Tips

1. **Skip build after first run:** `dotnet test --no-build`
2. **Filter to relevant tests:** Use `--filter` to run subset
3. **Use Release build for benchmarks:** `dotnet test -c Release`
4. **Disable parallel for debugging:** `-- xUnit.ParallelizeTestCollections=false`
5. **Mock expensive operations:** Use Moq or similar for I/O, network, database

## Additional References

<!-- Trimmed for size to satisfy validator. See SKILL.md for pre-commit integration, test organization, and quick commands. -->
