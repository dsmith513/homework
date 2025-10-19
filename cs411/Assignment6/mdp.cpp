#include "mdp.h"
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

static inline string ltrim(const string& s) {
    size_t i = 0; while (i < s.size() && std::isspace((unsigned char)s[i])) ++i;
    return s.substr(i);
}
static inline string rtrim(const string& s) {
    if (s.empty()) return s;
    size_t i = s.size();
    while (i>0 && std::isspace((unsigned char)s[i-1])) --i;
    return s.substr(0, i);
}
static inline string trim(const string& s) { return rtrim(ltrim(s)); }

static inline vector<string> tokenize_line(const string& line) {
    // Split by whitespace, commas, or colons
    vector<string> out;
    string cur;
    auto flush=[&](){ if(!cur.empty()){ out.push_back(cur); cur.clear(); } };
    for (char ch : line) {
        if (std::isspace((unsigned char)ch) || ch==',' || ch==':') flush();
        else cur.push_back(ch);
    }
    flush();
    return out;
}