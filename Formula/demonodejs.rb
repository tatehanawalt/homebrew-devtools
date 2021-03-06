#==============================================================================
# title   :demonodejs
# version :0.0.0
# desc    :nodejs cli built as part of the homebrew demo/dev tools project
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
#==============================================================================
# exit    :0=success, 1=input error 2=execution error
# usage   :See the repo README file for usage
#==============================================================================
class Demonodejs < Formula
  bottle :unneeded                        # formula that can be installed without compilation
  desc 'Brew install demonodejs'          # formula description
  homepage 'https://www.TateHanawalt.com' # my website
  revision 0                              # force compile with no version changes
  version '0.0.0'                         # Formulae version
  head do
    url 'https://github.com/tatehanawalt/.th_sys.git', branch: 'main'
  end
  stable do
    url 'https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/demonodejs.tar.gz', :using => :curl
    sha256 'c1a8326d00fc512ab2ed05958d87755e0d899979e3ece9110a0fd4143af1aaff'
  end
  def install
    if build.head?
      cd 'demonodejs' do
        lib.install ['main.js', 'doc/man/demonodejs.1']
      end
    else
      lib.install ['main.js', 'doc/man/demonodejs.1']
    end
    bin.install lib/'main.js' => 'demonodejs'
    man1.install lib/'demonodejs.1'
  end
end
