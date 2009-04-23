#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor_c.h>

/* Classes & Modules */
static VALUE RubyVor_rb_mRubyVor;
static VALUE RubyVor_rb_mVDDT;

static VALUE RubyVor_rb_cComputation;
static VALUE RubyVor_rb_cPriorityQueue;
static VALUE RubyVor_rb_cQueueItem;
static VALUE RubyVor_rb_cPoint;

/*
 * Extension initialization
 */
void
Init_ruby_vor_c(void)
{
    /*
     * Set up our Modules and Class.
     */

    /*
     * Main RubyVor namespace.
     */
    RubyVor_rb_mRubyVor       = rb_define_module("RubyVor");

    
    /*
     * Voronoi Digram and Delaunay Triangulation namespace.
     */
    RubyVor_rb_mVDDT          = rb_define_module_under(RubyVor_rb_mRubyVor, "VDDT");

    
    /*
     * Class representing a VD/DT computation based on a set of 2-dimensional points
     */
    RubyVor_rb_cComputation   = rb_define_class_under(RubyVor_rb_mVDDT, "Computation", rb_cObject);
    rb_define_singleton_method(RubyVor_rb_cComputation, "from_points", RubyVor_from_points, 1);
    rb_define_method(RubyVor_rb_cComputation, "nn_graph", RubyVor_nn_graph, 0);
    rb_define_method(RubyVor_rb_cComputation, "minimum_spanning_tree", RubyVor_minimum_spanning_tree, -1);

    
    /*
     * A priority queue with a customizable heap-order property.
     */
    RubyVor_rb_cPriorityQueue = rb_define_class_under(RubyVor_rb_mRubyVor, "PriorityQueue", rb_cObject);
    RubyVor_rb_cQueueItem = rb_define_class_under(RubyVor_rb_cPriorityQueue, "QueueItem", rb_cObject);
    rb_define_method(RubyVor_rb_cPriorityQueue, "percolate_up", RubyVor_percolate_up, 1);
    rb_define_method(RubyVor_rb_cPriorityQueue, "percolate_down", RubyVor_percolate_down, 1);
    rb_define_method(RubyVor_rb_cPriorityQueue, "heapify", RubyVor_heapify, 0);


    /*
     * A simple Point class
     */
    RubyVor_rb_cPoint = rb_define_class_under(RubyVor_rb_mRubyVor, "Point", rb_cObject);
    rb_define_method(RubyVor_rb_cPoint, "distance_from", RubyVor_distance_from, 1);
    rb_define_method(RubyVor_rb_cPoint, "hash", RubyVor_point_hash, 0);
}




/*
 * Method declarations duplicated here for RDOC
 */

/*
 * Compute the voronoi diagram and delaunay triangulation from a set of points.
 *
 * This implementation uses Steven Fortune's sweepline algorithm, which runs in O(n log n) time and O(n) space.
 * It is limited to 2-dimensional space, therefore it expects to receive an array of objects that respond to 'x' and 'y' methods.
 */
VALUE RubyVor_from_points(VALUE, VALUE);

/*
 * Compute the nearest-neighbor graph using the existing Delaunay triangulation.
 */
VALUE RubyVor_nn_graph(VALUE);

/*
 * Computes the minimum spanning tree for given points, using the Delaunay triangulation as a seed.
 *
 * For points on a Euclidean plane, the MST is always comprised of a subset of the edges in a Delaunay triangulation. This makes computation of the tree very efficient: simply compute the Delaunay triangulation, and then run Prim's algorithm on the resulting edges.
 */
VALUE RubyVor_minimum_spanning_tree(int, VALUE*, VALUE);

/*
 * Move from the given index up, restoring the heap-order property.
 */
VALUE RubyVor_percolate_up(VALUE, VALUE);

/*
 * Move from the index down, restoring the heap-order property.
 */
VALUE RubyVor_percolate_down(VALUE, VALUE);

/*
 * Restore the heap-order property for a randomly ordered array of entries.
 */
VALUE RubyVor_heapify(VALUE);

/*
 * Compute the Euclidean distance between two points.
 */
VALUE RubyVor_distance_from(VALUE, VALUE);

/*
 * Hash value for a point.
 */
VALUE RubyVor_point_hash(VALUE);

/* keep comment so RDOC will find the last method definition */
