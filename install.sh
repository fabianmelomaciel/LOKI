#!/bin/bash
# Loki — Instalador POSIX
# Cobertura de SO: Linux, macOS, BSD y WSL (script POSIX puro, sin apt/brew/pkg).
# Windows nativo (sin WSL) → usar install.ps1 (PowerShell 5.1+ / pwsh cross-platform).
# Uso: ./install.sh [opencode|claude|all] | --check | --uninstall
# Mantener FileList en sync con install.ps1.

set -euo pipefail

TARGET="all"
MODE="install"
for arg in "$@"; do
    case "$arg" in
        --check) MODE="check" ;;
        --uninstall) MODE="uninstall" ;;
        opencode|claude|all) TARGET="$arg" ;;
    esac
done

SRC="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="loki"

# Fuente única de versión + lista de archivos (sync con install.ps1) — ver loki.manifest.sh
. "$SRC/loki.manifest.sh"
SKILL_VERSION="$LOKI_VERSION"
FILE_LIST="$LOKI_FILES"
CMD_LIST="$LOKI_CMD_LIST"

DEST_ROOTS=""
case "$TARGET" in
    all|opencode) DEST_ROOTS="$DEST_ROOTS ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills" ;;
esac
case "$TARGET" in
    all|claude) DEST_ROOTS="$DEST_ROOTS $HOME/.claude/skills" ;;
esac

# Destinos de slash-commands (fuente: .opencode/commands/ y .claude/commands/ del repo)
OCMD=""
CCMD=""
case "$TARGET" in
    all|opencode) OCMD="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands" ;;
esac
case "$TARGET" in
    all|claude) CCMD="$HOME/.claude/commands" ;;
esac

hash256() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
    else echo "install.sh: ni sha256sum ni shasum — integridad no verificable" >&2; exit 1; fi
}

install_skill() {
    local dest_root="$1"
    mkdir -p "$dest_root"
    local dest="$dest_root/$SKILL_NAME"
    rm -rf "$dest"
    mkdir -p "$dest"
    for f in $FILE_LIST; do
        if [ -e "$SRC/$f" ]; then
            cp -r "$SRC/$f" "$dest/$f"
        fi
    done
    # CODEX.md NO se copia (local-only)
    echo "  OK -> $dest  (v$SKILL_VERSION)"
}

check_skill() {
    local dest_root="$1"
    local dest="$dest_root/$SKILL_NAME"
    local drift=0 f rel path
    if [ ! -f "$dest/SKILL.md" ]; then
        echo "  [MISS]  $dest — no instalada"
        return 1
    fi
    for f in $FILE_LIST; do
        if [ -d "$SRC/$f" ]; then
            for path in $(cd "$SRC/$f" && find . -type f | sort); do
                rel="${path#./}"
                if [ ! -f "$dest/$f/$rel" ]; then
                    echo "  [DRIFT] falta: $f/$rel"; drift=1
                elif [ "$(hash256 "$SRC/$f/$rel")" != "$(hash256 "$dest/$f/$rel")" ]; then
                    echo "  [DRIFT] difiere: $f/$rel"; drift=1
                fi
            done
            if [ -d "$dest/$f" ]; then
                for path in $(cd "$dest/$f" && find . -type f | sort); do
                    rel="${path#./}"
                    if [ ! -f "$SRC/$f/$rel" ]; then
                        echo "  [DRIFT] extra (posible inyeccion): $f/$rel"; drift=1
                    fi
                done
            fi
        elif [ -f "$SRC/$f" ]; then
            if [ ! -f "$dest/$f" ]; then
                echo "  [DRIFT] falta: $f"; drift=1
            elif [ "$(hash256 "$SRC/$f")" != "$(hash256 "$dest/$f")" ]; then
                echo "  [DRIFT] difiere: $f"; drift=1
            fi
        fi
    done
    if [ "$drift" = "0" ]; then
        echo "  [SYNC]  $dest"
        return 0
    fi
    echo "  → $dest requiere re-instalación (./install.sh)"
    return 1
}

uninstall_skill() {
    local dest_root="$1"
    local dest="$dest_root/$SKILL_NAME"
    if [ -d "$dest" ]; then
        rm -rf "$dest"
        echo "  [DEL]   $dest"
    else
        echo "  [SKIP]  $dest no existe"
    fi
}

install_cmds() {
    local f
    if [ -n "$OCMD" ]; then
        mkdir -p "$OCMD"
        for f in $CMD_LIST; do
            if [ -f "$SRC/.opencode/commands/$f" ]; then cp "$SRC/.opencode/commands/$f" "$OCMD/$f"; fi
        done
        echo "  OK -> $OCMD  (slash-commands)"
    fi
    if [ -n "$CCMD" ]; then
        mkdir -p "$CCMD"
        for f in $CMD_LIST; do
            if [ -f "$SRC/.claude/commands/$f" ]; then cp "$SRC/.claude/commands/$f" "$CCMD/$f"; fi
        done
        echo "  OK -> $CCMD  (slash-commands)"
    fi
}

