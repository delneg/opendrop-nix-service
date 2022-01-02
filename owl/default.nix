{ stdenv, lib, fetchFromGitHub, cmake, libev, libnl, libpcap }:

stdenv.mkDerivation rec {
  pname = "owl";
  version = "unstable-2022-01-03";

  src = fetchFromGitHub {
    owner = "seemoo-lab";
    repo = "owl";
    rev = "fb09463f6a3d175c125165b89ec39a25b33e14b1";
    sha256 = "sha256-QSwCxpqp9CyB/MPstgtYr73/STHbcljiCpozhzgzAvA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libev libnl libpcap ];

  meta = with lib; {
    description = "An open Apple Wireless Direct Link (AWDL) implementation written in C";
    homepage = "https://owlink.org/";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}