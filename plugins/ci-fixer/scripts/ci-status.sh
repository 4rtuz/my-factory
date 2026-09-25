#!/usr/bin/env bash
# Hook de Claude Code que entrega al agente el resultado del CI de GitHub Actions.
# Modos:
#   session-start -> inyecta el estado inicial del CI del commit actual
#   post-push     -> tras un `git push`, espera al CI y devuelve el resultado
#   stop          -> impide que el agente termine mientras el CI no esté en verde
#
# Requisitos: gh (autenticado vía variable GH_TOKEN, nunca en este fichero), jq, git.

set -uo pipefail

MODE="${1:?Uso: ci-status.sh session-start|post-push|stop}"
INPUT="$(cat)"

# Solo actúa en sesiones del agente reparador; el resto de sesiones no se ven afectadas.
[[ "${CI_FIXER:-0}" == "1" ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Sin dependencias no hay resultado fiable: se avisa al arrancar (stdout de SessionStart
# llega como contexto) y el agente emite su informe BLOQUEADO.
for dep in git gh jq; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    [[ "$MODE" == "session-start" ]] && echo "RESULTADO_CI_INICIAL: none"$'\n'"Hook ci-fixer inactivo: falta '$dep' en el PATH."
    exit 0
  fi
done

MAX_ITER="${CI_MAX_ITER:-5}"             # iteraciones máximas de reparación
APPEAR_TIMEOUT="${CI_APPEAR_TIMEOUT:-120}" # segundos esperando a que aparezca el run
POLL_TIMEOUT="${CI_POLL_TIMEOUT:-1500}"  # segundos esperando a que termine el CI
LOG_LINES="${CI_LOG_LINES:-120}"         # líneas de log por workflow fallido
MAX_STOP_BLOCKS="${CI_MAX_STOP_BLOCKS:-3}" # bloqueos de Stop seguidos sobre el mismo commit
MAX_REPORT_CHARS=20000                   # tope para no saturar el contexto

# El estado vive dentro de .git: nunca se versiona ni ensucia el árbol de trabajo.
STATE_DIR="$(git rev-parse --absolute-git-dir)/ci-fixer"
SESSION_ID="$(jq -r '.session_id // "default"' <<<"$INPUT")"
COUNTER="$STATE_DIR/ci-iter-$SESSION_ID"
STOPS="$STATE_DIR/ci-stops-$SESSION_ID"
mkdir -p "$STATE_DIR"

SHA="$(git rev-parse HEAD)"
BRANCH="$(git branch --show-current)"
RUN_FIELDS="databaseId,workflowName,status,conclusion,url"

emit_block()   { jq -n --arg r "$1" '{decision:"block", reason:$r}'; }
emit_context() { jq -n --arg e "$1" --arg c "$2" \
                   '{hookSpecificOutput:{hookEventName:$e, additionalContext:$c}}'; }

list_runs() { gh run list --commit "$SHA" --json "$RUN_FIELDS" --limit 50 2>/dev/null || echo "[]"; }

# Espera a que existan runs para el commit y a que todos terminen. Imprime el JSON.
wait_for_runs() {
  local waited=0 runs
  runs="$(list_runs)"
  while [[ "$(jq length <<<"$runs")" -eq 0 ]]; do
    (( waited >= APPEAR_TIMEOUT )) && { echo "[]"; return; }
    sleep 10; waited=$((waited + 10)); runs="$(list_runs)"
  done
  waited=0
  while [[ "$(jq '[.[] | select(.status != "completed")] | length' <<<"$runs")" -gt 0 ]]; do
    (( waited >= POLL_TIMEOUT )) && break
    sleep 20; waited=$((waited + 20)); runs="$(list_runs)"
  done
  echo "$runs"
}

# Clasifica el resultado. Deja en STATE: ok | fail | infra | pending | none, y en REPORT el detalle.
summarize() {
  local runs="$1" failed id name concl url
  if [[ "$(jq length <<<"$runs")" -eq 0 ]]; then
    STATE="none"; REPORT="No se encontró ninguna ejecución de CI para el commit $SHA."; return
  fi
  if [[ "$(jq '[.[] | select(.status != "completed")] | length' <<<"$runs")" -gt 0 ]]; then
    STATE="pending"; REPORT="El CI del commit $SHA sigue en curso tras el tiempo máximo de espera."; return
  fi
  failed="$(jq '[.[] | select(.conclusion != "success" and .conclusion != "skipped" and .conclusion != "neutral")]' <<<"$runs")"
  if [[ "$(jq length <<<"$failed")" -eq 0 ]]; then
    STATE="ok"; REPORT="Todos los workflows del commit $SHA han pasado."; return
  fi
  # Sin ningún "failure" (solo cancelled, timed_out, startup_failure...) => probable fallo de infraestructura.
  if [[ "$(jq '[.[] | select(.conclusion == "failure")] | length' <<<"$failed")" -gt 0 ]]; then
    STATE="fail"
  else
    STATE="infra"
  fi
  REPORT="Workflows fallidos en el commit $SHA:"
  while read -r id; do
    name="$(jq -r --argjson i "$id" '.[] | select(.databaseId == $i) | .workflowName' <<<"$failed")"
    concl="$(jq -r --argjson i "$id" '.[] | select(.databaseId == $i) | .conclusion' <<<"$failed")"
    url="$(jq -r --argjson i "$id" '.[] | select(.databaseId == $i) | .url' <<<"$failed")"
    REPORT+=$'\n\n'"### $name | conclusión: $concl | $url"$'\n'
    REPORT+="$(gh run view "$id" --log-failed 2>/dev/null | tail -n "$LOG_LINES")"
  done < <(jq -r '.[].databaseId' <<<"$failed")
  REPORT="${REPORT:0:$MAX_REPORT_CHARS}"
}

iteration() { cat "$COUNTER" 2>/dev/null || echo 0; }

# Último mensaje del agente: campo del evento o, si no viene, el transcript.
last_message() {
  local msg transcript
  msg="$(jq -r '.last_assistant_message // ""' <<<"$INPUT")"
  transcript="$(jq -r '.transcript_path // ""' <<<"$INPUT")"
  if [[ -z "$msg" && -f "$transcript" ]]; then
    msg="$(tail -n 200 "$transcript" | jq -rs \
      '[.[] | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text] | last // ""' 2>/dev/null)"
  fi
  printf '%s' "$msg"
}

# Válvula anti-bucle: tras MAX_STOP_BLOCKS bloqueos seguidos sobre el mismo commit, deja parar.
stop_guard() {
  local psha="" pcount=0 c
  [[ -f "$STOPS" ]] && read -r psha pcount < "$STOPS"
  if [[ "$psha" == "$SHA" ]]; then c=$(( ${pcount:-0} + 1 )); else c=1; fi
  if (( c > MAX_STOP_BLOCKS )); then rm -f "$STOPS"; exit 0; fi
  echo "$SHA $c" > "$STOPS"
}

case "$MODE" in
  session-start)
    rm -f "$COUNTER" "$STOPS"
    summarize "$(wait_for_runs)"
    emit_context "SessionStart" "RESULTADO_CI_INICIAL: $STATE"$'\n'"SHA_INICIAL: $SHA"$'\n'"RAMA: $BRANCH"$'\n'"$REPORT"
    ;;

  post-push)
    cmd="$(jq -r '.tool_input.command // ""' <<<"$INPUT")"
    [[ "$cmd" =~ git[[:space:]]+push ]] || exit 0
    # Si el push no llegó al remoto, no hay CI que esperar.
    upstream="$(git rev-parse '@{u}' 2>/dev/null || echo "")"
    [[ "$upstream" == "$SHA" ]] || exit 0

    n=$(( $(iteration) + 1 )); echo "$n" > "$COUNTER"
    rm -f "$STOPS"
    summarize "$(wait_for_runs)"
    if [[ "$STATE" == "ok" ]]; then
      emit_context "PostToolUse" "RESULTADO_CI: ok (iteración $n)"$'\n'"$REPORT"
    else
      emit_block "RESULTADO_CI: $STATE (iteración $n de $MAX_ITER)"$'\n'"$REPORT"
    fi
    ;;

  stop)
    # Parada legítima por bloqueo declarado (infraestructura, test contradictorio, etc.).
    grep -qE 'Estado:[[:space:]]*\**BLOQUEADO' <<<"$(last_message)" && exit 0
    # Límite de iteraciones alcanzado: se permite parar para no entrar en bucle infinito.
    (( $(iteration) >= MAX_ITER )) && exit 0

    upstream="$(git rev-parse '@{u}' 2>/dev/null || echo "")"
    if [[ "$upstream" != "$SHA" ]]; then
      stop_guard
      emit_block "Tienes commits locales sin enviar a GitHub. Haz push (git push -u origin $BRANCH) para que se ejecute el CI antes de terminar."
      exit 0
    fi

    summarize "$(wait_for_runs)"
    if [[ "$STATE" == "ok" ]]; then
      rm -f "$COUNTER" "$STOPS"; exit 0
    fi
    stop_guard
    emit_block "No puedes terminar: el CI del commit $SHA está en estado '$STATE'. Continúa el ciclo de reparación o, si es un bloqueo real, emite el informe final con 'Estado: BLOQUEADO'."$'\n\n'"$REPORT"
    ;;

  *)
    echo "Modo desconocido: $MODE" >&2; exit 1
    ;;
esac
