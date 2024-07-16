#!/usr/bin/env bash

cur=$(dirname $(readlink -f $0))
cd $cur

pid=$(pidof lmgrd)

if [[ $pid == "" ]] ; then
    $cur/lin_flexlm_v11.17.2.0/lnx64.o/lmgrd -c $cur/aie.lic -l $cur/server.log
else
    echo process exist
fi
