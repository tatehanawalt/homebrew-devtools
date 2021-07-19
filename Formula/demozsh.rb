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
class Demozsh < Formula
  desc 'Brew install demozsh'
  homepage 'https://www.TateHanawalt.com'
  version '0.0.0'
  revision 0

  stable do
    url 'https://github.com/tatehanawalt/th_sys/releases/download/0.0.4/demozsh.tar.gz', using: :curl
    sha256 'c4d93067c46d0c76a432f7b2d1880310467cc5314bfe694791e845ec2810af4d'
  end

  head do
    url 'https://github.com/tatehanawalt/.th_sys.git', branch: 'main'
  end

  bottle :unneeded

  def install_common
    zsh_completion.install '_demozsh'
    lib.install 'demozsh.zsh'
    bin.install_symlink lib/"demozsh.zsh" => "demozsh"
    man1.install 'doc/man/demozsh.1'
  end

  def install
    if build.head?
      cd 'demozsh' do
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
