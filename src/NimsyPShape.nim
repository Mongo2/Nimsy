#[
  Module defining an object for custom shape drawing
]#

import Nimsygl
# import ../../opengl/src/opengl/glut
# import ../../opengl/src/opengl
# import ../../opengl/src/opengl/glu
import glm
import Nimsyprimitives
from Nimsytypes import PShape, PVector, DrawingModes
from NimsyPVector import normal, tangent3
import Nimsyglobals

import glfw
import glfw/wrapper
import ../../nim-glfw/src/glad/gl

proc newPShape*(): PShape =
  return PShape(vertices: newSeq[PVector](),
                vlen: 0,
                children: newSeq[PShape]())

proc beginShape*(s: PShape) =
  s.vertices = @[]
  s.vlen = 0

proc vertex*(s: PShape, x, y, z: float) =
  s.vertices.add(PVector(x: x, y: y, z: z))
  s.vlen += 1

proc vertex*(s: PShape, vec: PVector) =
  s.vertices.add(PVector(x: vec.x, y: vec.y, z: vec.z))
  s.vlen += 1

proc endShape*(s: PShape) =
  s.miters = newSeq[PVector]()
  s.normals = newSeq[PVector]()
  for n in 0..s.vertices.high-1:
    if n == 0:
      let tan = tangent3(s.vertices[s.vertices.high-1], s.vertices[n], s.vertices[n+1])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))
    elif n == s.vertices.high-1:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[0])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))
    else:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[n+1])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))

proc getVertex*(s: PShape, index: int): PVector =
  return s.vertices[index]

proc setVertex*(s: PShape, vertex: PVector, index: int) =
  s.vertices[index].x = vertex.x
  s.vertices[index].y = vertex.y
  s.vertices[index].z = vertex.z

  s.miters = newSeq[PVector]()
  s.normals = newSeq[PVector]()
  for n in 0..s.vertices.high-1:
    if n == 0:
      let tan = tangent3(s.vertices[s.vertices.high-1], s.vertices[n], s.vertices[n+1])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))
    elif n == s.vertices.high-1:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[0])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))
    else:
      let tan = tangent3(s.vertices[n-1], s.vertices[n], s.vertices[n+1])
      s.miters.add(normal(tan))
      s.normals.add(normal(s.vertices[n], s.vertices[n+1]))

proc getVertexCount*(s: PShape) : int =
  return s.vlen


proc shape*(s: PShape) =
  #FIXME: When drawing other stuff on the shape, the stencil test appears to be influenced.
  var
    pointer_modelView: ptr = modelView.caddr
    pointer_projection: ptr = projection.caddr

  glUniformMatrix4fv(modelViewLocation, GLsizei(1), GLboolean(false), pointer_modelView)
  glUniformMatrix4fv(projectionLocation, GLsizei(1), GLboolean(false), pointer_projection)

  if isFill:
    useFillColor()
    glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.POLYGON))
    glColorMask(false, false, false, false);
    glDepthMask(false);
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS,0x1,0x1);
    glStencilOp(GL_KEEP,GL_INVERT,GL_INVERT);

    #old gl
    glBegin(GL_TRIANGLE_FAN)
    for v in s.vertices:
     glVertex2f(v.x, v.y)
    glEnd()

    glDepthMask(true);
    glColorMask(true, true, true, true);
    glStencilFunc(GL_EQUAL,0x1,0x1);
    glStencilOp(GL_KEEP,GL_KEEP,GL_INVERT);
    glBegin(GL_TRIANGLE_FAN)
    for v in s.vertices:
      glVertex2f(v.x, v.y)
    glEnd()

    glDisable(GL_STENCIL_TEST);

  if isStroke:
    useStrokeColor()
    glVertexAttrib1f(GLuint(drawingModeLocation), GLfloat(DrawingModes.PATH))
    glBegin(GL_TRIANGLE_STRIP)
    for n in 0..s.vertices.high-1:
      glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(-s.miters[n].x), GLfloat(-s.miters[n].y))
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-s.normals[n].x), GLfloat(-s.normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
      glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(s.miters[n].x), GLfloat(s.miters[n].y))
      glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(s.normals[n].x), GLfloat(s.normals[n].y))
      glVertex2f(s.vertices[n].x, s.vertices[n].y)
    glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(-s.miters[0].x), GLfloat(-s.miters[0].y))
    glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(-s.normals[0].x), GLfloat(-s.normals[0].y))
    glVertex2f(s.vertices[0].x, s.vertices[0].y)
    glVertexAttrib2f(GLuint(vertexMiterLocation), GLfloat(s.miters[0].x), GLfloat(s.miters[0].y))
    glVertexAttrib2f(GLuint(vertexNormalLocation), GLfloat(s.normals[0].x), GLfloat(s.normals[0].y))
    glVertex2f(s.vertices[0].x, s.vertices[0].y)
    glEnd()
