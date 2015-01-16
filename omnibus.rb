base_dir      ENV.fetch('OMNIBUS_BASE_DIR', '/var/cache/omnibus')

# Standard flags used by Debian for compilation (dpkg-buildflags)
# Consider: https://wiki.debian.org/HardeningWalkthrough
inject_cflags '-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2'
inject_ldflags '-Wl,-Bsymbolic-functions -Wl,-z,relro'
