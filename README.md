# 🏗️ Azure Landing Zone Accelerator
## Microsoft Cloud Adoption Framework (CAF) Aligned
# Foundation with Infrastructure as Code

Uzma Shabbir — Cloud Security Engineer
AZ-104 | AZ-500 | London, UK
github.com/UzmaSami

---

## Overview

This project documents the design and
implementation of a Microsoft Cloud
Adoption Framework aligned Azure Landing
Zone — establishing the enterprise
foundation that makes every subsequent
workload deployment governed, secure,
and consistent by default.

A Landing Zone is the architectural
answer to a specific problem: how do
you ensure that the hundredth workload
deployed in an Azure environment meets
the same security, governance, and
operational standards as the first?
Without a Landing Zone the answer is
manual review and manual remediation —
both of which fail to scale. With a
Landing Zone the answer is automation
— the platform enforces standards at
deployment time before any non-compliant
resource can be created.

This project also introduces Bicep
infrastructure as code — defining the
Landing Zone components declaratively
so that the entire foundation can be
deployed consistently to any new
Azure environment in a single pipeline
execution rather than hours of manual
portal configuration.

---

## The Problem This Solves

Every organisation that adopts Azure
at scale eventually confronts the same
problem. The environment that was
carefully designed and governed in its
early stages becomes increasingly
difficult to govern as it grows.
Subscriptions multiply. Teams deploy
workloads without following the
established patterns. Resources appear
in unexpected regions. Tags are missing.
Network configurations deviate from
the baseline. Security controls are
inconsistently applied.

This is not a failure of intent. It
is a failure of architecture. When
the only mechanism for enforcing
standards is human review the
enforcement is only as consistent as
the humans performing it. People make
mistakes. Reviews are skipped under
time pressure. Exceptions are granted
and forgotten. The gap between the
intended architecture and the deployed
reality grows continuously.

A Landing Zone replaces human
enforcement with platform enforcement.
The Management Group hierarchy defines
where workloads are placed. Azure
Policy defines what is allowed within
each placement. The Hub network defines
how workloads connect. The governance
framework defines how access is
controlled. Everything that would
previously require human review to
ensure happens automatically through
the platform.

---

## Architecture


LANDING ZONE STRUCTURE
════════════════════════════════════════════════

MANAGEMENT LAYER
────────────────────────────────────────────────
Tenant Root Group
- └── mg-uzmasami-root (Root)
    - │   Policy: Azure Security Benchmark
    - │   Policy: Allowed Locations (UK)
    - │   Policy: Require Tags
    - │
    - ├── mg-uzmasami-platform (Platform)
    - │   │   Policy: Stricter security baseline
    - │   │
    - │   ├── mg-uzmasami-connectivity
    - │   │       Hub VNet subscription
    - │   │       Network infrastructure
    - │   │
    - │   └── mg-uzmasami-management
    - │           Log Analytics subscription
    - │           Security tooling
    - │
    - ├── mg-uzmasami-landingzones (Workloads)
    - │   │   Policy: Workload security baseline
    - │   │
    - │   ├── mg-uzmasami-corp
    - │   │       Internal workloads
    - │   │       Current subscription placed here
    - │   │
    - │   └── mg-uzmasami-online
    - │           Internet-facing workloads
    - │           Stricter egress controls
    - │
    - └── mg-uzmasami-sandbox (Development)
            No production policies
            Flexible for experimentation

CONNECTIVITY LAYER
────────────────────────────────────────────────
Hub VNet (10.100.0.0/16) — UK South
- ├── AzureFirewallSubnet (10.100.1.0/26)
- │   └── Azure Firewall Standard
- │       + Firewall Policy
- │       + Threat Intelligence
- │
- ├── AzureBastionSubnet (10.100.2.0/27)
- │   └── Azure Bastion Standard
- │       Secure RDP/SSH — no public IPs
- │
- ├── GatewaySubnet (10.100.3.0/27)
- │   └── VPN Gateway (when required)
- │
- └── snet-hub-management (10.100.4.0/24)
    Management and operations tools

