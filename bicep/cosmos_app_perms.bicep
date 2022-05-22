param roleDefinitionName string = 'Cosmos Application Role'
param accountName string
param accountId string
param appPrincipalId string

var roleDefinitionId = guid('sql-role-definition-', appPrincipalId, accountId)
var roleAssignmentId = guid(roleDefinitionId, appPrincipalId, accountId)

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-02-15-preview' = {
  name: '${accountName}/${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      accountId
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

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-02-15-preview' = {
  name: '${accountName}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: appPrincipalId
    scope: accountId
  }
}
