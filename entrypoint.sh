#!/bin/sh -l

echo $config > ~/.transifexrc

tx push -s
