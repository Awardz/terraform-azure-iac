provider "azurerm" {
    features {}
    subscription_id = "5e0eb190-ddfb-4a48-b690-90c7e3560b99"
}

resource "azurerm_resource_group" "example" {
    name = "tf-learn-rg"
    location = "eastus"
}