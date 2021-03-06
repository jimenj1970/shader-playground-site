#version 310 es

/*
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from Arm Limited.
 *    Copyright 2016-2020 Arm Ltd. All Rights Reserved.
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from Arm Limited.
 */

#extension GL_EXT_tessellation_shader : require
precision highp float;

layout(vertices = 4) out;
in vec3 v_position[];
out vec3 tc_position[];
patch out float tc_detail_level;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec2 screen_size;
uniform float max_lod_coverage;

#define ID gl_InvocationID
#define MAX_TESS_LEVEL 32.0

vec4 Project(vec3 v)
{
    vec4 result = projection * view * model * vec4(v, 1.0);
    result /= result.w;
    return result;
}

// We cull patches if all the vertices are offscreen.
// A vertex is offscreen if its screen-space projection is
// outside of the normalized device coordinates.
bool Offscreen(vec4 v)
{
    // Depending on the displacement, some patches that
    // are offscreen initially may have displaced vertices
    // inside the screen-space. The bias is hand-tuned to
    // compensate for this.
    const float BIAS = 0.5;

    if (v.x < -1.0 - BIAS ||
        v.x > +1.0 + BIAS ||
        v.y < -1.0 - BIAS ||
        v.y > +1.0 + BIAS)
    {
        return true;
    }
    return false;
}

// We also cull patches if they are backfacing. That is,
// all its normals (which in our case is simply the position
// normalized) are facing away from the camera. In screen-
// space, this reduces to checking if the z-component is
// negative.
bool Backfacing(vec4 v)
{
    // However, backfacing patches may still contribute
    // if its vertices are displaced far enough, so we
    // compensate with a bias for that too.
    const float BIAS = -0.3;
    return v.z < BIAS;
}

// We determine the tessellation factor (level of detail)
// by comparing the pixel-space distance of an edge to a
// threshold value. If the edge's distance is equal to
// the threshold, it is maximally tessellated. The threshold
// in this case is given by the max_lod_coverage uniform.
float Level(float dist)
{
    return mix(1.0, MAX_TESS_LEVEL, clamp(dist / max_lod_coverage, 0.0, 1.0));
}

void main()
{
    tc_position[ID] = v_position[ID];

    // Project patch corners to normalized-device coordinates
    vec4 ss0 = Project(v_position[0]);
    vec4 ss1 = Project(v_position[1]);
    vec4 ss2 = Project(v_position[2]);
    vec4 ss3 = Project(v_position[3]);

    // Compute view-space sphere normals, to determine
    // if a patch is backfacing and thus can be culled.
    vec4 vs0 = view * model * vec4(v_position[0], 0.0);
    vec4 vs1 = view * model * vec4(v_position[1], 0.0);
    vec4 vs2 = view * model * vec4(v_position[2], 0.0);
    vec4 vs3 = view * model * vec4(v_position[3], 0.0);

    if (ID == 0)
    {
        bool allOffscreen =
            all(bvec4(Offscreen(ss0),
                      Offscreen(ss1),
                      Offscreen(ss2),
                      Offscreen(ss3)));
        bool allBackfacing =
            all(bvec4(Backfacing(vs0),
                      Backfacing(vs1),
                      Backfacing(vs2),
                      Backfacing(vs3)));

        if (allOffscreen || allBackfacing)
        {
            gl_TessLevelInner[0] = 0.0;
            gl_TessLevelInner[1] = 0.0;
            gl_TessLevelOuter[0] = 0.0;
            gl_TessLevelOuter[1] = 0.0;
            gl_TessLevelOuter[2] = 0.0;
            gl_TessLevelOuter[3] = 0.0;

            tc_detail_level = 0.0;
        }
        else
        {
            // To pixel space
            ss0.xy = screen_size * (ss0.xy * 0.5 + vec2(0.5));
            ss1.xy = screen_size * (ss1.xy * 0.5 + vec2(0.5));
            ss2.xy = screen_size * (ss2.xy * 0.5 + vec2(0.5));
            ss3.xy = screen_size * (ss3.xy * 0.5 + vec2(0.5));

            //   0       d0        3
            //    +-------x-------+
            //    |               |       a: Inner[1]
            //    |   +---a---+   |       b: Inner[0]
            //    |   |       |   |       x: Outer[0]
            // d1 y   b       b   w d3    y: Outer[1]
            //    |   |       |   |       z: Outer[2]
            //    |   +---a---+   |       w: Outer[3]
            //    |               |
            //    +-------z-------+
            //   1       d2        2
            //
            // Next we compute the lengths of the patch edges
            // in pixel space. Refer to the diagram above for
            // the relation between which edge length corresponds
            // to what tessellation level.
            float d0 = length(ss0.xy - ss3.xy);
            float d1 = length(ss1.xy - ss0.xy);
            float d2 = length(ss2.xy - ss1.xy);
            float d3 = length(ss3.xy - ss2.xy);

            float level0 = Level(d0);
            float level1 = Level(d1);
            float level2 = Level(d2);
            float level3 = Level(d3);

            // The inner tessellation levels are computed as
            // the average between the associated outer levels.
            // See the diagram above.
            gl_TessLevelInner[0] = mix(level1, level3, 0.5);
            gl_TessLevelInner[1] = mix(level0, level2, 0.5);
            gl_TessLevelOuter[0] = level0;
            gl_TessLevelOuter[1] = level1;
            gl_TessLevelOuter[2] = level2;
            gl_TessLevelOuter[3] = level3;

            tc_detail_level = max(max(max(level0, level1), level2), level3) / MAX_TESS_LEVEL;
        }
    }
}
