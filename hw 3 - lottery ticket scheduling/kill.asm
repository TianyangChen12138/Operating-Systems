
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 da 08 00 	movl   $0x8da,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 ad 04 00 00       	call   4d0 <printf>
    exit();
  23:	e8 a7 02 00 00       	call   2cf <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 27                	jmp    59 <main+0x59>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 f1 01 00 00       	call   23d <atoi>
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 ab 02 00 00       	call   2ff <kill>

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  54:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5d:	3b 45 08             	cmp    0x8(%ebp),%eax
  60:	7c d0                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  62:	e8 68 02 00 00       	call   2cf <exit>

00000067 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  67:	55                   	push   %ebp
  68:	89 e5                	mov    %esp,%ebp
  6a:	57                   	push   %edi
  6b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6f:	8b 55 10             	mov    0x10(%ebp),%edx
  72:	8b 45 0c             	mov    0xc(%ebp),%eax
  75:	89 cb                	mov    %ecx,%ebx
  77:	89 df                	mov    %ebx,%edi
  79:	89 d1                	mov    %edx,%ecx
  7b:	fc                   	cld    
  7c:	f3 aa                	rep stos %al,%es:(%edi)
  7e:	89 ca                	mov    %ecx,%edx
  80:	89 fb                	mov    %edi,%ebx
  82:	89 5d 08             	mov    %ebx,0x8(%ebp)
  85:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  88:	5b                   	pop    %ebx
  89:	5f                   	pop    %edi
  8a:	5d                   	pop    %ebp
  8b:	c3                   	ret    

0000008c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  92:	8b 45 08             	mov    0x8(%ebp),%eax
  95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  98:	90                   	nop
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	8d 50 01             	lea    0x1(%eax),%edx
  9f:	89 55 08             	mov    %edx,0x8(%ebp)
  a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  a8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ab:	0f b6 12             	movzbl (%edx),%edx
  ae:	88 10                	mov    %dl,(%eax)
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	84 c0                	test   %al,%al
  b5:	75 e2                	jne    99 <strcpy+0xd>
    ;
  return os;
  b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ba:	c9                   	leave  
  bb:	c3                   	ret    

000000bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  bf:	eb 08                	jmp    c9 <strcmp+0xd>
    p++, q++;
  c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	0f b6 00             	movzbl (%eax),%eax
  cf:	84 c0                	test   %al,%al
  d1:	74 10                	je     e3 <strcmp+0x27>
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	0f b6 10             	movzbl (%eax),%edx
  d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  dc:	0f b6 00             	movzbl (%eax),%eax
  df:	38 c2                	cmp    %al,%dl
  e1:	74 de                	je     c1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	0f b6 d0             	movzbl %al,%edx
  ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  ef:	0f b6 00             	movzbl (%eax),%eax
  f2:	0f b6 c0             	movzbl %al,%eax
  f5:	29 c2                	sub    %eax,%edx
  f7:	89 d0                	mov    %edx,%eax
}
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    

000000fb <strlen>:

uint
strlen(char *s)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 101:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 108:	eb 04                	jmp    10e <strlen+0x13>
 10a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 10e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	01 d0                	add    %edx,%eax
 116:	0f b6 00             	movzbl (%eax),%eax
 119:	84 c0                	test   %al,%al
 11b:	75 ed                	jne    10a <strlen+0xf>
    ;
  return n;
 11d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 120:	c9                   	leave  
 121:	c3                   	ret    

00000122 <memset>:

void*
memset(void *dst, int c, uint n)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 128:	8b 45 10             	mov    0x10(%ebp),%eax
 12b:	89 44 24 08          	mov    %eax,0x8(%esp)
 12f:	8b 45 0c             	mov    0xc(%ebp),%eax
 132:	89 44 24 04          	mov    %eax,0x4(%esp)
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	89 04 24             	mov    %eax,(%esp)
 13c:	e8 26 ff ff ff       	call   67 <stosb>
  return dst;
 141:	8b 45 08             	mov    0x8(%ebp),%eax
}
 144:	c9                   	leave  
 145:	c3                   	ret    

00000146 <strchr>:

