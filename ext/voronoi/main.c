/*** MAIN.C ***/

#include <stdio.h>
#include <stdlib.h>  /* realloc(), qsort() */


#include "vdefs.h"

Site * readone(void), * nextone(void) ;
void readsites(void) ;


int repeat ;

VoronoiState rubyvorState;

void
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
        fscanf(pf, "%u" /* %u %u %u %u %u"*/, &size/*, &resident, &share, &text, &lib, &data*/);
        // DOMSGCAT(MSTATS, std::setprecision(4) << size / (1024.0) << "MB mem used");
        totalSize = (float)size / 1024.0;
        fprintf(stderr, "%f ", totalSize);
    }
    fclose(pf);
    
}

int
main(int argc, char *argv[])
{
    int c ;
    Site *(*next)() ;

    for (repeat=0; repeat < 3; repeat++)
    {

        print_memory();
        
        rubyvorState.sorted = rubyvorState.triangulate = rubyvorState.plot = rubyvorState.debug = 0 ;
        while ((c = getopt(argc, argv, "dpst")) != EOF)
        {
            switch(c)
            {
                case 'd':
                    rubyvorState.debug = 1 ;
                    break ;
                case 's':
                    rubyvorState.sorted = 1 ;
                    break ;
                case 't':
                    rubyvorState.triangulate = 1 ;
                    break ;
                case 'p':
                    rubyvorState.plot = 1 ;
                    break ;
            }
        }

        freeinit(&(rubyvorState.sfl), sizeof(Site)) ;

        if (rubyvorState.sorted)
        {
            scanf("%d %f %f %f %f", &(rubyvorState.nsites), &(rubyvorState.xmin), &(rubyvorState.xmax), &(rubyvorState.ymin), &(rubyvorState.ymax)) ;
            next = readone ;
        } else {
            readsites() ;
            next = nextone ;
        }
        
        rubyvorState.siteidx = 0 ;
        geominit() ;


        if (rubyvorState.plot)
            plotinit() ;
        
        voronoi(next) ;

        print_memory();

        free_all();
        
        print_memory();

        
        fprintf(stderr,"FINISHED ITERATION %i\n", repeat + 1);
    }
    
    return (0) ;
    
}

/*** sort sites on y, then x, coord ***/

int
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

Site *
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

void
readsites(void)
{
    int i ;

    rubyvorState.nsites = 0;

    // Allocate memory for 4000 sites...
    rubyvorState.sites = (Site *) myalloc(4000 * sizeof(Site));
    
    FILE * inputFile;

    inputFile = fopen("test.dat", "r");

    if (NULL==inputFile) {
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

    print_memory();

    
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

Site *
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

