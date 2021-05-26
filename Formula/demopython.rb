# ==============================================================================
# title   :dempoython
# version :0.0.0
# desc    :python cli built as part of the homebrew demo/dev tools project
# auth    :Dan Henderson(dphender@mtu.edu), Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
# ==============================================================================
# exit    :0=success, 1=input error 2=execution error
# usage   :See the repo README file for usage
# ==============================================================================
# frozen_string_literal: true

# Demopython Formula - brew formula for an example python script
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
    url "https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/demopython.tar.gz", :using => :curl
    sha256 "2303c97efa30a663302153ff8c69e40cfbed7d5d86a8d7272580e105df1a3897"
  end
  def install
    if build.head?
      cd "demopython" do
        lib.install ["main.py", "doc/man/demopython.1"]
      end
    else
      lib.install ["main.py", "doc/man/demopython.1"]
    end
    bin.install lib/"main.py" => "demopython"
    man1.install lib/"demopython.1"
  end
end