char*
strchr(const char *s, char c)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
 149:	83 ec 04             	sub    $0x4,%esp
 14c:	8b 45 0c             	mov    0xc(%ebp),%eax
 14f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 152:	eb 14                	jmp    168 <strchr+0x22>
    if(*s == c)
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	0f b6 00             	movzbl (%eax),%eax
 15a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 15d:	75 05                	jne    164 <strchr+0x1e>
      return (char*)s;
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	eb 13                	jmp    177 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 164:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	84 c0                	test   %al,%al
 170:	75 e2                	jne    154 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 172:	b8 00 00 00 00       	mov    $0x0,%eax
}
 177:	c9                   	leave  
 178:	c3                   	ret    

00000179 <gets>:

char*
gets(char *buf, int max)
{
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
 17c:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 186:	eb 4c                	jmp    1d4 <gets+0x5b>
    cc = read(0, &c, 1);
 188:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 18f:	00 
 190:	8d 45 ef             	lea    -0x11(%ebp),%eax
 193:	89 44 24 04          	mov    %eax,0x4(%esp)
 197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19e:	e8 44 01 00 00       	call   2e7 <read>
 1a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1aa:	7f 02                	jg     1ae <gets+0x35>
      break;
 1ac:	eb 31                	jmp    1df <gets+0x66>
    buf[i++] = c;
 1ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b1:	8d 50 01             	lea    0x1(%eax),%edx
 1b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b7:	89 c2                	mov    %eax,%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 c2                	add    %eax,%edx
 1be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c8:	3c 0a                	cmp    $0xa,%al
 1ca:	74 13                	je     1df <gets+0x66>
 1cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d0:	3c 0d                	cmp    $0xd,%al
 1d2:	74 0b                	je     1df <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d7:	83 c0 01             	add    $0x1,%eax
 1da:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1dd:	7c a9                	jl     188 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1df:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	01 d0                	add    %edx,%eax
 1e7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ed:	c9                   	leave  
 1ee:	c3                   	ret    

000001ef <stat>:

int
stat(char *n, struct stat *st)
{
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
 1f2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fc:	00 
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	89 04 24             	mov    %eax,(%esp)
 203:	e8 07 01 00 00       	call   30f <open>
 208:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 20f:	79 07                	jns    218 <stat+0x29>
    return -1;
 211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 216:	eb 23                	jmp    23b <stat+0x4c>
  r = fstat(fd, st);
 218:	8b 45 0c             	mov    0xc(%ebp),%eax
 21b:	89 44 24 04          	mov    %eax,0x4(%esp)
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	89 04 24             	mov    %eax,(%esp)
 225:	e8 fd 00 00 00       	call   327 <fstat>
 22a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 230:	89 04 24             	mov    %eax,(%esp)
 233:	e8 bf 00 00 00       	call   2f7 <close>
  return r;
 238:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23b:	c9                   	leave  
 23c:	c3                   	ret    

0000023d <atoi>:

int
atoi(const char *s)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 243:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24a:	eb 25                	jmp    271 <atoi+0x34>
    n = n*10 + *s++ - '0';
 24c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24f:	89 d0                	mov    %edx,%eax
 251:	c1 e0 02             	shl    $0x2,%eax
 254:	01 d0                	add    %edx,%eax
 256:	01 c0                	add    %eax,%eax
 258:	89 c1                	mov    %eax,%ecx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	8d 50 01             	lea    0x1(%eax),%edx
 260:	89 55 08             	mov    %edx,0x8(%ebp)
 263:	0f b6 00             	movzbl (%eax),%eax
 266:	0f be c0             	movsbl %al,%eax
 269:	01 c8                	add    %ecx,%eax
 26b:	83 e8 30             	sub    $0x30,%eax
 26e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	0f b6 00             	movzbl (%eax),%eax
 277:	3c 2f                	cmp    $0x2f,%al
 279:	7e 0a                	jle    285 <atoi+0x48>
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	0f b6 00             	movzbl (%eax),%eax
 281:	3c 39                	cmp    $0x39,%al
 283:	7e c7                	jle    24c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 285:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 288:	c9                   	leave  
 289:	c3                   	ret    

0000028a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 290:	8b 45 08             	mov    0x8(%ebp),%eax
 293:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 296:	8b 45 0c             	mov    0xc(%ebp),%eax
 299:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29c:	eb 17                	jmp    2b5 <memmove+0x2b>
    *dst++ = *src++;
 29e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a1:	8d 50 01             	lea    0x1(%eax),%edx
 2a4:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2aa:	8d 4a 01             	lea    0x1(%edx),%ecx
 2ad:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2b0:	0f b6 12             	movzbl (%edx),%edx
 2b3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b5:	8b 45 10             	mov    0x10(%ebp),%eax
 2b8:	8d 50 ff             	lea    -0x1(%eax),%edx
 2bb:	89 55 10             	mov    %edx,0x10(%ebp)
 2be:	85 c0                	test   %eax,%eax
 2c0:	7f dc                	jg     29e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c7:	b8 01 00 00 00       	mov    $0x1,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <exit>:
SYSCALL(exit)
 2cf:	b8 02 00 00 00       	mov    $0x2,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <wait>:
SYSCALL(wait)
 2d7:	b8 03 00 00 00       	mov    $0x3,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <pipe>:
SYSCALL(pipe)
 2df:	b8 04 00 00 00       	mov    $0x4,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <read>:
SYSCALL(read)
 2e7:	b8 05 00 00 00       	mov    $0x5,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <write>:
SYSCALL(write)
 2ef:	b8 10 00 00 00       	mov    $0x10,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <close>:
SYSCALL(close)
 2f7:	b8 15 00 00 00       	mov    $0x15,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <kill>:
SYSCALL(kill)
 2ff:	b8 06 00 00 00       	mov    $0x6,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <exec>:
SYSCALL(exec)
 307:	b8 07 00 00 00       	mov    $0x7,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <open>:
SYSCALL(open)
 30f:	b8 0f 00 00 00       	mov    $0xf,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <mknod>:
SYSCALL(mknod)
 317:	b8 11 00 00 00       	mov    $0x11,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <unlink>:
SYSCALL(unlink)
 31f:	b8 12 00 00 00       	mov    $0x12,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <fstat>:
SYSCALL(fstat)
 327:	b8 08 00 00 00       	mov    $0x8,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <link>:
SYSCALL(link)
 32f:	b8 13 00 00 00       	mov    $0x13,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <mkdir>:
SYSCALL(mkdir)
 337:	b8 14 00 00 00       	mov    $0x14,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <chdir>:
SYSCALL(chdir)
 33f:	b8 09 00 00 00       	mov    $0x9,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <dup>:
SYSCALL(dup)
 347:	b8 0a 00 00 00       	mov    $0xa,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <getpid>:
SYSCALL(getpid)
 34f:	b8 0b 00 00 00       	mov    $0xb,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <sbrk>:
SYSCALL(sbrk)
 357:	b8 0c 00 00 00       	mov    $0xc,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <sleep>:
SYSCALL(sleep)
 35f:	b8 0d 00 00 00       	mov    $0xd,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <uptime>:
SYSCALL(uptime)
 367:	b8 0e 00 00 00       	mov    $0xe,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <gettime>:
SYSCALL(gettime)
 36f:	b8 16 00 00 00       	mov    $0x16,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <settickets>:
SYSCALL(settickets)
 377:	b8 17 00 00 00       	mov    $0x17,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 18             	sub    $0x18,%esp
 385:	8b 45 0c             	mov    0xc(%ebp),%eax
 388:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 38b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 392:	00 
 393:	8d 45 f4             	lea    -0xc(%ebp),%eax
 396:	89 44 24 04          	mov    %eax,0x4(%esp)
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	89 04 24             	mov    %eax,(%esp)
 3a0:	e8 4a ff ff ff       	call   2ef <write>
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	56                   	push   %esi
 3ab:	53                   	push   %ebx
 3ac:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ba:	74 17                	je     3d3 <printint+0x2c>
 3bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c0:	79 11                	jns    3d3 <printint+0x2c>
    neg = 1;
 3c2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cc:	f7 d8                	neg    %eax
 3ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d1:	eb 06                	jmp    3d9 <printint+0x32>
  } else {
    x = xx;
 3d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3e3:	8d 41 01             	lea    0x1(%ecx),%eax
 3e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ef:	ba 00 00 00 00       	mov    $0x0,%edx
 3f4:	f7 f3                	div    %ebx
 3f6:	89 d0                	mov    %edx,%eax
 3f8:	0f b6 80 5c 0b 00 00 	movzbl 0xb5c(%eax),%eax
 3ff:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 403:	8b 75 10             	mov    0x10(%ebp),%esi
 406:	8b 45 ec             	mov    -0x14(%ebp),%eax
 409:	ba 00 00 00 00       	mov    $0x0,%edx
 40e:	f7 f6                	div    %esi
 410:	89 45 ec             	mov    %eax,-0x14(%ebp)
 413:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 417:	75 c7                	jne    3e0 <printint+0x39>
  if(neg)
 419:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41d:	74 10                	je     42f <printint+0x88>
    buf[i++] = '-';
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	8d 50 01             	lea    0x1(%eax),%edx
 425:	89 55 f4             	mov    %edx,-0xc(%ebp)
 428:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 42d:	eb 1f                	jmp    44e <printint+0xa7>
 42f:	eb 1d                	jmp    44e <printint+0xa7>
    putc(fd, buf[i]);
 431:	8d 55 dc             	lea    -0x24(%ebp),%edx
 434:	8b 45 f4             	mov    -0xc(%ebp),%eax
 437:	01 d0                	add    %edx,%eax
 439:	0f b6 00             	movzbl (%eax),%eax
 43c:	0f be c0             	movsbl %al,%eax
 43f:	89 44 24 04          	mov    %eax,0x4(%esp)
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	89 04 24             	mov    %eax,(%esp)
 449:	e8 31 ff ff ff       	call   37f <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 44e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 452:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 456:	79 d9                	jns    431 <printint+0x8a>
    putc(fd, buf[i]);
}
 458:	83 c4 30             	add    $0x30,%esp
 45b:	5b                   	pop    %ebx
 45c:	5e                   	pop    %esi
 45d:	5d                   	pop    %ebp
 45e:	c3                   	ret    

0000045f <printlong>:

static void
printlong(int fd, unsigned long long xx, int base, int sgn)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
 462:	83 ec 38             	sub    $0x38,%esp
 465:	8b 45 0c             	mov    0xc(%ebp),%eax
 468:	89 45 e0             	mov    %eax,-0x20(%ebp)
 46b:	8b 45 10             	mov    0x10(%ebp),%eax
 46e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
 471:	8b 45 e0             	mov    -0x20(%ebp),%eax
 474:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 477:	89 d0                	mov    %edx,%eax
 479:	31 d2                	xor    %edx,%edx
 47b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
 47e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 481:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(fd, upper, 16, 0);
 484:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 488:	74 22                	je     4ac <printlong+0x4d>
 48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 494:	00 
 495:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 49c:	00 
 49d:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	89 04 24             	mov    %eax,(%esp)
 4a7:	e8 fb fe ff ff       	call   3a7 <printint>
    printint(fd, lower, 16, 0);
 4ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4b6:	00 
 4b7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4be:	00 
 4bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	89 04 24             	mov    %eax,(%esp)
 4c9:	e8 d9 fe ff ff       	call   3a7 <printint>
}
 4ce:	c9                   	leave  
 4cf:	c3                   	ret    

