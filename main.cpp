# include <iostream>
# include <functional>
# include <cstring>

using namespace std;

hash<std::string> str_hash;
char hashes[22][8];
int max_collisions;

void hash_keywords() {
    char keywords[22][8] = {"array", "type", "is", "integer", "real", "boolean", "true",
                            "false", "record", "end", "while", "loop", "for", "in", "reverse",
                            "if", "then", "routine", "record", "foreach", "from", "loop"};
    for (auto &keyword : keywords) {
        int h = str_hash(keyword);
        h = abs(h) % 22;
        int cnt = 0;
        while (true) {
            h %= 22;
            if (hashes[h][0] == 0) {
                strncpy(hashes[h], keyword, 8);
                break;
            } else {
                h++;
                cnt++;
                max_collisions = max(cnt, max_collisions);
            }
        }
    }
}

bool isKeyword(const string &buffer) {
    int h = str_hash(buffer);
    h = abs(h) % 22;
    int cnt = 0;
    while (true) {
        h %= 22;
        if (buffer == hashes[h]) {
            return true;
        } else {
            cnt++;
            h++;
            if (cnt > max_collisions) {
                return false;
            }
        }
    }
}

int main() {
    hash_keywords();
    for (auto & word : hashes) {
        printf("%d ", isKeyword(word));
    }
    printf("\n");
    printf("%d ", isKeyword("zalupa"));
    printf("%d ", isKeyword("her"));
}