#include "types.h"
#include "stat.h"
#include "user.h"

int head(int fd, int h, char *name){
  char buf[512];
  memset(buf, 0 , sizeof(buf));
  int i;
  int j;
  int n;
  int l;
  int a;
  int b;
  int c;
  int d;
  char *found;

  a = b = c = d = l = 0;

  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      if(buf[i] == '\n'){
        l++;
      }
    }
    if(l < h){
      a = l;
      printf (1, "%s", buf);
    }
    if(l >= h){
      if(a == 0){
        b = h;
      }
      else{
        b = h - a;
      }
      if(b == 1){
        found = strchr(buf, '\n');
        c = found - buf;
        for(j=0; j<=c; j++){
          printf (1, "%c", buf[j]);
        }
        return 0;
      }
      else{
        found = strchr(buf, '\n');
        b = b - 1;
        while(d < b){
          found = strchr(found + 1, '\n');
          c = found - buf;
          d = d + 1;
        }
        for(j=0; j<=c; j++){
          printf (1, "%c", buf[j]);
        }
        return 0;
      }
    }
    memset(buf, 0 , sizeof(buf));
  }
  if(n < 0){
    printf(1, "head: read error\n");
    return 0;
  }
  return 0;
}

int main(int argc, char *argv[])
{
  char *b;
  int fd, i, c;
  c = 10;

  if(argc <= 1){
    head(0, c, "");
    exit();
  }
  
  if(argc <= 2){
    b = argv[1];
    if(*b == '-'){
      b = b + 1;
      c = atoi(b);
      head(0, c, "");
      exit();
    }
    else{
      if((fd = open(argv[1], 0)) < 0){
        printf(1, "head: cannot open %s\n", argv[1]);
        exit();
      }
      head(fd, c, argv[1]);
      close(fd);
      exit();
    }
  }
  
  for(i = 1; i < argc; i++){
    b = argv[i];
    if(*b == '-'){
      b = b + 1;
      c = atoi(b);
    }
    else{
      while((fd = open(argv[i], 0)) < 0 && (i < argc)){
        i = i + 1;
      }
      if(i < argc){
        head(fd, c, argv[i]);
        close(fd);
      }
    }
  }
  exit();
}
