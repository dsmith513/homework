#include "mdp.h"
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <fstream>

#pragma region load functions
static inline string leftTrim(const string& s) {
    size_t i = 0; 
    while (i < s.size() && isspace((unsigned char)s[i])) {
        i++;
    }
    return s.substr(i);
}

static inline string rightTrim(const string& s) {
    if (s.empty()) return s;
    size_t i = s.size();
    while (i > 0 && isspace((unsigned char)s[i-1])) {
        i--;
    }
    return s.substr(0, i);
}

static inline string trim(const string& s) {
    return rightTrim(leftTrim(s)); 
}

static inline vector<string> tokenize_line(const string& line) {
    // Split by whitespace, commas, or colons
    vector<string> output;
    string cur;
    auto flush = [&](){
        if(!cur.empty()){ 
            output.push_back(cur); 
            cur.clear(); 
        } 
    };
    for (char ch : line) {
        if (isspace((unsigned char)ch) || ch==',' || ch==':') {
            flush();
        }
        else cur.push_back(ch);
    }
    flush();
    return output;
}

// load MDP from file at "path" into "mdp" structure
// returns true on success, false on failure
bool load_mdp(const string& path, MDP& mdp) {
    // open file "path" for reading
    ifstream fin(path);
    if (!fin) { 
        cerr << "Could not open: " << path << "\n"; 
        return false; 
    }

    // read all lines, ignoring comments and blank lines
    // tokenize each line and store tokens in a single vector
    vector<string> tokens;
    string line;
    while (getline(fin, line)) {
        auto s = trim(line);
        if (s.empty() || s[0]=='#') {
            continue;
        }
        auto parts = tokenize_line(s);
        tokens.insert(tokens.end(), parts.begin(), parts.end());
    }

    // iterator for tokens
    auto it = tokens.begin();

    // lambda function for safer parsing
    // checks whether the next token matches expected key ("size", "walls", etc.)
    // returns true if it matches, false otherwise
    auto is_next_key = [&](const string& key)->bool{
        return (it!= tokens.end() && *it == key);
    };

    // lambda function for safer parsing
    // reads next token and converts to an int and stores in vector v and increments iterator
    auto pull_int = [&](int& v)->bool{
        if (it==tokens.end()) {
            return false;
        } 
        v = stoi(*it++); 
        return true;
    };

    // lambda function for safer parsing
    // reads next token and converts to a double and stores in vector v and increments iterator
    auto pull_double = [&](double& v)->bool{
        if (it==tokens.end()) {
            return false;
        } 
        v = stod(*it++); 
        return true;
    };

    // accept any order of keys from input file
    while (it != tokens.end()) {
        string key = *it++;
        if (key == "size") {
            // if key is size, initialize mdp accordingly
            int rows, cols; 
            if (!pull_int(rows) || !pull_int(cols)) { 
                cerr << "Invalid size\n"; 
                return false; 
            }

            mdp.rows = rows; 
            mdp.cols = cols;
            mdp.wall.assign(mdp.rows+1, vector<bool>(mdp.cols+1, false));
            mdp.is_terminal.assign(mdp.rows+1, vector<bool>(mdp.cols+1, false));
            mdp.terminal_reward.assign(mdp.rows+1, vector<double>(mdp.cols+1, 0.0));

        } else if (key == "walls") {
            // keep reading wall positions until next key or end of tokens
            while (it!= tokens.end() && !is_next_key("size") && !is_next_key("terminal_states")
                   && !is_next_key("reward") && !is_next_key("transition_probabilities")
                   && !is_next_key("discount_rate") && !is_next_key("epsilon")) {
                int row, col; 
                // read wall position
                if(!pull_int(row) || !pull_int(col)) { 
                    cerr << "Invalid walls\n"; 
                    return false; 
                }
                // mark wall in mdp if valid position
                if (mdp.in_bounds(row, col)) {
                    mdp.wall[row][col] = true;
                }
            }

        } else if (key == "terminal_states") {
            // keep reading terminal states until next key or end of tokens
            while (it!= tokens.end() && !is_next_key("size") && !is_next_key("walls")
                   && !is_next_key("reward") && !is_next_key("transition_probabilities")
                   && !is_next_key("discount_rate") && !is_next_key("epsilon")) {
                int row, col; 
                double reward;
                // read terminal state position and reward
                if(!pull_int(row) || !pull_int(col) || !pull_double(reward)) { 
                    cerr << "Invalid terminal states\n"; 
                    return false; 
                }
                // mark terminal state and set reward if valid position
                if (mdp.in_bounds(row, col)) { 
                    mdp.is_terminal[row][col] = true; 
                    mdp.terminal_reward[row][col] = reward; 
                }
            }

        } else if (key == "reward") {
            // read default reward
            if (!pull_double(mdp.default_reward)) { 
                cerr << "Invalid reward\n"; 
                return false; 
            }

        } else if (key == "transition_probabilities") {
            // read 4 transition probabilities in order: intended, left, right, reverse
            if (!pull_double(mdp.transition_probabilities[0]) || !pull_double(mdp.transition_probabilities[1]) ||
                !pull_double(mdp.transition_probabilities[2]) || !pull_double(mdp.transition_probabilities[3])) {
                cerr << "Need 4 transition probabilities\n"; 
                return false;
            }

        } else if (key == "discount_rate") {
            // read discount rate
            if (!pull_double(mdp.discount_rate)) { 
                cerr << "Bad discount_rate\n"; 
                return false; 
            }

        } else if (key == "epsilon") {
            // read epsilon
            if (!pull_double(mdp.epsilon)) { 
                cerr << "Bad epsilon\n"; 
                return false; 
            }

        } else {
            cerr << "Unknown key: " << key << "\n";
            return false;
        }
    }

    // validate grid size
    if (mdp.rows <= 0 || mdp.cols <= 0) {
        cerr << "Grid size missing/invalid.\n"; 
        return false;
    }

    // successful load
    return true;
}
#pragma endregion