Spoke VNets (peered to Hub)
- ├── vnet-lz-spoke-identity (10.101.0.0/16)
- │   Identity services workloads
- │
- ├── vnet-lz-spoke-management (10.102.0.0/16)
- │   Management and monitoring workloads
- │
- └── vnet-lz-spoke-workload (10.103.0.0/16)
    Application workloads
    - ├── snet-workload-web  (10.103.1.0/24)
    - ├── snet-workload-app  (10.103.2.0/24)
    - └── snet-workload-data (10.103.3.0/24)

SECURITY LAYER
────────────────────────────────────────────────
Microsoft Defender for Cloud
- ├── All plans enabled (Standard tier)
- └── Connected to central Log Analytics

Microsoft Sentinel
- └── Enabled on central workspace
    - └── Inherits all existing analytics rules

Azure Policy (Landing Zone policies)
- ├── Allowed locations: UK South + West
- ├── Require tags: Environment, Owner, CostCenter
- ├── No public storage
- ├── HTTPS storage only
- ├── Audit NSG on subnets
- └── Azure Security Benchmark v3

IDENTITY LAYER
────────────────────────────────────────────────
Microsoft Entra ID
- ├── Landing Zone RBAC assignments
- ├── Custom roles from Project 8
- └── PIM-governed privileged access

INFRASTRUCTURE AS CODE
────────────────────────────────────────────────
Bicep Templates
- ├── landing-zone.bicep (main)
- ├── modules/
- │   ├── management-groups.bicep
- │   ├── hub-vnet.bicep
- │   ├── spoke-vnets.bicep
- │   ├── firewall.bicep
- │   └── log-analytics.bicep
- └── parameters/
    - ├── production.json
    - └── sandbox.json


---

## What is a Landing Zone

The term Landing Zone is borrowed from
the military concept of an area prepared
and secured before troops arrive. In
Azure the analogy is precise — a Landing
Zone is an environment prepared and
secured before workloads arrive.

Microsoft defines a Landing Zone as
a subscription that has been made
ready to host workloads through the
application of governance, security,
networking, and identity controls
that meet the organisation's
requirements. The Landing Zone is
not the workload. It is the prepared
environment that receives the workload.

The distinction matters because it
changes the conversation from "how do
we secure this workload" to "how do
we create an environment in which
any workload placed here is
automatically secure." The first
question requires per-workload security
engineering. The second question
requires platform security engineering.
Platform engineering scales. Per-
workload engineering does not.

---

## Cloud Adoption Framework Alignment

The Microsoft Cloud Adoption Framework
is a collection of documentation,
best practices, and tooling that guides
organisations through cloud adoption.
The Landing Zone section of CAF defines
the design areas that a Landing Zone
must address — identity, network
topology, resource organisation,
management, governance, and security.

This Landing Zone implementation was
designed against the CAF design areas
explicitly.

The resource organisation design area
is addressed by the Management Group
hierarchy — the eight-group structure
separates platform from workload from
sandbox in the pattern CAF recommends.

The network topology design area is
addressed by the Hub-and-Spoke
architecture — the pattern CAF
recommends for enterprise connectivity
with centralised security services
in the hub.

The governance design area is addressed
by the Azure Policy assignments at
Management Group scope — enforcing
standards across all subscriptions
in each Management Group without
requiring per-subscription assignment.

The security design area is addressed
by Defender for Cloud and Sentinel
connected to the central Log Analytics
workspace — the CAF recommendation
for centralised security operations.

The identity design area is addressed
by the RBAC structure using custom
roles defined in Project 8 and PIM
for privileged access.

Aligning to CAF matters beyond the
technical implementation. CAF
alignment means the Landing Zone
uses the same terminology, the same
patterns, and the same reference
architecture that Microsoft, its
partners, and enterprise Azure
customers use. An engineer who
understands this Landing Zone
can work with any CAF-aligned
environment because the concepts
transfer.

---

## Infrastructure as Code — Bicep

The Landing Zone components are
defined in Bicep — Microsoft's
domain-specific language for
declarative Azure resource deployment.
Every resource in the Landing Zone
can be deployed by running the
Bicep template rather than executing
a sequence of portal clicks or
PowerShell commands.

