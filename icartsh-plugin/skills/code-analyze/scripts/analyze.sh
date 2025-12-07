#!/bin/bash
# analyze.sh - Comprehensive code analysis script for PigeonPea
#
# Usage:
#   ./analyze.sh [--all|--static|--security|--dependencies]
#   ./analyze.sh --help
#
# Examples:
#   ./analyze.sh --all              # Run all analysis checks
#   ./analyze.sh --static           # Run static code analysis only
#   ./analyze.sh --security         # Run security scans only
#   ./analyze.sh --dependencies     # Run dependency vulnerability checks only

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
DOTNET_DIR="${REPO_ROOT}/dotnet"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

run_check() {
    local check_name="$1"
    shift
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    print_info "Running: $check_name"

    if "$@"; then
        print_success "$check_name passed"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        print_error "$check_name failed"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Analysis functions
run_static_analysis() {
    print_header "Static Code Analysis"

    if ! command_exists dotnet; then
        print_error ".NET SDK not found. Install .NET SDK 9.0 or later."
        return 1
    fi

    cd "$DOTNET_DIR"

    # Check if solution needs restore
    if [ ! -d "shared-app/obj" ]; then
        print_info "Restoring dependencies first..."
        if ! dotnet restore PigeonPea.sln --verbosity quiet; then
            print_error "Failed to restore dependencies"
            return 1
        fi
    fi

    print_info "Building with Roslyn analyzers enabled..."
    BUILD_OUTPUT=$(dotnet build PigeonPea.sln \
        /p:RunAnalyzers=true \
        /p:TreatWarningsAsErrors=false \
        --verbosity minimal \
        --nologo 2>&1)
    BUILD_EXIT=$?

    if [ $BUILD_EXIT -ne 0 ]; then
        print_error "Build failed - fix compilation errors first"
        echo "$BUILD_OUTPUT"
        return 1
    fi

    # Count CA (analyzer) and CS (compiler) warnings
    CA_WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -c "warning CA" || true)
    CS_WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -c "warning CS" || true)
    TOTAL_WARNINGS=$((CA_WARNING_COUNT + CS_WARNING_COUNT))

    if [ "$TOTAL_WARNINGS" -gt 0 ]; then
        if [ "$CA_WARNING_COUNT" -gt 0 ]; then
            print_warning "Found $CA_WARNING_COUNT analyzer (CA) warnings"
            echo "$BUILD_OUTPUT" | grep "warning CA" || true
        fi
        if [ "$CS_WARNING_COUNT" -gt 0 ]; then
            print_info "Found $CS_WARNING_COUNT compiler (CS) warnings"
            echo "$BUILD_OUTPUT" | grep "warning CS" || true
        fi
        return 0  # Warnings don't fail the check
    else
        print_success "No warnings found - clean build!"
        return 0
    fi
}

run_security_scan() {
    print_header "Security Scanning"

    # Check for pre-commit
    if ! command_exists pre-commit; then
        print_warning "pre-commit not installed. Install with: pip install pre-commit"
        return 1
    fi

    cd "$REPO_ROOT"

    local security_passed=true

    # Run gitleaks
    if run_check "gitleaks" pre-commit run gitleaks --all-files --verbose; then
        :
    else
        security_passed=false
    fi

    # Run detect-secrets
    if run_check "detect-secrets" pre-commit run detect-secrets --all-files --verbose; then
        :
    else
        security_passed=false
    fi

    # Run .NET security analyzers
    print_info "Running .NET security analyzers..."
    cd "$DOTNET_DIR"
    if run_check ".NET security analyzers" \
        dotnet build PigeonPea.sln \
        /p:RunAnalyzers=true \
        /warnaserror:CA5350,CA5351,CA5359,CA5364,CA5379,CA5384 \
        --verbosity quiet \
        --nologo; then
        :
    else
        security_passed=false
    fi

    if [ "$security_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

run_dependency_check() {
    print_header "Dependency Vulnerability Check"

    if ! command_exists dotnet; then
        print_error ".NET SDK not found"
        return 1
    fi

    cd "$DOTNET_DIR"

    print_info "Checking for vulnerable packages (including transitive)..."

    # Run vulnerability check and capture output
    VULN_OUTPUT=$(dotnet list package --vulnerable --include-transitive 2>&1)
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        if echo "$VULN_OUTPUT" | grep -q "Severity"; then # Vulnerability tables have a "Severity" header
            print_error "Vulnerable packages detected!"
            echo "$VULN_OUTPUT"
            return 1
        else
            print_warning "Dependency check failed with an unexpected error."
            echo "$VULN_OUTPUT"
            return 1
        fi
    else
        print_success "No vulnerable packages found"
        return 0
    fi
}

run_all_checks() {
    print_header "Running All Analysis Checks"

    local all_passed=true

    if ! run_check "Static analysis" run_static_analysis; then
        all_passed=false
    fi

    if ! run_security_scan; then
        all_passed=false
    fi

    if ! run_check "Dependency vulnerability check" run_dependency_check; then
        all_passed=false
    fi

    if [ "$all_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

show_summary() {
    print_header "Analysis Summary"
    echo "Total checks: $TOTAL_CHECKS"
    echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"

    if [ $FAILED_CHECKS -eq 0 ]; then
        print_success "All analysis checks passed!"
        return 0
    else
        print_error "Some analysis checks failed"
        return 1
    fi
}

show_help() {
    cat << EOF
Code Analysis Script for PigeonPea

Usage:
  $0 [OPTIONS]

Options:
  --all           Run all analysis checks (default)
  --static        Run static code analysis only (Roslyn analyzers)
  --security      Run security scans only (gitleaks, detect-secrets)
  --dependencies  Run dependency vulnerability checks only
  --help          Show this help message

Examples:
  $0                      # Run all checks
  $0 --all                # Run all checks
  $0 --static             # Static analysis only
  $0 --security           # Security scans only
  $0 --dependencies       # Dependency checks only

Exit codes:
  0 - All checks passed
  1 - One or more checks failed

Requirements:
  - .NET SDK 9.0 or later
  - pre-commit (for security scans)
  - Internet connection (for dependency checks)

For more information, see:
  - .agent/skills/code-analyze/SKILL.md
  - .agent/skills/code-analyze/references/static-analysis.md
  - .agent/skills/code-analyze/references/security-scan.md
  - .agent/skills/code-analyze/references/dependency-check.md
EOF
}

# Main script
main() {
    print_header "PigeonPea Code Analysis"

    # Parse arguments
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --static)
            run_check "Static analysis" run_static_analysis
            ;;
        --security)
            run_security_scan
            ;;
        --dependencies|--deps)
            run_check "Dependency vulnerability check" run_dependency_check
            ;;
        --all|"")
            run_all_checks
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac

    local exit_code=$?

    if [ "${1:-}" != "--help" ]; then
        show_summary
        exit_code=$?
    fi

    exit $exit_code
}

# Run main
main "$@"
