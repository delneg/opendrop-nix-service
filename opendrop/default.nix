{ lib, python3Packages, libarchive, openssl }:
with python3Packages;
buildPythonApplication rec {
  pname = "opendrop";
  version = "0.13.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FE1oGpL6C9iBhI8Zj71Pm9qkObJvSeU2gaBZwK1bTQc=";
  };

  buildInputs = [ libarchive openssl ];
  propagatedBuildInputs = [ setuptools requests zeroconf pillow requests-toolbelt libarchive-c (callPackage ./fleep.nix { }) ];

  preConfigure = ''
    substituteInPlace opendrop/config.py --replace '"openssl"' '"${openssl}/bin/openssl"'
  '';

  doCheck = false;

  meta = with lib; {
    description = "An open Apple AirDrop implementation written in Python";
    homepage = "https://owlink.org/";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}