#!/bin/sh -l

echo $config > ~/.transifexrc

if $PUSH_SOURCES; then
    echo "PUSHING SOURCES"
    tx push -s
fi

if $PUSH_TRANSLATIONS; then
    echo "PUSHING TRANSLATIONS"
    tx push -t
fi

if $PULL_SOURCES; then
    echo "PULLING SOURCES"
    tx pull -s
fi

if $PULL_TRANSLATIONS; then
    echo "PULLING TRANSLATIONS"
    tx pull -a
fi
