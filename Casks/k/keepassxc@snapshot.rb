cask "keepassxc@snapshot" do
  version "2.8.0,257303"
  sha256 "e8070392a7ff782d6b6381f142004006f7855517ecde458fd022fffcd744d647"

  url "https://snapshot.keepassxc.org/build-#{version.csv.second}/KeePassXC-#{version.csv.first}-snapshot.dmg"
  name "KeePassXC"
  desc "Password manager app"
  homepage "https://keepassxc.org/"

  livecheck do
    url "https://snapshot.keepassxc.org/"
    regex(/href=.*?KeePassXC[._-]v?(\d+(?:\.\d+)+)-snapshot\.dmg/i)
    strategy :page_match do |page, regex|
      # Identify build numbers from directories like `build-123456`
      newest_build = page.scan(%r{href=["']?build[._-]v?(\d+(?:\.\d+)*)/?["' >]}i)
                         .flatten
                         .uniq
                         .max
      next if newest_build.blank?

      # Fetch the directory listing page for newest build
      build_response = Homebrew::Livecheck::Strategy.page_content("https://snapshot.keepassxc.org/build-#{newest_build}/")
      next if (build_page = build_response[:content]).blank?

      match = build_page.match(regex)
      next if match.blank?

      "#{match[1]},#{newest_build}"
    end
  end

  deprecate! date: "2025-05-01", because: :unsigned

  app "KeePassXC.app"
  binary "#{appdir}/KeePassXC.app/Contents/MacOS/keepassxc-cli"

  zap trash: "~/.keepassxc"

  caveats do
    requires_rosetta
  end
end
