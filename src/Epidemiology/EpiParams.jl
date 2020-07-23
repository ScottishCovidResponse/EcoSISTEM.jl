using Unitful
using LinearAlgebra
using DataFrames

"""
    SIRGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SIR model, as well as growth and decay of virus, and infection/recovery parameters.
"""
mutable struct SIRGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      sigma::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SIRGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}}, age_mixing::Matrix{Float64}, virus_growth::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, sigma::Vector{TimeUnitType{U}};
        freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("Age mixing matrix is not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth, virus_decay, beta_force, beta_env, sigma, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SIRGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, sigma::TimeUnitType{U};
        freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || error("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth], virus_decay, [beta_force], [beta_env], [sigma], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

"""
    SISGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SIS model, as well as growth and decay of virus, and infection/recovery parameters.
"""
mutable struct SISGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      sigma::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SISGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}}, age_mixing::Matrix{Float64}, virus_growth::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, sigma::Vector{TimeUnitType{U}}; freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("age_mixing parameters are not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth, virus_decay, beta_force, beta_env, sigma, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SISGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, sigma::TimeUnitType{U}; freq_vs_density_force::Float64 = 1.0,
        freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || error("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth], virus_decay, [beta_force], [beta_env], [sigma], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

"""
    SEIRGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SEIR model, as well as growth and decay of virus, and infection/incubation/recovery parameters.
"""
mutable struct SEIRGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      mu::Vector{TimeUnitType{U}}
      sigma::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SEIRGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}},
        age_mixing::Matrix{Float64},  virus_growth::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, mu::Vector{TimeUnitType{U}}, sigma::Vector{TimeUnitType{U}}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("age_mixing parameters are not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth, virus_decay, beta_force, beta_env, mu, sigma, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SEIRGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, mu::TimeUnitType{U}, sigma::TimeUnitType{U}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || error("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth], virus_decay, [beta_force], [beta_env], [mu], [sigma], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

"""
    SEIRSGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SEIRS model, as well as growth and decay of virus, and infection/incubation/recovery parameters.
"""
mutable struct SEIRSGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      mu::Vector{TimeUnitType{U}}
      sigma::Vector{TimeUnitType{U}}
      epsilon::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SEIRSGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}},
        age_mixing::Matrix{Float64}, virus_growth::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, mu::Vector{TimeUnitType{U}}, sigma::Vector{TimeUnitType{U}}, epsilon::Vector{TimeUnitType{U}}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("age_mixing parameters are not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth, virus_decay, beta_force, beta_env, mu, sigma, epsilon, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SEIRSGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, mu::TimeUnitType{U}, sigma::TimeUnitType{U}, epsilon::TimeUnitType{U}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || ("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth], virus_decay, [beta_force], [beta_env], [mu], [sigma], [epsilon], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

