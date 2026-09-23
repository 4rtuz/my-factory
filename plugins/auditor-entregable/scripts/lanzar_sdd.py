"""Lanza una sesión `claude -p "/sdd-spec-writer:sdd ..."` por cada petición pendiente de huecos.json.

Uso: python lanzar_sdd.py <repo> <huecos.json>

Secuencial a propósito: spec-writer numera las specs leyendo docs/specs/, y dos sesiones
en paralelo tomarían el mismo NNNN. Escribe un log por petición y resultado.json al lado de huecos.json.
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

TIMEOUT_S = 45 * 60
SDD = ("sdd-spec-writer", "spec-tools", "spec-validators")


def plugin_dirs() -> list[str]:
    """--plugin-dir para los plugins SDD hermanos, si este plugin se carga desde el repo my-factory.

    Instalado desde el marketplace no hay hermanos y la sesión hija usa los plugins instalados.
    """
    raiz = Path(__file__).resolve().parents[2]
    return [a for n in SDD if (raiz / n / ".claude-plugin").is_dir() for a in ("--plugin-dir", str(raiz / n))]


def pendientes(huecos: dict) -> list[dict]:
    return [p for p in huecos.get("peticiones", []) if not p.get("spec_existente")]


def main() -> int:
    repo, fichero = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    huecos = json.loads(fichero.read_text(encoding="utf-8"))
    claude = shutil.which("claude")
    if not claude:
        print("claude no está en el PATH", file=sys.stderr)
        return 2

    # Sin CLAUDECODE la sesión hija no se cree anidada; sin NOVELA_SESSION_ID el hook
    # de story-maker no le aplica las reglas del bucle (que vetan subagentes ajenos).
    env = {k: v for k, v in os.environ.items() if k not in ("CLAUDECODE", "NOVELA_SESSION_ID")}
    logs = fichero.parent / "sesiones"
    logs.mkdir(exist_ok=True)
    resultado = []
    for p in pendientes(huecos):
        cmd = [claude, "-p", f"/sdd-spec-writer:sdd {p['peticion']}",
               "--permission-mode", "acceptEdits",
               "--allowedTools", "Agent,Read,Glob,Grep,Write,Edit", *plugin_dirs()]
        log = logs / f"{p['id']}.log"
        try:
            r = subprocess.run(cmd, cwd=repo, env=env, capture_output=True, text=True,
                               encoding="utf-8", errors="replace", timeout=TIMEOUT_S)
            salida, codigo = r.stdout + r.stderr, r.returncode
        except subprocess.TimeoutExpired:
            salida, codigo = f"timeout tras {TIMEOUT_S}s", -1
        log.write_text(salida, encoding="utf-8")
        resultado.append({"id": p["id"], "codigo": codigo, "log": str(log.relative_to(repo))})
        print(f"{p['id']}: salida {codigo}", flush=True)

    tmp = fichero.parent / "resultado.json.tmp"
    tmp.write_text(json.dumps(resultado, indent=2, ensure_ascii=False), encoding="utf-8")
    tmp.replace(fichero.parent / "resultado.json")
    return 0 if all(r["codigo"] == 0 for r in resultado) else 1


if __name__ == "__main__":
    if sys.argv[1:] == ["--test"]:
        assert pendientes({"peticiones": [{"id": "a"}, {"id": "b", "spec_existente": "docs/specs/0004"}]}) == [{"id": "a"}]
        assert pendientes({}) == []
        assert all(Path(d).is_dir() for d in plugin_dirs()[1::2])
        print("ok")
        sys.exit(0)
    sys.exit(main())
