# ============================================
# Script: 05-landing-zone-firewall.ps1
# Purpose: Deploy Azure Firewall in Hub VNet
#          IMPORTANT: Delete after screenshots!
# Cost: ~£0.90/hour
# ============================================

Connect-AzAccount

$rgName   = "rg-lz-connectivity"
$location = "uksouth"

Write-Host @"
⚠️  PAID RESOURCE — COST WARNING
Azure Firewall costs ~£0.90/hour
Deploy → Take screenshots → DELETE!
Estimated total cost: ~£1.80 (2 hours)
"@ -ForegroundColor Red

$confirm = Read-Host "Type YES to continue"
if ($confirm -ne "YES") {exit}

# Start timer
$startTime = Get-Date
Write-Host "`n⏱️  TIMER STARTED: $startTime" `
    -ForegroundColor Yellow

# Create Public IP
Write-Host "`nCreating Firewall Public IP..." `
    -ForegroundColor Cyan

$firewallPIP = New-AzPublicIpAddress `
    -Name "pip-lz-firewall" `
    -ResourceGroupName $rgName `
    -Location $location `
    -AllocationMethod Static `
    -Sku Standard

Write-Host "✅ Public IP: $($firewallPIP.IpAddress)" `
    -ForegroundColor Green

# Create Firewall Policy
$fwPolicy = New-AzFirewallPolicy `
    -Name "afwpol-lz-hub" `
    -ResourceGroupName $rgName `
    -Location $location `
    -ThreatIntelMode Alert

Write-Host "✅ Firewall Policy created!" `
    -ForegroundColor Green

# Get Hub VNet
$hubVnet = Get-AzVirtualNetwork `
    -Name "vnet-lz-hub-uksouth" `
    -ResourceGroupName $rgName

# Deploy Firewall
Write-Host "`nDeploying Azure Firewall..." `
    -ForegroundColor Yellow
Write-Host "⏳ This takes 10-15 minutes..." `
    -ForegroundColor Yellow

$firewall = New-AzFirewall `
    -Name "afw-lz-hub-uksouth" `
    -ResourceGroupName $rgName `
    -Location $location `
    -VirtualNetwork $hubVnet `
    -PublicIpAddress $firewallPIP `
    -FirewallPolicyId $fwPolicy.Id `
    -SkuTier Standard `
    -Tag @{
        Purpose = "LZ-Hub-Firewall"
        Owner   = "Uzma Sami"
    }

Write-Host "✅ Azure Firewall deployed!" `
    -ForegroundColor Green
Write-Host "Private IP: $($firewall.IpConfigurations[0].PrivateIPAddress)" `
    -ForegroundColor Cyan

Write-Host @"

🚨 TAKE SCREENSHOTS NOW:
1. Azure Portal → Azure Firewall → Overview
2. Show private IP and public IP
3. Show firewall policy
4. Show Hub VNet topology

Then run the DELETE script immediately!
"@ -ForegroundColor Red

# Save private IP for route tables
$firewall.IpConfigurations[0].PrivateIPAddress |
    Out-File ".\firewall-ip.txt"

