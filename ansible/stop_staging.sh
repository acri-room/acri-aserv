#!/usr/bin/env bash
set -e

if [[ $(lxc --version) =~ ^5 ]] ; then
    publish_opts+=" --reuse "
fi

lxc stop staging
lxc publish staging --alias as --compression none $publish_opts
lxc delete staging

