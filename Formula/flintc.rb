require "language/node"

class MonoRequirement < Requirement
  fatal true

  satisfy(:build_env => false) { which("mono") }

  def message; <<~EOS
    mono is required; install it via:
      brew cask install mono-mdk
    EOS
  end
end

class Flintc < Formula
    desc "Flint is a new type-safe, contract-oriented programming language specifically designed for writing robust smart contracts on Ethereum."
    homepage "http://docs.flintlang.org"
    head "https://github.com/noellee/flint.git", :branch => "dev"
    version "0.1"

    depends_on MonoRequirement
    depends_on "node"
    depends_on "kylef/formulae/swiftenv"
    depends_on "z3"
    depends_on "wget"

    def install
      Language::Node.local_npm_install_args
      system "swiftenv init -"
      system "swiftenv rehash"
      ENV["PATH"] = "#{ENV["HOME"]}/.swiftenv/shims:#{ENV["PATH"]}"
      if not `swiftenv versions`.split.include? "5.0.2"
        system "swiftenv", "install", "--user", "5.0.2"
      end
      system "swift", "--version"
      system "make", "release", "BUILD_FLAGS=--product flintc --disable-sandbox"
      libexec.install Dir[".build/release/*"]
      bin.install_symlink libexec/"flintc"
    end

    test do
      system "#{bin}/flintc", "--help"
    end
  end