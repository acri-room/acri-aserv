#!/usr/bin/env bash

test -e /opt/vitis_ai/workspace && chown -hR $LOGIN_USER_UID:$LOGIN_USER_GID /opt/vitis_ai/workspace
test -e /opt/vitis_ai/CK-TOOLS  && chown -hR $LOGIN_USER_UID:$LOGIN_USER_GID /opt/vitis_ai/CK-TOOLS
test -e /opt/vitis_ai/conda/bin && chown -hR $LOGIN_USER_UID:$LOGIN_USER_GID /opt/vitis_ai/conda/bin
