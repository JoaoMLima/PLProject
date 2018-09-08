#include <bits/stdc++.h>
using namespace std;
#define mp make_pair
#define fi first
#define se second
#define pr printf
#define size 11
typedef pair<int, int> pii;
char maze[size][size];
/*
Define the maze's size with a odd number.
*/
void maze_maker_recursive(int y, int x) {
	pii p[4] = {mp(1, 0), mp(-1, 0), mp(0, 1), mp(0, -1)};
	random_shuffle(p, p+4);
	for (int i = 0; i < 4; i++) {
		if (y+2*p[i].fi > 0 && y+2*p[i].fi < size - 1 &&
			x+2*p[i].se > 0 && x+2*p[i].se < size -1 &&
			maze[y+2*p[i].fi][x+2*p[i].se] == '|') {
			maze[y+p[i].fi][x+p[i].se] = ' ';
			maze[y+2*p[i].fi][x+2*p[i].se] = ' ';
			maze_maker_recursive(y+2*p[i].fi, x+2*p[i].se);
		}
	}
}
int main() {
	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			maze[i][j] = '|';
		}
	}
	srand (time(0));

	int x = (rand()%(size/2))*2 + 1; int y = (size-1)*(rand()%2);
	pii a[2] = {mp(x, x), mp(y, y ? size-2 : 1)};
	//pr("a[0] %d %d a[1] %d %d\n", a[0].fi, a[0].se, a[1].se, a[1].se);
	random_shuffle(a, a+2);
	maze[a[0].fi][a[1].fi] = 'S';
	maze[a[0].se][a[1].se] = ' ';
	maze_maker_recursive(a[0].se, a[1].se);
	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			putchar(maze[i][j]);
		}
		putchar('\n');
	}
}