############################################
## INFRASTRUCTURE                         ##
############################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-albums-${local.unique_suffix}"
  location = "West Europe"
}

locals {
  unique_suffix                      = "demo"
  mssql_server_administrator_login   = "admin"
  mssql_server_administrator_login_password = "Password123!"
  mssql_database_name                = "albumsdb"
  apipoi_base_image_tag              = "1.0"
  apitrips_base_image_tag             = "1.0"
  apiuserjava_base_image_tag          = "1.0"
  apiuserprofile_base_image_tag       = "1.0"
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = "sql-${local.unique_suffix}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = local.mssql_server_administrator_login
  administrator_login_password = local.mssql_server_administrator_login_password
}

resource "azurerm_mssql_database" "mssql_database" {
  name           = local.mssql_database_name
  server_id      = azurerm_mssql_server.mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "BasePrice"
  max_size_gb    = 2
  sku_name       = "Basic"
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

############################################
## DATABASE                               ##
############################################

resource "null_resource" "db_schema" {
  depends_on = [
    azurerm_mssql_database.mssql_database
  ]
  provisioner "local-exec" {
    command = "sqlcmd -U ${local.mssql_server_administrator_login} -P ${local.mssql_server_administrator_login_password} -S ${azurerm_mssql_server.mssql_server.fully_qualified_domain_name} -d ${local.mssql_database_name} -i ../../support/datainit/MYDrivingDB.sql -e"
  }
}

resource "null_resource" "db_datainit" {
  depends_on = [
    null_resource.db_schema
  ]
  provisioner "local-exec" {
    command = "cd ../../support/datainit; bash ./sql_data_init.sh -s ${azurerm_mssql_server.mssql_server.fully_qualified_domain_name} -u ${local.mssql_server_administrator_login} -p ${local.mssql_server_administrator_login_password} -d ${local.mssql_database_name}; cd ../../iac/terraform"
  }
}

############################################
## DOCKER                                 ##
############################################

resource "null_resource" "docker_simulator" {
  depends_on = [
    azurerm_container_registry.container_registry
  ]
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/simulator:latest --registry ${azurerm_container_registry.container_registry.login_server} --file ../../support/simulator/Dockerfile ../../support/simulator"
  }
}

resource "null_resource" "docker_tripviewer" {
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/tripviewer:latest --registry ${azurerm_container_registry.container_registry.login_server} --file ../../support/tripviewer/Dockerfile ../../support/tripviewer"
  }
}

resource "null_resource" "docker_api-poi" {
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/api-poi:${local.apipoi_base_image_tag} --registry ${azurerm_container_registry.container_registry.login_server} --build-arg build_version=${local.apipoi_base_image_tag} --file ../../apis/poi/web/Dockerfile ../../apis/poi/web"
  }
}

resource "null_resource" "docker_api-trips" {
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/api-trips:${local.apitrips_base_image_tag} --registry ${azurerm_container_registry.container_registry.login_server} --build-arg build_version=${local.apitrips_base_image_tag} --file ../../apis/trips/Dockerfile ../../apis/trips"
  }
}

resource "null_resource" "docker_api-user-java" {
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/api-user-java:${local.apiuserjava_base_image_tag} --registry ${azurerm_container_registry.container_registry.login_server} --build-arg build_version=${local.apiuserjava_base_image_tag} --file ../../apis/user-java/Dockerfile ../../apis/user-java"
  }
}

resource "null_resource" "docker_api-userprofile" {
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/api-userprofile:${local.apiuserprofile_base_image_tag} --registry ${azurerm_container_registry.container_registry.login_server} --build-arg build_version=${local.apiuserprofile_base_image_tag} --file ../../apis/userprofile/Dockerfile ../../apis/userprofile"
  }
}

# Container Registry
resource "azurerm_container_registry" "container_registry" {
  name                = "acr${local.unique_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# Azure Open AI resource
resource "azurerm_cognitive_account" "openai" {
  name                = "openai-${local.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
}
