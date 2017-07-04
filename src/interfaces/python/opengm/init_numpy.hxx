#ifndef OPENGM_INIT_NUMPY_HXX
#define OPENGM_INIT_NUMPY_HXX

#include <Python.h>

// import_array() is a macro whose return type changed in python 3
// https://mail.scipy.org/pipermail/numpy-discussion/2010-December/054350.html
#if PY_MAJOR_VERSION >= 3

int init_numpy();

#else

void init_numpy();

#endif

#endif // OPENGM_INIT_NUMPY_HXX
