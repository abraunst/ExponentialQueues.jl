struct MultQueue{Q,I,F,F1} <: AbstractExponentialQueue{I,F}
    q::Q
    f::F1
end

MultQueue(q::Q,f::F1) where {I, F, Q <: AbstractExponentialQueue{I,F}, F1} = MultQueue{Q,I,F,F1}(q,f)

Base.:*(a::F1, q::Q) where {F1,I,F,Q<:AbstractExponentialQueue{I,F}} = MultQueue{Q,I,F,Base.RefValue{F1}}(q, Ref(a))
Base.:*(q::Q, a::F1) where {F1,I,F,Q<:AbstractExponentialQueue{I,F}} = a * q

Base.sum(mq::MultQueue{Q,I,F,F1}) where {Q,I,F,F1} = (mq.f[]*sum(mq.q))::F
Base.length(mq::MultQueue) = length(mq.q)
Base.isempty(mq::MultQueue) = isempty(mq.q)
peekevent(mq::MultQueue{Q,I,F,F1}; rng = Random.default_rng()) where {Q,I,F,F1} = peekevent(mq.q; rng)::I
@inline function Base.peek(mq::MultQueue{Q,I,F,F1}; rng = Random.default_rng()) where {Q,I,F,F1}
    i, t = peek(mq.q; rng)
    return i::I => (t / mq.f[])::F
end
@inline function Base.pop!(mq::MultQueue{Q,I,F,F1}; rng = Random.default_rng()) where {Q,I,F,F1}
    i, t = pop!(mq.q; rng)
    return i::I => (t / mq.f[])::F
end
Base.values(mq::MultQueue) = (mq.f[]*v for v in values(mq.q))
Base.keys(mq::MultQueue) = keys(mq.q)
function Base.iterate(mq::MultQueue, s = nothing)
    res = isnothing(s) ? iterate(mq.q) : iterate(mq.q, s)
    isnothing(res) ? res : ((res[1][1] => mq.f[]*res[1][2]), res[2])
end

Base.delete!(mq::MultQueue, i) = delete!(mq.q, i)
Base.setindex!(mq::MultQueue, v) = setindex!(mq.f, v)
Base.getindex(mq::MultQueue) = mq.f[]
Base.getindex(mq::MultQueue, i) = mq.q[i]*mq.f[]
