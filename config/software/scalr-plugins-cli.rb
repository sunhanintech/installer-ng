#
# Copyright 2017 Scalr, Inc.
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

# NOLICENSE (Includes itself in the Python license report)

name 'scalr-plugins-cli'
default_version 'v0.0.1'

dependency 'python'
dependency 'pip'
dependency 'mod-wsgi'


build do
  env = with_standard_compiler_flags(with_embedded_path)
  # Install scalr-server-plugins CLI
  command "#{install_dir}/embedded/bin/pip install" \
          " git+https://github.com/momohawari/scalr-server-plugins.git@release/#{version}", env: env
end
