"""Exercise the real shell installer against local release fixtures, without network or launch."""
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'dist/Habibi-Pet-Bot.app'
ASSET = 'Habibi-Pet-Bot-1.0.0-universal.zip'


@unittest.skipUnless(os.uname().sysname == 'Darwin', 'macOS installer')
class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.destination = self.base / 'Applications'
        self.env = dict(os.environ, PATH=str(self.bin) + ':' + os.environ['PATH'],
                        HABIBI_TEST_FIXTURES=str(self.base))
        subprocess.run(['ditto', '-c', '-k', '--keepParent', str(APP), str(self.base / ASSET)], check=True)
        checksum = hashlib.sha256((self.base / ASSET).read_bytes()).hexdigest()
        (self.base / 'SHA256SUMS.txt').write_text(f'{checksum}  {ASSET}\n')
        self.command('pgrep', '#!/bin/sh\nexit 1\n')
        self.command('curl', '''#!/usr/bin/env python3
import os, pathlib, shutil, sys
args=sys.argv[1:]
base=pathlib.Path(os.environ['HABIBI_TEST_FIXTURES'])
url=next(x for x in args if x.startswith('https://'))
output=pathlib.Path(args[args.index('-o')+1])
if os.environ.get('HABIBI_TEST_404') and url.endswith('SHA256SUMS.txt'):
    output.write_text('Not Found')
    print('404', end='')
else:
    name='source.tar.gz' if url.endswith('.tar.gz') else url.rsplit('/',1)[-1]
    shutil.copyfile(base/name, output)
    if '-w' in args: print('200', end='')
''')

    def command(self, name, text):
        path = self.bin / name
        path.write_text(text)
        path.chmod(0o755)

    def run_installer(self, *args):
        return subprocess.run(['bash', str(ROOT / 'install.sh'), '--app-dir', str(self.destination),
                               '--no-open', *args], env=self.env, text=True, capture_output=True, timeout=30)

    def test_release_installs_verified_app(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        installed = self.destination / 'Habibi-Pet-Bot.app'
        self.assertTrue(installed.is_dir())
        subprocess.run(['codesign', '--verify', '--strict', str(installed)], check=True)
        self.assertEqual(list(self.destination.glob('.habibi-stage.*')), [])

    def test_checksum_failure_preserves_existing_installation(self):
        old = self.destination / 'Habibi-Pet-Bot.app'
        old.mkdir(parents=True)
        (old / 'sentinel').write_text('original')
        (self.base / ASSET).write_bytes(b'corrupt download')
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Checksum verification failed', result.stderr)
        self.assertEqual((old / 'sentinel').read_text(), 'original')

    def test_unsafe_manifest_name_is_rejected(self):
        (self.base / 'SHA256SUMS.txt').write_text('a' * 64 + '  ../outside.zip\n')
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Invalid release checksum', result.stderr)
        self.assertFalse(self.destination.exists())

    def test_missing_pinned_version_does_not_fall_back(self):
        self.env['HABIBI_TEST_404'] = '1'
        result = self.run_installer('--version', '9.9.9')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Release unavailable', result.stderr)
        self.assertFalse(self.destination.exists())

    def test_linux_gets_clear_platform_message(self):
        self.command('uname', '#!/bin/sh\necho Linux\n')
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Linux, WSL, and Windows are not supported', result.stderr)

    def test_no_release_falls_back_to_local_source_build(self):
        source = self.base / 'source-fixture'
        (source / 'dist').mkdir(parents=True)
        subprocess.run(['ditto', str(APP), str(source / 'dist/Habibi-Pet-Bot.app')], check=True)
        (source / 'build.sh').write_text('#!/bin/zsh\nexit 0\n')
        subprocess.run(['tar', '-czf', str(self.base / 'source.tar.gz'), '-C', str(self.base), 'source-fixture'], check=True)
        self.env['HABIBI_TEST_404'] = '1'
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Building locally from source', result.stdout)
        self.assertTrue((self.destination / 'Habibi-Pet-Bot.app').is_dir())


if __name__ == '__main__':
    unittest.main()
