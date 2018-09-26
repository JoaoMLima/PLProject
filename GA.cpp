#include <bits/stdc++.h>
#define put push_back
#define mazeSize 11
#define F first
#define S second
using namespace std;
typedef pair<pair<int, int>, pair<int, int> > pairOfPairs;

/*
///////////////////////////////////////////////
Variaveis iniciais
*/
char maze[mazeSize][mazeSize+1];
int mazeDists[mazeSize][mazeSize];
char wallIcon = '|';
pair<int, int> spawn, escape;

/*
///////////////////////////////////////////////
Structs iniciais
*/

struct individual {
    int fitness;
    vector<int> moves;
    individual() {fitness = 0;}
};

struct population {
    int size;
    vector<individual> individuals;
    population(int sz) {size = sz;}
};

/*
///////////////////////////////////////////////
Funcoes auxiliares
*/
void randomSeed() {
    srand((int)time(0));
}

int randomRange(int start, int end, int step) {
    return (((rand()%(end-start+1))/step)*step)+start;
}



/*
///////////////////////////////////////////////
Funcoes utilitarias
*/
void mazeGeneratorRecursive(int x, int y, int dist) {
    mazeDists[x][y] = dist;
    int pairs[4][2] = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
    random_shuffle(pairs, pairs+4);
    for(int i = 0; i < 4; i++) {
        if (isValid(x+2*pairs[i][0], y+2*pairs[i][1]) && isAWall(x+2*pairs[i][0], y+2*pairs[i][1])) {
            maze[x+pairs[i][0]][y+pairs[i][1]] = ' ';
            maze[x+2*pairs[i][0]][y+2*pairs[i][1]] = ' ';
            mazeDists[x+pairs[i][0]][y+pairs[i][1]] = dist+1;
            mazeGeneratorRecursive(x+2*pairs[i][0], y+2*pairs[i][1], dist+2);
        }
    }
    //printf("%d %d %d %d %d %d %d %d\n", pairs[0][0], pairs[0][1], pairs[1][0], pairs[1][1], pairs[2][0], pairs[2][1], pairs[3][0], pairs[3][1]);
}
void mazeGenerator() {
    memset(maze, wallIcon, sizeof maze);
    for(int i = 0; i < mazeSize; i++) { maze[i][mazeSize] = '\n';}
    memset(mazeDists, -1, sizeof mazeDists);
    int x = randomRange(1, mazeSize-1, 2), y = (mazeSize-1)*randomRange(0, 1, 1);
    pairOfPairs coords = {{x, y}, {x, (y) ? y-1 : 1}};
    if (randomRange(0, 1, 1)) {
        swap(coords.F.F, coords.F.S);
        swap(coords.S.F, coords.S.S);
    }
    escape = coords.F, spawn = {randomRange(1, mazeSize-1, 2), randomRange(1, mazeSize-1, 2)};
    maze[escape.F][escape.S] = 'E', maze[coords.S.F][coords.S.S] = ' ';
    mazeDists[escape.F][escape.S] = 0;
    mazeGeneratorRecursive(coords.S.F, coords.S.S, 1);
    maze[spawn.F][spawn.S] = 'S';
}
void drawMaze() {
    printf("%s", maze);
}

int main() {
    randomSeed();
    mazeGenerator();
    drawMaze();
    
    return 0;
}