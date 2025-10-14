#include <cstdint>
#include <array>
#include <vector>
#include <string>
#include <queue>
#include <unordered_set>
#include <algorithm>
#include <unordered_map>

#pragma region data structures

// I got a bunch of errors as a result of initially declaring using namespace std so I used these delarations instead
using std::array;
using std::vector;
using std::string;
using std::queue;
using std::unordered_set;
using std::pair;
using std::unordered_map;
using std::priority_queue;
using std::abs;
using std::reverse;
using std::move;

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

// the object returned by the DLS helper algorithm
struct DLSResult {
    bool found = false;
    bool cutoff = false;
    string path;
    size_t nodes_expanded = 0;
};

// object representing each node in the DLS frontier
struct FrontierNode {
    State state;
    int parent;
    char action;
    int depth;
};

// the object returned by the main IDS algorithm
struct IDSResult {
    bool found = false;
    string moves = "";
    size_t nodes_expanded = 0;
};

// the object returned by the main AStar algorithm
struct AStarResult {
    bool found = false;
    string moves = "";
    size_t nodes_expanded = 0; 
    int cost = 0;              
};

// object representing each node stored in the global search "nodes" array for parent backtracking in AStar algorithm
// f_score is g_cost + heuristic(state) 
struct AStarSearchNode {
    State state;
    int parent_index;
    char action_from_parent;
    int g_cost;
    int f_score;
};

// object in the priority queue (OPEN set)
struct AStarQueueItem {
    int f_score;
    int g_cost;
    int node_index;
};

