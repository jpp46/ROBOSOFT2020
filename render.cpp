#include <My_MeshRender.h>
#include <Voxelyze.h>
#include <fstream>
#include <iostream>
#include <math.h>
#include <numeric>
#include <string>
#include <tuple>
#include <vector>

#ifdef USE_OMP
#include <omp.h>
#endif

using namespace std;

double t = 0;

const int DIM = 50;
const double DIAMETER = 0.14;
const double S_DIAMETER = 0.1825;
const double THICKNESS = 0.0015875 * 3;

const double vxSize = DIAMETER / DIM;
double sim_time = 1.6;
double cte = ((S_DIAMETER / DIAMETER) - 1.0) / sim_time;
double RHO = 1000000;
double ES = 68900;
double EF = 9000000;
double EE = 160000;
const double M = vxSize * vxSize * vxSize * RHO;

void make_membrane(CVoxelyze *Vx, vector<Vec3D<int>> fiber_pos)
{

    CVX_Material *silicone = Vx->addMaterial(ES, RHO);
    silicone->setColor(102, 255, 102, 60);
    silicone->setInternalDamping(1.0);

    CVX_Material *expand = Vx->addMaterial(EE, RHO);
    expand->setCte(0.06);
    expand->setColor(102, 255, 102, 60);
    expand->setInternalDamping(1.0);

    CVX_Material *fiber = Vx->addMaterial(EF, RHO);
    fiber->setColor(277, 38, 54, 255);
    fiber->setInternalDamping(1.0);

    double center = (DIM / 2) + 0.5;
    double radius = DIM / 2.0;

    for (int x = 1; x <= DIM; x++)
    {
        for (int y = 1; y <= DIM; y++)
        {
            if (sqrt(pow(x - center, 2.0) + pow(y - center, 2.0)) <= radius)
            {
                Vx->setVoxel(silicone, x, y, 0);
                Vx->setVoxel(expand, x, y, -1);
                Vx->setVoxel(silicone, x, y, -2);
            }
        }
    }

    for (int i = 0; i < fiber_pos.size(); i++)
    {
        auto pos = fiber_pos[i];
        if (sqrt(pow(pos.x - center, 2.0) + pow(pos.y - center, 2.0)) <= radius)
            Vx->setVoxel(fiber, pos.x, pos.y, pos.z);
    }
}

void run(CVoxelyze *Vx, double dt)
{
    while (t < sim_time)
    {
        Vx->setAmbientTemperature(t, true);
        Vx->doTimeStep(dt);
        t += dt;
    }

    double temp = t;
    for (int i = 0; i < 1000; i++)
    {
        Vx->setAmbientTemperature(temp, true);
        Vx->doTimeStep(dt);
        t += dt;
    }
}

tuple<double, double> fitness(vector<Vec3D<int>> fiber_pos, vector<vector<double>> target)
{
    CVoxelyze Vx(vxSize);
    make_membrane(&Vx, fiber_pos);
    Vx.enableFloor(false);
    Vx.enableCollisions(false);
    Vx.enableDrag(false);
    Vx.setGravity(0);
    double dt = Vx.recommendedTimeStep() / 1.2;
    Vx.doTimeStep(dt);

    My_MeshRender R(&Vx);
    R.generateMesh();
    R.saveMesh(2);
    run(&Vx, dt);
    R.generateMesh();
    R.saveMesh(3);

    auto voxels = Vx.voxelList();
    int size = voxels->size();
    vector<vector<double>> current(DIM, vector<double>(DIM));
    for (auto i = 0; i < size; i++)
    {
        CVX_Voxel *vx = (*voxels)[i];
        auto p = vx->position();
        current[vx->indexX() - 1][vx->indexY() - 1] += p.z / 3;
    }

    double ftns = 0;
    double max_errs = 0;
    double errs = 0;
    double n = 0;
    for (int x = 0; x < DIM; x++)
    {
        for (int y = 0; y < DIM; y++)
        {
            double max_error = abs((-1 * vxSize) - target[x][y]);
            double error = abs(current[x][y] - target[x][y]);
            if (max_error != 0)
            {
                errs += error;
                max_errs += max_error;
                ftns += error;
                n += 1;
            }
        }
    }
    double avg_err = (errs / n) / (max_errs / n);
    tuple<double, double> values(ftns / n, avg_err);
    return values;
}

int main(int argc, char *argv[])
{
    cout << "running" << endl;
    vector<Vec3D<int>> fiber_pos;
    vector<vector<double>> target(DIM, vector<double>(DIM));
    string fiber_path = string(argv[1]);
    string target_path = string(argv[2]);
    fstream fs;
    int length;

    fs.open(fiber_path, fstream::in);
    fs >> length;
    int x, y, z = 0;
    for (int i = 0; i < length; i++)
    {
        fs >> x;
        fs >> y;
        fs >> z;
        fiber_pos.push_back(Vec3D<int>(x, y, z));
    }
    fs.close();

    fs.open(target_path, fstream::in);
    for (int x = 0; x < DIM; x++)
    {
        for (int y = 0; y < DIM; y++)
        {
            fs >> target[x][y];
        }
    }
    fs.close();

    tuple<double, double> ftns = fitness(fiber_pos, target);
    cout << "ftns: " << get<0>(ftns) << endl;
    cout << "avg_err: " << get<1>(ftns) << endl;

    fs.open(fiber_path + ".res", fstream::out);
    fs << get<0>(ftns) << " " << get<1>(ftns);
    fs.close();

    return 0;
}
