#==============================================================================
# title   :demogolang
# version :0.0.0
# desc    :golang cli built as part of the homebrew demo/dev tools project
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
#==============================================================================
# exit    :0=success, 1=input error 2=execution error
# usage   :See the repo README file for usage
#==============================================================================
class Demogolang < Formula
  depends_on "go" => :build # dependencies
  desc "Brew install demogolang"          # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    url "https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/demogolang.tar.gz", :using => :curl
    sha256 "6b159cbe3b15b4332708f8b65738ed2825f6c4ad31ab04e3bc3f9f334a7704ca"
  end

  def install
    if build.head?
      cd "demogolang" do
        system "go", "build", "-ldflags", "-s -w -X main.Version=#{version}"
        lib.install ["demogolang", "doc/man/demogolang.1", "go.mod"]
      end
    else
      # We don't need the go.mod here because we are installing a pre-compiled distribution
      lib.install ["demogolang", "doc/man/demogolang.1"]
    end
    bin.install_symlink lib/"demogolang" => "demogolang"
    man1.install lib/"demogolang.1"
  end
end

__END__
