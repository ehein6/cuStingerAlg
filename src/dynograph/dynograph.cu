#include <dynograph_util/benchmark.h>
#include "cuStinger_wrapper.cuh"

int main(int argc, char** argv)
{
    DynoGraph::Benchmark::run<cuStinger_implementation>(argc, argv);
    return 0;
}