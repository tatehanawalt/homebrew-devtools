#==============================================================================
# title   :democpp
# desc    :C++ cli built as part of the homebrew demo/dev tools project
# version :0.0.0
# date    :1621396284
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
#==============================================================================
# exit    :0=success, 1=input error 2=execution error
# usage   :See the repo README file for usage
#==============================================================================
class Democpp < Formula
  depends_on "gcc" => :install            # dependencies
  desc "Brew install democpp"             # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    url "https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/democpp.tar.gz", :using => :curl
    sha256 "2719c4a119584c0de398fc6408d1813473b6e436da9d7b706446a5b37dc96857"
  end

  def install
      if build.head?
          system "g++", "main.cpp", "-o", "main"
      end
      lib.install ["main", "doc/man/democpp.1"]
      bin.install_symlink lib/"main" => "democpp"
      man1.install lib/"democpp.1"
  end
end

__END__
