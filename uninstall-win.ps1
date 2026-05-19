# Zoho Billing AI - Claude Code Uninstaller for Windows
# PowerShell uninstallation script for removing Zoho Billing AI agents

param(
    [string]$Agent,
    [switch]$All,
    [switch]$NonInteractive
)

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
    Write-Host "`n"
    Write-ColorOutput "╔════════════════════════════════════════════╗" -Color 'Cyan'
    Write-ColorOutput "║   Zoho Billing AI Claude Code Uninstaller  ║" -Color 'Cyan'
    Write-ColorOutput "╚════════════════════════════════════════════╝" -Color 'Cyan'
    Write-Host ""
}

function Get-InstalledAgents {
    $pluginDir = Join-Path $env:USERPROFILE ".claude" "plugins"

    if (-not (Test-Path $pluginDir)) {
        return @()
    }

    $agents = @()
    $agentDirs = Get-ChildItem -Path $pluginDir -Directory -ErrorAction SilentlyContinue

    foreach ($agentDir in $agentDirs) {
        $pluginJsonPath = Join-Path $agentDir.FullName ".claude-plugin" "plugin.json"
        $skillMdPath = Join-Path $agentDir.FullName "SKILL.md"

        if ((Test-Path $pluginJsonPath) -or (Test-Path $skillMdPath)) {
            $agents += $agentDir.Name
        }
    }

    return $agents
}

function Show-InstalledAgents {
    param(
        [array]$Agents
    )

    if ($Agents.Count -eq 0) {
        Write-ColorOutput "✗ No agents installed" -Color 'Red'
        return $false
    }

    Write-ColorOutput "Installed Agents:" -Color 'Cyan'
    for ($i = 0; $i -lt $Agents.Count; $i++) {
        Write-Host "  $($i + 1). $($Agents[$i])"
    }
    Write-Host ""

    return $true
}

function Remove-Agent {
    param(
        [string]$AgentName,
        [string]$PluginDir
    )

    $agentPath = Join-Path $PluginDir $AgentName

    if (-not (Test-Path $agentPath)) {
        Write-ColorOutput "✗ Agent not found: $AgentName" -Color 'Red'
        return $false
    }

    try {
        Remove-Item -Path $agentPath -Recurse -Force -ErrorAction Stop
        Write-ColorOutput "✓ Removed: $AgentName" -Color 'Green'

        # Clean up empty plugin directory
        $pluginDir = Split-Path $agentPath
        $remainingAgents = @(Get-ChildItem -Path $pluginDir -Directory -ErrorAction SilentlyContinue)

        if ($remainingAgents.Count -eq 0 -and (Test-Path $pluginDir)) {
            Remove-Item -Path $pluginDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-ColorOutput "✓ Cleaned up plugin directory" -Color 'Green'
        }

        return $true
    } catch {
        Write-ColorOutput "✗ Failed to remove $AgentName : $_" -Color 'Red'
        return $false
    }
}

function Confirm-Removal {
    param(
        [array]$AgentsToRemove
    )

    if ($NonInteractive) {
        return $true
    }

    Write-Host "Agents to remove:"
    foreach ($agent in $AgentsToRemove) {
        Write-Host "  • $agent"
    }
    Write-Host ""

    $response = Read-Host "Are you sure you want to remove these agents? (yes/no)"

    if ($response -eq "yes" -or $response -eq "y") {
        return $true
    } else {
        Write-ColorOutput "Uninstallation cancelled" -Color 'Yellow'
        return $false
    }
}

function Main {
    Show-Banner

    $pluginDir = Join-Path $env:USERPROFILE ".claude" "plugins"
    $installedAgents = Get-InstalledAgents

    if (-not (Show-InstalledAgents -Agents $installedAgents)) {
        exit 1
    }

    $agentsToRemove = @()

    if ($All) {
        $agentsToRemove = $installedAgents
    } elseif ($Agent) {
        if ($installedAgents -contains $Agent) {
            $agentsToRemove = @($Agent)
        } else {
            Write-ColorOutput "✗ Agent not installed: $Agent" -Color 'Red'
            exit 1
        }
    } else {
        # Interactive mode: show options
        if ($installedAgents.Count -eq 1) {
            Write-Host "Select agent to remove (enter number or 'all' to remove all):"
        } else {
            Write-Host "Select agent(s) to remove (enter number(s) separated by comma, or 'all'):"
        }

        $selection = Read-Host "Your choice"

        if ($selection -eq "all") {
            $agentsToRemove = $installedAgents
        } else {
            $numbers = $selection -split "," | ForEach-Object { $_.Trim() }
            foreach ($num in $numbers) {
                if ([int]::TryParse($num, [ref]$null)) {
                    $index = [int]$num - 1
                    if ($index -ge 0 -and $index -lt $installedAgents.Count) {
                        $agentsToRemove += $installedAgents[$index]
                    }
                }
            }
        }
    }

    if ($agentsToRemove.Count -eq 0) {
        Write-ColorOutput "✗ No valid agents selected" -Color 'Red'
        exit 1
    }

    if (-not (Confirm-Removal -AgentsToRemove $agentsToRemove)) {
        exit 1
    }

    Write-Host ""
    foreach ($agent in $agentsToRemove) {
        Remove-Agent -AgentName $agent -PluginDir $pluginDir
    }

    Write-Host ""
    Write-ColorOutput "✓ Uninstallation complete!" -Color 'Green'
    Write-Host ""
}

Main
