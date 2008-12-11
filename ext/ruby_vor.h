#ifndef __RUBY_VOR_H
#define __RUBY_VOR_H

extern VoronoiState rubyvorState;

/* Base modules */
VALUE rb_mRubyVor;
VALUE rb_mVDDT;

/* Computation */
VALUE rb_cComputation;
VALUE from_points(VALUE, VALUE);
VALUE nn_graph(VALUE);
// VALUE minimum_spanning_tree(int, VALUE*, VALUE);

/* PriorityQueue */
VALUE rb_cPriorityQueue;
VALUE rb_cQueueItem;
VALUE percolate_up(VALUE, VALUE);
VALUE percolate_down(VALUE, VALUE);
VALUE heapify(VALUE);

/* Point */
VALUE rb_cPoint;
VALUE distance_from(VALUE, VALUE);

#endif
