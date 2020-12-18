from Bezier import Bezier
import constants as c
import random
import math
import numpy as np
import sys
from subprocess import call

class INDIVIDUAL:
    def __init__(self, i, d):
        # assuming curves have one control point, [Sx, Ex, Cx, Cy] for each fiber
        # assuming we have two planes, each with c.FIBERS of fibers on them
        self.genome = np.random.randint(0, high=c.GRID_SIZE-1, size=(c.FIBERS, 4), dtype='int')
        self.fitness = -10000
        self.error = -10000
        self.ID = i
        self.d = d
        self.rnd1 = np.random.randint(low=1, high=10000)
        self.rnd2 = np.random.randint(low=1, high=10000)
    
    def Start_Evaluation(self, plot=False):
        self.rnd1 = np.random.randint(low=1, high=10000)
        self.rnd2 = np.random.randint(low=1, high=10000)
        # make Bezier curves representing the fibers
        t_points = np.arange(0, 1, 0.01)
        # plane of vertical fibers
        vertical_grid = np.zeros((c.GRID_SIZE, c.GRID_SIZE))
        for n in range(c.FIBERS_TOP):
            points = np.array([[self.genome[n, 0], self.genome[n, 1]], [self.genome[n, 2], self.genome[n, 3]]])
            curve = Bezier.Curve(t_points, points)
            grid = Bezier.DistCurve(curve)
            vertical_grid = np.logical_or(vertical_grid, grid)
        
        # plane of horizontal fibers
        horizontal_grid = np.zeros((c.GRID_SIZE, c.GRID_SIZE))
        for n in range(c.FIBERS_TOP, c.FIBERS):
            points = np.array([[self.genome[n, 0], self.genome[n, 1]], [self.genome[n, 2], self.genome[n, 3]]])
            curve = Bezier.Curve(t_points, points)
            grid = Bezier.DistCurve(curve)
            horizontal_grid = np.logical_or(horizontal_grid, grid)
            
        # save the grids
        if plot:
            Bezier.PlotGrid(vertical_grid, "verticalGrid.jpg")
            Bezier.PlotGrid(horizontal_grid, "horizontalGrid.jpg")
        
        file = open(f'results/bezier/genome{self.ID}_{self.rnd1}_{self.rnd2}.csv', 'w')
        l = np.count_nonzero(horizontal_grid) + np.count_nonzero(vertical_grid)
        file.write(f'{l} ')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                if horizontal_grid[i, j]:
                    file.write(f'{i+1} {j+1} -2 ')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                if vertical_grid[i, j]:
                    file.write(f'{i+1} {j+1} 0 ')
        file.close()
        call(['./membrane.exe', f'results/bezier/genome{self.ID}_{self.rnd1}_{self.rnd2}.csv', f'target/d{self.d}.csv.res'])
    
    def Compute_Fitness(self):
        file = open(f'results/bezier/genome{self.ID}_{self.rnd1}_{self.rnd2}.csv.res', 'r')
        results = file.read().split(' ')
        self.fitness = -float(results[0])
        self.error = -float(results[1])
        file.close()
        call(['rm', f'results/bezier/genome{self.ID}_{self.rnd1}_{self.rnd2}.csv'])
        call(['rm', f'results/bezier/genome{self.ID}_{self.rnd1}_{self.rnd2}.csv.res'])
    
    def Mutate(self):
        geneToMutateRow = random.randint(0, c.FIBERS-1)
        geneToMutateCol = random.randint(0, 4-1)
        #self.genome[geneToMutateRow, geneToMutateCol] = random.gauss(self.genome[geneToMutateRow, geneToMutateCol] , math.fabs(self.genome[geneToMutateRow, geneToMutateCol]))
        self.genome[geneToMutateRow, geneToMutateCol] = random.randint(0, c.GRID_SIZE-1)
    
    def Print(self):
        print('[', self.ID, self.fitness, ']', end=' ')
        
    
    def SaveBest(self, seed, d):
        # make Bezier curves representing the fibers
        t_points = np.arange(0, 1, 0.01)
        # plane of vertical fibers
        vertical_grid = np.zeros((c.GRID_SIZE, c.GRID_SIZE))
        for n in range(c.FIBERS_TOP):
            points = np.array([[self.genome[n, 0], self.genome[n, 1]], [self.genome[n, 2], self.genome[n, 3]]])
            curve = Bezier.Curve(t_points, points)
            grid = Bezier.DistCurve(curve)
            vertical_grid = np.logical_or(vertical_grid, grid)
        
        # plane of horizontal fibers
        horizontal_grid = np.zeros((c.GRID_SIZE, c.GRID_SIZE))
        for n in range(c.FIBERS_TOP, c.FIBERS):
            points = np.array([[self.genome[n, 0], self.genome[n, 1]], [self.genome[n, 2], self.genome[n, 3]]])
            curve = Bezier.Curve(t_points, points)
            grid = Bezier.DistCurve(curve)
            horizontal_grid = np.logical_or(horizontal_grid, grid)

        file = open(f'results/best/Bezier-D{d}-Seed-{seed}.csv', 'w')
        l = np.count_nonzero(horizontal_grid) + np.count_nonzero(vertical_grid)
        file.write(f'{l} ')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                if horizontal_grid[i, j]:
                    file.write(f'{i+1} {j+1} -2 ')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                if vertical_grid[i, j]:
                    file.write(f'{i+1} {j+1} 0 ')
        file.close()

        file = open(f'results/best/Bezier-D{d}-Seed-{seed}-grid.csv', 'w')
        file.write('top grid:\n')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                file.write(f'{int(vertical_grid[i, j])} ')
            file.write('\n')

        file.write('\nbot grid:\n')
        for i in range(c.GRID_SIZE):
            for j in range(c.GRID_SIZE):
                file.write(f'{int(horizontal_grid[i, j])} ')
            file.write('\n')
        file.close()




