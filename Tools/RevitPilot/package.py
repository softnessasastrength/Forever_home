"""Package an already validated local pilot run for manual review elsewhere."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path


def package(run, output):
    run = run.resolve()
    manifest = json.loads((run / 'manifest.json').read_text(encoding='utf-8'))
    if not all(manifest['checks'].values()):
        raise ValueError('Implemented validation checks must pass before packaging')
    files = []
    for item in manifest['files']:
        path = (run / item['path']).resolve()
        if not path.is_relative_to(run):
            raise ValueError('Manifest path leaves run directory')
        if hashlib.sha256(path.read_bytes()).hexdigest() != item['sha256']:
            raise ValueError('Artifact changed since validation: ' + item['path'])
        files.append((path, item['path']))
    # Exclusive creation preserves any earlier review package.
    with zipfile.ZipFile(output, 'x', compression=zipfile.ZIP_DEFLATED) as archive:
        for path, name in files:
            archive.write(path, name)
        archive.write(run / 'manifest.json', 'manifest.json')
        archive.write(Path(__file__).with_name('2018_REVIEW.md'), 'START_HERE.md')
    with zipfile.ZipFile(output) as archive:
        if archive.testzip() is not None:
            raise ValueError('ZIP CRC validation failed')
    print(json.dumps({'package': output.name, 'bytes': output.stat().st_size,
                      'sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
                      'crc_check': 'pass', 'revit_2018': 'not tested'}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('run_folder', type=Path)
    parser.add_argument('output_zip', type=Path)
    args = parser.parse_args()
    package(args.run_folder, args.output_zip)
