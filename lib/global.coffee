# Veldspar EVE Online API Client
# global.coffee - Namespace definitions & configuration
# Copyright © Denis Luchkin-Zhou

# Global scope
root = exports ? this

# Application namespace definition
root = root.Veldspar ?= { }

# Veldspar configuration namespace
config = root.Config ?= { }

# EVE API server protocol and hostname
config.apiHost = 'https://api.eveonline.com'
config.apiHost = 'http://localhost:8888'
#config.apiHost = 'https://api.testeveonline.com'

# Indicates whether to log detailed request and response parameters
config.verbose = no

# Indicates whether to hide unpublished entities from clients
config.hideUnpublished = yes