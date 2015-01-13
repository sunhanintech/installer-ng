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

default_version '1.0.1j'
source url: "http://www.openssl.org/source/openssl-#{version}.tar.gz",
       md5: 'f7175c9cd3c39bb1907ac8bba9df8ed3'

relative_path "openssl-#{version}"

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

  if aix?
    patch_env = env.dup
    patch_env['PATH'] = "/opt/freeware/bin:#{env['PATH']}"
    patch source: 'openssl-1.0.1f-do-not-build-docs.patch', env: patch_env
  else
    patch source: 'openssl-1.0.1f-do-not-build-docs.patch'
  end

  command configure_command, env: env
  make 'depend', env: env
  # make -j N on openssl is not reliable
  make env: env
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