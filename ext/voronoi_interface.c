#include <ruby.h>
#include <voronoi/vdefs.h>
#include <stdio.h>
#include <stdlib.h>

static VALUE rb_mRubyVor;
static VALUE rb_mVDDT;
static VALUE rb_cDecomposition;


static VALUE
do_something(VALUE self)
{
    char * x;
    x = "Hello, World!";
    return rb_str_new(x, strlen(x));
}

void
Init_voronoi_interface(void)
{
    rb_mRubyVor       = rb_define_module("RubyVor");
    rb_mVDDT          = rb_define_module_under(rb_mRubyVor, "VDDT");
    rb_cDecomposition = rb_define_class_under(rb_mVDDT, "Decomposition", rb_cObject);

    rb_define_method(rb_cDecomposition, "do_something", do_something, 0);
}
