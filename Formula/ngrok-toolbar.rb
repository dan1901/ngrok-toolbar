class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "84002d6f5a3e5a4d33bb94e07196eafa45f1de8faf86a55d34c186cc646034c8"
  license "MIT"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "swift", "build", "-c", "release", "--disable-sandbox"

      # SPM outputs to .build/{arch}-apple-macosx/release/
      arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
      bin_path = ".build/#{arch}-apple-macosx/release"

      bin.install "#{bin_path}/NgrokTools" => "ngrok-toolbar"

      # Create app bundle
      app_dir = prefix/"NgrokToolbar.app"
      app_contents = app_dir/"Contents"
      (app_contents/"MacOS").mkpath
      (app_contents/"Resources").mkpath

      cp "#{bin_path}/NgrokTools", app_contents/"MacOS/NgrokTools"
      cp "Info.plist", app_contents/"Info.plist"

      if File.exist?("AppIcon.icns")
        cp "AppIcon.icns", app_contents/"Resources/AppIcon.icns"
      end

      # Resource bundle at .app/ root (where SPM's Bundle.module looks)
      resource_bundle = "#{bin_path}/NgrokTools_NgrokTools.bundle"
      if File.directory?(resource_bundle)
        cp_r resource_bundle, app_dir/"NgrokTools_NgrokTools.bundle"
      end
    end
  end

  def caveats
    <<~EOS
      To start ngrok-toolbar:
        open #{prefix}/NgrokToolbar.app

      Or run directly:
        ngrok-toolbar

      You need an ngrok API Key (not authtoken):
        https://dashboard.ngrok.com/api-keys
    EOS
  end

  test do
    assert_predicate bin/"ngrok-toolbar", :exist?
  end
end
