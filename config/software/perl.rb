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

name 'perl'
default_version '5.20.2'

dependency 'zlib'
dependency 'bzip2'
dependency 'gdbm'

source url: "http://www.cpan.org/src/5.0/perl-#{version}.tar.gz"

version '5.20.2' do
  source md5: '81b17b9a4e5ee18e54efe906c9bf544d'
end

relative_path "perl-#{version}"

license path: 'Copying'


build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['BUILD_ZLIB'] = "False"
  env['BUILD_BZIP2'] = "0"
  env["ZLIB_INCLUDE"] = "#{install_dir}/embedded/include"
  env["BZIP2_INCLUDE"] = "#{install_dir}/embedded/include"
  env["ZLIB_LIB"] = "#{install_dir}/embedded/lib"
  env["BZIP2_LIB"] = "#{install_dir}/embedded/lib"

  command './Configure' \
              ' -des' \
              " -Dprefix=#{install_dir}/embedded" \
              ' -Dusethreads' \
              ' -Dnoextensions="DB_File"' \
              ' -de' \
              " -Dlocincpth=#{install_dir}/embedded/include" \
              " -Dloclibpth=#{install_dir}/embedded/lib", env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end
