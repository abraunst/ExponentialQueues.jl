struct NestedQueue{L,E,F,I} <: AbstractExponentialQueue{Pair{E,I},F}
    qlist::L
    function NestedQueue(qlist::L) where L
        E = promote_type((typeof(e) for (e,q) in qlist)...)
        getf(::AbstractExponentialQueue{I,F}) where {I,F} = F
        geti(::AbstractExponentialQueue{I,F}) where {I,F} = I
        I = promote_type((geti(q) for (_,q) in qlist)...)
        F = promote_type((getf(q) for (_,q) in qlist)...)
        return new{L,E,F,I}(qlist)
    end 
end

"""
A `NestedQueue` holds a container of exponential queues 
"""
NestedQueue(x, xs...) = NestedQueue((x,xs...))

Base.isempty(nq::NestedQueue) = all(isempty(q) for (_,q) in nq.qlist)

Base.sum(nq::NestedQueue{L,E,F,I}) where {L,E,F,I} = sum(sum(q) for (_,q) in nq.qlist; init=zero(F))

Base.length(nq::NestedQueue) = sum(length(q) for (_,q) in nq.qlist; init=0)

Base.values(nq::NestedQueue) = Iterators.flatten(values(q) for (_,q) in nq.qlist)

Base.keys(nq::NestedQueue) = (i for (i,v) in nq)

function Base.iterate(nq::NestedQueue, ss...)
    res = iterate(Iterators.flatten(zip(Iterators.repeated(e),q) for (e,q) in nq.qlist), ss...)
    isnothing(res) && return nothing 
    (a,(b, v)), s = res
    return ((a => b) => v), s
end

function pickqueue(nq::NestedQueue; rng, s = sum(nq))
    r::Float64 = rand(rng) * s
    for (e,q) in nq.qlist
        r -= sum(q)
        if r <= 0
            return e,q
        end
    end
    @assert false
end

function peekevent(nq::NestedQueue; rng = Random.default_rng())
    e,q = pickqueue(nq; rng)
    return e => peekevent(q; rng)
end

function Base.peek(nq::NestedQueue; rng = Random.default_rng())
    s = sum(nq)
    e,q = pickqueue(nq; rng, s)
    return (e => peekevent(q; rng)) => randexp(rng)/s
end

function Base.pop!(nq::NestedQueue; rng = Random.default_rng())
    s = sum(nq)
    e, q = pickqueue(nq; rng, s)
    i, _ = pop!(q; rng)
    return (e => i) => randexp(rng)/s
end