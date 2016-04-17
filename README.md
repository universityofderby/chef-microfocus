microfocus chef cookbook
========================
The `microfocus` cookbook provides the `microfocus_server_express` resource.
This resource installs Micro Focus Server Express and License Manager, installs the specified license, then enables and starts the License Manager service.

Requirements
------------
- Chef 12.5 or higher
- Ruby 2.0 or higher (preferably from the Chef full-stack installer)
- Network accessible package repositories

Platform Support
----------------
The following platforms have been tested with Test Kitchen:
- centos-6
- centos-7

Usage
-----
Include `microfocus` as a dependency in your cookbook's `metadata.rb`.

```
depends 'microfocus', '~> 2.0'
```

Resources
---------
Define a `microfocus_server_express` resource in your recipe. E.g.

    microfocus_server_express '/opt/microfocus/cobol' do
      checksum 'ec833c62bdb63f48b7bf7b83b0100e0c82317f9653096d03ba2c9be27a0f6ebd'
      license_number 'license_number'
      serial_number 'serial_number'
      url 'http://artifacts.local.org/microfocus/server-express/sx51_wp11_redhat_x86_64_dev.tar'
    end

#### Properties
- `checksum` - SHA-256 checksum for the Server Express archive.
- `group` - group for the Server Express directory (default: 'root').
- `install_responses` - array of hashes (pattern to match and input value) to override the default install responses.
- `license_manager_path` - full path to install License Manager (default: '/opt/microfocus/mflmf').
- `license_number` - Server Express license number (required: true).
- `mflmcmd_responses` - array of hashes (pattern to match and input value) to override the default mflmcmd responses.
- `mode` - mode for the Server Express directory (default: 0755).
- `owner` - owner for the Server Express directory (default: 'root').
- `serial_number` - Server Express serial number (required: true).
- `server_express_path` - full path to install Server Express (name_property: true, recommended default: '/opt/microfocus/cobol').
- `url` - URL for the Server Express archive (required: true).

Recipes
-------
#### microfocus::default
The default recipe is blank.

Contributing
------------
1. Fork the repository on GitHub.
2. Create a named feature branch (like `add_component_x`).
3. Write your change.
4. Write tests for your change (this cookbook currently uses InSpec with Test Kitchen).
5. Run the tests, ensuring they all pass.
6. Submit a Pull Request using GitHub.

License and Authors
-------------------
Author: Richard Lock

Copyright 2016 University of Derby

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
