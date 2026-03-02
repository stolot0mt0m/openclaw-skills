# REVIEW.md — voice-reply skill

## Changes (ClawHub Feedback Fix)

### Architecture Decisions

1. **User-local install as default**: Installer now defaults to `~/.local/share/voice-reply/` instead of requiring root and writing to `/opt`. System-wide install is still available via `--system` flag. This addresses the concern about needing sudo for installation.

2. **SHA256 checksum verification**: All three downloads (sherpa-onnx binary, thorsten voice, ryan voice) are verified against checksums published in the upstream `checksum.txt` files on the GitHub release pages. The `--skip-checksums` flag is available but discouraged.

3. **Entrypoint clarity**: `bin/voice-reply` was always present in the package but ClawHub's automated review didn't detect it. SKILL.md now has an explicit "Runtime Entrypoint" section. The installer also verifies the entrypoint exists and is executable at step 4/5.

4. **Path resolution cascade**: `bin/voice-reply` now auto-discovers sherpa-onnx and voice models using a cascade: env var > user-local path > system path. This means it works regardless of whether the user did a local or system install.

5. **LD_LIBRARY_PATH**: The runtime script now sets `LD_LIBRARY_PATH` to include `$RUNTIME_DIR/lib`, which is required for sherpa-onnx shared libraries to load correctly, especially in user-local installs.

### Known Limitations

- **Linux x86_64 only**: sherpa-onnx pre-built binaries are only available for Linux x64. ARM support would require building from source.
- **No streaming**: TTS generates the full audio file before outputting. Long texts will have a noticeable delay.
- **Two voices only**: Only German (thorsten) and English (ryan) are shipped. Users can add more manually.
- **Temp file output**: Audio is written to `/tmp/voice-reply-output.ogg` — concurrent calls would overwrite each other. The PID-based temp dir helps during generation but the final output path is fixed.

### Scalability Notes

- Each TTS call uses ~500MB RAM temporarily. Not suitable for high-concurrency servers.
- Voice models are ~64-110MB each. Adding many languages increases disk usage linearly.
- sherpa-onnx binary + libs are ~28MB, reasonable for embedded/edge deployments.

### Security Review

- **Download verification**: SHA256 checksums sourced from upstream `checksum.txt` files on GitHub releases.
- **No root at runtime**: `bin/voice-reply` never requires elevated privileges.
- **No network at runtime**: After installation, the skill is fully offline.
- **Installer root usage**: Only needed for `--system` mode (writing to /opt) and for `apt install ffmpeg`. User-local mode needs no root.
- **No arbitrary code execution**: The installer only downloads tar archives and extracts them. No post-install scripts from downloaded content are executed.
- **Temp file handling**: Uses PID-namespaced temp dirs during generation, cleaned up on completion.
