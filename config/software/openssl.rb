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

name 'openssl'

dependency 'zlib'
dependency 'cacerts'

default_version '1.0.2j'
source url: "http://www.openssl.org/source/openssl-#{version}.tar.gz"

version '1.0.1k' do
  source md5: 'd4f002bd22a56881340105028842ae1f'
end

version '1.0.1l' do
  source md5: 'cdb22925fc9bc97ccbf1e007661f2aa6'
end

version '1.0.1m' do
  source md5: 'd143d1555d842a069cb7cc34ba745a06'
end

version '1.0.1n' do
  source md5: '139568bd5a56fa49b72a290d37113f30' 
end

version '1.0.1o' do
  source md5: 'af1096f500a612e2e2adacb958d7eab1'
end

version '1.0.1p' do
  source md5: '7563e92327199e0067ccd0f79f436976'
end

version '1.0.1q' do
  source md5: '54538d0cdcb912f9bc2b36268388205e'
end

version '1.0.1r' do
  source md5: '1abd905e079542ccae948af37e393d28'
end

version '1.0.1s' do
  source md5: '562986f6937aabc7c11a6d376d8a0d26'
end

version '1.0.1t' do
  source md5: '9837746fcf8a6727d46d22ca35953da1'
end

version '1.0.1u' do
  source md5: '130bb19745db2a5a09f22ccbbf7e69d0'
end

version '1.0.2j' do
  source md5: '96322138f0b69e61b7212bc53d5e912b'
end

relative_path "openssl-#{version}"

license path: 'LICENSE'


build do
  # View: https://raw.githubusercontent.com/opscode/omnibus-software/master/config/software/openssl.rb
  # We are only interested in Linux here.
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = ['./config',
                       "--prefix=#{install_dir}/embedded",
                       "--with-zlib-lib=#{install_dir}/embedded/lib",
                       "--with-zlib-include=#{install_dir}/embedded/include",
                       'no-idea',
                       'no-mdc2',
                       'no-rc5',
                       'zlib',
                       'shared',
                       'disable-gost',
                       "-L#{install_dir}/embedded/lib",
                       "-I#{install_dir}/embedded/include",
                       "-Wl,-rpath,#{install_dir}/embedded/lib"].join(' ')

  command configure_command, env: env
  make 'depend', env: env
  # make -j N on openssl is not reliable
  make "-j #{workers}", env: env
  if aix?
    # We have to sudo this because you can't actually run slibclean without being root.
    # Something in openssl changed in the build process so now it loads the libcrypto
    # and libssl libraries into AIX's shared library space during the first part of the
    # compile. This means we need to clear the space since it's not being used and we
    # can't install the library that is already in use. Ideally we would patch openssl
    # to make this not be an issue.
    # Bug Ref: http://rt.openssl.org/Ticket/Display.html?id=2986&user=guest&pass=guest
    command 'sudo /usr/sbin/slibclean', env: env
  end
  make 'install', env: env
end
