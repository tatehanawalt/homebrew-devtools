#==============================================================================
#title   :demozsh
#version :0.0.0
#desc    :zsh cli built as part of the homebrew demo/dev tools project
#usage   :See the repo README file for usage
#exit    :0=success, 1=input error 2=execution error
#auth    :Tate Hanawalt(tate@tatehanawalt.com)
#date    :1621396284
#==============================================================================
class Demozsh < Formula

  bottle :unneeded                        # formula that can be installed without compilation
  depends_on "zsh" => :install            # dependencies
  desc "Brew install demozsh"             # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    puts "HEAD SECTION:"
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    puts "STABLE SECTION:"
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
    sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
  end

  def install
    puts "INSTALL SECTION:"
    cd "demozsh" do
      lib.install ["_demozsh", "demozsh.zsh", "doc/man/demozsh.1"]
    end
    zsh_completion.install lib/"_demozsh"
    bin.install lib/"demozsh.zsh" => "demozsh"
    man1.install lib/"demozsh.1"
  end

end

__END__
