
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 85 09 00 00 	movl   $0x985,(%esp)
  18:	e8 9a 03 00 00       	call   3b7 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 85 09 00 00 	movl   $0x985,(%esp)
  38:	e8 82 03 00 00       	call   3bf <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 85 09 00 00 	movl   $0x985,(%esp)
  4c:	e8 66 03 00 00       	call   3b7 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 92 03 00 00       	call   3ef <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 86 03 00 00       	call   3ef <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 8d 09 00 	movl   $0x98d,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 fb 04 00 00       	call   578 <printf>
    pid = fork();
  7d:	e8 ed 02 00 00       	call   36f <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 a0 09 00 	movl   $0x9a0,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 d7 04 00 00       	call   578 <printf>
      exit();
  a1:	e8 d1 02 00 00       	call   377 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 40 0c 00 	movl   $0xc40,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 82 09 00 00 	movl   $0x982,(%esp)
  bc:	e8 ee 02 00 00       	call   3af <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 b3 09 00 	movl   $0x9b3,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 a3 04 00 00       	call   578 <printf>
      exit();
  d5:	e8 9d 02 00 00       	call   377 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 c9 09 00 	movl   $0x9c9,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 88 04 00 00       	call   578 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 8a 02 00 00       	call   37f <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>

0000010f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 114:	8b 4d 08             	mov    0x8(%ebp),%ecx
 117:	8b 55 10             	mov    0x10(%ebp),%edx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 cb                	mov    %ecx,%ebx
 11f:	89 df                	mov    %ebx,%edi
 121:	89 d1                	mov    %edx,%ecx
 123:	fc                   	cld    
 124:	f3 aa                	rep stos %al,%es:(%edi)
 126:	89 ca                	mov    %ecx,%edx
 128:	89 fb                	mov    %edi,%ebx
 12a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 130:	5b                   	pop    %ebx
 131:	5f                   	pop    %edi
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 140:	90                   	nop
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8d 50 01             	lea    0x1(%eax),%edx
 147:	89 55 08             	mov    %edx,0x8(%ebp)
 14a:	8b 55 0c             	mov    0xc(%ebp),%edx
 14d:	8d 4a 01             	lea    0x1(%edx),%ecx
 150:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 153:	0f b6 12             	movzbl (%edx),%edx
 156:	88 10                	mov    %dl,(%eax)
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strcpy+0xd>
    ;
  return os;
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 167:	eb 08                	jmp    171 <strcmp+0xd>
    p++, q++;
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	74 10                	je     18b <strcmp+0x27>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	0f b6 10             	movzbl (%eax),%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	38 c2                	cmp    %al,%dl
 189:	74 de                	je     169 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 00             	movzbl (%eax),%eax
 191:	0f b6 d0             	movzbl %al,%edx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 c0             	movzbl %al,%eax
 19d:	29 c2                	sub    %eax,%edx
 19f:	89 d0                	mov    %edx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 04                	jmp    1b6 <strlen+0x13>
 1b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	0f b6 00             	movzbl (%eax),%eax
 1c1:	84 c0                	test   %al,%al
 1c3:	75 ed                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d0:	8b 45 10             	mov    0x10(%ebp),%eax
 1d3:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1da:	89 44 24 04          	mov    %eax,0x4(%esp)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	89 04 24             	mov    %eax,(%esp)
 1e4:	e8 26 ff ff ff       	call   10f <stosb>
  return dst;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ec:	c9                   	leave  
 1ed:	c3                   	ret    

000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	83 ec 04             	sub    $0x4,%esp
 1f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fa:	eb 14                	jmp    210 <strchr+0x22>
    if(*s == c)
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 00             	movzbl (%eax),%eax
 202:	3a 45 fc             	cmp    -0x4(%ebp),%al
 205:	75 05                	jne    20c <strchr+0x1e>
      return (char*)s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	eb 13                	jmp    21f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	84 c0                	test   %al,%al
 218:	75 e2                	jne    1fc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21f:	c9                   	leave  
 220:	c3                   	ret    

00000221 <gets>:

