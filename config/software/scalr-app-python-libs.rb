#
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

# NOLICENSE (Nothing gets included in the package)

name 'scalr-app-python-libs'

source :path => '__SCALR_REQUIREMENTS_PATH__'

# Python
dependency 'pip'

# Python package dependencies
dependency 'libffi'
dependency 'openssl'
dependency 'cairo'
dependency 'pango'
dependency 'glib'
dependency 'libxml2'
dependency 'rrdtool'
dependency 'libyaml'

license :project_license
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Clean build dir
  command "rm -rf #{build_dir}/pybuild/*"

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  # Then, install the rest
  command "#{install_dir}/embedded/bin/pip install" \
          " --build #{build_dir}/pybuild" \
          ' --requirement ./scalrpy.txt', env: env

  command "rm -rf #{build_dir}/pybuild/*"

  command "#{install_dir}/embedded/bin/pip3 install" \
          " --build #{build_dir}/pybuild" \
          ' --requirement ./server-all.txt', env: env

  # Make sure that the permissions are correct on the cacert
  command "chmod 644 #{install_dir}/embedded/lib/python2.7/site-packages/httplib2/cacerts.txt"

end
