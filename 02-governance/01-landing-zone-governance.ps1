# ============================================
# Script: 02-landing-zone-governance.ps1
# Purpose: Apply Landing Zone governance
#          policies following CAF and
#          Azure Security Benchmark
# ============================================

Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$scope          = "/subscriptions/$subscriptionId"
$location       = "uksouth"

Write-Host "Applying Landing Zone Governance..." `
    -ForegroundColor Cyan

# ---- Policy 1: Allowed Locations ----
Write-Host "`n[1/6] Allowed Locations..." `
    -ForegroundColor Yellow

$locationPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -eq "Allowed locations"
    } | Select-Object -First 1

if ($locationPolicy) {
    New-AzPolicyAssignment `
        -Name "lz-allowed-locations" `
        -DisplayName "LZ: UK South and West Only" `
        -PolicyDefinition $locationPolicy `
        -Scope $scope `
        -PolicyParameterObject @{
            listOfAllowedLocations = @{
                value = @("uksouth","ukwest","global")
            }
        } `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Location policy applied!" `
        -ForegroundColor Green
}

# ---- Policy 2: Require Tags ----
Write-Host "`n[2/6] Require Tags..." -ForegroundColor Yellow

$tagPolicies = @("Environment","Owner","CostCenter")

foreach ($tag in $tagPolicies) {
    $tagPolicy = Get-AzPolicyDefinition |
        Where-Object {
            $_.Properties.DisplayName -eq `
            "Require a tag on resources"
        } | Select-Object -First 1

    if ($tagPolicy) {
        New-AzPolicyAssignment `
            -Name "lz-require-tag-$($tag.ToLower())" `
            -DisplayName "LZ: Require $tag Tag" `
            -PolicyDefinition $tagPolicy `
            -Scope $scope `
            -PolicyParameterObject @{
                tagName = @{value = $tag}
            } `
            -ErrorAction SilentlyContinue | Out-Null

        Write-Host "✅ Tag required: $tag" `
            -ForegroundColor Green
    }
}

# ---- Policy 3: Security Benchmark ----
Write-Host "`n[3/6] Azure Security Benchmark..." `
    -ForegroundColor Yellow

$asbPolicy = Get-AzPolicySetDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "Azure Security Benchmark"
    } | Select-Object -First 1

if ($asbPolicy) {
    New-AzPolicyAssignment `
        -Name "lz-security-benchmark" `
        -DisplayName "LZ: Azure Security Benchmark v3" `
        -PolicySetDefinition $asbPolicy `
        -Scope $scope `
        -AssignIdentity `
        -Location $location `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Security Benchmark assigned!" `
        -ForegroundColor Green
}

# ---- Policy 4: No Public Storage ----
Write-Host "`n[4/6] No Public Storage..." `
    -ForegroundColor Yellow

$publicStoragePolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "public access*storage" -or
        $_.Properties.DisplayName -like `
        "Storage account public access"
    } | Select-Object -First 1

if ($publicStoragePolicy) {
    New-AzPolicyAssignment `
        -Name "lz-no-public-storage" `
        -DisplayName "LZ: Block Public Storage Access" `
        -PolicyDefinition $publicStoragePolicy `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ No public storage policy applied!" `
        -ForegroundColor Green
}

# ---- Policy 5: HTTPS Storage Only ----
Write-Host "`n[5/6] HTTPS Storage Only..." `
    -ForegroundColor Yellow

$httpsPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "Secure transfer*storage"
    } | Select-Object -First 1

if ($httpsPolicy) {
    New-AzPolicyAssignment `
        -Name "lz-https-storage" `
        -DisplayName "LZ: Require HTTPS Storage" `
        -PolicyDefinition $httpsPolicy `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ HTTPS storage policy applied!" `
        -ForegroundColor Green
}

# ---- Policy 6: Audit NSGs ----
Write-Host "`n[6/6] Audit NSG Coverage..." `
    -ForegroundColor Yellow

$nsgPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "network security group*subnet"
    } | Select-Object -First 1

if ($nsgPolicy) {
    New-AzPolicyAssignment `
        -Name "lz-audit-nsg" `
        -DisplayName "LZ: Audit NSG on Subnets" `
        -PolicyDefinition $nsgPolicy `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ NSG audit policy applied!" `
        -ForegroundColor Green
}

# Summary
Write-Host "`n=== LANDING ZONE POLICIES ===" `
    -ForegroundColor Cyan
Get-AzPolicyAssignment -Scope $scope |
    Where-Object {
        $_.Name -like "lz-*"
    } |
    Select-Object `
    @{N="Policy";E={$_.Properties.DisplayName}} |
    Format-Table -AutoSize -Wrap

