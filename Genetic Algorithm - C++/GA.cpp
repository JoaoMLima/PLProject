#include <bits/stdc++.h>
//#include <windows.h>
#include <unistd.h>
#include <thread>
#include <chrono>
#define put push_back
#define F first
#define S second
using namespace std;
typedef pair<pair<int, int>, pair<int, int>> pairOfPairs;
//typedef struct individual;

struct individual
{
    long long fitness;
    vector<char> moves;
    individual() { fitness = 0ll; }
    bool operator<(individual other)
    {
        //Comparador utilizado no sort
        return fitness > other.fitness;
    }
};

/*
///////////////////////////////////////////////
Variaveis iniciais
*/
int mazeSize = 0;
int populationSize = 1000;
const double mutationChance = 0.1;
const int fitnessConstant = 10e6;
vector<individual> population;
char **maze;
int **mazeDists;
char wallIcon = '|';
pair<int, int> spawn;
pair<int, int> escape;
int numOfWalls = 0;
char directions[4] = {'U', 'D', 'L', 'R'};
map<char, pair<int, int>> moves = {{'U', {-1, 0}}, {'D', {1, 0}}, {'L', {0, -1}}, {'R', {0, 1}}};
int chromossomeSize = 0;
map<char, array<char, 3>> coherentMoves = {{'U', {'U', 'L', 'R'}}, {'D', {'D', 'L', 'R'}}, {'R', {'R', 'D', 'U'}}, {'L', {'L', 'D', 'U'}}};
int quartil[4] = {(int)(populationSize * 0.01), (int)(populationSize * 0.25), (int)(populationSize * 0.4), (int)(populationSize * 0.75)};
map<int, pair<int, int>> groups = {{1, {0, quartil[0]}}, {2, {quartil[0] + 1, quartil[1]}}, {3, {quartil[1] + 1, quartil[2]}}, {4, {quartil[2] + 1, quartil[3]}}, {5, {quartil[3] + 1, populationSize - 1}}};
double groupsChance[5] = {0.5, 0.25, 0.15, 0.08, 0.02};
int groupsArray[100];
bool finished = false;

/*
///////////////////////////////////////////////
Structs iniciais
*/

/*
///////////////////////////////////////////////
Funcoes auxiliares
*/

bool isValid(int x, int y)
{
    bool xValid = (0 <= x && x < mazeSize);
    bool yValid = (0 <= y && y < mazeSize);
    return xValid && yValid;
}

bool isAWall(int x, int y)
{
    return maze[x][y] == wallIcon;
}

void randomSeed()
{
    srand((int)time(0));
}

int randomRange(int start, int end, int step = 1)
{
    if (start > end)
    {
        int temp = start;
        start = end;
        end = start;
    }
    return (((rand() % (end - start + 1)) / step) * step) + start;
}

void initVariables()
{
    maze = new char *[mazeSize];
    mazeDists = new int *[mazeSize];
    for (int i = 0; i < mazeSize; i++)
    {
        maze[i] = (char *)malloc(mazeSize * sizeof(char));
        memset(maze[i], wallIcon, mazeSize * sizeof(char));
        mazeDists[i] = (int *)malloc(mazeSize * sizeof(int));
        memset(mazeDists[i], -1, mazeSize * sizeof(int));
    }
    int j = 5;
    int count = 0;
    for (int i = 99; i >= 0; i--)
    {
        if (count < groupsChance[j - 1] * 100)
        {
            count++;
            groupsArray[i] = j;
        }
        else
        {
            count = 0;
            j--;
            i++;
        }
    }
}

/*
///////////////////////////////////////////////
Metodos de movimento
*/

pair<int, int> vectorSum(pair<int, int> point, pair<int, int> direction)
{
    pair<int, int> newPoint = {point.F + direction.F, point.S + direction.S};
    return newPoint;
}

pair<int, int> makeAMove(pair<int, int> point, char direction)
{
    return vectorSum(point, moves[direction]);
}

