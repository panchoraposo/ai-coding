#!/usr/bin/env bash
# Compatibility alias — EnMaaS replaced the workshop MaaS URL for this template.
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-enmaas.sh"
