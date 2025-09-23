#include <cstdint>
#include <array>
#include <vector>
#include <string>

using namespace std;
using State = uint64_t;

struct Node {
    State state;
    int parent;
    char action;
};

struct BFSResult {
    bool found = false;
    string moves = "";
    size_t nodes_expanded = 0;
};

inline uint8_t get_tile(State currentState, int location) {
    return (currentState >> (location * 4)) & 0xFULL;
}

inline State set_tile(State currentState, int location, uint8_t value) {
    const State mask = ~(0xFULL << (location * 4));
    return (currentState & mask) | (State(value) << (location * 4));
}

State pack(const array<uint8_t, 16>& puzzleState) {
    State packedState = 0;
    for (int i = 0; i < 16; i++){
        packedState |= (State(puzzleState[i]) << (i*4));
    } 
    return packedState;
}

array<uint8_t, 16> unpack16(State packedState) {
    array<uint8_t, 16> puzzleState{};
    for (int i = 0; i < 16; i++) {
        puzzleState[i] = get_tile(packedState, i);
    } 
    return puzzleState;
}

bool is_goal(State puzzleState) {
    for (int i = 0; i < 15; i++) {
        if (get_tile(puzzleState, i) != i+1) return false;
    }
    return get_tile(puzzleState, 15) == 0;
}

int find_blank_square(State puzzleState) {
    for (int i = 0; i < 16; i++) {
        if (get_tile(puzzleState, i) == 0) return i;
    }
    return -1;
}

inline State swap_position(State puzzleState, int i, int j) {
    uint8_t a = get_tile(puzzleState, i);
    uint8_t b = get_tile(puzzleState, j);
    puzzleState = set_tile(puzzleState, i, b);
    puzzleState = set_tile(puzzleState, j, a);
    return puzzleState;
}

vector<pair<State, char>> generate_children(State puzzleState) {
    vector<pair<State, char>> children;
    int blank_square_position = find_blank_square(puzzleState);
    int blank_row = blank_square_position / 4;
    int blank_col = blank_square_position % 4;

    if (blank_row > 0) {
        children.emplace_back(swap_position(puzzleState, blank_square_position, blank_square_position - 4), 'U');
    }
    if (blank_row < 3) {
        children.emplace_back(swap_position(puzzleState, blank_square_position, blank_square_position + 4), 'D');
    }
    if (blank_col > 0) {
        children.emplace_back(swap_position(puzzleState, blank_square_position, blank_square_position - 1), 'L');
    }
    if (blank_col < 3) {
        children.emplace_back(swap_position(puzzleState, blank_square_position, blank_square_position + 1), 'R');
    }

    return children;
}

BFSResult BFS(State initial) {
    
}