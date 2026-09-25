#!/usr/bin/env bash
set -euo pipefail

grep "RMS Residual (m) =" RESIDUALS.TXT
grep " RMS POSITION UNCERTAINTY =" MAPINFO.TXT
