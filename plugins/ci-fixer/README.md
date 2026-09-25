# ci-fixer

Agente que repara de forma autónoma los fallos de CI de GitHub Actions corrigiendo el **código de producción, nunca los tests**. Cada fallo pasa por `/sdd-spec-writer:sdd` (spec, implementation plan y validators) antes de implementarse con `ponytail`.

## Piezas

| Ruta | Qué es |
|---|---|
| `agents/ci-fixer.md` | Prompt del agente: diagnóstico → definición → `/sdd` → implementación → tests locales → commit + push → revisión |
| `hooks/hooks.json` | Registra `ci-status.sh` en `SessionStart`, `PostToolUse` (Bash) y `Stop` |
| `scripts/ci-status.sh` | Entrega al agente el resultado del CI al arrancar, tras cada `git push` y al intentar terminar |
| `settings/ci-fixer.settings.json` | `CI_FIXER=1`, allowlist mínima de git/gh y deny de tests, CI, force push y ramas protegidas |

Los hooks se cargan en toda sesión con el plugin habilitado, pero el script sale sin hacer nada salvo que `CI_FIXER=1`: el resto de sesiones no se ven afectadas.

## Requisitos

- `git`, `jq`, `gh` y `bash` (en Windows, Git Bash).
- `gh` autenticado por la variable de entorno `GH_TOKEN` (permisos de lectura de Actions y escritura de contenidos en el repo). Nunca en un fichero.
- Plugins `sdd-spec-writer` (con `spec-tools` y `spec-validators`), `ponytail` y `mattpocock-skills` del marketplace my-factory.
- Estar en una rama de trabajo que no sea `main`, `master`, `develop`, `release/*`, `hotfix/*` ni la rama por defecto, con upstream en `origin`.

## Uso

Desde la raíz del repo que quieres reparar:

```bash
export GH_TOKEN=...   # desde tu gestor de secretos
CI_FIXER=1 claude --agent ci-fixer:ci-fixer \
  --settings "<ruta-del-plugin>/settings/ci-fixer.settings.json" \
  --permission-mode acceptEdits \
  -p "Repara el CI de esta rama"
```

Añade con `--allowedTools` el comando de tests del proyecto (p. ej. `"Bash(npm test*)"`) para que no pida permiso en modo headless. Para una ejecución desatendida, hazlo en un contenedor o runner efímero.

## Variables del hook

| Variable | Por defecto | Qué controla |
|---|---|---|
| `CI_MAX_ITER` | 5 | Iteraciones máximas (pushes) de reparación |
| `CI_APPEAR_TIMEOUT` | 120 | Segundos esperando a que aparezca el run tras el push |
| `CI_POLL_TIMEOUT` | 1500 | Segundos esperando a que termine el CI |
| `CI_LOG_LINES` | 120 | Líneas de log por workflow fallido |
| `CI_MAX_STOP_BLOCKS` | 3 | Veces seguidas que `Stop` bloquea sobre el mismo commit antes de dejar parar (anti-bucle) |

El contador de iteraciones se guarda en `.git/ci-fixer/`, fuera del árbol de trabajo.

## Salvaguardas

- **Permisos** (`settings/`): deny de `Edit`/`Write` sobre ficheros y configuración de tests, `.github/**` y `.claude/**`; deny de force push, push a ramas protegidas, `--amend`, `rebase`, `reset --hard`, `--no-verify`, `git rm` y `git mv`.
- **Prompt**: prohíbe skip/xfail, bajar umbrales de cobertura, crear tests o tocar CI; `git add` fichero a fichero; comprobación final con `git diff --name-only <SHA_INICIAL>...HEAD`.
- **Hook Stop**: no deja terminar con el CI en rojo ni con commits sin enviar, salvo informe `Estado: BLOQUEADO`, límite de iteraciones o la válvula anti-bucle.

Los deny por patrón no cubren todo (un `rm` por Bash, p. ej.): la comprobación final del diff es la que manda.
