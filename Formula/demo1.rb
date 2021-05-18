
# -----------------------------------------------------
# Brewd Builder FormulaMaker
# @author Tate Hanawalt
# -----------------------------------------------------
class Demo1 < Formula

  # STATIC SECTION
  # ----------------------------------------------------------------------------
  version "0.0.0"

  # get the shaval with $: shasum -a 256 <path/to/installfile.tar.gz>
  sha256 "275ff91052abae98daf4fe730efa81c817f93411af6dac4989e42c107b40e9ab"
  desc "Brew install demo 1"
  homepage "https://www.TateHanawalt.com"

  # DOWNLOAD SECTION
  # ----------------------------------------------------------------------------
  # TAR Install File Getter
  # ip = "127.0.0.1"
  # port = 4123
  # requrl = "http://#{ip}:#{port}"
  # url "#{requrl}/linker/darwin/0.0.0", :using => :curl
  # INSTALL SECTION
  # ----------------------------------------------------------------------------
  # def install
  #   # Brewd .buildconf INSTALLSECTION
  #   lib.install Dir["*"]
  #   ENV.deparallelize
  #   bin.install_symlink lib/"linker.sh" => "linker"
  # end

end
