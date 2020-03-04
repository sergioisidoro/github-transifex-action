#!/bin/bash

# exit when any command fails
set -e

echo $config > ~/.transifexrc

if [ $PUSH_SOURCES ] ; then
    echo "PUSHING SOURCES"
    tx push -s --no-interactive
fi

if [ $PUSH_TRANSLATIONS ] ; then
    echo "PUSHING TRANSLATIONS"
    tx push -t --no-interactive
fi

if [ $PULL_SOURCES ] ; then
    echo "PULLING SOURCES"
    tx pull -s --no-interactive
fi

if [ $PULL_TRANSLATIONS ] ; then
    args=()

    if [ $MINIMUM_PERC != 0 ] ; then
        args+=( "--minimum-perc=$MINIMUM_PERC" )
    fi

    if [ $DISABLE_OVERRIDE ] ; then
        args+=( "--disable-overwrite" )
    fi

    echo "PULLING TRANSLATIONS (with args: $args)"
    tx pull -a --no-interactive "${args[@]}"
fi
