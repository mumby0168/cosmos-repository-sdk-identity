param location string =  resourceGroup().location

@secure()
param acrPassword string

resource kv 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'cosmosidentitydemokv'
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableSoftDelete: false
  }
}

resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: 'secret'
  parent: kv  
  properties: {
    value: 'mysupersecret'
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: 'acr_password'
  parent: kv
  properties: {
    value: acrPassword
  }
}
