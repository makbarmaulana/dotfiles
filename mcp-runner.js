const fs = require('fs');
const os = require('os');
const { spawnSync } = require('child_process');

// Path cross-platform ke .secrets.env di dalam folder dotfiles
const envPath = os.homedir() + '/dotfiles/.secrets.env';
const env = { ...process.env };

// Load environment variables dari .secrets.env jika filenya ada
if (fs.existsSync(envPath)) {
    const lines = fs.readFileSync(envPath, 'utf8').split('\n');
    for (const line of lines) {
        const match = line.match(/^\s*([^=#]+?)\s*=\s*(.*?)\s*$/);
        if (match) {
            let val = match[2];
            // Hapus quotes jika ada
            val = val.replace(/^['"]|['"]$/g, '');
            env[match[1]] = val;
        }
    }
}

// Ambil perintah yang akan dijalankan
const args = process.argv.slice(1); // karena ini di-require via eval, argument yang masuk setelahnya
if (args.length === 0) process.exit(0);

const cmd = args[0];
const cmdArgs = args.slice(1);

// Jalankan perintah dengan environment variables yang sudah digabung
const result = spawnSync(cmd, cmdArgs, { stdio: 'inherit', env });
process.exit(result.status || 0);
