{ pkgs 
}:

with pkgs;

mkShellNoCC {
  nativeBuildInputs = [
    nodejs-18_x
  ];
  shellHook = ''
    npm install
    npx playwright install
    export PATH="$PWD/node_modules/.bin/:$PATH"
  '';
}
