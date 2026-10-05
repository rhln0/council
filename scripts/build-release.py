from pathlib import Path
import hashlib, json
root = Path(__file__).resolve().parent.parent
files = sorted((root / "council").iterdir())
release = {"schema": 1, "version": json.loads((root / "council/manifest.json").read_text())["version"], "files": [{"path": f.name, "sha256": hashlib.sha256(f.read_bytes()).hexdigest()} for f in files if f.is_file()]}
(root / "update.json").write_text(json.dumps(release, indent=2))
