// ============================================
// File: landing-zone.bicep
// Purpose: Infrastructure as Code for
//          Landing Zone deployment
//          Clients LOVE Bicep templates!
// Author: Uzma Sami | AZ-104 | AZ-500
// ============================================

targetScope = 'subscription'

// ============================================
// PARAMETERS
// ============================================

@description('Primary Azure region')
param location string = 'uksouth'

@description('Engineer name')
param engineerName string = 'Uzma Sami'

@description('Environment type')
@allowed(['Production','Development','Sandbox'])
param environment string = 'Production'

@description('Hub VNet address space')
param hubAddressPrefix string = '10.100.0.0/16'

@description('Log Analytics retention days')
@minValue(30)
@maxValue(730)
param logRetentionDays int = 90

// ============================================
// VARIABLES
// ============================================

var tags = {
  Engineer:    engineerName
  Environment: environment
  ManagedBy:   'Bicep-LandingZone'
  CreatedDate: utcNow('yyyy-MM-dd')
  Project:     'Azure-Landing-Zone'
}

var hubSubnets = [
  {
    name:          'AzureFirewallSubnet'
    addressPrefix: '10.100.1.0/26'
  }
  {
    name:          'AzureBastionSubnet'
    addressPrefix: '10.100.2.0/27'
  }
  {
    name:          'GatewaySubnet'
    addressPrefix: '10.100.3.0/27'
  }
  {
    name:          'snet-hub-management'
    addressPrefix: '10.100.4.0/24'
  }
]

// ============================================
// RESOURCE GROUPS
// ============================================

resource rgConnectivity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-connectivity'
  location: location
  tags:     tags
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-management'
  location: location
  tags:     tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-security'
  location: location
  tags:     tags
}

resource rgIdentity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-identity'
  location: location
  tags:     tags
}

// ============================================
// LOG ANALYTICS WORKSPACE
// ============================================

module logAnalytics 'modules/log-analytics.bicep' = {
  name:  'deploy-log-analytics'
  scope: rgManagement
  params: {
    workspaceName:  'law-lz-uzmasami-2026'
    location:       location
    retentionDays:  logRetentionDays
    tags:           tags
  }
}

// ============================================
// HUB VIRTUAL NETWORK
// ============================================

module hubVnet 'modules/hub-vnet.bicep' = {
  name:  'deploy-hub-vnet'
  scope: rgConnectivity
  params: {
    vnetName:      'vnet-lz-hub-uksouth'
    location:      location
    addressPrefix: hubAddressPrefix
    subnets:       hubSubnets
    tags:          tags
  }
}

// ============================================
// OUTPUTS
// ============================================

output hubVnetId string = hubVnet.outputs.vnetId
output workspaceId string = logAnalytics.outputs.workspaceId
output rgConnectivityName string = rgConnectivity.name
output rgManagementName string = rgManagement.name

