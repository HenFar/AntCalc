"""Run a checkout with PYTHONPATH=src python -m antcalc [runcard]."""

import sys

from .orchestrator import orchestrator

orchestrator(*sys.argv[1:2])
