attribute vec2 a_pos;
attribute vec2 a_normal;

uniform float u_linewidth;
uniform float u_linelen;
uniform mat4 u_mv_matrix;
uniform mat4 u_p_matrix;

attribute float e_i_drawing_mode;
varying float e_o_drawing_mode;

void main() {
  vec4 pos = u_mv_matrix * vec4(a_pos, 0, 1);
  gl_Position = u_p_matrix * pos;
  e_o_drawing_mode = e_i_drawing_mode;
}
