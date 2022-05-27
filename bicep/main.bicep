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

module keyVault 'modules/key_vault.bicep' = {
  name: 'key-vault'
  params: {
    location: location
    acrPassword: acr.listCredentials().passwords[0].value
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
