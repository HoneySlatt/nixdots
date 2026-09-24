{ claudeDesktop, nodejs }:

claudeDesktop.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ nodejs ];

  postInstall = (old.postInstall or "") + ''
    themeRoot="$TMPDIR/claude-quickshell"
    asar extract "$out/lib/claude-desktop/resources/app.asar" "$themeRoot"
    cp ${./claude-desktop-theme.cjs} "$themeRoot/quickshell-theme.cjs"

    node - "$themeRoot" <<'JS'
    const fs = require('fs');
    const path = require('path');
    const root = process.argv[2];
    const manifestPath = path.join(root, 'package.json');
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    if (!manifest.main || !fs.existsSync(path.join(root, manifest.main))) {
      throw new Error('Claude Desktop entry point not found');
    }
    fs.writeFileSync(path.join(root, 'quickshell-entry.cjs'),
      'require("./quickshell-theme.cjs");\nrequire(' +
      JSON.stringify('./' + manifest.main) + ');\n');
    manifest.main = 'quickshell-entry.cjs';
    fs.writeFileSync(manifestPath, JSON.stringify(manifest));
    JS

    asar pack --unpack "*.node" "$themeRoot" "$out/lib/claude-desktop/resources/app.asar"
  '';
})