char*
gets(char *buf, int max)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 227:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22e:	eb 4c                	jmp    27c <gets+0x5b>
    cc = read(0, &c, 1);
 230:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 237:	00 
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	89 44 24 04          	mov    %eax,0x4(%esp)
 23f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 246:	e8 44 01 00 00       	call   38f <read>
 24b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 252:	7f 02                	jg     256 <gets+0x35>
      break;
 254:	eb 31                	jmp    287 <gets+0x66>
    buf[i++] = c;
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25f:	89 c2                	mov    %eax,%edx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	01 c2                	add    %eax,%edx
 266:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 270:	3c 0a                	cmp    $0xa,%al
 272:	74 13                	je     287 <gets+0x66>
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	3c 0d                	cmp    $0xd,%al
 27a:	74 0b                	je     287 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27f:	83 c0 01             	add    $0x1,%eax
 282:	3b 45 0c             	cmp    0xc(%ebp),%eax
 285:	7c a9                	jl     230 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <stat>:

int
stat(char *n, struct stat *st)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a4:	00 
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 07 01 00 00       	call   3b7 <open>
 2b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b7:	79 07                	jns    2c0 <stat+0x29>
    return -1;
 2b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2be:	eb 23                	jmp    2e3 <stat+0x4c>
  r = fstat(fd, st);
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 fd 00 00 00       	call   3cf <fstat>
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 bf 00 00 00       	call   39f <close>
  return r;
 2e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <atoi>:

int
atoi(const char *s)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
 2e8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f2:	eb 25                	jmp    319 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f7:	89 d0                	mov    %edx,%eax
 2f9:	c1 e0 02             	shl    $0x2,%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	01 c0                	add    %eax,%eax
 300:	89 c1                	mov    %eax,%ecx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	8d 50 01             	lea    0x1(%eax),%edx
 308:	89 55 08             	mov    %edx,0x8(%ebp)
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	01 c8                	add    %ecx,%eax
 313:	83 e8 30             	sub    $0x30,%eax
 316:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x48>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c7                	jle    2f4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 17                	jmp    35d <memmove+0x2b>
    *dst++ = *src++;
 346:	8b 45 fc             	mov    -0x4(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 4a 01             	lea    0x1(%edx),%ecx
 355:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 358:	0f b6 12             	movzbl (%edx),%edx
 35b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35d:	8b 45 10             	mov    0x10(%ebp),%eax
 360:	8d 50 ff             	lea    -0x1(%eax),%edx
 363:	89 55 10             	mov    %edx,0x10(%ebp)
 366:	85 c0                	test   %eax,%eax
 368:	7f dc                	jg     346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36f:	b8 01 00 00 00       	mov    $0x1,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <exit>:
SYSCALL(exit)
 377:	b8 02 00 00 00       	mov    $0x2,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <wait>:
SYSCALL(wait)
 37f:	b8 03 00 00 00       	mov    $0x3,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <pipe>:
SYSCALL(pipe)
 387:	b8 04 00 00 00       	mov    $0x4,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <read>:
SYSCALL(read)
 38f:	b8 05 00 00 00       	mov    $0x5,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <write>:
SYSCALL(write)
 397:	b8 10 00 00 00       	mov    $0x10,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <close>:
SYSCALL(close)
 39f:	b8 15 00 00 00       	mov    $0x15,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <kill>:
SYSCALL(kill)
 3a7:	b8 06 00 00 00       	mov    $0x6,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <exec>:
SYSCALL(exec)
 3af:	b8 07 00 00 00       	mov    $0x7,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <open>:
SYSCALL(open)
 3b7:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <mknod>:
SYSCALL(mknod)
 3bf:	b8 11 00 00 00       	mov    $0x11,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <unlink>:
SYSCALL(unlink)
 3c7:	b8 12 00 00 00       	mov    $0x12,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <fstat>:
SYSCALL(fstat)
 3cf:	b8 08 00 00 00       	mov    $0x8,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <link>:
SYSCALL(link)
 3d7:	b8 13 00 00 00       	mov    $0x13,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <mkdir>:
SYSCALL(mkdir)
 3df:	b8 14 00 00 00       	mov    $0x14,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <chdir>:
SYSCALL(chdir)
 3e7:	b8 09 00 00 00       	mov    $0x9,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <dup>:
SYSCALL(dup)
 3ef:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <getpid>:
SYSCALL(getpid)
 3f7:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <sbrk>:
SYSCALL(sbrk)
 3ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <sleep>:
SYSCALL(sleep)
 407:	b8 0d 00 00 00       	mov    $0xd,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <uptime>:
SYSCALL(uptime)
 40f:	b8 0e 00 00 00       	mov    $0xe,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <gettime>:
SYSCALL(gettime)
 417:	b8 16 00 00 00       	mov    $0x16,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <settickets>:
SYSCALL(settickets)
 41f:	b8 17 00 00 00       	mov    $0x17,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
 42a:	83 ec 18             	sub    $0x18,%esp
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 433:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43a:	00 
 43b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 43e:	89 44 24 04          	mov    %eax,0x4(%esp)
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	89 04 24             	mov    %eax,(%esp)
 448:	e8 4a ff ff ff       	call   397 <write>
}
 44d:	c9                   	leave  
 44e:	c3                   	ret    

