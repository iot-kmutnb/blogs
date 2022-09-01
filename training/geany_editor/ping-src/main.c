#include <stdio.h>  // for printf(), sprintf()
#include "ping.h"   // for exec_ping(), pipe_ping()

int main( int argc, char **argv ) {
  char cmd[32];
  sprintf( cmd, "/usr/bin/ping %s -c %u", "8.8.8.8", 5 );
  // send a ping packet to 8.8.8.8 (Google DNS server) 5 times
  // Method 1)
  if ( exec_ping( cmd ) != 0 ) {
    printf( "PING command execution using system() failed!" );
  }
  // Method 2)
  if ( pipe_ping( cmd ) != 0 ) {
    printf( "PING command execution using popen() failed!" );
  }
  return 0;
}

