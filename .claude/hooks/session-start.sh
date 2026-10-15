#!/bin/bash
# Instala MarkItDown (PDF, PowerPoint, Word, Excel -> markdown) en cada sesión de Claude Code en la nube.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if python3 -c "import markitdown, docx, pptx, openpyxl, pdfminer" 2>/dev/null; then
  exit 0
fi

python3 -m pip install -q 'markitdown[all]'
