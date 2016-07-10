var cmd = process.argv[2],
    output = process.argv[3],
    input = process.argv[4];

var result = require('child_process').spawnSync(cmd, ['-', output, '--no-color', '--strict-math=on', '--silent'], { input: input });
if (result.status) {
  require('fs').writeFileSync(output+'.errorlog', result.stderr);
  process.exit(result.status);
}