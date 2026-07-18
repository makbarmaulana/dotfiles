const fs = require('fs');
const os = require('os');
const { spawnSync } = require('child_process');

const envPath = os.homedir() + '/dotfiles/.secrets.env';
const env = { ...process.env };

if (fs.existsSync(envPath)) {
    const lines = fs.readFileSync(envPath, 'utf8').split('\n');
    for (const line of lines) {
        const match = line.match(/^\s*([^=#]+?)\s*=\s*(.*?)\s*$/);
        if (match) {
            let val = match[2];
            val = val.replace(/^['"]|['"]$/g, '');
            env[match[1]] = val;
        }
    }
}

const args = process.argv.slice(1);
if (args.length === 0) process.exit(0);

let cmd = args[0];
const cmdArgs = args.slice(1);

const options = { stdio: 'inherit', env };

if (process.platform === 'win32') {
    options.shell = true;
}

const result = spawnSync(cmd, cmdArgs, options);

if (result.error) {
    console.error(`Error spawning ${cmd}:`, result.error);
    process.exit(1);
}

process.exit(result.status !== null ? result.status : 1);
