# Gemini Web Fetch - WebFetch Fallback

When WebFetch fails to access a URL (bot blocking, auth walls, Reddit, etc.), use Gemini CLI as a fallback to fetch and analyze web content.

## When to use

- WebFetch returns an error or blocked response
- The target site is known to block bots (Reddit, LinkedIn, etc.)
- User explicitly asks to use Gemini for web fetching

## How to use

Run Gemini CLI in non-interactive mode via Bash. Gemini uses Google Search grounding to access web content.

```bash
export GEMINI_API_KEY="$GEMINI_API_KEY" && echo "<prompt about the URL>" | gemini -m gemini-2.5-flash 2>&1 | tail -30
```

- Pipe `tail -30` to skip Gemini's startup warnings (skill conflicts, etc.)
- Set Bash timeout to 120000ms (Gemini needs time for search grounding)

### Examples

**Summarize a blocked page:**
```bash
export GEMINI_API_KEY="$GEMINI_API_KEY" && echo "What are the top 5 posts on r/ClaudeAI right now? Summarize each in one line." | gemini -m gemini-2.5-flash 2>&1 | tail -30
```

**Extract specific info from a URL:**
```bash
export GEMINI_API_KEY="$GEMINI_API_KEY" && echo "Find and summarize the main content at <URL>. Include key points." | gemini -m gemini-2.5-flash 2>&1 | tail -30
```

## Important notes

- Gemini accesses web content via Google Search grounding (not direct HTTP fetch)
- Do NOT use this as a first choice — always try WebFetch first
- GEMINI_API_KEY is set in ~/.zshrc — ensure `export` is used in the command
