# Azure Confidential Compute VM Deployment with Bicep Templates

This repository contains Bicep templates for deploying Azure Confidential Compute machines, configured with Confidential Disk Encryption and Customer Managed Key(CMK) encryption.

The templates will deploy the following resources in Azure:
- Azure Virtual Network 
- Azure Key Vault
- Azure Disk Encryption Set
- Azure Bastion (Optional)
- Azure Confidential Compute VM 

## Prerequisites

### Create Confidential VM Orchestrator Service Principal
This service principal is created using the [Azure Graph Powershell](https://learn.microsoft.com/powershell/microsoftgraph/overview?view=graph-powershell-1.0) commands below.

`Connect-Graph -Tenant "your tenant ID" Application.ReadWrite.All`

`New-MgServicePrincipal -AppId "bf7b6499-ff71-4aa2-97a4-f372087be7f0" -DisplayName "Confidential VM Orchestrator"`

### Get Confidential VM Orchestrator Object ID for Deployment
Once the service principal is created, the unique per tenant Object ID of the Service Principal will need to be identified and provided as part of the template deployment. 

The object ID can be retrieved using the Azure CLI command below, or by navigating to the Azure Portal and searching for Confidential VM Orchestrator in Entra for the tenant. 

`$cvmAgent = az ad sp show --id "bf7b6499-ff71-4aa2-97a4-f372087be7f0" | Out-String | ConvertFrom-Json`

`$cvmAgent.id`