# coding:utf-8
from xml.etree import ElementTree

from repodataParser.RepoParser import Parser

from ._base import BaseRepoAdapter
from ._util import get_version_tuple


RPM_ROOT_TPL = "https://packagecloud.io/{user}/{repo}/{platform}/{arch}/"
RPM_REPOMD_PATH = "repodata/repomd.xml"

RPM_REPOMD_NS = {'repo': 'http://linux.duke.edu/metadata/repo'}


class ParserWithRequests(Parser):
    def __init__(self, session, url):
        self.session = session
        self.url = url
        Parser.__init__(self, url=url)

    # Library does name mangling.
    def _Parser__open(self):
        r = self.session.get(self.url, headers={"User-Agent": "curl/7.37.1"})
        r.raise_for_status()
        self.res = r.content


class RpmRepoAdapter(BaseRepoAdapter):
    def _get_platforms(self):
        return ["el/6", "el/7", "ol/6", "ol/7"]

    def _get_archs(self):
        return ["x86_64",]

    def _extract_file_name(self, pkg):
        return pkg["location"][1]["href"]

    def _extract_pkg_name(self, pkg):
        return pkg["name"][0]

    def _extract_orderable_version(self, pkg):
        version = pkg["version"][1]
        ver, rel = version["ver"], version["rel"]
        return get_version_tuple(ver, rel)

    def _fetch_package_list(self, platform, arch):
        root_url = RPM_ROOT_TPL.format(user=self.user, repo=self.repo, platform=platform, arch=arch)
        # Get repomd for primary URL first

        repomd = self.client_session.get("{0}{1}".format(root_url, RPM_REPOMD_PATH)).text
        primary_path = ElementTree.fromstring(repomd).findall("./repo:data[@type='primary']/repo:location", RPM_REPOMD_NS)[0].get('href')

        repodata = ParserWithRequests(self.client_session, "{0}{1}".format(root_url, primary_path))
        return  list(repodata.getList())

