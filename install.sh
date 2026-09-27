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
SKILL_VERSION="1.0.0"

# Lista canónica (sync con install.ps1)
FILE_LIST="SKILL.md README.md LICENSE SECURITY.md docs references templates scripts"

DEST_ROOTS=""
case "$TARGET" in
    all|opencode) DEST_ROOTS="$DEST_ROOTS ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills" ;;
esac
case "$TARGET" in
    all|claude) DEST_ROOTS="$DEST_ROOTS $HOME/.claude/skills" ;;
esac

hash256() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
    else echo "nohash"; fi
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
    if [ ! -f "$dest/SKILL.md" ]; then
        echo "  [MISS]  $dest — no instalada"
        return 1
    fi
    local h1 h2
    h1=$(hash256 "$SRC/SKILL.md")
    h2=$(hash256 "$dest/SKILL.md")
    if [ "$h1" = "$h2" ]; then
        echo "  [SYNC]  $dest"
        return 0
    fi
    echo "  [DRIFT] $dest — repo v$SKILL_VERSION ≠ instalada → re-ejecutá ./install.sh"
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

echo ""
echo "🔐 Loki Installer v$SKILL_VERSION"

if [ "$MODE" = "uninstall" ]; then
    echo "=== UNINSTALL ==="
    for dr in $DEST_ROOTS; do uninstall_skill "$dr"; done
    echo ""
    exit 0
fi

if [ "$MODE" = "check" ]; then
    echo "=== CHECK (repo vs instalación) ==="
    ok=1
    for dr in $DEST_ROOTS; do
        check_skill "$dr" || ok=0
    done
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