0000044f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44f:	55                   	push   %ebp
 450:	89 e5                	mov    %esp,%ebp
 452:	56                   	push   %esi
 453:	53                   	push   %ebx
 454:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 457:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 45e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 462:	74 17                	je     47b <printint+0x2c>
 464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 468:	79 11                	jns    47b <printint+0x2c>
    neg = 1;
 46a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 471:	8b 45 0c             	mov    0xc(%ebp),%eax
 474:	f7 d8                	neg    %eax
 476:	89 45 ec             	mov    %eax,-0x14(%ebp)
 479:	eb 06                	jmp    481 <printint+0x32>
  } else {
    x = xx;
 47b:	8b 45 0c             	mov    0xc(%ebp),%eax
 47e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 481:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 488:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 48b:	8d 41 01             	lea    0x1(%ecx),%eax
 48e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 491:	8b 5d 10             	mov    0x10(%ebp),%ebx
 494:	8b 45 ec             	mov    -0x14(%ebp),%eax
 497:	ba 00 00 00 00       	mov    $0x0,%edx
 49c:	f7 f3                	div    %ebx
 49e:	89 d0                	mov    %edx,%eax
 4a0:	0f b6 80 48 0c 00 00 	movzbl 0xc48(%eax),%eax
 4a7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ab:	8b 75 10             	mov    0x10(%ebp),%esi
 4ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b1:	ba 00 00 00 00       	mov    $0x0,%edx
 4b6:	f7 f6                	div    %esi
 4b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bf:	75 c7                	jne    488 <printint+0x39>
  if(neg)
 4c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c5:	74 10                	je     4d7 <printint+0x88>
    buf[i++] = '-';
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	8d 50 01             	lea    0x1(%eax),%edx
 4cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d5:	eb 1f                	jmp    4f6 <printint+0xa7>
 4d7:	eb 1d                	jmp    4f6 <printint+0xa7>
    putc(fd, buf[i]);
 4d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4df:	01 d0                	add    %edx,%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 31 ff ff ff       	call   427 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fe:	79 d9                	jns    4d9 <printint+0x8a>
    putc(fd, buf[i]);
}
 500:	83 c4 30             	add    $0x30,%esp
 503:	5b                   	pop    %ebx
 504:	5e                   	pop    %esi
 505:	5d                   	pop    %ebp
 506:	c3                   	ret    

00000507 <printlong>:

static void
printlong(int fd, unsigned long long xx, int base, int sgn)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	83 ec 38             	sub    $0x38,%esp
 50d:	8b 45 0c             	mov    0xc(%ebp),%eax
 510:	89 45 e0             	mov    %eax,-0x20(%ebp)
 513:	8b 45 10             	mov    0x10(%ebp),%eax
 516:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
 519:	8b 45 e0             	mov    -0x20(%ebp),%eax
 51c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 51f:	89 d0                	mov    %edx,%eax
 521:	31 d2                	xor    %edx,%edx
 523:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
 526:	8b 45 e0             	mov    -0x20(%ebp),%eax
 529:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(fd, upper, 16, 0);
 52c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 530:	74 22                	je     554 <printlong+0x4d>
 532:	8b 45 f4             	mov    -0xc(%ebp),%eax
 535:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 53c:	00 
 53d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 544:	00 
 545:	89 44 24 04          	mov    %eax,0x4(%esp)
 549:	8b 45 08             	mov    0x8(%ebp),%eax
 54c:	89 04 24             	mov    %eax,(%esp)
 54f:	e8 fb fe ff ff       	call   44f <printint>
    printint(fd, lower, 16, 0);
 554:	8b 45 f0             	mov    -0x10(%ebp),%eax
 557:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 55e:	00 
 55f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 566:	00 
 567:	89 44 24 04          	mov    %eax,0x4(%esp)
 56b:	8b 45 08             	mov    0x8(%ebp),%eax
 56e:	89 04 24             	mov    %eax,(%esp)
 571:	e8 d9 fe ff ff       	call   44f <printint>
}
 576:	c9                   	leave  
 577:	c3                   	ret    

