#version 310 es
/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 *    (C) COPYRIGHT 2016 ARM Limited
 *        ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */
precision highp float;

in vec3 position;
out vec3 v_position;

uniform samplerCube heightmap;
uniform float height_scale;

void main()
{
    // The vertex shader takes as input 6 planes aligned to
    // a cube, and produces the coarse displaced spherical mesh
    // We do this by normalizing the position on the cube,
    // to produce a sphere, and displace by sampling the
    // displacement cubemap.
    v_position = normalize(position);
    v_position *= 1.0 + texture(heightmap, v_position).r * height_scale;
}
