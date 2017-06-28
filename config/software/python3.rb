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

name 'python3'
default_version '3.5.3'

dependency 'gdbm'
dependency 'ncurses'
dependency 'zlib'
dependency 'openssl'
dependency 'bzip2'
dependency 'expat'
dependency 'libffi'
dependency 'sqlite'
dependency 'augeas'

source url: "https://www.python.org/ftp/python/#{version}/Python-#{version}.tgz"

version '3.5.2' do
  source md5: '3fe8434643a78630c61c6464fe2e7e72'
end

version '3.5.3' do
  source md5: '6192f0e45f02575590760e68c621a488'
end

relative_path "Python-#{version}"

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['CFLAGS'] = "-I#{install_dir}/embedded/include -O3 -g -pipe"

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          ' --with-system-expat' \
          ' --with-system-ffi' \
          ' --enable-shared' \
          ' --enable-unicode=ucs4' \
          ' --with-dbmliborder=gdbm', env: env

  make "-j #{workers}", env: env
  make 'install', env: env

  # There exists no configure flag to tell Python to not compile readline
  #delete "#{install_dir}/embedded/lib/python3.5/lib-dynload/readline.*"

  # Remove unused extension which is known to make healthchecks fail on CentOS 6
  delete "#{install_dir}/embedded/lib/python3.5/lib-dynload/_bsddb.*"

end
