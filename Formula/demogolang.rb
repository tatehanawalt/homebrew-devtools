#==============================================================================
#title   :demogolang
#version :0.0.0
#desc    :golang cli built as part of the homebrew demo/dev tools project
#usage   :See the repo README file for usage
#exit    :0=success, 1=input error 2=execution error
#auth    :Tate Hanawalt(tate@tatehanawalt.com)
#date    :1621396284
#==============================================================================
class Demogolang < Formula

  # ------------------------------------------------------------------------------------------
  # Formula vars/params
  # ------------------------------------------------------------------------------------------

  # bottle :unneeded                      # formula that can be
  depends_on "go" => :build               # dependencies
  desc "Brew install demogolang"          # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  # ------------------------------------------------------------------------------------------
  # Formulae Methods:
  # ------------------------------------------------------------------------------------------

  # versions download differentiators
  head do # brew install --HEAD demogolang
    puts "HEAD SECTION:"
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end
  stable do # brew install demogolang
    puts "STABLE SECTION:"
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
    sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
  end

  # os/arch level handlers
  on_linux do
    puts "ON_LINUX SECTION:"
  end
  on_macos do
    puts "ON_MACOS SECTION:"
  end

  # Installatiion Methods
  def install # Install the actual cli regardless of stable or head...
    puts "INSTALL SECTION:"
    cd "demogolang" do
      system "go", "build", "-ldflags", "-s -w -X 'main.Version=#{version}'"
      lib.install ["demogolang", "doc/man/demogolang.1"]
    end
    bin.install_symlink lib/"demogolang" => "demogolang"
    man1.install lib/"demogolang.1"
  end
  def post_install # Called after installation completes
    puts "POST INSTALL SECTION:"
  end

  # Clean up / Reference
  def caveats # List caveats of this formulae
    <<~EOS
      are there any caveats to brew installs? no... the answer is no.
    EOS
  end
end
__END__
