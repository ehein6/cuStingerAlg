#include "cuStinger_wrapper.cuh"
#include "algs.cuh"

#include "static_breadth_first_search/bfs_top_down.cuh"
#include "static_breadth_first_search/bfs_bottom_up.cuh"
#include "static_breadth_first_search/bfs_hybrid.cuh"
#include "static_connected_components/cc.cuh"
#include "static_page_rank/pr.cuh"
#include "static_betweenness_centrality/bc.cuh"



#include <dynograph_util/args.h>
#include <dynograph_util/logger.h>

using namespace cuStingerAlgs;

// Implementation of cuStinger_wrapper

cuStinger_wrapper::cuStinger_wrapper(size_t max_nv)
// Initialize host CSR dummy graph
: off(max_nv)
, adj(1)
{
    cuStingerInitConfig config;
    config.initState = eInitStateCSR;
    config.maxNV = max_nv;

    // HACK
    // cuStinger only knows how to initialize using a CSR right now, so we'll give it a tiny one
    // 0 -> 1
    off[0] = 0;
    for (size_t i = 0; i < off.size(); ++i)
    {
        off[i] = 1;
    }
    adj[0] = 1;


    config.csrNV = off.size();
    config.csrNE = adj.size();
    config.csrOff = off.data();
    config.csrAdj = adj.data();
    graph.initializeCuStinger(config);
}

cuStinger_wrapper::~cuStinger_wrapper()
{
    graph.freecuStinger();
}


// Implementation of cuStingerAlgs_wrapper
#define DYNOGRAPH_NUM_BC_SOURCES 128

cuStingerAlgs_wrapper::cuStingerAlgs_wrapper(cuStinger& graph)
// Betweenness Centrality needs # of sources passed in the constructor
// We know DynoGraph always does 128 Betweenness Centrality traversals, but this isn't stored anywhere
: bc_values(DYNOGRAPH_NUM_BC_SOURCES), bc(DYNOGRAPH_NUM_BC_SOURCES, bc_values.data())
{
    bc.Init(graph);
    bfs.Init(graph);
    cc.Init(graph);
    pagerank.Init(graph);
}

cuStingerAlgs_wrapper::~cuStingerAlgs_wrapper()
{
    bc.Release();
    bfs.Release();
    cc.Release();
    pagerank.Release();
}

// Implementation of cuStinger_implementation

cuStinger_implementation::cuStinger_implementation(const DynoGraph::Args& args, int64_t max_vertex_id)
: DynoGraph::DynamicGraph(args, max_vertex_id)
, graph_wrapper(max_vertex_id + 1)
, graph(graph_wrapper.graph)
, algs(graph)
{

}

cuStinger_implementation::cuStinger_implementation(const DynoGraph::Args &args, int64_t max_vertex_id, const DynoGraph::Batch &batch)
: DynoGraph::DynamicGraph(args, max_vertex_id)
, graph_wrapper(max_vertex_id + 1)
, graph(graph_wrapper.graph)
, algs(graph)
{
    // FIXME
    insert_batch(batch);
}

// Implementation of cuStinger_implementation

std::vector<std::string> get_supported_algs() { return {"bc", "bfs", "cc", "pagerank"}; };

void
cuStinger_implementation::before_batch(const DynoGraph::Batch& batch, const int64_t threshold)
{}

void
cuStinger_implementation::insert_batch(const DynoGraph::Batch & b)
{
    BatchUpdateData bud(b.size(), true);

    #pragma omp parallel for
    for (int i = 0; i < b.size(); ++i)
    {
        const DynoGraph::Edge& e = b[i];
        bud.getSrc()[i] = e.src;
        bud.getDst()[i] = e.dst;
    }

    BatchUpdate bu(bud);

    length_t allocs;
    graph.edgeInsertions(bu,allocs);
}

void
cuStinger_implementation::delete_edges_older_than(int64_t threshold) {
    // FIXME
};
void
cuStinger_implementation::update_alg(const std::string &name, const std::vector<int64_t> &sources, DynoGraph::Range<int64_t> data)
{
    if (name == "bc")
    {
        algs.bc.Reset();
        algs.bc.Run(graph);
    }
    else if (name == "bfs")
    {
        for (auto source : sources)
        {
            algs.bfs.Reset();
            algs.bfs.setInputParameters(source);
            algs.bfs.Run(graph);
        }
    }
    else if (name == "cc")
    {
        algs.cc.Reset();
        algs.cc.Run(graph);
    }
    else if (name == "pagerank")
    {
        algs.pagerank.Reset();
        algs.pagerank.setInputParameters(5, 0.001);
        algs.pagerank.Run(graph);
    } else {
        DynoGraph::Logger::get_instance() << "Algorithm " << name << " is not implemented\n";
        DynoGraph::die();
    }
}

int64_t
cuStinger_implementation::get_out_degree(int64_t vertex_id) const
{
    // FIXME
    return 0;
}

int64_t
cuStinger_implementation::get_num_vertices() const
{
    // // FIXME
    // cuStinger &g = const_cast<cuStinger&>(graph);
    // return g.getMaxNV();
    return 0;
}

int64_t
cuStinger_implementation::get_num_edges() const
{
    // cuStinger &g = const_cast<cuStinger&>(graph);
    // return g.getNumberEdgesUsed();
    return 0;
}

std::vector<int64_t>
cuStinger_implementation::get_high_degree_vertices(int64_t n) const
{
    // FIXME
    std::vector<int64_t> vertices(n);
    int64_t i = 1;
    std::generate(vertices.begin(), vertices.end(), [&i]{ return i; });
    return vertices;
}
