class Demo1 < Formula
  version "0.0.0"

  # get the shaval with $: shasum -a 256 <path/to/installfile.tar.gz>
  sha256 "51d57c363194931a91e6cb8ebc813f8bfa9e6af9d3c36e0c9a6d72504734cb8c"
  desc "Brew install demo 1"
  homepage "https://www.TateHanawalt.com"
  url "https://api.github.com/repos/tatehanawalt/.th_sys/tarball/0.0.0", :using => :curl

  def install
    lib.install Dir["*"]
    ENV.deparallelize
    bin.install_symlink lib/demo1.zsh => demo1
  end

end


# -----------------------------------------------------
# Brewd Builder FormulaMaker
# @author Tate Hanawalt
# -----------------------------------------------------

# STATIC SECTION
# ----------------------------------------------------------------------------

# INSTALL SECTION
# ----------------------------------------------------------------------------
# def install
#   # Brewd .buildconf INSTALLSECTION
#   lib.install Dir["*"]
#   ENV.deparallelize
#   bin.install_symlink lib/"linker.sh" => "linker"
# end
# tatehanawalt-.th_sys-6d849d2
