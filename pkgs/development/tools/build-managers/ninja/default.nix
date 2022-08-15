{ lib, stdenv, fetchFromGitHub, fetchpatch, python3, buildDocs ? true, asciidoc, docbook_xml_dtd_45, docbook_xsl, libxslt, re2c }:

with lib;

stdenv.mkDerivation rec {
  pname = "ninja";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "ninja-build";
    repo = "ninja";
    rev = "v${version}";
    sha256 = "sha256-xZwMdwvg29lauHKk9M318Vz7pXZFhf3kFcyOTBdjmJM=";
  };

  nativeBuildInputs = [ python3 re2c ] ++ optionals buildDocs [ asciidoc docbook_xml_dtd_45 docbook_xsl libxslt.bin ];

  buildPhase = ''
    python configure.py --bootstrap
  '' + optionalString buildDocs ''
    # "./ninja -vn manual" output copied here to support cross compilation.
    asciidoc -b docbook -d book -o build/manual.xml doc/manual.asciidoc
    xsltproc --nonet doc/docbook.xsl build/manual.xml > doc/manual.html
  '';

  installPhase = ''
    install -Dm555 -t $out/bin ninja
    install -Dm444 misc/bash-completion $out/share/bash-completion/completions/ninja
    install -Dm444 misc/zsh-completion $out/share/zsh/site-functions/_ninja
  '' + optionalString buildDocs ''
    install -Dm444 -t $out/share/doc/ninja doc/manual.asciidoc doc/manual.html
  '';

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Small build system with a focus on speed";
    longDescription = ''
      Ninja is a small build system with a focus on speed. It differs from
      other build systems in two major respects: it is designed to have its
      input files generated by a higher-level build system, and it is designed
      to run builds as fast as possible.
    '';
    homepage = "https://ninja-build.org/";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice bjornfor orivej ];
  };
}