00000578 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
// bdg 10/05/2015: Add %l
void
printf(int fd, char *fmt, ...)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 48             	sub    $0x48,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 57e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 585:	8d 45 0c             	lea    0xc(%ebp),%eax
 588:	83 c0 04             	add    $0x4,%eax
 58b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 58e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 595:	e9 ba 01 00 00       	jmp    754 <printf+0x1dc>
    c = fmt[i] & 0xff;
 59a:	8b 55 0c             	mov    0xc(%ebp),%edx
 59d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a0:	01 d0                	add    %edx,%eax
 5a2:	0f b6 00             	movzbl (%eax),%eax
 5a5:	0f be c0             	movsbl %al,%eax
 5a8:	25 ff 00 00 00       	and    $0xff,%eax
 5ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5b4:	75 2c                	jne    5e2 <printf+0x6a>
      if(c == '%'){
 5b6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ba:	75 0c                	jne    5c8 <printf+0x50>
        state = '%';
 5bc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5c3:	e9 88 01 00 00       	jmp    750 <printf+0x1d8>
      } else {
        putc(fd, c);
 5c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5cb:	0f be c0             	movsbl %al,%eax
 5ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d2:	8b 45 08             	mov    0x8(%ebp),%eax
 5d5:	89 04 24             	mov    %eax,(%esp)
 5d8:	e8 4a fe ff ff       	call   427 <putc>
 5dd:	e9 6e 01 00 00       	jmp    750 <printf+0x1d8>
      }
    } else if(state == '%'){
 5e2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5e6:	0f 85 64 01 00 00    	jne    750 <printf+0x1d8>
      if(c == 'd'){
 5ec:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5f0:	75 2d                	jne    61f <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f5:	8b 00                	mov    (%eax),%eax
 5f7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5fe:	00 
 5ff:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 606:	00 
 607:	89 44 24 04          	mov    %eax,0x4(%esp)
 60b:	8b 45 08             	mov    0x8(%ebp),%eax
 60e:	89 04 24             	mov    %eax,(%esp)
 611:	e8 39 fe ff ff       	call   44f <printint>
        ap++;
 616:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61a:	e9 2a 01 00 00       	jmp    749 <printf+0x1d1>
      } else if(c == 'l') {
 61f:	83 7d e4 6c          	cmpl   $0x6c,-0x1c(%ebp)
 623:	75 38                	jne    65d <printf+0xe5>
        printlong(fd, *(unsigned long long *)ap, 10, 0);
 625:	8b 45 e8             	mov    -0x18(%ebp),%eax
 628:	8b 50 04             	mov    0x4(%eax),%edx
 62b:	8b 00                	mov    (%eax),%eax
 62d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 634:	00 
 635:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
 63c:	00 
 63d:	89 44 24 04          	mov    %eax,0x4(%esp)
 641:	89 54 24 08          	mov    %edx,0x8(%esp)
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	89 04 24             	mov    %eax,(%esp)
 64b:	e8 b7 fe ff ff       	call   507 <printlong>
        // long longs take up 2 argument slots
        ap++;
 650:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        ap++;
 654:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 658:	e9 ec 00 00 00       	jmp    749 <printf+0x1d1>
      } else if(c == 'x' || c == 'p'){
 65d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 661:	74 06                	je     669 <printf+0xf1>
 663:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 667:	75 2d                	jne    696 <printf+0x11e>
        printint(fd, *ap, 16, 0);
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 675:	00 
 676:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 67d:	00 
 67e:	89 44 24 04          	mov    %eax,0x4(%esp)
 682:	8b 45 08             	mov    0x8(%ebp),%eax
 685:	89 04 24             	mov    %eax,(%esp)
 688:	e8 c2 fd ff ff       	call   44f <printint>
        ap++;
 68d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 691:	e9 b3 00 00 00       	jmp    749 <printf+0x1d1>
      } else if(c == 's'){
 696:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 69a:	75 45                	jne    6e1 <printf+0x169>
        s = (char*)*ap;
 69c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ac:	75 09                	jne    6b7 <printf+0x13f>
          s = "(null)";
 6ae:	c7 45 f4 d2 09 00 00 	movl   $0x9d2,-0xc(%ebp)
        while(*s != 0){
 6b5:	eb 1e                	jmp    6d5 <printf+0x15d>
 6b7:	eb 1c                	jmp    6d5 <printf+0x15d>
          putc(fd, *s);
 6b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bc:	0f b6 00             	movzbl (%eax),%eax
 6bf:	0f be c0             	movsbl %al,%eax
 6c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	89 04 24             	mov    %eax,(%esp)
 6cc:	e8 56 fd ff ff       	call   427 <putc>
          s++;
 6d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d8:	0f b6 00             	movzbl (%eax),%eax
 6db:	84 c0                	test   %al,%al
 6dd:	75 da                	jne    6b9 <printf+0x141>
 6df:	eb 68                	jmp    749 <printf+0x1d1>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6e1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e5:	75 1d                	jne    704 <printf+0x18c>
        putc(fd, *ap);
 6e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	0f be c0             	movsbl %al,%eax
 6ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f3:	8b 45 08             	mov    0x8(%ebp),%eax
 6f6:	89 04 24             	mov    %eax,(%esp)
 6f9:	e8 29 fd ff ff       	call   427 <putc>
        ap++;
 6fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 702:	eb 45                	jmp    749 <printf+0x1d1>
      } else if(c == '%'){
 704:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 708:	75 17                	jne    721 <printf+0x1a9>
        putc(fd, c);
 70a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	89 44 24 04          	mov    %eax,0x4(%esp)
 714:	8b 45 08             	mov    0x8(%ebp),%eax
 717:	89 04 24             	mov    %eax,(%esp)
 71a:	e8 08 fd ff ff       	call   427 <putc>
 71f:	eb 28                	jmp    749 <printf+0x1d1>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 721:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 728:	00 
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	89 04 24             	mov    %eax,(%esp)
 72f:	e8 f3 fc ff ff       	call   427 <putc>
        putc(fd, c);
 734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 737:	0f be c0             	movsbl %al,%eax
 73a:	89 44 24 04          	mov    %eax,0x4(%esp)
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	89 04 24             	mov    %eax,(%esp)
 744:	e8 de fc ff ff       	call   427 <putc>
      }
      state = 0;
 749:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 750:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 754:	8b 55 0c             	mov    0xc(%ebp),%edx
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	01 d0                	add    %edx,%eax
 75c:	0f b6 00             	movzbl (%eax),%eax
 75f:	84 c0                	test   %al,%al
 761:	0f 85 33 fe ff ff    	jne    59a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 767:	c9                   	leave  
 768:	c3                   	ret    

00000769 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 769:	55                   	push   %ebp
 76a:	89 e5                	mov    %esp,%ebp
 76c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	83 e8 08             	sub    $0x8,%eax
 775:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 778:	a1 64 0c 00 00       	mov    0xc64,%eax
 77d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 780:	eb 24                	jmp    7a6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 78a:	77 12                	ja     79e <free+0x35>
 78c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 792:	77 24                	ja     7b8 <free+0x4f>
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	8b 00                	mov    (%eax),%eax
 799:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 79c:	77 1a                	ja     7b8 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a1:	8b 00                	mov    (%eax),%eax
 7a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ac:	76 d4                	jbe    782 <free+0x19>
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b6:	76 ca                	jbe    782 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	01 c2                	add    %eax,%edx
 7ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	39 c2                	cmp    %eax,%edx
 7d1:	75 24                	jne    7f7 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	8b 50 04             	mov    0x4(%eax),%edx
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	8b 40 04             	mov    0x4(%eax),%eax
 7e1:	01 c2                	add    %eax,%edx
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	8b 10                	mov    (%eax),%edx
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	89 10                	mov    %edx,(%eax)
 7f5:	eb 0a                	jmp    801 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fa:	8b 10                	mov    (%eax),%edx
 7fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ff:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 40 04             	mov    0x4(%eax),%eax
 807:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	01 d0                	add    %edx,%eax
 813:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 816:	75 20                	jne    838 <free+0xcf>
    p->s.size += bp->s.size;
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 50 04             	mov    0x4(%eax),%edx
 81e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 821:	8b 40 04             	mov    0x4(%eax),%eax
 824:	01 c2                	add    %eax,%edx
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 82c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82f:	8b 10                	mov    (%eax),%edx
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	89 10                	mov    %edx,(%eax)
 836:	eb 08                	jmp    840 <free+0xd7>
  } else
    p->s.ptr = bp;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83e:	89 10                	mov    %edx,(%eax)
  freep = p;
 840:	8b 45 fc             	mov    -0x4(%ebp),%eax
 843:	a3 64 0c 00 00       	mov    %eax,0xc64
}
 848:	c9                   	leave  
 849:	c3                   	ret    

