/*
 *  v2.h
 *  ScyllaLib
 *
 *  Created by Dale Thomas on 06/05/11.
 *  Copyright 2011 Scylla Games. All rights reserved.
 *  www.scylla-games.com
 *  scyllagames@gmail.com
 *
 */

#ifndef __SCYLLALIB_V2_H__
#define __SCYLLALIB_V2_H__

#include <math.h>
#include <string>

/*******************************************************
 * A useful 2D vector class with overloaded operators. *
 *******************************************************/

class v2
{
public:

	/*** constructors ***/
	v2();
	v2(const float _Value0, const float _Value1);
	static const v2 zero;
	static const v2 one;

	/*** accessors ***/
	const v2 operator =(const v2& _Value);
	const float& x() const { return f[0]; }
	      float& x()       { return f[0]; }
	const float& y() const { return f[1]; }
	      float& y()       { return f[1]; }
	const float& operator[](const int _Index) const { return f[_Index]; }
	      float& operator[](const int _Index)       { return f[_Index]; }
	const float* ptr() const { return &f[0]; }
	      float* ptr()       { return &f[0]; }

	/*** unary operation ***/
	v2 operator-() const;

	/*** scalar operations ***/
	void operator+=(const float _Value);
	void operator-=(const float _Value);
	void operator*=(const float _Value);
	void operator/=(const float _Value);

	v2 operator+(const float _Value) const;
	v2 operator-(const float _Value) const;
	v2 operator*(const float _Value) const;
	v2 operator/(const float _Value) const;

	/*** vector operations ***/
	void operator+=(const v2& _Value);
	void operator-=(const v2& _Value);
	void operator*=(const v2& _Value);
	void operator/=(const v2& _Value);

	v2 operator+(const v2& _Value) const;
	v2 operator-(const v2& _Value) const;
	v2 operator*(const v2& _Value) const;
	v2 operator/(const v2& _Value) const;

	float len() const;
	float len2() const;
	v2 unit() const;
	float normalise();
	v2 canonicalise();
	v2 round() const;
	v2 recip() const;
	v2 rot90() const;
	v2 rot270() const;
	void clamp(const v2& _Min,const v2& _Max);

//	static v2 min(const v2& _V1,const v2& _V2) { return v2(mymin(_V1[0],_V2[0]),mymin(_V1[1],_V2[1])); }
//	static v2 max(const v2& _V1,const v2& _V2) { return v2(mymax(_V1[0],_V2[0]),mymax(_V1[1],_V2[1])); }

	static float dot(const v2& _Value1,const v2& _Value2) { return _Value1[0]*_Value2[0] + _Value1[1]*_Value2[1]; }
	static float cross(const v2& _Value1,const v2& _Value2) { return _Value1[1]*_Value2[0] - _Value1[0]*_Value2[1]; }
	void print(const std::string _String="") const;
	void print(const std::string _String="");

private:
    
	float f[2];
    
};


#endif // #ifndef __SCYLLALIB_V2_H__
