# Azurerm provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_virtual_network" "example" {
  name                = "vnet-shared-hub-westeurope-001"
  resource_group_name = "rg-shared-westeurope-01"
}

data "azurerm_subnet" "example" {
  name                 = "snet-private-ep"
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_virtual_network.example.resource_group_name
}

module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.2.0"

  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  location              = "westeurope"

  # SQL Server and Database details
  # The valid service objective name for the database include S0, S1, S2, S3, P1, P2, P4, P6, P11 
  sqlserver_name               = "te-sqldbserver01"
  database_name                = "demomssqldb"
  sql_database_edition         = "Standard"
  sqldb_service_objective_name = "S1"

  # SQL server extended auditing policy defaults to `true`. 
  # To turn off set enable_sql_server_extended_auditing_policy to `false`  
  # DB extended auditing policy defaults to `false`. 
  # to tun on set the variable `enable_database_extended_auditing_policy` to `true` 
  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  # schedule scan notifications to the subscription administrators
  # Manage Vulnerability Assessment set `enable_vulnerability_assessment` to `true`
  enable_vulnerability_assessment = false
  email_addresses_for_alerts      = ["user@example.com", "firstname.lastname@example.com"]

  # enabling the Private Endpoints for Sql servers
  enable_private_endpoint = true
  existing_vnet_id        = data.azurerm_virtual_network.example.id
  existing_subnet_id      = data.azurerm_subnet.example.id
  # existing_private_dns_zone = "demo.example.com"

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure SQL database including audit logs
  # log analytic workspace name required
  enable_log_monitoring        = true
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  enable_firewall_rules = true
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "123.201.36.94"
      end_ip_address   = "123.201.36.94"
    }
  ]

  # Adding additional TAG's to your Azure resources
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
