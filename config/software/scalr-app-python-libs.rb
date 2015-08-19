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

# Separately installed dep
dependency 'python-m2crypto'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  # Note that m2crypto is installed separately in python-m2crypto.
  # Then, install the rest
  command "#{install_dir}/embedded/bin/pip install" \
          ' --requirement ./requirements.txt', env: env

end
