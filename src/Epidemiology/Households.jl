mutable struct Households
    individualID::Vector{Int64}
    gridID::Vector{Int64}
    householdID::Vector{Int64}
    infection_status::Matrix{Int64}
    numhouseholds::Vector{Int64}

    function Households(individualID::Vector{Int64}, gridID::Vector{Int64}, householdID::Vector{Int64}, infection_status::Matrix{Int64}, numhouseholds::Vector{Int64})
        length(individualID) == length(gridID) || throw(DimensionMismatch("Number of individuals in grid IDs doesn't match individual IDs"))
        length(individualID) == length(householdID) || throw(DimensionMismatch("Number of individuals in household IDs doesn't match individual IDs"))
        size(infection_status, 1) == length(individualID) || throw(DimensionMismatch("Number of individuals in infection status doesn't match IDs"))
        return new(individualID, gridID, householdID, infection_status, numhouseholds)
    end
end
function emptyHouseholds(totalpop::Int64, numclasses::Int64, numhouseholds::Vector{Int64})
    ids = collect(1:totalpop)
    return Households(ids, fill(0, totalpop), fill(0, totalpop), fill(0, totalpop, numclasses), numhouseholds)
end

function instantiate_households!(ml::EpiLandscape, hh::Households)
    # Find location on grid
    hh.gridID .= vcat(map(i -> fill(i, sum(ml.matrix[:, i])), 1:size(ml.matrix, 2))...)

    # Assign randomly to a household and infection status
    for j in unique(hh.gridID)
        grid_indivs = hh.individualID[hh.gridID .== j]
        start = hh.numhouseholds[j] * j
        hh.householdID[grid_indivs] .= rand((start - hh.numhouseholds[j] + 1):start, length(grid_indivs))
        samp = cumsum(ml.matrix[:, j])
        for i in 1:length(samp)
            ordered_indivs = grid_indivs[(samp[i]-ml.matrix[i, j] + 1):samp[i]]
            hh.infection_status[ordered_indivs, i] .+= 1
        end
    end
    sum(hh.infection_status) == length(hh.individualID) || error("Infection status does not match number of individuals")
end