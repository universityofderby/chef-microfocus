name 'microfocus'
maintainer 'University of Derby'
maintainer_email 'serverteam@derby.ac.uk'
license 'Apache 2.0'
description 'Provides microfocus_server_express resource'
chef_version '>= 14'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '3.0.0'
source_url 'https://github.com/universityofderby/chef-microfocus'
issues_url 'https://github.com/universityofderby/chef-microfocus/issues'

depends 'ark', '~> 2.0'
depends 'systemd', '~> 2.0'

supports 'centos'
supports 'redhat'