The case for infrastructure as code
in a Landing Zone context is
particularly strong. A Landing Zone
that exists only as deployed resources
can drift from its intended state.
Changes made through the portal or
ad-hoc scripts modify the deployed
state without modifying the definition.
Over time the deployed state and the
intended state diverge. The definition
of what the Landing Zone should be
exists only in someone's memory or
in documentation that may be out
of date.

Infrastructure as code makes the
intended state explicit and version-
controlled. Every change to the
Landing Zone definition is a commit
in the Git repository. The history
of changes is visible. The reason
for each change can be documented
in the commit message. The current
state of the definition is always
the most recently committed version.
Drift between the deployed state
and the defined state can be detected
by comparing the deployed resources
against the template.

bicep
// landing-zone.bicep
// Main deployment template

targetScope = 'subscription'

// ════════════════════════════════
// PARAMETERS
// ════════════════════════════════

@description('Primary Azure region')
param location string = 'uksouth'

@description('Environment type')
@allowed(['Production', 'Development', 'Sandbox'])
param environment string = 'Production'

@description('Hub VNet address space')
param hubAddressPrefix string = '10.100.0.0/16'

@description('Log Analytics retention days')
@minValue(30)
@maxValue(730)
param logRetentionDays int = 90

@description('Engineer name for tagging')
param engineerName string = 'Uzma Shabbir'

// ════════════════════════════════
// VARIABLES
// ════════════════════════════════

var tags = {
  Engineer:    engineerName
  Environment: environment
  ManagedBy:   'Bicep-LandingZone'
  Project:     'Azure-Landing-Zone'
  CreatedDate: utcNow('yyyy-MM-dd')
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

// ════════════════════════════════
// RESOURCE GROUPS
// ════════════════════════════════

resource rgConnectivity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-connectivity-uks'
  location: location
  tags:     tags
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-management-uks'
  location: location
  tags:     tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     'rg-lz-security-uks'
  location: location
  tags:     tags
}

// ════════════════════════════════
// MODULES
// ════════════════════════════════

module logAnalytics 'modules/log-analytics.bicep' = {
  name:  'deploy-log-analytics'
  scope: rgManagement
  params: {
    workspaceName: 'law-lz-uzmasami-2026'
    location:      location
    retentionDays: logRetentionDays
    tags:          tags
  }
}

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

module spokeVnets 'modules/spoke-vnets.bicep' = {
  name:  'deploy-spoke-vnets'
  scope: rgConnectivity
  params: {
    hubVnetId: hubVnet.outputs.vnetId
    location:  location
    tags:      tags
  }
}

// ════════════════════════════════
// OUTPUTS
// ════════════════════════════════

output hubVnetId      string = hubVnet.outputs.vnetId
output workspaceId    string = logAnalytics.outputs.workspaceId
output rgConnectivity string = rgConnectivity.name
output rgManagement   string = rgManagement.name


The modular structure of the Bicep
template reflects good infrastructure
as code practice. The main template
orchestrates the deployment. Each
module is responsible for a single
component — Log Analytics, Hub VNet,
Spoke VNets. Modules are independently
testable and reusable. The hub-vnet
module can be used in any Landing
Zone deployment without modification.

---

## Azure Bastion — Secure Remote Access

Azure Bastion provides browser-based
RDP and SSH access to virtual machines
without requiring public IP addresses
on those VMs. It deploys into the
AzureBastionSubnet of the Hub VNet
and provides access to VMs in all
peered spoke VNets through the
hub-spoke connectivity.

The traditional approach to remote
access — public IP on the VM, RDP
or SSH port open in the NSG — is
one of the most consistently exploited
configurations in cloud environments.
Exposed RDP is the entry point for
a large proportion of ransomware
incidents. Internet-scanning services
find exposed RDP within minutes of
a public IP being assigned.

Bastion eliminates this attack surface
completely. No VM requires a public IP
for management access. No port 3389
or 22 needs to be open to the internet
in any NSG. Management access is
provided through the Azure portal
over HTTPS — a protocol that is
already permitted and monitored.

