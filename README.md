# ExponentialQueues

[![Build Status](https://github.com/abraunst/ExponentialQueues.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abraunst/ExponentialQueues.jl/actions/workflows/CI.yml?query=branch%3Amain)

This library implements a series of event queues with rates to sample a Poisson point process with constant rates (in the specific sense that rates don't change between events, but can cange at event instants). It is specifically optimized such that:

* Changing rates, inserting and removing events have cost `O(log(N))` where `N` is the number of events.

* Sampling cost is `O(log(N))`

The libary implements the following types:

* `ExponentialQueue`: an updatable queue of up to `N` events with ids `1...N` and rates `Q[1]` ... `Q[N]`. Its interface follows the one of `Dict{Int,Float64}`.

* `ExponentialQueueDict{I,F}`: an updatable queue of events `i::I` and rates `Q[i]::F`. Its interface follows the one of `Dict{I,F}`.

* `ConstantRate`: a queue with `N` events of uniform rate `r`

* `MultQueue`: a composed queue which represnts a multiple of another queue.

* `NestedQueue` a mixed queue which represents the union of an arbitrary number of other queues.

These types are aritrarily composable.