0000084a <morecore>:

static Header*
morecore(uint nu)
{
 84a:	55                   	push   %ebp
 84b:	89 e5                	mov    %esp,%ebp
 84d:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 850:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 857:	77 07                	ja     860 <morecore+0x16>
    nu = 4096;
 859:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 860:	8b 45 08             	mov    0x8(%ebp),%eax
 863:	c1 e0 03             	shl    $0x3,%eax
 866:	89 04 24             	mov    %eax,(%esp)
 869:	e8 91 fb ff ff       	call   3ff <sbrk>
 86e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 871:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 875:	75 07                	jne    87e <morecore+0x34>
    return 0;
 877:	b8 00 00 00 00       	mov    $0x0,%eax
 87c:	eb 22                	jmp    8a0 <morecore+0x56>
  hp = (Header*)p;
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	8b 55 08             	mov    0x8(%ebp),%edx
 88a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 88d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 890:	83 c0 08             	add    $0x8,%eax
 893:	89 04 24             	mov    %eax,(%esp)
 896:	e8 ce fe ff ff       	call   769 <free>
  return freep;
 89b:	a1 64 0c 00 00       	mov    0xc64,%eax
}
 8a0:	c9                   	leave  
 8a1:	c3                   	ret    

000008a2 <malloc>:

