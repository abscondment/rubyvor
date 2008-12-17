#include <ruby.h>
#include <vdefs.h>
#include <ruby_vor_c.h>
#include <stdio.h>
#include <stdlib.h>

static Site * nextone(void);
static int scomp(const void *, const void *);

//
// See ruby_vor.c for RDOC
//


//
// Class methods for RubyVor::VDDT::Computation
//

VALUE
RubyVor_from_points(VALUE self, VALUE pointsArray)
{
    //VALUE returnValue;
    VALUE * inPtr, newComp;
    ID x, y;

    long i, inSize;

    // Require T_ARRAY
    Check_Type(pointsArray, T_ARRAY);

    // Intern our point access methods
    x = rb_intern("x");
    y = rb_intern("y");


    // Require nonzero size and x & y methods on each array object
    if (RARRAY(pointsArray)->len < 1)
        rb_raise(rb_eRuntimeError, "points array have a nonzero length");
    for (i = 0; i < RARRAY(pointsArray)->len; i++) {
        if(!rb_respond_to(RARRAY(pointsArray)->ptr[i], x) || !rb_respond_to(RARRAY(pointsArray)->ptr[i], y))
            rb_raise(rb_eRuntimeError, "members of points array must respond to 'x' and 'y'");
    }

    // Load up point count & points pointer.
    pointsArray = rb_funcall(pointsArray, rb_intern("uniq"), 0);
    inSize = RARRAY(pointsArray)->len;
    inPtr  = RARRAY(pointsArray)->ptr;

    
    // Initialize rubyvorState
    initialize_state(0 /* debug? */);
    debug_memory();
    
    // Create our return object.
    newComp = rb_funcall(self, rb_intern("new"), 0);
    rb_iv_set(newComp, "@points", pointsArray);
    
    // Store it in rubyvorState so we can populate its values.
    rubyvorState.comp = (void *) &newComp;
    
    //
    // Read in the sites, sort, and compute xmin, xmax, ymin, ymax
    //
    // TODO: refactor this block into a separate method for clarity?
    //
    {
        // Allocate memory for N sites...
        rubyvorState.sites = (Site *) myalloc(inSize * sizeof(Site));
    
    
        // Iterate over the arrays, doubling the incoming values.
        for (i=0; i<inSize; i++)
        {
            rubyvorState.sites[rubyvorState.nsites].coord.x = NUM2DBL(rb_funcall(inPtr[i], x, 0));
            rubyvorState.sites[rubyvorState.nsites].coord.y = NUM2DBL(rb_funcall(inPtr[i], y, 0));
            
            // 
            rubyvorState.sites[rubyvorState.nsites].sitenbr = rubyvorState.nsites;
            rubyvorState.sites[rubyvorState.nsites++].refcnt = 0;
            
            // Allocate for N more if we just hit a multiple of N...
            if (rubyvorState.nsites % inSize == 0)
            {
                rubyvorState.sites = (Site *)myrealloc(rubyvorState.sites,(rubyvorState.nsites+inSize)*sizeof(Site),rubyvorState.nsites*sizeof(Site));
            }
        }
        
        // Sort the Sites
        qsort((void *)rubyvorState.sites, rubyvorState.nsites, sizeof(Site), scomp) ;
        
        // Pull the minimum values.
        rubyvorState.xmin = rubyvorState.sites[0].coord.x;
        rubyvorState.xmax = rubyvorState.sites[0].coord.x;
        for (i=1; i < rubyvorState.nsites; ++i)
        {
            if (rubyvorState.sites[i].coord.x < rubyvorState.xmin)
            {
                rubyvorState.xmin = rubyvorState.sites[i].coord.x;
            }
            if (rubyvorState.sites[i].coord.x > rubyvorState.xmax)
            {
                rubyvorState.xmax = rubyvorState.sites[i].coord.x;
            }
        }
        rubyvorState.ymin = rubyvorState.sites[0].coord.y;
        rubyvorState.ymax = rubyvorState.sites[rubyvorState.nsites-1].coord.y;
        
    }

    
    // Perform the computation
    voronoi(nextone);
    debug_memory();
    
    // Get rid of our comp reference
    rubyvorState.comp = (void *)NULL;
    
    // Free our allocated objects
    free_all();    
    debug_memory();

    return newComp;
}


//
// Instance methods
//

