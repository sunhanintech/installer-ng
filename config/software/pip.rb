#
# Copyright 2013-2014 Chef Software, Inc.
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

name "pip"
default_version "9.0.1"

dependency "setuptools"

#source url: "https://pypi.python.org/packages/source/p/pip/pip-#{version}.tar.gz"
source url: "https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-#{version}.tar.gz"

version '1.3' do
  source md5: '918559b784e2aca9559d498050bb86e7'
end

version '1.4' do
  source md5: 'ca790be30004937987767eac42cfa44a'
end

version '9.0.1' do
  source md5: '35f01da33009719497f01a4ba69d63c9'
end

relative_path "pip-#{version}"

license path: 'LICENSE.txt'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python setup.py install" \
          " --prefix=#{install_dir}/embedded", env: env
end
