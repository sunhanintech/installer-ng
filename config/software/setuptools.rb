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
default_version "33.1.1"

dependency "python"

source url: "https://github.com/pypa/setuptools/archive/v#{version}.tar.gz"

version '33.1.1' do
  source md5: '6f325e870730cd90f3ac9608cdf6a82f'
end

license path: 'LICENSE'

relative_path "setuptools-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python bootstrap.py" \
          " --prefix=#{install_dir}/embedded", env: env

  command "#{install_dir}/embedded/bin/python setup.py install" \
          " --prefix=#{install_dir}/embedded", env: env
end
