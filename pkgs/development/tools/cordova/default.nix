{ stdenv, lib, gnome2, fetchFromGitHub, pkgs, xlibs, udev, makeWrapper, makeDesktopItem, docker }:

stdenv.mkDerivation rec {
  name = "cordova-docker${version}";
  version = "2018-03-10";

  src = fetchFromGitHub {
    owner = "tinco";
    repo = "docker-cordova";
    rev = "5d8dc057b2df5fcb780d86bc4ea8b44754d7c95c";
    sha256 = "0b2bk1wywz7pzca4rgac5k3r25zgd3inf9p0862bkvwqhyj3s0bh";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ docker ];

  dontPatchELF = true;

  img = pkgs.dockerTools.buildImage {
    name = "docker-cordova";
    contents = [ pkgs.stdenv.shellPackage pkgs.coreutils ];
    config = {
      Env = [
        # When shell=true, mesos invokes "sh -c '<cmd>'", so make sure "sh" is
        # on the PATH.
        "PATH=${pkgs.stdenv.shellPackage}/bin:${pkgs.coreutils}/bin"
      ];
      Entrypoint = [ "echo" ];
    };
  };

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    echo "docker run --rm --device=/dev/bus/usb:/dev/bus/usb:rwm -v \$(realpath ~)/.android:/root/.android -v \$(pwd):/src xurei/docker-cordova:latest cordova --no-insight \"\$@\"" > $out/bin/cordova
    chmod a+x $out/bin/cordova
  '';

  meta = with stdenv.lib; {
    description = "Cordova (dockerized)";
    license = stdenv.lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ xurei ];
  };
}
