class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  license "MIT"

  # Update URL and sha256 when creating a new release
  # url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v0.1.0.tar.gz"
  # sha256 "UPDATE_WITH_ACTUAL_SHA256"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/NgrokTools" => "ngrok-toolbar"
    end

    # Install app bundle
    app_bundle = prefix/"NgrokToolbar.app/Contents"
    app_bundle.mkpath
    (app_bundle/"MacOS").install bin/"ngrok-toolbar" => "NgrokTools"
    (app_bundle/"..").install "NgrokTools/Info.plist" => "Contents/Info.plist"
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
