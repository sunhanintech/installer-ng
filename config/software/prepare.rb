#
# Copyright 2012-2014 Chef Software, Inc.
# Copyright 2015 Scalr, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# NOLICENSE (Nothing included in package)

name 'prepare'
description 'the steps required to prepare the build'
default_version '1.0.0'

skip_transitive_dependency_licensing true


build do
  block do
    %w{embedded embedded/lib embedded/bin bin}.each do |dir|
      command "mkdir #{install_dir}/#{dir}"
      command "chmod 755 #{install_dir}/#{dir}"
      command "touch -a #{install_dir}/#{dir}/.gitkeep"
    end
  end
end
