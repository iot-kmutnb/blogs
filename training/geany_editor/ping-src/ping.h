#ifndef __PING_H
#define __PING_H

#include <stdio.h>  // for printf(), snprintf()
#include <stdlib.h> // for system()

int exec_ping( const char *cmd );
int pipe_ping( const char *cmd );

#endif

