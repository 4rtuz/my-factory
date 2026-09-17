#!/usr/bin/env node
// Avisa a Claude de los submodulos de git que aun no tienen entrada en marketplace.json.
import { readFileSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

export function missingEntries(gitmodules, manifest) {
  return [...gitmodules.matchAll(/^\s*path\s*=\s*(.+)$/gm)]
    .map(m => m[1].trim())
    .filter(p => !manifest.includes(`"./${p}"`))
}

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..')
const read = p => { try { return readFileSync(join(root, p), 'utf8') } catch { return '' } }

if (process.argv[2] === '--selftest') {
  const { strictEqual: eq } = await import('node:assert')
  const mods = '[submodule "tools/foo"]\n\tpath = tools/foo\n[submodule "tools/foobar"]\n\tpath = tools/foobar\n'
  eq(missingEntries(mods, '{"source": "./tools/foo"}').join(), 'tools/foobar')
  eq(missingEntries(mods, '{}').join(), 'tools/foo,tools/foobar')
  eq(missingEntries('', '{}').length, 0)
  console.log('ok')
  process.exit(0)
}

const missing = missingEntries(read('.gitmodules'), read('.claude-plugin/marketplace.json'))
if (!missing.length) process.exit(0)

let hookEventName = 'UserPromptSubmit'
try { hookEventName = JSON.parse(readFileSync(0, 'utf8')).hook_event_name || hookEventName } catch {}

console.log(JSON.stringify({
  systemMessage: `marketplace: sin entrada -> ${missing.join(', ')}`,
  hookSpecificOutput: {
    hookEventName,
    additionalContext: `Submodulos sin entrada en .claude-plugin/marketplace.json: ${missing.join(', ')}. Aplica ahora el procedimiento de .claude/commands/sync-marketplace.md para cada uno.`
  }
}))
