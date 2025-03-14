struct ConstantQueue{T,I,F} <: AbstractExponentialQueue{I,F}
    events::T
    rate::F
end

"""
`ConstantQueue(evs, r)` hold a queue with events in the container `evs`, all with 
the same rate `r`. The `evs` container should support `delete!(evs, i)` (e.g. if 
evs is a `Set`) for the queue to support `pop!`. 
"""
ConstantQueue(events::T, rate::F) where {T,F} = ConstantQueue{T,eltype(events),F}(events,rate)

Base.sum(cq::ConstantQueue) = cq.rate[] * length(cq)

function Base.getindex(q::ConstantQueue, i)
    @boundscheck i in q.events || throw(BoundsError(q.events, i))
    return q.rate[]
end

Base.peek(q::ConstantQueue; rng = Random.default_rng()) = peekevent(q; rng) => randexp()/q.rate[]

peekevent(q::ConstantQueue; rng = Random.default_rng()) = rand(rng, q.events)

Base.isempty(q::ConstantQueue) = isempty(q.events)

Base.length(q::ConstantQueue) = length(q.events)

Base.values(cq::ConstantQueue) = Iterators.repeated(cq.rate[], length(cq.events))
Base.keys(cq::ConstantQueue) = cq.events

function Base.pop!(cq::ConstantQueue; rng = Random.default_rng())
    i,t = peek(cq; rng)
    delete!(cq, i)
    return i => t
end

function Base.iterate(cq::ConstantQueue, s = nothing)
    res = isnothing(s) ? iterate(cq.events) : iterate(cq.events, s)
    isnothing(res) ? res : ((res[1] => cq.rate[]), res[2])
end

Base.delete!(cq::ConstantQueue, i) = delete!(cq.events, i)
