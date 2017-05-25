name "readline"
default_version "6.3"

# http://buildroot-busybox.2317881.n4.nabble.com/PATCH-readline-link-directly-against-ncurses-td24410.html
# https://bugzilla.redhat.com/show_bug.cgi?id=499837
# http://lists.osgeo.org/pipermail/grass-user/2003-September/010290.html
# http://trac.sagemath.org/attachment/ticket/14405/readline-tinfo.diff
dependency "ncurses"

source :url => "ftp://ftp.gnu.org/gnu/readline/readline-#{version}.tar.gz",
       :md5 => "33c8fb279e981274f485fd91da77e94a"

relative_path "readline-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  patch :source => "readline-6.2-curses-link.patch" , :plevel => 1

  command './configure ' \
          " --prefix=#{install_dir}/embedded" \
          " --with-curses", env: env

  command 'make', env: env
  command 'make install', env: env

end
