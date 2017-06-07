#[
  This module implements a vector object.
  TODO:Missing procedures:
    #[
      set()
      copy()
      lerp()
      array()
    ]#
  TODO: Math operators should produce new vector, while math procs should operate on the vector they get called upon
]#

import random
import math
from Nimsytypes import PVector

proc newPVector*(x, y, z: float): PVector =
  return PVector(x: 0, y: 0, z: 0)

proc newPVector*(value: float): PVector =
  return PVector(x: value, y: value, z: value)

proc random2D*(): PVector =
  return PVector(x: random(1.0), y: random(1.0), z: 0)

proc random3D*(): PVector =
  return PVector(x: random(1.0), y: random(1.0), z: random(1.0))

proc fromAngle*(angle: float): PVector =
  return PVector(x: cos(angle), y: sin(angle), z: 0)

proc magSq*(v: PVector): float =
  return v.x*v.x + v.y*v.y + v.z*v.z

proc mag*(v: PVector): float =
  return sqrt(v.magSq())

proc `+`(v1, v2: PVector): PVector =
  return PVector(x: v1.x+v2.x,
                  y: v1.y+v2.y,
                  z: v1.z+v2.z)

proc `-`(v1, v2: PVector): PVector =
  return PVector(x: v1.x-v2.x,
                  y: v1.y-v2.y,
                  z: v1.z-v2.z)

proc `*`(v1, v2: PVector): PVector =
  return PVector(x: v1.x*v2.x,
                  y: v1.y*v2.y,
                  z: v1.z*v2.z)

proc `/`(v1, v2: PVector): PVector =
  return PVector(x: v1.x/v2.x,
                  y: v1.y/v2.y,
                  z: v1.z/v2.z)

proc `*`(v1: PVector, s: float): PVector =
  return PVector(x: v1.x*s,
                  y: v1.y*s,
                  z: v1.z*s)

proc `/`(v1: PVector, s: float): PVector =
  return PVector(x: v1.x/s,
                  y: v1.y/s,
                  z: v1.z/s)

proc add*(v1, v2: PVector) =
  v1.x += v2.x
  v1.y += v2.y
  v1.z += v2.z

#TODO: implement more adding, subbing, multiplying and dividing procedures

proc sub*(v1, v2: PVector) =
  v1.x -= v2.x
  v1.y -= v2.y
  v1.z -= v2.z

proc mult*(v1, v2: PVector) =
  v1.x *= v2.x
  v1.y *= v2.y
  v1.z *= v2.z

proc mult*(v1: PVector, s: float) =
  v1.x *= s
  v1.y *= s
  v1.z *= s

#CONSIDERATION: div is a keyword in nim. Maybe have full names for every vector operation? (for consistency)
proc divide*(v1, v2: PVector) =
  v1.x /= v2.x
  v1.y /= v2.y
  v1.z /= v2.z

proc divide*(v1: PVector, s: float) =
  v1.x /= s
  v1.y /= s
  v1.z /= s

proc dist*(v1, v2: PVector): float =
  var
    x = v2.x-v1.x
    y = v2.y-v1.x
    z = v2.z-v1.z
  return sqrt(x*x + y*y + z*z)

proc dot*(v1, v2: PVector): float =
  #TODO: look into Kahan summation
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z

proc cross*(v1, v2: PVector): PVector =
  var
    tx = v1.y*v2.z + v1.z*v2.y
    ty = v1.x*v2.z + v1.z*v2.x
    tz = v1.x*v2.y + v1.y*v2.x
  return PVector(x: tx, y: ty, z: tz)

proc normalized*(v: PVector): PVector =
  var m: float = v.mag
  return PVector(x: v.x/m, y: v.y/m, z: v.z/m)

proc normalize*(v: PVector) =
  var m: float = v.mag
  v.x = v.x/m
  v.y = v.y/m
  v.z = v.z/m

proc limited*(v: PVector, max: float): PVector =
  var
    tx: float = v.x
    ty: float = v.y
    tz: float = v.z
  if tx > max:
    tx = max
  if ty > max:
    ty = max
  if tz > max:
    tz = max
  return PVector(x: tx, y: ty, z: tz)

proc setMag*(v: PVector, len: float): PVector =
  return v.normalized() * len

proc heading*(v: PVector): float =
  var
    tv: PVector = v.normalized()
    zv: PVector = newPVector(0.0)
    mapdot: float = (1.0 - (tv.dot(zv) + 1.0) * 0.5)

  return mapdot * 180.0

proc rotated*(v: PVector, angle: float): PVector =
  var
    cs: float = cos(angle)
    sn: float = sin(angle)
  return PVector(x: (v.x*cs - v.y*sn), y: (v.x*sn + v.y*cs), z: v.z)

proc rotate*(v: PVector, angle: float) =
  var
    cs: float = cos(angle)
    sn: float = sin(angle)
  v.x = (v.x*cs - v.y*sn)
  v.y = (v.x*sn + v.y*cs)
  v.z = v.z

proc angleBetween*(v1, v2: PVector): float =
  let
    tv1: PVector = v1.normalized()
    tv2: PVector = v2.normalized()
  var
    mapdot: float = (1.0 - (tv1.dot(tv2) + 1.0) * 0.5)

  return mapdot * 180.0

proc normal*(v1: PVector): PVector =
  var nv = v1
  nv.normalize()
  let tx = nv.x
  nv.x = nv.y
  nv.y = -tx
  return nv

proc normal*(v1, v2: PVector): PVector =
  var nv = v2 - v1
  nv.normalize()
  let tx = nv.x
  nv.x = nv.y
  nv.y = -tx
  return nv

proc tangent3*(v1, v2, v3: PVector): PVector =
  return ((v3-v2).normalized() + (v2-v1).normalized()).normalized()