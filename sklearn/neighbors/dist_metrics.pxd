#!python
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
cimport numpy as np
from libc.math cimport fmax, fmin, fabs, sqrt, exp, cos, pow

from typedefs cimport DTYPE_t, ITYPE_t, DITYPE_t
from typedefs import DTYPE, ITYPE

######################################################################
# Inline distance functions
#
#  We use these for the default (euclidean) case so that they can be
#  inlined.  This leads to faster computation for the most common case
cdef inline DTYPE_t euclidean_dist(DTYPE_t* x1, DTYPE_t* x2,
                                   ITYPE_t size) except -1:
    cdef DTYPE_t tmp, d=0
    for j in range(size):
        tmp = x1[j] - x2[j]
        d += tmp * tmp
    return sqrt(d)

cdef inline DTYPE_t euclidean_rdist(DTYPE_t* x1, DTYPE_t* x2,
                                    ITYPE_t size) except -1:
    cdef DTYPE_t tmp, d=0
    for j in range(size):
        tmp = x1[j] - x2[j]
        d += tmp * tmp
    return d

cdef inline DTYPE_t euclidean_dist_to_rdist(DTYPE_t dist) except -1:
    return dist * dist

cdef inline DTYPE_t euclidean_rdist_to_dist(DTYPE_t dist) except -1:
    return sqrt(dist)

cdef int euclidean_cdist(DTYPE_t[:, ::1] X, DTYPE_t[:, ::1] Y,
                         DTYPE_t[:, ::1] D) except -1

######################################################################
# DistanceMetric base class
cdef class DistanceMetric:
    # The following attributes are required for a few of the subclasses.
    # we must define them here so that cython's limited polymorphism will work.
    # Because we don't expect to instantiate a lot of these objects, the
    # extra memory overhead of this setup should not be an issue.
    cdef DTYPE_t p
    cdef DTYPE_t[::1] vec
    cdef DTYPE_t[:, ::1] mat
    cdef DTYPE_t* vec_ptr
    cdef DTYPE_t* mat_ptr
    cdef ITYPE_t size
    cdef object func
    cdef object kwargs

    cdef DTYPE_t dist(self, DTYPE_t* x1, DTYPE_t* x2, ITYPE_t size) except -1

    cdef DTYPE_t rdist(self, DTYPE_t* x1, DTYPE_t* x2, ITYPE_t size) except -1

    cdef int pdist(self, DTYPE_t[:, ::1] X, DTYPE_t[:, ::1] D) except -1

    cdef int cdist(self, DTYPE_t[:, ::1] X, DTYPE_t[:, ::1] Y,
                   DTYPE_t[:, ::1] D) except -1

    cdef DTYPE_t _rdist_to_dist(self, DTYPE_t rdist) except -1

    cdef DTYPE_t _dist_to_rdist(self, DTYPE_t dist) except -1