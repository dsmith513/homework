#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <cmath>
#include <algorithm>

using namespace std;

// trim helper function for clean string parsing
string trim(const string &s) {
    size_t start = 0;
    while (start < s.size() && isspace(static_cast<unsigned char>(s[start]))) start++;
    if (start == s.size()) return "";
    size_t end = s.size() - 1;
    while (end > start && isspace(static_cast<unsigned char>(s[end]))) end--;
    return s.substr(start, end - start + 1);
}

// data structure to represent one row of the csv file
// values represents each element in the row
struct Restaurant {
    vector<string> values;
};

// data structure to reperesent a node in the decision tree
struct DecisionTreeNode {
    bool is_leaf;
    string label;
    int attribute_index;
    map<string, DecisionTreeNode*> children;

    DecisionTreeNode(bool leaf=false) : is_leaf(leaf), attribute_index(-1) {}
};

// function to read CSV file into restaurants
// each row is a Restaurant
bool read_csv(const string &filename, vector<string> &attr_names, vector<Restaurant> &restaurants) {
    ifstream fin(filename);
    if (!fin) {
        cerr << "Cannot open file: " << filename << "\n";
        return false;
    }

    string line;

    if (!getline(fin, line)) {
        cerr << "Empty file\n";
        return false;
    }
    {
        stringstream ss(line);
        string cell;
        while (getline(ss, cell, ',')) {
            attr_names.push_back(trim(cell));
        }
    }

    while (getline(fin, line)) {
        if (line.empty()) continue;
        stringstream ss(line);
        string cell;
        Restaurant ex;
        while (getline(ss, cell, ',')) {
            string val = trim(cell);

            if (!val.empty() && val.back() == '\r') val.pop_back();
            ex.values.push_back(val);
        }
        if (!ex.values.empty())
            restaurants.push_back(ex);
    }

    return true;
}

// function to calculate entropy
double entropy(const vector<Restaurant> &restaurants, int target_index) {
    if (restaurants.empty()) return 0.0;
    unordered_map<string, int> counts;
    for (const auto &e : restaurants) {
        counts[e.values[target_index]]++;
    }
    double n = (double)restaurants.size();
    double H = 0.0;
    for (auto &p : counts) {
        double prob = p.second / n;
        if (prob > 0)
            H -= prob * log2(prob);
    }
    return H;
}

// function to calculate information gain
double information_gain(const vector<Restaurant> &restaurants,
                        int attr_index,
                        int target_index) {
    double base_entropy = entropy(restaurants, target_index);
    if (base_entropy == 0.0) return 0.0;

    unordered_map<string, vector<Restaurant>> subsets;
    for (const auto &e : restaurants) {
        subsets[e.values[attr_index]].push_back(e);
    }

    double n = (double)restaurants.size();
    double remainder = 0.0;
    for (auto &kv : subsets) {
        double weight = kv.second.size() / n;
        remainder += weight * entropy(kv.second, target_index);
    }
    return base_entropy - remainder;
}

// function to find plurality value of target attribute
// i.e., most common value
string plurality_value(const vector<Restaurant> &restaurants, int target_index) {
    unordered_map<string, int> counts;
    for (const auto &e : restaurants) {
        counts[e.values[target_index]]++;
    }
    string best_label;
    int best_count = -1;
    for (auto &p : counts) {
        if (p.second > best_count) {
            best_count = p.second;
            best_label = p.first;
        }
    }
    return best_label;
}

// function to check if all restaurants have the same classification
bool same_classification(const vector<Restaurant> &restaurants, int target_index) {
    if (restaurants.empty()) return true;
    const string &first = restaurants[0].values[target_index];
    for (const auto &e : restaurants) {
        if (e.values[target_index] != first) return false;
    }
    return true;
}

// returns indices of attributes still available (excluding target)
vector<int> all_attributes_except_target(int num_attrs, int target_index) {
    vector<int> attrs;
    for (int i = 0; i < num_attrs; ++i)
        if (i != target_index) attrs.push_back(i);
    return attrs;
}

// remove one attribute index from list
vector<int> remove_attribute(const vector<int> &attrs, int attr_index) {
    vector<int> res;
    for (int a : attrs)
        if (a != attr_index) res.push_back(a);
    return res;
}

// main decision tree learning function
DecisionTreeNode* learn_decision_tree(const vector<Restaurant> &restaurants,
                                      const vector<int> &attributes,
                                      const vector<Restaurant> &parent_restaurants,
                                      int target_index) {
    if (restaurants.empty()) {
        // if restaurants is empty, return plurality value of parent_restaurants
        DecisionTreeNode *leaf = new DecisionTreeNode(true);
        leaf->label = plurality_value(parent_restaurants, target_index);
        return leaf;
    } else if (same_classification(restaurants, target_index)) {
        // all restaurants have same classification
        DecisionTreeNode *leaf = new DecisionTreeNode(true);
        leaf->label = restaurants[0].values[target_index];
        return leaf;
    } else if (attributes.empty()) {
        // no attributes left
        DecisionTreeNode *leaf = new DecisionTreeNode(true);
        leaf->label = plurality_value(restaurants, target_index);
        return leaf;
    } else {
        // choose attribute with highest information gain
        double best_gain = -1.0;
        int best_attr = -1;
        for (int a : attributes) {
            double gain = information_gain(restaurants, a, target_index);
            if (gain > best_gain) {
                best_gain = gain;
                best_attr = a;
            }
        }

        DecisionTreeNode *tree = new DecisionTreeNode(false);
        tree->attribute_index = best_attr;

        // find all values of this attribute in current restaurants
        unordered_set<string> values_set;
        for (const auto &e : restaurants)
            values_set.insert(e.values[best_attr]);

        vector<int> new_attrs = remove_attribute(attributes, best_attr);

        for (const string &v : values_set) {
            vector<Restaurant> res;
            for (const auto &r : restaurants) {
                if (r.values[best_attr] == v)
                    res.push_back(r);
            }
            DecisionTreeNode *subtree =
                learn_decision_tree(res, new_attrs, restaurants, target_index);
            tree->children[v] = subtree;
        }
        return tree;
    }
}

// function to print the decision tree
void print_tree(const DecisionTreeNode *node, const vector<string> &attr_names, string indent = "") {
    if (node->is_leaf) {
        cout << indent << "Leaf: " << node->label << "\n";
        return;
    }

    cout << indent << attr_names[node->attribute_index] << " ?\n";
    for (const auto &child : node->children) {
        cout << indent << "  [" << child.first << "] -> ";
        if (child.second->is_leaf) {
            cout << "Leaf: " << child.second->label << "\n";
        } else {
            cout << "\n";
            print_tree(child.second, attr_names, indent + "    ");
        }
    }
}

void delete_tree(DecisionTreeNode *node) {
    if (!node) return;
    for (auto &kv : node->children) {
        delete_tree(kv.second);
    }
    delete node;
}


int main(int argc, char *argv[]) {
    string filename = "restaurant.csv";
    if (argc > 1) filename = argv[1];

    vector<string> attr_names;
    vector<Restaurant> restaurants;

    if (!read_csv(filename, attr_names, restaurants)) {
        return 1;
    }

    int num_attrs = (int)attr_names.size();
    int target_index = num_attrs - 1; // last column is the class label

    vector<int> attributes = all_attributes_except_target(num_attrs, target_index);

    DecisionTreeNode *tree = learn_decision_tree(restaurants, attributes, restaurants, target_index);

    cout << "Decision tree learned from " << filename << ":\n\n";
    print_tree(tree, attr_names);

    delete_tree(tree);
    return 0;
}
