using AliasTables

struct ConstantQueue{T,F} <: AbstractExponentialQueue{Int, Float64}
    rates::T
    s::F
    at::AliasTable{UInt,Int}
end


ConstantQueue(p) = ConstantQueue(p, sum(p), AliasTable(p))

Base.sum(sq::ConstantQueue) = sq.s

Base.length(sq::ConstantQueue) = length(sq.rates)

@inline Base.getindex(sq::ConstantQueue, i...) = sq.rates[i...]

Base.iterate(sq:: ConstantQueue, s...) = iterate(((i => sq.rates[i]) for i in eachindex(sq.rates)), s...)

@inline function Base.peek(sq::ConstantQueue; rng = Random.default_rng())
    (rand(rng, sq.at) => randexp(rng) / sum(sq))::Pair{Int, Float64}
end


@inline function peekevent(sq::ConstantQueue; rng = Random.default_rng())
    rand(rng, sq.at)
end
