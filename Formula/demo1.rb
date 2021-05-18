# demo1
# @author Tate W. Hanawalt - tate@tatehanawalt.com
#
# this is a demo brew formula in the tatehanawalt/devtools homebrew tap

require_relative "../lib/private"

class Demo1 < Formula

  def initialize()
    super
    # puts "this is an initialization method"
    # @cust_id = id
    # @cust_name = name
    # @cust_addr = addr
  end


  version "0.0.0"
  desc "Brew install demo 1"
  homepage "https://www.TateHanawalt.com"
  url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
  sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
  head "https://github.com/tatehanawalt/.th_sys.git", branch: "main"

  def install
    ohai "this is the install section, access token: #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"

    puts "\n\nthis is an install section \n\n"

    lib.install Dir["*"]
    bin.install_symlink lib/"demo1.zsh" => "demo1"
    man1.install lib/"demo1.1"
  end
end

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
