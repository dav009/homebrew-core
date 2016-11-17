class Tbb < Formula
  desc "Rich and complete approach to parallelism in C++"
  homepage "https://www.threadingbuildingblocks.org/"
  url "https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb2017_20161004oss_src.tgz"
  version "4.4-20161004"
  sha256 "f4ba7a7ed1bcb6c05d47e73624ca2e4580104bc0d3e0a3ccc7b67fa324760cb1"

  bottle do
    cellar :any
    sha256 "73c1cd36c36438422b4ef200d8928c2d22145bc17ec6b2548039d80ab6107dfe" => :sierra
    sha256 "6cb9dd98e549c62298aeadfca71acdaf487b03fcce9f51ad3955714b5017a79a" => :el_capitan
    sha256 "ede1550b833c4e2f9aad3d3d33edb07bbfea2dac58d0ef8237b5386c12cca11a" => :yosemite
  end

  option :cxx11

  # requires malloc features first introduced in Lion
  # https://github.com/Homebrew/homebrew/issues/32274
  depends_on :macos => :lion
  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "swig" => :build

  def install
    # Intel sets varying O levels on each compile command.
    ENV.no_optimization

    compiler = ENV.compiler == :clang ? "clang" : "gcc"
    args = %W[tbb_build_prefix=BUILDPREFIX compiler=#{compiler}]

    if build.cxx11?
      ENV.cxx11
      args << "cpp0x=1" << "stdlib=libc++"
    end

    system "make", *args
    lib.install Dir["build/BUILDPREFIX_release/*.dylib"]
    include.install "include/tbb"

    cd "python" do
      ENV["TBBROOT"] = prefix
      system "python", *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <tbb/task_scheduler_init.h>
      #include <iostream>

      int main()
      {
        std::cout << tbb::task_scheduler_init::default_num_threads();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-ltbb", "-o", "test"
    system "./test"
  end
end
