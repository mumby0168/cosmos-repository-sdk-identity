param location string = resourceGroup().location
param servicePrincipalId string

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: toLower('cosmossdkidentitydemoacr')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource booksApiMid 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'books-api-mid'
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'cosmosidentitykv'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'acr_password'
  parent: kv
  properties: {
    value: 'value'
  }
}


module acaEnv 'modules/aca_env.bicep' = {
  name: 'env'
  params: {
    location: location
  }
}

module cosmos 'modules/cosmos.bicep' = {
  name: 'cosmos'
  params: {
    location: location
    appPrincipalId: booksApiMid.properties.principalId
  }
}

output acrLoginServer string = acr.properties.loginServer
