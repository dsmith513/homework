#include <iostream>
#include "mdp.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <mdp_input_file>\n";
        return 1;
    }

    MDP mdp;
    if (!load_mdp(argv[1], mdp)) {
        std::cerr << "Failed to load MDP from file.\n";
        return 2;
    }

    // Runs value iteration and prints utilities at each iteration internally
    VIResult res = run_value_iteration(mdp, /*print_each_iter=*/true);

    // Print final policy (as required)
    std::cout << "Final policy:\n";
    print_policy_grid(mdp, res.policy);

    return 0;
}
