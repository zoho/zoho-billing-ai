# Zoho Billing AI - Claude Code Installer for Windows
# PowerShell installation script for Zoho Billing AI agents

param(
    [switch]$SkipValidation,
    [switch]$NonInteractive
)

# Color output function
function Write-ColorOutput {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Message,
        [ValidateSet('Green', 'Red', 'Yellow', 'Blue', 'Cyan')]
        [string]$Color = 'White'
    )

    $colors = @{
        'Green'  = 'Green'
        'Red'    = 'Red'
        'Yellow' = 'Yellow'
        'Blue'   = 'Cyan'
        'Cyan'   = 'Cyan'
    }

    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Show-Banner {
    Write-Host "`n" -NoNewline
    Write-ColorOutput "╔════════════════════════════════════════════╗" -Color 'Cyan'
    Write-ColorOutput "║   Zoho Billing AI Claude Code Installer    ║" -Color 'Cyan'
    Write-ColorOutput "║   Payment Intelligence & Quote Management   ║" -Color 'Cyan'
    Write-ColorOutput "╚════════════════════════════════════════════╝" -Color 'Cyan'
    Write-Host ""
}

function Check-Prerequisites {
    Write-ColorOutput "→ Checking prerequisites..." -Color 'Cyan'

    # Check for Git
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $gitVersion = & git --version
        Write-ColorOutput "✓ Git found: $gitVersion" -Color 'Green'
    } else {
        Write-ColorOutput "✗ Git not found. Please install Git first." -Color 'Red'
        exit 1
    }

    # Check for Claude CLI
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if ($claude) {
        Write-ColorOutput "✓ Claude Code CLI found" -Color 'Green'
    } else {
        Write-ColorOutput "✗ Claude Code CLI not found. Install from: https://claude.ai" -Color 'Red'
        exit 1
    }
}

function Create-PluginDirectory {
    Write-ColorOutput "→ Creating plugin directory..." -Color 'Cyan'

    $pluginDir = Join-Path $env:USERPROFILE ".claude" "plugins"

    if (Test-Path $pluginDir) {
        Write-ColorOutput "✓ Directory exists: $pluginDir" -Color 'Green'
    } else {
        try {
            New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
            Write-ColorOutput "✓ Directory created: $pluginDir" -Color 'Green'
        } catch {
            Write-ColorOutput "✗ Failed to create directory: $_" -Color 'Red'
            exit 1
        }
    }

    return $pluginDir
}

function Get-AgentSource {
    param(
        [string]$PluginDir
    )

    Write-ColorOutput "→ Fetching Zoho Billing AI agents..." -Color 'Cyan'

    # Check if running from local clone
    if ((Test-Path "claude/agents") -and (Test-Path ".git")) {
        Write-ColorOutput "→ Installing from local directory..." -Color 'Cyan'
        return $pwd
    }

    # Check if it's a GitHub clone in a temp location
    if ((Test-Path "claude/agents") -and (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "→ Installing from local directory..." -Color 'Cyan'
        return $pwd
    }

    # Otherwise clone from GitHub
    Write-ColorOutput "→ Cloning from GitHub..." -Color 'Cyan'
    $tempDir = Join-Path $env:TEMP "zoho-billing-ai-$(Get-Random)"

    try {
        & git clone https://github.com/zoho/zoho-billing-ai.git $tempDir 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Repository cloned" -Color 'Green'
            return $tempDir
        } else {
            Write-ColorOutput "✗ Failed to clone repository" -Color 'Red'
            exit 1
        }
    } catch {
        Write-ColorOutput "✗ Error cloning repository: $_" -Color 'Red'
        exit 1
    }
}

function Install-Agents {
    param(
        [string]$SourceDir,
        [string]$PluginDir
    )

    Write-ColorOutput "→ Installing agents from claude/agents/..." -Color 'Cyan'

    $agentsDir = Join-Path $SourceDir "claude" "agents"

    if (-not (Test-Path $agentsDir)) {
        Write-ColorOutput "✗ No agents directory found at $agentsDir" -Color 'Red'
        exit 1
    }

    $agents = @()
    $failedAgents = @()

    # Get all agent directories
    $agentDirs = Get-ChildItem -Path $agentsDir -Directory

    foreach ($agentDir in $agentDirs) {
        $agentName = $agentDir.Name

        # Validate agent has required files
        $hasPluginJson = Test-Path (Join-Path $agentDir.FullName ".claude-plugin" "plugin.json")
        $hasSkillMd = Test-Path (Join-Path $agentDir.FullName "SKILL.md")

        if (-not ($hasPluginJson -or $hasSkillMd)) {
            $failedAgents += $agentName
            continue
        }

        # Install agent
        $targetDir = Join-Path $PluginDir $agentName

        try {
            # Remove existing installation
            if (Test-Path $targetDir) {
                Remove-Item -Path $targetDir -Recurse -Force | Out-Null
            }

            # Copy entire agent directory
            Copy-Item -Path $agentDir.FullName -Destination $targetDir -Recurse -Force

            Write-ColorOutput "✓ Installed: $agentName" -Color 'Green'
            $agents += $agentName
        } catch {
            Write-ColorOutput "✗ Failed to install $agentName : $_" -Color 'Red'
            $failedAgents += $agentName
        }
    }

    return @{
        'Installed' = $agents
        'Failed'    = $failedAgents
    }
}

