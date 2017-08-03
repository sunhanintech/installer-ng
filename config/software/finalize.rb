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

# NOLICENSE (Nothing included in package)

name 'finalize'
description 'Cleans up useless data, generates a version manifest file and license manifest files'
default_version '2.0.0'

source :path => File.expand_path('files/license-scripts', Omnibus::Config.project_root)

dependency 'yolk'
dependency 'license-gem'

license :project_license
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Cleanup irrelevant data

  # noinspection RubyLiteralArrayInspection
  [
      'docs',             # MySQL build info
      'htdocs',           # Default page for Apache
      'man',              # Various man pages
      'icons',            # Apache autoindex icons.
      'manual',           # Apache manual
      'mysql-test',       # MySQL test suite
      'mysql-doc',        # MySQL documentation
      'share/man',        # Various man pages
      'share/gtk-doc',    # GTK documentation
      'share/doc',        # Various documentation pages
      'sql-bench',        # MySQL benchmark
      'php/man',          # PHP man pages
  ].each do |dir|
    delete "#{install_dir}/embedded/#{dir}"
  end

  # Version Manifest
  block do
    File.open("#{install_dir}/version-manifest.txt", 'w') do |f|
      f.puts "#{project.name} #{project.build_version}"
      f.puts ''
      f.puts Omnibus::Reports.pretty_version_map(project)
    end
  end

  # License manifest
  license_dir = "#{install_dir}/LICENSES"
  mkdir license_dir

  command "#{install_dir}/embedded/bin/python" \
          ' ./python-licenses.py' \
          " #{license_dir}/python-lib-licenses.txt", env: env

  command "#{install_dir}/embedded/bin/ruby" \
          ' ./ruby-licenses.rb' \
          " #{license_dir}/ruby-lib-licenses.txt", env: env

  block do
    File.open("#{license_dir}/php-lib-licenses.txt", 'w') do |f|
      php_packages = `#{install_dir}/embedded/bin/php #{install_dir}/embedded/bin/composer.phar show -N`.lines
      php_packages.each do |package|
        package = package.strip
        version = `#{install_dir}/embedded/bin/php #{install_dir}/embedded/bin/composer.phar show #{package} |grep '^version' |cut -d: -f2-`.strip
        license = `#{install_dir}/embedded/bin/php #{install_dir}/embedded/bin/composer.phar show #{package} |grep '^license' |cut -d: -f2-`.strip
        f.puts "This project includes the PHP package #{package} version #{version},"
        f.puts "available under the following license(s):"
        f.puts license
        f.puts ''
      end
    end
  end
end
