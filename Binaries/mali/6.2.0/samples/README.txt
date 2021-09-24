How to compile the samples
--------------------------

Navigate to this samples folder from the command line and use following commands.
Note that they assume the malisc executable is on your path.


Linux or macOS
---------------

OpenGL ES SL

$ malisc openglessl/shader.vert
$ malisc openglessl/shader.frag
$ malisc openglessl/shader.comp
$ malisc openglessl/shader.geom
$ malisc openglessl/shader.tesc
$ malisc openglessl/shader.tese

OpenCL C

$ malisc opencl/program.cl --name convolve_sobel

Vulkan SPIR-V

$ malisc --vertex --spirv vulkan/vert.spv
$ malisc --fragment --spirv vulkan/frag.spv
$ malisc --compute --spirv vulkan/comp.spv
$ malisc --geometry --spirv vulkan/geom.spv
$ malisc --tessellation_control --spirv vulkan/tesc.spv
$ malisc --tessellation_evaluation --spirv vulkan/tese.spv
$ malisc --vertex --spirv -y foo vulkan/vert-entrypoint-foo.spv


Windows
-------

OpenGL ES SL

malisc.exe openglessl\shader.vert
malisc.exe openglessl\shader.frag
malisc.exe openglessl\shader.comp
malisc.exe openglessl\shader.geom
malisc.exe openglessl\shader.tesc
malisc.exe openglessl\shader.tese

Vulkan SPIR-V

malisc.exe --vertex --spirv vulkan\vert.spv
malisc.exe --fragment --spirv vulkan\frag.spv
malisc.exe --compute --spirv vulkan\comp.spv
malisc.exe --geometry --spirv vulkan\geom.spv
malisc.exe --tessellation_control --spirv vulkan\tesc.spv
malisc.exe --tessellation_evaluation --spirv vulkan\tese.spv
malisc.exe --vertex --spirv -y foo vulkan/vert-entrypoint-foo.spv


Notes
-----
The Mali Offline Compiler accepts Vulkan SPIR-V binary modules.
You can create a SPIR-V binary module from a shader written in ESSL using
glslang https://github.com/KhronosGroup/glslang

Note that shaders written using Vulkan-specific features cannot be compiled
as OpenGL ES SL shaders by the Mali Offline Compiler.
See https://www.khronos.org/registry/vulkan/specs/misc/GL_KHR_vulkan_glsl.txt
for more information about Vulkan-specific shaders semantics.

The SPIR-V binary samples have been created using
glslang (Glslang Version: Overload400-PrecQual.2000 12-Apr-2017).
This can be downloaded from https://github.com/KhronosGroup/glslang

The commands used to create the SPIR-V binaries are:

$ ./glslangValidator -V vert.vert
$ ./glslangValidator -V frag.frag
$ ./glslangValidator -V comp.comp
$ ./glslangValidator -V geom.geom
$ ./glslangValidator -V tesc.tesc
$ ./glslangValidator -V tese.tese
$ ./glslangValidator -V vert.vert --source-entrypoint main -e foo -o vert-entrypoint-foo.spv
