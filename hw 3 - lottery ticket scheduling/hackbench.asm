
_hackbench:     file format elf32-i386


Disassembly of section .text:

00000000 <rdtsc>:
{
  asm volatile("hlt");
}

static inline unsigned long long rdtsc(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    unsigned long long ret;
    asm volatile ( "rdtsc" : "=A"(ret) );
   6:	0f 31                	rdtsc  
   8:	89 45 f8             	mov    %eax,-0x8(%ebp)
   b:	89 55 fc             	mov    %edx,-0x4(%ebp)
    return ret;
   e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  11:	8b 55 fc             	mov    -0x4(%ebp),%edx
}
  14:	c9                   	leave  
  15:	c3                   	ret    

00000016 <barf>:
}pollfd[512];



static void barf(const char *msg)
{
  16:	55                   	push   %ebp
  17:	89 e5                	mov    %esp,%ebp
  19:	83 ec 18             	sub    $0x18,%esp
  printf(STDOUT, "(Error: %s)\n", msg);
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  23:	c7 44 24 04 38 0f 00 	movl   $0xf38,0x4(%esp)
  2a:	00 
  2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  32:	e8 f5 0a 00 00       	call   b2c <printf>
  exit();
  37:	e8 ef 08 00 00       	call   92b <exit>

0000003c <fdpair>:
}

static void fdpair(int fds[2])
{
  3c:	55                   	push   %ebp
  3d:	89 e5                	mov    %esp,%ebp
  3f:	83 ec 18             	sub    $0x18,%esp
  if (use_pipes) {
  42:	a1 44 14 00 00       	mov    0x1444,%eax
  47:	85 c0                	test   %eax,%eax
  49:	74 20                	je     6b <fdpair+0x2f>
    // TODO: Implement myPipe
    //    pipe(fds[0], fds[1]);
    if (pipe(fds) == 0)
  4b:	8b 45 08             	mov    0x8(%ebp),%eax
  4e:	89 04 24             	mov    %eax,(%esp)
  51:	e8 e5 08 00 00       	call   93b <pipe>
  56:	85 c0                	test   %eax,%eax
  58:	75 0f                	jne    69 <fdpair+0x2d>
      fd_count += 2;
  5a:	a1 60 14 00 00       	mov    0x1460,%eax
  5f:	83 c0 02             	add    $0x2,%eax
  62:	a3 60 14 00 00       	mov    %eax,0x1460
      return;
  67:	eb 0e                	jmp    77 <fdpair+0x3b>
  69:	eb 0c                	jmp    77 <fdpair+0x3b>
  } else {
    // This mode would not run correctly in xv6
    //if (socketpair(AF_UNIX, SOCK_STREAM, 0, fds) == 0)
    //  return;
    barf("Socket mode is running. (error)\n");
  6b:	c7 04 24 48 0f 00 00 	movl   $0xf48,(%esp)
  72:	e8 9f ff ff ff       	call   16 <barf>
  }
  //barf("Creating fdpair");
}
  77:	c9                   	leave  
  78:	c3                   	ret    

00000079 <checkEvents>:

static void checkEvents(int id, int event, int caller, char *msg){
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	83 ec 28             	sub    $0x28,%esp
  if(event == POLLIN){
  7f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  83:	75 79                	jne    fe <checkEvents+0x85>
    if(caller == SENDER){
  85:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
  89:	75 2e                	jne    b9 <checkEvents+0x40>
      printf(STDOUT, "send[%d] is %s ... (pollfd[%d].events = POLLIN)\n", id, msg, id);
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  92:	8b 45 14             	mov    0x14(%ebp),%eax
  95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  a0:	c7 44 24 04 6c 0f 00 	movl   $0xf6c,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 78 0a 00 00       	call   b2c <printf>
  b4:	e9 c7 00 00 00       	jmp    180 <checkEvents+0x107>
    }else if(caller == RECEIVER){
  b9:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
  bd:	75 2e                	jne    ed <checkEvents+0x74>
      printf(STDOUT, "recv[%d] is %s ... (pollfd[%d].events = POLLIN)\n", id, msg, id);
  bf:	8b 45 08             	mov    0x8(%ebp),%eax
  c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  c6:	8b 45 14             	mov    0x14(%ebp),%eax
  c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  cd:	8b 45 08             	mov    0x8(%ebp),%eax
  d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  d4:	c7 44 24 04 a0 0f 00 	movl   $0xfa0,0x4(%esp)
  db:	00 
  dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e3:	e8 44 0a 00 00       	call   b2c <printf>
  e8:	e9 93 00 00 00       	jmp    180 <checkEvents+0x107>
    }else{
      barf("checkEvents");
  ed:	c7 04 24 d1 0f 00 00 	movl   $0xfd1,(%esp)
  f4:	e8 1d ff ff ff       	call   16 <barf>
  f9:	e9 82 00 00 00       	jmp    180 <checkEvents+0x107>
    }
  }else if(event == FREE){
  fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 102:	75 70                	jne    174 <checkEvents+0xfb>
    if(caller == SENDER){
 104:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
 108:	75 2b                	jne    135 <checkEvents+0xbc>
      printf(STDOUT, "send[%d] is %s ... (pollfd[%d].events = FREE)\n", id, msg, id);
 10a:	8b 45 08             	mov    0x8(%ebp),%eax
 10d:	89 44 24 10          	mov    %eax,0x10(%esp)
 111:	8b 45 14             	mov    0x14(%ebp),%eax
 114:	89 44 24 0c          	mov    %eax,0xc(%esp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	89 44 24 08          	mov    %eax,0x8(%esp)
 11f:	c7 44 24 04 e0 0f 00 	movl   $0xfe0,0x4(%esp)
 126:	00 
 127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12e:	e8 f9 09 00 00       	call   b2c <printf>
 133:	eb 4b                	jmp    180 <checkEvents+0x107>
    }else if(caller == RECEIVER){
 135:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
 139:	75 2b                	jne    166 <checkEvents+0xed>
      printf(STDOUT, "recv[%d] is %s ... (pollfd[%d].events = FREE)\n", id, msg, id);
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 44 24 10          	mov    %eax,0x10(%esp)
 142:	8b 45 14             	mov    0x14(%ebp),%eax
 145:	89 44 24 0c          	mov    %eax,0xc(%esp)
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	c7 44 24 04 10 10 00 	movl   $0x1010,0x4(%esp)
 157:	00 
 158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 15f:	e8 c8 09 00 00       	call   b2c <printf>
 164:	eb 1a                	jmp    180 <checkEvents+0x107>
    }else{
      barf("checkEvents");
 166:	c7 04 24 d1 0f 00 00 	movl   $0xfd1,(%esp)
 16d:	e8 a4 fe ff ff       	call   16 <barf>
 172:	eb 0c                	jmp    180 <checkEvents+0x107>
    }
  }else{
    barf("checkEvents");
 174:	c7 04 24 d1 0f 00 00 	movl   $0xfd1,(%esp)
 17b:	e8 96 fe ff ff       	call   16 <barf>
  }	      
}
 180:	c9                   	leave  
 181:	c3                   	ret    

00000182 <ready>:

/* Block until we're ready to go */
static void ready(int ready_out, int wakefd, int id, int caller)
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	83 ec 28             	sub    $0x28,%esp
  char dummy;
  dummy = 'a';
 188:	c6 45 f7 61          	movb   $0x61,-0x9(%ebp)
  // TODO: Implement myPoll function
  pollfd[id].fd = wakefd;
 18c:	8b 45 10             	mov    0x10(%ebp),%eax
 18f:	8b 55 0c             	mov    0xc(%ebp),%edx
 192:	89 14 c5 80 14 00 00 	mov    %edx,0x1480(,%eax,8)
  if(caller == RECEIVER) pollfd[id].events = POLLIN;
 199:	83 7d 14 02          	cmpl   $0x2,0x14(%ebp)
 19d:	75 0d                	jne    1ac <ready+0x2a>
 19f:	8b 45 10             	mov    0x10(%ebp),%eax
 1a2:	66 c7 04 c5 84 14 00 	movw   $0x1,0x1484(,%eax,8)
 1a9:	00 01 00 

  /* Tell them we're ready. */
  if (write(ready_out, &dummy, 1) != 1)
 1ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b3:	00 
 1b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
 1b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
 1be:	89 04 24             	mov    %eax,(%esp)
 1c1:	e8 85 07 00 00       	call   94b <write>
 1c6:	83 f8 01             	cmp    $0x1,%eax
 1c9:	74 0c                	je     1d7 <ready+0x55>
    barf("CLIENT: ready write");
 1cb:	c7 04 24 3f 10 00 00 	movl   $0x103f,(%esp)
 1d2:	e8 3f fe ff ff       	call   16 <barf>

  /* Wait for "GO" signal */
  //TODO: Polling should be re-implemented for xv6.
  //if (poll(&pollfd, 1, -1) != 1)
  //        barf("poll");
  if(caller == SENDER){
 1d7:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
 1db:	75 14                	jne    1f1 <ready+0x6f>
    if(DEBUG) checkEvents(id, pollfd[id].events, caller, "waiting");
    while(pollfd[id].events == POLLIN);
 1dd:	90                   	nop
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	0f b7 04 c5 84 14 00 	movzwl 0x1484(,%eax,8),%eax
 1e8:	00 
 1e9:	66 83 f8 01          	cmp    $0x1,%ax
 1ed:	74 ef                	je     1de <ready+0x5c>
 1ef:	eb 21                	jmp    212 <ready+0x90>
    if(DEBUG) checkEvents(id, pollfd[id].events, caller, "ready");
  }else if(caller == RECEIVER){
 1f1:	83 7d 14 02          	cmpl   $0x2,0x14(%ebp)
 1f5:	75 0f                	jne    206 <ready+0x84>
    pollfd[id].events = FREE;
 1f7:	8b 45 10             	mov    0x10(%ebp),%eax
 1fa:	66 c7 04 c5 84 14 00 	movw   $0x0,0x1484(,%eax,8)
 201:	00 00 00 
 204:	eb 0c                	jmp    212 <ready+0x90>
    //while(getticks() < TIMEOUT);
    if(DEBUG) checkEvents(id, pollfd[id].events, caller, "ready");
  }else{
    barf("Failed being ready.");
 206:	c7 04 24 53 10 00 00 	movl   $0x1053,(%esp)
 20d:	e8 04 fe ff ff       	call   16 <barf>
  }
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <sender>:
static void sender(unsigned int num_fds,
                   unsigned int out_fd[num_fds],
                   int ready_out,
                   int wakefd,
		   int id)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	53                   	push   %ebx
 218:	81 ec 94 00 00 00    	sub    $0x94,%esp
  char data[DATASIZE];
  int k;
  for(k=0; k<DATASIZE-1 ; k++){
 21e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 225:	eb 0f                	jmp    236 <sender+0x22>
    data[k] = 'b';
 227:	8d 55 80             	lea    -0x80(%ebp),%edx
 22a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22d:	01 d0                	add    %edx,%eax
 22f:	c6 00 62             	movb   $0x62,(%eax)
                   int wakefd,
		   int id)
{
  char data[DATASIZE];
  int k;
  for(k=0; k<DATASIZE-1 ; k++){
 232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 236:	83 7d f4 62          	cmpl   $0x62,-0xc(%ebp)
 23a:	7e eb                	jle    227 <sender+0x13>
    data[k] = 'b';
  }
  data[k] = '\0';
 23c:	8d 55 80             	lea    -0x80(%ebp),%edx
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	01 d0                	add    %edx,%eax
 244:	c6 00 00             	movb   $0x0,(%eax)
  
  unsigned int i, j;

  //TODO: Fix Me?
  ready(ready_out, wakefd, id, SENDER);
 247:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 24e:	00 
 24f:	8b 45 18             	mov    0x18(%ebp),%eax
 252:	89 44 24 08          	mov    %eax,0x8(%esp)
 256:	8b 45 14             	mov    0x14(%ebp),%eax
 259:	89 44 24 04          	mov    %eax,0x4(%esp)
 25d:	8b 45 10             	mov    0x10(%ebp),%eax
 260:	89 04 24             	mov    %eax,(%esp)
 263:	e8 1a ff ff ff       	call   182 <ready>

  /* Now pump to every receiver. */
  for (i = 0; i < loops; i++) {
 268:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 26f:	eb 7c                	jmp    2ed <sender+0xd9>
    for (j = 0; j < num_fds; j++) {
 271:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 278:	eb 67                	jmp    2e1 <sender+0xcd>
      int ret, done = 0;
 27a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

    again:
      ret = write(out_fd[j], data + done, sizeof(data)-done);
 281:	8b 45 e8             	mov    -0x18(%ebp),%eax
 284:	ba 64 00 00 00       	mov    $0x64,%edx
 289:	29 c2                	sub    %eax,%edx
 28b:	89 d0                	mov    %edx,%eax
 28d:	89 c2                	mov    %eax,%edx
 28f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 292:	8d 4d 80             	lea    -0x80(%ebp),%ecx
 295:	01 c1                	add    %eax,%ecx
 297:	8b 45 ec             	mov    -0x14(%ebp),%eax
 29a:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
 2a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a4:	01 d8                	add    %ebx,%eax
 2a6:	8b 00                	mov    (%eax),%eax
 2a8:	89 54 24 08          	mov    %edx,0x8(%esp)
 2ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 2b0:	89 04 24             	mov    %eax,(%esp)
 2b3:	e8 93 06 00 00       	call   94b <write>
 2b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(DEBUG) printf(STDOUT, "send[%d]: ret = %d. (%d/%d/%d)\n", id, ret, i, num_fds, loops);
      if (ret < 0)
 2bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 2bf:	79 0c                	jns    2cd <sender+0xb9>
	barf("SENDER: write");
 2c1:	c7 04 24 67 10 00 00 	movl   $0x1067,(%esp)
 2c8:	e8 49 fd ff ff       	call   16 <barf>
      done += ret;
 2cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d0:	01 45 e8             	add    %eax,-0x18(%ebp)
      if (done < sizeof(data))
 2d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2d6:	83 f8 63             	cmp    $0x63,%eax
 2d9:	77 02                	ja     2dd <sender+0xc9>
	goto again;
 2db:	eb a4                	jmp    281 <sender+0x6d>
  //TODO: Fix Me?
  ready(ready_out, wakefd, id, SENDER);

  /* Now pump to every receiver. */
  for (i = 0; i < loops; i++) {
    for (j = 0; j < num_fds; j++) {
 2dd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 2e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2e4:	3b 45 08             	cmp    0x8(%ebp),%eax
 2e7:	72 91                	jb     27a <sender+0x66>

  //TODO: Fix Me?
  ready(ready_out, wakefd, id, SENDER);

  /* Now pump to every receiver. */
  for (i = 0; i < loops; i++) {
 2e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2ed:	a1 40 14 00 00       	mov    0x1440,%eax
 2f2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 2f5:	0f 82 76 ff ff ff    	jb     271 <sender+0x5d>
      if (done < sizeof(data))
	goto again;
      if(DEBUG) printf(STDOUT, "send[%d]'s task has done. (%d/%d/%d)\n", id, ret, i, num_fds, loops);
    }
  }
}
 2fb:	81 c4 94 00 00 00    	add    $0x94,%esp
 301:	5b                   	pop    %ebx
 302:	5d                   	pop    %ebp
 303:	c3                   	ret    

00000304 <receiver>:
static void receiver(unsigned int num_packets,
                     int in_fd,
                     int ready_out,
                     int wakefd,
		     int id)
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	81 ec 88 00 00 00    	sub    $0x88,%esp
  unsigned int i;

  /* Wait for start... */
  ready(ready_out, wakefd, id, RECEIVER);
 30d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
 314:	00 
 315:	8b 45 18             	mov    0x18(%ebp),%eax
 318:	89 44 24 08          	mov    %eax,0x8(%esp)
 31c:	8b 45 14             	mov    0x14(%ebp),%eax
 31f:	89 44 24 04          	mov    %eax,0x4(%esp)
 323:	8b 45 10             	mov    0x10(%ebp),%eax
 326:	89 04 24             	mov    %eax,(%esp)
 329:	e8 54 fe ff ff       	call   182 <ready>

  /* Receive them all */
  for (i = 0; i < num_packets; i++) {
 32e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 335:	eb 51                	jmp    388 <receiver+0x84>
    char data[DATASIZE];
    int ret, done = 0;
 337:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  again:
    ret = read(in_fd, data + done, DATASIZE - done);
 33e:	b8 64 00 00 00       	mov    $0x64,%eax
 343:	2b 45 f0             	sub    -0x10(%ebp),%eax
 346:	8b 55 f0             	mov    -0x10(%ebp),%edx
 349:	8d 4d 88             	lea    -0x78(%ebp),%ecx
 34c:	01 ca                	add    %ecx,%edx
 34e:	89 44 24 08          	mov    %eax,0x8(%esp)
 352:	89 54 24 04          	mov    %edx,0x4(%esp)
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	89 04 24             	mov    %eax,(%esp)
 35c:	e8 e2 05 00 00       	call   943 <read>
 361:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(DEBUG) printf(STDOUT, "recv[%d]: ret = %d. (%d/%d)\n", id, ret, i, num_packets);
    if (ret < 0)
 364:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 368:	79 0c                	jns    376 <receiver+0x72>
      barf("SERVER: read");
 36a:	c7 04 24 75 10 00 00 	movl   $0x1075,(%esp)
 371:	e8 a0 fc ff ff       	call   16 <barf>
    done += ret;
 376:	8b 45 ec             	mov    -0x14(%ebp),%eax
 379:	01 45 f0             	add    %eax,-0x10(%ebp)
    if (done < DATASIZE){
 37c:	83 7d f0 63          	cmpl   $0x63,-0x10(%ebp)
 380:	7f 02                	jg     384 <receiver+0x80>
      goto again;
 382:	eb ba                	jmp    33e <receiver+0x3a>

  /* Wait for start... */
  ready(ready_out, wakefd, id, RECEIVER);

  /* Receive them all */
  for (i = 0; i < num_packets; i++) {
 384:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 388:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38b:	3b 45 08             	cmp    0x8(%ebp),%eax
 38e:	72 a7                	jb     337 <receiver+0x33>
    if (done < DATASIZE){
      goto again;
    }
    if(DEBUG) printf(STDOUT, "recv[%d]'s task has done. (%d/%d)\n", id, i, num_packets);
  }
}
 390:	c9                   	leave  
 391:	c3                   	ret    

00000392 <group>:

/* One group of senders and receivers */
static unsigned int group(unsigned int num_fds,
                          int ready_out,
                          int wakefd)
{
 392:	55                   	push   %ebp
 393:	89 e5                	mov    %esp,%ebp
 395:	56                   	push   %esi
 396:	53                   	push   %ebx
 397:	83 ec 40             	sub    $0x40,%esp
 39a:	89 e0                	mov    %esp,%eax
 39c:	89 c3                	mov    %eax,%ebx
  unsigned int i;
  unsigned int out_fds[num_fds];
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	89 c2                	mov    %eax,%edx
 3a3:	83 ea 01             	sub    $0x1,%edx
 3a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
 3a9:	c1 e0 02             	shl    $0x2,%eax
 3ac:	8d 50 03             	lea    0x3(%eax),%edx
 3af:	b8 10 00 00 00       	mov    $0x10,%eax
 3b4:	83 e8 01             	sub    $0x1,%eax
 3b7:	01 d0                	add    %edx,%eax
 3b9:	be 10 00 00 00       	mov    $0x10,%esi
 3be:	ba 00 00 00 00       	mov    $0x0,%edx
 3c3:	f7 f6                	div    %esi
 3c5:	6b c0 10             	imul   $0x10,%eax,%eax
 3c8:	29 c4                	sub    %eax,%esp
 3ca:	8d 44 24 14          	lea    0x14(%esp),%eax
 3ce:	83 c0 03             	add    $0x3,%eax
 3d1:	c1 e8 02             	shr    $0x2,%eax
 3d4:	c1 e0 02             	shl    $0x2,%eax
 3d7:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i = 0; i < num_fds; i++) {
 3da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e1:	e9 8e 00 00 00       	jmp    474 <group+0xe2>
    int fds[2];

    /* Create the pipe between client and server */
    fdpair(fds);
 3e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 3e9:	89 04 24             	mov    %eax,(%esp)
 3ec:	e8 4b fc ff ff       	call   3c <fdpair>

    /* Fork the receiver. */
    switch (fork()) {
 3f1:	e8 2d 05 00 00       	call   923 <fork>
 3f6:	83 f8 ff             	cmp    $0xffffffff,%eax
 3f9:	74 06                	je     401 <group+0x6f>
 3fb:	85 c0                	test   %eax,%eax
 3fd:	74 0e                	je     40d <group+0x7b>
 3ff:	eb 56                	jmp    457 <group+0xc5>
    case -1: barf("fork()");
 401:	c7 04 24 82 10 00 00 	movl   $0x1082,(%esp)
 408:	e8 09 fc ff ff       	call   16 <barf>
    case 0:
      close(fds[1]);
 40d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 410:	89 04 24             	mov    %eax,(%esp)
 413:	e8 3b 05 00 00       	call   953 <close>
      fd_count++;
 418:	a1 60 14 00 00       	mov    0x1460,%eax
 41d:	83 c0 01             	add    $0x1,%eax
 420:	a3 60 14 00 00       	mov    %eax,0x1460
      receiver(num_fds*loops, fds[0], ready_out, wakefd, i);
 425:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 428:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 42b:	a1 40 14 00 00       	mov    0x1440,%eax
 430:	0f af 45 08          	imul   0x8(%ebp),%eax
 434:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 438:	8b 4d 10             	mov    0x10(%ebp),%ecx
 43b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
 43f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 442:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 446:	89 54 24 04          	mov    %edx,0x4(%esp)
 44a:	89 04 24             	mov    %eax,(%esp)
 44d:	e8 b2 fe ff ff       	call   304 <receiver>
      exit();
 452:	e8 d4 04 00 00       	call   92b <exit>
    }

    out_fds[i] = fds[1];
 457:	8b 45 e8             	mov    -0x18(%ebp),%eax
 45a:	89 c1                	mov    %eax,%ecx
 45c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 45f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 462:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    close(fds[0]);
 465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 468:	89 04 24             	mov    %eax,(%esp)
 46b:	e8 e3 04 00 00       	call   953 <close>
                          int wakefd)
{
  unsigned int i;
  unsigned int out_fds[num_fds];

  for (i = 0; i < num_fds; i++) {
 470:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 474:	8b 45 f4             	mov    -0xc(%ebp),%eax
 477:	3b 45 08             	cmp    0x8(%ebp),%eax
 47a:	0f 82 66 ff ff ff    	jb     3e6 <group+0x54>
    out_fds[i] = fds[1];
    close(fds[0]);
  }

  /* Now we have all the fds, fork the senders */
  for (i = 0; i < num_fds; i++) {
 480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 487:	eb 59                	jmp    4e2 <group+0x150>
    switch (fork()) {
 489:	e8 95 04 00 00       	call   923 <fork>
 48e:	83 f8 ff             	cmp    $0xffffffff,%eax
 491:	74 06                	je     499 <group+0x107>
 493:	85 c0                	test   %eax,%eax
 495:	74 0e                	je     4a5 <group+0x113>
 497:	eb 45                	jmp    4de <group+0x14c>
    case -1: barf("fork()");
 499:	c7 04 24 82 10 00 00 	movl   $0x1082,(%esp)
 4a0:	e8 71 fb ff ff       	call   16 <barf>
    case 0:
      fd_count += 2;
 4a5:	a1 60 14 00 00       	mov    0x1460,%eax
 4aa:	83 c0 02             	add    $0x2,%eax
 4ad:	a3 60 14 00 00       	mov    %eax,0x1460
      sender(num_fds, out_fds, ready_out, wakefd, i);
 4b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b8:	89 54 24 10          	mov    %edx,0x10(%esp)
 4bc:	8b 55 10             	mov    0x10(%ebp),%edx
 4bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
 4c3:	8b 55 0c             	mov    0xc(%ebp),%edx
 4c6:	89 54 24 08          	mov    %edx,0x8(%esp)
 4ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ce:	8b 45 08             	mov    0x8(%ebp),%eax
 4d1:	89 04 24             	mov    %eax,(%esp)
 4d4:	e8 3b fd ff ff       	call   214 <sender>
      exit();
 4d9:	e8 4d 04 00 00       	call   92b <exit>
    out_fds[i] = fds[1];
    close(fds[0]);
  }

  /* Now we have all the fds, fork the senders */
  for (i = 0; i < num_fds; i++) {
 4de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	3b 45 08             	cmp    0x8(%ebp),%eax
 4e8:	72 9f                	jb     489 <group+0xf7>
      exit();
    }
  }

  /* Close the fds we have left */
  for (i = 0; i < num_fds; i++)
 4ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4f1:	eb 15                	jmp    508 <group+0x176>
    close(out_fds[i]);
 4f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4f9:	8b 04 90             	mov    (%eax,%edx,4),%eax
 4fc:	89 04 24             	mov    %eax,(%esp)
 4ff:	e8 4f 04 00 00       	call   953 <close>
      exit();
    }
  }

  /* Close the fds we have left */
  for (i = 0; i < num_fds; i++)
 504:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	3b 45 08             	cmp    0x8(%ebp),%eax
 50e:	72 e3                	jb     4f3 <group+0x161>
    close(out_fds[i]);

  /* Reap number of children to reap */
  return num_fds * 2;
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	01 c0                	add    %eax,%eax
 515:	89 dc                	mov    %ebx,%esp
}
 517:	8d 65 f8             	lea    -0x8(%ebp),%esp
 51a:	5b                   	pop    %ebx
 51b:	5e                   	pop    %esi
 51c:	5d                   	pop    %ebp
 51d:	c3                   	ret    

0000051e <main>:

int main(int argc, char *argv[])
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	53                   	push   %ebx
 522:	83 e4 f0             	and    $0xfffffff0,%esp
 525:	83 ec 50             	sub    $0x50,%esp
  unsigned int i, num_groups, total_children;
  //struct timeval start, stop, diff;
  unsigned long long start=0, stop=0, diff=0;
 528:	c7 44 24 40 00 00 00 	movl   $0x0,0x40(%esp)
 52f:	00 
 530:	c7 44 24 44 00 00 00 	movl   $0x0,0x44(%esp)
 537:	00 
 538:	c7 44 24 38 00 00 00 	movl   $0x0,0x38(%esp)
 53f:	00 
 540:	c7 44 24 3c 00 00 00 	movl   $0x0,0x3c(%esp)
 547:	00 
 548:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
 54f:	00 
 550:	c7 44 24 34 00 00 00 	movl   $0x0,0x34(%esp)
 557:	00 
  // NOTE: More than 8 causes error due to num of fds.
  unsigned int num_fds = NUM_FDS;  // Original this is 20
 558:	c7 44 24 2c 08 00 00 	movl   $0x8,0x2c(%esp)
 55f:	00 
    use_pipes = 1;
    argc--;
    argv++;
    }
  */
  use_pipes = 1;
 560:	c7 05 44 14 00 00 01 	movl   $0x1,0x1444
 567:	00 00 00 
  argc--;
 56a:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
  argv++;
 56e:	83 45 0c 04          	addl   $0x4,0xc(%ebp)

  //if (argc != 2 || (num_groups = atoi(argv[1])) == 0)
  //        barf("Usage: hackbench [-pipe] <num groups>\n");

  // NOTE: More than 3 causes error due to num of processes.
  num_groups = NUM_GROUPS; // TODO: This may seriously be considered.
 572:	c7 44 24 28 02 00 00 	movl   $0x2,0x28(%esp)
 579:	00 

  fdpair(readyfds);
 57a:	8d 44 24 20          	lea    0x20(%esp),%eax
 57e:	89 04 24             	mov    %eax,(%esp)
 581:	e8 b6 fa ff ff       	call   3c <fdpair>
  fdpair(wakefds);
 586:	8d 44 24 18          	lea    0x18(%esp),%eax
 58a:	89 04 24             	mov    %eax,(%esp)
 58d:	e8 aa fa ff ff       	call   3c <fdpair>

  total_children = 0;
 592:	c7 44 24 48 00 00 00 	movl   $0x0,0x48(%esp)
 599:	00 
  for (i = 0; i < num_groups; i++)
 59a:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 5a1:	00 
 5a2:	eb 25                	jmp    5c9 <main+0xab>
    total_children += group(num_fds, readyfds[1], wakefds[0]);
 5a4:	8b 54 24 18          	mov    0x18(%esp),%edx
 5a8:	8b 44 24 24          	mov    0x24(%esp),%eax
 5ac:	89 54 24 08          	mov    %edx,0x8(%esp)
 5b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
 5b8:	89 04 24             	mov    %eax,(%esp)
 5bb:	e8 d2 fd ff ff       	call   392 <group>
 5c0:	01 44 24 48          	add    %eax,0x48(%esp)

  fdpair(readyfds);
  fdpair(wakefds);

  total_children = 0;
  for (i = 0; i < num_groups; i++)
 5c4:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 5c9:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 5cd:	3b 44 24 28          	cmp    0x28(%esp),%eax
 5d1:	72 d1                	jb     5a4 <main+0x86>
    total_children += group(num_fds, readyfds[1], wakefds[0]);

  /* Wait for everyone to be ready */
  for (i = 0; i < total_children; i++)
 5d3:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 5da:	00 
 5db:	eb 32                	jmp    60f <main+0xf1>
    if (read(readyfds[0], &dummy, 1) != 1)
 5dd:	8b 44 24 20          	mov    0x20(%esp),%eax
 5e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5e8:	00 
 5e9:	8d 54 24 17          	lea    0x17(%esp),%edx
 5ed:	89 54 24 04          	mov    %edx,0x4(%esp)
 5f1:	89 04 24             	mov    %eax,(%esp)
 5f4:	e8 4a 03 00 00       	call   943 <read>
 5f9:	83 f8 01             	cmp    $0x1,%eax
 5fc:	74 0c                	je     60a <main+0xec>
      barf("Reading for readyfds");
 5fe:	c7 04 24 89 10 00 00 	movl   $0x1089,(%esp)
 605:	e8 0c fa ff ff       	call   16 <barf>
  total_children = 0;
  for (i = 0; i < num_groups; i++)
    total_children += group(num_fds, readyfds[1], wakefds[0]);

  /* Wait for everyone to be ready */
  for (i = 0; i < total_children; i++)
 60a:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 60f:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 613:	3b 44 24 48          	cmp    0x48(%esp),%eax
 617:	72 c4                	jb     5dd <main+0xbf>
    if (read(readyfds[0], &dummy, 1) != 1)
      barf("Reading for readyfds");

  //gettimeofday(&start, NULL);
  start = rdtsc();
 619:	e8 e2 f9 ff ff       	call   0 <rdtsc>
 61e:	89 44 24 40          	mov    %eax,0x40(%esp)
 622:	89 54 24 44          	mov    %edx,0x44(%esp)
  if(DEBUG) printf(STDOUT, "Start Watching Time ...\n");
  

  /* Kick them off */
  if (write(wakefds[1], &dummy, 1) != 1)
 626:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 62a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 631:	00 
 632:	8d 54 24 17          	lea    0x17(%esp),%edx
 636:	89 54 24 04          	mov    %edx,0x4(%esp)
 63a:	89 04 24             	mov    %eax,(%esp)
 63d:	e8 09 03 00 00       	call   94b <write>
 642:	83 f8 01             	cmp    $0x1,%eax
 645:	74 0c                	je     653 <main+0x135>
    barf("Writing to start them");
 647:	c7 04 24 9e 10 00 00 	movl   $0x109e,(%esp)
 64e:	e8 c3 f9 ff ff       	call   16 <barf>

  /* Reap them all */
  //TODO: Fix different specifications between xv6 and Linux
  for (i = 0; i < total_children; i++) {
 653:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 65a:	00 
 65b:	eb 0a                	jmp    667 <main+0x149>
    //int status;
    //wait(&status); // TODO: Too Many Arguments???
    wait(); // Waiting for that all child's tasks finish.
 65d:	e8 d1 02 00 00       	call   933 <wait>
  if (write(wakefds[1], &dummy, 1) != 1)
    barf("Writing to start them");

  /* Reap them all */
  //TODO: Fix different specifications between xv6 and Linux
  for (i = 0; i < total_children; i++) {
 662:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 667:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 66b:	3b 44 24 48          	cmp    0x48(%esp),%eax
 66f:	72 ec                	jb     65d <main+0x13f>
    // TODO: What's WIFEXITED ???
    //if (!WIFEXITED(status))
    //  exit();
  }
  
  stop = rdtsc();
 671:	e8 8a f9 ff ff       	call   0 <rdtsc>
 676:	89 44 24 38          	mov    %eax,0x38(%esp)
 67a:	89 54 24 3c          	mov    %edx,0x3c(%esp)
  if(DEBUG) printf(STDOUT, "Stop Watching Time ...\n");
  diff = stop - start;
 67e:	8b 4c 24 40          	mov    0x40(%esp),%ecx
 682:	8b 5c 24 44          	mov    0x44(%esp),%ebx
 686:	8b 44 24 38          	mov    0x38(%esp),%eax
 68a:	8b 54 24 3c          	mov    0x3c(%esp),%edx
 68e:	29 c8                	sub    %ecx,%eax
 690:	19 da                	sbb    %ebx,%edx
 692:	89 44 24 30          	mov    %eax,0x30(%esp)
 696:	89 54 24 34          	mov    %edx,0x34(%esp)

  /* Print time... */
  printf(STDOUT, "Time: 0x%l [ticks]\n", diff);
 69a:	8b 44 24 30          	mov    0x30(%esp),%eax
 69e:	8b 54 24 34          	mov    0x34(%esp),%edx
 6a2:	89 44 24 08          	mov    %eax,0x8(%esp)
 6a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
 6aa:	c7 44 24 04 b4 10 00 	movl   $0x10b4,0x4(%esp)
 6b1:	00 
 6b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 6b9:	e8 6e 04 00 00       	call   b2c <printf>
  if(DEBUG) printf(STDOUT, "fd_count = %d\n", fd_count);
  exit();
 6be:	e8 68 02 00 00       	call   92b <exit>

000006c3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	57                   	push   %edi
 6c7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 6c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 6cb:	8b 55 10             	mov    0x10(%ebp),%edx
 6ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d1:	89 cb                	mov    %ecx,%ebx
 6d3:	89 df                	mov    %ebx,%edi
 6d5:	89 d1                	mov    %edx,%ecx
 6d7:	fc                   	cld    
 6d8:	f3 aa                	rep stos %al,%es:(%edi)
 6da:	89 ca                	mov    %ecx,%edx
 6dc:	89 fb                	mov    %edi,%ebx
 6de:	89 5d 08             	mov    %ebx,0x8(%ebp)
 6e1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 6e4:	5b                   	pop    %ebx
 6e5:	5f                   	pop    %edi
 6e6:	5d                   	pop    %ebp
 6e7:	c3                   	ret    

000006e8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 6e8:	55                   	push   %ebp
 6e9:	89 e5                	mov    %esp,%ebp
 6eb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 6f4:	90                   	nop
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	8d 50 01             	lea    0x1(%eax),%edx
 6fb:	89 55 08             	mov    %edx,0x8(%ebp)
 6fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 701:	8d 4a 01             	lea    0x1(%edx),%ecx
 704:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 707:	0f b6 12             	movzbl (%edx),%edx
 70a:	88 10                	mov    %dl,(%eax)
 70c:	0f b6 00             	movzbl (%eax),%eax
 70f:	84 c0                	test   %al,%al
 711:	75 e2                	jne    6f5 <strcpy+0xd>
    ;
  return os;
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 716:	c9                   	leave  
 717:	c3                   	ret    

00000718 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 718:	55                   	push   %ebp
 719:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 71b:	eb 08                	jmp    725 <strcmp+0xd>
    p++, q++;
 71d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 721:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	0f b6 00             	movzbl (%eax),%eax
 72b:	84 c0                	test   %al,%al
 72d:	74 10                	je     73f <strcmp+0x27>
 72f:	8b 45 08             	mov    0x8(%ebp),%eax
 732:	0f b6 10             	movzbl (%eax),%edx
 735:	8b 45 0c             	mov    0xc(%ebp),%eax
 738:	0f b6 00             	movzbl (%eax),%eax
 73b:	38 c2                	cmp    %al,%dl
 73d:	74 de                	je     71d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f b6 d0             	movzbl %al,%edx
 748:	8b 45 0c             	mov    0xc(%ebp),%eax
 74b:	0f b6 00             	movzbl (%eax),%eax
 74e:	0f b6 c0             	movzbl %al,%eax
 751:	29 c2                	sub    %eax,%edx
 753:	89 d0                	mov    %edx,%eax
}
 755:	5d                   	pop    %ebp
 756:	c3                   	ret    

00000757 <strlen>:

uint
strlen(char *s)
{
 757:	55                   	push   %ebp
 758:	89 e5                	mov    %esp,%ebp
 75a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 75d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 764:	eb 04                	jmp    76a <strlen+0x13>
 766:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 76a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	01 d0                	add    %edx,%eax
 772:	0f b6 00             	movzbl (%eax),%eax
 775:	84 c0                	test   %al,%al
 777:	75 ed                	jne    766 <strlen+0xf>
    ;
  return n;
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 77c:	c9                   	leave  
 77d:	c3                   	ret    

0000077e <memset>:

void*
memset(void *dst, int c, uint n)
{
 77e:	55                   	push   %ebp
 77f:	89 e5                	mov    %esp,%ebp
 781:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 784:	8b 45 10             	mov    0x10(%ebp),%eax
 787:	89 44 24 08          	mov    %eax,0x8(%esp)
 78b:	8b 45 0c             	mov    0xc(%ebp),%eax
 78e:	89 44 24 04          	mov    %eax,0x4(%esp)
 792:	8b 45 08             	mov    0x8(%ebp),%eax
 795:	89 04 24             	mov    %eax,(%esp)
 798:	e8 26 ff ff ff       	call   6c3 <stosb>
  return dst;
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7a0:	c9                   	leave  
 7a1:	c3                   	ret    

000007a2 <strchr>:

char*
strchr(const char *s, char c)
{
 7a2:	55                   	push   %ebp
 7a3:	89 e5                	mov    %esp,%ebp
 7a5:	83 ec 04             	sub    $0x4,%esp
 7a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ab:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 7ae:	eb 14                	jmp    7c4 <strchr+0x22>
    if(*s == c)
 7b0:	8b 45 08             	mov    0x8(%ebp),%eax
 7b3:	0f b6 00             	movzbl (%eax),%eax
 7b6:	3a 45 fc             	cmp    -0x4(%ebp),%al
 7b9:	75 05                	jne    7c0 <strchr+0x1e>
      return (char*)s;
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	eb 13                	jmp    7d3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 7c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7c4:	8b 45 08             	mov    0x8(%ebp),%eax
 7c7:	0f b6 00             	movzbl (%eax),%eax
 7ca:	84 c0                	test   %al,%al
 7cc:	75 e2                	jne    7b0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 7ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
 7d3:	c9                   	leave  
 7d4:	c3                   	ret    

000007d5 <gets>:

char*
gets(char *buf, int max)
{
 7d5:	55                   	push   %ebp
 7d6:	89 e5                	mov    %esp,%ebp
 7d8:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 7e2:	eb 4c                	jmp    830 <gets+0x5b>
    cc = read(0, &c, 1);
 7e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7eb:	00 
 7ec:	8d 45 ef             	lea    -0x11(%ebp),%eax
 7ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7fa:	e8 44 01 00 00       	call   943 <read>
 7ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 802:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 806:	7f 02                	jg     80a <gets+0x35>
      break;
 808:	eb 31                	jmp    83b <gets+0x66>
    buf[i++] = c;
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	8d 50 01             	lea    0x1(%eax),%edx
 810:	89 55 f4             	mov    %edx,-0xc(%ebp)
 813:	89 c2                	mov    %eax,%edx
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	01 c2                	add    %eax,%edx
 81a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 81e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 820:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 824:	3c 0a                	cmp    $0xa,%al
 826:	74 13                	je     83b <gets+0x66>
 828:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 82c:	3c 0d                	cmp    $0xd,%al
 82e:	74 0b                	je     83b <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	83 c0 01             	add    $0x1,%eax
 836:	3b 45 0c             	cmp    0xc(%ebp),%eax
 839:	7c a9                	jl     7e4 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 83b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 83e:	8b 45 08             	mov    0x8(%ebp),%eax
 841:	01 d0                	add    %edx,%eax
 843:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 846:	8b 45 08             	mov    0x8(%ebp),%eax
}
 849:	c9                   	leave  
 84a:	c3                   	ret    

0000084b <stat>:

int
stat(char *n, struct stat *st)
{
 84b:	55                   	push   %ebp
 84c:	89 e5                	mov    %esp,%ebp
 84e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 851:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 858:	00 
 859:	8b 45 08             	mov    0x8(%ebp),%eax
 85c:	89 04 24             	mov    %eax,(%esp)
 85f:	e8 07 01 00 00       	call   96b <open>
 864:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 867:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 86b:	79 07                	jns    874 <stat+0x29>
    return -1;
 86d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 872:	eb 23                	jmp    897 <stat+0x4c>
  r = fstat(fd, st);
 874:	8b 45 0c             	mov    0xc(%ebp),%eax
 877:	89 44 24 04          	mov    %eax,0x4(%esp)
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	89 04 24             	mov    %eax,(%esp)
 881:	e8 fd 00 00 00       	call   983 <fstat>
 886:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	89 04 24             	mov    %eax,(%esp)
 88f:	e8 bf 00 00 00       	call   953 <close>
  return r;
 894:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <atoi>:

int
atoi(const char *s)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 89f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 8a6:	eb 25                	jmp    8cd <atoi+0x34>
    n = n*10 + *s++ - '0';
 8a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 8ab:	89 d0                	mov    %edx,%eax
 8ad:	c1 e0 02             	shl    $0x2,%eax
 8b0:	01 d0                	add    %edx,%eax
 8b2:	01 c0                	add    %eax,%eax
 8b4:	89 c1                	mov    %eax,%ecx
 8b6:	8b 45 08             	mov    0x8(%ebp),%eax
 8b9:	8d 50 01             	lea    0x1(%eax),%edx
 8bc:	89 55 08             	mov    %edx,0x8(%ebp)
 8bf:	0f b6 00             	movzbl (%eax),%eax
 8c2:	0f be c0             	movsbl %al,%eax
 8c5:	01 c8                	add    %ecx,%eax
 8c7:	83 e8 30             	sub    $0x30,%eax
 8ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8cd:	8b 45 08             	mov    0x8(%ebp),%eax
 8d0:	0f b6 00             	movzbl (%eax),%eax
 8d3:	3c 2f                	cmp    $0x2f,%al
 8d5:	7e 0a                	jle    8e1 <atoi+0x48>
 8d7:	8b 45 08             	mov    0x8(%ebp),%eax
 8da:	0f b6 00             	movzbl (%eax),%eax
 8dd:	3c 39                	cmp    $0x39,%al
 8df:	7e c7                	jle    8a8 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 8e4:	c9                   	leave  
 8e5:	c3                   	ret    

000008e6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 8e6:	55                   	push   %ebp
 8e7:	89 e5                	mov    %esp,%ebp
 8e9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 8ec:	8b 45 08             	mov    0x8(%ebp),%eax
 8ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 8f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8f8:	eb 17                	jmp    911 <memmove+0x2b>
    *dst++ = *src++;
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	8d 50 01             	lea    0x1(%eax),%edx
 900:	89 55 fc             	mov    %edx,-0x4(%ebp)
 903:	8b 55 f8             	mov    -0x8(%ebp),%edx
 906:	8d 4a 01             	lea    0x1(%edx),%ecx
 909:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 90c:	0f b6 12             	movzbl (%edx),%edx
 90f:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 911:	8b 45 10             	mov    0x10(%ebp),%eax
 914:	8d 50 ff             	lea    -0x1(%eax),%edx
 917:	89 55 10             	mov    %edx,0x10(%ebp)
 91a:	85 c0                	test   %eax,%eax
 91c:	7f dc                	jg     8fa <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 91e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 921:	c9                   	leave  
 922:	c3                   	ret    

00000923 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 923:	b8 01 00 00 00       	mov    $0x1,%eax
 928:	cd 40                	int    $0x40
 92a:	c3                   	ret    

0000092b <exit>:
SYSCALL(exit)
 92b:	b8 02 00 00 00       	mov    $0x2,%eax
 930:	cd 40                	int    $0x40
 932:	c3                   	ret    

00000933 <wait>:
SYSCALL(wait)
 933:	b8 03 00 00 00       	mov    $0x3,%eax
 938:	cd 40                	int    $0x40
 93a:	c3                   	ret    

0000093b <pipe>:
SYSCALL(pipe)
 93b:	b8 04 00 00 00       	mov    $0x4,%eax
 940:	cd 40                	int    $0x40
 942:	c3                   	ret    

00000943 <read>:
SYSCALL(read)
 943:	b8 05 00 00 00       	mov    $0x5,%eax
 948:	cd 40                	int    $0x40
 94a:	c3                   	ret    

0000094b <write>:
SYSCALL(write)
 94b:	b8 10 00 00 00       	mov    $0x10,%eax
 950:	cd 40                	int    $0x40
 952:	c3                   	ret    

00000953 <close>:
SYSCALL(close)
 953:	b8 15 00 00 00       	mov    $0x15,%eax
 958:	cd 40                	int    $0x40
 95a:	c3                   	ret    

0000095b <kill>:
SYSCALL(kill)
 95b:	b8 06 00 00 00       	mov    $0x6,%eax
 960:	cd 40                	int    $0x40
 962:	c3                   	ret    

00000963 <exec>:
SYSCALL(exec)
 963:	b8 07 00 00 00       	mov    $0x7,%eax
 968:	cd 40                	int    $0x40
 96a:	c3                   	ret    

0000096b <open>:
SYSCALL(open)
 96b:	b8 0f 00 00 00       	mov    $0xf,%eax
 970:	cd 40                	int    $0x40
 972:	c3                   	ret    

00000973 <mknod>:
SYSCALL(mknod)
 973:	b8 11 00 00 00       	mov    $0x11,%eax
 978:	cd 40                	int    $0x40
 97a:	c3                   	ret    

0000097b <unlink>:
SYSCALL(unlink)
 97b:	b8 12 00 00 00       	mov    $0x12,%eax
 980:	cd 40                	int    $0x40
 982:	c3                   	ret    

00000983 <fstat>:
SYSCALL(fstat)
 983:	b8 08 00 00 00       	mov    $0x8,%eax
 988:	cd 40                	int    $0x40
 98a:	c3                   	ret    

0000098b <link>:
SYSCALL(link)
 98b:	b8 13 00 00 00       	mov    $0x13,%eax
 990:	cd 40                	int    $0x40
 992:	c3                   	ret    

00000993 <mkdir>:
SYSCALL(mkdir)
 993:	b8 14 00 00 00       	mov    $0x14,%eax
 998:	cd 40                	int    $0x40
 99a:	c3                   	ret    

0000099b <chdir>:
SYSCALL(chdir)
 99b:	b8 09 00 00 00       	mov    $0x9,%eax
 9a0:	cd 40                	int    $0x40
 9a2:	c3                   	ret    

000009a3 <dup>:
SYSCALL(dup)
 9a3:	b8 0a 00 00 00       	mov    $0xa,%eax
 9a8:	cd 40                	int    $0x40
 9aa:	c3                   	ret    

000009ab <getpid>:
SYSCALL(getpid)
 9ab:	b8 0b 00 00 00       	mov    $0xb,%eax
 9b0:	cd 40                	int    $0x40
 9b2:	c3                   	ret    

000009b3 <sbrk>:
SYSCALL(sbrk)
 9b3:	b8 0c 00 00 00       	mov    $0xc,%eax
 9b8:	cd 40                	int    $0x40
 9ba:	c3                   	ret    

000009bb <sleep>:
SYSCALL(sleep)
 9bb:	b8 0d 00 00 00       	mov    $0xd,%eax
 9c0:	cd 40                	int    $0x40
 9c2:	c3                   	ret    

000009c3 <uptime>:
SYSCALL(uptime)
 9c3:	b8 0e 00 00 00       	mov    $0xe,%eax
 9c8:	cd 40                	int    $0x40
 9ca:	c3                   	ret    

000009cb <gettime>:
SYSCALL(gettime)
 9cb:	b8 16 00 00 00       	mov    $0x16,%eax
 9d0:	cd 40                	int    $0x40
 9d2:	c3                   	ret    

000009d3 <settickets>:
SYSCALL(settickets)
 9d3:	b8 17 00 00 00       	mov    $0x17,%eax
 9d8:	cd 40                	int    $0x40
 9da:	c3                   	ret    

000009db <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 9db:	55                   	push   %ebp
 9dc:	89 e5                	mov    %esp,%ebp
 9de:	83 ec 18             	sub    $0x18,%esp
 9e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 9e4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 9e7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 9ee:	00 
 9ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f6:	8b 45 08             	mov    0x8(%ebp),%eax
 9f9:	89 04 24             	mov    %eax,(%esp)
 9fc:	e8 4a ff ff ff       	call   94b <write>
}
 a01:	c9                   	leave  
 a02:	c3                   	ret    

00000a03 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a03:	55                   	push   %ebp
 a04:	89 e5                	mov    %esp,%ebp
 a06:	56                   	push   %esi
 a07:	53                   	push   %ebx
 a08:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a0b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a12:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a16:	74 17                	je     a2f <printint+0x2c>
 a18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a1c:	79 11                	jns    a2f <printint+0x2c>
    neg = 1;
 a1e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a25:	8b 45 0c             	mov    0xc(%ebp),%eax
 a28:	f7 d8                	neg    %eax
 a2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a2d:	eb 06                	jmp    a35 <printint+0x32>
  } else {
    x = xx;
 a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
 a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a3c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 a3f:	8d 41 01             	lea    0x1(%ecx),%eax
 a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a48:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4b:	ba 00 00 00 00       	mov    $0x0,%edx
 a50:	f7 f3                	div    %ebx
 a52:	89 d0                	mov    %edx,%eax
 a54:	0f b6 80 48 14 00 00 	movzbl 0x1448(%eax),%eax
 a5b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 a5f:	8b 75 10             	mov    0x10(%ebp),%esi
 a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a65:	ba 00 00 00 00       	mov    $0x0,%edx
 a6a:	f7 f6                	div    %esi
 a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a73:	75 c7                	jne    a3c <printint+0x39>
  if(neg)
 a75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a79:	74 10                	je     a8b <printint+0x88>
    buf[i++] = '-';
 a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7e:	8d 50 01             	lea    0x1(%eax),%edx
 a81:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a84:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 a89:	eb 1f                	jmp    aaa <printint+0xa7>
 a8b:	eb 1d                	jmp    aaa <printint+0xa7>
    putc(fd, buf[i]);
 a8d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a93:	01 d0                	add    %edx,%eax
 a95:	0f b6 00             	movzbl (%eax),%eax
 a98:	0f be c0             	movsbl %al,%eax
 a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a9f:	8b 45 08             	mov    0x8(%ebp),%eax
 aa2:	89 04 24             	mov    %eax,(%esp)
 aa5:	e8 31 ff ff ff       	call   9db <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 aaa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 aae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ab2:	79 d9                	jns    a8d <printint+0x8a>
    putc(fd, buf[i]);
}
 ab4:	83 c4 30             	add    $0x30,%esp
 ab7:	5b                   	pop    %ebx
 ab8:	5e                   	pop    %esi
 ab9:	5d                   	pop    %ebp
 aba:	c3                   	ret    

00000abb <printlong>:

static void
printlong(int fd, unsigned long long xx, int base, int sgn)
{
 abb:	55                   	push   %ebp
 abc:	89 e5                	mov    %esp,%ebp
 abe:	83 ec 38             	sub    $0x38,%esp
 ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
 ac4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 ac7:	8b 45 10             	mov    0x10(%ebp),%eax
 aca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
 acd:	8b 45 e0             	mov    -0x20(%ebp),%eax
 ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 ad3:	89 d0                	mov    %edx,%eax
 ad5:	31 d2                	xor    %edx,%edx
 ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
 ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
 add:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(fd, upper, 16, 0);
 ae0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae4:	74 22                	je     b08 <printlong+0x4d>
 ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 af0:	00 
 af1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 af8:	00 
 af9:	89 44 24 04          	mov    %eax,0x4(%esp)
 afd:	8b 45 08             	mov    0x8(%ebp),%eax
 b00:	89 04 24             	mov    %eax,(%esp)
 b03:	e8 fb fe ff ff       	call   a03 <printint>
    printint(fd, lower, 16, 0);
 b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b12:	00 
 b13:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 b1a:	00 
 b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
 b1f:	8b 45 08             	mov    0x8(%ebp),%eax
 b22:	89 04 24             	mov    %eax,(%esp)
 b25:	e8 d9 fe ff ff       	call   a03 <printint>
}
 b2a:	c9                   	leave  
 b2b:	c3                   	ret    

00000b2c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
// bdg 10/05/2015: Add %l
void
printf(int fd, char *fmt, ...)
{
 b2c:	55                   	push   %ebp
 b2d:	89 e5                	mov    %esp,%ebp
 b2f:	83 ec 48             	sub    $0x48,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 b32:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 b39:	8d 45 0c             	lea    0xc(%ebp),%eax
 b3c:	83 c0 04             	add    $0x4,%eax
 b3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 b42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 b49:	e9 ba 01 00 00       	jmp    d08 <printf+0x1dc>
    c = fmt[i] & 0xff;
 b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
 b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b54:	01 d0                	add    %edx,%eax
 b56:	0f b6 00             	movzbl (%eax),%eax
 b59:	0f be c0             	movsbl %al,%eax
 b5c:	25 ff 00 00 00       	and    $0xff,%eax
 b61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b68:	75 2c                	jne    b96 <printf+0x6a>
      if(c == '%'){
 b6a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b6e:	75 0c                	jne    b7c <printf+0x50>
        state = '%';
 b70:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b77:	e9 88 01 00 00       	jmp    d04 <printf+0x1d8>
      } else {
        putc(fd, c);
 b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b7f:	0f be c0             	movsbl %al,%eax
 b82:	89 44 24 04          	mov    %eax,0x4(%esp)
 b86:	8b 45 08             	mov    0x8(%ebp),%eax
 b89:	89 04 24             	mov    %eax,(%esp)
 b8c:	e8 4a fe ff ff       	call   9db <putc>
 b91:	e9 6e 01 00 00       	jmp    d04 <printf+0x1d8>
      }
    } else if(state == '%'){
 b96:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b9a:	0f 85 64 01 00 00    	jne    d04 <printf+0x1d8>
      if(c == 'd'){
 ba0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 ba4:	75 2d                	jne    bd3 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 ba6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ba9:	8b 00                	mov    (%eax),%eax
 bab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 bb2:	00 
 bb3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 bba:	00 
 bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
 bbf:	8b 45 08             	mov    0x8(%ebp),%eax
 bc2:	89 04 24             	mov    %eax,(%esp)
 bc5:	e8 39 fe ff ff       	call   a03 <printint>
        ap++;
 bca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bce:	e9 2a 01 00 00       	jmp    cfd <printf+0x1d1>
      } else if(c == 'l') {
 bd3:	83 7d e4 6c          	cmpl   $0x6c,-0x1c(%ebp)
 bd7:	75 38                	jne    c11 <printf+0xe5>
        printlong(fd, *(unsigned long long *)ap, 10, 0);
 bd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bdc:	8b 50 04             	mov    0x4(%eax),%edx
 bdf:	8b 00                	mov    (%eax),%eax
 be1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 be8:	00 
 be9:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
 bf0:	00 
 bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
 bf5:	89 54 24 08          	mov    %edx,0x8(%esp)
 bf9:	8b 45 08             	mov    0x8(%ebp),%eax
 bfc:	89 04 24             	mov    %eax,(%esp)
 bff:	e8 b7 fe ff ff       	call   abb <printlong>
        // long longs take up 2 argument slots
        ap++;
 c04:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        ap++;
 c08:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c0c:	e9 ec 00 00 00       	jmp    cfd <printf+0x1d1>
      } else if(c == 'x' || c == 'p'){
 c11:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 c15:	74 06                	je     c1d <printf+0xf1>
 c17:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 c1b:	75 2d                	jne    c4a <printf+0x11e>
        printint(fd, *ap, 16, 0);
 c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c20:	8b 00                	mov    (%eax),%eax
 c22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 c29:	00 
 c2a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 c31:	00 
 c32:	89 44 24 04          	mov    %eax,0x4(%esp)
 c36:	8b 45 08             	mov    0x8(%ebp),%eax
 c39:	89 04 24             	mov    %eax,(%esp)
 c3c:	e8 c2 fd ff ff       	call   a03 <printint>
        ap++;
 c41:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c45:	e9 b3 00 00 00       	jmp    cfd <printf+0x1d1>
      } else if(c == 's'){
 c4a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 c4e:	75 45                	jne    c95 <printf+0x169>
        s = (char*)*ap;
 c50:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c53:	8b 00                	mov    (%eax),%eax
 c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 c58:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c60:	75 09                	jne    c6b <printf+0x13f>
          s = "(null)";
 c62:	c7 45 f4 c8 10 00 00 	movl   $0x10c8,-0xc(%ebp)
        while(*s != 0){
 c69:	eb 1e                	jmp    c89 <printf+0x15d>
 c6b:	eb 1c                	jmp    c89 <printf+0x15d>
          putc(fd, *s);
 c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c70:	0f b6 00             	movzbl (%eax),%eax
 c73:	0f be c0             	movsbl %al,%eax
 c76:	89 44 24 04          	mov    %eax,0x4(%esp)
 c7a:	8b 45 08             	mov    0x8(%ebp),%eax
 c7d:	89 04 24             	mov    %eax,(%esp)
 c80:	e8 56 fd ff ff       	call   9db <putc>
          s++;
 c85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8c:	0f b6 00             	movzbl (%eax),%eax
 c8f:	84 c0                	test   %al,%al
 c91:	75 da                	jne    c6d <printf+0x141>
 c93:	eb 68                	jmp    cfd <printf+0x1d1>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c95:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 c99:	75 1d                	jne    cb8 <printf+0x18c>
        putc(fd, *ap);
 c9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c9e:	8b 00                	mov    (%eax),%eax
 ca0:	0f be c0             	movsbl %al,%eax
 ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
 ca7:	8b 45 08             	mov    0x8(%ebp),%eax
 caa:	89 04 24             	mov    %eax,(%esp)
 cad:	e8 29 fd ff ff       	call   9db <putc>
        ap++;
 cb2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 cb6:	eb 45                	jmp    cfd <printf+0x1d1>
      } else if(c == '%'){
 cb8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 cbc:	75 17                	jne    cd5 <printf+0x1a9>
        putc(fd, c);
 cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 cc1:	0f be c0             	movsbl %al,%eax
 cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
 cc8:	8b 45 08             	mov    0x8(%ebp),%eax
 ccb:	89 04 24             	mov    %eax,(%esp)
 cce:	e8 08 fd ff ff       	call   9db <putc>
 cd3:	eb 28                	jmp    cfd <printf+0x1d1>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 cd5:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 cdc:	00 
 cdd:	8b 45 08             	mov    0x8(%ebp),%eax
 ce0:	89 04 24             	mov    %eax,(%esp)
 ce3:	e8 f3 fc ff ff       	call   9db <putc>
        putc(fd, c);
 ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ceb:	0f be c0             	movsbl %al,%eax
 cee:	89 44 24 04          	mov    %eax,0x4(%esp)
 cf2:	8b 45 08             	mov    0x8(%ebp),%eax
 cf5:	89 04 24             	mov    %eax,(%esp)
 cf8:	e8 de fc ff ff       	call   9db <putc>
      }
      state = 0;
 cfd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 d04:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 d08:	8b 55 0c             	mov    0xc(%ebp),%edx
 d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d0e:	01 d0                	add    %edx,%eax
 d10:	0f b6 00             	movzbl (%eax),%eax
 d13:	84 c0                	test   %al,%al
 d15:	0f 85 33 fe ff ff    	jne    b4e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 d1b:	c9                   	leave  
 d1c:	c3                   	ret    

00000d1d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d1d:	55                   	push   %ebp
 d1e:	89 e5                	mov    %esp,%ebp
 d20:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d23:	8b 45 08             	mov    0x8(%ebp),%eax
 d26:	83 e8 08             	sub    $0x8,%eax
 d29:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d2c:	a1 6c 14 00 00       	mov    0x146c,%eax
 d31:	89 45 fc             	mov    %eax,-0x4(%ebp)
 d34:	eb 24                	jmp    d5a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d39:	8b 00                	mov    (%eax),%eax
 d3b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d3e:	77 12                	ja     d52 <free+0x35>
 d40:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d43:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d46:	77 24                	ja     d6c <free+0x4f>
 d48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d4b:	8b 00                	mov    (%eax),%eax
 d4d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d50:	77 1a                	ja     d6c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d55:	8b 00                	mov    (%eax),%eax
 d57:	89 45 fc             	mov    %eax,-0x4(%ebp)
 d5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d5d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d60:	76 d4                	jbe    d36 <free+0x19>
 d62:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d65:	8b 00                	mov    (%eax),%eax
 d67:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d6a:	76 ca                	jbe    d36 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 d6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d6f:	8b 40 04             	mov    0x4(%eax),%eax
 d72:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d79:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d7c:	01 c2                	add    %eax,%edx
 d7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d81:	8b 00                	mov    (%eax),%eax
 d83:	39 c2                	cmp    %eax,%edx
 d85:	75 24                	jne    dab <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 d87:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d8a:	8b 50 04             	mov    0x4(%eax),%edx
 d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d90:	8b 00                	mov    (%eax),%eax
 d92:	8b 40 04             	mov    0x4(%eax),%eax
 d95:	01 c2                	add    %eax,%edx
 d97:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d9a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 d9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 da0:	8b 00                	mov    (%eax),%eax
 da2:	8b 10                	mov    (%eax),%edx
 da4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 da7:	89 10                	mov    %edx,(%eax)
 da9:	eb 0a                	jmp    db5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dae:	8b 10                	mov    (%eax),%edx
 db0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 db3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 db8:	8b 40 04             	mov    0x4(%eax),%eax
 dbb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dc5:	01 d0                	add    %edx,%eax
 dc7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 dca:	75 20                	jne    dec <free+0xcf>
    p->s.size += bp->s.size;
 dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dcf:	8b 50 04             	mov    0x4(%eax),%edx
 dd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 dd5:	8b 40 04             	mov    0x4(%eax),%eax
 dd8:	01 c2                	add    %eax,%edx
 dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ddd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 de0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 de3:	8b 10                	mov    (%eax),%edx
 de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 de8:	89 10                	mov    %edx,(%eax)
 dea:	eb 08                	jmp    df4 <free+0xd7>
  } else
    p->s.ptr = bp;
 dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 def:	8b 55 f8             	mov    -0x8(%ebp),%edx
 df2:	89 10                	mov    %edx,(%eax)
  freep = p;
 df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 df7:	a3 6c 14 00 00       	mov    %eax,0x146c
}
 dfc:	c9                   	leave  
 dfd:	c3                   	ret    

00000dfe <morecore>:

static Header*
morecore(uint nu)
{
 dfe:	55                   	push   %ebp
 dff:	89 e5                	mov    %esp,%ebp
 e01:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 e04:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 e0b:	77 07                	ja     e14 <morecore+0x16>
    nu = 4096;
 e0d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 e14:	8b 45 08             	mov    0x8(%ebp),%eax
 e17:	c1 e0 03             	shl    $0x3,%eax
 e1a:	89 04 24             	mov    %eax,(%esp)
 e1d:	e8 91 fb ff ff       	call   9b3 <sbrk>
 e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 e25:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 e29:	75 07                	jne    e32 <morecore+0x34>
    return 0;
 e2b:	b8 00 00 00 00       	mov    $0x0,%eax
 e30:	eb 22                	jmp    e54 <morecore+0x56>
  hp = (Header*)p;
 e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e3b:	8b 55 08             	mov    0x8(%ebp),%edx
 e3e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e44:	83 c0 08             	add    $0x8,%eax
 e47:	89 04 24             	mov    %eax,(%esp)
 e4a:	e8 ce fe ff ff       	call   d1d <free>
  return freep;
 e4f:	a1 6c 14 00 00       	mov    0x146c,%eax
}
 e54:	c9                   	leave  
 e55:	c3                   	ret    

00000e56 <malloc>:

void*
malloc(uint nbytes)
{
 e56:	55                   	push   %ebp
 e57:	89 e5                	mov    %esp,%ebp
 e59:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e5c:	8b 45 08             	mov    0x8(%ebp),%eax
 e5f:	83 c0 07             	add    $0x7,%eax
 e62:	c1 e8 03             	shr    $0x3,%eax
 e65:	83 c0 01             	add    $0x1,%eax
 e68:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 e6b:	a1 6c 14 00 00       	mov    0x146c,%eax
 e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 e77:	75 23                	jne    e9c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 e79:	c7 45 f0 64 14 00 00 	movl   $0x1464,-0x10(%ebp)
 e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e83:	a3 6c 14 00 00       	mov    %eax,0x146c
 e88:	a1 6c 14 00 00       	mov    0x146c,%eax
 e8d:	a3 64 14 00 00       	mov    %eax,0x1464
    base.s.size = 0;
 e92:	c7 05 68 14 00 00 00 	movl   $0x0,0x1468
 e99:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e9f:	8b 00                	mov    (%eax),%eax
 ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ea7:	8b 40 04             	mov    0x4(%eax),%eax
 eaa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ead:	72 4d                	jb     efc <malloc+0xa6>
      if(p->s.size == nunits)
 eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 eb2:	8b 40 04             	mov    0x4(%eax),%eax
 eb5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 eb8:	75 0c                	jne    ec6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ebd:	8b 10                	mov    (%eax),%edx
 ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ec2:	89 10                	mov    %edx,(%eax)
 ec4:	eb 26                	jmp    eec <malloc+0x96>
      else {
        p->s.size -= nunits;
 ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ec9:	8b 40 04             	mov    0x4(%eax),%eax
 ecc:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ecf:	89 c2                	mov    %eax,%edx
 ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ed4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 eda:	8b 40 04             	mov    0x4(%eax),%eax
 edd:	c1 e0 03             	shl    $0x3,%eax
 ee0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ee6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ee9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 eef:	a3 6c 14 00 00       	mov    %eax,0x146c
      return (void*)(p + 1);
 ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ef7:	83 c0 08             	add    $0x8,%eax
 efa:	eb 38                	jmp    f34 <malloc+0xde>
    }
    if(p == freep)
 efc:	a1 6c 14 00 00       	mov    0x146c,%eax
 f01:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 f04:	75 1b                	jne    f21 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 f06:	8b 45 ec             	mov    -0x14(%ebp),%eax
 f09:	89 04 24             	mov    %eax,(%esp)
 f0c:	e8 ed fe ff ff       	call   dfe <morecore>
 f11:	89 45 f4             	mov    %eax,-0xc(%ebp)
 f14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 f18:	75 07                	jne    f21 <malloc+0xcb>
        return 0;
 f1a:	b8 00 00 00 00       	mov    $0x0,%eax
 f1f:	eb 13                	jmp    f34 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
 f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
 f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 f2a:	8b 00                	mov    (%eax),%eax
 f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 f2f:	e9 70 ff ff ff       	jmp    ea4 <malloc+0x4e>
}
 f34:	c9                   	leave  
 f35:	c3                   	ret    
