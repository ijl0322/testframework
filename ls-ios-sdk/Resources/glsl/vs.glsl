#version 100
attribute vec3 position;

attribute vec2 UV;
varying vec2 vUV;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

uniform int stereoMode; // 0=ou; 1=sbs

void main(){
  if (0 == stereoMode) {
    vUV = UV;
  } else {
    vUV = vec2(UV.x * 0.5, UV.y * 0.5);
  }

  gl_Position = projectionMatrix
              * viewMatrix
              * modelMatrix
              * vec4(position, 1.0);
}
