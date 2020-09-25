

function question(io::IO, qt::Symbol, q, context, answers...)
    out = _writeq(Val(qt), q, context, answers...)
    println(io, out)
end

function question(io::IO, qt::Symbol, q)
    qt ∈ (:ESS, FIL) || throw(ArgumentError("need to specify a context and an answer"))
    question(io, qt, q, ())
end

export question

## https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Reuse_Questions/Upload_Questions
## upload question types

const NUM = :NUM # numeric: answer, [tolerance]
const MC = :MC   # multiple choice: ("ans1" => true, "ans2" => false, ...)
const MA = :MA   # multiple answer: ("ans1" => true, "ans2" => false, "ans3" => true, ...)
const TR = :TR   # tru false: answer::Bool
const FIB = :FIB # fill in blank: answer = ("ans1", "ans2", ...)
const ESS = :ESS # Essay: no answer given
const SR = :SR   # short reponse: answer = short_response
const FIL = :FIL  # File upload: no answer

export NUM, MC, MA, TR, FIB, ESS, SR, FIL



# answer, [tolerance]
function _writeq(::Val{:NUM}, q, context, answer, tolerance=nothing)
    qq = create_html(q, context)
    if isnothing(tolerance)
        out = "NUM\t$qq\t$answer"
    else
        out = "NUM\t$qq\t$answer\t$tolerance"
    end
    return out
end
        
# answers = ("ans1"=>true, "ans2"=>false, ...)
function _writeq(::Val{:MC}, q, context, answers)
    qq = create_html(q, context)
    io = IOBuffer()
    print(io, "MC"); print(io, "\t")
    print(io, qq)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, context, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
    out = String(take!(io))
    out
end

# answers = ("ans1"=>true, "ans2"=>false, ...)
function _writeq(::Val{:MA}, q, context, answers)
    qq = create_html(q, context)
    io = IOBuffer()
    print(io, "MA"), print(io, "\t")
    print(io, qq)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, context, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
    out = String(take!(io))
end

# answer [true | false]
function _writeq(::Val{:TR}, q, context, answer::Bool)
    qq = create_html(q, context)
    "TR\t$qq\t$(string(answer))"
end

# q = "...() ... () ..."
# answers = (ans1, ..., ansn)
function _writeq(::Val{:FIB}, q, context, answers)
    qq = create_html(q, context)
    io = IOBuffer()
    print(io, "FIB\t")
    print(io, qq); print(io, "\t")
    print(io, join(answers, "\t"))
    out = String(take!(io))
    out
end

function _writeq(::Val{:ESS}, q, context, answers...)
    qq = create_html(q, context)
    "ESS\t$qq"
end


function _writeq(::Val{:SR}, q, context, answers...)
    qq = create_html(q, context)
    sa = create_html(first(answers), (), strip=true)
    "SR\t$qq\t$sa"
end

function _writeq(::Val{:FIL}, q, context=(), answers...)
    qq = create_html(q, context)
    "FIL\t$qq"
end

