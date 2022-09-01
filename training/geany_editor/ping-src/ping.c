#include "ping.h"

#define PING_BUF_LEN (128)

int exec_ping( const char *cmd ) {
  if( cmd == NULL ) { return -1; }
  int status = system( cmd ); // execute the ping command
  return status >> 8; // status code divided by 256
}

int pipe_ping( const char *cmd ) {
  if( cmd == NULL ) { return -1; }
  char buf[ PING_BUF_LEN ];
  FILE *fp;
  // run the command and open the pipe 
  if ((fp = popen(cmd, "r")) == NULL) {
    printf( "Error opening pipe!\n" );
    return -1;
  }
  // read from pipe iine by line (limited by PING_BUF_LEN)
  while (fgets(buf, PING_BUF_LEN, fp) != NULL) {
    printf( "> %s", buf ); // show output from the ping command
  }
  // close the pipe
  if ( pclose(fp) ) {
    return -1; // command not found or exited with error
  }
  return 0; // status ok
}

