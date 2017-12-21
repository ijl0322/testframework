#version 100
precision mediump float;

varying vec2 vUV;
uniform sampler2D imageTexture;

void main() {
  mediump vec3 rgb = texture2D(imageTexture, vUV).rgb;

  gl_FragColor = vec4(rgb.rgb, 1);
}
