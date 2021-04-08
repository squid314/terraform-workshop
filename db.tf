resource "azurerm_mssql_server" "db-server" {
  name = "${var.resource-prefix}-db-server"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  administrator_login = "dbadmin"
  administrator_login_password = "ThisIsABadOne123$%^"
  version = "12.0"
  public_network_access_enabled = true
  // note: field is not documented but is present in the code
  minimum_tls_version = "1.2"
}

resource "azurerm_mssql_database" "db-database" {
  name = "${var.resource-prefix}-db-database"
  server_id = azurerm_mssql_server.db-server.id
  sku_name = "Basic"
}

resource "azurerm_sql_firewall_rule" "db-fwrule-myip" {
  name = "${var.resource-prefix}-db-fwrule-myip"
  resource_group_name = azurerm_resource_group.rg-main.name
  server_name = azurerm_mssql_server.db-server.name
  start_ip_address = var.my-ip-address
  end_ip_address   = var.my-ip-address
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
