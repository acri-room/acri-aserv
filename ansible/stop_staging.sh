#!/usr/bin/env bash
lxc stop staging
lxc publish staging --alias as --compression none --reuse
lxc delete staging

