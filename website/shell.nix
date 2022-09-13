{ pkgs 
}:

with pkgs;

mkShellNoCC {
  nativeBuildInputs = [
    nodejs-18_x
    elmPackages.elm
  ];
  shellHook = ''
    npm install
    export PATH="$PWD/node_modules/.bin/:$PATH"
  '';
}
