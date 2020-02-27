#!/bin/sh -l

echo $config > ~/.transifexrc

if [    "$PUSH_SOURCES" = true ] ; then
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

if [ $PULL_TRANSLATIONS = true ] ; then
    echo "PULLING TRANSLATIONS"
    tx pull -a
fi
