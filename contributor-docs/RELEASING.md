Configuring Your Environment
----------------------------

Configuring your environment is the more difficult step. Here's what you
need to do.


### Tools ###

You will need the following tools installed:

  + `git`, `bash`, `python` - obviously.
  + `bundle` to run cookbook tests (and `bundle install` must have been run
    first).
  + `berkshelf` - to package the cookbooks.
    The best way to get this is to install the Chef Development Kit (using
    Homebrew: `brew cask install chef-dk`).
  + *GNU* `mktemp` and `sed` - because you Mac's are wrong.
    Using Homebrew: `brew install coreutils gnu-sed`. It's ok if this gets
    installed with a `g` prefix, we detect it.
  + GNU `parallel` - to build the `scalr-manage` packages in parallel.
    Using Homebrew: `brew install parallel`.
  + `s3put`, which is part of `boto`. Using pip: `pip install boto`.
  + `tox`, a test runner for Python. Using pip: `pip install tox`.
  + `twine`, a helper for Python package uploads. Using pip:
    `pip install twine`.
  + `docker`, with a functional Docker environment (i.e. `DOCKER_HOST`, etc.).
    You can either use `boot2docker`, or a remote Docker, either work fine.

Optionally, you can also install the Scalr CLI tools if you intend to use the
`-f` option in `./release.sh`.
Once you've made changes to the installer, you'll want to release a new
version.


### Credentials ###

#### GitHub ####

If you are going to create final releases (more on this below), you'll need
to have push access to the `scalr/installer-ng` repository on GitHub.

#### AWS ####

To upload the installer cookbooks to S3, you will need to have credentials
configured for Boto that will grant you push access to the
`installer.scalr.com` bucket.

There are many ways to configure Boto, but the most straightforward one is
to set the following environment variables: `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY`.

#### Package Cloud ####

To publish packages, you need to have a `~/.packagecloud` credentials file
that grants access to the `scalr` organizations.

You can get this by installing the [`package_cloud` CLI utility][10] and
running it.

#### PyPi ####

TODO!

For now, your PyPi uploads will fail, but that's fine.


Building a New Release
----------------------

Before building a new release, make sure that you commit all pending changes.

Then, issue the following command, from the root of the installer project:

    ./release.sh <version>

Note that the version format must follow [semantic versioning][00], and that
this is actually enforced by the `version_helper.py` script. We also have a few
additional conventions (review `version_helper.py` to identify what a suitable
version looks like).

Semantically, we interpret a breaking change (i.e. one that triggers bumping
the major version number) as a change that requires running "configure" again.


### Issuing a Pre-Release ###

The version number you use also has an impact on what the release script does.

If your release is a pre-release (i.e. it looks like `1.1.1-a.1`), then the
release script will push your packages to one of the pre-release repositories
(e.g. `scalr/scalr-manage-a`), and will not push the release branch to GitHub
(though you can push it yourself).

However, if your release isn't a pre-release (i.e. it looks like `1.1.1`), then
the release script will push to the main repository (`scalr/scalr-manage`),
and will publish your release branch to GitHub.


Merging
-------

Technically, once your release is live in the repos and on PyPi, it's live for
end-users, so it's important that you ensure that before you make a release,
it's ready for history (i.e. make sure that all extraneous changes are
properly rebased, that the branch fast-forwards form master, that it works,
etc.).

For now, this means that releases should be done sequentially (so that we
don't have multiple people conflicting for a release).

At this time, releases are created by: `Thomas Orozco <thomas@scalr.com>`.


  [00]: http://semver.org
  [10]: https://packagecloud.io/docs#cli_install
