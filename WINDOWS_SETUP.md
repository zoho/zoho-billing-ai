# Windows Installation Guide

This guide covers installing Zoho Billing AI agents on Windows for Claude Code CLI.

## Quick Start (Automatic Installation)

### Prerequisites
- **PowerShell 5.0+** (included with Windows 10+)
- **Git** (download from https://git-scm.com/download/win)
- **Claude Code CLI** (https://claude.ai)

### Step 1: Open PowerShell

1. Press **Win + X** and select "Windows PowerShell" or "Windows Terminal"
2. Alternatively, press **Win + R**, type `powershell`, and press Enter

### Step 2: Allow Script Execution

PowerShell may block unsigned scripts. Run this command once:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Press `Y` and Enter to confirm.

### Step 3: Run the Installer

Copy and paste this command into PowerShell:

```powershell
iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.ps1')
```

Or download the script first:

```powershell
# Download to Downloads folder
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.ps1" `
  -OutFile "$env:USERPROFILE\Downloads\install.ps1"

# Run it
& "$env:USERPROFILE\Downloads\install.ps1"
```

### Step 4: Verify Installation

The script will:
- ✓ Check for Git and Claude Code CLI
- ✓ Create `~\.claude\plugins` directory
- ✓ Download agents from GitHub (or use local files)
- ✓ Copy all agents to the plugins directory
- ✓ Verify each agent's configuration

You should see:
```
✓ Installed: payment-intelligence-agent
✓ Installed: quote-agent
✓ Installed: retention-agent
✓ All agents installed successfully!
```

## Manual Installation

### Option A: From Local Repository

If you have the repository cloned locally:

```powershell
# Navigate to the repository
cd "C:\path\to\zoho-billing-ai"

# Run the installer
.\install.ps1
```

### Option B: From GitHub (without cloning)

```powershell
# Download install.ps1
$url = "https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.ps1"
$path = "$env:USERPROFILE\install.ps1"
Invoke-WebRequest -Uri $url -OutFile $path

# Run it
& $path
```

## Configuration

After installation, configure your credentials:

### Step 1: Get Your Zoho Organization ID

1. Go to **Zoho Billing** → **Settings** → **Organization**
2. Copy your **Organization ID**

### Step 2: Create API Key

1. Go to **Zoho Billing** → **Settings** → **API Connections**
2. Click **Create New Token**
3. Select scope: **Zoho Billing**
4. Copy the generated API Key

### Step 3: Configure Agents

When you first use an agent in Claude Code, it will prompt you for:
- Organization ID
- API Key

Paste the values you copied above.

## Uninstallation

To remove agents:

```powershell
# Remove specific agent
.\uninstall.ps1 -Agent "quote-agent"

# Remove all agents
.\uninstall.ps1 -All

# Interactive mode (shows menu)
.\uninstall.ps1
```

### Manual Uninstallation

If the script fails, manually remove agents:

```powershell
# Delete the plugins directory
Remove-Item -Path "$env:USERPROFILE\.claude\plugins" -Recurse -Force
```

## Troubleshooting

### "PowerShell scripts are disabled on this system"

Run this once:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Git not found"

Install Git from https://git-scm.com/download/win and restart PowerShell.

### "Claude CLI not found"

Install Claude Code from https://claude.ai and make sure it's in your PATH.

### "Partial install" warnings

Some files may not have copied. Try the manual installation method:

```powershell
# Download and extract repository
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
.\install.ps1
```

### Scripts location

Agents are installed to: `C:\Users\<YourUsername>\.claude\plugins\`

You can view them in File Explorer:
1. Press **Win + R**
2. Type `%USERPROFILE%\.claude\plugins`
3. Press Enter

## Using the Agents

Once installed, agents are available in Claude Code:

### Payment Intelligence Agent
```
"Check for cards expiring soon"
"Which subscriptions are at risk?"
"Show recent payment failures"
```

### Quote Agent
```
"Show me open quotes"
"Which deals are stalling?"
"Prioritize quotes for today"
```

### Retention Agent
```
"Analyze churn patterns"
"Which customers are at risk?"
"Show win-back opportunities"
```

## Support

- **GitHub Issues**: https://github.com/zoho/zoho-billing-ai/issues
- **Documentation**: Check README.md in each agent folder
- **Zoho Billing Help**: https://www.zoho.com/billing/help/

## PowerShell Script Parameters

The `install.ps1` script accepts these optional parameters:

```powershell
# Skip validation checks
.\install.ps1 -SkipValidation

# Non-interactive mode (no prompts)
.\install.ps1 -NonInteractive
```

The `uninstall.ps1` script accepts:

```powershell
# Remove specific agent (no confirmation prompt)
.\uninstall.ps1 -Agent "quote-agent" -NonInteractive

# Remove all agents
.\uninstall.ps1 -All

# Non-interactive uninstall
.\uninstall.ps1 -All -NonInteractive
```