"""
    SEI2HRDGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SEI2HRD model, as well as growth and decay of virus, and infection/incubation/hospitalisation/recovery parameters.
"""
mutable struct SEI2HRDGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth_asymp::Vector{TimeUnitType{U}}
      virus_growth_symp::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      sigma_1::Vector{TimeUnitType{U}}
      sigma_2::Vector{TimeUnitType{U}}
      sigma_hospital::Vector{TimeUnitType{U}}
      mu_1::Vector{TimeUnitType{U}}
      mu_2::Vector{TimeUnitType{U}}
      hospitalisation::Vector{TimeUnitType{U}}
      death_home::Vector{TimeUnitType{U}}
      death_hospital::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SEI2HRDGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}},
        age_mixing::Matrix{Float64}, virus_growth_asymp::Vector{TimeUnitType{U}},
        virus_growth_symp::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, sigma_1::Vector{TimeUnitType{U}},
        sigma_2::Vector{TimeUnitType{U}},
        sigma_hospital::Vector{TimeUnitType{U}},
        mu_1::Vector{TimeUnitType{U}},
        mu_2::Vector{TimeUnitType{U}},
        hospitalisation::Vector{TimeUnitType{U}},
        death_home::Vector{TimeUnitType{U}},
        death_hospital::Vector{TimeUnitType{U}}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("age_mixing parameters are not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth_asymp, virus_growth_symp, virus_decay, beta_force, beta_env, sigma_1,
        sigma_2, sigma_hospital, mu_1, mu_2, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SEI2HRDGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth_asymp::TimeUnitType{U},
        virus_growth_symp::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, sigma_1::TimeUnitType{U},
        sigma_2::TimeUnitType{U},
        sigma_hospital::TimeUnitType{U},
        mu_1::TimeUnitType{U},
        mu_2::TimeUnitType{U},
        hospitalisation::TimeUnitType{U},
        death_home::TimeUnitType{U},
        death_hospital::TimeUnitType{U}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || ("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth_asymp], [virus_growth_symp], virus_decay, [beta_force], [beta_env], [sigma_1], [sigma_2], [sigma_hospital], [mu_1], [mu_2], [hospitalisation], [death_home], [death_hospital], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

"""
SEI2HRDGrowth(birth::Vector{TimeUnitType{U}},
    death::Vector{TimeUnitType{U}}, beta::TimeUnitType{U}, prob_sym::Float64, prob_hosp::Float64, case_fatality_ratio::Float64, T_lat::Unitful.Time, T_asym::Unitful.Time, T_sym::Unitful.Time, T_hosp::Unitful.Time, T_rec::Unitful.Time) where {U <: Unitful.Units}

Function to calculate SEI2HRD parameters from initial probabilities of developing symptoms and needing hospitalisation, case fatality ratio, and time for transition between different categories.
"""
function SEI2HRDGrowth(birth::Vector{TimeUnitType{U}},
    death::Vector{TimeUnitType{U}}, virus_growth_asymp::TimeUnitType{U},
    virus_growth_symp::TimeUnitType{U},
    virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U},
    prob_sym::Float64, prob_hosp::Float64, cfr_home::Float64, cfr_hosp::Float64,
    T_lat::Unitful.Time, T_asym::Unitful.Time, T_sym::Unitful.Time,
    T_hosp::Unitful.Time, T_rec::Unitful.Time, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}
    # Exposed -> asymptomatic
    mu_1 = 1/T_lat
    # Asymptomatic -> symptomatic
    mu_2 = prob_sym * 1/T_asym
    # Symptomatic -> hospital
    hospitalisation = prob_hosp * 1/T_sym
    # Asymptomatic -> recovered
    sigma_1 = (1 - prob_sym) * 1/T_asym
    # Symptomatic -> recovered
    sigma_2 = (1 - prob_hosp) * (1 - cfr_home) * 1/T_rec
    # Hospital -> recovered
    sigma_hospital = (1 - cfr_hosp) * 1/T_hosp
    # Symptomatic -> death
    death_home = cfr_home * 2/T_hosp
    # Hospital -> death
    death_hospital = cfr_hosp * 1/T_hosp
    return SEI2HRDGrowth{U}(birth, death, virus_growth_asymp, virus_growth_symp, virus_decay, beta_force, beta_env,
    sigma_1, sigma_2, sigma_hospital, mu_1, mu_2, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
end

function SEI2HRDGrowth(birth::Matrix{TimeUnitType{U}},
    death::Matrix{TimeUnitType{U}},
    age_mixing::Matrix{Float64},  virus_growth_asymp::Vector{TimeUnitType{U}},
    virus_growth_symp::Vector{TimeUnitType{U}},
    virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}},
    prob_sym::Vector{Float64}, prob_hosp::Vector{Float64}, cfr_home::Vector{Float64}, cfr_hosp::Vector{Float64},
    T_lat::Unitful.Time, T_asym::Unitful.Time, T_sym::Unitful.Time,
    T_hosp::Unitful.Time, T_rec::Unitful.Time, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}
    # Exposed -> asymptomatic
    mu_1 = fill(1/T_lat, length(beta_force))
    # Asymptomatic -> symptomatic
    mu_2 = prob_sym .* 1/T_asym
    # Symptomatic -> hospital
    hospitalisation = prob_hosp .* 1/T_sym
    # Asymptomatic -> recovered
    sigma_1 = (1 .- prob_sym) .* 1/T_asym
    # Symptomatic -> recovered
    sigma_2 = (1 .- prob_hosp) .* (1 .- cfr_home) .* 1/T_rec
    # Hospital -> recovered
    sigma_hospital = (1 .- cfr_hosp) .* 1/T_hosp
    # Symptomatic -> death
    death_home = cfr_home .* 2/T_hosp
    # Hospital -> death
    death_hospital = cfr_hosp .* 1/T_hosp
    return SEI2HRDGrowth{U}(birth, death, age_mixing,  virus_growth_asymp, virus_growth_symp, virus_decay, beta_force, beta_env, sigma_1, sigma_2, sigma_hospital, mu_1, mu_2, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
end



"""
    SEI3HRDGrowth{U <: Unitful.Units} <: AbstractParams

Parameter set that houses information on birth and death rates of different classes in an SEI3HRD model, as well as growth and decay of virus, and infection/incubation/hospitalisation/recovery parameters.
"""
mutable struct SEI3HRDGrowth{U <: Unitful.Units} <: AbstractParams
      birth::Matrix{TimeUnitType{U}}
      death::Matrix{TimeUnitType{U}}
      age_mixing::Matrix{Float64}
      virus_growth_asymp::Vector{TimeUnitType{U}}
      virus_growth_presymp::Vector{TimeUnitType{U}}
      virus_growth_symp::Vector{TimeUnitType{U}}
      virus_decay::TimeUnitType{U}
      beta_force::Vector{TimeUnitType{U}}
      beta_env::Vector{TimeUnitType{U}}
      sigma_1::Vector{TimeUnitType{U}}
      sigma_2::Vector{TimeUnitType{U}}
      sigma_hospital::Vector{TimeUnitType{U}}
      mu_1::Vector{TimeUnitType{U}}
      mu_2::Vector{TimeUnitType{U}}
      mu_3::Vector{TimeUnitType{U}}
      hospitalisation::Vector{TimeUnitType{U}}
      death_home::Vector{TimeUnitType{U}}
      death_hospital::Vector{TimeUnitType{U}}
      freq_vs_density_force::Float64
      freq_vs_density_env::Float64
      env_virus_scale::Float64

    # Multiple age categories
    function SEI3HRDGrowth{U}(birth::Matrix{TimeUnitType{U}},
        death::Matrix{TimeUnitType{U}},
        age_mixing::Matrix{Float64}, virus_growth_asymp::Vector{TimeUnitType{U}},
        virus_growth_presymp::Vector{TimeUnitType{U}},
        virus_growth_symp::Vector{TimeUnitType{U}}, virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}}, sigma_1::Vector{TimeUnitType{U}},
        sigma_2::Vector{TimeUnitType{U}},
        sigma_hospital::Vector{TimeUnitType{U}},
        mu_1::Vector{TimeUnitType{U}},
        mu_2::Vector{TimeUnitType{U}},
        mu_3::Vector{TimeUnitType{U}},
        hospitalisation::Vector{TimeUnitType{U}},
        death_home::Vector{TimeUnitType{U}},
        death_hospital::Vector{TimeUnitType{U}}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        size(birth) == size(death) || error("Birth and death vector lengths differ")
        all(beta_force .!= 0/day) & all(beta_env .!= 0/day) || warning("Transmission rates are zero.")
        size(age_mixing, 1) == size(birth, 2) || error("age_mixing parameters are not the correct length")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        return new{U}(birth, death, age_mixing, virus_growth_asymp, virus_growth_presymp, virus_growth_symp, virus_decay, beta_force, beta_env, sigma_1,
        sigma_2, sigma_hospital, mu_1, mu_2, mu_3, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
    # Single age category
    function SEI3HRDGrowth{U}(birth::Vector{TimeUnitType{U}},
        death::Vector{TimeUnitType{U}}, virus_growth_asymp::TimeUnitType{U},
        virus_growth_presymp::TimeUnitType{U},
        virus_growth_symp::TimeUnitType{U}, virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U}, sigma_1::TimeUnitType{U},
        sigma_2::TimeUnitType{U},
        sigma_hospital::TimeUnitType{U},
        mu_1::TimeUnitType{U},
        mu_2::TimeUnitType{U},
        mu_3::TimeUnitType{U},
        hospitalisation::TimeUnitType{U},
        death_home::TimeUnitType{U},
        death_hospital::TimeUnitType{U}, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

        length(birth) == length(death) || ("Birth and death vector lengths differ")
        (beta_force != 0/day) & (beta_env != 0/day) || warning("Transmission rate is zero.")
        (freq_vs_density_force <= 1) & (freq_vs_density_force >= 0) || error("Frequency/density balance must be 0-1")
        (freq_vs_density_env <= 1) & (freq_vs_density_env >= 0) || error("Frequency/density balance must be 0-1")

        new_birth = reshape(birth, length(birth), 1)
        new_death = reshape(birth, length(death), 1)
        age_mixing = fill(1.0, 1, 1)
        return new{U}(new_birth, new_death, age_mixing, [virus_growth_asymp], [virus_growth_presymp], [virus_growth_symp], virus_decay, [beta_force], [beta_env], [sigma_1], [sigma_2], [sigma_hospital], [mu_1], [mu_2], [mu_3], [hospitalisation], [death_home], [death_hospital], freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

function SEI3HRDGrowth(birth::Vector{TimeUnitType{U}},
    death::Vector{TimeUnitType{U}}, virus_growth_asymp::TimeUnitType{U},
    virus_growth_presymp::TimeUnitType{U},
    virus_growth_symp::TimeUnitType{U},
    virus_decay::TimeUnitType{U}, beta_force::TimeUnitType{U}, beta_env::TimeUnitType{U},
    prob_sym::Float64, prob_hosp::Float64, cfr_home::Float64, cfr_hosp::Float64,
    T_lat::Unitful.Time, T_asym::Unitful.Time, T_presym::Unitful.Time, T_sym::Unitful.Time,
    T_hosp::Unitful.Time, T_rec::Unitful.Time, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

    # Exposed -> asymptomatic
    mu_1 = (1 - prob_sym) * 1/T_lat
    # Exposed -> Pre-symptomatic
    mu_2 = prob_sym * 1/T_lat
    # Pre-symptomatic -> symptomatic
    mu_3 = 1/T_presym
    # Symptomatic -> hospital
    hospitalisation = prob_hosp * 1/T_sym
    # Asymptomatic -> recovered
    sigma_1 = 1/T_asym
    # Symptomatic -> recovered
    sigma_2 = (1 - prob_hosp) * (1 - cfr_home) * 1/T_rec
    # Hospital -> recovered
    sigma_hospital = (1 - cfr_hosp) * 1/T_hosp
    # Symptomatic -> death
    death_home = cfr_home * 2/T_hosp
    # Hospital -> death
    death_hospital = cfr_hosp * 1/T_hosp
    return SEI3HRDGrowth{U}(birth, death, virus_growth_asymp, virus_growth_presymp, virus_growth_symp, virus_decay, beta_force, beta_env,
    sigma_1, sigma_2, sigma_hospital, mu_1, mu_2, mu_3, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
end

function SEI3HRDGrowth(birth::Matrix{TimeUnitType{U}},
    death::Matrix{TimeUnitType{U}},
    age_mixing::Matrix{Float64},  virus_growth_asymp::Vector{TimeUnitType{U}},
    virus_growth_presymp::Vector{TimeUnitType{U}},
    virus_growth_symp::Vector{TimeUnitType{U}},
    virus_decay::TimeUnitType{U}, beta_force::Vector{TimeUnitType{U}}, beta_env::Vector{TimeUnitType{U}},
    prob_sym::Vector{Float64}, prob_hosp::Vector{Float64}, cfr_home::Vector{Float64}, cfr_hosp::Vector{Float64},
    T_lat::Unitful.Time, T_asym::Unitful.Time, T_presym::Unitful.Time, T_sym::Unitful.Time,
    T_hosp::Unitful.Time, T_rec::Unitful.Time, freq_vs_density_force::Float64 = 1.0, freq_vs_density_env::Float64 = 1.0, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}

    # Exposed -> asymptomatic
    mu_1 = (1 .- prob_sym) .* 1/T_lat
    # Exposed -> Pre-symptomatic
    mu_2 = prob_sym .* 1/T_lat
    # Pre-symptomatic -> symptomatic
    mu_3 = fill(1/T_presym, length(beta_force))
    # Symptomatic -> hospital
    hospitalisation = prob_hosp .* 1/T_sym
    # Asymptomatic -> recovered
    sigma_1 = (1 .- prob_sym) .* 1/T_asym
    # Symptomatic -> recovered
    sigma_2 = (1 .- prob_hosp) .* (1 .- cfr_home) .* 1/T_rec
    # Hospital -> recovered
    sigma_hospital = (1 .- cfr_hosp) .* 1/T_hosp
    # Symptomatic -> death
    death_home = cfr_home .* 2/T_hosp
    # Hospital -> death
    death_hospital = cfr_hosp .* 1/T_hosp
    return SEI3HRDGrowth{U}(birth, death, age_mixing,  virus_growth_asymp, virus_growth_presymp, virus_growth_symp, virus_decay, beta_force, beta_env, sigma_1, sigma_2, sigma_hospital, mu_1, mu_2, mu_3, hospitalisation, death_home, death_hospital, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
end

"""
    EpiParams{U <: Unitful.Units} <: AbstractParams

Parameter set for any epi model type, which stores information on birth, virus generation and decay probabilities, as well as matrices for transitions between different states. `transition` houses straightforward transition probabilities between classes, whereas `transition_virus` houses probabilities that should be multiplied by the amount of virus in the system, such as infection transitions.
"""
mutable struct EpiParams{U <: Unitful.Units} <: AbstractParams
    births::Vector{TimeUnitType{U}}
    virus_growth::Vector{TimeUnitType{U}}
    virus_decay::TimeUnitType{U}
    transition::Matrix{TimeUnitType{U}}
    transition_force::Matrix{TimeUnitType{U}}
    transition_virus::Matrix{TimeUnitType{U}}
    age_mixing::Matrix{Float64}
    freq_vs_density_force::Float64
    freq_vs_density_env::Float64
    env_virus_scale::Float64
    function EpiParams{U}(births::Vector{TimeUnitType{U}}, virus_growth::Vector{TimeUnitType{U}},
        virus_decay::TimeUnitType{U}, transition::Matrix{TimeUnitType{U}}, transition_force::Matrix{TimeUnitType{U}}, transition_virus::Matrix{TimeUnitType{U}}, age_mixing::Matrix{Float64}, freq_vs_density_force::Float64, freq_vs_density_env::Float64, env_virus_scale::Float64 = 1.0) where {U <: Unitful.Units}
        size(transition, 1) == size(transition, 2) || error("Transition matrix should be square.")
        size(transition, 1) == size(transition_virus, 1) || error("Transition matrices should match dimensions.")
        size(transition_force, 1) == size(transition_virus, 1) || error("Transition matrices should match dimensions.")
        new{U}(births, virus_growth, virus_decay, transition, transition_force, transition_virus, age_mixing, freq_vs_density_force, freq_vs_density_env, env_virus_scale)
    end
end

function create_transition_matrix(params::AbstractParams, paramDat::DataFrame, age_categories::Int64, nclasses::Int64)
    # Set up number of classes etc
    cat_idx = reshape(1:(nclasses * age_categories), age_categories, nclasses)

    # Set up transition matrix
    tm_size = nclasses * age_categories
    tmat = zeros(typeof(params.beta_env[1]), tm_size, tm_size)

    # Death
    for i in 1:(nclasses-1)
        dmat = @view tmat[cat_idx[:, end], cat_idx[:, i]]
        dmat[diagind(dmat)].= params.death[cat_idx[:, i]]
    end

    # Other transitions
    ordered_transitions = paramDat[!, :param]
    from = paramDat[!, :from]
    to = paramDat[!, :to]
    for i in eachindex(to)
            view_mat = @view tmat[cat_idx[:, to[i]], cat_idx[:, from[i]]]
            view_mat[diagind(view_mat)] .= ordered_transitions[i]
    end
    return tmat
end

function create_virus_matrix(beta::Vector{TimeUnitType{U}}, age_categories::Int64, nclasses::Int64) where U <: Unitful.Units
    cat_idx = reshape(1:(nclasses * age_categories), age_categories, nclasses)
    vm_size = nclasses * age_categories
    vmat = zeros(typeof(beta[1]), vm_size, vm_size)
    bmat = @view vmat[cat_idx[:, 2], cat_idx[:, 1]]
    bmat[diagind(bmat)] .= beta
    return vmat
end

function create_virus_vector(virus_growth::Vector{TimeUnitType{U}}, age_categories::Int64, nclasses::Int64, inf_cat::Int64) where U <: Unitful.Units
    cat_idx = reshape(1:(nclasses * age_categories), age_categories, nclasses)
    vm_size = nclasses * age_categories
    v_growth = fill(0.0 * unit(virus_growth[1]), vm_size)
    v_growth[cat_idx[:, inf_cat]] .= virus_growth
    return v_growth
end
"""
    transition(params::SISGrowth)

Function to create transition matrix from SIS parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SISGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 3

    from = 2
    to = 1
    paramDat = DataFrame(from = from, to = to, param = params.sigma)

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth, age_categories, nclasses, 2)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end

"""
    transition(params::SIRGrowth)

Function to create transition matrix from SIR parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SIRGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 4

    from = 2
    to = 3
    paramDat = DataFrame(from = from, to = to, param = params.sigma)

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth, age_categories, nclasses, 2)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end

"""
    transition(params::SEIRGrowth)

Function to create transition matrix from SEIR parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SEIRGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 5

    from = [2, 3]
    to = [3, 4]
    paramDat = DataFrame(from = from, to = to, param = [params.mu, params.sigma])

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth, age_categories, nclasses, 3)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end

"""
    transition(params::SEIRSGrowth)

Function to create transition matrix from SEIRS parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SEIRSGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 5

    from = [2, 3, 4]
    to = [3, 4, 1]
    paramDat = DataFrame(from = from, to = to, param = [params.mu, params.sigma, params.epsilon])

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth, age_categories, nclasses, 3)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end

"""
    transition(params::SEI2HRDGrowth)

Function to create transition matrix from SEI2HRD parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SEI2HRDGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 7

    ordered_transitions = (incubation_period = params.mu_1, symptoms_develop = params.mu_2, symptoms_worsen = params.hospitalisation, recovery_asymptomatic = params.sigma_1, recovery_symptomatic = params.sigma_2, recovery_hospital = params.sigma_hospital, death_symptomatic = params.death_home,
    death_hospitalised = params.death_hospital)
    from = [2, 3, 4, 3, 4, 5, 4, 5]
    to = [3, 4, 5, 6, 6, 6, 7, 7]
    paramDat = DataFrame(from = from, to = to, param = collect(ordered_transitions))

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth_asymp, age_categories, nclasses, 3)
    v_growth .+= create_virus_vector(params.virus_growth_symp, age_categories, nclasses, 4)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end

"""
    transition(params::SEI3HRDGrowth)

Function to create transition matrix from SEI2HRD parameters and return an `EpiParams` type that can be used by the model update.
"""
function transition(params::SEI3HRDGrowth, age_categories = 1)
    # Set up number of classes etc
    nclasses = 8

    ordered_transitions = (asymptomatic = params.mu_1, incubation_period = params.mu_2, symptoms_develop = params.mu_2, symptoms_worsen = params.hospitalisation, recovery_asymptomatic = params.sigma_1, recovery_symptomatic = params.sigma_2, recovery_hospital = params.sigma_hospital, death_symptomatic = params.death_home,
    death_hospitalised = params.death_hospital)
    from = [2, 2, 4, 5, 3, 5, 6, 5, 6]
    to = [3, 4, 5, 6, 7, 7, 7, 8, 8]
    paramDat = DataFrame(from = from, to = to, param = collect(ordered_transitions))

    tmat = create_transition_matrix(params, paramDat, age_categories, nclasses)

    # Env virus matrix
    vmat = create_virus_matrix(params.beta_env, age_categories, nclasses)

    # Force matrix
    vfmat = create_virus_matrix(params.beta_force, age_categories, nclasses)

    # Virus growth and decay
    v_growth = create_virus_vector(params.virus_growth_asymp, age_categories, nclasses, 3)
    v_growth .+= create_virus_vector(params.virus_growth_presymp, age_categories, nclasses, 4)
    v_growth .+= create_virus_vector(params.virus_growth_symp, age_categories, nclasses, 5)

  return EpiParams{typeof(unit(params.beta_force[1]))}(params.birth[1:end], v_growth, params.virus_decay, tmat, vfmat, vmat, params.age_mixing, params.freq_vs_density_force, params.freq_vs_density_env, params.env_virus_scale)
end
