import hashlib
import importlib.util
import json
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


SPEC = importlib.util.spec_from_file_location("acquire_upstream", Path("tools/acquire_upstream.py"))
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_download_streams_archive_and_records_provenance(tmp_path: Path):
    payload = b"Rar! synthetic test payload"

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(payload)

        def log_message(self, *_args):
            pass

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever)
    thread.start()
    try:
        destination = tmp_path / "source.rar"
        result = MODULE.download(f"http://127.0.0.1:{server.server_port}/source.rar", destination)
    finally:
        server.shutdown()
        thread.join()
        server.server_close()

    assert destination.read_bytes() == payload
    assert result["size"] == len(payload)
    assert result["sha256"] == hashlib.sha256(payload).hexdigest()
    assert not (tmp_path / "source.rar.part").exists()


def test_inventory_is_sorted_and_content_addressed(tmp_path: Path):
    (tmp_path / "z.pas").write_text("unit Z;", encoding="utf-8")
    (tmp_path / "dir").mkdir()
    (tmp_path / "dir" / "a.dfm").write_text("object A", encoding="utf-8")
    entries = MODULE.inventory(tmp_path)
    assert [entry["path"] for entry in entries] == ["dir/a.dfm", "z.pas"]
    assert all(len(entry["sha256"]) == 64 for entry in entries)


def test_main_writes_machine_readable_archive_metadata(tmp_path: Path):
    source = tmp_path / "source.rar"
    source.write_bytes(b"archive")
    metadata = tmp_path / "archive.json"
    assert MODULE.main(["--url", source.as_uri(), "--output", str(tmp_path / "copy.rar"), "--metadata", str(metadata)]) == 0
    document = json.loads(metadata.read_text(encoding="utf-8"))
    assert document["url"] == source.as_uri()
    assert document["archive"] == "copy.rar"
