# demozsh                         @author Tate W. Hanawalt               tate@tatehanawalt.com
#
# this is a demo brew formula in the tatehanawalt/devtools homebrew tap for a zsh based cli
# with zsh completions
# ==========================================================================================
class Demozsh < Formula
  # ------------------------------------------------------------------------------------------
  # Formula vars/params
  # ------------------------------------------------------------------------------------------
  bottle :unneeded                        # formula that can be installed without compilation
  depends_on "zsh" => :install            # dependencies
  desc "Brew install demozsh"             # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version
  # ------------------------------------------------------------------------------------------
  # Formulae Methods:
  # ------------------------------------------------------------------------------------------

  # versions download differentiators
  head do # brew install --HEAD demozsh
    puts "HEAD SECTION:"
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end
  stable do # brew install demozsh
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
    cd "demozsh" do
      lib.install ["_demozsh", "demozsh.zsh", "doc/man/demozsh.1"]
    end
    zsh_completion.install lib/"_demozsh"
    bin.install lib/"demozsh.zsh" => "demozsh"
    man1.install lib/"demozsh.1"
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
