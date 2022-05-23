param baseName string = resourceGroup().name
param location string = resourceGroup().location
param dbId string = 'managed-id-db'
param pk string = '/partitionKey'
param roleDefinitionName string = 'Cosmos Application Role'
param appPrincipalId string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: '${baseName}-cosmos'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  name: '${cosmosAccount.name}/${dbId}'
  properties: {
    resource: {
      id: dbId
    }
  }
}

resource booksContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  parent: db
  name: 'books'
  properties: {
    resource: {
      id: 'books'
      partitionKey: {
        paths: [
          pk
        ]
        kind: 'Hash'
      }
    }
  }
}


// Permissions for MID

var roleDefinitionId = guid('sql-role-definition-', appPrincipalId, cosmosAccount.id)
var roleAssignmentId = guid(roleDefinitionId, appPrincipalId, cosmosAccount.id)

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  name: '${cosmosAccount.name}/${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      cosmosAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: '${cosmosAccount.name}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: appPrincipalId
    scope: cosmosAccount.id
  }
}


output databaseId string = dbId
output cosmosDns string = cosmosAccount.properties.documentEndpoint
