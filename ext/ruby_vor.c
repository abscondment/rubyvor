#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor.h>

//
// Extension initialization
//
void
Init_ruby_vor(void)
{
    //
    // Set up our Modules and Class.
    //

    /*
     * Main RubyVor namespace.
     */
    rb_mRubyVor       = rb_define_module("RubyVor");

    
    /*
     * Voronoi Digram and Delaunay Triangulation namespace.
     */
    rb_mVDDT          = rb_define_module_under(rb_mRubyVor, "VDDT");

    
    /*
     * Class representing a VD/DT computation based on a set of 2-dimensional points
     */
    rb_cComputation   = rb_define_class_under(rb_mVDDT, "Computation", rb_cObject);
    rb_define_singleton_method(rb_cComputation, "from_points", from_points, 1);
    rb_define_method(rb_cComputation, "nn_graph", nn_graph, 0);
    // rb_define_method(rb_cComputation, "minimum_spanning_tree", minimum_spanning_tree, -1);

    
    /*
     * A priority queue with a customizable heap-order property.
     */
    rb_cPriorityQueue = rb_define_class_under(rb_mRubyVor, "PriorityQueue", rb_cObject);
    rb_cQueueItem = rb_define_class_under(rb_cPriorityQueue, "QueueItem", rb_cObject);
    rb_define_method(rb_cPriorityQueue, "percolate_up", percolate_up, 1);
    rb_define_method(rb_cPriorityQueue, "percolate_down", percolate_down, 1);
    rb_define_method(rb_cPriorityQueue, "heapify", heapify, 0);


    /*
     * A simple Point class
     */
    rb_cPoint = rb_define_class_under(rb_mRubyVor, "Point", rb_cObject);
    rb_define_method(rb_cPoint, "distance_from", distance_from, 1);
}




//
// Method declarations duplicated here for RDOC
//

/*
 * Compute the voronoi diagram and delaunay triangulation from a set of points.
 *
 * This implementation uses Steven Fortune's sweepline algorithm, which runs in O(n log n) time and O(n) space.
 * It is limited to 2-dimensional space, therefore it expects to receive an array of objects that respond to 'x' and 'y' methods.
 */
VALUE from_points(VALUE, VALUE);

/*
 * Compute the nearest-neighbor graph using the existing Delaunay triangulation.
 */
VALUE nn_graph(VALUE);

/*
 * Compute the MST for the nearest-nearest graph using a Priority Queue and Prim's algorithm.
 */
// VALUE minimum_spanning_tree(int, VALUE*, VALUE);

/*
 * Move from the given index up, restoring the heap-order property.
 */
VALUE percolate_up(VALUE, VALUE);

/*
 * Move from the index down, restoring the heap-order property.
 */
VALUE percolate_down(VALUE, VALUE);

/*
 * Restore the heap-order property for a randomly ordered array of entries.
 */
VALUE heapify(VALUE);

/*
 * Compute the Euclidean distance between two points.
 */
VALUE distance_from(VALUE, VALUE);
