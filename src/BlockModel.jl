"""
CouplingVariableRef

Coupling variable reference. `block_id` identifies the problem block containing 
the variable, `coupling_id` identifies a set of variables whose values are equal,
and `ref` contains the `JuMP.VariableRef` of the coupling variable.
"""
struct CouplingVariableRef
    block_id::Int
    coupling_id
    ref::JuMP.VariableRef
end

"""
BlockModel

Block model struture contrains a set of `JuMP.Model` objects, each of which
represents a sub-block model with the information of how to couple these block
models. 
"""
mutable struct BlockModel
    model::Dict{Int,JuMP.Model} # Dictionary of block models
    coupling_variables::Vector{CouplingVariableRef} # array of variables that couple block models
    variables_by_couple::Dict{Any,Vector{JuMP.VariableRef}} # maps `couple_id` to `JuMP.VariableRef`
    function BlockModel()
        return new(
            Dict(), 
            [],
            Dict())
    end
end

"""
add_block_model!

Add block model `model` to `block_model::BlockModel` with `block_id`.
"""
function add_block_model!(block_model::BlockModel, block_id::Integer, model::JuMP.Model)
    block_model.model[block_id] = model
end

"""
num_blocks

Number of blocks in `block_model::BlockModel`
"""
num_blocks(block_model::BlockModel) = length(block_model.model)

"""
    block_model

This returns a dictionary of `JuMP.Model` objects.
"""
block_model(block_model::BlockModel) = block_model.model

"""
    block_model

This returns a `JuMP.Model` object for a given `block_id`.
"""
block_model(block_model::BlockModel, block_id::Integer) = block_model.model[block_id]

"""
    num_coupling_variables

This returns the number of coupling variables in `block_model::BlockModel`.
"""
num_coupling_variables(block_model::BlockModel) = length(block_model.coupling_variables)

"""
    coupling_variables

This returns the array of coupling variables in `block_model::BlockModel`.
"""
coupling_variables(block_model::BlockModel) = block_model.coupling_variables

"""
    set_coupling_variables!

This sets coupling variables `variables` to `block_model::BlockModel`. Internally,
`BlockModel.coupling_variables` and `BlockModel.variables_by_couple` will be set.
"""
function set_coupling_variables!(block_model::BlockModel, variables::Vector{CouplingVariableRef})
    block_model.coupling_variables = variables
    block_model.variables_by_couple = Dict(v.coupling_id => [] for v in variables)
    for v in variables
        push!(block_model.variables_by_couple[v.coupling_id], v.ref)
    end
end