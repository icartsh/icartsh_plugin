# Run Benchmarks - Detailed Procedure

## Overview

This guide covers running performance benchmarks for the PigeonPea solution using BenchmarkDotNet, a powerful library for benchmarking .NET code with high precision and statistical analysis.

## What are Benchmarks?

Benchmarks measure code performance (execution time, memory allocation, throughput) to:

- Identify performance bottlenecks
- Compare alternative implementations
- Track performance over time
- Validate optimization efforts

## Prerequisites

- .NET SDK 9.0+
- Benchmark project: `./dotnet/benchmarks/PigeonPea.Benchmarks.csproj`
- BenchmarkDotNet package (already configured)
- **Release configuration** (required for accurate results)

## Standard Benchmark Flow

### Step 1: Navigate to Benchmarks Directory

```bash
cd ./dotnet/benchmarks
```

### Step 2: Build in Release Mode

```bash
dotnet build -c Release
```

**Critical:** Always use Release mode for benchmarks. Debug mode skews results.

### Step 3: Run Benchmarks

```bash
dotnet run -c Release
```

BenchmarkDotNet executes benchmarks, performs warm-up, measurement iterations, and statistical analysis.

### Step 4: Review Results

Results are displayed in console and saved to `./BenchmarkDotNet.Artifacts/results/`.

## Benchmark Execution

### Run All Benchmarks

```bash
cd ./dotnet/benchmarks
dotnet run -c Release
```

### Run Specific Benchmark Class

```bash
cd ./dotnet/benchmarks
dotnet run -c Release --filter "*StringBenchmarks*"
```

### Run Specific Benchmark Method

```bash
cd ./dotnet/benchmarks
dotnet run -c Release --filter "*StringBenchmarks.Concat*"
```

### Run with Custom Job

```bash
cd ./dotnet/benchmarks
dotnet run -c Release -- --job short
```

Job options: `short`, `medium`, `long`, `verylong`

## Benchmark Output

### Console Output Example

```
| Method    | Mean      | Error    | StdDev   | Allocated |
|---------- |----------:|---------:|---------:|----------:|
| Concat    | 12.34 ns  | 0.21 ns  | 0.19 ns  | 40 B      |
| Format    | 45.67 ns  | 0.89 ns  | 0.83 ns  | 64 B      |
| Interpolate | 23.45 ns | 0.34 ns  | 0.32 ns  | 48 B      |
```

- **Method:** Benchmark method name
- **Mean:** Average execution time
- **Error:** Standard error of the mean
- **StdDev:** Standard deviation
- **Allocated:** Memory allocated per operation

### Artifacts Location

```
./dotnet/benchmarks/BenchmarkDotNet.Artifacts/
  results/
    MyBenchmark-report.html     # HTML report
    MyBenchmark-report.csv      # CSV data
    MyBenchmark-report.md       # Markdown report
  logs/
    MyBenchmark.log             # Detailed log
```

## Writing Benchmarks

### Basic Benchmark Structure

```csharp
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;

namespace PigeonPea.Benchmarks;

[MemoryDiagnoser]
public class StringBenchmarks
{
    private const int Iterations = 100;

    [Benchmark]
    public string Concat()
    {
        var result = "";
        for (int i = 0; i < Iterations; i++)
            result += "a";
        return result;
    }

    [Benchmark]
    public string StringBuilder()
    {
        var sb = new System.Text.StringBuilder();
        for (int i = 0; i < Iterations; i++)
            sb.Append("a");
        return sb.ToString();
    }

    [Benchmark(Baseline = true)]
    public string StringCreate()
    {
        return string.Create(Iterations, 'a', (span, c) =>
        {
            span.Fill(c);
        });
    }
}

public class Program
{
    public static void Main(string[] args)
    {
        BenchmarkRunner.Run<StringBenchmarks>();
    }
}
```

### Benchmark Attributes

```csharp
[Benchmark]                  // Mark method as benchmark
[Benchmark(Baseline = true)] // Mark as baseline for comparison
[Arguments(10, 20)]          // Pass arguments to benchmark
[Params(10, 100, 1000)]      // Run with multiple parameter values
[IterationCount(10)]         // Custom iteration count
[WarmupCount(5)]             // Custom warmup count
```

### Diagnosers

```csharp
[MemoryDiagnoser]           // Track memory allocations
[ThreadingDiagnoser]        // Track threading info
[EventPipeProfiler(...)]    // CPU profiling
```

## Benchmark Configuration

### Global Configuration

```csharp
using BenchmarkDotNet.Configs;
using BenchmarkDotNet.Jobs;
using BenchmarkDotNet.Toolchains.InProcess.Emit;

[Config(typeof(Config))]
public class MyBenchmarks
{
    private class Config : ManualConfig
    {
        public Config()
        {
            AddJob(Job.Default
                .WithRuntime(CoreRuntime.Core90)
                .WithPlatform(Platform.X64)
                .WithJit(Jit.RyuJit));

            AddDiagnoser(MemoryDiagnoser.Default);
            AddColumn(StatisticColumn.P95);
        }
    }
}
```

### Job Configuration

```csharp
[SimpleJob(RuntimeMoniker.Net90)]
[SimpleJob(RuntimeMoniker.Net80)]
public class MyBenchmarks
{
    // Compare performance across runtimes
}
```

## Analyzing Results

### Compare Baseline

```
| Method       | Mean     | Ratio |
|------------- |---------:|------:|
| Baseline     | 100.0 ns | 1.00  |
| Optimized    | 50.0 ns  | 0.50  |
| Alternative  | 150.0 ns | 1.50  |
```

- **Ratio:** Relative to baseline (0.50 = 2x faster, 1.50 = 1.5x slower)

### Statistical Significance

BenchmarkDotNet performs statistical analysis:

- **Outliers:** Identified and can be removed
- **Multimodal distribution:** Indicates interference (antivirus, background tasks)
- **Confidence intervals:** 95% by default

### Memory Analysis

```
| Method    | Allocated |
|---------- |----------:|
| Original  | 1024 B    |
| Optimized | 64 B      |
```

Lower allocation = less GC pressure = better performance.

## Common Errors and Solutions

### Error: "Benchmarks must be run in Release mode"

**Cause:** Running in Debug configuration

**Fix:**

```bash
dotnet run -c Release
```

### Error: "No benchmarks found"

**Cause:** No methods decorated with `[Benchmark]` or benchmark class not passed to `BenchmarkRunner.Run`

**Solutions:**

1. Ensure methods have `[Benchmark]` attribute
2. Check `Main` method calls `BenchmarkRunner.Run<YourBenchmarkClass>()`

### Error: "Benchmark throws exception"

**Cause:** Code in benchmark method throws unhandled exception

**Solutions:**

1. Run with detailed output:

   ```bash
   dotnet run -c Release -- --verbosity Detailed
   ```

2. Fix code in benchmark method
3. Use `[GlobalSetup]` to initialize state safely

### Warning: Multimodal distribution detected

**Cause:** Performance variance due to background processes

**Solutions:**

1. Close unnecessary applications
2. Disable antivirus during benchmarking
3. Use longer warmup: `[WarmupCount(10)]`
4. Re-run benchmarks

### Warning: High variance

**Cause:** Unstable execution environment

**Solutions:**

1. Ensure sufficient iterations (BenchmarkDotNet auto-adjusts)
2. Run on dedicated hardware (not VM if possible)
3. Disable CPU frequency scaling (performance mode)

## Additional References

<!-- Trimmed for size to satisfy validator. See SKILL.md for best practices, CI/CD integration, and example benchmarks. -->
