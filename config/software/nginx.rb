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

name 'nginx'
default_version '1.8.0'

source url: "http://nginx.org/download/nginx-#{version}.tar.gz"

version '1.8.0' do
  source md5: '3ca4a37931e9fa301964b8ce889da8cb'
end

dependency 'openssl'
dependency 'pcre'
dependency 'zlib'

relative_path "nginx-#{version}"

license path: 'LICENSE'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          " --with-ld-opt=-L#{install_dir}/embedded/lib" \
          " --with-cc-opt=\"-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include\"" \
          " --conf-path=#{install_dir}/etc/nginx/nginx.conf" \
          " --error-log-path=#{install_dir}/var/log/nginx/web.error.log" \
          " --http-log-path=#{install_dir}/var/log/nginx/web.access.log" \
          " --pid-path=#{install_dir}/var/run/nginx/nginx.pid" \
          " --http-client-body-temp-path=#{install_dir}/var/lib/nginx/client_body_temp" \
          " --http-proxy-temp-path=#{install_dir}/var/lib/nginx/proxy_temp" \
          " --http-fastcgi-temp-path=#{install_dir}/var/lib/nginx/fastcgi_temp" \
          " --http-uwsgi-temp-path=#{install_dir}/var/lib/nginx/uwsgi_temp" \
          " --http-scgi-temp-path=#{install_dir}/var/lib/nginx/scgi_temp" \
          ' --with-http_ssl_module' \
          ' --with-http_stub_status_module' \
          ' --with-http_gzip_static_module' \
          ' --with-http_spdy_module' \
          ' --with-threads' \
          ' --with-ipv6', env: env

  make env: env
  make 'install', env: env

  #Delete unwanted pahts. Will be re-created by Chef if needed
  ['embedded/html', 'etc/nginx', 'var/log/nginx', 'var/run/nginx', 'var/lib/nginx'].each do |dir|
    command "rm -rf '#{install_dir}/#{dir}'"
  end

end

