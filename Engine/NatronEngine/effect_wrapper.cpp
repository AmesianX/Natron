
//workaround to access protected functions
#define protected public

// default includes
#include <shiboken.h>
#include <typeresolver.h>
#include <typeinfo>
#include "natronengine_python.h"

#include "effect_wrapper.h"

// Extra includes



// Target ---------------------------------------------------------

extern "C" {
static PyMethodDef Sbk_Effect_methods[] = {

    {0} // Sentinel
};

} // extern "C"

static int Sbk_Effect_traverse(PyObject* self, visitproc visit, void* arg)
{
    return reinterpret_cast<PyTypeObject*>(&SbkObject_Type)->tp_traverse(self, visit, arg);
}
static int Sbk_Effect_clear(PyObject* self)
{
    return reinterpret_cast<PyTypeObject*>(&SbkObject_Type)->tp_clear(self);
}
// Class Definition -----------------------------------------------
extern "C" {
static SbkObjectType Sbk_Effect_Type = { { {
    PyVarObject_HEAD_INIT(&SbkObjectType_Type, 0)
    /*tp_name*/             "NatronEngine.Effect",
    /*tp_basicsize*/        sizeof(SbkObject),
    /*tp_itemsize*/         0,
    /*tp_dealloc*/          &SbkDeallocWrapper,
    /*tp_print*/            0,
    /*tp_getattr*/          0,
    /*tp_setattr*/          0,
    /*tp_compare*/          0,
    /*tp_repr*/             0,
    /*tp_as_number*/        0,
    /*tp_as_sequence*/      0,
    /*tp_as_mapping*/       0,
    /*tp_hash*/             0,
    /*tp_call*/             0,
    /*tp_str*/              0,
    /*tp_getattro*/         0,
    /*tp_setattro*/         0,
    /*tp_as_buffer*/        0,
    /*tp_flags*/            Py_TPFLAGS_DEFAULT|Py_TPFLAGS_CHECKTYPES|Py_TPFLAGS_HAVE_GC,
    /*tp_doc*/              0,
    /*tp_traverse*/         Sbk_Effect_traverse,
    /*tp_clear*/            Sbk_Effect_clear,
    /*tp_richcompare*/      0,
    /*tp_weaklistoffset*/   0,
    /*tp_iter*/             0,
    /*tp_iternext*/         0,
    /*tp_methods*/          Sbk_Effect_methods,
    /*tp_members*/          0,
    /*tp_getset*/           0,
    /*tp_base*/             reinterpret_cast<PyTypeObject*>(&SbkObject_Type),
    /*tp_dict*/             0,
    /*tp_descr_get*/        0,
    /*tp_descr_set*/        0,
    /*tp_dictoffset*/       0,
    /*tp_init*/             0,
    /*tp_alloc*/            0,
    /*tp_new*/              0,
    /*tp_free*/             0,
    /*tp_is_gc*/            0,
    /*tp_bases*/            0,
    /*tp_mro*/              0,
    /*tp_cache*/            0,
    /*tp_subclasses*/       0,
    /*tp_weaklist*/         0
}, },
    /*priv_data*/           0
};
} //extern


// Type conversion functions.

// Python to C++ pointer conversion - returns the C++ object of the Python wrapper (keeps object identity).
static void Effect_PythonToCpp_Effect_PTR(PyObject* pyIn, void* cppOut) {
    Shiboken::Conversions::pythonToCppPointer(&Sbk_Effect_Type, pyIn, cppOut);
}
static PythonToCppFunc is_Effect_PythonToCpp_Effect_PTR_Convertible(PyObject* pyIn) {
    if (pyIn == Py_None)
        return Shiboken::Conversions::nonePythonToCppNullPtr;
    if (PyObject_TypeCheck(pyIn, (PyTypeObject*)&Sbk_Effect_Type))
        return Effect_PythonToCpp_Effect_PTR;
    return 0;
}

// C++ to Python pointer conversion - tries to find the Python wrapper for the C++ object (keeps object identity).
static PyObject* Effect_PTR_CppToPython_Effect(const void* cppIn) {
    PyObject* pyOut = (PyObject*)Shiboken::BindingManager::instance().retrieveWrapper(cppIn);
    if (pyOut) {
        Py_INCREF(pyOut);
        return pyOut;
    }
    const char* typeName = typeid(*((::Effect*)cppIn)).name();
    return Shiboken::Object::newObject(&Sbk_Effect_Type, const_cast<void*>(cppIn), false, false, typeName);
}

void init_Effect(PyObject* module)
{
    SbkNatronEngineTypes[SBK_EFFECT_IDX] = reinterpret_cast<PyTypeObject*>(&Sbk_Effect_Type);

    if (!Shiboken::ObjectType::introduceWrapperType(module, "Effect", "Effect*",
        &Sbk_Effect_Type, &Shiboken::callCppDestructor< ::Effect >)) {
        return;
    }

    // Register Converter
    SbkConverter* converter = Shiboken::Conversions::createConverter(&Sbk_Effect_Type,
        Effect_PythonToCpp_Effect_PTR,
        is_Effect_PythonToCpp_Effect_PTR_Convertible,
        Effect_PTR_CppToPython_Effect);

    Shiboken::Conversions::registerConverterName(converter, "Effect");
    Shiboken::Conversions::registerConverterName(converter, "Effect*");
    Shiboken::Conversions::registerConverterName(converter, "Effect&");
    Shiboken::Conversions::registerConverterName(converter, typeid(::Effect).name());



}
