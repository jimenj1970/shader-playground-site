#version 310 es
/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 *    (C) COPYRIGHT 2015 ARM Limited
 *        ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 */
// validator:PASS

#extension GL_EXT_tessellation_shader : require

layout(triangles, equal_spacing, cw) in;
void main()
{
    gl_Position = vec4(gl_TessCoord, 0);
}
