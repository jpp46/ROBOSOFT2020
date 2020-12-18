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
    silicone->setColor(0, 0, 255);
    silicone->setInternalDamping(1.0);

    CVX_Material *expand = Vx->addMaterial(EE, RHO);
    expand->setCte(0.06);
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

double error(vector<Vec3D<int>> fiber_pos, vector<Vec3D<double>> points)
{
    CVoxelyze Vx(vxSize);
    make_membrane(&Vx, fiber_pos);
    Vx.enableFloor(false);
    Vx.enableCollisions(false);
    Vx.enableDrag(false);
    Vx.setGravity(0);
    double dt = Vx.recommendedTimeStep() / 1.2;
    Vx.doTimeStep(dt);

    double baseline_avg_diff = 0;
    for (int i = 0; i < points.size(); i += 4)
    {
        double avg_z = 0;
        double offset = vxSize / 2;
        avg_z += (Vx.voxel((int)points[i].x, (int)points[i].y, 0)->position().z - offset);
        avg_z += (Vx.voxel((int)points[i + 1].x, (int)points[i + 1].y, 0)->position().z - offset);
        avg_z += (Vx.voxel((int)points[i + 2].x, (int)points[i + 2].y, 0)->position().z - offset);
        avg_z += (Vx.voxel((int)points[i + 3].x, (int)points[i + 3].y, 0)->position().z - offset);
        avg_z /= 4;
        baseline_avg_diff += abs(points[i].z - avg_z) / 20;
    }

    run(&Vx, dt);

    double avg_diff = 0;
    for (int i = 0; i < points.size(); i += 4)
    {
        double avg_z = 0;
        double offset = vxSize / 2;
        avg_z += (Vx.voxel((int)points[i].x, (int)points[i].y, 0)->position().z);
        avg_z += (Vx.voxel((int)points[i + 1].x, (int)points[i + 1].y, 0)->position().z);
        avg_z += (Vx.voxel((int)points[i + 2].x, (int)points[i + 2].y, 0)->position().z);
        avg_z += (Vx.voxel((int)points[i + 3].x, (int)points[i + 3].y, 0)->position().z);
        avg_z /= 4;
        avg_diff += abs(points[i].z - avg_z) / 20;
    }
    return avg_diff / baseline_avg_diff;
}

int main(int argc, char *argv[])
{
    cout << "running" << endl;
    vector<string> sim_paths{"results/best/Bezier-D1-Seed-0.csv", "results/best/Bezier-D1-Seed-1.csv",
                             "results/best/Bezier-D1-Seed-2.csv", "results/best/Bezier-D1-Seed-3.csv",
                             "results/best/Bezier-D2-Seed-0.csv", "results/best/Bezier-D2-Seed-1.csv",
                             "results/best/Bezier-D2-Seed-2.csv"};
    vector<string> real_paths{"target/saddle-target-0.csv", "target/saddle-target-1.csv", "target/saddle-target-2.csv",
                              "target/saddle-target-3.csv", "target/monkey-target-0.csv", "target/monkey-target-1.csv",
                              "target/monkey-target-2.csv"};
    fstream sp;
    fstream rp;
    fstream pp;
    int length, x, y, z;
    for (int i = 0; i < 7; i++)
    {
        sp.open(sim_paths[i], fstream::in);
        sp >> length;
        vector<Vec3D<int>> fiber_pos;
        for (int i = 0; i < length; i++)
        {
            sp >> x;
            sp >> y;
            sp >> z;
            fiber_pos.push_back(Vec3D<int>(x, y, z));
        }
        sp.close();

        rp.open(real_paths[i], fstream::in);
        pp.open("target/points.csv", fstream::in);
        vector<Vec3D<double>> points;
        for (int i = 0; i < 20; i++)
        {
            rp >> z;
            for (int j = 0; j < 4; j++)
            {
                pp >> x;
                pp >> y;
                points.push_back(Vec3D<double>(x, y, z));
            }
        }
        pp.close();
        rp.close();
        double err = error(fiber_pos, points);
        rp.open(real_paths[i] + ".res", fstream::out);
        rp << err;
        rp.close();
    }
    return 0;
}