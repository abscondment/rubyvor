#include <ruby.h>
#include <vdefs.h>
#include <stdio.h>
#include <stdlib.h>

VoronoiState rubyvorState;

static VALUE rb_mRubyVor;
static VALUE rb_mVDDT;
static VALUE rb_cDecomposition;
static int repeat;

// Private method definitions
static Site * readone(void), * nextone(void);
static void readsites(void);
//static void print_memory(void);

static VALUE
from_points(VALUE self, VALUE pointsArray)
{
    //VALUE returnValue;
    VALUE * inPtr;
    ID x, y;
    long i, inSize, xsum, ysum;
    Site *(*next)() ;

    xsum = 0;
    ysum = 0;
    repeat = 0;

    rubyvorState.triangulate = 1;
    // hi
    
    //print_memory();

    // Initialize the Site Freelist
    freeinit(&(rubyvorState.sfl), sizeof(Site)) ;

    // Read in the sites
    readsites() ;
    next = nextone;

    // Initialize the geometry module
    rubyvorState.siteidx = 0 ;
    geominit() ;


    if (rubyvorState.plot)
        plotinit();

    // Perform the computation
    voronoi(next);
    
    //print_memory();

    // Free our allocated objects
    free_all();
    
    //print_memory();
    
    //fprintf(stderr,"FINISHED ITERATION %i\n", repeat + 1);
    
    /*
    x = rb_intern("x");
    y = rb_intern("y");
    
    inSize = RARRAY(pointsArray)->len;
    inPtr  = RARRAY(pointsArray)->ptr;

    // Require x & y methods
    if (inSize < 1 || !rb_respond_to(inPtr[0], x) || !rb_respond_to(inPtr[0], y))
        rb_raise(rb_eRuntimeError, "target must respond to 'x' and 'y' and have a nonzero length");

    // Iterate over the arrays, doubling the incoming values.
    for (i=0; i<inSize; i++)
    {
        xsum += FIX2INT(rb_funcall(inPtr[i], x, 0));
        ysum += FIX2INT(rb_funcall(inPtr[i], y, 0));
    }
    
    print_memory();
    */
    
    return LONG2FIX(xsum - ysum);
}

void
Init_voronoi_interface(void)
{
    // Set up our Modules and Class.
    rb_mRubyVor       = rb_define_module("RubyVor");
    rb_mVDDT          = rb_define_module_under(rb_mRubyVor, "VDDT");
    rb_cDecomposition = rb_define_class_under(rb_mVDDT, "Decomposition", rb_cObject);

    // Add methods.
    rb_define_singleton_method(rb_cDecomposition, "from_points", from_points, 1);
}



/*
static void
print_memory(void)
{
    char buf[30];
    FILE* pf;

    unsigned size; //       total program size
    unsigned resident;//   resident set size
    unsigned share;//      shared pages
    unsigned text;//       text (code)
    unsigned lib;//        library
    unsigned data;//       data/stack
    unsigned dt;//         dirty pages (unused in Linux 2.6)

    float totalSize;
    
    snprintf(buf, 30, "/proc/%u/statm", (unsigned)getpid());
    pf = fopen(buf, "r");
    if (NULL != pf)
    {
        fscanf(pf, "%u", &size);//, %u, %u ... etc &resident, &share, &text, &lib, &data);
        // DOMSGCAT(MSTATS, std::setprecision(4) << size / (1024.0) << "MB mem used");
        totalSize = (float)size / 1024.0;
        fprintf(stderr, "%f ", totalSize);
    }
    fclose(pf);
    
}
*/


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

/*** read all sites, sort, and compute xmin, xmax, ymin, ymax ***/

static void
readsites(void)
{
    int i ;

    rubyvorState.nsites = 0;

    // Allocate memory for 4000 sites...
    rubyvorState.sites = (Site *) myalloc(4000 * sizeof(Site));
    
    FILE * inputFile;

    inputFile = fopen("test.dat", "r");

    if (NULL==inputFile)
    {
        fprintf(stderr, "Input file missing.");
        exit(0);
    }
    
    while (fscanf(inputFile, "%f %f", &rubyvorState.sites[rubyvorState.nsites].coord.x, &rubyvorState.sites[rubyvorState.nsites].coord.y) != EOF)
    {
        rubyvorState.sites[rubyvorState.nsites].sitenbr = rubyvorState.nsites ;
        rubyvorState.sites[rubyvorState.nsites++].refcnt = 0 ;

        // Allocate for 4000 more if we just hit a multiple of 4000...
        if (rubyvorState.nsites % 4000 == 0)
		{
            rubyvorState.sites = (Site *)myrealloc(rubyvorState.sites,(rubyvorState.nsites+4000)*sizeof(Site),rubyvorState.nsites*sizeof(Site));
		}
    }

    //print_memory();
    
    // Close the file
    fclose(inputFile);

    // Sort the Sites
    qsort((void *)rubyvorState.sites, rubyvorState.nsites, sizeof(Site), scomp) ;

    // Pull the minimum values.
    rubyvorState.xmin = rubyvorState.sites[0].coord.x ;
    rubyvorState.xmax = rubyvorState.sites[0].coord.x ;
    for (i = 1 ; i < rubyvorState.nsites ; ++i)
    {
        if(rubyvorState.sites[i].coord.x < rubyvorState.xmin)
        {
            rubyvorState.xmin = rubyvorState.sites[i].coord.x ;
        }
        if (rubyvorState.sites[i].coord.x > rubyvorState.xmax)
        {
            rubyvorState.xmax = rubyvorState.sites[i].coord.x ;
        }
    }
    rubyvorState.ymin = rubyvorState.sites[0].coord.y ;
    rubyvorState.ymax = rubyvorState.sites[rubyvorState.nsites-1].coord.y ;
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
