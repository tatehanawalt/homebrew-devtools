# demo1
# @author Tate W. Hanawalt - tate@tatehanawalt.com
#
# this is a demo brew formula in the tatehanawalt/devtools homebrew tap

require_relative "../lib/private"

class Demo1 < Formula

  version "0.0.0"
  desc "Brew install demo 1"
  homepage "https://www.TateHanawalt.com"

  # when version is static but formula needs recompiling for another reason. 0 is default & unwritten.
  revision 0

  # formula that can be installed without compilation
  bottle :unneeded

  # pass skip to disable post-install stdlib checking
  cxxstdlib_check :skip

  # Options can be used as arguments to `brew install`.
  # To switch features on/off: `"with-something"` or `"with-otherthing"`.
  option :universal



  stable do
    # Stable-only dependencies should be nested inside a `stable` block rather than
    # using a conditional. It is preferrable to also pull the URL and checksum into
    # the block if one is necessary.

    puts "\nSTABLE SECTION:"

    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
    sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
    #url "https://example.com/foo-1.0.tar.gz"
    #sha1 "cafebabe78901234567890123456789012345678"
    #depends_on "libxml2"
    #depends_on "libffi"
  end

  head do
    # Optionally, specify a repository to be used. Brew then generates a
    # `--HEAD` option. Remember to also test it.
    puts "\nHEAD SECTION:"

    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  devel do
    # The optional devel block is only executed if the user passes `--devel`.
    # Use this to specify a not-yet-released version of a software.
    puts "\nDEVEL SECTION:"

    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end


  def install
    puts "\nINSTALL SECTION:"
    puts "  ACTIVE_LOG_PREFIX:              #{self.active_log_prefix}"
    puts "  ALIAS_CHANGED:                  #{self.alias_changed?}"
    puts "  ALIASES:                        #{self.aliases}"
    puts "  ALIAS_NAME:                     #{self.alias_name}"
    puts "  ALIAS_PATH:                     #{self.alias_path}"
    puts "  ANY_INSTALLED_PREFIX:           #{self.any_installed_prefix}"
    puts "  ANY_INSTALLED_VERSION:          #{self.any_installed_version}"
    puts "  BASH_COMPLETION:                #{self.bash_completion}"
    puts "  BIN:                            #{self.bin}"
    puts "  BOTTLE_HASH:                    #{self.bottle_hash}"
    puts "  BOTTLE_TAB_ATTRIBUTES:          #{self.bottle_tab_attributes}"
    puts "  BUILD:                          #{self.build}"
    puts "  BUILD_PATH:                     #{self.buildpath}"
    puts "  CAVEATS:                        #{self.caveats}"
    puts "  CURRENT_INSTALLED_ALIAS_TARGET: #{self.current_installed_alias_target}"
    puts "  DEPRECATED:                     #{self.deprecated?}"
    puts "  DEPRECATION_DATE:               #{self.deprecation_date}"
    puts "  DEPRECATION_REASON:             #{self.deprecation_reason}"
    puts "  DESC:                           #{self.desc}"
    puts "  DISABLE_DATE:                   #{self.disable_date}"
    puts "  DISABLE_REASON:                 #{self.disable_reason}"
    puts "  DISABLED:                       #{self.disabled?}"
    puts "  DOC:                            #{self.doc}"
    puts "  ETC:                            #{self.etc}"
    puts "  FISH_COMPLETION:                #{self.fish_completion}"
    puts "  FISH_FUNCTION:                  #{self.fish_function}"
    puts "  FRAMEWORKDS:                    #{self.frameworks}"
    puts "  FOLLOW_INSTALLED_ALIAS:         #{self.follow_installed_alias}"
    puts "  FULL_ALIAS_NAME:                #{self.full_alias_name}"
    puts "  FULL_INSTALLED_ALIAS_NAME:      #{self.full_installed_alias_name}"
    puts "  FULL_INSTALLED_SPECIFIED_NAME:  #{self.full_installed_specified_name}"
    puts "  FULL_SPECIFIED_NAME:            #{self.full_specified_name}"
    puts "  FULL_NAME:                      #{self.full_name}"
    # puts "  HEAD_VERSION_OUTDATED:          #{self.head_version_outdated?}"
    puts "  HOMEPAGE:                       #{self.homepage}"
    puts "  INCLUDE:                        #{self.include}"
    puts "  INFO:                           #{self.info}"
    # puts "  INSTALL:                        #{self.install}"
    puts "  INSTALLED_ALIAS_NAME:           #{self.installed_alias_name}"
    puts "  INSTALLED_ALIAS_PATH:           #{self.installed_alias_path}"
    puts "  INSTALLED_ALIAS_TARGET_CHANGED: #{self.installed_alias_target_changed?}"
    puts "  INSTALLED_SPECIFIED_NAME:       #{self.installed_specified_name}"
    puts "  KEG_ONLY:                       #{self.keg_only?}"
    puts "  KEXT_PREFIX:                    #{self.kext_prefix}"
    puts "  LATEST_HEAD_PREFIX:             #{self.latest_head_prefix}"
    puts "  LATEST_HEAD_VERSION:            #{self.latest_head_version}"
    puts "  LIB:                            #{self.lib}"
    puts "  LIBEXEC:                        #{self.libexec}"
    puts "  LICENSE:                        #{self.license}"
    puts "  LINKED:                         #{self.linked?}"
    puts "  LINKED_VERSION:                 #{self.linked_version}"
    puts "  LIVECHECK:                      #{self.livecheck}"
    puts "  LIVECHECKABLE:                  #{self.livecheckable?}"
    puts "  MAN:                            #{self.man}"
    puts "  MAN1:                           #{self.man1}"
    puts "  MAN2:                           #{self.man2}"
    puts "  MAN3:                           #{self.man3}"
    puts "  MAN4:                           #{self.man4}"
    puts "  MAN5:                           #{self.man5}"
    puts "  MAN6:                           #{self.man6}"
    puts "  MAN7:                           #{self.man7}"
    puts "  MAN8:                           #{self.man8}"
    puts "  MIGRATION_NEEDED:               #{self.migration_needed?}"
    puts "  NAME:                           #{self.name}"
    puts "  NEW_FORMULA_AVAILABLE:          #{self.new_formula_available?}"
    puts "  OLD_INSTALLED_FORMULAE:         #{self.old_installed_formulae}"
    puts "  OLDNAME:                        #{self.oldname}"
    puts "  OPT_BIN:                        #{self.opt_bin}"
    puts "  OPT_ELISP:                      #{self.opt_elisp}"
    puts "  OPT_FRAMEWORKS:                 #{self.opt_frameworks}"
    puts "  OPT_INCLUDE:                    #{self.opt_include}"
    puts "  OPT_LIB:                        #{self.opt_lib}"
    puts "  OPT_LIBEXEC:                    #{self.opt_libexec}"
    puts "  OPT_PKGSHARE:                   #{self.opt_pkgshare}"
    puts "  OPT_PREFIX:                     #{self.opt_prefix}"
    puts "  OPT_SBIN:                       #{self.opt_sbin}"
    puts "  OPT_SHARE:                      #{self.opt_share}"
    # puts "  OPTION_DEFINED:                 #{self.option_defined?}"
    puts "  OPTLINKED:                      #{self.optlinked?}"
    puts "  PATH:                           #{self.path}"
    puts "  PKG_VERSION:                    #{self.pkg_version}"
    puts "  PKGETC:                         #{self.pkgetc}"
    puts "  PKGSHARE:                       #{self.pkgshare}"
    # puts "  PLIST:                          #{self.plist}"
    puts "  PLIST_NAME:                     #{self.plist_name}"
    puts "  PLIST_PATH:                     #{self.plist_path}"
    puts "  POUR_BOTTLE:                    #{self.pour_bottle?}"
    puts "  RESOURCES:                      #{self.resources}"
    puts "  RPATH:                          #{self.rpath}"
    puts "  REVISION:                       #{self.revision}"
    puts "  RUNTIME_INSTALLED_F_DEPENDENTS: #{self.runtime_installed_formula_dependents}"
    puts "  SBIN:                           #{self.sbin}"
    puts "  SERVICE:                        #{self.service}"
    puts "  SERVICE?:                       #{self.service?}"
    puts "  SERVICE_NAME:                   #{self.service_name}"
    puts "  SHARE:                          #{self.share}"
    puts "  SKIP_CXXSTDLIB_CHECK:           #{self.skip_cxxstdlib_check?}"
    puts "  SPECIFIED_NAME:                 #{self.specified_name}"
    puts "  SPECIFIED_PATH:                 #{self.specified_path}"
    puts "  STD_CABAL_V2_ARGS:              #{self.std_cabal_v2_args}"
    puts "  STD_CARGO_ARGS:                 #{self.std_cargo_args}"
    puts "  STD_CMAKE_ARGS:                 #{self.std_cmake_args}"
    puts "  STD_CONFIGURE_ARGS:             #{self.std_configure_args}"
    puts "  STD_GO_ARGS:                    #{self.std_go_args}"
    puts "  STD_MESON_ARGS:                 #{self.std_meson_args}"
    puts "  SUPERSEDES_AN_INSTALLED_FORMULA?: #{self.supersedes_an_installed_formula?}"
    # puts "  system:                        #{self.system?}"
    puts "  SYSTEMD_SERVICE_PATH:           #{self.systemd_service_path}"
    puts "  TEST_PATH:                      #{self.testpath}"
    puts "  UPDATE_HEAD_VERSION:            #{self.update_head_version}"
    puts "  VAR:                            #{self.var}"
    puts "  VERSION:                        #{self.version}"
    puts "  VERSIONED_FORMULA:              #{self.versioned_formula?}"
    puts "  VERSIONED_FORMULAE:             #{self.versioned_formulae}"
    puts "  VERSION_SCHEME:                 #{self.version_scheme}"
    puts "  ZSH_COMPLETION:                 #{self.zsh_completion}"
    puts "  ZSH_FUNCTION:                   #{self.zsh_function}"
    # puts "  ON_LINUX:                       #{self.on_linux}"
    # puts "  ON_MACOS:                       #{self.on_macos}"
    puts ""
    # puts "  CURRENT:                        #{current}"
    puts "  DEBUG?:                         #{self.debug?}"
    puts "  QUIET?:                         #{self.quiet?}"
    puts "  VERBOSE?:                       #{self.verbose?}"
    # puts "  WITH_CONTEXT:                   #{self.with_context}"


    lib.install Dir["*"]
    bin.install_symlink lib/"demo1.zsh" => "demo1"
    man1.install lib/"demo1.1"

    # bash_completion.install "watson.completion" => "watson"
    # zsh_completion.install lib/"_demo1" => "_demo1"

    system "ls", "-la"
    system "pwd"

  end

  def post_install
    puts "\nPOST INSTALL SECTION:"
  end

  def caveats
    <<~EOS
      Are optional. Something the user must be warned about?
    EOS
  end

