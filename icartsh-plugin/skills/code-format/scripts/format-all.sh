#!/usr/bin/env bash
# Format script for PigeonPea - runs all code formatters
# This script formats both .NET code (dotnet format) and other files (prettier)

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail # Exit on pipeline failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOTNET_DIR="$REPO_ROOT/dotnet"
SOLUTION_FILE="$DOTNET_DIR/PigeonPea.sln"
VERIFY_MODE="${VERIFY_MODE:-false}"
VERBOSE="${VERBOSE:-false}"
SKIP_DOTNET="${SKIP_DOTNET:-false}"
SKIP_PRETTIER="${SKIP_PRETTIER:-false}"

# Functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Format all code in the PigeonPea repository using dotnet format and prettier.

OPTIONS:
    -v, --verify               Verify-only mode (no modifications, check formatting)
    -V, --verbose              Verbose output
    --skip-dotnet              Skip .NET code formatting
    --skip-prettier            Skip Prettier formatting
    -h, --help                 Show this help message

ENVIRONMENT VARIABLES:
    VERIFY_MODE      Verify-only mode (default: false)
    VERBOSE          Verbose output (default: false)
    SKIP_DOTNET      Skip .NET formatting (default: false)
    SKIP_PRETTIER    Skip Prettier formatting (default: false)

EXAMPLES:
    # Format all code
    $0

    # Verify formatting without modifications (CI/CD mode)
    $0 --verify

    # Format only .NET code
    $0 --skip-prettier

    # Format only non-.NET code
    $0 --skip-dotnet

    # Verbose output
    $0 --verbose

EOF
}

check_prerequisites() {
    local missing_tools=()

    if [[ "$SKIP_DOTNET" == "false" ]]; then
        if ! command -v dotnet &> /dev/null; then
            missing_tools+=(".NET SDK")
        fi
    fi

    if [[ "$SKIP_PRETTIER" == "false" ]]; then
        if ! command -v node &> /dev/null; then
            missing_tools+=("Node.js")
        fi
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and try again."
        exit 1
    fi

    if [[ "$SKIP_DOTNET" == "false" ]]; then
        if [[ ! -f "$SOLUTION_FILE" ]]; then
            print_error "Solution file not found: $SOLUTION_FILE"
            exit 1
        fi

        if [[ "$VERBOSE" == "true" ]]; then
            print_info ".NET SDK version: $(dotnet --version)"
        fi
    fi

    if [[ "$SKIP_PRETTIER" == "false" && "$VERBOSE" == "true" ]]; then
        print_info "Node.js version: $(node --version)"
    fi
}

format_dotnet() {
    if [[ "$SKIP_DOTNET" == "true" ]]; then
        print_warning "Skipping .NET code formatting"
        return 0
    fi

    print_step "Formatting .NET code (C# files)..."

    cd "$DOTNET_DIR"

    local format_args=("$SOLUTION_FILE")

    if [[ "$VERIFY_MODE" == "true" ]]; then
        format_args+=("--verify-no-changes")
        print_info "Running dotnet format in verify mode..."
    else
        print_info "Running dotnet format..."
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        format_args+=("--verbosity" "detailed")
    fi

    if dotnet format "${format_args[@]}"; then
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_info "✓ .NET code formatting verified (no violations)"
        else
            print_info "✓ .NET code formatting complete"
        fi
        cd "$REPO_ROOT"
        return 0
    else
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_error "✗ .NET code formatting violations found"
            print_error "Run 'dotnet format $SOLUTION_FILE' to fix"
        else
            print_error "✗ .NET code formatting failed"
        fi
        cd "$REPO_ROOT"
        return 1
    fi
}