The cost implication of Bastion is
material — approximately £0.17 per
hour for the Standard SKU. In this
portfolio Bastion was deployed,
configured, and tested before being
removed to manage lab costs. The
deployment demonstrates the capability.
The Bicep template enables redeployment
in minutes when needed.

---

## Landing Zone Policy Framework

The policy assignments in the Landing
Zone complement the policies applied
in Project 8 but serve a distinct
purpose. Project 8 policies govern
existing resources. Landing Zone
policies govern the platform that
new resources are created on.

The Allowed Locations policy prevents
resources from being created outside
UK South and UK West. This is a
data sovereignty control — ensuring
that workload data does not leave
UK geography without an explicit
decision to change the policy. In
a regulated environment this policy
provides the technical control that
compliance frameworks require for
data residency.

The Require Tags policy ensures
that every resource created in the
Landing Zone is tagged with the
minimum required metadata — Environment,
Owner, and CostCenter. Tags applied
at creation rather than retrospectively
are the only reliable tagging model.
A policy that denies resource creation
without required tags eliminates the
remediation debt that accumulates
when tagging is left to individual
deployments.

The No Public Storage policy prevents
any storage account in the Landing
Zone from being created with public
blob access enabled. This is the
Landing Zone expression of the
same control implemented manually
in Project 4 — at the Landing Zone
level the control is automatic and
cannot be bypassed by a deployment
that omits the configuration.

---

## How This Connects the Portfolio

The Landing Zone is the architectural
culmination of the governance and
security work done in all preceding
projects. It makes that work the
default rather than the exception.

In a Landing Zone the Hub-and-Spoke
network from Project 3 is the
connectivity baseline that all new
workloads connect to rather than
a specific implementation for a
specific workload. The governance
policies from Project 8 apply
automatically to all subscriptions
in the Landing Zone rather than being
manually assigned. The Defender for
Cloud configuration from Project 1
is inherited by all resources deployed
in the Landing Zone rather than being
enabled resource by resource.

A new team that deploys a workload
into a subscription in the Corp
Landing Zone automatically inherits:
network connectivity through the Hub,
security monitoring through Defender
for Cloud and Sentinel, governance
through the policy assignments, and
access control through the RBAC
structure. They do not need to
configure any of this. The platform
provides it. This is the value that
a Landing Zone delivers at scale.

---

## Challenges Encountered

**Management Group hierarchy and
subscription assignment**

Assigning a subscription to a Management
Group requires the account performing
the assignment to have the Management
Group Contributor or Owner role at
the destination Management Group and
either Owner or User Access Administrator
at the subscription. This permission
requirement is more complex than
standard Azure RBAC and is not
immediately obvious from the portal
experience. Understanding the exact
permissions required for each step
of the Management Group setup prevented
several permission-related failures
during initial deployment.

*Bicep subscription-scoped deployment*

Bicep templates that deploy resource
groups — as this one does — must
be deployed at subscription scope
rather than resource group scope.
The targetScope declaration at the
top of the template must be set to
subscription. Deploying a subscription-
scoped template using az deployment
group create rather than
az deployment sub create produces
an error that references the wrong
scope — not the template syntax —
making it confusing to diagnose
without understanding the scope
model.

*Firewall and Bastion cost management*

Both Azure Firewall and Azure Bastion
incur hourly charges that accumulate
significantly over a lab deployment
period. The operational discipline
of deploying, testing, capturing
evidence, and immediately removing
these resources was essential for
managing lab costs within the Pay
As You Go subscription budget.
Each deployment was scripted to
include a reminder prompt before
proceeding and a delete script that
was prepared before the deployment
was initiated — ensuring that cost
management was part of the deployment
plan rather than an afterthought
after the fact.

---

## Lessons Learned

The most important lesson from this
project was the difference between
a governed environment and an
environment with governance tooling
installed. Governance tooling —
Management Groups, Azure Policy,
RBAC — can be deployed without
producing a governed environment if
the policies are in audit mode, the
roles are assigned too broadly, and
the Management Group hierarchy does
not match the organisational structure
it is meant to govern.

