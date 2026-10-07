"""Checkout paths shared by the runner and its tool adapters."""

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
LEGACY_WOLFRAM_DIR = REPO_ROOT / "legacy" / "wolfram"
LEGACY_LOADERS_DIR = LEGACY_WOLFRAM_DIR / "loaders"
