targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''


@description('Relative Path of ASA Jar')
param relativePath string

@secure()
@description('PSQL Server administrator password')
param psqlAdminPassword string

@secure()
@description('Application user password')
param psqlUserPassword string

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var asaInstanceName = '${abbrs.springApps}${resourceToken}'
var appName = 'simple-todo-web'
var keyVaultName = '${abbrs.keyVaultVaults}${resourceToken}'
var psqlServerName = '${abbrs.postgresServer}${resourceToken}'
var databaseName = 'Todo'
var psqlUserPasswordSecretName = 'DATABASE-PASSWORD'
var psqlAdminName = 'psqladmin'
var psqlUserName = 'psqluser'
var tags = {
  'azd-env-name': environmentName
  'spring-cloud-azure': 'true'
}


// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module keyVault 'modules/keyvault/keyvault.bicep' = {
  name: '${deployment().name}--kv'
  scope: resourceGroup(rg.name)
  params: {
  	keyVaultName: keyVaultName
  	location: location
	tags: tags
	principalId: principalId
  }
}

module postgresql 'modules/postgresql/flexibleserver.bicep' = {
  name: '${deployment().name}--pg'
  scope: resourceGroup(rg.name)
  params: {
  	serverName: psqlServerName
    location: location
  	tags: tags
  	keyVaultName: keyVault.outputs.name
  	psqlAdminName: psqlAdminName
  	psqlUserName: psqlUserName
    psqlAdminPassword: psqlAdminPassword
    psqlUserPassword: psqlUserPassword
    psqlUserPasswordSecretName: psqlUserPasswordSecretName
  }
}

module springApps 'modules/springapps/springapps.bicep' = {
  name: '${deployment().name}--asa'
  scope: resourceGroup(rg.name)
  params: {
    location: location
	appName: appName
	tags: union(tags, { 'azd-service-name': appName })
	asaInstanceName: asaInstanceName
	relativePath: relativePath
	keyVaultName: keyVault.outputs.name
	databaseUsername: psqlUserName
  }
}

module apiKeyVaultAccess './modules/keyvault/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: resourceGroup(rg.name)
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: springApps.outputs.identityPrincipalId
  }
}

output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
