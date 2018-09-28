#include <bits/stdc++.h>
#include <windows.h>
#define put push_back
#define F first
#define S second
using namespace std;
typedef pair<pair<int, int>, pair<int, int>> pairOfPairs;
typedef struct individual;

/*
///////////////////////////////////////////////
Variaveis iniciais
*/
int mazeSize = 0;
int populationSize = 1000;
const double mutationChance = 0.4;
const int fitnessConstant = 10e6;
vector<individual> population;
char **maze;
int **mazeDists;
char wallIcon = '|';
pair<int, int> spawn, escape;
int numOfWalls = 0;
char directions[4] = {'U', 'D', 'L', 'R'};
map<char, pair<int, int>> moves = {{'U', {-1, 0}}, {'D', {1, 0}}, {'L', {0, -1}}, {'R', {0, 1}}};
int chromossomeSize;
map<char, array<char, 3>> coherentMoves = {{'U', {'U', 'L', 'R'}}, {'D', {'D', 'L', 'R'}}, {'R', {'R', 'D', 'U'}}, {'L', {'L', 'D', 'U'}}};
int quartil[4] = {(int)(populationSize * 0.01), (int)(populationSize * 0.25), (int)(populationSize * 0.4), (int)(populationSize * 0.75)};
map<int, pair<int, int>> groups = {{1, {0, quartil[0]}}, {2, {quartil[0] + 1, quartil[1]}}, {3, {quartil[1] + 1, quartil[2]}}, {4, {quartil[2] + 1, quartil[3]}}, {5, {quartil[3] + 1, populationSize - 1}}};
double groupsChance[5] = {0.5, 0.25, 0.15, 0.08, 0.02};
int groupsArray[100];

/*
///////////////////////////////////////////////
Structs iniciais
*/

struct individual
{
    int fitness;
    vector<char> moves;
    individual() { fitness = 0; }
    bool operator<(individual other)
    {
        //Comparador utilizado no sort
        return fitness < other.fitness;
    }
};

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
    if (start > end){
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
    // double groupsChance[5] = {0.5, 0.25, 0.15, 0.08, 0.02};
    int j = 5;
    int count = 0;
    for (int i = 99; i >= 0; i--)
    {
        if (count < groupsChance[j-1]*100 ){
            count++;
            groupsArray[i] = j;
        }
        else {
            count = 0;
            j--;
            i++;
        }
    }
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
    maze[escape.F][escape.S] = 'E', maze[coords.S.F][coords.S.S] = ' ';
    mazeDists[escape.F][escape.S] = 0;
    numOfWalls -= 2;
    mazeGeneratorRecursive(coords.S.F, coords.S.S, 1);
    maze[spawn.F][spawn.S] = 'S';
    chromossomeSize = mazeSize * mazeSize - numOfWalls - 1;
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

void initPopulation()
{
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
    return isValid(newPoint.F, newPoint.S) && isAWall(newPoint.F, newPoint.S);
}

/*
///////////////////////////////////////////////
Metodos do GA
*/

void calculateFitness()
{
    for (int i = 0; i < populationSize; i++)
    {
        individual indiv = population[i];
        set<pair<int, int>> visited;
        long long fitness = fitnessConstant;
        pair<int, int> startPoint = spawn;
        visited.insert(spawn);
        bool finished = false;

        // Talvez seja necessario colocar uma verificacao de not null aqui
        for (int j = 0; j < indiv.moves.size(); j++)
        {
            char move = indiv.moves[j];

            if (isValidMove(startPoint, move))
            {
                startPoint = makeAMove(startPoint, move);
                fitness += 10;
            }
            else
            {
                fitness -= 200;
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

        if (indiv.moves.empty())
        {
            fitness = -fitnessConstant;
        }

        fitness -= mazeDists[startPoint.F][startPoint.S] * 1000;
        indiv.fitness = fitness;
    }
}

void sortByFitness()
{
    reverse(population.begin(), population.end());
}

vector<char> getFittest()
{
    sortByFitness();
    return population.front().moves;
}

double doubleRand()
{
    return double(rand()) / (double(RAND_MAX) + 1.0);
}

void mutation(individual &cromossome)
{
    if (mutationChance > doubleRand() && !cromossome.moves.empty())
    {
        if (doubleRand() > 0.6)
        {
            int temp = randomRange(1, cromossome.moves.size() / 2);
            for (int i = 0; i < temp; i++)
            {
                if (!cromossome.moves.empty())
                {
                    // coherentMoves[mommy.back()][randomRange(0, 2)]
                    cromossome.moves.push_back(coherentMoves[cromossome.moves.back()][randomRange(0, 2)]);
                }
                else
                {
                    cromossome.moves.push_back(directions[randomRange(0, 3)]);
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
            
            if (l1 == 0 && l2 != 0)
            {
                for (int a = 0; a < chromossomeSize / 2; a++)
                {
                    if (a == 0)
                    {
                        daddy.push_back(directions[randomRange(0, 2)]);
                    }
                    else
                    {
                        daddy.push_back(coherentMoves[daddy.back()][randomRange(0, 2)]);
                    }
                }
                son = daddy;
            }
            else if (l2 == 0 && l1 != 0)
            {
                for (int a = 0; a < chromossomeSize / 2; a++)
                {
                    if (a == 0)
                    {
                        mommy.push_back(directions[randomRange(0, 2)]);
                    }
                    else
                    {
                        mommy.push_back(coherentMoves[mommy.back()][randomRange(0, 2)]);
                    }
                }
                son = mommy;
            }

            else
            {
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
                        son.push_back(first.at(k));
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
                            son.push_back(second.at(k));
                        }
                    }
                }
            }
            string sonString(son.begin(), son.end());
            if (chromossomeSet.insert(sonString).S)
            {
                sonIsValid = true;
            }
        }
        individual newSon;
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
    printf(
"---------------------------------------------------------- \n\
#################### - MAZER SOLVER - #################### \n\
---------------------------------------------------------- \n"
            );
    cout << "Size of maze: ";
    cin >> mazeSize;
    mazeSize = 2 * mazeSize + 1;
    cout << endl;
    bool generate = true;
    do
    { 
        initVariables();
        mazeGenerator();
        drawMaze();
        cout << "Generate new maze?(y/n): ";
        string resposta;
        cin >> resposta;
        generate = (resposta == "y") ? true : false;
    } while(generate);
    
    cout << "Size of population: ";
    cin >> populationSize;
    cout << endl;
    
    initPopulation();
    int generation = 0; 
    int fittestFitness = 0;
    vector<char> fittest;

    int limitOfGenerations = 20000;
/*
    cout << "Limit of Generations: ";
    cin >> limitOfGenerations;
    cout << endl;
    */
    
    int start_s=clock();

    while(generation < limitOfGenerations){
        calculateFitness();
        fittest = getFittest();
        fittestFitness = population.front().fitness;
        
        ///if fittestFitness > fitnessConstant : finalists.append(fittest);
        ///print (len(finalists))

        population = crossover();
        
        generation += 1;

        //Sleep(500);        
        
        string fittestString(fittest.begin(), fittest.end());     
        cout << fittestString << endl;     
        //system ("CLS"); 
    }

    int stop_s=clock();
    cout << "time: " << (stop_s-start_s)/double(CLOCKS_PER_SEC)*1000 << endl;
   
    return 0;
}