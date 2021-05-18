# demo1
# @author Tate W. Hanawalt - tate@tatehanawalt.com
#
# this is a demo brew formula in the tatehanawalt/devtools homebrew tap

class Demo2 < Formula

  version "0.0.0"
  desc "Brew install demo 2"
  homepage "https://www.TateHanawalt.com"

  # when version is static but formula needs recompiling for another reason. 0 is default & unwritten.
  revision 0

  # pass skip to disable post-install stdlib checking
  cxxstdlib_check :skip

  stable do # brew install demo2
    puts "\nSTABLE SECTION:"
    url "https://github.com/tatehanawalt/.th_sys/releases/download/0.0.1/0.0.1.tar.gz", :using => :curl
    sha256 "c294de88385e86260a6f858219aeb10038e460ebe713f98a44bd5f916b1cf2bf"
  end

  head do # brew install --HEAD demo2
    puts "\nHEAD SECTION:"
    url "https://github.com/tatehanawalt/.th_sys.git", branch: "main"
  end

  depends_on "go" => :build

  on_linux do
    puts "\nON_LINUX SECTION:"
  end

  on_macos do
    puts "\nON_MACOS SECTION:"
  end

  def install
    puts "\nINSTALL SECTION:"
    # lib.install Dir["demo2/*"]
    cd "demo2" do
      system "go", "build", "-ldflags", "-s -w -X 'main.Version=#{version}'"
      lib.install ["demo2"]
    end

    bin.install_symlink lib/"demo2" => "demo2"
  end
end

__END__
