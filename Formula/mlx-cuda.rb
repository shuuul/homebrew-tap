class MlxCuda < Formula
  desc "MLX array framework C++ library with the CUDA backend (Linux)"
  homepage "https://github.com/ml-explore/mlx"
  # The source tarball pins the version and license; the install uses MLX's
  # official mlx-cuda-13 wheel (prebuilt libmlx.so, headers, vendored
  # BLAS/LAPACK) so the CUDA kernels are not rebuilt here. Keep the version
  # in lockstep with homebrew-core's macOS `mlx`.
  url "https://github.com/ml-explore/mlx/archive/refs/tags/v0.32.4.tar.gz"
  sha256 "0276db8d7bf1af8db6d4ae25c7c550abea4d5b3b6a16207610a5d4a0c19fe1a0"
  license "MIT"

  livecheck do
    formula "mlx"
  end

  depends_on "patchelf" => :build
  depends_on "unzip" => :build
  depends_on :linux

  resource "mlx-cuda-13" do
    on_arm do
      url "https://files.pythonhosted.org/packages/01/3f/69bda81076a5c41c549a641f50ec6b2cee5541aec77b9d3df1c7a5d1ff13/mlx_cuda_13-0.32.4-py3-none-manylinux_2_35_aarch64.whl"
      sha256 "cf8a67b49cebff85cd98b1d118c09f6c8ee966b899a914c50cc74d614b25616e"
    end
    on_intel do
      url "https://files.pythonhosted.org/packages/04/71/6aa03c097939a45ac7bafc5deec3c6429d5272af5a817228bff35ad73f35/mlx_cuda_13-0.32.4-py3-none-manylinux_2_35_x86_64.whl"
      sha256 "94cb48fba73e5ee39467e51c35c51c691123359ca17bafd1a24cf92ad6732bee"
    end
  end

  def install
    # A .whl is a zip, but Homebrew does not unpack it by extension.
    system "unzip", "-q", resource("mlx-cuda-13").cached_download, "-d", "wheel"
    cd "wheel" do
      include.install Dir["mlx/include/*"]
      share.install Dir["mlx/share/*"]
      lib.install "mlx/lib/libmlx.so"
      lib.install Dir["mlx_cuda_13.libs/*"]
      # The wheel's rpath points into site-packages (nvidia/* wheels and
      # mlx_cuda_13.libs). Here the vendored libs sit next to libmlx.so and the
      # CUDA libraries come from the system loader path.
      system "patchelf", "--set-rpath", "$ORIGIN", lib/"libmlx.so"
    end
  end

  def caveats
    <<~EOS
      libmlx.so loads the system NVIDIA stack, which Homebrew does not provide:
      the NVIDIA driver (libcuda.so.1), CUDA 13 (cuBLAS, cuFFT, cuSOLVER,
      NVRTC and the toolkit headers), cuDNN 9 and NCCL 2, all on the dynamic
      loader path (ld.so.conf). MLX's CUDA JIT finds the headers through
      CUDA_HOME or CUDA_PATH, else /usr/local/cuda.
    EOS
  end

  test do
    # Links and loads libmlx.so without touching the GPU: Homebrew's test
    # sandbox hides the NVIDIA device nodes, and every mlx array (even on the
    # CPU device) allocates through cudaMallocManaged.
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include "mlx/version.h"
      int main() {
        std::cout << mlx::core::version() << std::endl;
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++20", "test.cpp", "-I#{include}", "-L#{lib}", "-lmlx",
           "-Wl,-rpath,#{lib}", "-o", "test"
    assert_equal version.to_s, shell_output("./test").strip
  end
end
