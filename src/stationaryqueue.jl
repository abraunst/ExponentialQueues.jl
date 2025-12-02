using AliasTables

struct StationaryQueue{T,F} <: AbstractExponentialQueue{Int, Float64}
    rates::T
    s::F
    at::AliasTable{UInt,Int}
end


StationaryQueue(p) = StationaryQueue(p, sum(p), AliasTable(p))

Base.sum(sq::StationaryQueue) = sq.s

Base.length(sq::StationaryQueue) = length(sq.rates)

@inline Base.getindex(sq::StationaryQueue, i...) = sq.rates[i...]

Base.iterate(sq:: StationaryQueue, s...) = iterate(((i => sq.rates[i]) for i in eachindex(sq.rates)), s...)

@inline function Base.peek(sq::StationaryQueue; rng = Random.default_rng())
    (rand(rng, sq.at) => randexp(rng) / sum(sq))::Pair{Int, Float64}
end


@inline function peekevent(sq::StationaryQueue; rng = Random.default_rng())
    rand(rng, sq.at)
end
