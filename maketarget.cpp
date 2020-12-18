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

// 3/16 of an inch
// 14 centimeter diameter uninflated
//? centimeter diameter inflated

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

vector<vector<double>> maketarget(vector<Vec3D<int>> fiber_pos)
{
    CVoxelyze Vx(vxSize);
    make_membrane(&Vx, fiber_pos);
    Vx.enableFloor(false);
    Vx.enableCollisions(false);
    Vx.enableDrag(false);
    Vx.setGravity(0.0);
    double dt = Vx.recommendedTimeStep() / 1.2;

    My_MeshRender R(&Vx);
    R.generateMesh();
    R.saveMesh(0);
    run(&Vx, dt);
    R.generateMesh();
    R.saveMesh(1);

    auto voxels = Vx.voxelList();
    int size = voxels->size();
    vector<vector<double>> target(DIM, vector<double>(DIM));
    for (auto i = 0; i < size; i++)
    {
        CVX_Voxel *vx = (*voxels)[i];
        auto p = vx->position();
        target[vx->indexX() - 1][vx->indexY() - 1] += p.z / 3;
    }
    return target;
}

double normalize(double x, double minx, double maxx, double a, double b)
{
    return ((b - a) * ((x - minx) / (maxx - minx))) + a;
}

int main(int argc, char *argv[])
{
    cout << "running" << endl;
    vector<Vec3D<int>> fiber_pos;
    string fiber_path = string(argv[1]);
    int bin = 0;
    fstream fs;

    fs.open(fiber_path, fstream::in);
    for (int y = DIM; y >= 1; y--)
    {
        for (int x = 1; x <= DIM; x++)
        {
            fs >> bin;
            if (bin == 1)
            {
                fiber_pos.push_back(Vec3D<int>(x, y, 0));
            }
        }
    }
    for (int y = DIM; y >= 1; y--)
    {
        for (int x = 1; x <= DIM; x++)
        {
            fs >> bin;
            if (bin == 1)
            {
                fiber_pos.push_back(Vec3D<int>(x, y, -2));
            }
        }
    }
    fs.close();

    vector<vector<double>> target = maketarget(fiber_pos);
    fs.open(fiber_path + ".res", fstream::out);
    for (int x = 0; x < DIM; x++)
    {
        for (int y = 0; y < DIM; y++)
        {
            fs << target[x][y] << " ";
        }
    }
    fs.close();

    return 0;
}

//[0.00047689639923449625, 0.8836675486929911, 0.8424901681316475, 0.06410134333356451, 0.0004133791324143642,
// 0.8108404488034004]