// converts priority queue into a min-heap on f_score
struct AStarQueueCompare {
    bool operator()(const AStarQueueItem& a, const AStarQueueItem& b) const {
        if (a.f_score != b.f_score) return a.f_score > b.f_score; // lower f first
        return a.g_cost < b.g_cost; // on tie, prefer deeper
    }
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

// Heuristic 1: number of misplaced tiles (ignoring blank)
// returns count of how many non-blank tiles are not in their goal positions
inline int heuristic_misplaced_tiles(State puzzleState) {
    int h = 0;
    for (int i = 0; i < 15; i++) {
        uint8_t tile = get_tile(puzzleState, i);
        if (tile != 0 && tile != uint8_t(i + 1)) h++;
    }
    return h;
}

// Heuristic 2: Manhattan distance of all tiles from their goals (ignore blank)
// adds Manhattan distance of each non-blank tile to h, and returns h
inline int heuristic_manhattan(State puzzleState) {
    auto row = [](int idx) { return idx / 4; };
    auto col = [](int idx) { return idx % 4; };

    int h = 0;
    for (int i = 0; i < 16; i++) {
        uint8_t tile = get_tile(puzzleState, i);
        if (tile == 0) continue;               
        int goal_idx = int(tile) - 1;          
        h += abs(row(i) - row(goal_idx)) + abs(col(i) - col(goal_idx));
    }
    return h;
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

// Depth-Limited-Search algorithm helper function for IDS of 15-puzzle
// returns a DFSResult object containing a bool found, a bool cutoff, a string path containing the path to the solution, and the number of nodes visited
// visits nodes until the specified depth limit
DLSResult DLS(State initial, int limit) {
    // create a vector of all visited nodes starting with initial
    // initial node has parent index of -1 and an action of 0 because no action has been taken yet as well as depth of 0 because it is the initial node
    vector<FrontierNode> nodes;
    nodes.push_back({initial, -1, 0, 0});

    // use a vector for frontier so we can have lifo logic and push the initial node's index (0) in the nodes variable
    vector<int> frontier;
    frontier.push_back(0);

    DLSResult result;

    // loop through frontier until goal is found or frontier is empty
    // if frontier is empty, no possible path to the goal state is possible
    while (!frontier.empty()) {
        // get the node at the back for lifo logic
        int nodeID = frontier.back();
        frontier.pop_back();
        auto &node = nodes[nodeID];

        // check if the goal state is found and return appropriate values
        if (is_goal(node.state)) {
            // get moves needed to reach goal
            string path;
            for (int cur = nodeID; nodes[cur].parent != -1; cur = nodes[cur].parent) {
                path.push_back(nodes[cur].action);
            }
            reverse(path.begin(), path.end());
            result.found = true;
            result.path = path;
            return result;
        }

        // check if we have reached the depth limit
        // if at the depth limit, do not generate children
        if (node.depth == limit) {
            result.cutoff = true; 
        } else {
            result.nodes_expanded++;
            for (auto [child, action] : generate_children(node.state)) {
                // check if child node is already in the frontier
                // only add children not already in the frontier
                bool in_frontier = false;
                for (int current = nodeID; current != -1; current = nodes[current].parent) {
                    if (nodes[current].state == child) {
                        in_frontier = true;
                        break;
                    }
                }
                if (in_frontier) continue;

                nodes.push_back({child, nodeID, action, node.depth + 1});
                frontier.push_back((int)nodes.size() - 1);
            }
        }
    }

    // no solution found at current depth limit
    return result;
}

// Iterative-Deepening-Search algorithm for 15-puzzle
// returns an IDSResult object containing a bool found, a bool cutoff, a string path containing the path to the solution, and the number of nodes visited
// visits all nodes until solution is found or max_depth is reached
// max_depth is set to 100 by default to prevent large memory consumption
IDSResult IDS(State initial, int max_depth = 100) {
    IDSResult result;

    // check if initial is already goal state
    if (is_goal(initial)) {
        result.found = true;
        return result;
    }

    // run DLS algorithm at every depth level until max_depth
    for (int depth = 0; depth <= max_depth; depth++) {
        DLSResult dls = DLS(initial, depth);
        result.nodes_expanded += dls.nodes_expanded;

        if (dls.found) {
            // solution found
            result.found = true;
            result.moves = dls.path;
            return result;
        } else if (!dls.cutoff) {
            // no solution found at max_depth limit
            return result;
        }
    }
}

// A-Star algorithm for 15-puzzle that accepts any heuristic function
// returns an AStarResult object containing a bool found, a string path containing a path to the solution, the number of nodes visited, and the optimal cost in moves
template <typename HeuristicFn>
AStarResult AStarCore(State initial_state, HeuristicFn H) {
    AStarResult result;

    if (is_goal(initial_state)) {
        result.found = true;
        result.cost = 0;
        return result;
    }

    // create a vector of AStarSearchNodes and initialize parent node
    vector<AStarSearchNode> nodes;
    nodes.push_back({
        initial_state, // state
        -1, // parent index
        0, // action from parent
        0, // g_cost
        H(initial_state) // f_score
    });

    // create a priority queue open_set using AStarQueueCompare to order by lowest f_score
    // initialize root node into open_set
    priority_queue<AStarQueueItem, vector<AStarQueueItem>, AStarQueueCompare> open_set;
    open_set.push({nodes[0].f_score, nodes[0].g_cost, 0});

    // best g-cost seen so far for each state
    // reserve memory for best_g_cost to improve performance and initialize root node
    unordered_map<State, int> best_g_cost;
    best_g_cost.reserve(1 << 20);
    best_g_cost[initial_state] = 0;

    // search until goal is found or open_set is empty
    while (!open_set.empty()) {
        AStarQueueItem top_item = open_set.top();
        open_set.pop();

        const int current_index = top_item.node_index;
        const AStarSearchNode& current_node = nodes[current_index];

        // expansion happens on pop
        result.nodes_expanded++;

        // goal check
        if (is_goal(current_node.state)) {
            string path;
            for (int idx = current_index; nodes[idx].parent_index != -1; idx = nodes[idx].parent_index) {
                path.push_back(nodes[idx].action_from_parent);
            }
            reverse(path.begin(), path.end());

            result.found = true;
            result.moves = move(path);
            result.cost  = current_node.g_cost;
            // goal found
            return result;
        }

        // explore children
        for (auto [child_state, action] : generate_children(current_node.state)) {
            const int tentative_g = current_node.g_cost + 1;

            auto it = best_g_cost.find(child_state);
            if (it != best_g_cost.end() && tentative_g >= it->second) {
                // already saw this state with a cheaper or equal path—skip
                continue;
            }

            // better path (or first time) to child
            // f is calculated using the chosen heuristic function H
            best_g_cost[child_state] = tentative_g;
            int f = tentative_g + H(child_state);

            nodes.push_back({
                child_state,
                current_index,
                action,
                tentative_g,
                f
            });

            open_set.push({f, tentative_g, (int)nodes.size() - 1});
        }
    }

    // no solution reachable
    return result;
}

// run AStarCore with Manhattan distance heuristic
AStarResult AStarManhattan(State initial_state) {
    return AStarCore(initial_state, heuristic_manhattan);
}

// run AStarCore with misplaced tiles heuristic
AStarResult AStarMisplaced(State initial_state) {
    return AStarCore(initial_state, heuristic_misplaced_tiles);
}

#pragma endregion