bool isValidMove(pair<int, int> point, char direction)
{
    pair<int, int> newPoint = vectorSum(point, moves[direction]);
    return isValid(newPoint.F, newPoint.S) && !isAWall(newPoint.F, newPoint.S);
}

/*
///////////////////////////////////////////////
Funcoes utilitarias
*/

void mazeGeneratorRecursive(int x, int y, int dist)
{
    mazeDists[x][y] = dist;
    int pairs[4][2] = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
    random_shuffle(pairs, pairs + 4);
    for (int i = 0; i < 4; i++)
    {
        if (isValid(x + 2 * pairs[i][0], y + 2 * pairs[i][1]) && isAWall(x + 2 * pairs[i][0], y + 2 * pairs[i][1]))
        {
            maze[x + pairs[i][0]][y + pairs[i][1]] = ' ';
            maze[x + 2 * pairs[i][0]][y + 2 * pairs[i][1]] = ' ';
            mazeDists[x + pairs[i][0]][y + pairs[i][1]] = dist + 1;
            numOfWalls -= 2;
            mazeGeneratorRecursive(x + 2 * pairs[i][0], y + 2 * pairs[i][1], dist + 2);
        }
    }
}
void mazeGenerator()
{

    int x = randomRange(1, mazeSize - 1, 2), y = (mazeSize - 1) * randomRange(0, 1);
    pairOfPairs coords = {{x, y}, {x, (y) ? y - 1 : 1}};
    if (randomRange(0, 1))
    {
        swap(coords.F.F, coords.F.S);
        swap(coords.S.F, coords.S.S);
    }
    escape = coords.F, spawn = {randomRange(1, mazeSize - 1, 2), randomRange(1, mazeSize - 1, 2)};
    maze[escape.F][escape.S] = 'E', maze[coords.S.F]
                [coords.S.S] = ' ';
    mazeDists[escape.F][escape.S] = 0;
    numOfWalls -= 2;
    mazeGeneratorRecursive(coords.S.F, coords.S.S, 1);
    maze[spawn.F][spawn.S] = 'S';
    chromossomeSize = mazeSize * mazeSize - numOfWalls;
}

void limparTela() {
    #ifdef WIN32
        system("cls");
    #else
        system("clear");
    #endif
}

void drawMaze()
{
    for (int i = 0; i < mazeSize; i++)
    {
        for (int j = 0; j < mazeSize; j++)
        {
            putchar(maze[i][j]);
        }
        putchar('\n');
    }
}


void drawFittest(vector<char> fittest)
{
    this_thread::sleep_for(std::chrono::seconds(7));
    limparTela();
    pair<int, int> indi = spawn;
    for(int h = 0; h < fittest.size(); h++) {
        maze[indi.F][indi.S] = '*';
        drawMaze();
        maze[indi.F][indi.S] = ' ';
        if (isValidMove(indi, fittest[h])) {
            indi = makeAMove(indi, fittest[h]);
        }
        if(maze[spawn.F][spawn.S] == ' '){
            maze[spawn.F][spawn.S] = 'S';
        }
        this_thread::sleep_for(std::chrono::milliseconds(150));
        limparTela();
        if(indi == escape) {
            break;
        }
    }
    maze[indi.F][indi.S] = '*';
    drawMaze();
}

void initPopulation()
{
    population.clear();
    for (int ind = 0; ind < populationSize; ind++)
    {
        population.push_back(individual());
        for (int move = 0; move < (rand() % chromossomeSize + 1); move++)
        {
            if (move)
            {
                population[ind].moves.push_back(coherentMoves[population[ind].moves.back()][randomRange(0, 2)]);
            }
            else
            {
                population[ind].moves.push_back(directions[randomRange(0, 3)]);
            }
        }
    }
}

/*
///////////////////////////////////////////////
Metodos do GA
*/