function Verify-Installation {
    param(
        [string]$PluginDir,
        [array]$Agents
    )

    Write-ColorOutput "→ Verifying installation..." -Color 'Cyan'

    foreach ($agent in $Agents) {
        $agentPath = Join-Path $PluginDir $agent
        $pluginJsonPath = Join-Path $agentPath ".claude-plugin" "plugin.json"

        if (Test-Path $pluginJsonPath) {
            Write-ColorOutput "✓ Verified: $agent" -Color 'Green'
        } else {
            Write-ColorOutput "⚠ Partial install: $agent (some files may be missing)" -Color 'Yellow'
        }
    }
}

function Show-QuickStart {
    param(
        [string]$PluginDir,
        [array]$Agents
    )

    Write-Host ""
    Write-ColorOutput "╔════════════════════════════════════════════╗" -Color 'Green'
    Write-ColorOutput "║        Installation Complete!              ║" -Color 'Green'
    Write-ColorOutput "╚════════════════════════════════════════════╝" -Color 'Green'
    Write-Host ""
    Write-Host "  Installed to: $PluginDir"
    Write-Host "  Total agents: $($Agents.Count) plugin(s)`n"

    Write-ColorOutput "Available Agents:" -Color 'Cyan'

    if ($Agents -contains "payment-intelligence-agent") {
        Write-Host "  • payment-intelligence-agent"
        Write-Host "    → Check for cards expiring soon"
        Write-Host "    → Analyze recent payment failures"
        Write-Host "    → Which subscriptions are at risk?"
    }

    if ($Agents -contains "quote-agent") {
        Write-Host "  • quote-agent"
        Write-Host "    → Show me open quotes"
        Write-Host "    → Which deals are stalling?"
        Write-Host "    → Prioritize quotes for today"
    }

    if ($Agents -contains "retention-agent") {
        Write-Host "  • retention-agent"
        Write-Host "    → Analyze churn patterns"
        Write-Host "    → Which customers at risk?"
        Write-Host "    → Win-back opportunities"
    }

    Write-Host ""
    Write-ColorOutput "Quick Start:" -Color 'Cyan'
    Write-Host "  1. Open Claude Code"
    Write-Host "  2. Use trigger phrases above to activate agents"
    Write-Host ""

    Write-ColorOutput "Configuration:" -Color 'Cyan'
    Write-Host "  Each agent requires Zoho Organization ID and API Key:"
    Write-Host "  • Find Organization ID: Zoho Billing → Settings → Organization"
    Write-Host "  • Create API Key: Zoho Billing → Settings → API Connections"
    Write-Host "  • When prompted, provide these credentials"
    Write-Host ""

    Write-ColorOutput "Documentation:" -Color 'Cyan'
    Write-Host "  GitHub: https://github.com/zoho/zoho-billing-ai"
    Write-Host "  Each agent folder contains detailed instructions"
    Write-Host ""

    Write-ColorOutput "✓ All agents installed successfully!" -Color 'Green'
    Write-Host ""
}

# Main installation flow
function Main {
    Show-Banner
    Check-Prerequisites
    $pluginDir = Create-PluginDirectory
    $sourceDir = Get-AgentSource -PluginDir $pluginDir
    $result = Install-Agents -SourceDir $sourceDir -PluginDir $pluginDir

    if ($result.Installed.Count -gt 0) {
        Verify-Installation -PluginDir $pluginDir -Agents $result.Installed
        Show-QuickStart -PluginDir $pluginDir -Agents $result.Installed
    } else {
        Write-ColorOutput "✗ No agents were installed successfully" -Color 'Red'
        exit 1
    }

    if ($result.Failed.Count -gt 0) {
        Write-ColorOutput "⚠ Failed to install: $($result.Failed -join ', ')" -Color 'Yellow'
    }
}

# Run installation
Main
