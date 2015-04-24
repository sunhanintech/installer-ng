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
require 'shellwords'

name 'ssmtp'
default_version '2.64'

dependency 'openssl'
dependency 'cacerts'

source url: "http://ftp.de.debian.org/debian/pool/main/s/ssmtp/ssmtp_#{version}.orig.tar.bz2"

version '2.64' do
  source md5: '65b4e0df4934a6cd08c506cabcbe584f'
end

relative_path "ssmtp-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  patch source: '0001-Support-LDFLAGS.patch'
  patch source: '0001-Add-missing-lcrypto.patch'
  patch source: '0001-Do-not-autogenerate-config.patch'
  patch source: '0001-Do-not-log-to-tmp.patch'
  patch source: '0001-SSMTP-Validate-TLS-Server-Cert-From-Fedora.patch'
  patch source: '0001-SSMTP-Garbage-Writes-from-Fedora.patch'
  patch source: '0001-SSMTP-Authpass-from-Fedora.patch'
  patch source: '0001-SSMTP-Add-option-to-not-verify-SSL-certs.patch'

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          " --sysconfdir=#{install_dir}/etc" \
          ' --enable-logfile' \
          ' --enable-ssl' \
          ' --enable-inet6' \
          ' --enable-md5auth' \
          " --with-cflags=#{Shellwords.escape(env['CFLAGS'])}", env: env

  make env: env
  make 'install', env: env
end