#pragma region value iteration functions
// direction arrays and arrow symbols
// dr is change in row, dc is change in column, ARROW is symbol for action
// dr, dc: U,R,D,L
// i.e. dr[0], dc[0] is up; dr[1], dc[1] is right; etc.
static const int dr[4] = {-1, 0, 1, 0}; // U,R,D,L
static const int dc[4] = { 0, 1, 0,-1};
static const char ARROW[4] = {'^','>','v','<'};

// helper functions to find index of directions left, right, and reverse of a given direction
// i.e. left_of(0) = 3 (left of up is left), left_of(1) = 0 (left of right is up), etc.
static inline int left_of(int dir) { 
    return (dir+3) % 4; 
}
static inline int right_of(int dir) { 
    return (dir+1) % 4;
}
static inline int reverse_of(int dir) { 
    return (dir+2) % 4; 
}

// helper function to compute next position after taking action a from (row, col)
// if next position is out of bounds or a wall, stay in place
// returns pair of (new_row, new_col)
static inline pair<int,int> step_or_stay(const MDP& mdp, int row, int col, int action) {
    int new_row = row + dr[action], new_col = col + dc[action];
    if (!mdp.in_bounds(new_row, new_col) || mdp.wall[new_row][new_col]) {
        return {row, col};
    }
    return {new_row, new_col};
}

// compute Q-value for state (r,c) and action a given utilities U
// Q(s,a) = sum_{s'} P(s'|s,a) * U(s')
// where s' are possible next states from s taking action a
// mdp: MDP structure
// U: current utility grid
// row, col: current state position 
// action: action index
// returns computed Q-value
static double q_value(const MDP& mdp, const vector<vector<double>>& U, int row, int col, int action) {
    array<int,4> acts{action, left_of(action), right_of(action), reverse_of(action)};
    const double probabilities[4] = { mdp.transition_probabilities[0], mdp.transition_probabilities[1], 
                        mdp.transition_probabilities[2], mdp.transition_probabilities[3] };
    double q = 0.0;

    for (int i = 0; i < 4; i++) {
        auto [new_row, new_col] = step_or_stay(mdp, row, col, acts[i]);
        q += probabilities[i] * U[new_row][new_col];
    }
    return q;
}

