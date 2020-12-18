import matplotlib.pyplot as plt
from individual import INDIVIDUAL
from population import POPULATION
from subprocess import call
import constants as c
import random
import copy
import pickle
import sys

SEED = int(sys.argv[1])
D = int(sys.argv[2])
random.seed(SEED)
file = open(f'results/history/Bezier-D{D}-Seed-{SEED}-Best.csv', 'w')
file.write('G, Fitness\n')
file.close()
file = open(f'results/history/Bezier-D{D}-Seed-{SEED}-Avg.csv', 'w')
file.write('G, Fitness\n')
file.close()

call(['mkdir', f'results/history/Bezier-genomes-D{D}-Seed{SEED}'])

print("GENERATION: " + str(0))
print("========================================================")
parents = POPULATION(c.POP_SIZE, D)
parents.Evaluate()
parents.SaveFitnessHistory(0, SEED, D)
parents.SaveBestIndiv(SEED, D)

# for r in range(1, c.RUNS+1)
for g in range(1, c.GENS):
    print("GENERATION: " + str(g))
    print("========================================================")
    children = POPULATION(c.POP_SIZE, D)
    children.Fill_From(parents)
    children.Evaluate()

    parents.ReplaceWith(children)
    parents.SaveFitnessHistory(g, SEED, D)
    parents.SavePopulation(g, SEED, D)
    parents.SaveBestIndiv(SEED, D)