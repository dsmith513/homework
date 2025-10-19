#pragma once

#include <array>
#include <string>
#include <vector>

using namespace std;

struct MDP {
    int rows = 0;
    int cols = 0;
    vector<vector<bool>> wall;
    vector<vector<bool>> is_terminal;
    vector<vector<double>> terminal_reward;
    double default_reward = 0.0;
    array<double, 4> transition_probabilities {};
    double gamma = 1.0;
    double epsilon = 0.001;

    bool in_bounds(int r, int c) const {
        return r>=1 && r<=rows && c>=1 && c<=cols;
    }
};

struct VIResult {
    vector<vector<double>> utilities;
    vector<vector<char>> policy;
    int iterations = 0;
};

bool load_mdp(string& path, MDP& mdp);
VIResult run_value_iteration(const MDP& mdp, bool print_each_iteration = true);

