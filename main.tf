provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "example" {
    name = "tf-learn-rg"
    location = "eastus"
}

resource "azurerm_virtual_network" "example" {
    name = "example-netowrk"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
    name = "internal"
    resource_group_name = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes = ["10.0.2.0/24"]

}

resource "azurerm_public_ip" "example" {
    name = "example-pip"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method = "Static"
}

resource "azurerm_network_interface" "example" {
    name = "example-nic"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name


    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.example.id
    }
}

resource "azurerm_network_security_group" "example" {
    name = "example-nsg"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    security_rule {
        name = "SSH"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "HTTP"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "example" {
    subnet_id = azurerm_subnet.example.id
    network_security_group_id = azurerm_network_security_group.example.id
  
}

resource "azurerm_linux_virtual_machine" "example" {
    admin_username = "adminuser"
    location = azurerm_resource_group.example.location
    name = "my_first_vm"
    computer_name = "myfirstvm"
    resource_group_name = azurerm_resource_group.example.name
    network_interface_ids = [azurerm_network_interface.example.id]
    size = "Standard_B1s"
                                                        

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    
    admin_ssh_key {
        username = "adminuser"
        public_key = file("~/.ssh/id_ed25519.pub") # Ensure you have a valid SSH key pair
    }

    user_data = filebase64("${path.module}/scripts/install_nginx.sh") # Ensure this script exists in the specified path}")

}

output "vm_public_ip" {
    value = azurerm_public_ip.example.ip_address
    description = "The public IP address of the virtual machine"
  
}