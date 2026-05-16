# ============================================
# Script: 07-generate-lz-report.ps1
# Purpose: Generate comprehensive Landing
#          Zone implementation report
# ============================================

Connect-AzAccount

$reportDate     = Get-Date -Format "yyyy-MM-dd HH:mm"
$subscriptionId = (Get-AzContext).Subscription.Id
$subName        = (Get-AzContext).Subscription.Name

# Gather data
$mgGroups    = Get-AzManagementGroup `
    -ErrorAction SilentlyContinue
$vnets       = Get-AzVirtualNetwork `
    -ErrorAction SilentlyContinue
$policies    = Get-AzPolicyAssignment `
    -Scope "/subscriptions/$subscriptionId" `
    -ErrorAction SilentlyContinue |
    Where-Object {$_.Name -like "lz-*"}
$workspaces  = Get-AzOperationalInsightsWorkspace `
    -ErrorAction SilentlyContinue
$defPlans    = Get-AzSecurityPricing `
    -ErrorAction SilentlyContinue |
    Where-Object {$_.PricingTier -eq "Standard"}

# Vnet rows
$vnetRows = ""
foreach ($vnet in $vnets) {
    $vnetRows += @"
        <tr>
            <td>$($vnet.Name)</td>
            <td>$($vnet.AddressSpace.AddressPrefixes -join ', ')</td>
            <td>$($vnet.Subnets.Count) subnets</td>
            <td><span class='badge-green'>✅ Active</span></td>
        </tr>
"@
}

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Landing Zone Report</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial;
               background: #0d1117; color: #e6edf3;
               padding: 40px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: linear-gradient(
                      135deg, #1f6feb, #388bfd);
                  padding: 30px; border-radius: 16px;
                  margin-bottom: 25px; }
        .header h1 { font-size: 26px; }
        .header p { opacity: 0.85; font-size: 13px;
                    margin-top: 5px; }
        .metric-grid { display: grid;
                       grid-template-columns: repeat(4,1fr);
                       gap: 16px; margin-bottom: 25px; }
        .metric-box { background: #161b22;
                      border: 1px solid #1f6feb;
                      border-radius: 10px; padding: 20px;
                      text-align: center; }
        .metric-number { font-size: 40px; font-weight: 700;
                         color: #388bfd; }
        .metric-label { font-size: 12px; color: #8b949e;
                        margin-top: 6px; }
        h2 { color: #388bfd; border-left: 4px solid #1f6feb;
             padding-left: 12px; margin: 25px 0 15px; }
        .layer-grid { display: grid;
                      grid-template-columns: repeat(2,1fr);
                      gap: 16px; margin-bottom: 25px; }
        .layer-card { background: #161b22;
                      border: 1px solid #30363d;
                      border-radius: 10px; padding: 20px; }
        .layer-card h3 { color: #388bfd; font-size: 15px;
                         margin-bottom: 12px; }
        .layer-item { padding: 6px 0; font-size: 12px;
                      border-bottom: 1px solid #21262d;
                      color: #e6edf3; }
        table { width: 100%; border-collapse: collapse;
                background: #161b22; border-radius: 10px;
                overflow: hidden; margin-bottom: 20px; }
        th { background: #1f6feb; color: white;
             padding: 12px; font-size: 12px;
             text-align: left; }
        td { padding: 10px 12px; font-size: 12px;
             border-bottom: 1px solid #21262d; }
        .badge-green { background: #1a4731; color: #3fb950;
                       padding: 3px 10px; border-radius: 20px;
                       font-size: 11px; }
        footer { margin-top: 40px; text-align: center;
                 color: #8b949e; font-size: 11px;
                 padding-top: 20px;
                 border-top: 1px solid #21262d; }
    </style>
</head>
<body>
<div class='container'>
    <div class='header'>
        <h1>🏗️ Azure Landing Zone Accelerator Report</h1>
        <p>Engineer: Uzma Sami | AZ-104 | AZ-500</p>
        <p>Framework: Microsoft Cloud Adoption Framework (CAF)</p>
        <p>Subscription: $subName | Date: $reportDate</p>
    </div>

    <div class='metric-grid'>
        <div class='metric-box'>
            <div class='metric-number'>$($mgGroups.Count)</div>
            <div class='metric-label'>Management Groups</div>
        </div>
        <div class='metric-box'>
            <div class='metric-number'>$($vnets.Count)</div>
            <div class='metric-label'>Virtual Networks</div>
        </div>
        <div class='metric-box'>
            <div class='metric-number'>$($policies.Count)</div>
            <div class='metric-label'>LZ Policies</div>
        </div>
        <div class='metric-box'>
            <div class='metric-number'>$($defPlans.Count)</div>
            <div class='metric-label'>Defender Plans</div>
        </div>
    </div>

    <h2>🏛️ Landing Zone Layers</h2>
    <div class='layer-grid'>
        <div class='layer-card'>
            <h3>📋 Management Layer</h3>
            <div class='layer-item'>✅ CAF MG Hierarchy (8 groups)</div>
            <div class='layer-item'>✅ Tenant Root configured</div>
            <div class='layer-item'>✅ Platform MG created</div>
            <div class='layer-item'>✅ Landing Zones MG created</div>
            <div class='layer-item'>✅ Corp + Online Workloads</div>
            <div class='layer-item'>✅ Sandbox environment</div>
        </div>
        <div class='layer-card'>
            <h3>⚖️ Governance Layer</h3>
            <div class='layer-item'>✅ Azure Security Benchmark</div>
            <div class='layer-item'>✅ Allowed Locations (UK)</div>
            <div class='layer-item'>✅ Require Tags (3 tags)</div>
            <div class='layer-item'>✅ No Public Storage</div>
            <div class='layer-item'>✅ HTTPS Storage Only</div>
            <div class='layer-item'>✅ NSG Audit</div>
        </div>
        <div class='layer-card'>
            <h3>🌐 Connectivity Layer</h3>
            <div class='layer-item'>✅ Hub VNet: 10.100.0.0/16</div>
            <div class='layer-item'>✅ Identity Spoke: 10.101.0.0/16</div>
            <div class='layer-item'>✅ Management Spoke: 10.102.0.0/16</div>
            <div class='layer-item'>✅ Workload Spoke: 10.103.0.0/16</div>
            <div class='layer-item'>✅ Hub-Spoke Peerings</div>
            <div class='layer-item'>✅ Azure Firewall (documented)</div>
        </div>
        <div class='layer-card'>
            <h3>🛡️ Security Layer</h3>
            <div class='layer-item'>✅ Log Analytics (90 days)</div>
            <div class='layer-item'>✅ Microsoft Sentinel</div>
            <div class='layer-item'>✅ Defender for Cloud</div>
            <div class='layer-item'>✅ Security Contacts</div>
            <div class='layer-item'>✅ NSG Baseline</div>
            <div class='layer-item'>✅ Bicep IaC Template</div>
        </div>
    </div>

    <h2>🌐 Virtual Networks</h2>
    <table>
        <tr>
            <th>VNet Name</th>
            <th>Address Space</th>
            <th>Subnets</th>
            <th>Status</th>
        </tr>
        $vnetRows
    </table>

    <h2>✅ CAF Compliance Checklist</h2>
    <table>
        <tr><th>CAF Requirement</th><th>Status</th><th>Details</th></tr>
        <tr>
            <td>Management Group Hierarchy</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>CAF naming convention followed</td>
        </tr>
        <tr>
            <td>Policy-Driven Governance</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>6 LZ policies assigned</td>
        </tr>
        <tr>
            <td>Hub & Spoke Network</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>Hub + 3 spoke VNets peered</td>
        </tr>
        <tr>
            <td>Centralized Logging</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>Log Analytics 90-day retention</td>
        </tr>
        <tr>
            <td>Security Monitoring</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>Sentinel + Defender enabled</td>
        </tr>
        <tr>
            <td>Infrastructure as Code</td>
            <td><span class='badge-green'>✅ Done</span></td>
            <td>Bicep template created</td>
        </tr>
        <tr>
            <td>Azure Firewall</td>
            <td><span class='badge-green'>✅ Documented</span></td>
            <td>Template ready — P1 licensed deploy</td>
        </tr>
    </table>

    <footer>
        Azure Landing Zone Accelerator |
        Uzma Sami | AZ-104 | AZ-500 |
        $reportDate | CAF Aligned
    </footer>
</div>
</body>
</html>
"@

$reportPath = ".\lz-report-$(Get-Date -Format 'yyyyMMdd').html"
$html | Out-File $reportPath -Encoding UTF8
Start-Process $reportPath

Write-Host "✅ Landing Zone report generated!" `
    -ForegroundColor Green

