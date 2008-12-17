#ifndef __RUBY_VOR_H
#define __RUBY_VOR_H

#ifndef RB_LONG_BITS
#define RB_LONG_BITS sizeof(long)*8
#endif

#ifndef RB_HASH_FILTER
#define RB_HASH_FILTER ((2 << (RB_LONG_BITS / 2 - 1)) - 1)
#endif

extern VoronoiState rubyvorState;

/* Base modules */
VALUE RubyVor_rb_mRubyVor;
VALUE RubyVor_rb_mVDDT;

/* Computation */
VALUE RubyVor_rb_cComputation;
VALUE RubyVor_from_points(VALUE, VALUE);
VALUE RubyVor_nn_graph(VALUE);
// VALUE minimum_spanning_tree(int, VALUE*, VALUE);

/* PriorityQueue */
VALUE RubyVor_rb_cPriorityQueue;
VALUE RubyVor_rb_cQueueItem;
VALUE RubyVor_percolate_up(VALUE, VALUE);
VALUE RubyVor_percolate_down(VALUE, VALUE);
VALUE RubyVor_heapify(VALUE);

/* Point */
VALUE RubyVor_rb_cPoint;
VALUE RubyVor_distance_from(VALUE, VALUE);
VALUE RubyVor_point_hash(VALUE);

#endif
