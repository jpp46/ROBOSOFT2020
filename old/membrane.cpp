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

const double vxSize = 0.0015875;
const double RHO = 1070000;
const double ES = 68900;
const double EF = 16000000;
const double M = vxSize * vxSize * vxSize * RHO;

void make_membrane(CVoxelyze *Vx, vector<Vec3D<int>> fiber_pos)
{

    CVX_Material *silicone = Vx->addMaterial(ES, RHO);
    silicone->setColor(0, 0, 255);
    silicone->setInternalDamping(1.0);

    CVX_Material *expand = Vx->addMaterial(EF / 10, RHO);
    expand->setCte(0.05);
    expand->setColor(0, 255, 0);
    expand->setInternalDamping(1.0);

    CVX_Material *fiber = Vx->addMaterial(EF, RHO);
    fiber->setColor(255, 0, 0);
    fiber->setInternalDamping(1.0);

    double center = (DIM / 2) + 0.5;
    double radius = DIM / 2.0;

    for (int x = 1; x <= DIM; x++)
    {
        for (int y = 1; y <= DIM; y++)
        {
            if (sqrt(pow(x - center, 2.0) + pow(y - center, 2.0)) <= radius)
            {
                Vx->setVoxel(silicone, x, y, -1);
                Vx->setVoxel(expand, x, y, 0);
                Vx->setVoxel(silicone, x, y, 1);
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
    while (t < 3)
    {
        Vx->setAmbientTemperature(t, true);
        Vx->doTimeStep(dt);
        t += dt;
    }

    double temp = t;
    for (int i = 0; i < 6000; i++)
    {
        Vx->setAmbientTemperature(temp, true);
        Vx->doTimeStep(dt);
        t += dt;
    }
}

double fitness(vector<Vec3D<int>> fiber_pos, vector<vector<double>> target)
{
    CVoxelyze Vx(vxSize);
    make_membrane(&Vx, fiber_pos);
    Vx.enableFloor(false);
    Vx.enableCollisions(false);
    Vx.enableDrag(false);
    Vx.setGravity(0);
    double dt = Vx.recommendedTimeStep() / 1.2;

    run(&Vx, dt);

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
    for (int x = 0; x < DIM; x++)
    {
        for (int y = 0; y < DIM; y++)
        {
            ftns -= abs(current[x][y] - target[x][y]);
        }
    }
    return ftns;
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

    double ftns = fitness(fiber_pos, target);
    cout << "ftns: " << ftns << endl;

    fs.open(fiber_path + ".res", fstream::out);
    fs << ftns << endl;
    fs.close();

    return 0;
}
