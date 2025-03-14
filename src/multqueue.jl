struct MultQueue{Q,I,F,F1} <: AbstractExponentialQueue{I,F}
    q::Q
    f::F1
end

MultQueue(q::Q,f::F1) where {I, F, Q <: AbstractExponentialQueue{I,F}, F1} = MultQueue{Q,I,F,F1}(q,f)

Base.:*(a::F1, q::Q) where {F1,I,F,Q<:AbstractExponentialQueue{I,F}} = MultQueue{Q,I,F,Base.RefValue{F1}}(q, Ref(a))
Base.:*(q::Q, a::F1) where {F1,I,F,Q<:AbstractExponentialQueue{I,F}} = a * q

Base.sum(mq::MultQueue) = mq.f[]*sum(mq.q)
Base.length(mq::MultQueue) = length(mq.q)
Base.isempty(mq::MultQueue) = isempty(mq.q)
peekevent(mq::MultQueue; rng = Random.default_rng()) = peekevent(mq.q; rng)
Base.peek(mq::MultQueue; rng = Random.default_rng()) = peekevent(mq.q; rng) => randexp(rng)/sum(mq)
function Base.pop!(mq::MultQueue; rng = Random.default_rng())
    i, t = pop!(mq.q; rng)
    return i, t / mq.f[]
end
Base.values(mq::MultQueue) = (mq.f[]*v for v in values(nq.q))
Base.keys(mq::MultQueue) = keys(mq.q)
function Base.iterate(mq::MultQueue, s = nothing)
    res = isnothing(s) ? iterate(mq.q) : iterate(mq.q, s)
    isnothing(res) ? res : ((res[1].first => mq.f[]*res[1].second), res[2])
end
