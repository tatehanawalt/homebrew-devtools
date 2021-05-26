#==============================================================================
# title   :democ
# version :0.0.0
# desc    :C cli built as part of the homebrew demo/dev tools project
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
#==============================================================================
# usage   :See the repo README file for usage
# exit    :0=success, 1=input error 2=execution error
#==============================================================================
class Democ < Formula
  depends_on "llvm" => :install           # dependencies
  desc "Brew install democ"               # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.4"                         # Formulae version
  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end
  stable do
    url "https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/democ.tar.gz", :using => :curl
    sha256 "e6631356c9d0b2c9873a4ef7fee6a265a566a2a90fe0ce903bb0e5fcd1408076"
  end
  def install
    if build.head?
        cd "democ" do
            system "clang", "main.c", "-o", "main"
            bin.install "main" => "democ"
            man1.install "doc/man/democ.1"
        end
        return
    end
    bin.install "main" => "democ"
    man1.install "doc/man/democ.1"
  end
end
