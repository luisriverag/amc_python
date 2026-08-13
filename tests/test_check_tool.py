import importlib.util
from pathlib import Path


SPEC = importlib.util.spec_from_file_location("check", Path("tools/check.py"))
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_check_tool_runs_documented_checks_in_order(monkeypatch):
    calls = []

    def record(command, *, environment=None):
        calls.append((command, environment))

    monkeypatch.setattr(MODULE, "run", record)
    assert MODULE.main() == 0
    assert calls[0][0][1:] == ["-m", "pytest", "-q"]
    assert calls[1][0][1:] == ["-m", "compileall", "-q", "src", "tests", "tools"]
    assert calls[2][0][1:] == ["tools/validate_fixtures.py"]
    assert calls[3][0][1:] == ["-m", "amc.cli", "--help"]
    assert calls[3][1]["PYTHONPATH"].split(MODULE.os.pathsep)[0] == str(MODULE.ROOT / "src")
    assert calls[4][0] == ["git", "diff", "--check"]
    assert calls[5][0] == ["git", "diff", "--cached", "--check"]
