cask "habibi-pet-bot" do
  version :latest
  sha256 :no_check

  url "https://github.com/AKA-Muhannad/Habibi-Pet-Bot/releases/latest/download/Habibi-Pet-Bot-universal.zip"
  name "Habibi-Pet-Bot"
  desc "Animated desktop companion for Claude Code and Apple Intelligence"
  homepage "https://github.com/AKA-Muhannad/Habibi-Pet-Bot"

  depends_on macos: ">= :ventura"

  app "Habibi-Pet-Bot.app"

  caveats <<~EOS
    Requires a published GitHub release. Check its signing status before installing.
    Install Claude Code separately. Apple Intelligence requires compatible hardware.
    To update this latest-version cask: brew reinstall --cask aka-muhannad/habibi-pet-bot/habibi-pet-bot
  EOS
end
