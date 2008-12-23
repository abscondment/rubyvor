#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor_c.h>
#include <math.h>

/*
 * Euclidean distance between two Points
 */
VALUE
RubyVor_distance_from(VALUE self, VALUE other)
{
    return rb_float_new(sqrt(pow(NUM2DBL(rb_iv_get(self, "@x")) - NUM2DBL(rb_iv_get(other, "@x")), 2.0) +
                             pow(NUM2DBL(rb_iv_get(self, "@y")) - NUM2DBL(rb_iv_get(other, "@y")), 2.0)));
}

VALUE
RubyVor_point_hash(VALUE self)
{
    double x, y;
    char *c;
    long i, xHash, yHash;

    x = NUM2DBL(rb_iv_get(self, "@x"));
    y = NUM2DBL(rb_iv_get(self, "@y"));

    /* Bastardized from Ruby's numeric.c */
    
    for (c = (char*)&x, xHash = 0, i = 0; i < sizeof(double); i++) xHash += c[i] * 971;
    for (c = (char*)&y, yHash = 0, i = 0; i < sizeof(double); i++) yHash += c[i] * 971;

    xHash = xHash & RB_HASH_FILTER;
    yHash = yHash & RB_HASH_FILTER;
    
    return LONG2FIX((xHash << (RB_LONG_BITS / 2)) | yHash);
}
