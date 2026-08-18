import importlib.util
from pathlib import Path
import tarfile


SPEC = importlib.util.spec_from_file_location(
    "check_package", Path("tools/check_package.py")
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_environment_python_uses_platform_layout(monkeypatch, tmp_path):
    monkeypatch.setattr(MODULE.os, "name", "nt")
    assert MODULE.environment_python(tmp_path) == tmp_path / "Scripts" / "python.exe"
    monkeypatch.setattr(MODULE.os, "name", "posix")
    assert MODULE.environment_python(tmp_path) == tmp_path / "bin" / "python"


def test_environment_script_uses_platform_layout(monkeypatch, tmp_path):
    monkeypatch.setattr(MODULE.os, "name", "nt")
    assert MODULE.environment_script(tmp_path, "amc") == tmp_path / "Scripts" / "amc.exe"
    monkeypatch.setattr(MODULE.os, "name", "posix")
    assert MODULE.environment_script(tmp_path, "amc") == tmp_path / "bin" / "amc"


def test_package_check_builds_installs_and_smoke_tests(monkeypatch, tmp_path):
    calls = []
    output_calls = []

    class TemporaryDirectory:
        def __init__(self, **_kwargs):
            pass

        def __enter__(self):
            return str(tmp_path)

        def __exit__(self, *_args):
            return False

    class Builder:
        def __init__(self, *, with_pip):
            assert with_pip is True

        def create(self, environment):
            (environment / "bin").mkdir(parents=True)

    def record(command, *, environment=None):
        calls.append((command, environment))
        if command[1:4] == ["-m", "build", "--sdist"]:
            dist = tmp_path / "dist"
            dist.mkdir()
            with tarfile.open(dist / "amc_python-0.1.0.tar.gz", "w:gz") as archive:
                for name in ("LICENSE", "README.md", "pyproject.toml", "src/amc/model.py"):
                    source = tmp_path / name.replace("/", "_")
                    source.write_text(name, encoding="utf-8")
                    archive.add(source, arcname=f"amc_python-0.1.0/{name}")
        if command[1:4] == ["-m", "pip", "wheel"]:
            (tmp_path / "wheelhouse" / "amc_python-0.1.0-py3-none-any.whl").touch()

    def record_output(command, expected, *, environment=None):
        output_calls.append((command, expected, environment))

    monkeypatch.setattr(MODULE.tempfile, "TemporaryDirectory", TemporaryDirectory)
    monkeypatch.setattr(MODULE.venv, "EnvBuilder", Builder)
    monkeypatch.setattr(MODULE, "run", record)
    monkeypatch.setattr(MODULE, "run_with_output", record_output)
    monkeypatch.setattr(MODULE.os, "name", "posix")
    monkeypatch.setenv("PYTHONPATH", "should-not-leak")

    assert MODULE.main() == 0
    assert calls[0][0][1:4] == ["-m", "build", "--sdist"]
    assert calls[1][0][1:4] == ["-m", "pip", "wheel"]
    assert calls[2][0][1:4] == ["-m", "pip", "install"]
    assert "--no-deps" not in calls[2][0]
    assert calls[3][0][1:] == ["-m", "amc.cli", "--help"]
    assert "PYTHONPATH" not in calls[3][1]
    assert calls[4][0][-1] == "--help"
    assert calls[4][0][0].endswith("/venv/bin/amc")
    assert "PYTHONPATH" not in calls[4][1]
    assert calls[5][0][-1] == "import tkinter; import amc.gui"
    assert "amc-gui" in calls[6][0][-1]
    assert calls[7][0][0].endswith("/venv/bin/amc-gui")
    assert calls[7][0][-1] == "--help"
    assert calls[8][0][0].endswith("/venv/bin/amc-web")
    assert calls[8][0][-1] == "--help"
    assert all("PYTHONPATH" not in environment for _, environment in calls[3:])
    assert output_calls[0][0][-2:] == ["list", "--json"]
    assert output_calls[0][1] == "[]\n"
    assert "PYTHONPATH" not in output_calls[0][2]


def test_run_with_output_rejects_unexpected_stdout(monkeypatch):
    class Result:
        stdout = "wrong\n"

    monkeypatch.setattr(MODULE.subprocess, "run", lambda *_args, **_kwargs: Result())
    try:
        MODULE.run_with_output(["amc", "list", "--json"], "[]\n")
    except RuntimeError as error:
        assert "unexpected output" in str(error)
    else:
        raise AssertionError("package check accepted unexpected console output")


def test_validate_sdist_rejects_historical_evidence(tmp_path):
    archive = tmp_path / "amc_python-0.1.0.tar.gz"
    source = tmp_path / "evidence.pas"
    source.write_text("unit Evidence;", encoding="utf-8")
    with tarfile.open(archive, "w:gz") as stream:
        stream.add(
            source,
            arcname="amc_python-0.1.0/src/original/Common/evidence.pas",
        )

    try:
        MODULE.validate_sdist(archive)
    except RuntimeError as error:
        assert "historical evidence" in str(error)
    else:
        raise AssertionError("package check accepted historical evidence")