check_cmds() {
    local f rc=0
    if [ -n "$OCMD" ]; then
        for f in $CMD_LIST; do
            if [ ! -f "$OCMD/$f" ]; then echo "  [DRIFT] comando falta: $OCMD/$f"; rc=1
            elif [ "$(hash256 "$SRC/.opencode/commands/$f")" != "$(hash256 "$OCMD/$f")" ]; then echo "  [DRIFT] comando difiere: $OCMD/$f"; rc=1
            fi
        done
    fi
    if [ -n "$CCMD" ]; then
        for f in $CMD_LIST; do
            if [ ! -f "$CCMD/$f" ]; then echo "  [DRIFT] comando falta: $CCMD/$f"; rc=1
            elif [ "$(hash256 "$SRC/.claude/commands/$f")" != "$(hash256 "$CCMD/$f")" ]; then echo "  [DRIFT] comando difiere: $CCMD/$f"; rc=1
            fi
        done
    fi
    return $rc
}

uninstall_cmds() {
    local f
    if [ -n "$OCMD" ]; then
        for f in $CMD_LIST; do
            if [ -f "$OCMD/$f" ]; then rm -f "$OCMD/$f"; echo "  [DEL]   $OCMD/$f"; fi
        done
    fi
    if [ -n "$CCMD" ]; then
        for f in $CMD_LIST; do
            if [ -f "$CCMD/$f" ]; then rm -f "$CCMD/$f"; echo "  [DEL]   $CCMD/$f"; fi
        done
    fi
}

echo ""
echo "🔐 Loki Installer v$SKILL_VERSION"

if [ "$MODE" = "uninstall" ]; then
    echo "=== UNINSTALL ==="
    for dr in $DEST_ROOTS; do uninstall_skill "$dr"; done
    uninstall_cmds
    echo ""
    exit 0
fi

if [ "$MODE" = "check" ]; then
    if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
        echo "ERROR: ni sha256sum ni shasum disponibles — verificación de integridad abortada (fail-closed)" >&2
        exit 1
    fi
    echo "=== CHECK (repo vs instalación) ==="
    ok=1
    for dr in $DEST_ROOTS; do
        check_skill "$dr" || ok=0
    done
    check_cmds || ok=0
    echo ""
    echo "[delegación] SkillGrid skills:"
    SG_ROOTS="${SKILLGRID:-} ${SRC}/../SkillGrid/skills"
    for s in auditor-de-seguridad cyber-neo hack-audit audit-loop supply-chain-auditor prompt-injection-guard; do
        found=0
        for r in $SG_ROOTS; do
            [ -n "$r" ] && [ -f "$r/$s/SKILL.md" ] && found=1 && break
        done
        if [ "$found" = "1" ]; then echo "  [OK]    $s"; else echo "  [MISS]  $s"; fi
    done
    echo ""
    if [ "$ok" = "1" ]; then echo "RESULTADO: SYNC"; exit 0; else echo "RESULTADO: DRIFT — re-instalar"; exit 1; fi
fi

# INSTALL
n=0
total=0
for dr in $DEST_ROOTS; do
    total=$((total + 1))
done
for dr in $DEST_ROOTS; do
    n=$((n + 1))
    echo "[$n/$total] $dr"
    install_skill "$dr"
done
install_cmds

echo ""
echo "[tools] Matriz de herramientas T0 (detección):"
TOOLS="semgrep trivy gitleaks trufflehog checkov bandit safety nuclei nmap ffuf nikto node npm git"
AVAIL=0
MISSING=""
TOTAL=0
for t in $TOOLS; do
    TOTAL=$((TOTAL + 1))
    if command -v "$t" >/dev/null 2>&1; then
        AVAIL=$((AVAIL + 1))
        printf "  [OK]    %s\n" "$t"
    else
        MISSING="$MISSING $t"
        printf "  [MISS]  %s\n" "$t"
    fi
done
echo "Disponibles: $AVAIL/$TOTAL"
if [ -n "$MISSING" ]; then
    echo "Faltantes (se declaran en el informe):$MISSING"
fi

echo ""
echo "[delegación] SkillGrid skills:"
SG_ROOTS="${SKILLGRID:-} ${SRC}/../SkillGrid/skills"
for s in auditor-de-seguridad cyber-neo hack-audit audit-loop supply-chain-auditor prompt-injection-guard; do
    found=0
    for r in $SG_ROOTS; do
        [ -n "$r" ] && [ -f "$r/$s/SKILL.md" ] && found=1 && break
    done
    if [ "$found" = "1" ]; then echo "  [OK]    $s"; else echo "  [MISS]  $s — fallback T0-only"; fi
done

echo ""
echo "✅ Instalado v$SKILL_VERSION. Uso: 'Auditá <target> con Loki'."
echo "⚠️  5 gates de autorización requeridos antes de cualquier acción activa."
echo ""
