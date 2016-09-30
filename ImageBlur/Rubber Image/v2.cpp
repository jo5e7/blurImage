/*
 *  v2.cpp
 *  ScyllaLib
 *
 *  Created by Dale Thomas on 06/05/11.
 *  Copyright 2011 Scylla Games. All rights reserved.
 *  www.scylla-games.com
 *  scyllagames@gmail.com
 *
 */

#include "v2.h"
#include <stdio.h>

#define V2_EPSILON 0.000001f

/*** constructors ***/
v2::v2() { f[0] = 0.f; f[1] = 0.f; }
v2::v2(const float _Value0, const float _Value1) { f[0] = _Value0; f[1] = _Value1; }
const v2 v2::zero(0,0);
const v2 v2::one(1,1);

/*** accessors ***/
const v2 v2::operator =(const v2& _Value) { f[0] = _Value[0]; f[1] = _Value[1]; return *this; }

/*** unary operation ***/
v2 v2::operator-() const { return v2(-f[0],-f[1]); }

/*** scalar operations ***/
void v2::operator+=(const float _Value) { f[0] += _Value; f[1] += _Value; }
void v2::operator-=(const float _Value) { f[0] -= _Value; f[1] -= _Value; }
void v2::operator*=(const float _Value) { f[0] *= _Value; f[1] *= _Value; }
void v2::operator/=(const float _Value) { f[0] /= _Value; f[1] /= _Value; }

v2 v2::operator+(const float _Value) const { return v2( f[0]+_Value, f[1]+_Value ); }
v2 v2::operator-(const float _Value) const { return v2( f[0]-_Value, f[1]-_Value ); }
v2 v2::operator*(const float _Value) const { return v2( f[0]*_Value, f[1]*_Value ); }
v2 v2::operator/(const float _Value) const { return v2( f[0]/_Value, f[1]/_Value ); }

/*** vector operations ***/
void v2::operator+=(const v2& _Value) { f[0] += _Value[0]; f[1] += _Value[1]; }
void v2::operator-=(const v2& _Value) { f[0] -= _Value[0]; f[1] -= _Value[1]; }
void v2::operator*=(const v2& _Value) { f[0] *= _Value[0]; f[1] *= _Value[1]; }
void v2::operator/=(const v2& _Value) { f[0] /= _Value[0]; f[1] /= _Value[1]; }

v2 v2::operator+(const v2& _Value) const { return v2( f[0]+_Value[0], f[1]+_Value[1] ); }
v2 v2::operator-(const v2& _Value) const { return v2( f[0]-_Value[0], f[1]-_Value[1] ); }
v2 v2::operator*(const v2& _Value) const { return v2( f[0]*_Value[0], f[1]*_Value[1] ); }
v2 v2::operator/(const v2& _Value) const { return v2( f[0]/_Value[0], f[1]/_Value[1] ); }

float v2::len2() const { return f[0]*f[0] + f[1]*f[1]; }
float v2::len() const { float l2=len2(); return (l2>V2_EPSILON)?sqrtf(l2):0.f;  }

v2 v2::unit() const { float l=len(); return (l>V2_EPSILON)?*this/l:v2::zero; }
float v2::normalise() { float l=len(); if(l>V2_EPSILON) *this/=l; else *this=v2::zero; return l; }

v2 v2::canonicalise()
{
#define UNITY (1.0 - 1.0e-6)
	if     ( f[0] >=  UNITY ) return v2( 1,0);
	else if( f[0] <= -UNITY ) return v2(-1,0);
	else if( f[1] >=  UNITY ) return v2(0, 1);
	else if( f[1] <= -UNITY ) return v2(0,-1);
	else return v2::zero;
#undef UNITY
}
v2 v2::round() const { return v2(floor(f[0]),floor(f[1])); }
v2 v2::recip() const { return v2(1.f/f[0],1.f/f[1]); }
v2 v2::rot90() const { return v2(-f[1],f[0]); }
v2 v2::rot270() const { return v2(f[1],-f[0]); }
void v2::clamp(const v2& _Min,const v2& _Max)
{
	if(f[0]<_Min[0]) f[0]=_Min[0];
	if(f[0]>_Max[0]) f[0]=_Max[0];
	if(f[1]<_Min[1]) f[1]=_Min[1];
	if(f[1]>_Max[1]) f[1]=_Max[1];
}

void v2::print(const std::string _String) const { printf( "%s %.3f %.3f\n", _String.c_str(), f[0], f[1] ); }
void v2::print(const std::string _String)       { printf( "%s %.3f %.3f\n", _String.c_str(), f[0], f[1] ); }

#undef V2_EPSILON
