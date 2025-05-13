@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of Disk Encryption Set')
param diskEncryptSetName string = 'DES-01'

@description('Name of Disk Encryption Set for Data Disk')
param diskEncryptSetNameData string = 'DES-Data-01'

@description('Name of Azure Key Vault')
param keyVaultName string

@description('Object ID of the Confidential VM Orchestrator Service Principal')
@secure()
param objectIDConfidentialOrchestrator string

@description('Indicates whether the key should be created.')
param createKeyResources bool = true

var keyVaultSku = 'premium'
var keyName = 'acckey01'
var keyNameData = 'acckeydata01'
var cvmoRBACRoleName = 'Key Vault Crypto Service Release User'
var desRBACRoleName = 'Key Vault Crypto User'
var desRBACRoleNameData = 'Key Vault Crypto User'
var roleIdMapping = {
  'Key Vault Crypto Service Release User': '08bbd89e-9f13-488c-ac41-acfcb10c90ab'
  'Key Vault Crypto User': '12338af0-0e69-4776-bea7-57ae8d297424'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
}
var policyType = 'application/json; charset=utf-8'
var policyData = 'ewogICJhbnlPZiI6IFsKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRldXMuZXVzLmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWR3dXMud3VzLmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRuZXUubmV1LmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWR3ZXUud2V1LmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRldXMyLmV1czIuYXR0ZXN0LmF6dXJlLm5ldC8iCiAgICB9CiAgXSwKICAidmVyc2lvbiI6ICIxLjAuMCIKfQ'

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = if (createKeyResources) {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
    enabledForDeployment: false
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    publicNetworkAccess: 'Disabled'
    tenantId: subscription().tenantId
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource accKey01 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = if (createKeyResources) {
  parent: keyVault
  name: keyName
  properties: {
    attributes: {
      enabled: true
      exportable: true
    }
    keyOps: [
      'wrapKey'
      'unwrapKey'
    ]
    keySize: 3072
    kty: 'RSA-HSM'
    release_policy: {
      contentType: policyType
      data: policyData
    }
  }
}

resource dataKey01 'Microsoft.KeyVault/vaults/keys@2023-02-01' = if (createKeyResources) {
  name: keyNameData
  parent: keyVault
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'encrypt'
      'decrypt'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

resource diskEncryptSetACC 'Microsoft.Compute/diskEncryptionSets@2024-03-02' = if (createKeyResources) {
  name: diskEncryptSetName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVault.id
      }
      keyUrl: accKey01.properties.keyUriWithVersion
    }
    encryptionType: 'ConfidentialVmEncryptedWithCustomerKey'
  }
}

resource diskEncryptSetData 'Microsoft.Compute/diskEncryptionSets@2024-03-02' = if (createKeyResources) {
  name: diskEncryptSetNameData
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVault.id
      }
      keyUrl: dataKey01.properties.keyUriWithVersion
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

resource roleIdMapping_desRBACRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (createKeyResources) {
  scope: keyVault
  name: guid(roleIdMapping[desRBACRoleName], keyVault.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdMapping[desRBACRoleName])
    principalId: diskEncryptSetACC.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource roleIdMapping_cvmoRBACRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (createKeyResources) {
  scope: keyVault
  name: guid(roleIdMapping[cvmoRBACRoleName], objectIDConfidentialOrchestrator, keyVault.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdMapping[cvmoRBACRoleName])
    principalId: objectIDConfidentialOrchestrator
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    diskEncryptSetACC
  ]
}

resource roleAssignmentDiskEncryptSetData 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (createKeyResources) {
  name: guid(diskEncryptSetData.id, keyVault.id, 'KeyVaultCryptoUser')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdMapping[desRBACRoleNameData])
    principalId: diskEncryptSetData.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

