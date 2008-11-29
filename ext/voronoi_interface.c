#include <ruby.h>
#include <voronoi/vdefs.h>
#include <stdio.h>
#include <stdlib.h>

static VALUE rb_mRubyVor;
static VALUE rb_mVDDT;
static VALUE rb_cDecomposition;

Site * sites;

static VALUE
from_points(VALUE self, VALUE pointsArray)
{
    //VALUE returnValue;
    VALUE * inPtr;
    ID x, y;
    long i, inSize, xsum, ysum;

    xsum = 0;
    ysum = 0;
    
    x = rb_intern("x");
    y = rb_intern("y");
    
    inSize = RARRAY(pointsArray)->len;
    inPtr  = RARRAY(pointsArray)->ptr;

    // Require x & y methods
    if (inSize < 1 || !rb_respond_to(inPtr[0], x) || !rb_respond_to(inPtr[0], y))
        rb_raise(rb_eRuntimeError, "target must respond to 'x' and 'y' and have a nonzero length");

    // Iterate over the arrays, doubling the incoming values.
    for (i=0; i<inSize; i++)
    {
        xsum += FIX2INT(rb_funcall(inPtr[i], x, 0));
        ysum += FIX2INT(rb_funcall(inPtr[i], y, 0));
    }
    print_memory();
    
    return LONG2FIX(xsum - ysum);
}

void
Init_voronoi_interface(void)
{
    // Set up our Modules and Class.
    rb_mRubyVor       = rb_define_module("RubyVor");
    rb_mVDDT          = rb_define_module_under(rb_mRubyVor, "VDDT");
    rb_cDecomposition = rb_define_class_under(rb_mVDDT, "Decomposition", rb_cObject);

    // Add methods.
    rb_define_singleton_method(rb_cDecomposition, "from_points", from_points, 1);
}
