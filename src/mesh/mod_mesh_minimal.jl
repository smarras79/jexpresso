using Test
using DelimitedFiles
using Gridap
using Gridap.Arrays
using Gridap.Arrays: Table
using Gridap.Geometry
using Gridap.Fields
using Gridap.ReferenceFEs
using Gridap.CellData
using Gridap.Geometry: GridMock
using GridapGmsh
using LinearAlgebra
using Printf
using Revise
using ElasticArrays
using StaticArrays

export St_mesh

export mod_mesh_build_mesh!
export mod_mesh_read_gmsh!

const POIN         = UInt8(0)
const EDGE         = UInt8(1)
const FACE         = UInt8(2)
const ELEM         = UInt8(3)

const VERTEX_NODES = UInt8(1)
const EDGE_NODES   = UInt8(2)
const FACE_NODES   = UInt8(4)


abstract type At_geo_entity end


include("../basis/basis_structs.jl")

Base.@kwdef mutable struct St_mesh{TInt, TFloat}


    #x = CachedArray(zeros(TFloat, 2))
    #y = CachedArray(zeros(TFloat, 2))
    #z = CachedArray(zeros(TFloat, 2))
    #    
    #x_ho = CachedArray(zeros(TFloat, 2))
    #y_ho = CachedArray(zeros(TFloat, 2))
    #z_ho = CachedArray(zeros(TFloat, 2))
        
    x::Union{Array{TFloat}, Missing} = zeros(2)
    y::Union{Array{TFloat}, Missing} = zeros(2)
    z::Union{Array{TFloat}, Missing} = zeros(2)
    
    x_ho::Union{Array{TFloat}, Missing} = zeros(2)
    y_ho::Union{Array{TFloat}, Missing} = zeros(2)
    z_ho::Union{Array{TFloat}, Missing} = zeros(2)
    
    xmin::Union{TFloat, Missing} = -1.0;
    xmax::Union{TFloat, Missing} = +1.0;
    
    ymin::Union{TFloat, Missing} = -1.0;
    ymax::Union{TFloat, Missing} = +1.0;

    zmin::Union{TFloat, Missing} = -1.0;
    zmax::Union{TFloat, Missing} = +1.0;

    npx::Union{TInt, Missing} = 1
    npy::Union{TInt, Missing} = 1
    npz::Union{TInt, Missing} = 1

    nelem::Union{TInt, Missing} = 1
    npoin::Union{TInt, Missing} = 1        #This is updated after populating with high-order nodes
    npoin_linear::Union{TInt, Missing} = 1 #This is always the original number of the first-order grid

    nedges::Union{TInt, Missing} = 1     # total number of edges
    nedges_bdy::Union{TInt, Missing} = 1 # bdy edges
    nedges_int::Union{TInt, Missing} = 1 # internal edges

    nfaces::Union{TInt, Missing} = 1     # total number of faces
    nfaces_bdy::Union{TInt, Missing} = 1 # bdy faces
    nfaces_int::Union{TInt, Missing} = 1 # internal faces
    
    nsd::Union{TInt, Missing} = 1
    nop::Union{TInt, Missing} = 4
    ngl::Union{TInt, Missing} = nop + 1
    npoin_el::Union{TInt, Missing} = 1 #Total number of points in the reference element
    
    NNODES_EL::Union{TInt, Missing}  =  2^nsd
    NEDGES_EL::Union{TInt, Missing}  = 12
    NFACES_EL::Union{TInt, Missing}  =  6
    EDGE_NODES::Union{TInt, Missing} =  2
    FACE_NODES::Union{TInt, Missing} =  4

    
    #low and high order connectivity tables
    cell_node_ids::Table{Int64,Vector{Int64},Vector{Int64}} = Gridap.Arrays.Table(zeros(nelem), zeros(8))
    cell_node_ids_ho::Table{Int64,Vector{Int64},Vector{Int64}} = Gridap.Arrays.Table(zeros(nelem), zeros(8))
    
    conn_ho_ptr       = ElasticArray{Int64}(undef, nelem)    
    conn_ho           = ElasticArray{Int64}(undef, ngl*nelem)
    conn_unique_edges = ElasticArray{Int64}(undef,  1, 2)
    conn_unique_faces = ElasticArray{Int64}(undef,  1, 4)

    conn_edge_L2G     = ElasticArray{Int64}(undef, 1, NEDGES_EL, nelem)
    conn_face_L2G     = ElasticArray{Int64}(undef, 1, NFACES_EL, nelem)
    
    conn_edge_el      = ElasticArray{Int64}(undef, 2, NEDGES_EL, nelem)
    conn_face_el      = ElasticArray{Int64}(undef, 4, NFACES_EL, nelem)
    face_in_elem      = ElasticArray{Int64}(undef, 2, NFACES_EL, nelem)
    
end

function mod_mesh_read_gmsh!(mesh::St_mesh, gmsh_filename::String)

    #
    # Read GMSH grid from file
    #
    model    = GmshDiscreteModel(gmsh_filename, renumber=true)
    topology = get_grid_topology(model)
    mesh.nsd = num_cell_dims(model)
    
    mesh.NNODES_EL  = 8
    mesh.NEDGES_EL  = 12
    mesh.NFACES_EL  = 6
    mesh.EDGE_NODES = 2
    mesh.FACE_NODES = 4
    #dump(topology)
    
    mesh.nedges            = num_faces(model,EDGE)
    mesh.nelem             = num_faces(model,ELEM)
    mesh.conn_unique_edges = get_face_nodes(model, EDGE) #edges --> 2 nodes
    
    #Edges
    @time add_high_order_nodes_edges!(mesh)

end


#
# FOR DISCOURSE.JULIA
#
function  add_high_order_nodes_edges!(mesh::St_mesh)
    @info " CCCC"

    # INCREASE/DECREASE "NEL" to see how allocation changes
    NEL     = 20 #mesh.nelem

    #Do not touch NGLOBAL and NLOCAL
    NGLOBAL = mesh.nedges
    NLOCAL  = mesh.NEDGES_EL
    #

    
    cache_unique_edges = array_cache(mesh.conn_unique_edges) # allocation here
    @info typeof(cache_unique_edges)
    
    for iglob = 1:NGLOBAL

        ai = getindex!(cache_unique_edges, mesh.conn_unique_edges, iglob)        

        #@info sizeof(ai[1]) sizeof(ai[2])
        #@info typeof(ai)
        
        for iel = 1:NEL
            for iloc = 1:NLOCAL
                
                if(issetequal([ai[1], ai[2]], [ai[1], ai[2]]))
                    # (UN)COMMENT THIS IF to SEE HOW ALLOCATION BEHAVES    
                end
                
            end
        end
    end
    @info " DDDD"
    
    return 
end
