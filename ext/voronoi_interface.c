#include <ruby.h>
#include <vdefs.h>
#include <stdio.h>
#include <stdlib.h>




VoronoiState rubyvorState;

/*
 * RDOC DOC DE DOC
 */
static VALUE rb_mRubyVor;
static VALUE rb_mVDDT;
static VALUE rb_cComputation;
static int repeat, rit;

// Static method definitions
static VALUE from_points(VALUE, VALUE);

static Site * readone(void), * nextone(void);
static int scomp(const void *, const void *);



void
Init_voronoi_interface(void)
{
    //
    // Set up our Modules and Class.
    //

    /*
     * TODO: DOC DOC DE DOC
     */
    rb_mRubyVor       = rb_define_module("RubyVor");
    /*
     * Voronoi Digram and Delaunay Triangulation namespace.
     */
    rb_mVDDT          = rb_define_module_under(rb_mRubyVor, "VDDT");
    /*
     * Represents a VD/DT computation based on a set of 2-dimensional points
     */
    rb_cComputation   = rb_define_class_under(rb_mVDDT, "Computation", rb_cObject);

    //
    // Add methods.
    //
    rb_define_singleton_method(rb_cComputation, "from_points", from_points, 1);
}


//
// Class methods
//


/*
 * Compute the voronoi diagram and delaunay triangulation from a set of points.
 *
 * This implementation uses Steven Fortune's sweepline algorithm, which runs in O(n log n) time and O(n) space.
 * It is limited to 2-dimensional space, therefore it expects to receive an array of objects that respond to 'x' and 'y' methods.
 */
static VALUE
from_points(VALUE self, VALUE pointsArray)
{
    //VALUE returnValue;
    VALUE * inPtr, newComp;
    ID x, y;

    long i, inSize;

    // TODO: remove
    repeat = 1;
    
    for (rit = 0; rit < repeat; rit++) {

    // Require T_ARRAY
    //Check_Type(pointsArray, T_ARRAY);

    // Intern our point access methods
    x = rb_intern("x");
    y = rb_intern("y");

    // Load up point count & points pointer.
    inSize = RARRAY(pointsArray)->len;
    inPtr  = RARRAY(pointsArray)->ptr;

    // Require nonzero size and x & y methods on each array object
    if (inSize < 1)
        rb_raise(rb_eRuntimeError, "points array have a nonzero length");
    for (i = 0; i < inSize; i++) {
        if(!rb_respond_to(inPtr[i], x) || !rb_respond_to(inPtr[i], y))
            rb_raise(rb_eRuntimeError, "members of points array must respond to 'x' and 'y'");
    }

    
    // Initialize rubyvorState
    initialize_state(/* debug? */ 0);
    debug_memory();
    
    // Create our return object.
    newComp = rb_funcall(self, rb_intern("new"), 1, pointsArray);
    // Store it in rubyvorState so we can populate its values.
    rubyvorState.comp = (void *) &newComp;
    //
    // Read in the sites, sort, and compute xmin, xmax, ymin, ymax
    //
    // TODO: refactor this block into a separate method for clarity?
    //
    {
        // Allocate memory for 4000 sites...
        rubyvorState.sites = (Site *) myalloc(4000 * sizeof(Site));
    
    
        // Iterate over the arrays, doubling the incoming values.
        for (i=0; i<inSize; i++)
        {
            rubyvorState.sites[rubyvorState.nsites].coord.x = NUM2DBL(rb_funcall(inPtr[i], x, 0));
            rubyvorState.sites[rubyvorState.nsites].coord.y = NUM2DBL(rb_funcall(inPtr[i], y, 0));
            
            // 
            rubyvorState.sites[rubyvorState.nsites].sitenbr = rubyvorState.nsites;
            rubyvorState.sites[rubyvorState.nsites++].refcnt = 0;
            
            // Allocate for 4000 more if we just hit a multiple of 4000...
            if (rubyvorState.nsites % 4000 == 0)
            {
                rubyvorState.sites = (Site *)myrealloc(rubyvorState.sites,(rubyvorState.nsites+4000)*sizeof(Site),rubyvorState.nsites*sizeof(Site));
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

    if (rubyvorState.debug)
        fprintf(stderr,"FINISHED ITERATION %i\n", rit + 1);

    
    } // end repeat...
    
    return newComp;
}


//
// Instance methods (none)
//



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


/*** read one site ***/
static Site *
readone(void)
{
    Site * s ;

    s = (Site *)getfree(&(rubyvorState.sfl)) ;
    s->refcnt = 0 ;
    s->sitenbr = rubyvorState.siteidx++ ;
    if (scanf("%f %f", &(s->coord.x), &(s->coord.y)) == EOF)
    {
        return ((Site *)NULL ) ;
    }
    return (s) ;
}
