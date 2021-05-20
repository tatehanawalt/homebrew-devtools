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

  depends_on "go" => :build             # dependencies
  desc "Brew install demogolang"          # formula description
  homepage "https://www.TateHanawalt.com" # my website
  revision 0                              # force compile with no version changes
  version "0.0.0"                         # Formulae version

  head do
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  stable do
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.0/demogolang.tar.gz", :using => :curl
    sha256 "efee5e17d0f42b3fc5255c93e784cb9dee6efb03b17494f9a43172d1a2b34437"
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
