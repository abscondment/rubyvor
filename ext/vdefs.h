#ifndef __VDEFS_H
#define __VDEFS_H

#ifndef NULL
#define NULL 0
#endif

#define DELETED -2

typedef struct tagFreenode
{
    struct tagFreenode * nextfree;
} Freenode ;


typedef struct tagFreelist
{
    Freenode * head;
    int nodesize;
} Freelist ;

typedef struct tagPoint
{
    float x ;
    float y ;
} Point ;

/* structure used both for sites and for vertices */

typedef struct tagSite
{
    Point coord ;
    int sitenbr ;
    int refcnt ;
} Site ;


typedef struct tagEdge
{
    float a, b, c ;
    Site * ep[2] ;
    Site * reg[2] ;
    int edgenbr ;
} Edge ;

#define le 0
#define re 1

typedef struct tagHalfedge
{
    struct tagHalfedge * ELleft ;
    struct tagHalfedge * ELright ;
    Edge * ELedge ;
    int ELrefcnt ;
    char ELpm ;
    Site * vertex ;
    float ystar ;
    struct tagHalfedge * PQnext ;
} Halfedge ;

typedef struct tagVoronoiState
{
    /* voronoi.c */
    int sorted, plot, debug, siteidx;
    float xmin, xmax, ymin, ymax;
    Site * sites;
    void * comp;
    void (* storeT)(int, int, int);
    void (* storeL)(float, float, float);
    void (* storeE)(int, int, int);
    void (* storeV)(float, float);
    void (* storeS)(float, float);
    
    /* geometry.c */
    float deltax, deltay;
    int nsites, nedges, sqrt_nsites, nvertices;
    Freelist sfl;

    /* edgelist.c */
    int ELhashsize;
    Site * bottomsite;
} VoronoiState;

extern VoronoiState rubyvorState;

/* edgelist.c */
void ELinitialize(void) ;
Halfedge * HEcreate(Edge *, int) ;
void ELinsert(Halfedge *, Halfedge *) ;
Halfedge * ELgethash(int) ;
Halfedge * ELleftbnd(Point *) ;
void ELdelete(Halfedge *) ;
Halfedge * ELright(Halfedge *) ;
Halfedge * ELleft(Halfedge *) ;
Site * leftreg(Halfedge *) ;
Site * rightreg(Halfedge *) ;
Halfedge * getELleftend(void) ;
Halfedge * getELrightend(void) ;

/* geometry.c */
void geominit(void) ;
Edge * bisect(Site *, Site *) ;
Site * intersect(Halfedge *, Halfedge *) ;
int right_of(Halfedge *, Point *) ;
void endpoint(Edge *, int, Site *) ;
float dist(Site *, Site *) ;
void makevertex(Site *) ;
void deref(Site *) ;
void ref(Site *) ;

/* heap.c */
void PQinsert(Halfedge *, Site *, float) ;
void PQdelete(Halfedge *) ;
int PQbucket(Halfedge *) ;
int PQempty(void) ;
Point PQ_min(void) ;
Halfedge * PQextractmin(void) ;
void PQinitialize(void) ;

/* getopt.c */
extern int getopt(int, char *const *, const char *);

/* memory.c */
void freeinit(Freelist *, int) ;
char *getfree(Freelist *) ;
void makefree(Freenode *, Freelist *) ;
char *myalloc(unsigned) ;
char *myrealloc(void *, unsigned, unsigned);
void free_all(void);

/* output.c */
void openpl(void) ;
void line(float, float, float, float) ;
void circle(float, float, float) ;
void range(float, float, float, float) ;
void out_bisector(Edge *) ;
void out_ep(Edge *) ;
void out_vertex(Site *) ;
void out_site(Site *) ;
void out_triple(Site *, Site *, Site *) ;
void plotinit(void) ;
void clip_line(Edge *) ;
void debug_memory(void);

/* voronoi.c */
void voronoi(Site *(*)()) ;
void initialize_state(int);
#endif


