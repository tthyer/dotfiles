# User Preferences

## Notion MCP Tips
- Targeted edits on Notion tables rarely work — use `replace_content` for the full page or `replace_content_range` spanning well beyond the table
- Use broad selection snippets that include unique text before and after the table, not text inside the table itself

## Claude Code Plugin Tips
- `pluginRoot` in marketplace.json does NOT get applied to source paths — use explicit paths like `./plugins/ops` instead of relying on `pluginRoot` + `./ops`
- Plugin sources must start with `./` (e.g., `"source": "./plugins/ops"`)
- After pushing changes to a plugin repo, run `claude plugin marketplace update <name>` before reinstalling

## Communication
- Be concise, don't be verbose
