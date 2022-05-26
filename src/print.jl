

function Base.show(io::IO, result::ARASResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Orderings: ")
    println(io, result.orderings)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end



function Base.show(io::IO, result::CODASResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end


function Base.show(io::IO, result::COPRASResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::CRITICResult)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::CoCoSoResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::EDASResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::ElectreResult)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::GreyResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ordering)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::MABACResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::MAIRCAResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::MARCOSResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::MooraResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::MoosraMethod)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: (from worst to best)")
    println(io, result.rankings)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end


