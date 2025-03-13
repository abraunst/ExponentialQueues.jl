struct ConstantQueue{T,F} <: AbstractExponentialQueue{T,F}
    events::T
    rate::F
end

Base.sum(cq::ConstantQueue) = cq.rate[] * length(events)

function Base.getindex(q::ConstantQueue, i)
    @boundscheck i in q.events || throw(BoundsError(q.events, i))
    return q.rate[]
end

Base.peek(q::ConstantQueue; rng = Random.default_rng()) = peekevent(q; rng) => randexp()/q.rate[]

peekevent(q::ConstantQueue; rng = Random.default_rng()) = rand(rng, q.events)

Base.isempty(q::ConstantQueue) = isempty(q.events)

Base.length(q::ConstantQueue) = length(q.events)

Base.values(cq::ConstantQueue) = Iterators.repeated(cq.rate[], length(cq.events))
Base.keys(cq::ConstantQueue) = events

function Base.iterate(cq::ConstantQueue, s = nothing)
    res = isnothing(s) ? iterate(cq.events) : iterate(cq.events, s)
    isnothing(res) ? res : ((res[1] => cq.rate[]), res[2])
end
