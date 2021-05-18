# demo2                         @author Tate W. Hanawalt               tate@tatehanawalt.com
#
# This is a demo brew formula in the tatehanawalt/devtools homebrew tap for a go based cli
# ==========================================================================================
class Demo2 < Formula
  # ------------------------------------------------------------------------------------------
  # Formula vars/params
  # ------------------------------------------------------------------------------------------
  # bottle :unneeded                       # formula that can be
  depends_on "go" => :build               # dependencies
  desc "Brew install demo 2"              # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                                                  # Formulae version
  # ------------------------------------------------------------------------------------------
  # Formulae Methods:
  # ------------------------------------------------------------------------------------------
  stable do # brew install demo2
    puts "STABLE SECTION:"
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
    sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
  end
  head do # brew install --HEAD demo2
    puts "HEAD SECTION:"
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end
  on_linux do
    puts "ON_LINUX SECTION:"
  end
  on_macos do
    puts "ON_MACOS SECTION:"
  end
  def install # Install the actual cli regardless of stable or head...
    puts "INSTALL SECTION:"
    cd "demo2" do
      system "go", "build", "-ldflags", "-s -w -X 'main.Version=#{version}'"
      lib.install ["demo2", "doc/man/demo2.1"]
    end
    bin.install_symlink lib/"demo2" => "demo2"
    man1.install lib/"demo2.1"
  end
  def post_install # Called after installation completes
    puts "POST INSTALL SECTION:"
  end
  def caveats # List caveats of this formulae
    <<~EOS
      are there any caveats to brew installs? no... the answer is no.
    EOS
  end
end
__END__
