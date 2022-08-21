cask "toucli" do
    version "1.0"
    sha256 "9f544ce9d9f3100054745377759303213744b5ed9e7940d956efed3724696868"
  
    url "https://github.com/pathtofile/toucli/releases/download/v#{version}/toucli.zip"
    name "toucli"
    desc "Use touchID and the Secure Enclave to encrypt data from the commandline"
    homepage "https://github.com/pathtofile/toucli"
  
    depends_on macos: ">= :big_sur"
    app "toucli.app"
  end