format_prettier() {
    if [[ "$SKIP_PRETTIER" == "true" ]]; then
        print_warning "Skipping Prettier formatting"
        return 0
    fi

    print_step "Formatting non-.NET files (JSON, YAML, Markdown)..."

    cd "$REPO_ROOT"

    local prettier_patterns=(
        "**/*.json"
        "**/*.yml"
        "**/*.yaml"
        "**/*.md"
    )

    # Add JavaScript/TypeScript if present
    if find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) | grep -q .; then
        prettier_patterns+=(
            "**/*.js"
            "**/*.jsx"
            "**/*.ts"
            "**/*.tsx"
        )
    fi

    local prettier_args=()

    if [[ "$VERIFY_MODE" == "true" ]]; then
        prettier_args+=("--check")
        print_info "Running prettier in check mode..."
    else
        prettier_args+=("--write")
        print_info "Running prettier..."
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        prettier_args+=("--loglevel" "debug")
    fi

    local all_success=true

    if [[ "$VERBOSE" == "true" ]]; then
        print_info "Formatting patterns: ${prettier_patterns[*]}"
    fi

    # Run prettier on all patterns at once for better performance
    if ! npx prettier "${prettier_args[@]}" "${prettier_patterns[@]}" --no-error-on-unmatched-pattern; then
        all_success=false
    fi

    if [[ "$all_success" == "true" ]]; then
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_info "✓ Prettier formatting verified (no violations)"
        else
            print_info "✓ Prettier formatting complete"
        fi
        return 0
    else
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_error "✗ Prettier formatting violations found"
            print_error "Run 'npx prettier --write \"**/*.{json,yml,yaml,md}\"' to fix"
        else
            print_error "✗ Prettier formatting failed"
        fi
        return 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verify)
            VERIFY_MODE=true
            shift
            ;;
        -V|--verbose)
            VERBOSE=true
            shift
            ;;
        --skip-dotnet)
            SKIP_DOTNET=true
            shift
            ;;
        --skip-prettier)
            SKIP_PRETTIER=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate options
if [[ "$SKIP_DOTNET" == "true" && "$SKIP_PRETTIER" == "true" ]]; then
    print_error "Cannot skip both dotnet and prettier formatting"
    exit 1
fi

# Main execution
main() {
    print_info "========================================="
    print_info "PigeonPea Code Format Script"
    print_info "========================================="
    print_info "Repository: $REPO_ROOT"
    if [[ "$VERIFY_MODE" == "true" ]]; then
        print_info "Mode: Verify (check-only, no modifications)"
    else
        print_info "Mode: Format (will modify files)"
    fi
    print_info "========================================="

    check_prerequisites

    local dotnet_result=0
    local prettier_result=0

    # Format .NET code
    if ! format_dotnet; then
        dotnet_result=1
    fi

    # Format non-.NET files
    if ! format_prettier; then
        prettier_result=1
    fi

    # Summary
    print_info "========================================="
    print_info "Summary"
    print_info "========================================="

    if [[ "$SKIP_DOTNET" == "false" ]]; then
        if [[ $dotnet_result -eq 0 ]]; then
            print_info ".NET formatting: ✓ Success"
        else
            print_error ".NET formatting: ✗ Failed"
        fi
    fi

    if [[ "$SKIP_PRETTIER" == "false" ]]; then
        if [[ $prettier_result -eq 0 ]]; then
            print_info "Prettier formatting: ✓ Success"
        else
            print_error "Prettier formatting: ✗ Failed"
        fi
    fi

    local total_result=$((dotnet_result + prettier_result))

    if [[ $total_result -eq 0 ]]; then
        print_info "========================================="
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_info "All formatting verified successfully!"
        else
            print_info "All formatting completed successfully!"
        fi
        print_info "========================================="
        exit 0
    else
        print_error "========================================="
        if [[ "$VERIFY_MODE" == "true" ]]; then
            print_error "Formatting violations found!"
            print_error "Run '$0' to fix formatting issues"
        else
            print_error "Formatting failed!"
        fi
        print_error "========================================="
        exit 1
    fi
}

main
