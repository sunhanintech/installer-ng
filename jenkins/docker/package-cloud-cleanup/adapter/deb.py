# coding:utf-8
from debian import deb822

from ._base import BaseRepoAdapter
from ._constant import HIGHEST_CHAR
from ._util import get_version_tuple


DEB_PKG_TPL = "https://packagecloud.io/{user}/{repo}/{distro}/dists/{release}/main/{arch}/Packages"


class DebRepoAdapter(BaseRepoAdapter):
    def _get_platforms(self):
        return ["ubuntu/precise", "ubuntu/trusty", "debian/wheezy", "debian/jessie"]

    def _get_archs(self):
        return ["binary-amd64",]

    def _extract_file_name(self, pkg):
        return pkg["Filename"]

    def _extract_pkg_name(self, pkg):
        return pkg["Package"]

    def _extract_orderable_version(self, pkg):
        deb_version = pkg["Version"].decode('utf-8')
        deb_version.replace('~', HIGHEST_CHAR)

        if "-" in deb_version:
            version, iteration = deb_version.split('-')
        else:
            version, iteration = deb_version, '1'
        return get_version_tuple(version, iteration)

    def _fetch_package_list(self, platform, arch):
        distro, release = platform.split("/")
        res = self.client_session.get(DEB_PKG_TPL.format(user=self.user, repo=self.repo, distro=distro, release=release, arch=arch), stream=True)
        res.raise_for_status()
        return list(deb822.Packages.iter_paragraphs(res.iter_lines()))
