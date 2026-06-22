# DEMO ONLY - intentionally insecure Terraform to trip IaC scanners
# (Trivy / Terrascan) in Microsoft Security DevOps.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo" {
  name     = "rg-insecure-demo"
  location = "South Central US"
}

# Storage account allowing public blob access + no HTTPS-only
resource "azurerm_storage_account" "insecure" {
  name                            = "insecuredemostorage"
  resource_group_name             = azurerm_resource_group.demo.name
  location                        = azurerm_resource_group.demo.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
  enable_https_traffic_only       = false
  min_tls_version                 = "TLS1_0"
}

# NSG that exposes SSH and RDP to the entire internet
resource "azurerm_network_security_group" "open" {
  name                = "nsg-wide-open"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "allow-ssh-from-anywhere"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp-from-anywhere"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}
