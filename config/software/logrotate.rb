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

name 'logrotate'
default_version '3.12.2'

dependency 'libpopt'

version '3.12.2' do
  source url: 'https://github.com/logrotate/logrotate/releases/download/3.12.2/logrotate-3.12.2.tar.xz'
  source md5: '923e753825405280aebcc4e73b4b2b55'
end

version '3.9.1' do
  source url: "https://fedorahosted.org/releases/l/o/logrotate/logrotate-#{version}.tar.gz"
  source md5: '4492b145b6d542e4a2f41e77fa199ab0'
end

relative_path "logrotate-#{version}"

license 'GPL-2.0'
license_file 'COPYING'
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Logrotate requires a very recent automake. We generate the autogen files elsewhere.
  # Including the version in the name ensures we regenerate the configure script and others if you upgrade logrotate.
  # The configure script can be generated using a recent system (e.g. Ubuntu 14.04 as of this writing)
  # using ./autogen.sh; provided the appropriate software (automake, libtool) is installed.
  #patch source: "0001-add-autogen-#{version}.patch"

  # Patch doesn't take modes into account. Change those that must be changed
  #%w{compile depcomp install-sh missing configure}.each do |bin|
  #  command "chmod 755 #{project_dir}/#{bin}"
  #end

  command './configure' \
          ' --without-selinux' \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end

