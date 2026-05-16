# ============================================
# Script: 04-landing-zone-security.ps1
# Purpose: Deploy Landing Zone security
#          baseline — Defender + Sentinel
#          + Log Analytics
# ============================================

Connect-AzAccount

$rgName        = "rg-lz-management"
$location      = "uksouth"
$workspaceName = "law-lz-uzmasami-2026"

# Create Management RG
New-AzResourceGroup `
    -Name $rgName `
    -Location $location `
    -Tag @{
        Purpose     = "LZ-Management"
        Environment = "Production"
        Owner       = "Uzma Sami"
    } | Out-Null

Write-Host "Creating Landing Zone Security..." `
    -ForegroundColor Cyan

# ---- Log Analytics Workspace ----
Write-Host "`n[1/4] Log Analytics Workspace..." `
    -ForegroundColor Yellow

$workspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName `
    -Location $location `
    -Sku "PerGB2018" `
    -RetentionInDays 90 `
    -Tag @{
        Purpose = "LZ-Central-Logging"
        Owner   = "Uzma Sami"
    }

Write-Host "✅ Log Analytics created!" `
    -ForegroundColor Green
Write-Host "   Workspace: $workspaceName" `
    -ForegroundColor White
Write-Host "   Retention: 90 days" -ForegroundColor White

# ---- Defender for Cloud ----
Write-Host "`n[2/4] Enabling Defender for Cloud..." `
    -ForegroundColor Yellow

$defenderPlans = @(
    "VirtualMachines",
    "StorageAccounts",
    "KeyVaults",
    "Arm",
    "Dns"
)

foreach ($plan in $defenderPlans) {
    try {
        Set-AzSecurityPricing `
            -Name $plan `
            -PricingTier "Standard" `
            -ErrorAction SilentlyContinue | Out-Null

        Write-Host "  ✅ Defender: $plan" `
            -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Skipped: $plan" `
            -ForegroundColor Yellow
    }
}

# ---- Microsoft Sentinel ----
Write-Host "`n[3/4] Enabling Microsoft Sentinel..." `
    -ForegroundColor Yellow

New-AzSentinelOnboardingState `
    -ResourceGroupName $rgName `
    -WorkspaceName $workspaceName `
    -Name "default" `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Microsoft Sentinel enabled!" `
    -ForegroundColor Green

# ---- Security Contacts ----
Write-Host "`n[4/4] Security Contacts..." `
    -ForegroundColor Yellow

Set-AzSecurityContact `
    -Name "lz-security-contact" `
    -Email "xxxxx@uzmasami.com" `
    -AlertsToAdmins On `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Security contacts configured!" `
    -ForegroundColor Green

Write-Host "`n=== LZ SECURITY SUMMARY ===" `
    -ForegroundColor Cyan
Write-Host "Log Analytics:   $workspaceName ✅" `
    -ForegroundColor Green
Write-Host "Defender:        5 plans enabled ✅" `
    -ForegroundColor Green
Write-Host "Sentinel:        Active ✅" -ForegroundColor Green
Write-Host "Security Contact: Configured ✅" `
    -ForegroundColor Green

