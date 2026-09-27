# Loki — manifest único (fuente de verdad para install.ps1 e install.sh)
# Formato KEY="VALUE" plano a propósito: install.sh lo sourcea nativo (`. loki.manifest.sh`),
# install.ps1 lo parsea con una regex simple. No agregar JSON/YAML acá — rompe la
# compatibilidad POSIX-sin-dependencias de install.sh (ver AGENTS.md).
LOKI_VERSION="1.2.0"
LOKI_FILES="SKILL.md README.md LICENSE SECURITY.md docs references templates scripts"
# Stems sin extensión: cada motor aporta su propia extensión (.md opencode/claude, .toml gemini)
LOKI_CMD_LIST="loki loki-scan"
