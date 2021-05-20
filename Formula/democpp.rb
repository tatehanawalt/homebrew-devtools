#==============================================================================
# title   :democpp
# version :0.0.0
# desc    :C++ cli built as part of the homebrew demo/dev tools project
# usage   :See the repo README file for usage
# exit    :0=success, 1=input error 2=execution error
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
#==============================================================================
class Democpp < Formula
  depends_on "g++" => :install            # dependencies
  desc "Brew install democpp"             # formula description
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
    cd "democpp" do
      system "g++", "main.cpp", "-o", "democpp"
      lib.install ["democpp", "doc/man/democpp.1"]
    end
    bin.install_symlink lib/"democpp" => "democpp"
    man1.install lib/"democpp.1"
  end
end

__END__
