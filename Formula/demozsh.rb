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
  desc "Brew install demozsh"             # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.0/demozsh.tar.gz", :using => :curl
    sha256 "cbb19c8defe3d76cff134f43abe1385be3d494aa8fa8a6aa5e10fb59288db7f7"
  end

  def install
    if build.head?
      cd "demozsh" do
        lib.install ["_demozsh", "demozsh.zsh", "doc/man/demozsh.1"]
      end
    else
      lib.install ["_demozsh", "demozsh.zsh", "doc/man/demozsh.1"]
    end
    zsh_completion.install lib/"_demozsh"
    bin.install lib/"demozsh.zsh" => "demozsh"
    man1.install lib/"demozsh.1"
  end

end

__END__