/*
VALUE
RubyVor_minimum_spanning_tree(int argc, VALUE *argv, VALUE self)
{
    VALUE dist_proc, nodes, nnGraph, points, queue, tmpHash, tmpArray, adjList, latestAddition;
    long i, j;

    // 0 mandatory, 1 optional
    rb_scan_args(argc, argv, "01", &dist_proc);

    if (NIL_P(dist_proc)) {
        // Use our default Proc
        dist_proc = rb_eval_string("lambda{|a,b| a.distance_from(b)}");
    } else if (rb_class_of(dist_proc) != rb_cProc) {
        // Blow up if we have a non-nil, non-Proc
        rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)", rb_obj_classname(dist_proc), rb_class2name(rb_cProc));
    }

    points  = rb_iv_get(self, "@points");
    nodes   = rb_ary_new2(RARRAY(points)->len);
    queue   = rb_eval_string("RubyVor::PriorityQueue.new(lambda{|a,b| a[:min_distance] < b[:min_distance]})");
    nnGraph = RubyVor_nn_graph(self);

    for (i=0; i < RARRAY(points)->len; i++) {
        tmpHash = rb_hash_new();

        // :node => n,
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("node")), INT2FIX(i));
        // :min_distance => (n == 0) ? 0.0 : Float::MAX,
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("min_distance")), (i == 0) ? INT2FIX(0) : rb_const_get(rb_cFloat, rb_intern("MAX")));
        // :parent => nil,
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("parent")), Qnil);
        // :adjacency_list => RubyVor_nn_graph[n].clone,
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("adjacency_list")), rb_funcall(RARRAY(nnGraph)->ptr[i], rb_intern("clone"), 0));
        // :min_adjacency_list => [],
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("min_adjacency_list")), rb_ary_new());
        // :in_q => true
        rb_hash_aset(tmpHash, ID2SYM(rb_intern("in_q")), Qtrue);
        
        rb_funcall(queue, rb_intern("push"), 1, tmpHash);
    }

    tmpArray = rb_funcall(queue, rb_intern("data"), 0);
    for (i = 0; i < RARRAY(tmpArray)->len; i++) {
        tmpHash = RARRAY(tmpArray)->ptr[i];
        adjList = rb_hash_aref(tmpHash, ID2SYM(rb_intern("adjacency_list")));
        
        for (j = 0; j < RARRAY(adjList)->len; j++)
            rb_ary_store(adjList, j, RARRAY(tmpArray)->ptr[ FIX2INT(RARRAY(adjList)->ptr[j]) ]);
    }

    latestAddition = rb_funcall(queue, rb_intern("pop"), 0);
    while (RTEST(latestAddition)) {
        rb_hash_aset(latestAddition, ID2SYM(rb_intern("in_q")), Qfalse);

        if (RTEST(rb_hash_aref(latestAddition, ID2SYM(rb_intern("parent"))))) {
        }
        break;
    }
    
    return tmpArray;
}
*/

VALUE
RubyVor_nn_graph(VALUE self)
{
    long i, j, k, x;
    VALUE dtRaw, graph, points, * dtPtr, * tripletPtr, * graphPtr;

    graph = rb_iv_get(self, "@nn_graph");
    
    if (RTEST(graph))
        return graph;

    // Create an array of same size as points for the graph
    points = rb_iv_get(self, "@points");
    
    graph = rb_ary_new2(RARRAY(points)->len);
    for (i = 0; i < RARRAY(points)->len; i++)
        rb_ary_push(graph, rb_ary_new());
    
    // Get our pointer into this array.
    graphPtr = RARRAY(graph)->ptr;

    // Iterate over the triangulation
    dtRaw = rb_iv_get(self, "@delaunay_triangulation_raw");
    dtPtr = RARRAY(dtRaw)->ptr;
    for (i = 0; i < RARRAY(dtRaw)->len; i++) {
        tripletPtr = RARRAY(dtPtr[i])->ptr;

        /*
        for (x = 0; x < 3; x++) {
            rb_ary_push(graphPtr[FIX2INT(tripletPtr[x % 2 + 1])], FIX2INT(tripletPtr[x & 6]));
            rb_ary_push(graphPtr[FIX2INT(tripletPtr[x & 6])], FIX2INT(tripletPtr[x % 2 + 1]));
        }
        */

        rb_ary_push(graphPtr[FIX2INT(tripletPtr[0])], tripletPtr[1]);
        rb_ary_push(graphPtr[FIX2INT(tripletPtr[1])], tripletPtr[0]);

        rb_ary_push(graphPtr[FIX2INT(tripletPtr[0])], tripletPtr[2]);
        rb_ary_push(graphPtr[FIX2INT(tripletPtr[2])], tripletPtr[0]);

        rb_ary_push(graphPtr[FIX2INT(tripletPtr[1])], tripletPtr[2]);
        rb_ary_push(graphPtr[FIX2INT(tripletPtr[2])], tripletPtr[1]);
        
    }
    for (i = 0; i < RARRAY(graph)->len; i++) {
        if (RARRAY(graphPtr[i])->len < 1) {
            rb_raise(rb_eIndexError, "index of 0 (no neighbors) at %i", i);
            /*
            // No valid triangles touched this node -- include *all* possible neighbors
            for(j = 0; j < RARRAY(points)->len; j++) {
                if (j != i) {
                    rb_ary_push(graphPtr[i], INT2FIX(j));
                    if (RARRAY(graphPtr[j])->len > 0 && !rb_ary_includes(graphPtr[j], INT2FIX(i)))
                        rb_ary_push(graphPtr[j], INT2FIX(i));
                }
            }
            */
        } else {
            rb_funcall(graphPtr[i], rb_intern("uniq!"), 0);
        }
    }

    rb_iv_set(self, "@nn_graph", graph);
    
    return graph;
}



//
// Static C helper methods
//


/*** sort sites on y, then x, coord ***/
static int
scomp(const void * vs1, const void * vs2)
{
    Point * s1 = (Point *)vs1 ;
    Point * s2 = (Point *)vs2 ;

    if (s1->y < s2->y)
    {
        return (-1) ;
    }
    if (s1->y > s2->y)
    {
        return (1) ;
    }
    if (s1->x < s2->x)
    {
        return (-1) ;
    }
    if (s1->x > s2->x)
    {
        return (1) ;
    }
    return (0) ;
}

/*** return a single in-storage site ***/
static Site *
nextone(void)
{
    Site * s ;

    if (rubyvorState.siteidx < rubyvorState.nsites)
    {
        s = &rubyvorState.sites[rubyvorState.siteidx++];
        return (s) ;
    }
    else
    {
        return ((Site *)NULL) ;
    }
}
