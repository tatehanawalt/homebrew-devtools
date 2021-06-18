# ==============================================================================
# title   :demozsh
# version :0.0.0
# desc    :zsh cli built as part of the homebrew demo/dev tools project
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621396284
# ==============================================================================
# exit    :0=success, 1=input error 2=execution error
# usage   :See the repo README file for usage
# ==============================================================================
# frozen_string_literal: true

# Demozsh Formula - brew formula for an example zsh script
class Gaffer < Formula
  desc 'Brew install gaffer'
  homepage 'https://www.TateHanawalt.com'
  version '0.0.0'
  revision 0

  head do
    url 'https://github.com/tatehanawalt/.th_sys.git', branch: 'main'
  end

  bottle :unneeded

  def install_common
    zsh_completion.install '_gaffer'
    lib.install ['gaffer.zsh', 'config.zsh']
    bin.install_symlink lib/"gaffer.zsh" => "gaffer"
  end

  def install
    if build.head?
      cd 'gaffer' do
        install_common
      end
      return
    end
    install_common
  end

  test do
    assert true
  end
end
