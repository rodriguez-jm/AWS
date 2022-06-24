#Terraform plan name
$tfPlanName = "natInstanceVpc.tfplan"

#Terraform commands
terraform init
if ($? -ne $True) {
    return "Error. Check provider."
}
terraform fmt | Out-Null
terraform validate | Out-Null
if ($? -ne $True) {
    return "Error.Terraform configuration is invalid."
}
terraform plan -out $tfPlanName -detailed-exitcode
if (($LASTEXITCODE -eq 0) -or ( $LASTEXITCODE -eq 2)) {
    Write-Host "----------------------------------------------------"
    Write-Host "Plan $($tfPlanName) is valid! Deploying TF plan. . ."
    Write-Host "----------------------------------------------------"
    terraform apply "$tfPlanName"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "----------------------------------------------------"
        Write-Host "$($tfPlanName) successfully deployed!"
        Write-Host "----------------------------------------------------"
    }
    else {
        Write-Host "----------------------------------------------------"
        Write-Host "Error deploying $($tfPlanName). See error output."
        Write-Host "----------------------------------------------------"
    }
}