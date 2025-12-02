struct UniformQueue{T,I,F} <: AbstractExponentialQueue{I,F}
    events::T
    rate::F
end

"""
`UniformQueue(evs, r)` hold a queue with events in the container `evs`, all with 
the same rate `r`. The `evs` container should support `delete!(evs, i)` (e.g. if 
evs is a `Set`) for the queue to support `pop!`. 
"""
UniformQueue(events::T, rate::F) where {T,F} = ConstantQueue{T,eltype(events),F}(events,rate)

Base.sum(cq::UniformQueue) = cq.rate[] * length(cq)

function Base.getindex(q::UniformQueue, i)
    @boundscheck i in q.events || throw(BoundsError(q.events, i))
    return q.rate[]
end

Base.peek(q::UniformQueue; rng = Random.default_rng()) = peekevent(q; rng) => randexp()/q.rate[]

peekevent(q::UniformQueue; rng = Random.default_rng()) = rand(rng, q.events)

Base.isempty(q::UniformQueue) = isempty(q.events)

Base.length(q::UniformQueue) = length(q.events)

Base.values(cq::UniformQueue) = Iterators.repeated(cq.rate[], length(cq.events))
Base.keys(cq::UniformQueue) = cq.events

function Base.pop!(cq::UniformQueue; rng = Random.default_rng())
    i,t = peek(cq; rng)
    delete!(cq, i)
    return i => t
end

function Base.iterate(cq::UniformQueue, s = nothing)
    res = isnothing(s) ? iterate(cq.events) : iterate(cq.events, s)
    isnothing(res) ? res : ((res[1] => cq.rate[]), res[2])
end

Base.delete!(cq::UniformQueue, i) = delete!(cq.events, i)
