/*
 *  RubberImage.h
 *  RubberImage
 *
 *  Created by Dale Thomas on 10/10/11.
 *  Copyright 2011 Scylla Games. All rights reserved.
 *  www.scylla-games.com
 *  scyllagames@gmail.com
 *
 */

#ifndef __RubberImage_H__
#define __RubberImage_H__

#include "Include.h"
#include "v2.h"


/****************************************************************************************
 * This class holds the grid of elastic points and the mesh.                            *
 * It is responsible for creating, initialising, updating and drawing the textured mesh.*
 * The elasticity is simulated by providing a spring force from position towards rest   *
 * position. Think of it like each particle is connected to its rest position by a      *
 * spring of length 0. There are no forces between adjacent points.                     *
 ****************************************************************************************/
class RubberImage
{
public:
    
    // *** API ***
    void setTextureHandle(const GLuint _TextureHandle) { _texture_handle = _TextureHandle; }
    void setElasticity(const float _Elasticity) { _elasticity = _Elasticity; }
    void setDamping(const float _Damping) { _damping = _Damping; }
    void init(const int _NumX,const int _NumY,const v2& _Size); // set up the initial grid, create and initialise all points and index array
    void applySmudgeForce(const float _DeltaTime,const v2& _Pos,const v2& _Vel,const float _Radius);
    void update(const float _DeltaTime); // perform elastic physics on the grid
    void draw(); // draw the grid
 
    /****************************************************************************************
     * This struct holds data for 1 point of the grid                                       *
     * Each point has a position, a velocity, a rest position and uv coordinates.           *
     * Note: texture must be a power of 2. Here I use the upper left of a 1024x1024 texture *
     ****************************************************************************************/
    struct ElasticVertex
    {
        v2 _pos;
        v2 _vel;
        v2 _rest_pos;
        v2 _uv;
    };
    
    GLuint _texture_handle;
    int _num_points_x;
    int _num_points_y;
    float _elasticity;
    float _damping;
    std::vector<ElasticVertex> _vertices; // 2d array of elastic vertices stored in a 1D array
    std::vector<GLushort> _index_array; // indices into the vertex array to optimise drawing of the grid

};






#endif // #ifndef __RubberImage_H__
