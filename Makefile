PROJECT = aoc2021
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0
ERLC_OPTS += '+{nowarn_unused_function, {ints_sum, 1}}'

include erlang.mk
