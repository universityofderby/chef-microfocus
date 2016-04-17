microfocus chef cookbook
=====================
The `microfocus` cookbook provides the `microfocus_server_express` custom resource.
This resources installs Micro Focus Server Express and License Manager, installs the license using the specified details, then enables and starts the License Manager service.

Requirements
------------
- Chef 12.5 or higher
- Ruby 2.0 or higher (preferably from the Chef full-stack installer)
- Network accessible package repositories

Platform Support
----------------
The following platforms have been tested with Test Kitchen:
- CentOS
- Red Hat

Usage
-----
#### metadata.rb
Include `microfocus` as a dependency in your cookbook's `metadata.rb`.

```
depends 'microfocus', '= 2.0.0'
```

#### microfocus::default
The default recipe is blank because this is a resource cookbook.

Resources
---------
Define a `microfocus_server_express` resource in your recipe to install Micro Focus Server Express and License Manager.  E.g.

    microfocus_server_express '/opt/microfocus/cobol' do
      checksum 'sha-256_checksum'
      license_number 'license_number'
      serial_number 'serial_number'
      url 'http://artifacts.local.org/microfocus/server-express/sx51_wp11_redhat_x86_64_dev.tar'
    end

#### Properties
- `name` (required) - the resource name is the full path where Server Express will be installed.
- `checksum` (optional) - SHA-256 checksum for the Server Express archive.
- `license_number` (required) - Server Express license number.
- `serial_number` (required) - Server Express serial number.
- `url` (required) - URL for the Server Express archive.

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
