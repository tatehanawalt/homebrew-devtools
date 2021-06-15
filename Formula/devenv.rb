#===============================================================================
# title   :devenv
# version :0.0.0
# desc    :Configure a dev environment
# auth    :Tate Hanawalt(tate@tatehanawalt.com)
# date    :1621730185
#===============================================================================
# usage   :brew tap tatehanawalt/devtools  && brew install devenv
#===============================================================================
class Devenv < Formula
  bottle :unneeded                        # formula that can be installed without compilation
  desc 'Brew install demozsh'             # formula description
  homepage 'https://www.TateHanawalt.com' # my website
  revision 0                              # force compile with no version changes
  version '0.0.0'                         # Formulae version
  head do
    url 'https://github.com/tatehanawalt/.th_sys.git', branch: 'main'
  end
  def install
    puts "install DEVENV brew formula install:\n"
    puts "name:         #{name}\n"
    puts "plist_name:   #{plist_name}\n"
    puts "plist_path:   #{plist_path}\n"
    puts "service_name: #{service_name}\n"
    puts "service_name: #{HOMEBREW_PREFIX}\n"
    cd @name do
      pkgshare.install "zprofile"
      pkgshare.install "styles.less"
      pkgshare.install "zshrc"
    end
  end
  def caveats
    <<~EOS
      To activate devtools, add the following:

        To ~/.zprofile:
        source #{HOMEBREW_PREFIX}/share/#{name}/zprofile

        To ~/.zshrc:
        source #{HOMEBREW_PREFIX}/share/#{name}/zshrc

    EOS
  end
  #  plist_options manual: "opensearch"
  #  service do
  #    run opt_bin/"opensearch"
  #    working_dir var
  #    log_path var/"log/opensearch.log"
  #    error_log_path var/"log/opensearch.log"
  #  end
  test do
    # (testpath/".zshrc").write "source #{HOMEBREW_PREFIX}/share/#{name}/#{name}.zsh\n"
    # system "zsh", "--login", "-i", "-c", "${#name} help"
  end
end
