#!/bin/sh -l

echo $config > ~/.transifexrc

if [ "$PUSH_SOURCES" = true ] ; then
    echo "PUSHING SOURCES"
    tx push -s
fi

if [ "$PUSH_TRANSLATIONS" = true ] ; then
    echo "PUSHING TRANSLATIONS"
    tx push -t
fi

if [ "$PULL_SOURCES" = true ] ; then
    echo "PULLING SOURCES"
    tx pull -s
fi

if [ "$PULL_TRANSLATIONS" = true ] ; then
    args=()
    (( MINIMUM_PERC != 0 )) && args+=( "--minimum-perc=$MINIMUM_PERC" )
    (( DISABLE_OVERRIDE = true )) && args+=( "--disable-overwrite" )
    echo "PULLING TRANSLATIONS (with args: $args)"
    tx pull -a "${args[@]}"
fi