void calculateFitness()
{

    individual bestIndiv = individual();

    for (int i = 0; i < populationSize; i++)
    {
        set<pair<int, int>> visited;
        long long fitness = fitnessConstant;
        pair<int, int> startPoint = spawn;
        visited.insert(spawn);

        for (int j = 0; j < population[i].moves.size(); j++)
        {
            char move = population[i].moves[j];

            if (isValidMove(startPoint, move))
            {
                startPoint = makeAMove(startPoint, move);
                fitness -= 200;
            }
            else
            {
                fitness -= 400;
            }

            if (!visited.insert(startPoint).S)
            {
                fitness -= 300;
            }

            if (startPoint == escape)
            {
                fitness *= fitnessConstant;
                finished = true;
                break;
            }
        }

        if (population[i].moves.empty())
        {
            fitness = -fitnessConstant;
        }

        fitness -= mazeDists[startPoint.F][startPoint.S] * 1000;
        population[i].fitness = fitness;

        if (bestIndiv.fitness < population[i].fitness)
        {
            bestIndiv = population[i];
        }
    }
    string fittestString(bestIndiv.moves.begin(), bestIndiv.moves.end());
    cout << fittestString << endl;
}

void sortByFitness()
{
    sort(population.begin(), population.end());
}

double doubleRand()
{
    return double(rand()) / (double(RAND_MAX) + 1.0);
}

void mutation(individual &cromossome)
{
    if (mutationChance > doubleRand() && !cromossome.moves.empty())
    {
        if (doubleRand() > 0.9)
        {
            int temp = randomRange(1, cromossome.moves.size() / 2);
            for (int i = 0; i < temp; i++)
            {
                if (cromossome.moves.size() < chromossomeSize)
                {
                    cromossome.moves.push_back(coherentMoves[cromossome.moves.back()][randomRange(0, 2)]);
                }
            }
        }
        else
        {
            int temp = randomRange(1, cromossome.moves.size());
            for (int i = 0; i < temp; i++)
            {
                int idx = randomRange(0, cromossome.moves.size() - 1);
                if (idx != 0)
                {
                    cromossome.moves[idx] = coherentMoves[cromossome.moves[idx - 1]][randomRange(0, 2)];
                }
                else
                {
                    cromossome.moves[idx] = directions[randomRange(0, 3)];
                }
            }
        }
    }
}

vector<individual> crossover()
{
    vector<individual> newPopulation;
    set<string> chromossomeSet;

    for (int i = 0; i < populationSize; i++)
    {
        bool sonIsValid = false;
        vector<char> son;
        while (!sonIsValid)
        {
            pair<int, int> pairL = groups[groupsArray[randomRange(0, 99)]];
            pair<int, int> pairR = groups[groupsArray[randomRange(0, 99)]];
            int l1 = pairL.F;
            int l2 = pairL.S;
            int r1 = pairR.F;
            int r2 = pairR.S;
            vector<char> daddy = population[(randomRange(l1, r1))].moves;
            vector<char> mommy = population[(randomRange(l2, r2))].moves;

            vector<char> first = mommy;
            vector<char> second = daddy;

            if (rand() % 1)
            {
                swap(mommy, daddy);
            }

            int crossoverPoint = randomRange(1, chromossomeSize);

            for (int k = 0; k < crossoverPoint; k++)
            {
                if (k < first.size())
                {
                    son.push_back(first[k]);
                }
                else
                {
                    crossoverPoint = k;
                    break;
                }
            }

            for (int k = crossoverPoint; k < chromossomeSize; k++)
            {
                if (k < second.size())
                {
                    if (k == crossoverPoint)
                    {
                        son.push_back(coherentMoves[son.back()][randomRange(0, 2)]);
                    }
                    else
                    {
                        son.push_back(second[k]);
                    }
                }
                else
                {
                    break;
                }
            }

            string sonString(son.begin(), son.end());
            if (chromossomeSet.insert(sonString).S)
            {
                sonIsValid = true;
            }
            else
            {
                son.clear();
            }
        }

        individual newSon = individual();
        newSon.moves = son;
        mutation(newSon);
        newPopulation.push_back(newSon);
    }
    return newPopulation;
}

