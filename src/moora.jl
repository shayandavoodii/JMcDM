module MOORA 

export moora, MooraMethod, MooraResult

import ..MCDMMethod, ..MCDMResult, ..MCDMSetting
using ..Utilities 

using DataFrames 

struct MooraMethod <: MCDMMethod 
    method::Symbol
end 

MooraMethod() :: MooraMethod = MooraMethod(:reference)

struct MooraResult <: MCDMResult
    mooraType::Symbol
    decisionMatrix::DataFrame
    weights::Array{Float64,1}
    weightedDecisionMatrix::DataFrame
    referenceMatrix::Union{DataFrame, Nothing}
    scores::Vector
    bestIndex::Int64
end

function Base.show(io::IO, result::MooraResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end


"""
        moora_ref(decisionMat, weights, fns)

Apply MOORA (Multi-Objective Optimization By Ratio Analysis) method for a given matrix and weights.

# Arguments:
 - `decisionMat::DataFrame`: n × m matrix of objective values for n candidate (or strategy) and m criteria 
 - `weights::Array{Float64, 1}`: m-vector of weights that sum up to 1.0. If the sum of weights is not 1.0, it is automatically normalized.
 - `fns::Array{Function, 1}`: m-vector of function that are either maximum or minimum.

# Description 
moora() applies the MOORA method to rank n strategies subject to m criteria which are supposed to be 
either maximized or minimized. Note that this is the reference version of the MOORA method. For the 
ratio method, look at `moora_ratio`.  

# Output 
- `::MooraResult`: MooraResult object that holds multiple outputs including scores and best index.

# Examples
```julia-repl
julia> w =  [0.110, 0.035, 0.379, 0.384, 0.002, 0.002, 0.010, 0.077];

julia> Amat = [
             100 92 10 2 80 70 95 80 ;
             80  70 8  4 100 80 80 90 ;
             90 85 5 0 75 95 70 70 ; 
             70 88 20 18 60 90 95 85
           ];

julia> dmat = makeDecisionMatrix(Amat)
4×8 DataFrame
 Row │ Crt1     Crt2     Crt3     Crt4     Crt5     Crt6     Crt7     Crt8    
     │ Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64 
─────┼────────────────────────────────────────────────────────────────────────
   1 │   100.0     92.0     10.0      2.0     80.0     70.0     95.0     80.0
   2 │    80.0     70.0      8.0      4.0    100.0     80.0     80.0     90.0
   3 │    90.0     85.0      5.0      0.0     75.0     95.0     70.0     70.0
   4 │    70.0     88.0     20.0     18.0     60.0     90.0     95.0     85.0

julia> fns = makeminmax([maximum, maximum, maximum, maximum, maximum, maximum, maximum, maximum]);

julia> result = moora(dmat, w, fns)

julia> result.scores
4-element Array{Float64,1}:
 0.3315938731541169
 0.2901446390098523
 0.3730431072983815
 0.019265256092245782

julia> result.bestIndex
4
```

# References
Celikbilek Yakup, Cok Kriterli Karar Verme Yontemleri, Aciklamali ve Karsilastirmali
Saglik Bilimleri Uygulamalari ile. Editor: Muhlis Ozdemir, Nobel Kitabevi, Ankara, 2018

İşletmeciler, Mühendisler ve Yöneticiler için Operasyonel, Yönetsel ve Stratejik Problemlerin
Çözümünde Çok Kriterli Karar verme Yöntemleri, Editörler: Bahadır Fatih Yıldırım ve Emrah Önder,
Dora, 2. Basım, 2015, ISBN: 978-605-9929-44-8
"""
function moora_ref(decisionMat::DataFrame, weights::Array{Float64,1}, fns::Array{Function,1})::MooraResult

    w = unitize(weights)

    nalternatives, ncriteria = size(decisionMat)

    normalizedMat = normalize(decisionMat)
    weightednormalizedMat = w * normalizedMat

    # cmaxs = colmaxs(weightednormalizedMat)
    cmaxs = apply_columns(fns, weightednormalizedMat)
    cmins = apply_columns(reverseminmax(fns), weightednormalizedMat)

    refmat = similar(weightednormalizedMat)
    
    #=
    # This implementation is buggy and will be removed 
    # in later releases. 
    # note: the problem is fns[rowind] is non-sense
    # because fns are due to columns not rows.
    for rowind in 1:nalternatives
        if fns[rowind] == maximum 
            refmat[rowind, :] .= cmaxs - weightednormalizedMat[rowind, :]
        elseif fns[rowind] == minimum
            refmat[rowind, :] .= weightednormalizedMat[rowind, :] - cmins
        else
            @warn fns[rowind]
            error("Function must be either maximize or minimize")
        end
    end
    =#

    for rowind in 1:nalternatives
        for colind in 1:ncriteria
            if fns[colind] == maximum 
                refmat[rowind, colind] = cmaxs[colind] - weightednormalizedMat[rowind, colind]
            elseif fns[colind] == minimum
                refmat[rowind, colind] = weightednormalizedMat[rowind, colind] - cmins[colind]
            else
                @warn fns[colind]
                error("Function must be either maximize or minimize")
            end
        end
    end

    scores = rmaxs = rowmaxs(refmat)

    bestIndex = sortperm(rmaxs) |> first 

    result = MooraResult(
       :reference, 
       decisionMat,
       w,
       weightednormalizedMat,
       refmat,
       scores,
       bestIndex
   )

    return result
end



"""
        moora_ratio(decisionMat, weights, fns)

Apply MOORA (Multi-Objective Optimization By Ratio Analysis) method for a given matrix and weights.

# Arguments:
 - `decisionMat::DataFrame`: n × m matrix of objective values for n candidate (or strategy) and m criteria 
 - `weights::Array{Float64, 1}`: m-vector of weights that sum up to 1.0. If the sum of weights is not 1.0, it is automatically normalized.
 - `fns::Array{Function, 1}`: m-vector of function that are either maximum or minimum.

# Description 
moora() applies the MOORA method to rank n strategies subject to m criteria which are supposed to be 
either maximized or minimized. Note that this is the ratio version of the MOORA method. For the 
reference method, look at `moora_ref`.  

# Output 
- `::MooraResult`: MooraResult object that holds multiple outputs including scores and best index.


# References
KUNDAKCI, Nilsen. "Combined multi-criteria decision making approach based on MACBETH 
and MULTI-MOORA methods." Alphanumeric Journal 4.1 (2016): 17-26.
"""
function moora_ratio(decisionMat::DataFrame, weights::Array{Float64,1}, fns::Array{Function,1})::MooraResult
    w = unitize(weights)

    nalternatives, ncriteria = size(decisionMat)

    mat = Matrix(decisionMat)
    normalizedMatrix = similar(mat)
    weightednormalizedMat = similar(mat)

    zerotype = eltype(mat[1, :])
    
    for i in 1:ncriteria
        normalizedMatrix[:, i] = mat[:, i] ./ sqrt(sum(mat[:, i] .^ 2.0))
        weightednormalizedMat[:, i] = normalizedMatrix[:, i] .* w[i]
    end

    scores = zeros(zerotype, nalternatives)
    
    for i in 1:nalternatives
        for j in 1:ncriteria
            if fns[j] == maximum 
                scores[i] += weightednormalizedMat[i, j]
            elseif fns[j] == minimum
                scores[i] -= weightednormalizedMat[i, j]
            else
                error("In Moora, direction of optimization must be either minimum or maximum.")
            end
        end
    end

    bestIndex = scores |> sortperm |> last  

    return MooraResult(
        :ratio, 
       decisionMat,
       w,
       DataFrame(weightednormalizedMat, :auto),
       nothing, # refmat
       scores,
       bestIndex
    )
end


"""
        moora_ratio(decisionMat, weights, fns; method = :reference)

Apply MOORA (Multi-Objective Optimization By Ratio Analysis) method for a given matrix and weights.

# Arguments:
 - `decisionMat::DataFrame`: n × m matrix of objective values for n candidate (or strategy) and m criteria 
 - `weights::Array{Float64, 1}`: m-vector of weights that sum up to 1.0. If the sum of weights is not 1.0, it is automatically normalized.
 - `fns::Array{Function, 1}`: m-vector of function that are either maximum or minimum.
 - `method::Symbol`: Either `:reference` or `:ratio`. By default, it is `:reference`.


# Description 
moora() applies the MOORA method to rank n strategies subject to m criteria which are supposed to be 
either maximized or minimized. This method has two different versions. The method parameter determines the method used. It is `:reference` by default. For the other version, it can be set to `:ratio`.  

# Output 
- `::MooraResult`: MooraResult object that holds multiple outputs including scores and best index.


# References
KUNDAKCI, Nilsen. "Combined multi-criteria decision making approach based on MACBETH 
and MULTI-MOORA methods." Alphanumeric Journal 4.1 (2016): 17-26.

Celikbilek Yakup, Cok Kriterli Karar Verme Yontemleri, Aciklamali ve Karsilastirmali
Saglik Bilimleri Uygulamalari ile. Editor: Muhlis Ozdemir, Nobel Kitabevi, Ankara, 2018

İşletmeciler, Mühendisler ve Yöneticiler için Operasyonel, Yönetsel ve Stratejik Problemlerin
Çözümünde Çok Kriterli Karar verme Yöntemleri, Editörler: Bahadır Fatih Yıldırım ve Emrah Önder,
Dora, 2. Basım, 2015, ISBN: 978-605-9929-44-8
"""
function moora(decisionMat::DataFrame, weights::Array{Float64,1}, fns::Array{Function,1}; method::Symbol = :reference)::MooraResult
    if method == :reference 
        return moora_ref(decisionMat, weights, fns)
    elseif method == :ratio 
        return moora_ratio(decisionMat, weights, fns)
    else
        @error "Method not found: " method 
        @error "Moora is defined for methods :reference and :ratio"
        error("Terminating.")
    end
end


"""
        moora(setting; method = :reference)

Apply MOORA (Multi-Objective Optimization By Ratio Analysis) method for a given matrix and weights.

# Arguments:
 - `setting::MCDMSetting`: MCDMSetting object. 
 - `method::Symbol`: Either `:reference` or `:ratio`. By default, it is `:reference`.

# Description 
moora() applies the MOORA method to rank n strategies subject to m criteria which are supposed to be either maximized or minimized.

# Output 
- `::MooraResult`: MooraResult object that holds multiple outputs including scores and best index.
"""
function moora(setting::MCDMSetting; method::Symbol = :reference)::MooraResult
    moora(
        setting.df,
        setting.weights,
        setting.fns,
        method = method
    )
end 


function moora(mat::Matrix, weights::Array{Float64,1}, fns::Array{Function,1}; method::Symbol = :reference)::MooraResult
    moora(
        makeDecisionMatrix(mat),
        weights,
        fns,
        method = method
    )
end 

end # end of module MOORA 