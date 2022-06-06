param location string = resourceGroup().location
param acrPullRoleId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: toLower('cosmossdkidentitydemoacr')
  location: location
  sku: {
    name: 'Basic'
  }
}

resource booksApiMid 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'books-api-mid'
  location: location
}

var booksApiAcrPull = {
  name: guid(booksApiMid.id, resourceGroup().id, acrPullRoleId)
  roleDefinitionId: acrPullRoleId
}

resource booksApiAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: booksApiAcrPull.name
  scope: acr
  properties: {
    principalId: booksApiMid.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', booksApiAcrPull.roleDefinitionId)
  }
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
