# demo1
# @author Tate W. Hanawalt - tate@tatehanawalt.com
#
# this is a demo brew formula in the tatehanawalt/devtools homebrew tap
#
class Demo1 < Formula
  version "0.0.0"
  desc "Brew install demo 1"
  homepage "https://www.TateHanawalt.com"
  url "https://api.github.com/repos/tatehanawalt/.th_sys/tarball/0.0.1", :using => :curl
  sha256 "d5ef43b1a1a6a1d75bc19aadfaf56374c91bbe19040ef967ece77bd73508f08c"
  head "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  def install
    lib.install Dir["*"]
    bin.install_symlink lib/"demo1.zsh" => "demo1"
    man1.install lib/"demo1.1"
  end
end
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
