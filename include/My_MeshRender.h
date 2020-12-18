#ifndef VX_MESH_H
#define VX_MESH_H

#include "Voxelyze.h"
#include <vector>

class My_MeshRender
{
  public:
    My_MeshRender(CVoxelyze *voxelyzeInstance);

    void generateMesh();
    void saveMesh(int n);

  private:
    CVoxelyze *vx;

    std::vector<float> vertices;
    std::vector<float> colors;
    std::vector<int> triangles;
};
#endif