/*
///////////////////////////////////////////////
Metodo main
*/

int main()
{
    randomSeed();
    
    printf( "###################################################################################################################\n");
    printf( ".___  ___.      ___      ________   _______         _______.  ______    __      ____    ____  _______ .______      \n");
    printf( "|   \\/   |     /   \\    |       /  |   ____|       /       | /  __  \\  |  |     \\   \\  /   / |   ____||   _  \\     \n");
    printf( "|  \\  /  |    /  ^  \\   `---/  /   |  |__         |   (----`|  |  |  | |  |      \\   \\/   /  |  |__   |  |_)  |    \n");
    printf( "|  |\\/|  |   /  /_\\  \\     /  /    |   __|         \\   \\    |  |  |  | |  |       \\      /   |   __|  |      /     \n");
    printf( "|  |  |  |  /  _____  \\   /  /----.|  |____    .----)   |   |  `--'  | |  `----.   \\    /    |  |____ |  |\\ \\----.\n");
    printf( "|__|  |__| /__/     \\__\\ /________||_______|   |_______/     \\______/  |_______|    \\__/     |_______|| _| `._____|\n\n");
    printf( "###################################################################################################################\n\n");
    cout << "Size of maze: ";
    cin >> mazeSize;
    if (mazeSize <= 2) {
        mazeSize = 3;
    }
    if (mazeSize % 2 == 0){
        mazeSize += 1;
    }
    cout << endl;
    bool generate = true;

    do
    {
        //Necessárpara não acabar com o cálculo de chromossomeSize ao refazer o labirinto.

        numOfWalls = mazeSize * mazeSize;
        initVariables();
        mazeGenerator();
        drawMaze();
        cout << "Generate new maze?(y/n): ";
        string resposta;
        cin >> resposta;
        generate = (resposta == "y") ? true : false;
    } while (generate);

    cout << "Size of population: ";
    cin >> populationSize;

    initPopulation();
    int generation = 0;
    int fittestFitness = 0;
    vector<char> fittest;

    int limitOfGenerations = 1000;
    
    cout << "Limit of Generations: ";
    cin >> limitOfGenerations;
    cout << endl;
    
    int start_s = clock();
    //fittestFitness < fitnessConstant + fitnessConstant / 100
    while (generation < limitOfGenerations && !finished)
    {
        cout << generation << " ";
        calculateFitness();
        sortByFitness();
        if (!finished)
        {
            population = crossover();
        }
        generation += 1;
    }
    sortByFitness();
    fittest = population[0].moves;
    int stop_s = clock();

    drawFittest(fittest);
    cout << "Generation " << generation << " Fittest Fitness = " << population[0].fitness << endl;

    cout << "Time to solve: " << (stop_s - start_s) / (double(CLOCKS_PER_SEC)) << endl;

    cout << "Now see the dumb individual generation (press enter)" << endl;
    getchar();
    getchar();
    
    cout << "Random solution:" << endl;
    int dumbGeneration = 0;
    finished = false;
    fittestFitness = 0;
    while (dumbGeneration < generation && !finished)
    {
        initPopulation();
        cout << dumbGeneration << " ";
        calculateFitness();
        sortByFitness();
        if(population[0].fitness > fittestFitness) {
            fittestFitness = population[0].fitness;
            fittest = population[0].moves;
        }
        dumbGeneration++;
    }
    if (!finished) {
        cout << "Maze not finished!" << endl;
    } else {
        cout << "Maze finished!" << endl;
    }
    string fittestString(fittest.begin(), fittest.end());
    cout << "Best individual: "<< fittestString << endl;

    drawFittest(fittest);
    cout << "Press enter to exit" << endl;
    getchar();
    return 0;
}