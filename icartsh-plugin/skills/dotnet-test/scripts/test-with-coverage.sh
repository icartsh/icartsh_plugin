#!/bin/bash

# test-with-coverage.sh
# Run .NET tests with code coverage and generate HTML report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to dotnet directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$REPO_ROOT/dotnet"

if [ ! -f "PigeonPea.sln" ]; then
  echo -e "${RED}Error: PigeonPea.sln not found. Are you in the dotnet directory?${NC}"
  exit 1
fi

echo -e "${GREEN}Running tests with code coverage...${NC}"

# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage" --results-directory ./TestResults --verbosity normal

# Check if coverage file was generated
COVERAGE_FILE=$(find ./TestResults -name "coverage.cobertura.xml" | head -n 1)

if [ -z "$COVERAGE_FILE" ]; then
  echo -e "${RED}Error: Coverage file not found. Coverage collection may have failed.${NC}"
  exit 1
fi

echo -e "${GREEN}Coverage file generated: $COVERAGE_FILE${NC}"

# Check if ReportGenerator is installed
if ! command -v reportgenerator &> /dev/null; then
  echo -e "${YELLOW}ReportGenerator not found. Installing...${NC}"
  dotnet tool install -g dotnet-reportgenerator-globaltool
fi

echo -e "${GREEN}Generating HTML coverage report...${NC}"

# Generate HTML report and XML summary for accurate, merged coverage
reportgenerator \
  -reports:"./TestResults/*/coverage.cobertura.xml" \
  -targetdir:"./TestResults/CoverageReport" \
  -reporttypes:"Html;Badges;XmlSummary"

echo -e "${GREEN}Coverage report generated at: ./TestResults/CoverageReport/index.html${NC}"

# Extract coverage percentage from the merged summary report for accuracy and portability
COVERAGE_PERCENT=$(awk -F'[<>]' '/<Linecoverage>/ {print $3}' "./TestResults/CoverageReport/Summary.xml")

echo -e "${GREEN}Line Coverage: ${COVERAGE_PERCENT}%${NC}"

# Optional: Open report in browser (uncomment if desired)
# if command -v xdg-open &> /dev/null; then
#   xdg-open ./TestResults/CoverageReport/index.html
# elif command -v open &> /dev/null; then
#   open ./TestResults/CoverageReport/index.html
# fi

echo -e "${GREEN}Done!${NC}"
