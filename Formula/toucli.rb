cask "toucli" do
    version "0.0.1"
    sha256 "82307c6debf36e0619d46b4054c2be201a7d78ff98efdb3c4612bfb1d83b008f"

    url "https://github.com/pathtofile/toucli/releases/download/v#{version}/Toucli.zip"
    name "Toucli"
    desc "Use touchID and the Secure Enclave to encrypt data from the commandline"
    homepage "https://github.com/pathtofile/toucli"
  
    depends_on macos: ">= :big_sur"
  
    app "Toucli.app"
  
  end
