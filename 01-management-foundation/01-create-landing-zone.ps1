# ============================================
# Script: 01-create-landing-zone-foundation.ps1
# Purpose: Create Landing Zone management
#          group hierarchy following
#          Microsoft CAF (Cloud Adoption
#          Framework) best practices
# Author: Uzma Sami
# Date: May 2026
# ============================================

Connect-AzAccount

Write-Host @"
╔════════════════════════════════════════════╗
║   Azure Landing Zone Accelerator           ║
║   Author: Uzma Sami | AZ-104 | AZ-500     ║
║   Following Microsoft CAF Best Practices   ║
╚════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$tenantId       = (Get-AzContext).Tenant.Id
$subscriptionId = (Get-AzContext).Subscription.Id
$location       = "uksouth"

Write-Host "Tenant:       $tenantId" -ForegroundColor White
Write-Host "Subscription: $subscriptionId" -ForegroundColor White

# ============================================
# MANAGEMENT GROUP HIERARCHY
# Following Microsoft CAF naming convention
# ============================================

Write-Host "`nCreating CAF Management Group Hierarchy..." `
    -ForegroundColor Cyan

$managementGroups = @(
    @{
        Id          = "mg-uzmasami-root"
        DisplayName = "UzmaSami — Tenant Root"
        ParentId    = $null
    },
    @{
        Id          = "mg-uzmasami-platform"
        DisplayName = "UzmaSami — Platform"
        ParentId    = "mg-uzmasami-root"
    },
    @{
        Id          = "mg-uzmasami-landingzones"
        DisplayName = "UzmaSami — Landing Zones"
        ParentId    = "mg-uzmasami-root"
    },
    @{
        Id          = "mg-uzmasami-connectivity"
        DisplayName = "UzmaSami — Connectivity"
        ParentId    = "mg-uzmasami-platform"
    },
    @{
        Id          = "mg-uzmasami-management"
        DisplayName = "UzmaSami — Management"
        ParentId    = "mg-uzmasami-platform"
    },
    @{
        Id          = "mg-uzmasami-corp"
        DisplayName = "UzmaSami — Corp Workloads"
        ParentId    = "mg-uzmasami-landingzones"
    },
    @{
        Id          = "mg-uzmasami-online"
        DisplayName = "UzmaSami — Online Workloads"
        ParentId    = "mg-uzmasami-landingzones"
    },
    @{
        Id          = "mg-uzmasami-sandbox"
        DisplayName = "UzmaSami — Sandbox"
        ParentId    = "mg-uzmasami-root"
    }
)

foreach ($mg in $managementGroups) {
    try {
        if ($mg.ParentId) {
            New-AzManagementGroup `
                -GroupId $mg.Id `
                -DisplayName $mg.DisplayName `
                -ParentId "/providers/Microsoft.Management/managementGroups/$($mg.ParentId)" `
                -ErrorAction SilentlyContinue | Out-Null
        } else {
            New-AzManagementGroup `
                -GroupId $mg.Id `
                -DisplayName $mg.DisplayName `
                -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Host "✅ $($mg.DisplayName)" `
            -ForegroundColor Green
    } catch {
        Write-Host "⚠️  $($mg.DisplayName) — $($_.Exception.Message)" `
            -ForegroundColor Yellow
    }
}

# Assign subscription to Corp Landing Zone
Write-Host "`nAssigning subscription to Corp Landing Zone..." `
    -ForegroundColor Yellow

New-AzManagementGroupSubscription `
    -GroupId "mg-uzmasami-corp" `
    -SubscriptionId $subscriptionId `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Subscription assigned to Corp LZ!" `
    -ForegroundColor Green

# Verify hierarchy
Write-Host "`n=== CAF MANAGEMENT GROUP HIERARCHY ===" `
    -ForegroundColor Cyan

Get-AzManagementGroup |
    Select-Object DisplayName, Name |
    Format-Table -AutoSize

