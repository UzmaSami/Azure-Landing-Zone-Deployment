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

@description('Log Analytics retention days')
param logRetentionDays int = 90

// FIX: utcNow must be a parameter default
param runDate string = utcNow('yyyy-MM-dd')

// ============================================
// VARIABLES
// ============================================

var tags = {
  Engineer:    engineerName
  Environment: environment
  ManagedBy:   'Bicep-LandingZone'
  CreatedDate: runDate
  Project:     'Azure-Landing-Zone'
}

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

// ============================================
// RESOURCES (Self-Contained)
// ============================================

// Deploy Log Analytics Workspace directly
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name:     'law-lz-uzmasami-2026'
  location: location
  scope:    rgManagement
  tags:     tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
  }
}

// Deploy Hub VNet directly
resource hubVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name:     'vnet-lz-hub-uksouth'
  location: location
  scope:    rgConnectivity
  tags:     tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-hub-management'
        properties: {
          addressPrefix: '10.100.4.0/24'
        }
      }
    ]
  }
}

// ============================================
// OUTPUTS
// ============================================

output hubVnetId string = hubVnet.id
output workspaceId string = logAnalytics.id
