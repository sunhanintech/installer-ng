name 'dejavu-sans-ttf'
default_version '2.34'

source url: "http://sourceforge.net/projects/dejavu/files/dejavu/#{version}/dejavu-sans-ttf-#{version}.zip"

relative_path "dejavu-sans-ttf-#{version}"

version '2.34' do
  source md5: 'cdcd347d8c13934dd52a777ced41020a'
end

build do
  font_dir = "#{install_dir}/embedded/share/fonts/truetype/dejavu"
  mkdir font_dir
  sync './ttf', font_dir
end