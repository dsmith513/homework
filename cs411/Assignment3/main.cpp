#include "search.cpp"
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

void search(array<uint8_t, 16> state) {
    State initial_state = pack(state);
    auto time_initial = chrono::high_resolution_clock::now();
    long memory_initial = get_current_memory();
    IDSResult result = IDS(initial_state);
    long memory_final = get_current_memory();
    auto time_final = chrono::high_resolution_clock::now();

    double seconds = chrono::duration<double>(time_final - time_initial).count();
    long memoryKB = memory_final - memory_initial;

    if (result.found == false) {
        cout << "No possible solution found." << endl;
        return;
    }

    cout << "Moves taken: " << result.moves << endl;
    cout << "Nodes expanded: " << result.nodes_expanded << endl;
    cout << "Time taken: " << seconds << " seconds" << endl;
    cout << "Memory used: " << memoryKB << "kb" << endl;
}

array<uint8_t, 16> get_state_from_user() {
    array<uint8_t, 16> state{};
    cout << "Enter 16 values (0–15) for 15-puzzle separated by spaces: ";
    for (int i = 0; i < 16; i++) {
        cin >> state[i];
    }
    return state;
}

int main() {
    bool exit = false;
    while (!exit) {
        int key;
        cout << "Enter 1 for test solution, 2 to enter custom 15-puzzle, or -1 to exit: " << endl;
        cin >> key;
        switch (key) {
            case -1:
                exit = true;
                break;
            case 1:
                search(test_solution);
                cout << endl;
                break;
            case 2: {
                array<uint8_t, 16> state = get_state_from_user();
                search(state);
                cout << endl;
                break;
            }
            default:
                break;
        }
    }
    
    return 0;
}