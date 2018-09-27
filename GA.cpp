#include <bits/stdc++.h>
#define put push_back
#define F first
#define S second
using namespace std;
typedef pair<pair<int, int>, pair<int, int> > pairOfPairs;
typedef struct individual;

/*
///////////////////////////////////////////////
Variaveis iniciais
*/
const int mazeSize = 11;
const int populationSize = 1000;
const double mutationChance = 0.1;
const int fitnessConstant = 1e6;
vector<individual> population;
char maze[mazeSize][mazeSize+1];
int mazeDists[mazeSize][mazeSize];
char wallIcon = '|';
pair<int, int> spawn, escape;
int numOfWalls = mazeSize * mazeSize;
char directions[4] = {'U', 'D', 'L', 'R'};
map<char, pair<int, int> > moves = {{'U', {-1, 0}}, {'D', {1, 0}}, {'L', {0, -1}}, {'R', {0, 1}}};
int chromossomeSize;


/*
///////////////////////////////////////////////
Structs iniciais
*/

struct individual {
    int fitness;
    vector<char> moves;
    individual() {fitness = 0;}
    bool operator < (individual other) {
        //Comparador utilizado no sort
        return fitness < other.fitness;
    }
};

/*
///////////////////////////////////////////////
Funcoes auxiliares
*/

bool isValid(int x, int y){
    bool xValid = (0 <= x  && x < mazeSize );
    bool yValid = (0 <= y  && y < mazeSize );
    return xValid && yValid;
}
 
bool isAWall(int x, int y){
    return maze[x][y] == wallIcon;
}



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
            numOfWalls -= 2;
            mazeGeneratorRecursive(x+2*pairs[i][0], y+2*pairs[i][1], dist+2);
        }
    }
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
    numOfWalls -= 2;
    mazeGeneratorRecursive(coords.S.F, coords.S.S, 1);
    maze[spawn.F][spawn.S] = 'S';
    chromossomeSize = mazeSize * mazeSize - numOfWalls - 1;
}
void drawMaze() {
    printf("%s", maze);
}

void initPopulation () {
}

/*
///////////////////////////////////////////////
Metodos de movimento
*/

pair<int, int> vectorSum(pair<int, int> point, pair<int, int> direction){
    pair<int, int> newPoint = {point.F + direction.F, point.S + direction.S};
    return newPoint;
}
 
pair<int, int> makeAMove(pair<int, int> point, char direction){
    return vectorSum(point, moves[direction]);
}
 
bool isValidMove(pair<int, int> point, char direction){
    pair<int, int> newPoint = vectorSum(point, moves[direction]);
    return isValid(newPoint.F, newPoint.S) && isAWall(newPoint.F, newPoint.S);
}

/*
///////////////////////////////////////////////
Metodos do GA
*/

void sortByFitness(){
    reverse (population.begin(), population.end());
}
 
vector<char> getFittest(){
    sortByFitness();
    return population.front().moves;
}


/*
///////////////////////////////////////////////
Metodo main
*/

int main() {
    randomSeed();
    mazeGenerator();
    drawMaze();
    initPopulation();
    
    return 0;
}