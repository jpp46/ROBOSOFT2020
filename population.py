from individual import INDIVIDUAL
import copy
import random
import numpy as np

from copy import deepcopy

class POPULATION:
    def __init__(self, popSize, d):
        self.p = []
        self.popSize = popSize
        for i in range(0, self.popSize):
            self.p.append(INDIVIDUAL(i, d))
            
    def Print(self):
        for i in range(0, self.popSize):
            self.p[i].Print()
        print()
    
    def Evaluate(self):
        for i in range(0, self.popSize):
            self.p[i].Start_Evaluation()
        for i in range(0, self.popSize):
            self.p[i].Compute_Fitness()
            
    def Mutate(self):
        for i in range(0, self.popSize):
            self.p[i].Mutate()
            
    def ReplaceWith(self, other):
        for i in range(0, self.popSize):
            if (self.p[i].fitness < other.p[i].fitness):
                self.p[i] = deepcopy(other.p[i])
    
    def Fill_From(self, other):
        self.Copy_Best_From(other)
        #self.Print()
        self.Collect_Children_From(other)
        #self.Print()
    
    def Copy_Best_From(self, other):
        highest_fitness = -1
        highest_index = -1
        for i in range(0, self.popSize):
            if i == 0:
                highest_fitness = other.p[i].fitness
                highest_index = i
            elif (other.p[i].fitness >= highest_fitness):
                highest_fitness = other.p[i].fitness
                highest_index = i
        
        self.p[0] = deepcopy(other.p[highest_index])
        return highest_index
    
    def Collect_Children_From(self, other):
        for i in range(1,self.popSize):
            winner = other.Winner_Of_Tournament_Selection()
            self.p[i] = deepcopy(winner)
            self.p[i].Mutate()
            
    def Winner_Of_Tournament_Selection(other):
        p1 = random.randint(0, other.popSize-1)
        p2 = random.randint(0, other.popSize-1)
        while p1 == p2:
            p2 = random.randint(0, other.popSize-1)
        if other.p[p1].fitness > other.p[p2].fitness:
            return other.p[p1]
        else:
            return other.p[p2]

    def SavePopulation(self, g, seed, d):
        for i in range(0, self.popSize):
            with open(f'results/history/Bezier-genomes-D{d}-Seed{seed}/{g}-{i}.npy', 'wb') as file:
                np.save(file, self.p[i].genome)
    
    def SaveBestIndiv(self, seed, d):
        highest_fitness = -1
        highest_index = -1
        for i in range(0, self.popSize):
            if i == 0:
                highest_fitness = self.p[i].fitness
                highest_index = i
            elif (self.p[i].fitness >= highest_fitness):
                highest_fitness = self.p[i].fitness
                highest_index = i
        self.p[highest_index].SaveBest(seed, d)
    
    def SaveFitnessHistory(self, g, seed, d):
        f_sum = 0
        for i in range(0, self.popSize):
            f_sum += self.p[i].error 
        avg = f_sum / self.popSize
        
        file = open(f'results/history/Bezier-D{d}-Seed-{seed}-Avg.csv', 'a')
        file.write(f'{g}, {-avg}\n')
        file.close()

        highest_error = -1
        highest_index = -1
        for i in range(0, self.popSize):
            if i == 0:
                highest_error = self.p[i].error
                highest_index = i
            elif (self.p[i].error >= highest_error):
                highest_error = self.p[i].error
                highest_index = i
        file = open(f'results/history/Bezier-D{d}-Seed-{seed}-Best.csv', 'a')
        file.write(f'{g}, {-highest_error}\n')
        file.close()
        return avg