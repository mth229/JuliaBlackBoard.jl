using JuliaBlackBoard
using Test

@testset "JuliaBlackBoard.jl" begin
    d = tempdir()
    cdir = @__DIR__
    cp(joinpath(cdir, "test-setup.jl"), joinpath(d,"test-setup.jl"), force=true)
    include(joinpath(d, "test-setup.jl"))
end
