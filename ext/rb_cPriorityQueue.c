#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor_c.h>

/*
 * Instance methods for RubyVor::VDDT::PriorityQueue
 */


static VALUE
compare(VALUE a, VALUE b)
{
    double aD, bD;
    ID minDistance;
    minDistance = ID2SYM(rb_intern("min_distance"));

    if (CLASS_OF(a) == rb_path2class("RubyVor::PriorityQueue::QueueItem"))
        aD = NUM2DBL(rb_funcall(a, rb_intern("priority"), 0));
    else
      rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)", rb_obj_classname(a), rb_obj_classname(rb_path2class("RubyVor::PriorityQueue::QueueItem")));

    if (CLASS_OF(a) == rb_path2class("RubyVor::PriorityQueue::QueueItem"))
        bD = NUM2DBL(rb_funcall(b, rb_intern("priority"), 0));
    else
      rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)", rb_obj_classname(a), rb_obj_classname(rb_path2class("RubyVor::PriorityQueue::QueueItem")));

    return RTEST(aD < bD);
}

VALUE
RubyVor_percolate_up(VALUE self, VALUE index)
{
    VALUE item, data;
    long i, j, size;

    Check_Type(index, T_FIXNUM);
    
    data = rb_iv_get(self, "@data");
    Check_Type(data, T_ARRAY);
    
    size = FIX2INT(rb_iv_get(self, "@size"));
    i = FIX2INT(index) + 1;

    if (i < 1 || i > size)
        rb_raise(rb_eIndexError, "index %li out of range", i-1);
    
    j = i / 2;
    
    item = RARRAY_PTR(data)[i - 1];

    while(j > 0 && compare(item, RARRAY_PTR(data)[j - 1]))
    {
        rb_ary_store(data, i-1, RARRAY_PTR(data)[j - 1]);
        rb_funcall(RARRAY_PTR(data)[i-1], rb_intern("index="), 1, INT2FIX(i-1));
        i = j;
        j = j / 2;
    }

    rb_ary_store(data, i-1, item);
    rb_funcall(RARRAY_PTR(data)[i-1], rb_intern("index="), 1, INT2FIX(i-1));
    
    return Qnil;
}


VALUE
RubyVor_percolate_down(VALUE self, VALUE index)
{
    VALUE item, data;
    long i, j, k, size;

    Check_Type(index, T_FIXNUM);

    data = rb_iv_get(self, "@data");
    Check_Type(data, T_ARRAY);
    
    size = FIX2INT(rb_iv_get(self, "@size"));
    i = FIX2INT(index) + 1;
    
    if (i < 1 || i > size)
        rb_raise(rb_eIndexError, "index %li out of range", i-1);
    
    j = size / 2;

    item = RARRAY_PTR(data)[i - 1];

    while (!(i > j))
    {
        k = i * 2;
        if (k < size && compare(RARRAY_PTR(data)[k], RARRAY_PTR(data)[k - 1]))
            k++;

        if (compare(item, RARRAY_PTR(data)[k - 1]))
            j = -1;
        else
        {
            rb_ary_store(data, i-1, RARRAY_PTR(data)[k - 1]);
            rb_funcall(RARRAY_PTR(data)[i-1], rb_intern("index="), 1, INT2FIX(i-1));
            i = k;
        }
    }

    rb_ary_store(data, i-1, item);
    rb_funcall(RARRAY_PTR(data)[i-1], rb_intern("index="), 1, INT2FIX(i-1));
    
    return Qnil;
}


VALUE
RubyVor_heapify(VALUE self)
{
    long i, size;
    size = FIX2INT(rb_iv_get(self, "@size"));

    for(i = size / 2; i >= 1; i--)
        RubyVor_percolate_down(self, INT2FIX(i-1));

    return Qnil;
}
