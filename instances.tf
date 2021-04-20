resource "azurerm_public_ip" "inst-bastion-public-ip" {
  name = "${var.resource-prefix}-inst-bastion-public-ip"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  allocation_method = "Static"
  sku = "Standard"
  domain_name_label = "${var.resource-prefix}-inst-bastion"
}

resource "azurerm_network_interface" "inst-bastion-nic" {
  name = "${var.resource-prefix}-inst-bastion-nic"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  ip_configuration {
    name = "primary"
    subnet_id = azurerm_subnet.subnet-main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.inst-bastion-public-ip.id
  }
}

resource "azurerm_network_interface_application_security_group_association" "inst-bastion-nic-asg-bastion" {
  network_interface_id = azurerm_network_interface.inst-bastion-nic.id
  application_security_group_id =azurerm_application_security_group.asg-bastion.id
}

resource "azurerm_linux_virtual_machine" "inst-bastion" {
  depends_on = [azurerm_network_interface.inst-bastion-nic]

  name = "${var.resource-prefix}-inst-bastion"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  network_interface_ids = [azurerm_network_interface.inst-bastion-nic.id]
  admin_username = "admin"
  admin_password = "ThisIsABadOne123$%^"

  size = "Standard_B1s"
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

output "bastion-public-ip" {
  value = azurerm_public_ip.inst-bastion-public-ip.ip_address
}

resource "azurerm_network_interface" "inst-app-nic" {
  name = "${var.resource-prefix}-inst-app-nic"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  ip_configuration {
    name = "primary"
    subnet_id = azurerm_subnet.subnet-main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_security_group_association" "inst-app-nic-asg-app" {
  network_interface_id = azurerm_network_interface.inst-app-nic.id
  application_security_group_id = azurerm_application_security_group.asg-app.id
}

resource "azurerm_linux_virtual_machine" "inst-app" {
  depends_on = [azurerm_network_interface.inst-app-nic]

  name = "${var.resource-prefix}-inst-app"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  network_interface_ids = [azurerm_network_interface.inst-app-nic.id]

  size = "Standard_B1s"
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username = "admin"
  admin_ssh_key {
    username = azurerm_linux_virtual_machine.inst-app.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  custom_data = base64encode(templatefile("cloud-init-inst-app.yml.tmpl",
  {
    appconfig: {
      images: [
        "https://whyy.org/wp-content/uploads/2017/07/LOGO_First_overwhite-1-copy-1024x444.png",
        "https://i.pinimg.com/originals/36/ce/15/36ce15ea7932c29f65f480cbfd252329.jpg",
        "https://third-derivative.org/wp-content/uploads/2020/05/ThirdDerivative-Logo-TM-Light-Web.png"
      ],
      dbhost: azurerm_mssql_server.db-server.fully_qualified_domain_name,
      dbuser: azurerm_mssql_server.db-server.administrator_login,
      dbpass: azurerm_mssql_server.db-server.administrator_login_password,
      dbname: azurerm_mssql_database.db-database.name,
    }
  }))
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
