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

name 'libzmq'
default_version '4.0.5'

dependency 'libuuid'

source url: "http://download.zeromq.org/zeromq-#{version}.tar.gz"

version '4.0.5' do
  source md5: '73c39f5eb01b9d7eaf74a5d899f1d03d'
end

relative_path "zeromq-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['CXXFLAGS'] = "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"

  command "./configure --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end