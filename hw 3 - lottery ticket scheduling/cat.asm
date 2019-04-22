
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 80 0c 00 	movl   $0xc80,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 82 03 00 00       	call   3a5 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 80 0c 00 	movl   $0xc80,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 5f 03 00 00       	call   39d <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 90 09 00 	movl   $0x990,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 25 05 00 00       	call   586 <printf>
    exit();
  61:	e8 1f 03 00 00       	call   385 <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 fd 02 00 00       	call   385 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 79                	jmp    10b <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	01 d0                	add    %edx,%eax
  a2:	8b 00                	mov    (%eax),%eax
  a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 11 03 00 00       	call   3c5 <open>
  b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  b8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  bd:	79 2f                	jns    ee <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	01 d0                	add    %edx,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  d5:	c7 44 24 04 a1 09 00 	movl   $0x9a1,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 9d 04 00 00       	call   586 <printf>
      exit();
  e9:	e8 97 02 00 00       	call   385 <exit>
    }
    cat(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 06 ff ff ff       	call   0 <cat>
    close(fd);
  fa:	8b 44 24 18          	mov    0x18(%esp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 a7 02 00 00       	call   3ad <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 106:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 10b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 10f:	3b 45 08             	cmp    0x8(%ebp),%eax
 112:	0f 8c 7a ff ff ff    	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 118:	e8 68 02 00 00       	call   385 <exit>

0000011d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	57                   	push   %edi
 121:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 122:	8b 4d 08             	mov    0x8(%ebp),%ecx
 125:	8b 55 10             	mov    0x10(%ebp),%edx
 128:	8b 45 0c             	mov    0xc(%ebp),%eax
 12b:	89 cb                	mov    %ecx,%ebx
 12d:	89 df                	mov    %ebx,%edi
 12f:	89 d1                	mov    %edx,%ecx
 131:	fc                   	cld    
 132:	f3 aa                	rep stos %al,%es:(%edi)
 134:	89 ca                	mov    %ecx,%edx
 136:	89 fb                	mov    %edi,%ebx
 138:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13e:	5b                   	pop    %ebx
 13f:	5f                   	pop    %edi
 140:	5d                   	pop    %ebp
 141:	c3                   	ret    

00000142 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 14e:	90                   	nop
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	8d 50 01             	lea    0x1(%eax),%edx
 155:	89 55 08             	mov    %edx,0x8(%ebp)
 158:	8b 55 0c             	mov    0xc(%ebp),%edx
 15b:	8d 4a 01             	lea    0x1(%edx),%ecx
 15e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 161:	0f b6 12             	movzbl (%edx),%edx
 164:	88 10                	mov    %dl,(%eax)
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	84 c0                	test   %al,%al
 16b:	75 e2                	jne    14f <strcpy+0xd>
    ;
  return os;
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 175:	eb 08                	jmp    17f <strcmp+0xd>
    p++, q++;
 177:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	74 10                	je     199 <strcmp+0x27>
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 10             	movzbl (%eax),%edx
 18f:	8b 45 0c             	mov    0xc(%ebp),%eax
 192:	0f b6 00             	movzbl (%eax),%eax
 195:	38 c2                	cmp    %al,%dl
 197:	74 de                	je     177 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 d0             	movzbl %al,%edx
 1a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	0f b6 c0             	movzbl %al,%eax
 1ab:	29 c2                	sub    %eax,%edx
 1ad:	89 d0                	mov    %edx,%eax
}
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <strlen>:

uint
strlen(char *s)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1be:	eb 04                	jmp    1c4 <strlen+0x13>
 1c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	01 d0                	add    %edx,%eax
 1cc:	0f b6 00             	movzbl (%eax),%eax
 1cf:	84 c0                	test   %al,%al
 1d1:	75 ed                	jne    1c0 <strlen+0xf>
    ;
  return n;
 1d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	89 04 24             	mov    %eax,(%esp)
 1f2:	e8 26 ff ff ff       	call   11d <stosb>
  return dst;
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <strchr>:

char*
strchr(const char *s, char c)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 04             	sub    $0x4,%esp
 202:	8b 45 0c             	mov    0xc(%ebp),%eax
 205:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 208:	eb 14                	jmp    21e <strchr+0x22>
    if(*s == c)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	0f b6 00             	movzbl (%eax),%eax
 210:	3a 45 fc             	cmp    -0x4(%ebp),%al
 213:	75 05                	jne    21a <strchr+0x1e>
      return (char*)s;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	eb 13                	jmp    22d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	0f b6 00             	movzbl (%eax),%eax
 224:	84 c0                	test   %al,%al
 226:	75 e2                	jne    20a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 228:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <gets>:

char*
gets(char *buf, int max)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23c:	eb 4c                	jmp    28a <gets+0x5b>
    cc = read(0, &c, 1);
 23e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 245:	00 
 246:	8d 45 ef             	lea    -0x11(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 254:	e8 44 01 00 00       	call   39d <read>
 259:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 260:	7f 02                	jg     264 <gets+0x35>
      break;
 262:	eb 31                	jmp    295 <gets+0x66>
    buf[i++] = c;
 264:	8b 45 f4             	mov    -0xc(%ebp),%eax
 267:	8d 50 01             	lea    0x1(%eax),%edx
 26a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 26d:	89 c2                	mov    %eax,%edx
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	01 c2                	add    %eax,%edx
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27e:	3c 0a                	cmp    $0xa,%al
 280:	74 13                	je     295 <gets+0x66>
 282:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 286:	3c 0d                	cmp    $0xd,%al
 288:	74 0b                	je     295 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28d:	83 c0 01             	add    $0x1,%eax
 290:	3b 45 0c             	cmp    0xc(%ebp),%eax
 293:	7c a9                	jl     23e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 295:	8b 55 f4             	mov    -0xc(%ebp),%edx
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <stat>:

int
stat(char *n, struct stat *st)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b2:	00 
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 07 01 00 00       	call   3c5 <open>
 2be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c5:	79 07                	jns    2ce <stat+0x29>
    return -1;
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 23                	jmp    2f1 <stat+0x4c>
  r = fstat(fd, st);
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 fd 00 00 00       	call   3dd <fstat>
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 bf 00 00 00       	call   3ad <close>
  return r;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <atoi>:

int
atoi(const char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 300:	eb 25                	jmp    327 <atoi+0x34>
    n = n*10 + *s++ - '0';
 302:	8b 55 fc             	mov    -0x4(%ebp),%edx
 305:	89 d0                	mov    %edx,%eax
 307:	c1 e0 02             	shl    $0x2,%eax
 30a:	01 d0                	add    %edx,%eax
 30c:	01 c0                	add    %eax,%eax
 30e:	89 c1                	mov    %eax,%ecx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	8d 50 01             	lea    0x1(%eax),%edx
 316:	89 55 08             	mov    %edx,0x8(%ebp)
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	0f be c0             	movsbl %al,%eax
 31f:	01 c8                	add    %ecx,%eax
 321:	83 e8 30             	sub    $0x30,%eax
 324:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	3c 2f                	cmp    $0x2f,%al
 32f:	7e 0a                	jle    33b <atoi+0x48>
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 39                	cmp    $0x39,%al
 339:	7e c7                	jle    302 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 352:	eb 17                	jmp    36b <memmove+0x2b>
    *dst++ = *src++;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
 357:	8d 50 01             	lea    0x1(%eax),%edx
 35a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 35d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 360:	8d 4a 01             	lea    0x1(%edx),%ecx
 363:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 366:	0f b6 12             	movzbl (%edx),%edx
 369:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36b:	8b 45 10             	mov    0x10(%ebp),%eax
 36e:	8d 50 ff             	lea    -0x1(%eax),%edx
 371:	89 55 10             	mov    %edx,0x10(%ebp)
 374:	85 c0                	test   %eax,%eax
 376:	7f dc                	jg     354 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    

0000037d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37d:	b8 01 00 00 00       	mov    $0x1,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <exit>:
SYSCALL(exit)
 385:	b8 02 00 00 00       	mov    $0x2,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <wait>:
SYSCALL(wait)
 38d:	b8 03 00 00 00       	mov    $0x3,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <pipe>:
SYSCALL(pipe)
 395:	b8 04 00 00 00       	mov    $0x4,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <read>:
SYSCALL(read)
 39d:	b8 05 00 00 00       	mov    $0x5,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <write>:
SYSCALL(write)
 3a5:	b8 10 00 00 00       	mov    $0x10,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <close>:
SYSCALL(close)
 3ad:	b8 15 00 00 00       	mov    $0x15,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <kill>:
SYSCALL(kill)
 3b5:	b8 06 00 00 00       	mov    $0x6,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <exec>:
SYSCALL(exec)
 3bd:	b8 07 00 00 00       	mov    $0x7,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <open>:
SYSCALL(open)
 3c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <mknod>:
SYSCALL(mknod)
 3cd:	b8 11 00 00 00       	mov    $0x11,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <unlink>:
SYSCALL(unlink)
 3d5:	b8 12 00 00 00       	mov    $0x12,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <fstat>:
SYSCALL(fstat)
 3dd:	b8 08 00 00 00       	mov    $0x8,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <link>:
SYSCALL(link)
 3e5:	b8 13 00 00 00       	mov    $0x13,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <mkdir>:
SYSCALL(mkdir)
 3ed:	b8 14 00 00 00       	mov    $0x14,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <chdir>:
SYSCALL(chdir)
 3f5:	b8 09 00 00 00       	mov    $0x9,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <dup>:
SYSCALL(dup)
 3fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <getpid>:
SYSCALL(getpid)
 405:	b8 0b 00 00 00       	mov    $0xb,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <sbrk>:
SYSCALL(sbrk)
 40d:	b8 0c 00 00 00       	mov    $0xc,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <sleep>:
SYSCALL(sleep)
 415:	b8 0d 00 00 00       	mov    $0xd,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <uptime>:
SYSCALL(uptime)
 41d:	b8 0e 00 00 00       	mov    $0xe,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <gettime>:
SYSCALL(gettime)
 425:	b8 16 00 00 00       	mov    $0x16,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <settickets>:
SYSCALL(settickets)
 42d:	b8 17 00 00 00       	mov    $0x17,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 435:	55                   	push   %ebp
 436:	89 e5                	mov    %esp,%ebp
 438:	83 ec 18             	sub    $0x18,%esp
 43b:	8b 45 0c             	mov    0xc(%ebp),%eax
 43e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 441:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 448:	00 
 449:	8d 45 f4             	lea    -0xc(%ebp),%eax
 44c:	89 44 24 04          	mov    %eax,0x4(%esp)
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	89 04 24             	mov    %eax,(%esp)
 456:	e8 4a ff ff ff       	call   3a5 <write>
}
 45b:	c9                   	leave  
 45c:	c3                   	ret    

0000045d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45d:	55                   	push   %ebp
 45e:	89 e5                	mov    %esp,%ebp
 460:	56                   	push   %esi
 461:	53                   	push   %ebx
 462:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 465:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 46c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 470:	74 17                	je     489 <printint+0x2c>
 472:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 476:	79 11                	jns    489 <printint+0x2c>
    neg = 1;
 478:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 47f:	8b 45 0c             	mov    0xc(%ebp),%eax
 482:	f7 d8                	neg    %eax
 484:	89 45 ec             	mov    %eax,-0x14(%ebp)
 487:	eb 06                	jmp    48f <printint+0x32>
  } else {
    x = xx;
 489:	8b 45 0c             	mov    0xc(%ebp),%eax
 48c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 48f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 496:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 499:	8d 41 01             	lea    0x1(%ecx),%eax
 49c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 49f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a5:	ba 00 00 00 00       	mov    $0x0,%edx
 4aa:	f7 f3                	div    %ebx
 4ac:	89 d0                	mov    %edx,%eax
 4ae:	0f b6 80 44 0c 00 00 	movzbl 0xc44(%eax),%eax
 4b5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4b9:	8b 75 10             	mov    0x10(%ebp),%esi
 4bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4bf:	ba 00 00 00 00       	mov    $0x0,%edx
 4c4:	f7 f6                	div    %esi
 4c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cd:	75 c7                	jne    496 <printint+0x39>
  if(neg)
 4cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d3:	74 10                	je     4e5 <printint+0x88>
    buf[i++] = '-';
 4d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d8:	8d 50 01             	lea    0x1(%eax),%edx
 4db:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4de:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4e3:	eb 1f                	jmp    504 <printint+0xa7>
 4e5:	eb 1d                	jmp    504 <printint+0xa7>
    putc(fd, buf[i]);
 4e7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ed:	01 d0                	add    %edx,%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	0f be c0             	movsbl %al,%eax
 4f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	89 04 24             	mov    %eax,(%esp)
 4ff:	e8 31 ff ff ff       	call   435 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 504:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50c:	79 d9                	jns    4e7 <printint+0x8a>
    putc(fd, buf[i]);
}
 50e:	83 c4 30             	add    $0x30,%esp
 511:	5b                   	pop    %ebx
 512:	5e                   	pop    %esi
 513:	5d                   	pop    %ebp
 514:	c3                   	ret    

00000515 <printlong>:

static void
printlong(int fd, unsigned long long xx, int base, int sgn)
{
 515:	55                   	push   %ebp
 516:	89 e5                	mov    %esp,%ebp
 518:	83 ec 38             	sub    $0x38,%esp
 51b:	8b 45 0c             	mov    0xc(%ebp),%eax
 51e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 521:	8b 45 10             	mov    0x10(%ebp),%eax
 524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
 527:	8b 45 e0             	mov    -0x20(%ebp),%eax
 52a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 52d:	89 d0                	mov    %edx,%eax
 52f:	31 d2                	xor    %edx,%edx
 531:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
 534:	8b 45 e0             	mov    -0x20(%ebp),%eax
 537:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(fd, upper, 16, 0);
 53a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53e:	74 22                	je     562 <printlong+0x4d>
 540:	8b 45 f4             	mov    -0xc(%ebp),%eax
 543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 54a:	00 
 54b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 552:	00 
 553:	89 44 24 04          	mov    %eax,0x4(%esp)
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 fb fe ff ff       	call   45d <printint>
    printint(fd, lower, 16, 0);
 562:	8b 45 f0             	mov    -0x10(%ebp),%eax
 565:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 56c:	00 
 56d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 574:	00 
 575:	89 44 24 04          	mov    %eax,0x4(%esp)
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	89 04 24             	mov    %eax,(%esp)
 57f:	e8 d9 fe ff ff       	call   45d <printint>
}
 584:	c9                   	leave  
 585:	c3                   	ret    

00000586 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
// bdg 10/05/2015: Add %l
void
printf(int fd, char *fmt, ...)
{
 586:	55                   	push   %ebp
 587:	89 e5                	mov    %esp,%ebp
 589:	83 ec 48             	sub    $0x48,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 58c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 593:	8d 45 0c             	lea    0xc(%ebp),%eax
 596:	83 c0 04             	add    $0x4,%eax
 599:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 59c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5a3:	e9 ba 01 00 00       	jmp    762 <printf+0x1dc>
    c = fmt[i] & 0xff;
 5a8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ae:	01 d0                	add    %edx,%eax
 5b0:	0f b6 00             	movzbl (%eax),%eax
 5b3:	0f be c0             	movsbl %al,%eax
 5b6:	25 ff 00 00 00       	and    $0xff,%eax
 5bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c2:	75 2c                	jne    5f0 <printf+0x6a>
      if(c == '%'){
 5c4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c8:	75 0c                	jne    5d6 <printf+0x50>
        state = '%';
 5ca:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5d1:	e9 88 01 00 00       	jmp    75e <printf+0x1d8>
      } else {
        putc(fd, c);
 5d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d9:	0f be c0             	movsbl %al,%eax
 5dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	89 04 24             	mov    %eax,(%esp)
 5e6:	e8 4a fe ff ff       	call   435 <putc>
 5eb:	e9 6e 01 00 00       	jmp    75e <printf+0x1d8>
      }
    } else if(state == '%'){
 5f0:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5f4:	0f 85 64 01 00 00    	jne    75e <printf+0x1d8>
      if(c == 'd'){
 5fa:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5fe:	75 2d                	jne    62d <printf+0xa7>
        printint(fd, *ap, 10, 1);
 600:	8b 45 e8             	mov    -0x18(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 60c:	00 
 60d:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 614:	00 
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 39 fe ff ff       	call   45d <printint>
        ap++;
 624:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 628:	e9 2a 01 00 00       	jmp    757 <printf+0x1d1>
      } else if(c == 'l') {
 62d:	83 7d e4 6c          	cmpl   $0x6c,-0x1c(%ebp)
 631:	75 38                	jne    66b <printf+0xe5>
        printlong(fd, *(unsigned long long *)ap, 10, 0);
 633:	8b 45 e8             	mov    -0x18(%ebp),%eax
 636:	8b 50 04             	mov    0x4(%eax),%edx
 639:	8b 00                	mov    (%eax),%eax
 63b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 642:	00 
 643:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
 64a:	00 
 64b:	89 44 24 04          	mov    %eax,0x4(%esp)
 64f:	89 54 24 08          	mov    %edx,0x8(%esp)
 653:	8b 45 08             	mov    0x8(%ebp),%eax
 656:	89 04 24             	mov    %eax,(%esp)
 659:	e8 b7 fe ff ff       	call   515 <printlong>
        // long longs take up 2 argument slots
        ap++;
 65e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        ap++;
 662:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 666:	e9 ec 00 00 00       	jmp    757 <printf+0x1d1>
      } else if(c == 'x' || c == 'p'){
 66b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 66f:	74 06                	je     677 <printf+0xf1>
 671:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 675:	75 2d                	jne    6a4 <printf+0x11e>
        printint(fd, *ap, 16, 0);
 677:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 683:	00 
 684:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 68b:	00 
 68c:	89 44 24 04          	mov    %eax,0x4(%esp)
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	89 04 24             	mov    %eax,(%esp)
 696:	e8 c2 fd ff ff       	call   45d <printint>
        ap++;
 69b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69f:	e9 b3 00 00 00       	jmp    757 <printf+0x1d1>
      } else if(c == 's'){
 6a4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6a8:	75 45                	jne    6ef <printf+0x169>
        s = (char*)*ap;
 6aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ad:	8b 00                	mov    (%eax),%eax
 6af:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ba:	75 09                	jne    6c5 <printf+0x13f>
          s = "(null)";
 6bc:	c7 45 f4 b6 09 00 00 	movl   $0x9b6,-0xc(%ebp)
        while(*s != 0){
 6c3:	eb 1e                	jmp    6e3 <printf+0x15d>
 6c5:	eb 1c                	jmp    6e3 <printf+0x15d>
          putc(fd, *s);
 6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ca:	0f b6 00             	movzbl (%eax),%eax
 6cd:	0f be c0             	movsbl %al,%eax
 6d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 56 fd ff ff       	call   435 <putc>
          s++;
 6df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e6:	0f b6 00             	movzbl (%eax),%eax
 6e9:	84 c0                	test   %al,%al
 6eb:	75 da                	jne    6c7 <printf+0x141>
 6ed:	eb 68                	jmp    757 <printf+0x1d1>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ef:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6f3:	75 1d                	jne    712 <printf+0x18c>
        putc(fd, *ap);
 6f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	0f be c0             	movsbl %al,%eax
 6fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	89 04 24             	mov    %eax,(%esp)
 707:	e8 29 fd ff ff       	call   435 <putc>
        ap++;
 70c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 710:	eb 45                	jmp    757 <printf+0x1d1>
      } else if(c == '%'){
 712:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 716:	75 17                	jne    72f <printf+0x1a9>
        putc(fd, c);
 718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71b:	0f be c0             	movsbl %al,%eax
 71e:	89 44 24 04          	mov    %eax,0x4(%esp)
 722:	8b 45 08             	mov    0x8(%ebp),%eax
 725:	89 04 24             	mov    %eax,(%esp)
 728:	e8 08 fd ff ff       	call   435 <putc>
 72d:	eb 28                	jmp    757 <printf+0x1d1>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 72f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 736:	00 
 737:	8b 45 08             	mov    0x8(%ebp),%eax
 73a:	89 04 24             	mov    %eax,(%esp)
 73d:	e8 f3 fc ff ff       	call   435 <putc>
        putc(fd, c);
 742:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	89 44 24 04          	mov    %eax,0x4(%esp)
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
 74f:	89 04 24             	mov    %eax,(%esp)
 752:	e8 de fc ff ff       	call   435 <putc>
      }
      state = 0;
 757:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 75e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 762:	8b 55 0c             	mov    0xc(%ebp),%edx
 765:	8b 45 f0             	mov    -0x10(%ebp),%eax
 768:	01 d0                	add    %edx,%eax
 76a:	0f b6 00             	movzbl (%eax),%eax
 76d:	84 c0                	test   %al,%al
 76f:	0f 85 33 fe ff ff    	jne    5a8 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 775:	c9                   	leave  
 776:	c3                   	ret    

00000777 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 777:	55                   	push   %ebp
 778:	89 e5                	mov    %esp,%ebp
 77a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77d:	8b 45 08             	mov    0x8(%ebp),%eax
 780:	83 e8 08             	sub    $0x8,%eax
 783:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	a1 68 0c 00 00       	mov    0xc68,%eax
 78b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 78e:	eb 24                	jmp    7b4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	8b 45 fc             	mov    -0x4(%ebp),%eax
 793:	8b 00                	mov    (%eax),%eax
 795:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 798:	77 12                	ja     7ac <free+0x35>
 79a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a0:	77 24                	ja     7c6 <free+0x4f>
 7a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a5:	8b 00                	mov    (%eax),%eax
 7a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7aa:	77 1a                	ja     7c6 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7af:	8b 00                	mov    (%eax),%eax
 7b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ba:	76 d4                	jbe    790 <free+0x19>
 7bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bf:	8b 00                	mov    (%eax),%eax
 7c1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c4:	76 ca                	jbe    790 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c9:	8b 40 04             	mov    0x4(%eax),%eax
 7cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	01 c2                	add    %eax,%edx
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	39 c2                	cmp    %eax,%edx
 7df:	75 24                	jne    805 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e4:	8b 50 04             	mov    0x4(%eax),%edx
 7e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	8b 40 04             	mov    0x4(%eax),%eax
 7ef:	01 c2                	add    %eax,%edx
 7f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	8b 10                	mov    (%eax),%edx
 7fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 801:	89 10                	mov    %edx,(%eax)
 803:	eb 0a                	jmp    80f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8b 10                	mov    (%eax),%edx
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 40 04             	mov    0x4(%eax),%eax
 815:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	01 d0                	add    %edx,%eax
 821:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 824:	75 20                	jne    846 <free+0xcf>
    p->s.size += bp->s.size;
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 50 04             	mov    0x4(%eax),%edx
 82c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82f:	8b 40 04             	mov    0x4(%eax),%eax
 832:	01 c2                	add    %eax,%edx
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 83a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
 844:	eb 08                	jmp    84e <free+0xd7>
  } else
    p->s.ptr = bp;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 55 f8             	mov    -0x8(%ebp),%edx
 84c:	89 10                	mov    %edx,(%eax)
  freep = p;
 84e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 851:	a3 68 0c 00 00       	mov    %eax,0xc68
}
 856:	c9                   	leave  
 857:	c3                   	ret    

00000858 <morecore>:

static Header*
morecore(uint nu)
{
 858:	55                   	push   %ebp
 859:	89 e5                	mov    %esp,%ebp
 85b:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 85e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 865:	77 07                	ja     86e <morecore+0x16>
    nu = 4096;
 867:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 86e:	8b 45 08             	mov    0x8(%ebp),%eax
 871:	c1 e0 03             	shl    $0x3,%eax
 874:	89 04 24             	mov    %eax,(%esp)
 877:	e8 91 fb ff ff       	call   40d <sbrk>
 87c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 87f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 883:	75 07                	jne    88c <morecore+0x34>
    return 0;
 885:	b8 00 00 00 00       	mov    $0x0,%eax
 88a:	eb 22                	jmp    8ae <morecore+0x56>
  hp = (Header*)p;
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 892:	8b 45 f0             	mov    -0x10(%ebp),%eax
 895:	8b 55 08             	mov    0x8(%ebp),%edx
 898:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 89b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89e:	83 c0 08             	add    $0x8,%eax
 8a1:	89 04 24             	mov    %eax,(%esp)
 8a4:	e8 ce fe ff ff       	call   777 <free>
  return freep;
 8a9:	a1 68 0c 00 00       	mov    0xc68,%eax
}
 8ae:	c9                   	leave  
 8af:	c3                   	ret    

000008b0 <malloc>:

void*
malloc(uint nbytes)
{
 8b0:	55                   	push   %ebp
 8b1:	89 e5                	mov    %esp,%ebp
 8b3:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	8b 45 08             	mov    0x8(%ebp),%eax
 8b9:	83 c0 07             	add    $0x7,%eax
 8bc:	c1 e8 03             	shr    $0x3,%eax
 8bf:	83 c0 01             	add    $0x1,%eax
 8c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c5:	a1 68 0c 00 00       	mov    0xc68,%eax
 8ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d1:	75 23                	jne    8f6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8d3:	c7 45 f0 60 0c 00 00 	movl   $0xc60,-0x10(%ebp)
 8da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dd:	a3 68 0c 00 00       	mov    %eax,0xc68
 8e2:	a1 68 0c 00 00       	mov    0xc68,%eax
 8e7:	a3 60 0c 00 00       	mov    %eax,0xc60
    base.s.size = 0;
 8ec:	c7 05 64 0c 00 00 00 	movl   $0x0,0xc64
 8f3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 901:	8b 40 04             	mov    0x4(%eax),%eax
 904:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 907:	72 4d                	jb     956 <malloc+0xa6>
      if(p->s.size == nunits)
 909:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90c:	8b 40 04             	mov    0x4(%eax),%eax
 90f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 912:	75 0c                	jne    920 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	8b 10                	mov    (%eax),%edx
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	89 10                	mov    %edx,(%eax)
 91e:	eb 26                	jmp    946 <malloc+0x96>
      else {
        p->s.size -= nunits;
 920:	8b 45 f4             	mov    -0xc(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	2b 45 ec             	sub    -0x14(%ebp),%eax
 929:	89 c2                	mov    %eax,%edx
 92b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	c1 e0 03             	shl    $0x3,%eax
 93a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 55 ec             	mov    -0x14(%ebp),%edx
 943:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 946:	8b 45 f0             	mov    -0x10(%ebp),%eax
 949:	a3 68 0c 00 00       	mov    %eax,0xc68
      return (void*)(p + 1);
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	83 c0 08             	add    $0x8,%eax
 954:	eb 38                	jmp    98e <malloc+0xde>
    }
    if(p == freep)
 956:	a1 68 0c 00 00       	mov    0xc68,%eax
 95b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 95e:	75 1b                	jne    97b <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 960:	8b 45 ec             	mov    -0x14(%ebp),%eax
 963:	89 04 24             	mov    %eax,(%esp)
 966:	e8 ed fe ff ff       	call   858 <morecore>
 96b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 96e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 972:	75 07                	jne    97b <malloc+0xcb>
        return 0;
 974:	b8 00 00 00 00       	mov    $0x0,%eax
 979:	eb 13                	jmp    98e <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	8b 00                	mov    (%eax),%eax
 986:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 989:	e9 70 ff ff ff       	jmp    8fe <malloc+0x4e>
}
 98e:	c9                   	leave  
 98f:	c3                   	ret    
