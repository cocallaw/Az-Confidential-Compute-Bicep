@description('Azure region for resources')
param location string = resourceGroup().location

@description('Name of Disk Encryption Set')
param diskEncryptSetName string = 'DES-01'

@description('Name of Azure Key Vault')
param keyVaultName string

@description('Object ID of the Confidential VM Orchestrator Service Principal')
@secure()
param objectIDConfidentialOrchestrator string

var keyVaultSku = 'premium'
var keyName = 'acckey01'
var keyVaultID = keyVault.id
var policyType = 'application/json; charset=utf-8'
var policyData = 'ewogICJhbnlPZiI6IFsKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRldXMuZXVzLmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWR3dXMud3VzLmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRuZXUubmV1LmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWR3ZXUud2V1LmF0dGVzdC5henVyZS5uZXQvIgogICAgfSwKICAgIHsKICAgICAgImFsbE9mIjogWwogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWF0dGVzdGF0aW9uLXR5cGUiLAogICAgICAgICAgImVxdWFscyI6ICJzZXZzbnB2bSIKICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICJjbGFpbSI6ICJ4LW1zLWNvbXBsaWFuY2Utc3RhdHVzIiwKICAgICAgICAgICJlcXVhbHMiOiAiYXp1cmUtY29tcGxpYW50LWN2bSIKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhdXRob3JpdHkiOiAiaHR0cHM6Ly9zaGFyZWRldXMyLmV1czIuYXR0ZXN0LmF6dXJlLm5ldC8iCiAgICB9CiAgXSwKICAidmVyc2lvbiI6ICIxLjAuMCIKfQ'

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: false
    enableSoftDelete: true
    enablePurgeProtection: true
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource keyVaultName_key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
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

resource diskEncryptSet 'Microsoft.Compute/diskEncryptionSets@2021-12-01' = {
  name: diskEncryptSetName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVaultID
      }
      keyUrl: reference(keyVaultName_key.id, '2019-09-01', 'Full').properties.keyUriWithVersion
    }
    encryptionType: 'ConfidentialVmEncryptedWithCustomerKey'
  }
}

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: reference(diskEncryptSet.id, '2019-07-01', 'Full').identity.PrincipalId
        permissions: {
          keys: [
            'get'
            'list'
            'wrapKey'
            'unwrapKey'
          ]
          secrets: []
          certificates: []
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: objectIDConfidentialOrchestrator
        permissions: {
          keys: [
            'get'
            'release'
          ]
        }
      }
    ]
  }
}
