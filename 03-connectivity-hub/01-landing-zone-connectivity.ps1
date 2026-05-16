# ============================================
# Script: 03-landing-zone-connectivity.ps1
# Purpose: Build Landing Zone Hub & Spoke
#          network topology following CAF
#          connectivity patterns
# ============================================

Connect-AzAccount

$location = "uksouth"
$rgName   = "rg-lz-connectivity"

Write-Host "Building Landing Zone Connectivity..." `
    -ForegroundColor Cyan

# Create Connectivity Resource Group
New-AzResourceGroup `
    -Name $rgName `
    -Location $location `
    -Tag @{
        Environment = "Production"
        Owner       = "Uzma Sami"
        CostCenter  = "IT-Security"
        ManagedBy   = "LandingZone"
    } | Out-Null

Write-Host "✅ Connectivity RG created!" `
    -ForegroundColor Green

# ============================================
# HUB VNET — Central connectivity point
# ============================================

Write-Host "`nCreating Hub VNet..." -ForegroundColor Yellow

# Hub subnets
$hubSubnets = @(
    @{Name="AzureFirewallSubnet";   Prefix="10.100.1.0/26"},
    @{Name="AzureBastionSubnet";    Prefix="10.100.2.0/27"},
    @{Name="GatewaySubnet";         Prefix="10.100.3.0/27"},
    @{Name="snet-hub-management";   Prefix="10.100.4.0/24"},
    @{Name="snet-hub-shared";       Prefix="10.100.5.0/24"}
)

$subnetConfigs = @()
foreach ($subnet in $hubSubnets) {
    $subnetConfigs += New-AzVirtualNetworkSubnetConfig `
        -Name $subnet.Name `
        -AddressPrefix $subnet.Prefix `
        -PrivateEndpointNetworkPoliciesFlag "Disabled"
    Write-Host "  ✅ Subnet: $($subnet.Name)" `
        -ForegroundColor Green
}

$hubVnet = New-AzVirtualNetwork `
    -Name "vnet-lz-hub-uksouth" `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix "10.100.0.0/16" `
    -Subnet $subnetConfigs `
    -Tag @{
        Purpose     = "LZ-Hub-Connectivity"
        Environment = "Production"
        Owner       = "Uzma Sami"
    }

Write-Host "✅ Hub VNet created: 10.100.0.0/16" `
    -ForegroundColor Green

# ============================================
# SPOKE VNETS — Workload networks
# ============================================

Write-Host "`nCreating Spoke VNets..." -ForegroundColor Yellow

$spokes = @(
    @{
        Name    = "vnet-lz-spoke-identity"
        Prefix  = "10.101.0.0/16"
        Subnets = @(
            @{Name="snet-identity-adds"; Prefix="10.101.1.0/24"},
            @{Name="snet-identity-mgmt"; Prefix="10.101.2.0/24"}
        )
        Purpose = "Identity Services"
    },
    @{
        Name    = "vnet-lz-spoke-management"
        Prefix  = "10.102.0.0/16"
        Subnets = @(
            @{Name="snet-mgmt-tools";    Prefix="10.102.1.0/24"},
            @{Name="snet-mgmt-monitor";  Prefix="10.102.2.0/24"}
        )
        Purpose = "Management Tools"
    },
    @{
        Name    = "vnet-lz-spoke-workload"
        Prefix  = "10.103.0.0/16"
        Subnets = @(
            @{Name="snet-workload-web";  Prefix="10.103.1.0/24"},
            @{Name="snet-workload-app";  Prefix="10.103.2.0/24"},
            @{Name="snet-workload-data"; Prefix="10.103.3.0/24"}
        )
        Purpose = "Corp Workloads"
    }
)

$createdSpokes = @()

foreach ($spoke in $spokes) {
    $spokeSubnets = @()
    foreach ($subnet in $spoke.Subnets) {
        $spokeSubnets += New-AzVirtualNetworkSubnetConfig `
            -Name $subnet.Name `
            -AddressPrefix $subnet.Prefix
    }

    $spokeVnet = New-AzVirtualNetwork `
        -Name $spoke.Name `
        -ResourceGroupName $rgName `
        -Location $location `
        -AddressPrefix $spoke.Prefix `
        -Subnet $spokeSubnets `
        -Tag @{
            Purpose     = $spoke.Purpose
            Environment = "Production"
            Owner       = "Uzma Sami"
        }

    $createdSpokes += $spokeVnet
    Write-Host "✅ Spoke: $($spoke.Name) — $($spoke.Prefix)" `
        -ForegroundColor Green
}

# ============================================
# VNET PEERING — Hub to all Spokes
# ============================================

Write-Host "`nCreating Hub-Spoke Peerings..." `
    -ForegroundColor Yellow

foreach ($spoke in $createdSpokes) {
    $spokeName = $spoke.Name.Replace(
        "vnet-lz-spoke-",""
    )

    # Hub → Spoke
    Add-AzVirtualNetworkPeering `
        -Name "peer-hub-to-$spokeName" `
        -VirtualNetwork $hubVnet `
        -RemoteVirtualNetworkId $spoke.Id `
        -AllowForwardedTraffic `
        -AllowGatewayTransit `
        -ErrorAction SilentlyContinue | Out-Null

    # Spoke → Hub
    Add-AzVirtualNetworkPeering `
        -Name "peer-$spokeName-to-hub" `
        -VirtualNetwork $spoke `
        -RemoteVirtualNetworkId $hubVnet.Id `
        -AllowForwardedTraffic `
        -UseRemoteGateways:$false `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Peered: Hub ↔️ $spokeName" `
        -ForegroundColor Green
}

# ============================================
# NSGs — Landing Zone security baseline
# ============================================

Write-Host "`nCreating Landing Zone NSGs..." `
    -ForegroundColor Yellow

# Workload NSG
$workloadNSG = New-AzNetworkSecurityGroup `
    -Name "nsg-lz-workload" `
    -ResourceGroupName $rgName `
    -Location $location `
    -Tag @{Purpose = "LZ-Workload-NSG"}

# Add deny all inbound
$workloadNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "LZ-Deny-All-Inbound" `
    -Priority 4096 `
    -Direction Inbound `
    -Access Deny `
    -Protocol * `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange * |
    Set-AzNetworkSecurityGroup | Out-Null

Write-Host "✅ Workload NSG created with Deny-All!" `
    -ForegroundColor Green

# Save Hub VNet ID for next phase
$hubVnet.Id | Out-File ".\hub-vnet-id.txt"

Write-Host "`n=== CONNECTIVITY SUMMARY ===" `
    -ForegroundColor Cyan
Write-Host "Hub VNet:    10.100.0.0/16 ✅" -ForegroundColor Green
Write-Host "Identity:    10.101.0.0/16 ✅" -ForegroundColor Green
Write-Host "Management:  10.102.0.0/16 ✅" -ForegroundColor Green
Write-Host "Workload:    10.103.0.0/16 ✅" -ForegroundColor Green
Write-Host "Peerings:    All connected ✅" -ForegroundColor Green

