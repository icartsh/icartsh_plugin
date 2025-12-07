# Security Scanning - Detailed Procedure

## Overview

This guide provides step-by-step instructions for running security scans on the PigeonPea project using gitleaks, detect-secrets, and .NET security analyzers.

## Prerequisites

- **Pre-commit installed** (check: `pre-commit --version`)
- **gitleaks** configured in `.pre-commit-config.yaml`
- **detect-secrets** configured in `.pre-commit-config.yaml`
- **.NET SDK 9.0** for security analyzers

## Security Scanning Tools

### 1. Gitleaks (Secret Detection)

Scans Git history and files for hardcoded secrets, API keys, passwords, tokens.

**What it detects:**

- API keys (AWS, Azure, GitHub, etc.)
- Private keys and certificates
- Database connection strings
- OAuth tokens and secrets
- Passwords and credentials

**Configuration:** `.gitleaksignore` for false positives

### 2. Detect-Secrets (Secret Baseline)

Scans files for potential secrets using heuristics and maintains a baseline of known false positives.

**What it detects:**

- High entropy strings (potential passwords/keys)
- Base64-encoded secrets
- Hex-encoded secrets
- Private key headers

**Configuration:** `.secrets.baseline` for false positive baseline

### 3. .NET Security Analyzers (CA5xxx Rules)

Built-in Roslyn analyzers that detect security vulnerabilities in C# code.

**What it detects:**

- Insecure cryptography usage
- SQL injection vulnerabilities
- Path traversal issues
- XML external entity (XXE) attacks
- Insecure deserialization
- CSRF vulnerabilities

## Standard Security Scan Flow

### Step 1: Run Pre-commit Secret Detection

```bash
pre-commit run gitleaks --all-files
pre-commit run detect-secrets --all-files
```

This scans all files in the repository for secrets.

### Step 2: Run .NET Security Analysis

```bash
cd ./dotnet
dotnet build PigeonPea.sln /p:RunAnalyzers=true /p:TreatWarningsAsErrors=true
```

Security rules (CA5xxx) are enabled by default and run during build.

### Step 3: Review Findings

**Gitleaks output:**

```
INFO[0000] 7 commits scanned.
INFO[0000] scan completed in 142ms
INFO[0000] No leaks found
```

**Detect-secrets output:**

```
detect-secrets...........Passed
```

**Security analyzer output:**

```
console-app/Program.cs(42,15): warning CA5351: Do Not Use Broken Cryptographic Algorithms
```

## Additional References

<!-- Trimmed for size to satisfy validator. See SKILL.md for overview and runbook links. -->