void*
malloc(uint nbytes)
{
 8a2:	55                   	push   %ebp
 8a3:	89 e5                	mov    %esp,%ebp
 8a5:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a8:	8b 45 08             	mov    0x8(%ebp),%eax
 8ab:	83 c0 07             	add    $0x7,%eax
 8ae:	c1 e8 03             	shr    $0x3,%eax
 8b1:	83 c0 01             	add    $0x1,%eax
 8b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8b7:	a1 64 0c 00 00       	mov    0xc64,%eax
 8bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8c3:	75 23                	jne    8e8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8c5:	c7 45 f0 5c 0c 00 00 	movl   $0xc5c,-0x10(%ebp)
 8cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cf:	a3 64 0c 00 00       	mov    %eax,0xc64
 8d4:	a1 64 0c 00 00       	mov    0xc64,%eax
 8d9:	a3 5c 0c 00 00       	mov    %eax,0xc5c
    base.s.size = 0;
 8de:	c7 05 60 0c 00 00 00 	movl   $0x0,0xc60
 8e5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8eb:	8b 00                	mov    (%eax),%eax
 8ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	8b 40 04             	mov    0x4(%eax),%eax
 8f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f9:	72 4d                	jb     948 <malloc+0xa6>
      if(p->s.size == nunits)
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 904:	75 0c                	jne    912 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 906:	8b 45 f4             	mov    -0xc(%ebp),%eax
 909:	8b 10                	mov    (%eax),%edx
 90b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90e:	89 10                	mov    %edx,(%eax)
 910:	eb 26                	jmp    938 <malloc+0x96>
      else {
        p->s.size -= nunits;
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	8b 40 04             	mov    0x4(%eax),%eax
 918:	2b 45 ec             	sub    -0x14(%ebp),%eax
 91b:	89 c2                	mov    %eax,%edx
 91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 920:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 40 04             	mov    0x4(%eax),%eax
 929:	c1 e0 03             	shl    $0x3,%eax
 92c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	8b 55 ec             	mov    -0x14(%ebp),%edx
 935:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 938:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93b:	a3 64 0c 00 00       	mov    %eax,0xc64
      return (void*)(p + 1);
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	83 c0 08             	add    $0x8,%eax
 946:	eb 38                	jmp    980 <malloc+0xde>
    }
    if(p == freep)
 948:	a1 64 0c 00 00       	mov    0xc64,%eax
 94d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 950:	75 1b                	jne    96d <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 952:	8b 45 ec             	mov    -0x14(%ebp),%eax
 955:	89 04 24             	mov    %eax,(%esp)
 958:	e8 ed fe ff ff       	call   84a <morecore>
 95d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 960:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 964:	75 07                	jne    96d <malloc+0xcb>
        return 0;
 966:	b8 00 00 00 00       	mov    $0x0,%eax
 96b:	eb 13                	jmp    980 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 970:	89 45 f0             	mov    %eax,-0x10(%ebp)
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 97b:	e9 70 ff ff ff       	jmp    8f0 <malloc+0x4e>
}
 980:	c9                   	leave  
 981:	c3                   	ret    
