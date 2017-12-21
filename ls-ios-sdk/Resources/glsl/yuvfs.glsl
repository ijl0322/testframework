#version 100
precision mediump float;

varying vec2 vUV;
uniform sampler2D lumaTexture;
uniform sampler2D chromaTexture;

void main() {
  mediump vec3 yuv;
  lowp vec3 rgb;

  yuv.x = texture2D(lumaTexture, vUV).r;
  yuv.yz = texture2D(chromaTexture, vUV).rg - vec2(0.5, 0.5);

  // Using BT.709 which is the standard for HDTV
  rgb = mat3(      1,       1,      1,
                   0, -.18732, 1.8556,
             1.57481, -.46813,      0) * yuv;

  gl_FragColor = vec4(rgb, 1);
}

