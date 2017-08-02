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
name 'libnettle'
default_version '3.3'

source url: "https://ftp.gnu.org/gnu/nettle/nettle-#{version}.tar.gz"

version '3.3' do
  source md5: '10f969f78a463704ae73529978148dbe'
end

relative_path "nettle-#{version}"

license 'LGPL-3.0'
license_file 'COPYING.LESSERv3'

dependency 'libgmp'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          ' --disable-static' \
          " --libdir=#{install_dir}/embedded/lib" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end
