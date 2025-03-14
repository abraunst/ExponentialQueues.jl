using ExponentialQueues
using Test
using Random


@testset "ExponentialQueue" begin
    e = ExponentialQueue([5=>10.0, 10=>0.0])
    i,t = peek(e)
    @test i == 5
    @test !isempty(e)
    i,t = pop!(e)
    @test i == 5
    @test isempty(e)
    e[10] = 5
    empty!(e)
    @test isempty(e)
end

@testset "ExponentialQueueDict" begin
    e = ExponentialQueueDict{String}()
    e["event1"] = 5
    e["event1"] = 0
    @test !haskey(e, "event1")
    e["event1"] = 10
    @test e["event2"] == 0
    @test (e["event1"] = 10; e["event1"] == 10)
    i,t = peek(e)
    @test i == "event1"
    @test !isempty(e)
    i,t = pop!(e)
    @test i == "event1"
    @test isempty(e)
    e = ExponentialQueueDict{}()
    e[1000] = 10
    empty!(e)
    @test isempty(e)
    e1 = ExponentialQueue()
    @test string(e1) == "ExponentialQueue(Pair{Int64, Float64}[])"
    events = Dict(1 => 1.0, 2 => 2.0, 3 => 3.0)
    for (k,r) in events
        e1[k] = r
    end
    e2 = ExponentialQueueDict(events)
    @test e1 == e2
    @test string(e2) == "ExponentialQueueDict([2 => 2.0, 3 => 3.0, 1 => 1.0])"
    @test Set(keys(events)) == Set(keys(e2))
    @test Set(values(events)) == Set(values(e2))

    e4 = ExponentialQueueDict(["A"=>1//2, "B"=>1//4, "C"=>1//4])
    @test eltype(e4) == Pair{String,Rational{Int}}
    e5 = ExponentialQueueDict(["A"=>1/2, "B"=>1/4, "C"=>1/4])
    @test e4 == e5
end

@testset "Reproducibility" begin
    Q = ExponentialQueue(i=>i for i in 1:1000)
    C = ConstantQueue(1:10, 0.5)
    N = NestedQueue(:a => Q, :b => 2Q, :c => 3Q, :d => 2C)
    for i in 1:10
        x1 = peek(N; rng = MersenneTwister(0))
        x2 = peek(N; rng = MersenneTwister(0))
        @test x1 == x2
    end
end

@testset "ConstantQueue" begin
    C = ConstantQueue('a':'f', 0.5)
    @test C['a'] == 0.5
    @test !haskey(C, 'g')
    @test peekevent(C) ∈ 'a':'f'
end

@testset "NestedQueue" begin
    Q = ExponentialQueue(i=>i for i in 1:10)
    N = NestedQueue(i => i*Q for i in 20:30)
    i,j = peekevent(N)
    @test i ∈ 20:30 && j ∈ 1:10
end

nothing
