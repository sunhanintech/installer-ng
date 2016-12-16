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

name "setuptools"
default_version "32.0.0"

dependency "python"

#source url: "https://pypi.python.org/packages/source/s/setuptools/setuptools-#{version}.tar.gz"
source url: "https://pypi.python.org/packages/dc/37/f01d823fd312ba8ea6c3aea906d2d6ac9e9e8bf9e7853e34f296e94b0d0d/setuptools-#{version}.tar.gz"

version '0.7.7' do
  source md5: '0d7bc0e1a34b70a97e706ef74aa7f37f'
  license url: "https://bitbucket.org/pypa/setuptools/src/#{version}/setup.py?at=default#cl-138"
end

version '32.0.0' do
  source md5: 'e5f513a5b53e843b361d663feec4f5fa'
  license path: "LICENSE"
end

relative_path "setuptools-#{version}"


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python setup.py install" \
          " --prefix=#{install_dir}/embedded", env: env
end
