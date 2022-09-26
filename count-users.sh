#!/usr/bin/env bash
who | awk '{print $1}' | sort -u | wc -l
