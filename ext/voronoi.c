
/*** VORONOI.C ***/

#include <ruby.h>
#include <vdefs.h>
#include <stdio.h>

VoronoiState rubyvorState;

/* Static method definitions: C -> Ruby storage methods. */
static void storeTriangulationTriplet(const int, const int, const int);
static void storeLine(const float, const float, const float);
static void storeEndpoint(const int, const int, const int);
static void storeVertex(const float, const float);
static void storeSite(const float, const float);

/*** implicit parameters: nsites, sqrt_nsites, xmin, xmax, ymin, ymax,
 : deltax, deltay (can all be estimates).
 : Performance suffers if they are wrong; better to make nsites,
 : deltax, and deltay too big than too small.  (?)
 ***/

void initialize_state(int debug)
{
    /* Set up our initial state */
    rubyvorState.debug = debug;
    rubyvorState.plot = 0;
    rubyvorState.nsites = 0;
    rubyvorState.siteidx = 0;
    
    rubyvorState.storeT = storeTriangulationTriplet;
    rubyvorState.storeL = storeLine;
    rubyvorState.storeE = storeEndpoint;
    rubyvorState.storeV = storeVertex;
    rubyvorState.storeS = storeSite;
    
    /* Initialize the Site Freelist */
    freeinit(&(rubyvorState.sfl), sizeof(Site)) ;

    /* Initialize the geometry module */
    geominit() ;

    /* TODO: remove C plot references */
    if (rubyvorState.plot)
        plotinit();
}

void
voronoi(Site *(*nextsite)(void))
{
    Site * newsite, * bot, * top, * temp, * p, * v ;
    Point newintstar ;
    int pm , c;
    Halfedge * lbnd, * rbnd, * llbnd, * rrbnd, * bisector ;
    Edge * e ;

    newintstar.x = newintstar.y = c = 0;
    
    PQinitialize() ;
    rubyvorState.bottomsite = (*nextsite)() ;
    out_site(rubyvorState.bottomsite) ;
    ELinitialize() ;
    newsite = (*nextsite)() ;
    
    while (1)
    {
        if(!PQempty())
            newintstar = PQ_min() ;
        
        if (newsite != (Site *)NULL && (PQempty()
            || newsite -> coord.y < newintstar.y
            || (newsite->coord.y == newintstar.y
            && newsite->coord.x < newintstar.x)))
        {
            /* new site is smallest */
            {
                out_site(newsite) ;
            }
            lbnd = ELleftbnd(&(newsite->coord)) ;
            rbnd = ELright(lbnd) ;
            bot = rightreg(lbnd) ;
            e = bisect(bot, newsite) ;
            bisector = HEcreate(e, le) ;
            ELinsert(lbnd, bisector) ;
            p = intersect(lbnd, bisector) ;
            if (p != (Site *)NULL)
            {
                PQdelete(lbnd) ;
                PQinsert(lbnd, p, dist(p,newsite)) ;
            }
            lbnd = bisector ;
            bisector = HEcreate(e, re) ;
            ELinsert(lbnd, bisector) ;
            p = intersect(bisector, rbnd) ;
            if (p != (Site *)NULL)
            {
                PQinsert(bisector, p, dist(p,newsite)) ;
            }
            newsite = (*nextsite)() ;
        }
        else if (!PQempty())   /* intersection is smallest */
        {
            lbnd = PQextractmin() ;
            llbnd = ELleft(lbnd) ;
            rbnd = ELright(lbnd) ;
            rrbnd = ELright(rbnd) ;
            bot = leftreg(lbnd) ;
            top = rightreg(rbnd) ;
            out_triple(bot, top, rightreg(lbnd)) ;
            v = lbnd->vertex ;
            makevertex(v) ;
            endpoint(lbnd->ELedge, lbnd->ELpm, v);
            endpoint(rbnd->ELedge, rbnd->ELpm, v) ;
            ELdelete(lbnd) ;
            PQdelete(rbnd) ;
            ELdelete(rbnd) ;
            pm = le ;
            if (bot->coord.y > top->coord.y)
            {
                temp = bot ;
                bot = top ;
                top = temp ;
                pm = re ;
            }
            e = bisect(bot, top) ;
            bisector = HEcreate(e, pm) ;
            ELinsert(llbnd, bisector) ;
            endpoint(e, re-pm, v) ;
            deref(v) ;
            p = intersect(llbnd, bisector) ;
            if (p  != (Site *) NULL)
            {
                PQdelete(llbnd) ;
                PQinsert(llbnd, p, dist(p,bot)) ;
            }
            p = intersect(bisector, rrbnd) ;
            if (p != (Site *) NULL)
            {
                PQinsert(bisector, p, dist(p,bot)) ;
            }
        }
        else
        {
            break ;
        }
    }
    
    for( lbnd = ELright(getELleftend()) ;
         lbnd != getELrightend() ;
         lbnd = ELright(lbnd))
    {
        e = lbnd->ELedge ;
        out_ep(e) ;
    }
}




