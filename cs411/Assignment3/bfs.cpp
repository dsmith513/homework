#include <cstdint>
#include <array>
#include <vector>
#include <string>
#include <queue>
#include <unordered_set>
#include <algorithm>

#pragma region data structures

// I got a bunch of errors as a result of initially declaring using namespace std so I used these delarations instead
using std::array;
using std::vector;
using std::string;
using std::queue;
using std::unordered_set;
using std::pair;

// each node's state is represented by the datatype uint64_t
// this is done because in the 15-puzzle there are 16 tiles
// each tile (0-15) fits in 4 bits, 4 * 16 = 64 bits
// the blank square is represented by the value 0
using State = uint64_t;

// each node contains its unique state, its parent index, and the directional action taken from the parent to reach that state
struct Node {
    State state;
    int parent;
    char action;
};

// the object returned by the main BFS algorithm
struct BFSResult {
    bool found = false;
    string moves = "";
    size_t nodes_expanded = 0;
};

#pragma endregion

#pragma region helper functions

// helper function to get the value (0-15) of a tile at location in currentState
// offsets location by 4 to reach correct value in currentState
// 0xFULL masks off only the lowest 4 bits so only the value in that tile is returned
inline uint8_t get_tile(State currentState, int location) {
    return (currentState >> (location * 4)) & 0xFULL;
}

// helper function to set a value in currentState at location
// value is an 8-bit integer instead of a 40bit integer because the datatype uint_4t does not exist in C++
// offsets location by 4 and uses 0xFULL to clear out the old tile
// uses | operator to write the new tile into that slot
inline State set_tile(State currentState, int location, uint8_t value) {
    const State mask = ~(0xFULL << (location * 4));
    return (currentState & mask) | (State(value) << (location * 4));
}

// helper function to convert an array of 16 8-bit integers into a usable State
// loops through the array and offsets by 4 to insert each value into the packedState variable
// returns the packedState variable which can then be taken as an argument for the BFS algorithm
State pack(const array<uint8_t, 16>& puzzleState) {
    State packedState = 0;
    for (int i = 0; i < 16; i++){
        packedState |= (State(puzzleState[i]) << (i*4));
    } 
    return packedState;
}

// helper function to unpack a State variable into an array of 16 8-bit integers
// this function is not currently used anywhere in bfs.cpp or main.cpp and is primarily for debugging purposes
array<uint8_t, 16> unpack(State packedState) {
    array<uint8_t, 16> puzzleState{};
    for (int i = 0; i < 16; i++) {
        puzzleState[i] = get_tile(packedState, i);
    } 
    return puzzleState;
}

// helper function to check if puzzleState is in the goal configuration
// goal configuration: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0}
// the blank square is represented by the value 0
// returns true if goal configuration, false otherwise
bool is_goal(State puzzleState) {
    for (int i = 0; i < 15; i++) {
        if (get_tile(puzzleState, i) != i+1) return false;
    }
    return get_tile(puzzleState, 15) == 0;
}

// helper function find the black tile in puzzleState
// loops through each tile and returns the index of the tile with the value 0
int find_blank_square(State puzzleState) {
    for (int i = 0; i < 16; i++) {
        if (get_tile(puzzleState, i) == 0) return i;
    }
    return -1;
}

// helper function to swap the position of the tiles at index i and j in puzzleState
// uses get_tile() to get the value at tiles i and j
// uses set_tile() to swap the values of tiles i and j
inline State swap_position(State puzzleState, int i, int j) {
    uint8_t a = get_tile(puzzleState, i);
    uint8_t b = get_tile(puzzleState, j);
    puzzleState = set_tile(puzzleState, i, b);
    puzzleState = set_tile(puzzleState, j, a);
    return puzzleState;
}

// helper function to generate all possible children of puzzleState
// cannot generate children that will result in an illegal move, for example cannot move up when already at top row
// returns a vector<pair<State, char>> containing legal children represented by pairs of states and moves required to reach those states
vector<pair<State, char>> generate_children(State puzzleState) {
    vector<pair<State, char>> children;

    // find blank square and row and column of its current position
    int blank_square_position = find_blank_square(puzzleState);
    int blank_row = blank_square_position / 4;
    int blank_col = blank_square_position % 4;

    // add legal children to children vector based on blank square's current position
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

#pragma endregion

#pragma region search algorithms

// Breadth-First-Search algorithm for 15-puzzle
// returns a BFSResult object which contains a bool found, a string of the moves taken to find the solution, and the number of nodes expanded
// only visits unique states, does not visit repeated states
BFSResult BFS(State initial) {
    // create a vector of all visited nodes starting with initial
    // initial node has parent index of -1 and an action of 0 because no action has been taken yet
    vector<Node> nodes;
    nodes.push_back({initial, -1, 0});

    // use a queue for frontier so we can have fifo logic and push the initial node's index (0) in the nodes variable
    queue<int> frontier;
    frontier.push(0);

    // use an unordered set for reached to avoid visiting repeated states
    // allocate space for 2^20 (or approximately 1 million) states to prevent constant rehashing and improve efficiency
    unordered_set<State> reached;
    reached.reserve(1 << 20);
    reached.insert(initial);

    BFSResult result;

    // check if intial state is already goal state
    if (is_goal(initial)) {
        result.found = true;
        return result;
    }

    // loop through frontier until goal is found or frontier is empty
    // if frontier is empty, no possible path to the goal state is possible
    while (!frontier.empty()) {
        // get node at index of next element in frontier and pop out of frontier queue
        int nodeID = frontier.front(); 
        frontier.pop();
        const Node& node = nodes[nodeID];

        // check all possible children of node's state for goal state
        for (auto [puzzleState, action] : generate_children(node.state)) {
            if (is_goal(puzzleState)) {
                nodes.push_back({puzzleState, nodeID, action});
                int goalID = (int)nodes.size() - 1;

                // get moves needed to reach goal
                string path;
                for (int current = goalID; nodes[current].parent != -1; current = nodes[current].parent) {
                    path.push_back(nodes[current].action);
                }
                reverse(path.begin(), path.end());

                result.found = true;
                result.moves = path;

                return result;
            }

            // only insert states that have not already been seen into frontier and reached
            if (!reached.count(puzzleState)) {
                reached.insert(puzzleState);
                nodes.push_back({puzzleState, nodeID, action});
                frontier.push((int)nodes.size() - 1);
            }
        }

        result.nodes_expanded++;
    }

    // no possible path to goal state possible
    return result;
}

#pragma endregion