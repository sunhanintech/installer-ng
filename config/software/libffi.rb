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

name 'libffi'
default_version '3.0.13'

source url: "ftp://sourceware.org/pub/libffi/libffi-#{version}.tar.gz",
       md5: '45f3b6dbc9ee7c7dfbbbc5feba571529'

relative_path "libffi-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # View:
  # - https://sourceware.org/ml/libffi-discuss/2014/msg00017.html
  # - https://ghc.haskell.org/trac/ghc/ticket/9620
  patch source: 'fix-libffi-libdir.patch'

  command './configure' \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  # libffi's default install location of header files is awful...
  copy "#{install_dir}/embedded/lib/libffi-#{version}/include/*", "#{install_dir}/embedded/include"
end

