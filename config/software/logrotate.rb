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
default_version '3.9.1'

dependency 'libpopt'

# the following line should replace the uncommented one the day we switch to a more recent version:
#source url: "https://github.com/logrotate/logrotate/releases/download/#{version}/logrotate-#{version}.tar.gz"
# the 3.9.1 URL is left hardcoded because the 3.9.1 release has a dumb version tag with dashes on github but newer ones use the format above
source url: "https://github.com/logrotate/logrotate/archive/r3-9-1.tar.gz"

version '3.9.1' do
  source md5: '8572b7c2cf9ade09a8a8e10098500fb3'
end

# Same as before
#relative_path "logrotate-#{version}"
relative_path "logrotate-r3-9-1"

license path: 'COPYING'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Logrotate requires a very recent automake. We generate the autogen files elsewhere.
  # Including the version in the name ensures we regenerate the configure script and others if you upgrade logrotate.
  # The configure script can be generated using a recent system (e.g. Ubuntu 14.04 as of this writing)
  # using ./autogen.sh; provided the appropriate software (automake, libtool) is installed.
  patch source: "0001-add-autogen-#{version}.patch"

  # Patch doesn't take modes into account. Change those that must be changed
  %w{compile depcomp install-sh missing configure}.each do |bin|
    command "chmod 755 #{project_dir}/#{bin}"
  end

  command './configure' \
          ' --without-selinux' \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end

