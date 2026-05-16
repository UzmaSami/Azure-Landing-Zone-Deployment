# 1. Create the modules directory
New-Item -ItemType Directory -Force -Path "./modules" | Out-Null

# 2. Create the Log Analytics Module
@"
param workspaceName string
param location string
param retentionDays int
param tags object

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: retentionDays
  }
}
output workspaceId string = law.id
"@ | Out-File -FilePath "./modules/log-analytics.bicep" -Encoding utf8

# 3. Create the VNet Module
@"
param vnetName string
param location string
param addressPrefix string
param subnets array
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ addressPrefix ] }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: { addressPrefix: subnet.addressPrefix }
    }]
  }
}
output vnetId string = vnet.id
"@ | Out-File -FilePath "./modules/hub-vnet.bicep" -Encoding utf8

# 4. Create the Main Landing Zone File
@"
targetScope = 'subscription'

param location string = 'uksouth'
param engineerName string = 'Uzma Sami'
@allowed(['Production','Development','Sandbox'])
param environment string = 'Production'
param hubAddressPrefix string = '10.100.0.0/16'
@minValue(30)
@maxValue(730)
param logRetentionDays int = 90
param runDate string = utcNow('yyyy-MM-dd')

var tags = {
  Engineer:    engineerName
  Environment: environment
  ManagedBy:   'Bicep-LandingZone'
  CreatedDate: runDate
  Project:     'Azure-Landing-Zone'
}

var hubSubnets = [
  { name: 'AzureFirewallSubnet', addressPrefix: '10.100.1.0/26' }
  { name: 'AzureBastionSubnet', addressPrefix: '10.100.2.0/27' }
  { name: 'GatewaySubnet', addressPrefix: '10.100.3.0/27' }
  { name: 'snet-hub-management', addressPrefix: '10.100.4.0/24' }
]

resource rgConnectivity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-lz-connectivity'
  location: location
  tags: tags
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-lz-management'
  location: location
  tags: tags
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'deploy-log-analytics'
  scope: rgManagement
  params: {
    workspaceName: 'law-lz-uzmasami-2026'
    location: location
    retentionDays: logRetentionDays
    tags: tags
  }
}

module hubVnet 'modules/hub-vnet.bicep' = {
  name: 'deploy-hub-vnet'
  scope: rgConnectivity
  params: {
    vnetName: 'vnet-lz-hub-uksouth'
    location: location
    addressPrefix: hubAddressPrefix
    subnets: hubSubnets
    tags: tags
  }
}

output hubVnetId string = hubVnet.outputs.vnetId
output workspaceId string = logAnalytics.outputs.workspaceId
"@ | Out-File -FilePath "./landing-zone.bicep" -Encoding utf8

# 5. Execute the deployment
Write-Host "`n🚀 Starting Bicep Deployment..." -ForegroundColor Cyan
New-AzDeployment -Name "UzmaLandingZone" -Location "uksouth" -TemplateFile "./landing-zone.bicep"
