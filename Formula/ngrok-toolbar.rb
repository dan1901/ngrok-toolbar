class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "b99745633cbc55b397b8607036abbb9b00c1d79b88da613732a56c21430a5b32"
  license "MIT"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/NgrokTools" => "ngrok-toolbar"

      # Install resource bundle
      resource_bundle = ".build/release/NgrokTools_NgrokTools.bundle"
      if File.directory?(resource_bundle)
        (lib/"NgrokTools_NgrokTools.bundle").install Dir["#{resource_bundle}/*"]
      end
    end

    # Create app bundle
    app_bundle = prefix/"NgrokToolbar.app/Contents"
    (app_bundle/"MacOS").mkpath
    (app_bundle/"Resources").mkpath
    cp bin/"ngrok-toolbar", app_bundle/"MacOS/NgrokTools"
    cp "NgrokTools/Info.plist", app_bundle/"Info.plist"

    # Copy icons
    if File.exist?("NgrokTools/AppIcon.icns")
      cp "NgrokTools/AppIcon.icns", app_bundle/"Resources/AppIcon.icns"
    end

    # Resource bundle must be at NgrokToolbar.app/ root (where Bundle.module looks)
    resource_bundle = "NgrokTools/.build/release/NgrokTools_NgrokTools.bundle"
    if File.directory?(resource_bundle)
      cp_r resource_bundle, prefix/"NgrokToolbar.app/"
    end

    system "codesign", "-s", "-", "-f", prefix/"NgrokToolbar.app"
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
