@description('The name of the administrator account to be created on the new VM.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Password or SSH key for the administrator account on the new VM.')
@secure()
param adminPasswordOrKey string

@description('Virtual machine name, will be either incrimented or appended to for the creation of related supporting resources.')
@maxLength(10)
param virtualMachineBaseName string = 'accvm'

@description('Size of the VM to create.')
@allowed([
  'Standard_DC2as_v5'
  'Standard_DC4as_v5'
  'Standard_DC8as_v5'
  'Standard_DC16as_v5'
  'Standard_DC32as_v5'
  'Standard_DC48as_v5'
  'Standard_DC64as_v5'
  'Standard_DC96as_v5'
  'Standard_DC2ads_v5'
  'Standard_DC4ads_v5'
  'Standard_DC8ads_v5'
  'Standard_DC16ads_v5'
  'Standard_DC32ads_v5'
  'Standard_DC48ads_v5'
  'Standard_DC64ads_v5'
  'Standard_DC96ads_v5'
])
param vmSize string = 'Standard_DC2as_v5'

@description('OS Image to be used to create the VM.')
@allowed([
  'Windows 11 Enterprise 22H2 Gen 2'
  'Windows 11 Enterprise 23H2 Gen 2'
  'Windows Server 2022 Gen 2'
  'Windows Server 2019 Gen 2'
  'Ubuntu 20.04 LTS Gen 2'
])
param osImageName string = 'Windows 11 Enterprise 23H2 Gen 2'

@description('Selecting DiskWithVMGuestState will enable Confidential OS Disk Encryption.')
@allowed([
  'VMGuestStateOnly'
  'DiskWithVMGuestState'
])
param securityType string = 'DiskWithVMGuestState'

@allowed([
  'yes'
  'no'
])
param createBastionHost string = 'yes'

@description('Object ID of the Confidential VM Orchestrator Service Principal')
@secure()
param objectIDConfidentialOrchestrator string

@description('Location for all resources, defaults to Resource Group location.')
param location string = resourceGroup().location

@description('Using the current deployment time to generate unique string for resource naming suchas the Azure Key Vault name.')
param timeUnique string = utcNow('hhmmss')

var virtualNetworkName = 'vnet-acc-lab'
var virtualNetworkAddressRange = '10.0.0.0/16'
var subnetName = 'sn00'
var subnetRange = '10.0.0.0/24'
var bastionHostName = 'bastion-acc-lab-01'
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetRange = '10.0.255.0/24'
var keyVaultName = 'AKV-${uniqueString(resourceGroup().id,timeUnique)}'
var diskEncryptSetName = 'DES-01'
var imageReference = imageList[osImageName]
var imageList = {
  'Windows 11 Enterprise 22H2 Gen 2': {
    publisher: 'microsoftwindowsdesktop'
    offer: 'windows-11'
    sku: 'win11-22h2-ent'
    version: 'latest'
  }
  'Windows 11 Enterprise 23H2 Gen 2': {
    publisher: 'microsoftwindowsdesktop'
    offer: 'windows-11'
    sku: 'win11-23h2-ent'
    version: 'latest'
  }
  'Windows Server 2022 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2022-datacenter-smalldisk-g2'
    version: 'latest'
  }
  'Windows Server 2019 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2019-datacenter-smalldisk-g2'
    version: 'latest'
  }
  'Ubuntu 20.04 LTS Gen 2': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-confidential-vm-focal'
    sku: '20_04-lts-cvm'
    version: 'latest'
  }
}
var isWindows = contains(osImageName, 'Windows')
var windowsConfiguration = {
  enableAutomaticUpdates: true
  provisionVMAgent: true
}
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        keyData: adminPasswordOrKey
        path: '/home/${adminUsername}/.ssh/authorized_keys'
      }
    ]
  }
}

resource virtualMachineBaseName_nic_01 'Microsoft.Network/networkInterfaces@2019-02-01' = {
  name: '${virtualMachineBaseName}-nic-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    Bastion
  ]
}

resource virtualMachineBaseName_01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${virtualMachineBaseName}-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${virtualMachineBaseName}osdisk-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          securityProfile: {
            diskEncryptionSet: {
              id: resourceId('Microsoft.Compute/diskEncryptionSets', diskEncryptSetName)
            }
            securityEncryptionType: securityType
          }
        }
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: virtualMachineBaseName_nic_01.id
        }
      ]
    }
    osProfile: {
      computerName: '${virtualMachineBaseName}-01'
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
      windowsConfiguration: (isWindows ? windowsConfiguration : null)
    }
    securityProfile: {
      securityType: 'ConfidentialVM'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

module DiskEncryption './DiskEncryption.bicep' = {
  name: 'DiskEncryption'
  params: {
    diskEncryptSetName: diskEncryptSetName
    keyVaultName: keyVaultName
    objectIDConfidentialOrchestrator: objectIDConfidentialOrchestrator
    location: location
  }
}

module VNet './VNet.bicep' = {
  name: 'VNet'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: subnetName
    subnetRange: subnetRange
    location: location
  }
  dependsOn: [
    DiskEncryption
  ]
}

module Bastion './Bastion.bicep' = if (createBastionHost == 'yes') {
  name: 'Bastion'
  scope: resourceGroup()
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: subnetName
    subnetRange: subnetRange
    bastionSubnetName: bastionSubnetName
    bastionSubnetRange: bastionSubnetRange
    bastionHostName: bastionHostName
    location: location
  }
  dependsOn: [
    VNet
  ]
}
