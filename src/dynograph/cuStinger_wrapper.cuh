#include <dynograph_util/dynamic_graph.h>
#include <utils.hpp>
#include <update.hpp>
#include <cuStingerDefs.hpp>
#include <cuStinger.hpp>

#include "algs.cuh"

#include "static_breadth_first_search/bfs_top_down.cuh"
#include "static_breadth_first_search/bfs_bottom_up.cuh"
#include "static_breadth_first_search/bfs_hybrid.cuh"
#include "static_connected_components/cc.cuh"
#include "static_page_rank/pr.cuh"
#include "static_betweenness_centrality/bc.cuh"

#include "static_katz_centrality/katz.cuh"

// RAII wrapper for cuStinger
struct cuStinger_wrapper
{
    // Store initial CSR graph
    std::vector<length_t> off;
    std::vector<vertexId_t> adj;

    // The cuStinger graph object
    cuStinger graph;

    cuStinger_wrapper(size_t max_nv);
    ~cuStinger_wrapper();
};

struct cuStingerAlgs_wrapper
{
    // Stores betweenness centrality results
    std::vector<float> bc_values;
    // Algorithms
    cuStingerAlgs::StaticBC bc;
    cuStingerAlgs::bfsBU bfs;
    cuStingerAlgs::ccConcurrentLB cc;
    cuStingerAlgs::StaticPageRank pagerank;
    cuStingerAlgs_wrapper(cuStinger& graph);
    ~cuStingerAlgs_wrapper();
};

class cuStinger_implementation : public DynoGraph::DynamicGraph
{
private:
    // RAII wrapper for cuStinger
    cuStinger_wrapper graph_wrapper;
    // Handy reference to the actual graph
    cuStinger & graph;
    // RAII wrapper for cuStinger algorithms
    cuStingerAlgs_wrapper algs;

public:
    cuStinger_implementation(const DynoGraph::Args& args, int64_t max_nv);
    cuStinger_implementation(const DynoGraph::Args &args, int64_t max_vertex_id, const DynoGraph::Batch &batch);

    static std::vector<std::string> get_supported_algs();
    void before_batch(const DynoGraph::Batch& batch, const int64_t threshold);
    void insert_batch(const DynoGraph::Batch & b);
    void delete_edges_older_than(int64_t threshold);
    void update_alg(const std::string &name, const std::vector<int64_t> &sources, DynoGraph::Range<int64_t> data);

    int64_t get_out_degree(int64_t vertex_id) const;
    int64_t get_num_vertices() const;
    int64_t get_num_edges() const ;
    std::vector<int64_t> get_high_degree_vertices(int64_t n) const;

};