/*
 * Static storage methods
 */

/*** stores a triplet of point indices that comprise a Delaunay triangle ***/
static void
storeTriangulationTriplet(const int a, const int b, const int c)
{
    VALUE trArray, triplet;
    
    /* Create a new triplet from the three incoming points */
    triplet = rb_ary_new2(3);
    
    rb_ary_push(triplet, INT2FIX(a));
    rb_ary_push(triplet, INT2FIX(b));
    rb_ary_push(triplet, INT2FIX(c));

    /* Get the existing raw triangulation */
    trArray = rb_funcall(*(VALUE *)rubyvorState.comp, rb_intern("delaunay_triangulation_raw"), 0);

    /* Add the new triplet to it */
    rb_ary_push(trArray, triplet);
}


/*** stores a line defined by ax + by = c ***/
static void
storeLine(const float a, const float b, const float c)
{
    VALUE lArray, line;
    
    /* Create a new line from the three values */
    line = rb_ary_new2(4);
    rb_ary_push(line, ID2SYM(rb_intern("l")));
    rb_ary_push(line, rb_float_new(a));
    rb_ary_push(line, rb_float_new(b));
    rb_ary_push(line, rb_float_new(c));

    /* Get the existing raw voronoi diagram */
    lArray = rb_funcall(*(VALUE *)rubyvorState.comp, rb_intern("voronoi_diagram_raw"), 0);

    /* Add the new line to it */
    rb_ary_push(lArray, line);
}


/***
 * Stores a Voronoi segment which is a subsegment of line number l;
 * with endpoints numbered v1 and v2.  If v1 or v2 is -1, the line
 * extends to infinity.
 ***/
static void
storeEndpoint(const int l, const int v1, const int v2)
{
    VALUE eArray, endpoint;
    
    /* Create a new endpoint from the three values */
    endpoint = rb_ary_new2(4);
    rb_ary_push(endpoint, ID2SYM(rb_intern("e")));
    rb_ary_push(endpoint, INT2FIX(l));
    rb_ary_push(endpoint, INT2FIX(v1));
    rb_ary_push(endpoint, INT2FIX(v2));

    /* Get the existing raw voronoi diagram */
    eArray = rb_funcall(*(VALUE *)rubyvorState.comp, rb_intern("voronoi_diagram_raw"), 0);

    /* Add the new endpoint to it */
    rb_ary_push(eArray, endpoint);
}


/*** stores a vertex at (a,b) ***/
static void
storeVertex(const float a, const float b)
{
    VALUE vArray, vertex;
    
    /* Create a new vertex from the coordinates */
    vertex = rb_ary_new2(3);
    rb_ary_push(vertex, ID2SYM(rb_intern("v")));
    rb_ary_push(vertex, rb_float_new(a));
    rb_ary_push(vertex, rb_float_new(b));

    /* Get the existing raw voronoi diagram */
    vArray = rb_funcall(*(VALUE *)rubyvorState.comp, rb_intern("voronoi_diagram_raw"), 0);

    /* Add the new vertex to it */
    rb_ary_push(vArray, vertex);
}


/***
 * stores an input site at (x,y)
 * TODO: redundant?
 ***/
static void
storeSite(const float x, const float y)
{
    VALUE sArray, site;
    
    /* Create a new site from the coordinates */
    site = rb_ary_new2(3);
    rb_ary_push(site, ID2SYM(rb_intern("s")));
    rb_ary_push(site, rb_float_new(x));
    rb_ary_push(site, rb_float_new(y));

    /* Get the existing raw voronoi diagram */
    sArray = rb_funcall(*(VALUE *)rubyvorState.comp, rb_intern("voronoi_diagram_raw"), 0);

    /* Add the new site to it */
    rb_ary_push(sArray, site);
}
