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

class cuStinger_wrapper : public DynoGraph::DynamicGraph
{
private:
    cuStinger graph;

    // Algorithms
    cuStingerAlgs::StaticPageRank pagerank;

    // Store initial CSR graph
    std::vector<length_t> off;
    std::vector<vertexId_t> adj;

    void init_algs();
    void free_algs();

public:
    cuStinger_wrapper(const DynoGraph::Args& args, int64_t max_nv);
    cuStinger_wrapper(const DynoGraph::Args &args, int64_t max_vertex_id, const DynoGraph::Batch &batch);
    ~cuStinger_wrapper();

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