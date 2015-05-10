default['microfocus']['server express']['url'] = node['common_artifact_repo'] + '/microfocus/server-express/5.1wp4/server-express-5.1wp4-redhat-installer.tar'
default['microfocus']['server express']['home'] = '/opt/microfocus/cobol'
default['microfocus']['license manager']['home'] = '/opt/microfocus/mflmf'

default['microfocus']['packages'] = ['make', 'binutils', 'gcc', 'libaio', 'libaio-devel', 'elfutils-libelf-devel', 'sysstat', 'elfutils-libelf', 'glibc-common', 'glibc-devel', 'gcc-c++', 'compat-libstdc++-33', 'expat', 'glibc', 'libgcc', 'libstdc++', 'libgcc']
default['gcc']['version'] = '4.4.7'
