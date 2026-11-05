"""Rebuild all bundled GLSL sources and record tool version plus content hashes."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(__doc__)
parser.add_argument('--qsb', default=shutil.which('qsb'))
args = parser.parse_args()
if not args.qsb:
    parser.error('Pass --qsb PATH to Qt Shader Tools 6.11.0 qsb executable')
qsb = str(Path(args.qsb).resolve())
version = subprocess.check_output([qsb, '--version'], text=True).strip()
flags = ['--glsl', '100 es,120,150', '--hlsl', '50', '--msl', '12']
manifest = {'tool': version, 'flags': flags, 'source_hash_normalization': 'LF', 'files': {}}
for folder in ('qml', 'examples/glass_lab'):
    for source in sorted((ROOT / folder).glob('*.frag')):
        output = source.with_suffix(source.suffix + '.qsb')
        subprocess.run([qsb, *flags, '-o', output.name, source.name], cwd=source.parent, check=True)
        manifest['files'][source.relative_to(ROOT).as_posix()] = {
            'source_sha256': hashlib.sha256(source.read_bytes().replace(b'\r\n', b'\n')).hexdigest(),
            'qsb_sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
        }
(ROOT / 'docs/shader-build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
print(json.dumps(manifest, indent=2))
