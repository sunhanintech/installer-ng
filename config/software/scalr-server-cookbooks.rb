#
## Copyright:: Copyright (c) 2012 Opscode, Inc.
## Copyright:: Copyright (c) 2015 Scalr, Inc.
## License:: Apache License, Version 2.0
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
#

name 'scalr-server-cookbooks'

dependency 'berkshelf'
dependency 'rsync'

# Can I use 'name' here?
source :path => File.expand_path('files/scalr-server-cookbooks', Omnibus::Config.project_root)

berks_pkg = 'pkg.tar.gz'

build do
  # Add the extra files and our cookbook
  command "mkdir -p #{install_dir}/embedded/cookbooks"
  command "#{install_dir}/embedded/bin/rsync --delete -a ./ #{install_dir}/embedded/cookbooks/"

  # Add the package and all the dependencies (NOTE: unfortunately this copies the scalr-server cookbook again)
  command "mkdir -p #{install_dir}/embedded"
  # TODO - We're in scalr-server-cookbooks, not in scalr-server, so the Berksfile is not there.
  command "#{install_dir}/embedded/bin/berks package #{install_dir}/#{berks_pkg}"
  command "cd #{install_dir}/embedded && rm -rf ./cookbooks && tar -xzvf #{berks_pkg} && rm #{berks_pkg}"
end
