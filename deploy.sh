#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — Azure Static Website Deployment
# Portfolio: Amanullah Katpar | DecodeLabs Cloud Computing Internship 2026
#
# Usage:
#   chmod +x deploy.sh
#   ./deploy.sh
#
# Prerequisites:
#   - Azure CLI installed (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
#   - Run `az login` before executing this script, OR set AZURE_CREDENTIALS env var
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-portfolio"
LOCATION="eastus"
STORAGE_ACCOUNT="amanullahportfolio"   # must be globally unique, 3-24 chars, lowercase alphanumeric only
# ──────────────────────────────────────────────────────────────────────────────

# Colours for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

info()    { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✔${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "${RED}✖${NC}  $1"; exit 1; }

# ── Pre-flight checks ─────────────────────────────────────────────────────────
command -v az &>/dev/null || error "Azure CLI not found. Install from https://aka.ms/InstallAzureCLIDeb"

# Check we're logged in
if ! az account show &>/dev/null; then
  warn "Not logged in to Azure. Running 'az login'..."
  az login
fi

SUBSCRIPTION_NAME=$(az account show --query "name" -o tsv)
info "Using Azure subscription: ${SUBSCRIPTION_NAME}"

# ── Step 1: Create Resource Group ─────────────────────────────────────────────
info "Step 1/5 — Creating resource group '${RESOURCE_GROUP}' in ${LOCATION}..."
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --output none
success "Resource group ready."

# ── Step 2: Create Storage Account ────────────────────────────────────────────
info "Step 2/5 — Creating storage account '${STORAGE_ACCOUNT}'..."
az storage account create \
  --name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access true \
  --min-tls-version TLS1_2 \
  --output none
success "Storage account created."

# ── Step 3: Enable Static Website Hosting ─────────────────────────────────────
info "Step 3/5 — Enabling static website hosting..."
az storage blob service-properties update \
  --account-name "${STORAGE_ACCOUNT}" \
  --static-website \
  --index-document "index.html" \
  --404-document "index.html" \
  --auth-mode login \
  --output none
success "Static website hosting enabled."

# ── Step 4: Upload website files to \$web container ───────────────────────────
info "Step 4/5 — Uploading website files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Upload HTML files
az storage blob upload-batch \
  --account-name "${STORAGE_ACCOUNT}" \
  --source "${SCRIPT_DIR}" \
  --destination "\$web" \
  --pattern "*.html" \
  --content-type "text/html" \
  --overwrite \
  --auth-mode login \
  --output none

# Upload CSS files
az storage blob upload-batch \
  --account-name "${STORAGE_ACCOUNT}" \
  --source "${SCRIPT_DIR}" \
  --destination "\$web" \
  --pattern "*.css" \
  --content-type "text/css" \
  --overwrite \
  --auth-mode login \
  --output none

# Upload JavaScript files
az storage blob upload-batch \
  --account-name "${STORAGE_ACCOUNT}" \
  --source "${SCRIPT_DIR}" \
  --destination "\$web" \
  --pattern "*.js" \
  --content-type "application/javascript" \
  --overwrite \
  --auth-mode login \
  --output none

# Upload assets (favicon, images, etc.)
if [ -d "${SCRIPT_DIR}/assets" ]; then
  az storage blob upload-batch \
    --account-name "${STORAGE_ACCOUNT}" \
    --source "${SCRIPT_DIR}/assets" \
    --destination "\$web/assets" \
    --overwrite \
    --auth-mode login \
    --output none
fi

success "All files uploaded."

# ── Step 5: Print live URL ─────────────────────────────────────────────────────
info "Step 5/5 — Retrieving live URL..."
LIVE_URL=$(az storage account show \
  --name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "primaryEndpoints.web" \
  --output tsv)

echo ""
echo -e "${GREEN}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│${NC}  🌍  Portfolio is LIVE!                                  ${GREEN}│${NC}"
echo -e "${GREEN}│${NC}                                                          ${GREEN}│${NC}"
echo -e "${GREEN}│${NC}  URL: ${BLUE}${LIVE_URL}${NC}"
echo -e "${GREEN}│${NC}                                                          ${GREEN}│${NC}"
echo -e "${GREEN}│${NC}  Share this link with your DecodeLabs mentor ✔          ${GREEN}│${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────┘${NC}"
echo ""
