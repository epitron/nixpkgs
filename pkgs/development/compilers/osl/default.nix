{ clangStdenv, stdenv, fetchFromGitHub, cmake, zlib, openexr,
openimageio, llvm, boost165, flex, bison, partio, pugixml,
utillinux, python
}:

let boost_static = boost165.override { enableStatic = true; };
in clangStdenv.mkDerivation rec {
  # In theory this could use GCC + Clang rather than just Clang,
  # but https://github.com/NixOS/nixpkgs/issues/29877 stops this
  name = "openshadinglanguage-${version}";
  version = "1.10.5";

  src = fetchFromGitHub {
    owner = "imageworks";
    repo = "OpenShadingLanguage";
    rev = "Release-1.10.5";
    sha256 = "1g7izkjqb5xmp87k2aw0fgkxhcf7b9jn9hi60lwav3yhs50j8qsi";
  };

  cmakeFlags = [ "-DUSE_BOOST_WAVE=ON" "-DENABLERTTI=ON" ];
  enableParallelBuilding = true;

  preConfigure = '' patchShebangs src/liboslexec/serialize-bc.bash '';
  
  buildInputs = [
     cmake zlib openexr openimageio llvm
     boost_static flex bison partio pugixml
     utillinux # needed just for hexdump
     python # CMake doesn't check this?
  ];
  # TODO: How important is partio? CMake doesn't seem to find it
  meta = with stdenv.lib; {
    description = "Advanced shading language for production GI renderers";
    homepage = http://opensource.imageworks.com/?p=osl;
    maintainers = with maintainers; [ hodapp ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
