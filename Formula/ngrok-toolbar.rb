class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "a15a3405e37e6cf5de6b3c0e1409f08dc81d12747999cf87ac67b492ce28f6df"
  license "MIT"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "make", "install", "PREFIX=#{prefix}"
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
