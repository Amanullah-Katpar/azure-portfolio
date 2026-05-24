# ☁ Azure Static Portfolio — Amanullah Katpar

> **DecodeLabs Cloud Computing Internship 2026 · Project 1: The Global Launch**

A personal portfolio website hosted **entirely on Azure Blob Storage** as a static website — no servers, no app service, no compute costs. Just pure cloud storage serving HTML, CSS, and JavaScript globally.

🌍 **Live URL:** *(fill in after first deploy — e.g. `https://amanullahportfolio.z13.web.core.windows.net/`)*

---

## 🏗 Architecture

```
Browser → Azure Blob Storage ($web container) → Static Website Endpoint
                                                         ↑
                               GitHub Actions auto-deploys on push to main
```

| Component | Service | Why |
|-----------|---------|-----|
| Hosting | Azure Blob Storage (Static Website) | Serverless, globally available, ~free |
| Storage tier | Standard_LRS | Cheapest tier, sufficient for a portfolio |
| Account kind | StorageV2 | Required for static website feature |
| CI/CD | GitHub Actions | Auto-deploy on every push to `main` |

---

## 📁 File Structure

```
azure-portfolio/
├── index.html                  # Single-page portfolio
├── style.css                   # Azure-themed responsive styles
├── script.js                   # Navbar, animations, scroll-reveal
├── assets/
│   └── favicon.svg             # Cloud favicon
├── deploy.sh                   # Manual Azure CLI deployment script
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
└── README.md                   # This file
```

---

## 🖥 Local Preview

No build step required. Serve the files locally with Python:

```bash
python3 -m http.server 8080
# open http://localhost:8080
```

Or with Node.js:

```bash
npx serve .
```

---

## 🚀 Azure Deployment

### Option A — Run the deploy script (first time setup)

#### Prerequisites

1. Install Azure CLI:
   ```bash
   # macOS
   brew install azure-cli
   
   # Ubuntu / Debian
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Windows (PowerShell)
   winget install Microsoft.AzureCLI
   ```

2. Login to Azure:
   ```bash
   az login
   ```

#### Run the script

```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Create resource group `rg-portfolio` in `eastus`
2. Create storage account `amanullahportfolio` (Standard_LRS, StorageV2)
3. Enable static website hosting with `index.html` as the index document
4. Upload all website files to the `$web` container
5. Print your live URL

> **Note on storage account name:** The name `amanullahportfolio` must be globally unique across all Azure customers. If it's taken, edit `STORAGE_ACCOUNT` in `deploy.sh` (3–24 lowercase alphanumeric characters).

---

### Option B — GitHub Actions CI/CD (auto-deploy on push)

After the first deploy via `deploy.sh`, set up GitHub Actions so every push to `main` automatically deploys the updated site.

#### Step 1: Create a service principal

```bash
# Replace <SUBSCRIPTION_ID> with your Azure subscription ID
# Get it via: az account show --query id -o tsv

az ad sp create-for-rbac \
  --name "github-portfolio-deploy" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-portfolio \
  --sdk-auth
```

Copy the entire JSON output — you'll need it in the next step.

#### Step 2: Add GitHub Secrets

Go to your repository → **Settings → Secrets and variables → Actions → New repository secret**

| Secret name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | The full JSON from Step 1 |
| `STORAGE_ACCOUNT` | `amanullahportfolio` |
| `RESOURCE_GROUP` | `rg-portfolio` |

#### Step 3: Push to main

```bash
git add .
git commit -m "update portfolio"
git push origin main
```

GitHub Actions will pick it up automatically. Check the **Actions** tab in your repo for live logs.

---

## 💰 Cost Estimate

Azure Blob Storage for a static portfolio site is essentially **free at this scale**:

| Item | Est. Cost |
|------|-----------|
| Storage (< 1 MB of HTML/CSS/JS) | ~$0.000 / month |
| Outbound data (< 1 GB / month) | ~$0.087 / GB = < $0.09 |
| Static website endpoint | Free |
| **Total** | **< $0.10 / month** |

---

## 📚 What I Learned (Project Reflection)

- Configured Azure Blob Storage for static website hosting without provisioning any servers
- Set storage account public access policies and blob service properties via Azure CLI
- Wrote a parameterised `deploy.sh` script with proper error handling (`set -euo pipefail`)
- Set up a GitHub Actions pipeline using `azure/login` and `azure/cli` actions with OIDC-style service principal auth
- Understood the `$web` magic container that Azure creates when static hosting is enabled

---

## 🛠 Tech Stack

- **Frontend:** Vanilla HTML5, CSS3 (custom properties, CSS Grid, Flexbox), ES6 JavaScript
- **Hosting:** Azure Blob Storage — Static Website
- **CI/CD:** GitHub Actions
- **CLI:** Azure CLI 2.x

---

*Built for DecodeLabs · Batch 2026 · Cloud Computing Track*
