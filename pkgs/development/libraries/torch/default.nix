{stdenv, fetchgit, luajit, openblas, imagemagick, cmake, curl, fftw, gnuplot
  , libjpeg, zeromq3, ncurses, openssl, libpng, qt4, readline, unzip
  , pkgconfig, zlib, libX11, which, fetchFromGitHub, git, hdf5
  , cudatoolkit, gcc5, withcuda
  }:
stdenv.mkDerivation rec{
  version = "0.0pre20160820";
  name = "torch-${version}";
  buildInputs = [
    luajit openblas imagemagick cmake curl fftw gnuplot unzip qt4
    libjpeg zeromq3 ncurses openssl libpng readline pkgconfig
    zlib libX11 which git hdf5 gcc5
  ] ++ (if withcuda then [ cudatoolkit ] else []);

  src = fetchgit {
    url = "https://github.com/torch/distro";
    rev = "0219027e6c4644a0ba5c5bf137c989a0a8c9e01b";
    sha256 = "1xcy6q1pkhzrrr44yc35wq53lwz09mvxk0fhcwjhjp671lzn98x6";
    fetchSubmodules = true;
  };

  torch_hdf5_src = fetchFromGitHub {
    owner = "deepmind";
    repo = "torch-hdf5";
    rev = "969ec7c5d004b8a5921168e80a845027a52ff123";
    sha256 = "15cf2km3ky0wj3n6r0z28w90aysj21i5w003bar0xsq6a2r2171f";
  };

  torchPath = "/home/olivier/torch";

  configurePhase = ":";

  buildCuda = if withcuda then "$out/bin/luarocks install cunn" else "";

  buildPhase = ''
    mkdir -p "$out"
    mkdir -p $out/torch_hdf5

    export PREFIX=$out
    sh install.sh -s

    export HOME=$TMP
    $buildCuda
    $out/bin/luarocks install totem
    $out/bin/luarocks install rnn

    cd $out/torch_hdf5
    cp -R $torch_hdf5_src/* $out/torch_hdf5
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
