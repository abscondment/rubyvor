#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor.h>
#include <math.h>

/*
 * Euclidean distance between two Points
 */
VALUE
distance_from(VALUE self, VALUE other)
{
    return rb_float_new(sqrt(pow(NUM2DBL(rb_iv_get(self, "@x")) - NUM2DBL(rb_iv_get(other, "@x")), 2.0) +
                             pow(NUM2DBL(rb_iv_get(self, "@y")) - NUM2DBL(rb_iv_get(other, "@y")), 2.0)));
}
