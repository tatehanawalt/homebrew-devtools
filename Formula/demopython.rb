#==============================================================================
#title   :dempoython
#version :0.0.0
#desc    :python cli built as part of the homebrew demo/dev tools project
#usage   :See the repo README file for usage
#exit    :0=success, 1=input error 2=execution error
#auth    :Dan Henderson(dphender@mtu.edu), Tate Hanawalt(tate@tatehanawalt.com)
#date    :1621396284
#==============================================================================
class Demopython < Formula

  bottle :unneeded                        # formula installed without compilation
  desc "Brew install demopython"          # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.0/demopython.tar.gz", :using => :curl
    sha256 "cbb19c8defe3d76cff134f43abe1385be3d494aa8fa8a6aa5e10fb59288db7f7"
  end

  def install
    if build.head?
      cd "demopython" do
        lib.install ["main.py"]
      end
    else
      lib.install ["main.py"]
    end
    bin.install_symlink lib/"main.py" => "demopython"
  end
end

__END__
