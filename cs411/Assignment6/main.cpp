#include <iostream>
#include "mdp.h"

using namespace std;

int main(int argc, char** argv) {
    string file_path = argv[1];
    MDP mdp;

    if (!load_mdp(file_path, mdp)) {
        cerr << "Failed to load MDP from file: " << file_path << "\n";
        return 2;
    }

    cout << "Running value iteration:\n\n";
    VIResult result = run_value_iteration(mdp, true);

    cout << "=============================================\n";
    cout << "Final utilities after " << result.iterations << " iterations:\n";
    print_utility_grid(mdp, result.utilities);
    cout << "\n";

    cout << "Optimal policy:\n";
    print_policy_grid(mdp, result.policy);
    cout << "=============================================\n";

    return 0;
}