end

# link_overwrite "bin/foo", "lib/bar"
# link_overwrite "share/man/man1/baz-*"
# plist_options startup: true
# plist_options manual: "foo"
# plist_options startup: true, manual: "foo start"
# skip_clean "bin/foo", "lib/bar" # skip cleaning paths in a formula


# A very good example intended to showcase and present the features / use cases of a formulae -> https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb

# debug mode: --debug
# verbose mode: --verbose
# add --interactive for interactive # try env | grep HOMEBREW

# List the release download urls
# export REPO=.th_sys
# export ORG=tatehanawalt
# curl -s https://api.github.com/repos/$ORG/$REPO/releases/latest
#
# Download with:
# curl -L https://api.github.com/repos/<org>/<repo>/tarball/<version> --output <version>.tar.gz
#
# FOR EXAMPLE,
#
# export VERSION=0.0.1
# export REPO=.th_sys
# export ORG=tatehanawalt
#
# curl -L "https://api.github.com/repos/${ORG}/${REPO}/tarball/${VERSION}" --output "${VERSION}.tar.gz"
#
# OR
#
# VERSION=0.0.0 && REPO=.th_sys && ORG=tatehanawalt && curl -L "https://api.github.com/repos/${ORG}/${REPO}/tarball/${VERSION}" --output "${VERSION}.tar.gz"
#
# Next, get the shasum of the tarball:
#
# shasum -a 256 ${VERSION}.tar.gz
#
# you can also untar with:
#
# tar -xvzf ${VERSION}.tar.gz
#
# Increment the formula VERSION
#
# Then commit the tap.
#
# To keep the existing version, commit the tap with the original version, THEN:
#
# uninstall the tap `brew untap tatehanawalt/devtools`
# clean the brew cache: `brew cleanup`
# re-install the tap: `brew tap tatehanawalt/devtools`
#
# Install the latest by:
# 1. unlink or uninstall existing formula: brew uninstall demo1
# 2. install head: brew install demo1 --HEAD
#
# Upgrade head:
# brew upgrade demo1 --fetch-HEAD
#
# when using a private repo, a github api token set to env var HOMEBREW_GITHUB_API_TOKEN is required
