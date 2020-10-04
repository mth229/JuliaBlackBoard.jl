using JuliaBlackBoard
## Authoring a test using pools means creating several differnt .txt files
## This shows how they can all be generated from one script
## The basic idea is to use `POOL` defined below to open a new pool
## file to write to for each desired pool (in the directory of the script)
##
## One way to use
## Author a test without randomization. Once happy,
## edit each file to be randomized to add the `POOL(i) do iop` call
## and randomize the question
##

OPEN(f) = JuliaBlackBoard._OPEN(f, @__FILE__)
POOL(f, i) = JuliaBlackBoard._POOL(f, i, @__FILE__)
STUB(io, i) = question(io, OP, "XXX REPLACE ME XXX: PUT pool $i here")

OPEN() do io

    q = mt"""
    # Question 1

How goes?
"""
    question(io, ESS, q)

    ## Pool question 1
    ## written to script_directory/script_name-pool-i.txt where i is 1 below
    STUB(io, 1)
    POOL(1) do iop
        q = mt"""
# Addition

${{:n}} + {{:m}} = $ ?
"""

        for n in 2:5, m in 2:5
            question(iop, NUM, q(n=n,m=m), n+m)
        end
    end

    ## Pool qustion 2
    STUB(io, 2)    
    POOL(2) do iop
        q = mt"""
# Times tables:

${{:n}} * {{:m}} =$ ?
"""
        for n in 2:7, m in 2:7
            question(iop, NUM, q(n=n,m=m), n*m)
        end
    end


    
end
        
