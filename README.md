# OpenClaw Skills

A collection of open-source skills for [OpenClaw](https://openclaw.ai) - the local AI assistant.

**Philosophy:** 100% local, no API keys required, privacy-first.

## Available Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [voice-reply](skills/voice-reply/) | Local text-to-speech using Piper voices | ✅ Ready |

## Installation

### Manual Installation

Copy any skill folder to your OpenClaw skills directory:

```bash
# Clone this repo
git clone https://github.com/stolot0mt0m/openclaw-skills.git

# Copy a skill to OpenClaw
cp -r openclaw-skills/skills/voice-reply ~/.openclaw/skills/
```

### Via ClawHub (when available)

```bash
npx clawhub install stolot0mt0m/voice-reply
```

## Requirements

- [OpenClaw](https://openclaw.ai) installed
- Linux (most skills are Linux-focused)
- Skill-specific requirements listed in each skill's README

## Contributing

Contributions welcome! Please:

1. Fork this repository
2. Create your skill in `skills/your-skill-name/`
3. Follow the [OpenClaw skill structure](https://docs.openclaw.ai/skills)
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [ClawHub Registry](https://clawhub.ai)
- [Skill Creation Guide](https://docs.openclaw.ai/skills/creating)