// print utility grid
// for walls, print '#'; for terminal states, print their reward
// for others, print utility value with 3 decimal places
// mdp: MDP structure
// G: utility grid to print
void print_utility_grid(const MDP& mdp, const vector<vector<double>>& G) {
    cout.setf(ios::fixed);
    cout << setprecision(3);

    for (int r = 1; r <= mdp.rows; r++) {
        for (int c = 1;c <= mdp.cols; c++) {
            if (mdp.wall[r][c]) {
                cout << setw(8) << "#";
            } else if (mdp.is_terminal[r][c]) {
                cout << setw(8) << mdp.terminal_reward[r][c];
            } else {
                cout << setw(8) << G[r][c];
            }
        }
        cout << "\n";
    }
}

// print policy grid
// for walls, print '#'; for terminal states, print 'T'
// for others, print action arrow
// mdp: MDP structure
// P: policy grid to print
void print_policy_grid(const MDP& mdp, const vector<vector<char>>& P) {
    for (int r = 1; r <= mdp.rows; r++) {
        for (int c = 1; c <= mdp.cols; c++) {
            if (mdp.wall[r][c]) {
                cout << "  #  ";
            }
            else if (mdp.is_terminal[r][c]) {
                cout << "  T  ";
            }
            else {
                cout << "  " << P[r][c] << "  ";
            }
        }
        cout << "\n";
    }
}

VIResult run_value_iteration(const MDP& mdp, bool print_each_iter) {
    vector<vector<double>> U(mdp.rows+1, vector<double>(mdp.cols+1, 0.0));
    vector<vector<double>> Up = U;

    // initialize terminal utilities to their rewards
    for (int r=1;r<=mdp.rows;r++)
        for (int c=1;c<=mdp.cols;c++)
            if (mdp.is_terminal[r][c]) U[r][c] = mdp.terminal_reward[r][c];

    if (print_each_iter) {
        cout << "Initial utilities (iteration 0):\n";
        print_utility_grid(mdp, U);
        cout << "\n";
    }

    int i = 0;
    while (true) {
        i++;
        double delta = 0.0;
        Up = U;

        for (int r=1;r<=mdp.rows;r++) {
            for (int c=1;c<=mdp.cols;c++) {
                if (m.wall[r][c]) continue;
                if (m.is_terminal[r][c]) { Up[r][c] = mdp.terminal_reward[r][c]; continue; }

                double R = m.default_reward;
                double best = -1e300;
                for (int a=0;a<4;a++) {
                    best = max(best, R + m.gamma * q_value(m, U, r, c, a));
                }
                Up[r][c] = best;
                delta = max(delta, fabs(Up[r][c] - U[r][c]));
            }
        }

        U.swap(Up);

        if (print_each_iter) {
            std::cout << "Iteration " << i << " utilities:\n";
            print_utility_grid(m, U);
            std::cout << "\n";
        }

        // stop condition (AIMA Fig 17.6; for gamma==1, use absolute epsilon)
        double bound = (mdp.discount_rate < 1.0) ? (mdp.epsilon * (1.0 - mdp.discount_rate) / mdp.discount_rate) : mdp.epsilon;
        if (delta <= bound) break;
    }

    // Build final policy
    vector<vector<char>> P(mdp.rows+1, vector<char>(mdp.cols+1, '?'));
    for (int r=1;r<=mdp.rows;r++) {
        for (int c=1;c<=mdp.cols;c++) {
            if (mdp.wall[r][c]) { P[r][c] = '#'; continue; }
            if (mdp.is_terminal[r][c]) { P[r][c] = 'T'; continue; }

            double R = m.default_reward;
            int bestA = 0;
            double best = -1e300;
            for (int a=0;a<4;a++) {
                double val = R + m.gamma * q_value(m, U, r, c, a);
                if (val > best) { best = val; bestA = a; }
            }
            P[r][c] = ARROW[bestA];
        }
    }

    VIResult res;
    res.U = move(U);
    res.policy = move(P);
    res.iterations = i;
    return res;
}
#pragma endregion