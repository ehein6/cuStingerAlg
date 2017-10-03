#include "cuStinger_wrapper.h"

#include <dynograph_util/args.h>

cuStinger_wrapper::cuStinger_wrapper(const DynoGraph::Args& args, int64_t max_vertex_id)
: DynoGraph::DynamicGraph(args, max_vertex_id)
, off(max_vertex_id + 1)
, adj(1)
{
    cuStingerInitConfig config;
    config.initState = eInitStateCSR;
    config.maxNV = max_vertex_id + 1;

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

cuStinger_wrapper::cuStinger_wrapper(const DynoGraph::Args &args, int64_t max_vertex_id, const DynoGraph::Batch &batch)
: DynoGraph::DynamicGraph(args, max_vertex_id)
{
    cuStingerInitConfig config;
    config.initState = eInitStateEmpty;
    config.maxNV = max_vertex_id + 1;
    graph.initializeCuStinger(config);
    // FIXME
    insert_batch(batch);
}

cuStinger_wrapper::~cuStinger_wrapper()
{
    graph.freecuStinger();
}


static std::vector<std::string> get_supported_algs() { return {}; };
void
cuStinger_wrapper::before_batch(const DynoGraph::Batch& batch, const int64_t threshold)
{}

void
cuStinger_wrapper::insert_batch(const DynoGraph::Batch & b)
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
cuStinger_wrapper::delete_edges_older_than(int64_t threshold) {
    // FIXME
};
void
cuStinger_wrapper::update_alg(const std::string &name, const std::vector<int64_t> &sources, DynoGraph::Range<int64_t> data)
{
    // FIXME
}

int64_t
cuStinger_wrapper::get_out_degree(int64_t vertex_id) const
{
    // FIXME
    return 0;
}

int64_t
cuStinger_wrapper::get_num_vertices() const
{
    // FIXME
    cuStinger &g = const_cast<cuStinger&>(graph);
    return g.getMaxNV();
}

int64_t
cuStinger_wrapper::get_num_edges() const
{
    cuStinger &g = const_cast<cuStinger&>(graph);
    return g.getNumberEdgesUsed();
}

std::vector<int64_t>
cuStinger_wrapper::get_high_degree_vertices(int64_t n) const
{
    // FIXME
    return {0};
}
