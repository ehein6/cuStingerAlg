#include <dynograph_util/benchmark.h>
#include "cuStinger_wrapper.h"

int main(int argc, char** argv)
{
    DynoGraph::Benchmark::run<cuStinger_wrapper>(argc, argv);
    return 0;
}