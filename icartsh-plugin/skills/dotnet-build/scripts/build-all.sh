#!/usr/bin/env bash
# Build script for PigeonPea .NET solution
# This script provides a convenient way to build the solution with common options

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail # Exit on pipeline failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SOLUTION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)/dotnet"
SOLUTION_FILE="$SOLUTION_DIR/PigeonPea.sln"
CONFIGURATION="${CONFIGURATION:-Debug}"
VERBOSITY="${VERBOSITY:-normal}"
RESTORE="${RESTORE:-true}"

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

print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build the PigeonPea .NET solution.

OPTIONS:
    -c, --configuration <config>   Build configuration: Debug or Release (default: Debug)
    -r, --no-restore               Skip package restore
    -v, --verbosity <level>        Verbosity level: quiet, minimal, normal, detailed, diagnostic (default: normal)
    -C, --clean                    Clean before building
    -h, --help                     Show this help message

ENVIRONMENT VARIABLES:
    CONFIGURATION    Build configuration (default: Debug)
    VERBOSITY        Verbosity level (default: normal)
    RESTORE          Whether to restore packages (default: true)

EXAMPLES:
    # Build with defaults (Debug, restore, normal verbosity)
    $0

    # Build Release configuration without restore
    $0 --configuration Release --no-restore

    # Build with detailed output
    $0 --verbosity detailed

    # Clean and build
    $0 --clean

EOF
}

check_prerequisites() {
    if ! command -v dotnet &> /dev/null; then
        print_error ".NET SDK not found. Please install .NET SDK 9.0 or later."
        exit 1
    fi

    if [[ ! -f "$SOLUTION_FILE" ]]; then
        print_error "Solution file not found: $SOLUTION_FILE"
        exit 1
    fi

    print_info ".NET SDK version: $(dotnet --version)"
}

clean_solution() {
    print_info "Cleaning solution..."
    cd "$SOLUTION_DIR"
    dotnet clean "$SOLUTION_FILE" --configuration "$CONFIGURATION" --verbosity "$VERBOSITY"
    print_info "Clean completed"
}

restore_packages() {
    if [[ "$RESTORE" == "true" ]]; then
        print_info "Restoring packages..."
        cd "$SOLUTION_DIR"
        dotnet restore "$SOLUTION_FILE" --verbosity "$VERBOSITY"
        print_info "Restore completed"
    else
        print_warning "Skipping package restore"
    fi
}

build_solution() {
    print_info "Building solution with configuration: $CONFIGURATION"
    cd "$SOLUTION_DIR"

    local build_args=("$SOLUTION_FILE")
    build_args+=("--configuration" "$CONFIGURATION")
    build_args+=("--verbosity" "$VERBOSITY")

    if [[ "$RESTORE" == "false" ]]; then
        build_args+=("--no-restore")
    fi

    if ! dotnet build "${build_args[@]}"; then
        print_error "Build failed!"
        return 1
    fi

    print_info "Build succeeded!"
    return 0
}

# Parse arguments
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--configuration)
            if [[ -z "${2-}" || "$2" =~ ^- ]]; then
                print_error "Option '$1' requires an argument."
                exit 1
            fi
            CONFIGURATION="$2"
            shift 2
            ;;
        --configuration=*)
            CONFIGURATION="${1#*=}"
            shift
            ;;
        -r|--no-restore)
            RESTORE=false
            shift
            ;;
        -v|--verbosity)
            if [[ -z "${2-}" || "$2" =~ ^- ]]; then
                print_error "Option '$1' requires an argument."
                exit 1
            fi
            VERBOSITY="$2"
            shift 2
            ;;
        --verbosity=*)
            VERBOSITY="${1#*=}"
            shift
            ;;
        -C|--clean)
            CLEAN=true
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

# Validate configuration
if [[ "$CONFIGURATION" != "Debug" && "$CONFIGURATION" != "Release" ]]; then
    print_error "Invalid configuration: $CONFIGURATION (must be Debug or Release)"
    exit 1
fi

# Validate verbosity
case "$VERBOSITY" in
    quiet|minimal|normal|detailed|diagnostic)
        ;;
    *)
        print_error "Invalid verbosity: $VERBOSITY"
        exit 1
        ;;
esac

# Main execution
main() {
    print_info "========================================="
    print_info "PigeonPea .NET Build Script"
    print_info "========================================="
    print_info "Solution: $SOLUTION_FILE"
    print_info "Configuration: $CONFIGURATION"
    print_info "Verbosity: $VERBOSITY"
    print_info "Restore: $RESTORE"
    print_info "========================================="

    check_prerequisites

    if [[ "$CLEAN" == "true" ]]; then
        clean_solution
    fi

    restore_packages
    build_solution

    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        print_info "========================================="
        print_info "Build completed successfully!"
        print_info "========================================="
        print_info "Artifacts location:"
        print_info "  $SOLUTION_DIR/*/bin/$CONFIGURATION/"
    else
        print_error "========================================="
        print_error "Build failed with exit code: $exit_code"
        print_error "========================================="
    fi

    exit $exit_code
}

main