000004d0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
// bdg 10/05/2015: Add %l
void
printf(int fd, char *fmt, ...)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 48             	sub    $0x48,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4dd:	8d 45 0c             	lea    0xc(%ebp),%eax
 4e0:	83 c0 04             	add    $0x4,%eax
 4e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ed:	e9 ba 01 00 00       	jmp    6ac <printf+0x1dc>
    c = fmt[i] & 0xff;
 4f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f8:	01 d0                	add    %edx,%eax
 4fa:	0f b6 00             	movzbl (%eax),%eax
 4fd:	0f be c0             	movsbl %al,%eax
 500:	25 ff 00 00 00       	and    $0xff,%eax
 505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 508:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 50c:	75 2c                	jne    53a <printf+0x6a>
      if(c == '%'){
 50e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 512:	75 0c                	jne    520 <printf+0x50>
        state = '%';
 514:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 51b:	e9 88 01 00 00       	jmp    6a8 <printf+0x1d8>
      } else {
        putc(fd, c);
 520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 523:	0f be c0             	movsbl %al,%eax
 526:	89 44 24 04          	mov    %eax,0x4(%esp)
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	89 04 24             	mov    %eax,(%esp)
 530:	e8 4a fe ff ff       	call   37f <putc>
 535:	e9 6e 01 00 00       	jmp    6a8 <printf+0x1d8>
      }
    } else if(state == '%'){
 53a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 53e:	0f 85 64 01 00 00    	jne    6a8 <printf+0x1d8>
      if(c == 'd'){
 544:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 548:	75 2d                	jne    577 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 54a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54d:	8b 00                	mov    (%eax),%eax
 54f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 556:	00 
 557:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 55e:	00 
 55f:	89 44 24 04          	mov    %eax,0x4(%esp)
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	89 04 24             	mov    %eax,(%esp)
 569:	e8 39 fe ff ff       	call   3a7 <printint>
        ap++;
 56e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 572:	e9 2a 01 00 00       	jmp    6a1 <printf+0x1d1>
      } else if(c == 'l') {
 577:	83 7d e4 6c          	cmpl   $0x6c,-0x1c(%ebp)
 57b:	75 38                	jne    5b5 <printf+0xe5>
        printlong(fd, *(unsigned long long *)ap, 10, 0);
 57d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 580:	8b 50 04             	mov    0x4(%eax),%edx
 583:	8b 00                	mov    (%eax),%eax
 585:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 58c:	00 
 58d:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
 594:	00 
 595:	89 44 24 04          	mov    %eax,0x4(%esp)
 599:	89 54 24 08          	mov    %edx,0x8(%esp)
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	89 04 24             	mov    %eax,(%esp)
 5a3:	e8 b7 fe ff ff       	call   45f <printlong>
        // long longs take up 2 argument slots
        ap++;
 5a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        ap++;
 5ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b0:	e9 ec 00 00 00       	jmp    6a1 <printf+0x1d1>
      } else if(c == 'x' || c == 'p'){
 5b5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b9:	74 06                	je     5c1 <printf+0xf1>
 5bb:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5bf:	75 2d                	jne    5ee <printf+0x11e>
        printint(fd, *ap, 16, 0);
 5c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c4:	8b 00                	mov    (%eax),%eax
 5c6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5cd:	00 
 5ce:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5d5:	00 
 5d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5da:	8b 45 08             	mov    0x8(%ebp),%eax
 5dd:	89 04 24             	mov    %eax,(%esp)
 5e0:	e8 c2 fd ff ff       	call   3a7 <printint>
        ap++;
 5e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e9:	e9 b3 00 00 00       	jmp    6a1 <printf+0x1d1>
      } else if(c == 's'){
 5ee:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f2:	75 45                	jne    639 <printf+0x169>
        s = (char*)*ap;
 5f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f7:	8b 00                	mov    (%eax),%eax
 5f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 604:	75 09                	jne    60f <printf+0x13f>
          s = "(null)";
 606:	c7 45 f4 ee 08 00 00 	movl   $0x8ee,-0xc(%ebp)
        while(*s != 0){
 60d:	eb 1e                	jmp    62d <printf+0x15d>
 60f:	eb 1c                	jmp    62d <printf+0x15d>
          putc(fd, *s);
 611:	8b 45 f4             	mov    -0xc(%ebp),%eax
 614:	0f b6 00             	movzbl (%eax),%eax
 617:	0f be c0             	movsbl %al,%eax
 61a:	89 44 24 04          	mov    %eax,0x4(%esp)
 61e:	8b 45 08             	mov    0x8(%ebp),%eax
 621:	89 04 24             	mov    %eax,(%esp)
 624:	e8 56 fd ff ff       	call   37f <putc>
          s++;
 629:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 62d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 630:	0f b6 00             	movzbl (%eax),%eax
 633:	84 c0                	test   %al,%al
 635:	75 da                	jne    611 <printf+0x141>
 637:	eb 68                	jmp    6a1 <printf+0x1d1>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 639:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 63d:	75 1d                	jne    65c <printf+0x18c>
        putc(fd, *ap);
 63f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	0f be c0             	movsbl %al,%eax
 647:	89 44 24 04          	mov    %eax,0x4(%esp)
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	89 04 24             	mov    %eax,(%esp)
 651:	e8 29 fd ff ff       	call   37f <putc>
        ap++;
 656:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65a:	eb 45                	jmp    6a1 <printf+0x1d1>
      } else if(c == '%'){
 65c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 660:	75 17                	jne    679 <printf+0x1a9>
        putc(fd, c);
 662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 665:	0f be c0             	movsbl %al,%eax
 668:	89 44 24 04          	mov    %eax,0x4(%esp)
 66c:	8b 45 08             	mov    0x8(%ebp),%eax
 66f:	89 04 24             	mov    %eax,(%esp)
 672:	e8 08 fd ff ff       	call   37f <putc>
 677:	eb 28                	jmp    6a1 <printf+0x1d1>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 679:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 680:	00 
 681:	8b 45 08             	mov    0x8(%ebp),%eax
 684:	89 04 24             	mov    %eax,(%esp)
 687:	e8 f3 fc ff ff       	call   37f <putc>
        putc(fd, c);
 68c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	89 44 24 04          	mov    %eax,0x4(%esp)
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	89 04 24             	mov    %eax,(%esp)
 69c:	e8 de fc ff ff       	call   37f <putc>
      }
      state = 0;
 6a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 6af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b2:	01 d0                	add    %edx,%eax
 6b4:	0f b6 00             	movzbl (%eax),%eax
 6b7:	84 c0                	test   %al,%al
 6b9:	0f 85 33 fe ff ff    	jne    4f2 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6bf:	c9                   	leave  
 6c0:	c3                   	ret    

000006c1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c1:	55                   	push   %ebp
 6c2:	89 e5                	mov    %esp,%ebp
 6c4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	83 e8 08             	sub    $0x8,%eax
 6cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d0:	a1 78 0b 00 00       	mov    0xb78,%eax
 6d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d8:	eb 24                	jmp    6fe <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	8b 00                	mov    (%eax),%eax
 6df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e2:	77 12                	ja     6f6 <free+0x35>
 6e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ea:	77 24                	ja     710 <free+0x4f>
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f4:	77 1a                	ja     710 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 704:	76 d4                	jbe    6da <free+0x19>
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	8b 00                	mov    (%eax),%eax
 70b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70e:	76 ca                	jbe    6da <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	8b 40 04             	mov    0x4(%eax),%eax
 716:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 720:	01 c2                	add    %eax,%edx
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	39 c2                	cmp    %eax,%edx
 729:	75 24                	jne    74f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 50 04             	mov    0x4(%eax),%edx
 731:	8b 45 fc             	mov    -0x4(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	8b 40 04             	mov    0x4(%eax),%eax
 739:	01 c2                	add    %eax,%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	8b 10                	mov    (%eax),%edx
 748:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74b:	89 10                	mov    %edx,(%eax)
 74d:	eb 0a                	jmp    759 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 10                	mov    (%eax),%edx
 754:	8b 45 f8             	mov    -0x8(%ebp),%eax
 757:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	01 d0                	add    %edx,%eax
 76b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 76e:	75 20                	jne    790 <free+0xcf>
    p->s.size += bp->s.size;
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 50 04             	mov    0x4(%eax),%edx
 776:	8b 45 f8             	mov    -0x8(%ebp),%eax
 779:	8b 40 04             	mov    0x4(%eax),%eax
 77c:	01 c2                	add    %eax,%edx
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 784:	8b 45 f8             	mov    -0x8(%ebp),%eax
 787:	8b 10                	mov    (%eax),%edx
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	89 10                	mov    %edx,(%eax)
 78e:	eb 08                	jmp    798 <free+0xd7>
  } else
    p->s.ptr = bp;
 790:	8b 45 fc             	mov    -0x4(%ebp),%eax
 793:	8b 55 f8             	mov    -0x8(%ebp),%edx
 796:	89 10                	mov    %edx,(%eax)
  freep = p;
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	a3 78 0b 00 00       	mov    %eax,0xb78
}
 7a0:	c9                   	leave  
 7a1:	c3                   	ret    

000007a2 <morecore>:

static Header*
morecore(uint nu)
{
 7a2:	55                   	push   %ebp
 7a3:	89 e5                	mov    %esp,%ebp
 7a5:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7af:	77 07                	ja     7b8 <morecore+0x16>
    nu = 4096;
 7b1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b8:	8b 45 08             	mov    0x8(%ebp),%eax
 7bb:	c1 e0 03             	shl    $0x3,%eax
 7be:	89 04 24             	mov    %eax,(%esp)
 7c1:	e8 91 fb ff ff       	call   357 <sbrk>
 7c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7cd:	75 07                	jne    7d6 <morecore+0x34>
    return 0;
 7cf:	b8 00 00 00 00       	mov    $0x0,%eax
 7d4:	eb 22                	jmp    7f8 <morecore+0x56>
  hp = (Header*)p;
 7d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7df:	8b 55 08             	mov    0x8(%ebp),%edx
 7e2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e8:	83 c0 08             	add    $0x8,%eax
 7eb:	89 04 24             	mov    %eax,(%esp)
 7ee:	e8 ce fe ff ff       	call   6c1 <free>
  return freep;
 7f3:	a1 78 0b 00 00       	mov    0xb78,%eax
}
 7f8:	c9                   	leave  
 7f9:	c3                   	ret    

000007fa <malloc>:

void*
malloc(uint nbytes)
{
 7fa:	55                   	push   %ebp
 7fb:	89 e5                	mov    %esp,%ebp
 7fd:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 800:	8b 45 08             	mov    0x8(%ebp),%eax
 803:	83 c0 07             	add    $0x7,%eax
 806:	c1 e8 03             	shr    $0x3,%eax
 809:	83 c0 01             	add    $0x1,%eax
 80c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 80f:	a1 78 0b 00 00       	mov    0xb78,%eax
 814:	89 45 f0             	mov    %eax,-0x10(%ebp)
 817:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 81b:	75 23                	jne    840 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 81d:	c7 45 f0 70 0b 00 00 	movl   $0xb70,-0x10(%ebp)
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	a3 78 0b 00 00       	mov    %eax,0xb78
 82c:	a1 78 0b 00 00       	mov    0xb78,%eax
 831:	a3 70 0b 00 00       	mov    %eax,0xb70
    base.s.size = 0;
 836:	c7 05 74 0b 00 00 00 	movl   $0x0,0xb74
 83d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 840:	8b 45 f0             	mov    -0x10(%ebp),%eax
 843:	8b 00                	mov    (%eax),%eax
 845:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 851:	72 4d                	jb     8a0 <malloc+0xa6>
      if(p->s.size == nunits)
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8b 40 04             	mov    0x4(%eax),%eax
 859:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85c:	75 0c                	jne    86a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	8b 10                	mov    (%eax),%edx
 863:	8b 45 f0             	mov    -0x10(%ebp),%eax
 866:	89 10                	mov    %edx,(%eax)
 868:	eb 26                	jmp    890 <malloc+0x96>
      else {
        p->s.size -= nunits;
 86a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	2b 45 ec             	sub    -0x14(%ebp),%eax
 873:	89 c2                	mov    %eax,%edx
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	c1 e0 03             	shl    $0x3,%eax
 884:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 887:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 88d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 890:	8b 45 f0             	mov    -0x10(%ebp),%eax
 893:	a3 78 0b 00 00       	mov    %eax,0xb78
      return (void*)(p + 1);
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	83 c0 08             	add    $0x8,%eax
 89e:	eb 38                	jmp    8d8 <malloc+0xde>
    }
    if(p == freep)
 8a0:	a1 78 0b 00 00       	mov    0xb78,%eax
 8a5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a8:	75 1b                	jne    8c5 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ad:	89 04 24             	mov    %eax,(%esp)
 8b0:	e8 ed fe ff ff       	call   7a2 <morecore>
 8b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8bc:	75 07                	jne    8c5 <malloc+0xcb>
        return 0;
 8be:	b8 00 00 00 00       	mov    $0x0,%eax
 8c3:	eb 13                	jmp    8d8 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ce:	8b 00                	mov    (%eax),%eax
 8d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8d3:	e9 70 ff ff ff       	jmp    848 <malloc+0x4e>
}
 8d8:	c9                   	leave  
 8d9:	c3                   	ret    
