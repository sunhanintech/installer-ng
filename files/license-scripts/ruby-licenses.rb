require 'gem_licenses'


# gem-licenses uses the gems that are loaded, so we just load all the gems.
Gem::Specification.each do |gem|
  begin
    require gem.name
  rescue LoadError
    # ignored
  end
end

File.open(ARGV.first, 'w') do |f|
  Gem.licenses.each do |license, gems|
    f.puts "#{license}"
    f.puts '=' * license.length
    gems.sort_by(&:name).each do |gem|
      f.puts "* #{gem.name} #{gem.version} (#{gem.homepage})"
    end
    f.puts ''
  end
end

