struct NestedQueue{L,E,F,I} <: AbstractExponentialQueue{Pair{E,I},F}
    qlist::L
    function NestedQueue(qlist::L) where L
        E = promote_type((typeof(e) for (e,q) in qlist)...)
        getf(::AbstractExponentialQueue{I,F}) where {I,F} = F
        geti(::AbstractExponentialQueue{I,F}) where {I,F} = I
        I = promote_type((geti(q) for (_,q) in qlist)...)
        F = promote_type((getf(q) for (_,q) in qlist)...)
        new{L,E,F,I}(qlist)
    end 
end

NestedQueue(x, xs...) = NestedQueue((x,xs...))

Base.isempty(nq::NestedQueue) = all(isempty(q) for (_,q) in nq.qlist)
Base.sum(nq::NestedQueue) = sum(sum(q) for (_,q) in nq.qlist; init=0.0)
Base.length(nq::NestedQueue) = sum(length(q) for (_,q) in nq.qlist; init=0)
Base.values(nq::NestedQueue) = Iterators.flatten(value(q) for (_,q) in nq.qlist)
Base.keys(nq::NestedQueue) = Iterators.flatten(keys(q) for (_,q) in nq.qlist)
function Base.iterate(nq::NestedQueue)
    (a,(b, v)), s = iterate(Iterators.flatten(zip(Iterators.repeated(e),q) for (e,q) in nq.qlist))
    ((a => b) => v), s
end

function Base.iterate(nq::NestedQueue, s)
    (a, (b, v)), s = iterate(Iterators.flatten(zip(Iterators.repeated(e),q) for (e,q) in nq.qlist), s)
    ((a => b) => v), s
end


function peekevent(nq::NestedQueue; rng = Random.default_rng(), s = sum(nq))
    r::Float64 = rand(rng) * s
    for (e,q) in nq.qlist
        r -= sum(q)
        if r <= 0
            return e => peekevent(q; rng)
        end
    end
    @assert false
end

function Base.peek(nq::NestedQueue; rng = Random.default_rng())
    s = sum(nq)
    peekevent(nq; rng, s) => randexp(rng)/s
end
