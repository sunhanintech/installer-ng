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

name 'ssh-keygen'
default_version '6.8p1'

dependency 'zlib'
dependency 'openssl'

source url: "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-#{version}.tar.gz"

version '6.8p1' do
  source md5: '08f72de6751acfbd0892b5f003922701'
end

relative_path "openssh-#{version}"

license path: 'LICENCE', encoding: Encoding::ISO_8859_1


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
    " --prefix=#{install_dir}/embedded", env: env

  binary = 'ssh-keygen'

  make binary, env: env
  command "install -m 0755 #{binary} #{install_dir}/embedded/bin/#{binary}", env: env
end
