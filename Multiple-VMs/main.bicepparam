using './main.bicep'

param adminUsername = 'myAdminUsername'
param authenticationType = 'password'
param adminPasswordOrKey = 'mySuperSecretPassword'
param virtualMachineBaseName = 'myVMname'
param numberOfACCVMs = 2
param vmSize = 'Standard_DC2as_v5'
param osImageName = 'Windows 11 Enterprise 23H2 Gen 2'
param securityType = 'DiskWithVMGuestState'
param createBastionHost = 'yes'
param objectIDConfidentialOrchestrator = '00000000-0000-0000-0000-000000000000'
