# 🏗️ Azure Landing Zone Accelerator
## Microsoft Cloud Adoption Framework (CAF) Aligned

## Overview
Production-ready Azure Landing Zone implementation
following Microsoft CAF best practices. Provides
a secure, governed, and monitored foundation for
enterprise workload deployment.

*Engineer:* Uzma Shabbir | AZ-104 | AZ-500
*Framework:* Microsoft CAF + Azure Security Benchmark
*IaC:* Bicep templates included 

## 🏛️ Landing Zone Layers

### Management Layer
- 8 CAF-aligned Management Groups
- Corp, Online, Platform, Sandbox hierarchy
- Subscription assignment to Corp LZ

### Governance Layer
- 6 Azure Policy assignments
- Azure Security Benchmark v3
- UK South/West location restriction
- Tag enforcement (Environment, Owner, CostCenter)

### Connectivity Layer
- Hub VNet: 10.100.0.0/16
- Identity Spoke: 10.101.0.0/16
- Management Spoke: 10.102.0.0/16
- Workload Spoke: 10.103.0.0/16
- Hub-Spoke peering fully configured
- Azure Firewall ready for deployment

### Security Layer
- Microsoft Sentinel enabled
- Defender for Cloud — 5 plans
- Log Analytics — 90 day retention
- Security contacts configured


# Deploy with Bicep
az deployment sub create \
  --location uksouth \
  --template-file 06-bicep-templates/landing-zone.bicep \
  --parameters environment=Production


## 💡 Key Differentiator
This Landing Zone includes *Bicep IaC templates*
making it deployable in any new subscription in
minutes.

## 👩‍💻 Author
*Uzma Sami*
Azure Security Engineer | AZ-104 | AZ-500
Available on Upwork for Azure Security projects
