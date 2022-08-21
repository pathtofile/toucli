cask "toucli" do
    version "1.0"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    url "https://github.com/pathtofile/toucli/releases/download/v#{version}/toucli.zip"
    name "Toucli"
    desc "Use touchID and the Secure Enclave to encrypt data from the commandline"
    homepage "https://github.com/pathtofile/toucli"
  
    depends_on macos: ">= :big_sur"
  
    app "toucli.app"
  
  end
