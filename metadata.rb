name 'microfocus'
maintainer 'University of Derby'
maintainer_email 'serverteam@derby.ac.uk'
license 'Apache 2.0'
description 'Provides microfocus resource'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.1'
source_url 'https://github.com/universityofderby/chef-microfocus' if respond_to?(:source_url)
issues_url 'https://github.com/universityofderby/chef-microfocus/issues' if respond_to?(:issues_url)

depends 'ark', '~> 1.0'

supports 'centos'
supports 'redhat'