A governed environment requires that
the tooling is configured correctly,
that the policy effects enforce rather
than audit, that the roles provide
least privilege rather than convenience,
and that the hierarchy reflects the
actual organisational boundaries.
The tools are necessary but not
sufficient. The configuration of
the tools determines whether governance
is real or cosmetic.

The second lesson concerned infrastructure
as code adoption. Writing a Bicep
template for an environment that was
first built manually surfaces every
implicit decision that was made during
the manual build. Parameters that were
obvious during manual deployment —
what address space to use, what
retention period to set, what SKU
to choose — must be made explicit
in the template. The discipline of
making these decisions explicit in
code produces better documentation
of the architectural decisions than
any manually written document could.

---

## What I Would Do Differently at Scale

At enterprise scale the Landing Zone
would be deployed using the Azure
Landing Zones Terraform module or
the ALZ Bicep reference implementation
— Microsoft-maintained implementations
of the full CAF Landing Zone that
include hundreds of policy definitions,
role definitions, and architecture
components that would take months to
implement from scratch. Building from
these reference implementations and
customising them for organisational
requirements is the correct approach
at enterprise scale.

The Bicep deployment pipeline would
be implemented in Azure DevOps or
GitHub Actions — enabling Landing
Zone changes to go through code
review, automated validation using
the Bicep linter and What-If
deployment analysis, and approval
gates before being applied to
production. A Landing Zone change
that breaks network connectivity
for all workloads is a high-impact
incident. Pipeline gates and What-If
previews prevent the most common
failure modes.

Subscription vending — an automated
process for creating new subscriptions,
placing them in the correct Management
Group, and applying the baseline
Landing Zone configuration — would
replace the manual subscription
setup process. In organisations that
create many subscriptions the manual
process is a bottleneck. Automating
it ensures consistency and removes
the dependency on a specific
individual's knowledge.

---

## Repository Structure


azure-landing-zone/
- │
- ├── bicep/
- │   ├── landing-zone.bicep
- │   ├── modules/
- │   │   ├── log-analytics.bicep
- │   │   ├── hub-vnet.bicep
- │   │   ├── spoke-vnets.bicep
- │   │   ├── azure-firewall.bicep
- │   │   ├── azure-bastion.bicep
- │   │   └── policy-assignments.bicep
- │   └── parameters/
- │       ├── production.json
- │       └── sandbox.json
- │
- ├── powershell/
- │   ├── 01-create-management-groups.ps1
- │   ├── 02-assign-lz-policies.ps1
- │   ├── 03-deploy-connectivity.ps1
- │   ├── 04-deploy-security.ps1
- │   ├── 05-deploy-firewall.ps1
- │   ├── 06-deploy-bastion.ps1
- │   └── DELETE-paid-resources.ps1
- │
- ├── docs/
- │   ├── architecture-diagram.png
- │   ├── caf-alignment.md
- │   ├── address-space-design.md
- │   └── policy-register.md
- │
- ├── screenshots/
- └── README.md


---

## Deployment

bash
# Deploy entire Landing Zone with Bicep

# Login to Azure
az login

# Set target subscription
az account set --subscription "YOUR-SUB-ID"

# What-If preview (validate before deploying)
az deployment sub what-if \
  --location uksouth \
  --template-file bicep/landing-zone.bicep \
  --parameters bicep/parameters/production.json

# Deploy
az deployment sub create \
  --location uksouth \
  --template-file bicep/landing-zone.bicep \
  --parameters bicep/parameters/production.json \
  --name "lz-deployment-$(date +%Y%m%d)"


---

## Series Navigation

| # | Project | Link |
|---|---------|------|
| ← P9 | ADSAE Security Tool | [View](../ad-security-automation-engine) |
| *P10* | *Azure Landing Zone* | You are here |
| → P11 | AI Threat Detection | [View](../ai-security-intelligence-platform) |
| 🏛️ | Enterprise Capstone | [View](../enterprise-hybrid-security-architecture) |

---

Uzma Shabbir
Azure Security Engineer | AZ-104 | AZ-500
[GitHub](https://github.com/UzmaSami) •
[LinkedIn](https://linkedin.com/in/uzma-shabbir-034361128)
