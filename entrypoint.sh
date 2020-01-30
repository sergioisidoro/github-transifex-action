#!/bin/sh -l

sh -c "TX INIT"

tx init

sh -c "PUSHING ALL SOURCES"
tx push -s
