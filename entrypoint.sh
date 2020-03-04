#!/bin/bash

echo $config > ~/.transifexrc

if [ $PUSH_SOURCES ] ; then
    echo "PUSHING SOURCES"
    tx push -s
fi

if [ $PUSH_TRANSLATIONS ] ; then
    echo "PUSHING TRANSLATIONS"
    tx push -t
fi

if [ $PULL_SOURCES ] ; then
    echo "PULLING SOURCES"
    tx pull -s
fi

if [ $PULL_TRANSLATIONS ] ; then
    args=()

    if [ $MINIMUM_PERC -ne 0 ] ; then
        args+=( "--minimum-perc=$MINIMUM_PERC" )
    fi

    if [ $DISABLE_OVERRIDE ] ; then
        args+=( "--disable-overwrite" )
    fi

    echo "PULLING TRANSLATIONS (with args: $args)"
    tx pull -a "${args[@]}"
fi
