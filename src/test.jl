using NewtonMethods
using LinearAlgebra: Diagonal, I, Symmetric
using Roots: fzero

include("types.jl")
include("base.jl")
include("invert.jl")

println("Running test...")
println("Make synthetic data...")

m0 = [2,1.2,0.1,0.15,0.03,deg2rad(28), deg2rad(39), deg2rad(58), deg2rad(90),deg2rad(58),deg2rad(90)]
ρ = 1.

C0 = thomsen2moduli(m0[1],m0[2],ρ,m0[3],m0[4],m0[5])

np=4
nsv=0
nsh=2

args = (np, nsv, nsh)

dobs = _gt(m0, np, nsv, nsh)

p = [VMeasure(dobs[2k-1],exp(dobs[2k]),.01,0.01) for k in 1:np]
sv = [VMeasure(dobs[2np+2k-1],exp(dobs[2np+2k]),.01,0.01) for k in 1:nsv]
sh = [VMeasure(dobs[2np+2nsv+2k-1],exp(dobs[2np+2nsv+2k]),.01,0.01) for k in 1:nsh]

# a prior moel parameters
m1 = [2.2,1.5,0.0,0.0,0.,deg2rad(25), deg2rad(40), deg2rad(55), deg2rad(90),deg2rad(90)]

C1 = thomsen2moduli(m1[1],m1[2],ρ,m1[3],m1[4],m1[5])

# run inversion thomsen
println("Run inversion to find Thomsen parameters...")

m, anglep, anglesv, anglesh, cm = findthomsen(p,sv,sh, m1[1], m1[2], m1[3], m1[4], m1[5])

println()
println("Model parameters: input | inverted")
show(IOContext(stdout), "text/plain",[m0[1:5]  m])
println()
println()
dcalc = _gt(vcat(m, anglep, anglesv, anglesh), np, nsv, nsh)
println("Observations: obs | calc")
show(IOContext(stdout), "text/plain",[dobs  dcalc])
println()

# run inversion moduli
println("Run inversion to find moduli...")

C, anglep, anglesv, anglesh, cm = findmoduli(p,sv,sh, ρ, C1[1,1], C1[1,3], C1[3,3], C1[5,5], C1[6,6], 100)

m = vcat([C[1,1], C[1,3], C[3,3], C[5,5], C[6,6]], anglep, anglesv, anglesh)

println()
println("Model parameters: input | inverted")
show(IOContext(stdout), "text/plain",C0)
println("\n------")
show(IOContext(stdout), "text/plain",C)
println()
println()
dcalc = _gc(m, ρ, np, nsv, nsh)
println("Observations: obs | calc")
show(IOContext(stdout), "text/plain",[dobs  dcalc])
