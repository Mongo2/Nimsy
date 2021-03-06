import Nimsytypes
# import ../../opengl/src/opengl/glut
# import ../../opengl/src/opengl
# import ../../opengl/src/opengl/glu
import glm
import math

import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

import NShader

#[ Constants ]#
const
  TESS_RES*: int = 64
  TWO_PI*: float = PI*2.0
  HALF_PI*: float = PI/2.0
  QUARTER_PI*: float = PI/4.0

#[ Opengl specific ]#
var
  #General opengl vars
  mWidth*: int
  mHeight*: int

  #Inputs
  mMouseX*: int
  mMouseY*: int

  #Drawing
  jointType*: EJoint = EJoint.MITER
  capType*: ECap = ECap.BUTT
  lineWidth*: float = 1.0                    ##Weight of stroke

  mainWindowID*: int

  #Main loop related
  FPS*: float = 30.0
  msInFrame*: float = 1000.0 / FPS
  isLoop*: bool

  #Rendering variables.
  isFill*: bool = true
  isStroke*: bool = true
  colorStroke*: array[4, float] = [0.0, 0.0, 0.0, 1.0]
  colorFill*: array[4, float] = [1.0, 1.0, 1.0, 1.0]

  #Shader matrices.
  modelView*: Mat4x4[float32]
  projection*: Mat4x4[float32]
  pushedModelView*: Mat4x4[float32]
  pushedProjection*: Mat4x4[float32]
  isMatPushed* = false

#Shader vars
var
  activeShader*: Shader

  #[ Locations ]#
  vertexMiterLocation*: GLint
  modelViewLocation*: GLint
  projectionLocation*: GLint
  fragmentStrokeColorLocation*: GLint
  fragmentFillColorLocation*: GLint
  vertexWidthLocation*: GLint
  vertexNormalLocation*: GLint
  vertexPositionLocation*: GLint
  drawingModeLocation*: GLint
