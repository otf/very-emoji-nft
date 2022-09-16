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
    npx playwright install-deps
    export PATH="$PWD/node_modules/.bin/:$PATH"
  '';
}
