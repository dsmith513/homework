#include "bfs.cpp"
#include <iostream>
#include <chrono>
#include <windows.h>
#include <Psapi.h>

using namespace std;

const array<uint8_t, 16> test_solution = {1, 0, 2, 4, 5, 7, 3, 8, 9, 6, 11, 12, 13, 10, 14, 15};

// function to get current memory usage in kb
// only works on windows
long get_current_memory() {
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
    return static_cast<long>(info.WorkingSetSize / 1024);
}

int main() {
    State initial_state = pack(test_solution);
    auto time_initial = chrono::high_resolution_clock::now();
    long memory_initial = get_current_memory();
    BFSResult result = BFS(initial_state);
    long memory_final = get_current_memory();
    auto time_final = chrono::high_resolution_clock::now();

    double seconds = chrono::duration<double>(time_final - time_initial).count();
    long memoryKB = memory_final - memory_initial;

    if (result.found == false) {
        cout << "No possible solution found." << endl;
        return 0;
    }

    cout << "Moves taken: " << result.moves << endl;
    cout << "Nodes expanded: " << result.nodes_expanded << endl;
    cout << "Time taken: " << seconds << " seconds" << endl;
    cout << "Memory used: " << memoryKB << "kb" << endl;

    return 0;
}