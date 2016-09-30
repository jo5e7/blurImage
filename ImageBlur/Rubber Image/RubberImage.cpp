/*
 *  RubberImage.cpp
 *  RubberImage
 *
 *  Created by Dale Thomas on 10/10/11.
 *  Copyright 2011 Scylla Games. All rights reserved.
 *  www.scylla-games.com
 *  scyllagames@gmail.com
 *
 */

#include "RubberImage.h"


void RubberImage::init(const int _NumX,const int _NumY,const v2& _Size)
{
    /* because textures have to be a power of 2, a full screen image 
     * is embedded in the upper left corner of a 1024x1024 texture */
    const v2 PORTRAIT_IMAGE_IN_1024x1024_TEXTURE_HACK = IMAGE_SIZE/v2(1024,1024);
    
    // *** store resolution of grid ***
    _num_points_x = _NumX;
    _num_points_y = _NumY;
    
    // *** create and initialise grid of vertices ***
    _vertices.clear(); // not neccessary, but feels clean
    _vertices.resize(_num_points_x*_num_points_y);
    for(int i=0,y=0; y<_num_points_y; ++y)
    {        
        float fy = float(y)/(_num_points_y-1); // fy range [0..1]
        for(int x=0; x<_num_points_x; ++x,++i)
        {
            float fx = float(x)/(_num_points_x-1); // fx range [0..1]
            _vertices[i]._rest_pos = v2(fx,fy)*SCREEN_SIZE; // rest position
            _vertices[i]._pos = _vertices[i]._rest_pos; // vertex starts at rest
            _vertices[i]._vel = v2::zero; // vertex stationary at start
            _vertices[i]._uv = v2(fx,fy)*PORTRAIT_IMAGE_IN_1024x1024_TEXTURE_HACK; // texture coordinates of vertex
        }
    }

    // *** create and initialise index array ***
    _index_array.clear();
    for(int i=0,y=0; y<_num_points_y-1; ++y)
    {        
        for(int x=0; x<_num_points_x; ++x,++i)
        {
            _index_array.push_back(i); // top of strip
            _index_array.push_back(i+_num_points_x); // bottom of strip
        }
        // *** make degenerate triangles to start next strip ***
        _index_array.push_back(_index_array.back());
        _index_array.push_back(i);
    }
}


/***********************************************************************************************
 * this function smears the points by applying a force in the direction of swipe with a smooth *
 * cosine falloff.                                                                             *
 * create more functions like this to implement various brushes, such as swirl, pinch or bulge *
 ***********************************************************************************************/ 
void RubberImage::applySmudgeForce(const float _DeltaTime,const v2& _Pos,const v2& _Vel,const float _Radius)
{
    // *** apply a force within radius of touch with smooth falloff ***
    for(unsigned int i=0; i<_vertices.size(); ++i)
    {
        v2 to_force = _Pos-_vertices[i]._pos;
        const float distance = to_force.normalise();
        if( distance<_Radius )
        {
            const float magnitude = (cosf(PI*(distance/_Radius))+1.f)*0.5; // cosine falloff            
            _vertices[i]._vel += _Vel*(magnitude*_DeltaTime);
        }
    }
}

void RubberImage::update(const float _DeltaTime)
{ 
    // *** update physics of grid ***
    const float elasticity = _elasticity*_DeltaTime;
    const float damping = _damping*_DeltaTime;
    for(unsigned int i=0; i<_vertices.size(); ++i)
    {
        _vertices[i]._vel += (_vertices[i]._rest_pos-_vertices[i]._pos)*elasticity; // elasticity
        _vertices[i]._vel -= _vertices[i]._vel*damping; // damping velocity
        _vertices[i]._pos += _vertices[i]._vel*_DeltaTime; // 1st order euler integration
    }
    
    // *** make sure edge points don't come into screen ***
    {
        for(int x=0; x<_num_points_x; ++x)
        {
            int index1 = x;
            if( _vertices[index1]._pos[1]>_vertices[index1]._rest_pos[1] ) 
            { 
                _vertices[index1]._pos[1] = _vertices[index1]._rest_pos[1];
                _vertices[index1]._vel[1] = 0.f;
            }
            int index2 = _num_points_x*_num_points_y-1-x;
            if( _vertices[index2]._pos[1]<_vertices[index2]._rest_pos[1] ) 
            { 
                _vertices[index2]._pos[1] = _vertices[index2]._rest_pos[1];
                _vertices[index2]._vel[1] = 0.f;
            }        
        }
        for(int y=0; y<_num_points_y; ++y)
        {
            int index1 = y*_num_points_x;
            if( _vertices[index1]._pos[0]>_vertices[index1]._rest_pos[0] ) 
            { 
                _vertices[index1]._pos[0] = _vertices[index1]._rest_pos[0];
                _vertices[index1]._vel[0] = 0.f;
            }
            int index2 = _num_points_x*_num_points_y-1-y*_num_points_x;
            if( _vertices[index2]._pos[0]<_vertices[index2]._rest_pos[0] ) 
            { 
                _vertices[index2]._pos[0] = _vertices[index2]._rest_pos[0];
                _vertices[index2]._vel[0] = 0.f;
            }     
        }
    }
}

void RubberImage::draw()
{
    if( _index_array.empty() ) return; // nothing to draw. is it an error?
    
    // *** bind the texture and make sure we are using textures
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D,_texture_handle);
    
    // *** enable vertex and texture coordinates using interleaved array ***
    glEnableClientState( GL_VERTEX_ARRAY );
    glVertexPointer( 2, GL_FLOAT, sizeof(ElasticVertex), &(_vertices[0]._pos[0]) );
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer( 2, GL_FLOAT, sizeof(ElasticVertex), &(_vertices[0]._uv[0]) );
    
    // *** draw mesh using index array ***
    glDrawElements( GL_TRIANGLE_STRIP, _index_array.size(), GL_UNSIGNED_SHORT, (GLvoid*)&(_index_array[0]) );
    
    // *** disable states to be nice and clean ***
    glDisableClientState( GL_VERTEX_ARRAY );
    glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}
