import Unrolled: @unroll

struct NestedQueue{LQ,LE,E,F,I} <: AbstractExponentialQueue{Tuple{E,I},F}
    qlist::LQ
    elist::LE
    function NestedQueue(qelist::QL) where {QL}
        qlist = map(last, qelist)
        elist = map(first, qelist)
        getf(::AbstractExponentialQueue{I,F}) where {I,F} = F
        geti(::AbstractExponentialQueue{I,F}) where {I,F} = I
        E = Union{(typeof(e) for e in elist)...}
        I = Union{(geti(q) for q in qlist)...}
        F = promote_type((getf(q) for q in qlist)...)
        return new{typeof(qlist),typeof(elist),E,F,I}(qlist, elist)
    end
end

"""
A `NestedQueue` holds a container of exponential queues 
"""
NestedQueue(x, xs...) = NestedQueue((x,xs...))


Base.isempty(nq::NestedQueue) = all(isempty, nq.qlist)

function Base.sum(nq::NestedQueue{LQ,LE,E,F,I}) where {LQ,LE,E,F,I}
    sum(sum, nq.qlist; init = zero(F))
end

Base.length(nq::NestedQueue) = sum(length, nq.qlist; init=0)

Base.values(nq::NestedQueue) = Iterators.flatten(values(q) for q in nq.qlist)

Base.keys(nq::NestedQueue) = (i for (i,_) in nq)

function Base.iterate(nq::NestedQueue, ss...)
    res = iterate(Iterators.flatten(zip(Iterators.repeated(e),q) for (e,q) in zip(nq.elist,nq.qlist)), ss...)
    isnothing(res) && return nothing 
    (a,(b, v)), s = res
    return ((a, b), v), s
end

@unroll function _pickqueue(ql,el,r)
    i = 1
    a = 0.0
    @inbounds @unroll for q in ql
        a += sum(q)
        r <= a && return el[i],ql[i]
        i += 1
    end
    @assert false
end

@unroll function _peek(ql,el,rng,s)
    i = 1
    r = rand(rng)*s
    a = 0.0
    @inbounds @unroll for q in ql
        a += sum(q)
        r <= a && return (el[i],peekevent(ql[i]; rng)) => randexp(rng)/s
        i += 1
    end
    @assert false
end

pickqueue(nq::NestedQueue; rng, s = sum(nq)) = _pickqueue(nq.qlist, nq.elist, rand(rng) * s)

function peekevent(nq::NestedQueue{LQ,LE,E,F,I}; rng = Random.default_rng()) where {LQ,LE,E,F,I}
    e,q = pickqueue(nq; rng)
    return e::E, peekevent(q; rng)::I
end

@inline function Base.peek(nq::NestedQueue{LQ,LE,E,F,I}; rng = Random.default_rng()) where {LQ,LE,E,F,I}
    _peek(nq.qlist, nq.elist, rng, sum(nq))::Pair{Tuple{E,I},F}
end

function Base.pop!(nq::NestedQueue; rng = Random.default_rng())
    s = sum(nq)
    e, q = pickqueue(nq; rng, s)
    i, _ = pop!(q; rng)
    return (e, i) => randexp(rng)/s
end
