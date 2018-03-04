{stdenv, fetchgit, luajit, openblas, imagemagick, cmake, curl, fftw, gnuplot
  , libjpeg, zeromq3, ncurses, openssl, libpng, qt4, readline, unzip
  , pkgconfig, zlib, libX11, which, fetchFromGitHub, git, hdf5
  }:
stdenv.mkDerivation rec{
  version = "0.0pre20160820";
  name = "torch-${version}";
  buildInputs = [
    luajit openblas imagemagick cmake curl fftw gnuplot unzip qt4
    libjpeg zeromq3 ncurses openssl libpng readline pkgconfig
    zlib libX11 which git hdf5
  ];

  src = fetchgit {
    url = "https://github.com/torch/distro";
    rev = "8b6a834f8c8755f6f5f84ef9d8da9cfc79c5ce1f";
    sha256 = "120hnz82d7izinsmv5smyqww71dhpix23pm43s522dfcglpql8xy";
    fetchSubmodules = true;
  };

  torch_hdf5_src = fetchFromGitHub {
    owner = "deepmind";
    repo = "torch-hdf5";
    rev = "969ec7c5d004b8a5921168e80a845027a52ff123";
    sha256 = "15cf2km3ky0wj3n6r0z28w90aysj21i5w003bar0xsq6a2r2171f";
  };

  # unpackPhase = ''
  #   tar -xzf $src --strip-components=1
  #   tar -xzf $torch_hdf5_src --strip-components=1
  # '';

  buildPhase = ''
    cd ..
    export PREFIX=$out
    mkdir -p "$out"

    mkdir -p $out/torch_hdf5
    cp -R $torch_hdf5_src/* $out/torch_hdf5

    # sh install.sh -s
    cp -R -L /home/olivier/nix/nixpkgs/distro-8b6a834/install/* $out
    export HOME=$TMP
    $out/bin/luarocks install totem

    cd $out/torch_hdf5
    $out/bin/luarocks make hdf5-0-0.rockspec
  '';
  installPhase = ":";
  meta = {
    inherit version;
    description = ''A scientific computing framework with wide support for machine learning algorithms'';
    license = stdenv.lib.licenses.bsd3 ;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
