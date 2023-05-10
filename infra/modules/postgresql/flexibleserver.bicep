param serverName string
param location string = resourceGroup().location
param tags object = {}
param keyVaultName string
param psqlAdminName string
param psqlUserName string
@secure()
param psqlAdminPassword string
@secure()
param psqlUserPassword string
param psqlAdminPasswordSecretName string
param psqlUserPasswordSecretName string
param databaseName string = 'todo'
param version string = '12'

// Latest official version 2022-12-01 does not have Bicep types available
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  location: location
  tags: tags
  name: serverName
  sku: {
  	name: 'Standard_D4s_v3'
  	tier: 'GeneralPurpose'
  }
  properties: {
    version: version
    administratorLogin: psqlAdminName
    administratorLoginPassword: psqlAdminPassword
    storage: {
      storageSizeGB: 32
    }
    availabilityZone: '1'
    highAvailability: {
      mode: 'Disabled'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
      tenantId: subscription().tenantId
    }
  }

  resource database 'databases' = {
    name: databaseName
    properties: {
      charset: 'utf8'
      collation: 'en_US.utf8'
    }
  }

  resource firewall_all 'firewallRules' = {
    name: 'allow-all-IPs'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }

}

resource psqlDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'psql-deployment-script'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.40.0'
    retentionInterval: 'PT1H' // Retain the script resource for 1 hour after it ends running
    timeout: 'PT5M' // Five minutes
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'PSQLADMINNAME'
        value: psqlAdminName
      }
      {
        name: 'PSQLADMINPASSWORD'
        secureValue: psqlAdminPassword
      }
      {
        name: 'PSQLUSERNAME'
        value: psqlUserName
      }
      {
        name: 'PSQLUSERPASSWORD'
        secureValue: psqlUserPassword
      }
      {
        name: 'DBNAME'
        value: databaseName
      }
      {
        name: 'DBSERVER'
        value: serverName
      }
    ]

    scriptContent: '''
su -
apt-get install sudo -y
usermod -aG sudo $USER
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.li st.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql

cat << EOF > create_user.sql
CREATE ROLE "$PSQLUSERNAME" WITH LOGIN PASSWORD '$PSQLUSERPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DBNAME TO "$PSQLUSERNAME";
EOF

psql "host=$DBSERVER.postgres.database.azure.com user=$PSQLADMINNAME dbname=$DBNAME port=5432 password=$PSQLADMINPASSWORD sslmode=require" < create_user.sql
    '''
  }
}

resource psqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: psqlAdminPasswordSecretName
  properties: {
    value: psqlAdminPassword
  }
}

resource psqlUserPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: psqlUserPasswordSecretName
  properties: {
    value: psqlUserPassword
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

output POSTGRES_DOMAIN_NAME string = postgresServer.properties.fullyQualifiedDomainName
