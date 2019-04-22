
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 40 e0 10 80       	mov    $0x8010e040,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b8 38 10 80       	mov    $0x801038b8,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 44 89 10 	movl   $0x80108944,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
80100049:	e8 4b 50 00 00       	call   80105099 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 50 1f 11 80 44 	movl   $0x80111f44,0x80111f50
80100055:	1f 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 54 1f 11 80 44 	movl   $0x80111f44,0x80111f54
8010005f:	1f 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 e0 10 80 	movl   $0x8010e074,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 54 1f 11 80    	mov    0x80111f54,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 44 1f 11 80 	movl   $0x80111f44,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 54 1f 11 80       	mov    0x80111f54,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 54 1f 11 80       	mov    %eax,0x80111f54

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 44 1f 11 80 	cmpl   $0x80111f44,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
801000bd:	e8 f8 4f 00 00       	call   801050ba <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 54 1f 11 80       	mov    0x80111f54,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
80100104:	e8 13 50 00 00       	call   8010511c <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 40 e0 10 	movl   $0x8010e040,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 cc 4c 00 00       	call   80104df0 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 44 1f 11 80 	cmpl   $0x80111f44,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 50 1f 11 80       	mov    0x80111f50,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
8010017c:	e8 9b 4f 00 00       	call   8010511c <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 44 1f 11 80 	cmpl   $0x80111f44,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 4b 89 10 80 	movl   $0x8010894b,(%esp)
8010019f:	e8 33 04 00 00       	call   801005d7 <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 1c 27 00 00       	call   801028f4 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 5c 89 10 80 	movl   $0x8010895c,(%esp)
801001f6:	e8 dc 03 00 00       	call   801005d7 <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 df 26 00 00       	call   801028f4 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 63 89 10 80 	movl   $0x80108963,(%esp)
80100230:	e8 a2 03 00 00       	call   801005d7 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
8010023c:	e8 79 4e 00 00       	call   801050ba <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 54 1f 11 80    	mov    0x80111f54,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 44 1f 11 80 	movl   $0x80111f44,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 54 1f 11 80       	mov    0x80111f54,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 54 1f 11 80       	mov    %eax,0x80111f54

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 27 4c 00 00       	call   80104ec9 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 40 e0 10 80 	movl   $0x8010e040,(%esp)
801002a9:	e8 6e 4e 00 00       	call   8010511c <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 79 04 00 00       	call   80100808 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <printlong>:

static void
printlong(unsigned long long xx, int base, int sgn)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
801003a6:	8b 45 08             	mov    0x8(%ebp),%eax
801003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
801003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801003b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801003b8:	89 d0                	mov    %edx,%eax
801003ba:	31 d2                	xor    %edx,%edx
801003bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
801003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801003c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(upper, 16, 0);
801003c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003c9:	74 1b                	je     801003e6 <printlong+0x46>
801003cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801003d5:	00 
801003d6:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801003dd:	00 
801003de:	89 04 24             	mov    %eax,(%esp)
801003e1:	e8 0b ff ff ff       	call   801002f1 <printint>
    printint(lower, 16, 0);
801003e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801003f0:	00 
801003f1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801003f8:	00 
801003f9:	89 04 24             	mov    %eax,(%esp)
801003fc:	e8 f0 fe ff ff       	call   801002f1 <printint>
}
80100401:	c9                   	leave  
80100402:	c3                   	ret    

80100403 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100403:	55                   	push   %ebp
80100404:	89 e5                	mov    %esp,%ebp
80100406:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100409:	a1 14 c6 10 80       	mov    0x8010c614,%eax
8010040e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100411:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100415:	74 0c                	je     80100423 <cprintf+0x20>
    acquire(&cons.lock);
80100417:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
8010041e:	e8 97 4c 00 00       	call   801050ba <acquire>

  if (fmt == 0)
80100423:	8b 45 08             	mov    0x8(%ebp),%eax
80100426:	85 c0                	test   %eax,%eax
80100428:	75 0c                	jne    80100436 <cprintf+0x33>
    panic("null fmt");
8010042a:	c7 04 24 6a 89 10 80 	movl   $0x8010896a,(%esp)
80100431:	e8 a1 01 00 00       	call   801005d7 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100436:	8d 45 0c             	lea    0xc(%ebp),%eax
80100439:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100443:	e9 5b 01 00 00       	jmp    801005a3 <cprintf+0x1a0>
    if(c != '%'){
80100448:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044c:	74 10                	je     8010045e <cprintf+0x5b>
      consputc(c);
8010044e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100451:	89 04 24             	mov    %eax,(%esp)
80100454:	e8 af 03 00 00       	call   80100808 <consputc>
      continue;
80100459:	e9 41 01 00 00       	jmp    8010059f <cprintf+0x19c>
    }
    c = fmt[++i] & 0xff;
8010045e:	8b 55 08             	mov    0x8(%ebp),%edx
80100461:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100468:	01 d0                	add    %edx,%eax
8010046a:	0f b6 00             	movzbl (%eax),%eax
8010046d:	0f be c0             	movsbl %al,%eax
80100470:	25 ff 00 00 00       	and    $0xff,%eax
80100475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010047c:	75 05                	jne    80100483 <cprintf+0x80>
      break;
8010047e:	e9 40 01 00 00       	jmp    801005c3 <cprintf+0x1c0>
    switch(c){
80100483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100486:	83 f8 6c             	cmp    $0x6c,%eax
80100489:	74 58                	je     801004e3 <cprintf+0xe0>
8010048b:	83 f8 6c             	cmp    $0x6c,%eax
8010048e:	7f 13                	jg     801004a3 <cprintf+0xa0>
80100490:	83 f8 25             	cmp    $0x25,%eax
80100493:	0f 84 e0 00 00 00    	je     80100579 <cprintf+0x176>
80100499:	83 f8 64             	cmp    $0x64,%eax
8010049c:	74 1d                	je     801004bb <cprintf+0xb8>
8010049e:	e9 e4 00 00 00       	jmp    80100587 <cprintf+0x184>
801004a3:	83 f8 73             	cmp    $0x73,%eax
801004a6:	0f 84 8d 00 00 00    	je     80100539 <cprintf+0x136>
801004ac:	83 f8 78             	cmp    $0x78,%eax
801004af:	74 63                	je     80100514 <cprintf+0x111>
801004b1:	83 f8 70             	cmp    $0x70,%eax
801004b4:	74 5e                	je     80100514 <cprintf+0x111>
801004b6:	e9 cc 00 00 00       	jmp    80100587 <cprintf+0x184>
    case 'd':
      printint(*argp++, 10, 1);
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801004cd:	00 
801004ce:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801004d5:	00 
801004d6:	89 04 24             	mov    %eax,(%esp)
801004d9:	e8 13 fe ff ff       	call   801002f1 <printint>
      break;
801004de:	e9 bc 00 00 00       	jmp    8010059f <cprintf+0x19c>
    case 'l':
        printlong(*(unsigned long long *)argp, 10, 0);
801004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e6:	8b 50 04             	mov    0x4(%eax),%edx
801004e9:	8b 00                	mov    (%eax),%eax
801004eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801004f2:	00 
801004f3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
801004fa:	00 
801004fb:	89 04 24             	mov    %eax,(%esp)
801004fe:	89 54 24 04          	mov    %edx,0x4(%esp)
80100502:	e8 99 fe ff ff       	call   801003a0 <printlong>
        // long longs take up 2 argument slots
        argp++;
80100507:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
        argp++;
8010050b:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
        break;
8010050f:	e9 8b 00 00 00       	jmp    8010059f <cprintf+0x19c>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100517:	8d 50 04             	lea    0x4(%eax),%edx
8010051a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010051d:	8b 00                	mov    (%eax),%eax
8010051f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100526:	00 
80100527:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010052e:	00 
8010052f:	89 04 24             	mov    %eax,(%esp)
80100532:	e8 ba fd ff ff       	call   801002f1 <printint>
      break;
80100537:	eb 66                	jmp    8010059f <cprintf+0x19c>
    case 's':
      if((s = (char*)*argp++) == 0)
80100539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053c:	8d 50 04             	lea    0x4(%eax),%edx
8010053f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100542:	8b 00                	mov    (%eax),%eax
80100544:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100547:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054b:	75 09                	jne    80100556 <cprintf+0x153>
        s = "(null)";
8010054d:	c7 45 ec 73 89 10 80 	movl   $0x80108973,-0x14(%ebp)
      for(; *s; s++)
80100554:	eb 17                	jmp    8010056d <cprintf+0x16a>
80100556:	eb 15                	jmp    8010056d <cprintf+0x16a>
        consputc(*s);
80100558:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010055b:	0f b6 00             	movzbl (%eax),%eax
8010055e:	0f be c0             	movsbl %al,%eax
80100561:	89 04 24             	mov    %eax,(%esp)
80100564:	e8 9f 02 00 00       	call   80100808 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100569:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100570:	0f b6 00             	movzbl (%eax),%eax
80100573:	84 c0                	test   %al,%al
80100575:	75 e1                	jne    80100558 <cprintf+0x155>
        consputc(*s);
      break;
80100577:	eb 26                	jmp    8010059f <cprintf+0x19c>
    case '%':
      consputc('%');
80100579:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
80100580:	e8 83 02 00 00       	call   80100808 <consputc>
      break;
80100585:	eb 18                	jmp    8010059f <cprintf+0x19c>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100587:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010058e:	e8 75 02 00 00       	call   80100808 <consputc>
      consputc(c);
80100593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100596:	89 04 24             	mov    %eax,(%esp)
80100599:	e8 6a 02 00 00       	call   80100808 <consputc>
      break;
8010059e:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010059f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005a3:	8b 55 08             	mov    0x8(%ebp),%edx
801005a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a9:	01 d0                	add    %edx,%eax
801005ab:	0f b6 00             	movzbl (%eax),%eax
801005ae:	0f be c0             	movsbl %al,%eax
801005b1:	25 ff 00 00 00       	and    $0xff,%eax
801005b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005bd:	0f 85 85 fe ff ff    	jne    80100448 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
801005c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005c7:	74 0c                	je     801005d5 <cprintf+0x1d2>
    release(&cons.lock);
801005c9:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801005d0:	e8 47 4b 00 00       	call   8010511c <release>
}
801005d5:	c9                   	leave  
801005d6:	c3                   	ret    

801005d7 <panic>:

void
panic(char *s)
{
801005d7:	55                   	push   %ebp
801005d8:	89 e5                	mov    %esp,%ebp
801005da:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
801005dd:	e8 09 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
801005e2:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
801005e9:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
801005ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801005f2:	0f b6 00             	movzbl (%eax),%eax
801005f5:	0f b6 c0             	movzbl %al,%eax
801005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801005fc:	c7 04 24 7a 89 10 80 	movl   $0x8010897a,(%esp)
80100603:	e8 fb fd ff ff       	call   80100403 <cprintf>
  cprintf(s);
80100608:	8b 45 08             	mov    0x8(%ebp),%eax
8010060b:	89 04 24             	mov    %eax,(%esp)
8010060e:	e8 f0 fd ff ff       	call   80100403 <cprintf>
  cprintf("\n");
80100613:	c7 04 24 89 89 10 80 	movl   $0x80108989,(%esp)
8010061a:	e8 e4 fd ff ff       	call   80100403 <cprintf>
  getcallerpcs(&s, pcs);
8010061f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100622:	89 44 24 04          	mov    %eax,0x4(%esp)
80100626:	8d 45 08             	lea    0x8(%ebp),%eax
80100629:	89 04 24             	mov    %eax,(%esp)
8010062c:	e8 3a 4b 00 00       	call   8010516b <getcallerpcs>
  for(i=0; i<10; i++)
80100631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100638:	eb 1b                	jmp    80100655 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063d:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100641:	89 44 24 04          	mov    %eax,0x4(%esp)
80100645:	c7 04 24 8b 89 10 80 	movl   $0x8010898b,(%esp)
8010064c:	e8 b2 fd ff ff       	call   80100403 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
80100651:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100655:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100659:	7e df                	jle    8010063a <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
8010065b:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
80100662:	00 00 00 
  for(;;)
    ;
80100665:	eb fe                	jmp    80100665 <panic+0x8e>

80100667 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100667:	55                   	push   %ebp
80100668:	89 e5                	mov    %esp,%ebp
8010066a:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010066d:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100674:	00 
80100675:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010067c:	e8 4c fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
80100681:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100688:	e8 23 fc ff ff       	call   801002b0 <inb>
8010068d:	0f b6 c0             	movzbl %al,%eax
80100690:	c1 e0 08             	shl    $0x8,%eax
80100693:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100696:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010069d:	00 
8010069e:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006a5:	e8 23 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
801006aa:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801006b1:	e8 fa fb ff ff       	call   801002b0 <inb>
801006b6:	0f b6 c0             	movzbl %al,%eax
801006b9:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006bc:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006c0:	75 30                	jne    801006f2 <cgaputc+0x8b>
    pos += 80 - pos%80;
801006c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006c5:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006ca:	89 c8                	mov    %ecx,%eax
801006cc:	f7 ea                	imul   %edx
801006ce:	c1 fa 05             	sar    $0x5,%edx
801006d1:	89 c8                	mov    %ecx,%eax
801006d3:	c1 f8 1f             	sar    $0x1f,%eax
801006d6:	29 c2                	sub    %eax,%edx
801006d8:	89 d0                	mov    %edx,%eax
801006da:	c1 e0 02             	shl    $0x2,%eax
801006dd:	01 d0                	add    %edx,%eax
801006df:	c1 e0 04             	shl    $0x4,%eax
801006e2:	29 c1                	sub    %eax,%ecx
801006e4:	89 ca                	mov    %ecx,%edx
801006e6:	b8 50 00 00 00       	mov    $0x50,%eax
801006eb:	29 d0                	sub    %edx,%eax
801006ed:	01 45 f4             	add    %eax,-0xc(%ebp)
801006f0:	eb 35                	jmp    80100727 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006f2:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006f9:	75 0c                	jne    80100707 <cgaputc+0xa0>
    if(pos > 0) --pos;
801006fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ff:	7e 26                	jle    80100727 <cgaputc+0xc0>
80100701:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100705:	eb 20                	jmp    80100727 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100707:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100710:	8d 50 01             	lea    0x1(%eax),%edx
80100713:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100716:	01 c0                	add    %eax,%eax
80100718:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010071b:	8b 45 08             	mov    0x8(%ebp),%eax
8010071e:	0f b6 c0             	movzbl %al,%eax
80100721:	80 cc 07             	or     $0x7,%ah
80100724:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100727:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010072b:	78 09                	js     80100736 <cgaputc+0xcf>
8010072d:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100734:	7e 0c                	jle    80100742 <cgaputc+0xdb>
    panic("pos under/overflow");
80100736:	c7 04 24 8f 89 10 80 	movl   $0x8010898f,(%esp)
8010073d:	e8 95 fe ff ff       	call   801005d7 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
80100742:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100749:	7e 53                	jle    8010079e <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010074b:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100750:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100756:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010075b:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100762:	00 
80100763:	89 54 24 04          	mov    %edx,0x4(%esp)
80100767:	89 04 24             	mov    %eax,(%esp)
8010076a:	e8 6e 4c 00 00       	call   801053dd <memmove>
    pos -= 80;
8010076f:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100773:	b8 80 07 00 00       	mov    $0x780,%eax
80100778:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010077b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100786:	01 c9                	add    %ecx,%ecx
80100788:	01 c8                	add    %ecx,%eax
8010078a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010078e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100795:	00 
80100796:	89 04 24             	mov    %eax,(%esp)
80100799:	e8 70 4b 00 00       	call   8010530e <memset>
  }
  
  outb(CRTPORT, 14);
8010079e:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801007a5:	00 
801007a6:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007ad:	e8 1b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007b5:	c1 f8 08             	sar    $0x8,%eax
801007b8:	0f b6 c0             	movzbl %al,%eax
801007bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801007bf:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007c6:	e8 02 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
801007cb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801007d2:	00 
801007d3:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007da:	e8 ee fa ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
801007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e2:	0f b6 c0             	movzbl %al,%eax
801007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801007e9:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007f0:	e8 d8 fa ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
801007f5:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007fd:	01 d2                	add    %edx,%edx
801007ff:	01 d0                	add    %edx,%eax
80100801:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100806:	c9                   	leave  
80100807:	c3                   	ret    

80100808 <consputc>:

void
consputc(int c)
{
80100808:	55                   	push   %ebp
80100809:	89 e5                	mov    %esp,%ebp
8010080b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010080e:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100813:	85 c0                	test   %eax,%eax
80100815:	74 07                	je     8010081e <consputc+0x16>
    cli();
80100817:	e8 cf fa ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010081c:	eb fe                	jmp    8010081c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010081e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100825:	75 26                	jne    8010084d <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100827:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010082e:	e8 14 65 00 00       	call   80106d47 <uartputc>
80100833:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010083a:	e8 08 65 00 00       	call   80106d47 <uartputc>
8010083f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100846:	e8 fc 64 00 00       	call   80106d47 <uartputc>
8010084b:	eb 0b                	jmp    80100858 <consputc+0x50>
  } else
    uartputc(c);
8010084d:	8b 45 08             	mov    0x8(%ebp),%eax
80100850:	89 04 24             	mov    %eax,(%esp)
80100853:	e8 ef 64 00 00       	call   80106d47 <uartputc>
  cgaputc(c);
80100858:	8b 45 08             	mov    0x8(%ebp),%eax
8010085b:	89 04 24             	mov    %eax,(%esp)
8010085e:	e8 04 fe ff ff       	call   80100667 <cgaputc>
}
80100863:	c9                   	leave  
80100864:	c3                   	ret    

80100865 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100865:	55                   	push   %ebp
80100866:	89 e5                	mov    %esp,%ebp
80100868:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
8010086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100872:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100879:	e8 3c 48 00 00       	call   801050ba <acquire>
  while((c = getc()) >= 0){
8010087e:	e9 39 01 00 00       	jmp    801009bc <consoleintr+0x157>
    switch(c){
80100883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100886:	83 f8 10             	cmp    $0x10,%eax
80100889:	74 1e                	je     801008a9 <consoleintr+0x44>
8010088b:	83 f8 10             	cmp    $0x10,%eax
8010088e:	7f 0a                	jg     8010089a <consoleintr+0x35>
80100890:	83 f8 08             	cmp    $0x8,%eax
80100893:	74 66                	je     801008fb <consoleintr+0x96>
80100895:	e9 93 00 00 00       	jmp    8010092d <consoleintr+0xc8>
8010089a:	83 f8 15             	cmp    $0x15,%eax
8010089d:	74 31                	je     801008d0 <consoleintr+0x6b>
8010089f:	83 f8 7f             	cmp    $0x7f,%eax
801008a2:	74 57                	je     801008fb <consoleintr+0x96>
801008a4:	e9 84 00 00 00       	jmp    8010092d <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
801008a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008b0:	e9 07 01 00 00       	jmp    801009bc <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b5:	a1 e8 21 11 80       	mov    0x801121e8,%eax
801008ba:	83 e8 01             	sub    $0x1,%eax
801008bd:	a3 e8 21 11 80       	mov    %eax,0x801121e8
        consputc(BACKSPACE);
801008c2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008c9:	e8 3a ff ff ff       	call   80100808 <consputc>
801008ce:	eb 01                	jmp    801008d1 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008d0:	90                   	nop
801008d1:	8b 15 e8 21 11 80    	mov    0x801121e8,%edx
801008d7:	a1 e4 21 11 80       	mov    0x801121e4,%eax
801008dc:	39 c2                	cmp    %eax,%edx
801008de:	74 16                	je     801008f6 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e0:	a1 e8 21 11 80       	mov    0x801121e8,%eax
801008e5:	83 e8 01             	sub    $0x1,%eax
801008e8:	83 e0 7f             	and    $0x7f,%eax
801008eb:	0f b6 80 60 21 11 80 	movzbl -0x7feedea0(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008f2:	3c 0a                	cmp    $0xa,%al
801008f4:	75 bf                	jne    801008b5 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008f6:	e9 c1 00 00 00       	jmp    801009bc <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fb:	8b 15 e8 21 11 80    	mov    0x801121e8,%edx
80100901:	a1 e4 21 11 80       	mov    0x801121e4,%eax
80100906:	39 c2                	cmp    %eax,%edx
80100908:	74 1e                	je     80100928 <consoleintr+0xc3>
        input.e--;
8010090a:	a1 e8 21 11 80       	mov    0x801121e8,%eax
8010090f:	83 e8 01             	sub    $0x1,%eax
80100912:	a3 e8 21 11 80       	mov    %eax,0x801121e8
        consputc(BACKSPACE);
80100917:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091e:	e8 e5 fe ff ff       	call   80100808 <consputc>
      }
      break;
80100923:	e9 94 00 00 00       	jmp    801009bc <consoleintr+0x157>
80100928:	e9 8f 00 00 00       	jmp    801009bc <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010092d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100931:	0f 84 84 00 00 00    	je     801009bb <consoleintr+0x156>
80100937:	8b 15 e8 21 11 80    	mov    0x801121e8,%edx
8010093d:	a1 e0 21 11 80       	mov    0x801121e0,%eax
80100942:	29 c2                	sub    %eax,%edx
80100944:	89 d0                	mov    %edx,%eax
80100946:	83 f8 7f             	cmp    $0x7f,%eax
80100949:	77 70                	ja     801009bb <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
8010094b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010094f:	74 05                	je     80100956 <consoleintr+0xf1>
80100951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100954:	eb 05                	jmp    8010095b <consoleintr+0xf6>
80100956:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010095e:	a1 e8 21 11 80       	mov    0x801121e8,%eax
80100963:	8d 50 01             	lea    0x1(%eax),%edx
80100966:	89 15 e8 21 11 80    	mov    %edx,0x801121e8
8010096c:	83 e0 7f             	and    $0x7f,%eax
8010096f:	89 c2                	mov    %eax,%edx
80100971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100974:	88 82 60 21 11 80    	mov    %al,-0x7feedea0(%edx)
        consputc(c);
8010097a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010097d:	89 04 24             	mov    %eax,(%esp)
80100980:	e8 83 fe ff ff       	call   80100808 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100985:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100989:	74 18                	je     801009a3 <consoleintr+0x13e>
8010098b:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010098f:	74 12                	je     801009a3 <consoleintr+0x13e>
80100991:	a1 e8 21 11 80       	mov    0x801121e8,%eax
80100996:	8b 15 e0 21 11 80    	mov    0x801121e0,%edx
8010099c:	83 ea 80             	sub    $0xffffff80,%edx
8010099f:	39 d0                	cmp    %edx,%eax
801009a1:	75 18                	jne    801009bb <consoleintr+0x156>
          input.w = input.e;
801009a3:	a1 e8 21 11 80       	mov    0x801121e8,%eax
801009a8:	a3 e4 21 11 80       	mov    %eax,0x801121e4
          wakeup(&input.r);
801009ad:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
801009b4:	e8 10 45 00 00       	call   80104ec9 <wakeup>
        }
      }
      break;
801009b9:	eb 00                	jmp    801009bb <consoleintr+0x156>
801009bb:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009bc:	8b 45 08             	mov    0x8(%ebp),%eax
801009bf:	ff d0                	call   *%eax
801009c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009c8:	0f 89 b5 fe ff ff    	jns    80100883 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009ce:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801009d5:	e8 42 47 00 00       	call   8010511c <release>
  if(doprocdump) {
801009da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009de:	74 05                	je     801009e5 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
801009e0:	e8 87 45 00 00       	call   80104f6c <procdump>
  }
}
801009e5:	c9                   	leave  
801009e6:	c3                   	ret    

801009e7 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009e7:	55                   	push   %ebp
801009e8:	89 e5                	mov    %esp,%ebp
801009ea:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
801009ed:	8b 45 08             	mov    0x8(%ebp),%eax
801009f0:	89 04 24             	mov    %eax,(%esp)
801009f3:	e8 cd 10 00 00       	call   80101ac5 <iunlock>
  target = n;
801009f8:	8b 45 10             	mov    0x10(%ebp),%eax
801009fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009fe:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a05:	e8 b0 46 00 00       	call   801050ba <acquire>
  while(n > 0){
80100a0a:	e9 aa 00 00 00       	jmp    80100ab9 <consoleread+0xd2>
    while(input.r == input.w){
80100a0f:	eb 42                	jmp    80100a53 <consoleread+0x6c>
      if(proc->killed){
80100a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a17:	8b 40 24             	mov    0x24(%eax),%eax
80100a1a:	85 c0                	test   %eax,%eax
80100a1c:	74 21                	je     80100a3f <consoleread+0x58>
        release(&cons.lock);
80100a1e:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a25:	e8 f2 46 00 00       	call   8010511c <release>
        ilock(ip);
80100a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2d:	89 04 24             	mov    %eax,(%esp)
80100a30:	e8 3c 0f 00 00       	call   80101971 <ilock>
        return -1;
80100a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a3a:	e9 a5 00 00 00       	jmp    80100ae4 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
80100a3f:	c7 44 24 04 e0 c5 10 	movl   $0x8010c5e0,0x4(%esp)
80100a46:	80 
80100a47:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80100a4e:	e8 9d 43 00 00       	call   80104df0 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a53:	8b 15 e0 21 11 80    	mov    0x801121e0,%edx
80100a59:	a1 e4 21 11 80       	mov    0x801121e4,%eax
80100a5e:	39 c2                	cmp    %eax,%edx
80100a60:	74 af                	je     80100a11 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a62:	a1 e0 21 11 80       	mov    0x801121e0,%eax
80100a67:	8d 50 01             	lea    0x1(%eax),%edx
80100a6a:	89 15 e0 21 11 80    	mov    %edx,0x801121e0
80100a70:	83 e0 7f             	and    $0x7f,%eax
80100a73:	0f b6 80 60 21 11 80 	movzbl -0x7feedea0(%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a80:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a84:	75 19                	jne    80100a9f <consoleread+0xb8>
      if(n < target){
80100a86:	8b 45 10             	mov    0x10(%ebp),%eax
80100a89:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a8c:	73 0f                	jae    80100a9d <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a8e:	a1 e0 21 11 80       	mov    0x801121e0,%eax
80100a93:	83 e8 01             	sub    $0x1,%eax
80100a96:	a3 e0 21 11 80       	mov    %eax,0x801121e0
      }
      break;
80100a9b:	eb 26                	jmp    80100ac3 <consoleread+0xdc>
80100a9d:	eb 24                	jmp    80100ac3 <consoleread+0xdc>
    }
    *dst++ = c;
80100a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa2:	8d 50 01             	lea    0x1(%eax),%edx
80100aa5:	89 55 0c             	mov    %edx,0xc(%ebp)
80100aa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100aab:	88 10                	mov    %dl,(%eax)
    --n;
80100aad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ab1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ab5:	75 02                	jne    80100ab9 <consoleread+0xd2>
      break;
80100ab7:	eb 0a                	jmp    80100ac3 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100ab9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100abd:	0f 8f 4c ff ff ff    	jg     80100a0f <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100ac3:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100aca:	e8 4d 46 00 00       	call   8010511c <release>
  ilock(ip);
80100acf:	8b 45 08             	mov    0x8(%ebp),%eax
80100ad2:	89 04 24             	mov    %eax,(%esp)
80100ad5:	e8 97 0e 00 00       	call   80101971 <ilock>

  return target - n;
80100ada:	8b 45 10             	mov    0x10(%ebp),%eax
80100add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ae0:	29 c2                	sub    %eax,%edx
80100ae2:	89 d0                	mov    %edx,%eax
}
80100ae4:	c9                   	leave  
80100ae5:	c3                   	ret    

80100ae6 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ae6:	55                   	push   %ebp
80100ae7:	89 e5                	mov    %esp,%ebp
80100ae9:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100aec:	8b 45 08             	mov    0x8(%ebp),%eax
80100aef:	89 04 24             	mov    %eax,(%esp)
80100af2:	e8 ce 0f 00 00       	call   80101ac5 <iunlock>
  acquire(&cons.lock);
80100af7:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100afe:	e8 b7 45 00 00       	call   801050ba <acquire>
  for(i = 0; i < n; i++)
80100b03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b0a:	eb 1d                	jmp    80100b29 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100b0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b12:	01 d0                	add    %edx,%eax
80100b14:	0f b6 00             	movzbl (%eax),%eax
80100b17:	0f be c0             	movsbl %al,%eax
80100b1a:	0f b6 c0             	movzbl %al,%eax
80100b1d:	89 04 24             	mov    %eax,(%esp)
80100b20:	e8 e3 fc ff ff       	call   80100808 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b2c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b2f:	7c db                	jl     80100b0c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b31:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100b38:	e8 df 45 00 00       	call   8010511c <release>
  ilock(ip);
80100b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80100b40:	89 04 24             	mov    %eax,(%esp)
80100b43:	e8 29 0e 00 00       	call   80101971 <ilock>

  return n;
80100b48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b4b:	c9                   	leave  
80100b4c:	c3                   	ret    

80100b4d <consoleinit>:

void
consoleinit(void)
{
80100b4d:	55                   	push   %ebp
80100b4e:	89 e5                	mov    %esp,%ebp
80100b50:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100b53:	c7 44 24 04 a2 89 10 	movl   $0x801089a2,0x4(%esp)
80100b5a:	80 
80100b5b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100b62:	e8 32 45 00 00       	call   80105099 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100b67:	c7 05 ac 2b 11 80 e6 	movl   $0x80100ae6,0x80112bac
80100b6e:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b71:	c7 05 a8 2b 11 80 e7 	movl   $0x801009e7,0x80112ba8
80100b78:	09 10 80 
  cons.locking = 1;
80100b7b:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100b82:	00 00 00 

  picenable(IRQ_KBD);
80100b85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b8c:	e8 bf 33 00 00       	call   80103f50 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100b91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b98:	00 
80100b99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ba0:	e8 0b 1f 00 00       	call   80102ab0 <ioapicenable>
}
80100ba5:	c9                   	leave  
80100ba6:	c3                   	ret    

80100ba7 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba7:	55                   	push   %ebp
80100ba8:	89 e5                	mov    %esp,%ebp
80100baa:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100bb0:	e8 fc 29 00 00       	call   801035b1 <begin_op>
  if((ip = namei(path)) == 0){
80100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80100bb8:	89 04 24             	mov    %eax,(%esp)
80100bbb:	e8 62 19 00 00       	call   80102522 <namei>
80100bc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc7:	75 0f                	jne    80100bd8 <exec+0x31>
    end_op();
80100bc9:	e8 67 2a 00 00       	call   80103635 <end_op>
    return -1;
80100bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd3:	e9 e8 03 00 00       	jmp    80100fc0 <exec+0x419>
  }
  ilock(ip);
80100bd8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bdb:	89 04 24             	mov    %eax,(%esp)
80100bde:	e8 8e 0d 00 00       	call   80101971 <ilock>
  pgdir = 0;
80100be3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bea:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100bf1:	00 
80100bf2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100bf9:	00 
80100bfa:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c04:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c07:	89 04 24             	mov    %eax,(%esp)
80100c0a:	e8 75 12 00 00       	call   80101e84 <readi>
80100c0f:	83 f8 33             	cmp    $0x33,%eax
80100c12:	77 05                	ja     80100c19 <exec+0x72>
    goto bad;
80100c14:	e9 7b 03 00 00       	jmp    80100f94 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100c19:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c1f:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c24:	74 05                	je     80100c2b <exec+0x84>
    goto bad;
80100c26:	e9 69 03 00 00       	jmp    80100f94 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100c2b:	e8 a8 74 00 00       	call   801080d8 <setupkvm>
80100c30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c33:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c37:	75 05                	jne    80100c3e <exec+0x97>
    goto bad;
80100c39:	e9 56 03 00 00       	jmp    80100f94 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100c3e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c45:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c4c:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c52:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c55:	e9 cb 00 00 00       	jmp    80100d25 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c5d:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100c64:	00 
80100c65:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c69:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c73:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c76:	89 04 24             	mov    %eax,(%esp)
80100c79:	e8 06 12 00 00       	call   80101e84 <readi>
80100c7e:	83 f8 20             	cmp    $0x20,%eax
80100c81:	74 05                	je     80100c88 <exec+0xe1>
      goto bad;
80100c83:	e9 0c 03 00 00       	jmp    80100f94 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100c88:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c8e:	83 f8 01             	cmp    $0x1,%eax
80100c91:	74 05                	je     80100c98 <exec+0xf1>
      continue;
80100c93:	e9 80 00 00 00       	jmp    80100d18 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100c98:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c9e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca4:	39 c2                	cmp    %eax,%edx
80100ca6:	73 05                	jae    80100cad <exec+0x106>
      goto bad;
80100ca8:	e9 e7 02 00 00       	jmp    80100f94 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cad:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cb3:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cb9:	01 d0                	add    %edx,%eax
80100cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc9:	89 04 24             	mov    %eax,(%esp)
80100ccc:	e8 d5 77 00 00       	call   801084a6 <allocuvm>
80100cd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd8:	75 05                	jne    80100cdf <exec+0x138>
      goto bad;
80100cda:	e9 b5 02 00 00       	jmp    80100f94 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100ce5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ceb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100cf1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100cf5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100cf9:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100cfc:	89 54 24 08          	mov    %edx,0x8(%esp)
80100d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d07:	89 04 24             	mov    %eax,(%esp)
80100d0a:	e8 ac 76 00 00       	call   801083bb <loaduvm>
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	79 05                	jns    80100d18 <exec+0x171>
      goto bad;
80100d13:	e9 7c 02 00 00       	jmp    80100f94 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d18:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d1f:	83 c0 20             	add    $0x20,%eax
80100d22:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d25:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d2c:	0f b7 c0             	movzwl %ax,%eax
80100d2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d32:	0f 8f 22 ff ff ff    	jg     80100c5a <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d38:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d3b:	89 04 24             	mov    %eax,(%esp)
80100d3e:	e8 b8 0e 00 00       	call   80101bfb <iunlockput>
  end_op();
80100d43:	e8 ed 28 00 00       	call   80103635 <end_op>
  ip = 0;
80100d48:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d52:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d62:	05 00 20 00 00       	add    $0x2000,%eax
80100d67:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d75:	89 04 24             	mov    %eax,(%esp)
80100d78:	e8 29 77 00 00       	call   801084a6 <allocuvm>
80100d7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d80:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d84:	75 05                	jne    80100d8b <exec+0x1e4>
    goto bad;
80100d86:	e9 09 02 00 00       	jmp    80100f94 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d9a:	89 04 24             	mov    %eax,(%esp)
80100d9d:	e8 34 79 00 00       	call   801086d6 <clearpteu>
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 9a 00 00 00       	jmp    80100e4e <exec+0x2a7>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	76 05                	jbe    80100dbf <exec+0x218>
      goto bad;
80100dba:	e9 d5 01 00 00       	jmp    80100f94 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcc:	01 d0                	add    %edx,%eax
80100dce:	8b 00                	mov    (%eax),%eax
80100dd0:	89 04 24             	mov    %eax,(%esp)
80100dd3:	e8 a0 47 00 00       	call   80105578 <strlen>
80100dd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ddb:	29 c2                	sub    %eax,%edx
80100ddd:	89 d0                	mov    %edx,%eax
80100ddf:	83 e8 01             	sub    $0x1,%eax
80100de2:	83 e0 fc             	and    $0xfffffffc,%eax
80100de5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df5:	01 d0                	add    %edx,%eax
80100df7:	8b 00                	mov    (%eax),%eax
80100df9:	89 04 24             	mov    %eax,(%esp)
80100dfc:	e8 77 47 00 00       	call   80105578 <strlen>
80100e01:	83 c0 01             	add    $0x1,%eax
80100e04:	89 c2                	mov    %eax,%edx
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e13:	01 c8                	add    %ecx,%eax
80100e15:	8b 00                	mov    (%eax),%eax
80100e17:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e22:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e29:	89 04 24             	mov    %eax,(%esp)
80100e2c:	e8 6a 7a 00 00       	call   8010889b <copyout>
80100e31:	85 c0                	test   %eax,%eax
80100e33:	79 05                	jns    80100e3a <exec+0x293>
      goto bad;
80100e35:	e9 5a 01 00 00       	jmp    80100f94 <exec+0x3ed>
    ustack[3+argc] = sp;
80100e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3d:	8d 50 03             	lea    0x3(%eax),%edx
80100e40:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e43:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e4a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e5b:	01 d0                	add    %edx,%eax
80100e5d:	8b 00                	mov    (%eax),%eax
80100e5f:	85 c0                	test   %eax,%eax
80100e61:	0f 85 4d ff ff ff    	jne    80100db4 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6a:	83 c0 03             	add    $0x3,%eax
80100e6d:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e74:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e78:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e7f:	ff ff ff 
  ustack[1] = argc;
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8e:	83 c0 01             	add    $0x1,%eax
80100e91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e98:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e9b:	29 d0                	sub    %edx,%eax
80100e9d:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea6:	83 c0 04             	add    $0x4,%eax
80100ea9:	c1 e0 02             	shl    $0x2,%eax
80100eac:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb2:	83 c0 04             	add    $0x4,%eax
80100eb5:	c1 e0 02             	shl    $0x2,%eax
80100eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100ebc:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ec6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ecd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ed0:	89 04 24             	mov    %eax,(%esp)
80100ed3:	e8 c3 79 00 00       	call   8010889b <copyout>
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	79 05                	jns    80100ee1 <exec+0x33a>
    goto bad;
80100edc:	e9 b3 00 00 00       	jmp    80100f94 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ee4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eed:	eb 17                	jmp    80100f06 <exec+0x35f>
    if(*s == '/')
80100eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef2:	0f b6 00             	movzbl (%eax),%eax
80100ef5:	3c 2f                	cmp    $0x2f,%al
80100ef7:	75 09                	jne    80100f02 <exec+0x35b>
      last = s+1;
80100ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efc:	83 c0 01             	add    $0x1,%eax
80100eff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f09:	0f b6 00             	movzbl (%eax),%eax
80100f0c:	84 c0                	test   %al,%al
80100f0e:	75 df                	jne    80100eef <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f16:	8d 50 6c             	lea    0x6c(%eax),%edx
80100f19:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100f20:	00 
80100f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f28:	89 14 24             	mov    %edx,(%esp)
80100f2b:	e8 fe 45 00 00       	call   8010552e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f36:	8b 40 04             	mov    0x4(%eax),%eax
80100f39:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f42:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f45:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f51:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f59:	8b 40 18             	mov    0x18(%eax),%eax
80100f5c:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f62:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f6b:	8b 40 18             	mov    0x18(%eax),%eax
80100f6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f71:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f7a:	89 04 24             	mov    %eax,(%esp)
80100f7d:	e8 47 72 00 00       	call   801081c9 <switchuvm>
  freevm(oldpgdir);
80100f82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f85:	89 04 24             	mov    %eax,(%esp)
80100f88:	e8 af 76 00 00       	call   8010863c <freevm>
  return 0;
80100f8d:	b8 00 00 00 00       	mov    $0x0,%eax
80100f92:	eb 2c                	jmp    80100fc0 <exec+0x419>

 bad:
  if(pgdir)
80100f94:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f98:	74 0b                	je     80100fa5 <exec+0x3fe>
    freevm(pgdir);
80100f9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f9d:	89 04 24             	mov    %eax,(%esp)
80100fa0:	e8 97 76 00 00       	call   8010863c <freevm>
  if(ip){
80100fa5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa9:	74 10                	je     80100fbb <exec+0x414>
    iunlockput(ip);
80100fab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fae:	89 04 24             	mov    %eax,(%esp)
80100fb1:	e8 45 0c 00 00       	call   80101bfb <iunlockput>
    end_op();
80100fb6:	e8 7a 26 00 00       	call   80103635 <end_op>
  }
  return -1;
80100fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc0:	c9                   	leave  
80100fc1:	c3                   	ret    

80100fc2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc2:	55                   	push   %ebp
80100fc3:	89 e5                	mov    %esp,%ebp
80100fc5:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100fc8:	c7 44 24 04 aa 89 10 	movl   $0x801089aa,0x4(%esp)
80100fcf:	80 
80100fd0:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80100fd7:	e8 bd 40 00 00       	call   80105099 <initlock>
}
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe4:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80100feb:	e8 ca 40 00 00       	call   801050ba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff0:	c7 45 f4 34 22 11 80 	movl   $0x80112234,-0xc(%ebp)
80100ff7:	eb 29                	jmp    80101022 <filealloc+0x44>
    if(f->ref == 0){
80100ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffc:	8b 40 04             	mov    0x4(%eax),%eax
80100fff:	85 c0                	test   %eax,%eax
80101001:	75 1b                	jne    8010101e <filealloc+0x40>
      f->ref = 1;
80101003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101006:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010100d:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80101014:	e8 03 41 00 00       	call   8010511c <release>
      return f;
80101019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101c:	eb 1e                	jmp    8010103c <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010101e:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101022:	81 7d f4 94 2b 11 80 	cmpl   $0x80112b94,-0xc(%ebp)
80101029:	72 ce                	jb     80100ff9 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010102b:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80101032:	e8 e5 40 00 00       	call   8010511c <release>
  return 0;
80101037:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010103c:	c9                   	leave  
8010103d:	c3                   	ret    

8010103e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010103e:	55                   	push   %ebp
8010103f:	89 e5                	mov    %esp,%ebp
80101041:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101044:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
8010104b:	e8 6a 40 00 00       	call   801050ba <acquire>
  if(f->ref < 1)
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	8b 40 04             	mov    0x4(%eax),%eax
80101056:	85 c0                	test   %eax,%eax
80101058:	7f 0c                	jg     80101066 <filedup+0x28>
    panic("filedup");
8010105a:	c7 04 24 b1 89 10 80 	movl   $0x801089b1,(%esp)
80101061:	e8 71 f5 ff ff       	call   801005d7 <panic>
  f->ref++;
80101066:	8b 45 08             	mov    0x8(%ebp),%eax
80101069:	8b 40 04             	mov    0x4(%eax),%eax
8010106c:	8d 50 01             	lea    0x1(%eax),%edx
8010106f:	8b 45 08             	mov    0x8(%ebp),%eax
80101072:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101075:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
8010107c:	e8 9b 40 00 00       	call   8010511c <release>
  return f;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101084:	c9                   	leave  
80101085:	c3                   	ret    

80101086 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101086:	55                   	push   %ebp
80101087:	89 e5                	mov    %esp,%ebp
80101089:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010108c:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80101093:	e8 22 40 00 00       	call   801050ba <acquire>
  if(f->ref < 1)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7f 0c                	jg     801010ae <fileclose+0x28>
    panic("fileclose");
801010a2:	c7 04 24 b9 89 10 80 	movl   $0x801089b9,(%esp)
801010a9:	e8 29 f5 ff ff       	call   801005d7 <panic>
  if(--f->ref > 0){
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	89 50 04             	mov    %edx,0x4(%eax)
801010bd:	8b 45 08             	mov    0x8(%ebp),%eax
801010c0:	8b 40 04             	mov    0x4(%eax),%eax
801010c3:	85 c0                	test   %eax,%eax
801010c5:	7e 11                	jle    801010d8 <fileclose+0x52>
    release(&ftable.lock);
801010c7:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
801010ce:	e8 49 40 00 00       	call   8010511c <release>
801010d3:	e9 82 00 00 00       	jmp    8010115a <fileclose+0xd4>
    return;
  }
  ff = *f;
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 10                	mov    (%eax),%edx
801010dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e0:	8b 50 04             	mov    0x4(%eax),%edx
801010e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010e6:	8b 50 08             	mov    0x8(%eax),%edx
801010e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010ec:	8b 50 0c             	mov    0xc(%eax),%edx
801010ef:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f2:	8b 50 10             	mov    0x10(%eax),%edx
801010f5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010f8:	8b 40 14             	mov    0x14(%eax),%eax
801010fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101101:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101108:	8b 45 08             	mov    0x8(%ebp),%eax
8010110b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101111:	c7 04 24 00 22 11 80 	movl   $0x80112200,(%esp)
80101118:	e8 ff 3f 00 00       	call   8010511c <release>
  
  if(ff.type == FD_PIPE)
8010111d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101120:	83 f8 01             	cmp    $0x1,%eax
80101123:	75 18                	jne    8010113d <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101125:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101129:	0f be d0             	movsbl %al,%edx
8010112c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010112f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101133:	89 04 24             	mov    %eax,(%esp)
80101136:	e8 c5 30 00 00       	call   80104200 <pipeclose>
8010113b:	eb 1d                	jmp    8010115a <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010113d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101140:	83 f8 02             	cmp    $0x2,%eax
80101143:	75 15                	jne    8010115a <fileclose+0xd4>
    begin_op();
80101145:	e8 67 24 00 00       	call   801035b1 <begin_op>
    iput(ff.ip);
8010114a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010114d:	89 04 24             	mov    %eax,(%esp)
80101150:	e8 d5 09 00 00       	call   80101b2a <iput>
    end_op();
80101155:	e8 db 24 00 00       	call   80103635 <end_op>
  }
}
8010115a:	c9                   	leave  
8010115b:	c3                   	ret    

8010115c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010115c:	55                   	push   %ebp
8010115d:	89 e5                	mov    %esp,%ebp
8010115f:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101162:	8b 45 08             	mov    0x8(%ebp),%eax
80101165:	8b 00                	mov    (%eax),%eax
80101167:	83 f8 02             	cmp    $0x2,%eax
8010116a:	75 38                	jne    801011a4 <filestat+0x48>
    ilock(f->ip);
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 40 10             	mov    0x10(%eax),%eax
80101172:	89 04 24             	mov    %eax,(%esp)
80101175:	e8 f7 07 00 00       	call   80101971 <ilock>
    stati(f->ip, st);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 b0 0c 00 00       	call   80101e3f <stati>
    iunlock(f->ip);
8010118f:	8b 45 08             	mov    0x8(%ebp),%eax
80101192:	8b 40 10             	mov    0x10(%eax),%eax
80101195:	89 04 24             	mov    %eax,(%esp)
80101198:	e8 28 09 00 00       	call   80101ac5 <iunlock>
    return 0;
8010119d:	b8 00 00 00 00       	mov    $0x0,%eax
801011a2:	eb 05                	jmp    801011a9 <filestat+0x4d>
  }
  return -1;
801011a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011a9:	c9                   	leave  
801011aa:	c3                   	ret    

801011ab <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011ab:	55                   	push   %ebp
801011ac:	89 e5                	mov    %esp,%ebp
801011ae:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801011b1:	8b 45 08             	mov    0x8(%ebp),%eax
801011b4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011b8:	84 c0                	test   %al,%al
801011ba:	75 0a                	jne    801011c6 <fileread+0x1b>
    return -1;
801011bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c1:	e9 9f 00 00 00       	jmp    80101265 <fileread+0xba>
  if(f->type == FD_PIPE)
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	8b 00                	mov    (%eax),%eax
801011cb:	83 f8 01             	cmp    $0x1,%eax
801011ce:	75 1e                	jne    801011ee <fileread+0x43>
    return piperead(f->pipe, addr, n);
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	8b 40 0c             	mov    0xc(%eax),%eax
801011d6:	8b 55 10             	mov    0x10(%ebp),%edx
801011d9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e4:	89 04 24             	mov    %eax,(%esp)
801011e7:	e8 95 31 00 00       	call   80104381 <piperead>
801011ec:	eb 77                	jmp    80101265 <fileread+0xba>
  if(f->type == FD_INODE){
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 00                	mov    (%eax),%eax
801011f3:	83 f8 02             	cmp    $0x2,%eax
801011f6:	75 61                	jne    80101259 <fileread+0xae>
    ilock(f->ip);
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 40 10             	mov    0x10(%eax),%eax
801011fe:	89 04 24             	mov    %eax,(%esp)
80101201:	e8 6b 07 00 00       	call   80101971 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101206:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 50 14             	mov    0x14(%eax),%edx
8010120f:	8b 45 08             	mov    0x8(%ebp),%eax
80101212:	8b 40 10             	mov    0x10(%eax),%eax
80101215:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101219:	89 54 24 08          	mov    %edx,0x8(%esp)
8010121d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101220:	89 54 24 04          	mov    %edx,0x4(%esp)
80101224:	89 04 24             	mov    %eax,(%esp)
80101227:	e8 58 0c 00 00       	call   80101e84 <readi>
8010122c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010122f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101233:	7e 11                	jle    80101246 <fileread+0x9b>
      f->off += r;
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 50 14             	mov    0x14(%eax),%edx
8010123b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010123e:	01 c2                	add    %eax,%edx
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 40 10             	mov    0x10(%eax),%eax
8010124c:	89 04 24             	mov    %eax,(%esp)
8010124f:	e8 71 08 00 00       	call   80101ac5 <iunlock>
    return r;
80101254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101257:	eb 0c                	jmp    80101265 <fileread+0xba>
  }
  panic("fileread");
80101259:	c7 04 24 c3 89 10 80 	movl   $0x801089c3,(%esp)
80101260:	e8 72 f3 ff ff       	call   801005d7 <panic>
}
80101265:	c9                   	leave  
80101266:	c3                   	ret    

80101267 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101267:	55                   	push   %ebp
80101268:	89 e5                	mov    %esp,%ebp
8010126a:	53                   	push   %ebx
8010126b:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101275:	84 c0                	test   %al,%al
80101277:	75 0a                	jne    80101283 <filewrite+0x1c>
    return -1;
80101279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010127e:	e9 20 01 00 00       	jmp    801013a3 <filewrite+0x13c>
  if(f->type == FD_PIPE)
80101283:	8b 45 08             	mov    0x8(%ebp),%eax
80101286:	8b 00                	mov    (%eax),%eax
80101288:	83 f8 01             	cmp    $0x1,%eax
8010128b:	75 21                	jne    801012ae <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010128d:	8b 45 08             	mov    0x8(%ebp),%eax
80101290:	8b 40 0c             	mov    0xc(%eax),%eax
80101293:	8b 55 10             	mov    0x10(%ebp),%edx
80101296:	89 54 24 08          	mov    %edx,0x8(%esp)
8010129a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129d:	89 54 24 04          	mov    %edx,0x4(%esp)
801012a1:	89 04 24             	mov    %eax,(%esp)
801012a4:	e8 e9 2f 00 00       	call   80104292 <pipewrite>
801012a9:	e9 f5 00 00 00       	jmp    801013a3 <filewrite+0x13c>
  if(f->type == FD_INODE){
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 02             	cmp    $0x2,%eax
801012b6:	0f 85 db 00 00 00    	jne    80101397 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012bc:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012ca:	e9 a8 00 00 00       	jmp    80101377 <filewrite+0x110>
      int n1 = n - i;
801012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d2:	8b 55 10             	mov    0x10(%ebp),%edx
801012d5:	29 c2                	sub    %eax,%edx
801012d7:	89 d0                	mov    %edx,%eax
801012d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012e2:	7e 06                	jle    801012ea <filewrite+0x83>
        n1 = max;
801012e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012ea:	e8 c2 22 00 00       	call   801035b1 <begin_op>
      ilock(f->ip);
801012ef:	8b 45 08             	mov    0x8(%ebp),%eax
801012f2:	8b 40 10             	mov    0x10(%eax),%eax
801012f5:	89 04 24             	mov    %eax,(%esp)
801012f8:	e8 74 06 00 00       	call   80101971 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 50 14             	mov    0x14(%eax),%edx
80101306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010130c:	01 c3                	add    %eax,%ebx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 40 10             	mov    0x10(%eax),%eax
80101314:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101318:	89 54 24 08          	mov    %edx,0x8(%esp)
8010131c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101320:	89 04 24             	mov    %eax,(%esp)
80101323:	e8 c0 0c 00 00       	call   80101fe8 <writei>
80101328:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010132b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010132f:	7e 11                	jle    80101342 <filewrite+0xdb>
        f->off += r;
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133a:	01 c2                	add    %eax,%edx
8010133c:	8b 45 08             	mov    0x8(%ebp),%eax
8010133f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	8b 40 10             	mov    0x10(%eax),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 75 07 00 00       	call   80101ac5 <iunlock>
      end_op();
80101350:	e8 e0 22 00 00       	call   80103635 <end_op>

      if(r < 0)
80101355:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101359:	79 02                	jns    8010135d <filewrite+0xf6>
        break;
8010135b:	eb 26                	jmp    80101383 <filewrite+0x11c>
      if(r != n1)
8010135d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101360:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101363:	74 0c                	je     80101371 <filewrite+0x10a>
        panic("short filewrite");
80101365:	c7 04 24 cc 89 10 80 	movl   $0x801089cc,(%esp)
8010136c:	e8 66 f2 ff ff       	call   801005d7 <panic>
      i += r;
80101371:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101374:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010137d:	0f 8c 4c ff ff ff    	jl     801012cf <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101386:	3b 45 10             	cmp    0x10(%ebp),%eax
80101389:	75 05                	jne    80101390 <filewrite+0x129>
8010138b:	8b 45 10             	mov    0x10(%ebp),%eax
8010138e:	eb 05                	jmp    80101395 <filewrite+0x12e>
80101390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101395:	eb 0c                	jmp    801013a3 <filewrite+0x13c>
  }
  panic("filewrite");
80101397:	c7 04 24 dc 89 10 80 	movl   $0x801089dc,(%esp)
8010139e:	e8 34 f2 ff ff       	call   801005d7 <panic>
}
801013a3:	83 c4 24             	add    $0x24,%esp
801013a6:	5b                   	pop    %ebx
801013a7:	5d                   	pop    %ebp
801013a8:	c3                   	ret    

801013a9 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013a9:	55                   	push   %ebp
801013aa:	89 e5                	mov    %esp,%ebp
801013ac:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801013b9:	00 
801013ba:	89 04 24             	mov    %eax,(%esp)
801013bd:	e8 e4 ed ff ff       	call   801001a6 <bread>
801013c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c8:	83 c0 18             	add    $0x18,%eax
801013cb:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801013d2:	00 
801013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801013da:	89 04 24             	mov    %eax,(%esp)
801013dd:	e8 fb 3f 00 00       	call   801053dd <memmove>
  brelse(bp);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	89 04 24             	mov    %eax,(%esp)
801013e8:	e8 2a ee ff ff       	call   80100217 <brelse>
}
801013ed:	c9                   	leave  
801013ee:	c3                   	ret    

801013ef <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ef:	55                   	push   %ebp
801013f0:	89 e5                	mov    %esp,%ebp
801013f2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801013f8:	8b 45 08             	mov    0x8(%ebp),%eax
801013fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801013ff:	89 04 24             	mov    %eax,(%esp)
80101402:	e8 9f ed ff ff       	call   801001a6 <bread>
80101407:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140d:	83 c0 18             	add    $0x18,%eax
80101410:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101417:	00 
80101418:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010141f:	00 
80101420:	89 04 24             	mov    %eax,(%esp)
80101423:	e8 e6 3e 00 00       	call   8010530e <memset>
  log_write(bp);
80101428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142b:	89 04 24             	mov    %eax,(%esp)
8010142e:	e8 89 23 00 00       	call   801037bc <log_write>
  brelse(bp);
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 d9 ed ff ff       	call   80100217 <brelse>
}
8010143e:	c9                   	leave  
8010143f:	c3                   	ret    

80101440 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101446:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010144d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101454:	e9 07 01 00 00       	jmp    80101560 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
80101459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101462:	85 c0                	test   %eax,%eax
80101464:	0f 48 c2             	cmovs  %edx,%eax
80101467:	c1 f8 0c             	sar    $0xc,%eax
8010146a:	89 c2                	mov    %eax,%edx
8010146c:	a1 18 2c 11 80       	mov    0x80112c18,%eax
80101471:	01 d0                	add    %edx,%eax
80101473:	89 44 24 04          	mov    %eax,0x4(%esp)
80101477:	8b 45 08             	mov    0x8(%ebp),%eax
8010147a:	89 04 24             	mov    %eax,(%esp)
8010147d:	e8 24 ed ff ff       	call   801001a6 <bread>
80101482:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010148c:	e9 9d 00 00 00       	jmp    8010152e <balloc+0xee>
      m = 1 << (bi % 8);
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	99                   	cltd   
80101495:	c1 ea 1d             	shr    $0x1d,%edx
80101498:	01 d0                	add    %edx,%eax
8010149a:	83 e0 07             	and    $0x7,%eax
8010149d:	29 d0                	sub    %edx,%eax
8010149f:	ba 01 00 00 00       	mov    $0x1,%edx
801014a4:	89 c1                	mov    %eax,%ecx
801014a6:	d3 e2                	shl    %cl,%edx
801014a8:	89 d0                	mov    %edx,%eax
801014aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b0:	8d 50 07             	lea    0x7(%eax),%edx
801014b3:	85 c0                	test   %eax,%eax
801014b5:	0f 48 c2             	cmovs  %edx,%eax
801014b8:	c1 f8 03             	sar    $0x3,%eax
801014bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014be:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801014c3:	0f b6 c0             	movzbl %al,%eax
801014c6:	23 45 e8             	and    -0x18(%ebp),%eax
801014c9:	85 c0                	test   %eax,%eax
801014cb:	75 5d                	jne    8010152a <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
801014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d0:	8d 50 07             	lea    0x7(%eax),%edx
801014d3:	85 c0                	test   %eax,%eax
801014d5:	0f 48 c2             	cmovs  %edx,%eax
801014d8:	c1 f8 03             	sar    $0x3,%eax
801014db:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014de:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e3:	89 d1                	mov    %edx,%ecx
801014e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014e8:	09 ca                	or     %ecx,%edx
801014ea:	89 d1                	mov    %edx,%ecx
801014ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ef:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f6:	89 04 24             	mov    %eax,(%esp)
801014f9:	e8 be 22 00 00       	call   801037bc <log_write>
        brelse(bp);
801014fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101501:	89 04 24             	mov    %eax,(%esp)
80101504:	e8 0e ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150f:	01 c2                	add    %eax,%edx
80101511:	8b 45 08             	mov    0x8(%ebp),%eax
80101514:	89 54 24 04          	mov    %edx,0x4(%esp)
80101518:	89 04 24             	mov    %eax,(%esp)
8010151b:	e8 cf fe ff ff       	call   801013ef <bzero>
        return b + bi;
80101520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	eb 52                	jmp    8010157c <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010152a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010152e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101535:	7f 17                	jg     8010154e <balloc+0x10e>
80101537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153d:	01 d0                	add    %edx,%eax
8010153f:	89 c2                	mov    %eax,%edx
80101541:	a1 00 2c 11 80       	mov    0x80112c00,%eax
80101546:	39 c2                	cmp    %eax,%edx
80101548:	0f 82 43 ff ff ff    	jb     80101491 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010154e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101551:	89 04 24             	mov    %eax,(%esp)
80101554:	e8 be ec ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101559:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101563:	a1 00 2c 11 80       	mov    0x80112c00,%eax
80101568:	39 c2                	cmp    %eax,%edx
8010156a:	0f 82 e9 fe ff ff    	jb     80101459 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101570:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
80101577:	e8 5b f0 ff ff       	call   801005d7 <panic>
}
8010157c:	c9                   	leave  
8010157d:	c3                   	ret    

8010157e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010157e:	55                   	push   %ebp
8010157f:	89 e5                	mov    %esp,%ebp
80101581:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101584:	c7 44 24 04 00 2c 11 	movl   $0x80112c00,0x4(%esp)
8010158b:	80 
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 12 fe ff ff       	call   801013a9 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101597:	8b 45 0c             	mov    0xc(%ebp),%eax
8010159a:	c1 e8 0c             	shr    $0xc,%eax
8010159d:	89 c2                	mov    %eax,%edx
8010159f:	a1 18 2c 11 80       	mov    0x80112c18,%eax
801015a4:	01 c2                	add    %eax,%edx
801015a6:	8b 45 08             	mov    0x8(%ebp),%eax
801015a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801015ad:	89 04 24             	mov    %eax,(%esp)
801015b0:	e8 f1 eb ff ff       	call   801001a6 <bread>
801015b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801015bb:	25 ff 0f 00 00       	and    $0xfff,%eax
801015c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c6:	99                   	cltd   
801015c7:	c1 ea 1d             	shr    $0x1d,%edx
801015ca:	01 d0                	add    %edx,%eax
801015cc:	83 e0 07             	and    $0x7,%eax
801015cf:	29 d0                	sub    %edx,%eax
801015d1:	ba 01 00 00 00       	mov    $0x1,%edx
801015d6:	89 c1                	mov    %eax,%ecx
801015d8:	d3 e2                	shl    %cl,%edx
801015da:	89 d0                	mov    %edx,%eax
801015dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e2:	8d 50 07             	lea    0x7(%eax),%edx
801015e5:	85 c0                	test   %eax,%eax
801015e7:	0f 48 c2             	cmovs  %edx,%eax
801015ea:	c1 f8 03             	sar    $0x3,%eax
801015ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f0:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801015f5:	0f b6 c0             	movzbl %al,%eax
801015f8:	23 45 ec             	and    -0x14(%ebp),%eax
801015fb:	85 c0                	test   %eax,%eax
801015fd:	75 0c                	jne    8010160b <bfree+0x8d>
    panic("freeing free block");
801015ff:	c7 04 24 fe 89 10 80 	movl   $0x801089fe,(%esp)
80101606:	e8 cc ef ff ff       	call   801005d7 <panic>
  bp->data[bi/8] &= ~m;
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101621:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101624:	f7 d1                	not    %ecx
80101626:	21 ca                	and    %ecx,%edx
80101628:	89 d1                	mov    %edx,%ecx
8010162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101634:	89 04 24             	mov    %eax,(%esp)
80101637:	e8 80 21 00 00       	call   801037bc <log_write>
  brelse(bp);
8010163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010163f:	89 04 24             	mov    %eax,(%esp)
80101642:	e8 d0 eb ff ff       	call   80100217 <brelse>
}
80101647:	c9                   	leave  
80101648:	c3                   	ret    

80101649 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101649:	55                   	push   %ebp
8010164a:	89 e5                	mov    %esp,%ebp
8010164c:	57                   	push   %edi
8010164d:	56                   	push   %esi
8010164e:	53                   	push   %ebx
8010164f:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
80101652:	c7 44 24 04 11 8a 10 	movl   $0x80108a11,0x4(%esp)
80101659:	80 
8010165a:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101661:	e8 33 3a 00 00       	call   80105099 <initlock>
  readsb(dev, &sb);
80101666:	c7 44 24 04 00 2c 11 	movl   $0x80112c00,0x4(%esp)
8010166d:	80 
8010166e:	8b 45 08             	mov    0x8(%ebp),%eax
80101671:	89 04 24             	mov    %eax,(%esp)
80101674:	e8 30 fd ff ff       	call   801013a9 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101679:	a1 18 2c 11 80       	mov    0x80112c18,%eax
8010167e:	8b 3d 14 2c 11 80    	mov    0x80112c14,%edi
80101684:	8b 35 10 2c 11 80    	mov    0x80112c10,%esi
8010168a:	8b 1d 0c 2c 11 80    	mov    0x80112c0c,%ebx
80101690:	8b 0d 08 2c 11 80    	mov    0x80112c08,%ecx
80101696:	8b 15 04 2c 11 80    	mov    0x80112c04,%edx
8010169c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010169f:	8b 15 00 2c 11 80    	mov    0x80112c00,%edx
801016a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801016a9:	89 7c 24 18          	mov    %edi,0x18(%esp)
801016ad:	89 74 24 14          	mov    %esi,0x14(%esp)
801016b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801016b5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801016b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801016c0:	89 d0                	mov    %edx,%eax
801016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801016c6:	c7 04 24 18 8a 10 80 	movl   $0x80108a18,(%esp)
801016cd:	e8 31 ed ff ff       	call   80100403 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d2:	83 c4 3c             	add    $0x3c,%esp
801016d5:	5b                   	pop    %ebx
801016d6:	5e                   	pop    %esi
801016d7:	5f                   	pop    %edi
801016d8:	5d                   	pop    %ebp
801016d9:	c3                   	ret    

801016da <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016da:	55                   	push   %ebp
801016db:	89 e5                	mov    %esp,%ebp
801016dd:	83 ec 28             	sub    $0x28,%esp
801016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e3:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ee:	e9 9e 00 00 00       	jmp    80101791 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f6:	c1 e8 03             	shr    $0x3,%eax
801016f9:	89 c2                	mov    %eax,%edx
801016fb:	a1 14 2c 11 80       	mov    0x80112c14,%eax
80101700:	01 d0                	add    %edx,%eax
80101702:	89 44 24 04          	mov    %eax,0x4(%esp)
80101706:	8b 45 08             	mov    0x8(%ebp),%eax
80101709:	89 04 24             	mov    %eax,(%esp)
8010170c:	e8 95 ea ff ff       	call   801001a6 <bread>
80101711:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101717:	8d 50 18             	lea    0x18(%eax),%edx
8010171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171d:	83 e0 07             	and    $0x7,%eax
80101720:	c1 e0 06             	shl    $0x6,%eax
80101723:	01 d0                	add    %edx,%eax
80101725:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101728:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172b:	0f b7 00             	movzwl (%eax),%eax
8010172e:	66 85 c0             	test   %ax,%ax
80101731:	75 4f                	jne    80101782 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101733:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010173a:	00 
8010173b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101742:	00 
80101743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 c0 3b 00 00       	call   8010530e <memset>
      dip->type = type;
8010174e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101751:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101755:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175b:	89 04 24             	mov    %eax,(%esp)
8010175e:	e8 59 20 00 00       	call   801037bc <log_write>
      brelse(bp);
80101763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101766:	89 04 24             	mov    %eax,(%esp)
80101769:	e8 a9 ea ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101771:	89 44 24 04          	mov    %eax,0x4(%esp)
80101775:	8b 45 08             	mov    0x8(%ebp),%eax
80101778:	89 04 24             	mov    %eax,(%esp)
8010177b:	e8 ed 00 00 00       	call   8010186d <iget>
80101780:	eb 2b                	jmp    801017ad <ialloc+0xd3>
    }
    brelse(bp);
80101782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101785:	89 04 24             	mov    %eax,(%esp)
80101788:	e8 8a ea ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010178d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101794:	a1 08 2c 11 80       	mov    0x80112c08,%eax
80101799:	39 c2                	cmp    %eax,%edx
8010179b:	0f 82 52 ff ff ff    	jb     801016f3 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801017a1:	c7 04 24 6b 8a 10 80 	movl   $0x80108a6b,(%esp)
801017a8:	e8 2a ee ff ff       	call   801005d7 <panic>
}
801017ad:	c9                   	leave  
801017ae:	c3                   	ret    

801017af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017af:	55                   	push   %ebp
801017b0:	89 e5                	mov    %esp,%ebp
801017b2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	8b 40 04             	mov    0x4(%eax),%eax
801017bb:	c1 e8 03             	shr    $0x3,%eax
801017be:	89 c2                	mov    %eax,%edx
801017c0:	a1 14 2c 11 80       	mov    0x80112c14,%eax
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 00                	mov    (%eax),%eax
801017cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801017d0:	89 04 24             	mov    %eax,(%esp)
801017d3:	e8 ce e9 ff ff       	call   801001a6 <bread>
801017d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017de:	8d 50 18             	lea    0x18(%eax),%edx
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	8b 40 04             	mov    0x4(%eax),%eax
801017e7:	83 e0 07             	and    $0x7,%eax
801017ea:	c1 e0 06             	shl    $0x6,%eax
801017ed:	01 d0                	add    %edx,%eax
801017ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f2:	8b 45 08             	mov    0x8(%ebp),%eax
801017f5:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fc:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101802:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101809:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180d:	8b 45 08             	mov    0x8(%ebp),%eax
80101810:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101817:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101822:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101825:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101829:	8b 45 08             	mov    0x8(%ebp),%eax
8010182c:	8b 50 18             	mov    0x18(%eax),%edx
8010182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101832:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101835:	8b 45 08             	mov    0x8(%ebp),%eax
80101838:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183e:	83 c0 0c             	add    $0xc,%eax
80101841:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101848:	00 
80101849:	89 54 24 04          	mov    %edx,0x4(%esp)
8010184d:	89 04 24             	mov    %eax,(%esp)
80101850:	e8 88 3b 00 00       	call   801053dd <memmove>
  log_write(bp);
80101855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101858:	89 04 24             	mov    %eax,(%esp)
8010185b:	e8 5c 1f 00 00       	call   801037bc <log_write>
  brelse(bp);
80101860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101863:	89 04 24             	mov    %eax,(%esp)
80101866:	e8 ac e9 ff ff       	call   80100217 <brelse>
}
8010186b:	c9                   	leave  
8010186c:	c3                   	ret    

8010186d <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010186d:	55                   	push   %ebp
8010186e:	89 e5                	mov    %esp,%ebp
80101870:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101873:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
8010187a:	e8 3b 38 00 00       	call   801050ba <acquire>

  // Is the inode already cached?
  empty = 0;
8010187f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101886:	c7 45 f4 54 2c 11 80 	movl   $0x80112c54,-0xc(%ebp)
8010188d:	eb 59                	jmp    801018e8 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101892:	8b 40 08             	mov    0x8(%eax),%eax
80101895:	85 c0                	test   %eax,%eax
80101897:	7e 35                	jle    801018ce <iget+0x61>
80101899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189c:	8b 00                	mov    (%eax),%eax
8010189e:	3b 45 08             	cmp    0x8(%ebp),%eax
801018a1:	75 2b                	jne    801018ce <iget+0x61>
801018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a6:	8b 40 04             	mov    0x4(%eax),%eax
801018a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801018ac:	75 20                	jne    801018ce <iget+0x61>
      ip->ref++;
801018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b1:	8b 40 08             	mov    0x8(%eax),%eax
801018b4:	8d 50 01             	lea    0x1(%eax),%edx
801018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ba:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018bd:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
801018c4:	e8 53 38 00 00       	call   8010511c <release>
      return ip;
801018c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cc:	eb 6f                	jmp    8010193d <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018d2:	75 10                	jne    801018e4 <iget+0x77>
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	8b 40 08             	mov    0x8(%eax),%eax
801018da:	85 c0                	test   %eax,%eax
801018dc:	75 06                	jne    801018e4 <iget+0x77>
      empty = ip;
801018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018e4:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018e8:	81 7d f4 f4 3b 11 80 	cmpl   $0x80113bf4,-0xc(%ebp)
801018ef:	72 9e                	jb     8010188f <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018f5:	75 0c                	jne    80101903 <iget+0x96>
    panic("iget: no inodes");
801018f7:	c7 04 24 7d 8a 10 80 	movl   $0x80108a7d,(%esp)
801018fe:	e8 d4 ec ff ff       	call   801005d7 <panic>

  ip = empty;
80101903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101906:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 55 08             	mov    0x8(%ebp),%edx
8010190f:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	8b 55 0c             	mov    0xc(%ebp),%edx
80101917:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010192e:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101935:	e8 e2 37 00 00       	call   8010511c <release>

  return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    

8010193f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101945:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
8010194c:	e8 69 37 00 00       	call   801050ba <acquire>
  ip->ref++;
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 40 08             	mov    0x8(%eax),%eax
80101957:	8d 50 01             	lea    0x1(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101960:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101967:	e8 b0 37 00 00       	call   8010511c <release>
  return ip;
8010196c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010196f:	c9                   	leave  
80101970:	c3                   	ret    

80101971 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101971:	55                   	push   %ebp
80101972:	89 e5                	mov    %esp,%ebp
80101974:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010197b:	74 0a                	je     80101987 <ilock+0x16>
8010197d:	8b 45 08             	mov    0x8(%ebp),%eax
80101980:	8b 40 08             	mov    0x8(%eax),%eax
80101983:	85 c0                	test   %eax,%eax
80101985:	7f 0c                	jg     80101993 <ilock+0x22>
    panic("ilock");
80101987:	c7 04 24 8d 8a 10 80 	movl   $0x80108a8d,(%esp)
8010198e:	e8 44 ec ff ff       	call   801005d7 <panic>

  acquire(&icache.lock);
80101993:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
8010199a:	e8 1b 37 00 00       	call   801050ba <acquire>
  while(ip->flags & I_BUSY)
8010199f:	eb 13                	jmp    801019b4 <ilock+0x43>
    sleep(ip, &icache.lock);
801019a1:	c7 44 24 04 20 2c 11 	movl   $0x80112c20,0x4(%esp)
801019a8:	80 
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	89 04 24             	mov    %eax,(%esp)
801019af:	e8 3c 34 00 00       	call   80104df0 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ba:	83 e0 01             	and    $0x1,%eax
801019bd:	85 c0                	test   %eax,%eax
801019bf:	75 e0                	jne    801019a1 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 0c             	mov    0xc(%eax),%eax
801019c7:	83 c8 01             	or     $0x1,%eax
801019ca:	89 c2                	mov    %eax,%edx
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d2:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
801019d9:	e8 3e 37 00 00       	call   8010511c <release>

  if(!(ip->flags & I_VALID)){
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 0c             	mov    0xc(%eax),%eax
801019e4:	83 e0 02             	and    $0x2,%eax
801019e7:	85 c0                	test   %eax,%eax
801019e9:	0f 85 d4 00 00 00    	jne    80101ac3 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	8b 40 04             	mov    0x4(%eax),%eax
801019f5:	c1 e8 03             	shr    $0x3,%eax
801019f8:	89 c2                	mov    %eax,%edx
801019fa:	a1 14 2c 11 80       	mov    0x80112c14,%eax
801019ff:	01 c2                	add    %eax,%edx
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	8b 00                	mov    (%eax),%eax
80101a06:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a0a:	89 04 24             	mov    %eax,(%esp)
80101a0d:	e8 94 e7 ff ff       	call   801001a6 <bread>
80101a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	8d 50 18             	lea    0x18(%eax),%edx
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	8b 40 04             	mov    0x4(%eax),%eax
80101a21:	83 e0 07             	and    $0x7,%eax
80101a24:	c1 e0 06             	shl    $0x6,%eax
80101a27:	01 d0                	add    %edx,%eax
80101a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a2f:	0f b7 10             	movzwl (%eax),%edx
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a51:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a58:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a66:	8b 50 08             	mov    0x8(%eax),%edx
80101a69:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a72:	8d 50 0c             	lea    0xc(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	83 c0 1c             	add    $0x1c,%eax
80101a7b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a82:	00 
80101a83:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a87:	89 04 24             	mov    %eax,(%esp)
80101a8a:	e8 4e 39 00 00       	call   801053dd <memmove>
    brelse(bp);
80101a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 7d e7 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa0:	83 c8 02             	or     $0x2,%eax
80101aa3:	89 c2                	mov    %eax,%edx
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab2:	66 85 c0             	test   %ax,%ax
80101ab5:	75 0c                	jne    80101ac3 <ilock+0x152>
      panic("ilock: no type");
80101ab7:	c7 04 24 93 8a 10 80 	movl   $0x80108a93,(%esp)
80101abe:	e8 14 eb ff ff       	call   801005d7 <panic>
  }
}
80101ac3:	c9                   	leave  
80101ac4:	c3                   	ret    

80101ac5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac5:	55                   	push   %ebp
80101ac6:	89 e5                	mov    %esp,%ebp
80101ac8:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101acb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101acf:	74 17                	je     80101ae8 <iunlock+0x23>
80101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad7:	83 e0 01             	and    $0x1,%eax
80101ada:	85 c0                	test   %eax,%eax
80101adc:	74 0a                	je     80101ae8 <iunlock+0x23>
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	8b 40 08             	mov    0x8(%eax),%eax
80101ae4:	85 c0                	test   %eax,%eax
80101ae6:	7f 0c                	jg     80101af4 <iunlock+0x2f>
    panic("iunlock");
80101ae8:	c7 04 24 a2 8a 10 80 	movl   $0x80108aa2,(%esp)
80101aef:	e8 e3 ea ff ff       	call   801005d7 <panic>

  acquire(&icache.lock);
80101af4:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101afb:	e8 ba 35 00 00       	call   801050ba <acquire>
  ip->flags &= ~I_BUSY;
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 0c             	mov    0xc(%eax),%eax
80101b06:	83 e0 fe             	and    $0xfffffffe,%eax
80101b09:	89 c2                	mov    %eax,%edx
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	89 04 24             	mov    %eax,(%esp)
80101b17:	e8 ad 33 00 00       	call   80104ec9 <wakeup>
  release(&icache.lock);
80101b1c:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101b23:	e8 f4 35 00 00       	call   8010511c <release>
}
80101b28:	c9                   	leave  
80101b29:	c3                   	ret    

80101b2a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b2a:	55                   	push   %ebp
80101b2b:	89 e5                	mov    %esp,%ebp
80101b2d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b30:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101b37:	e8 7e 35 00 00       	call   801050ba <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	8b 40 08             	mov    0x8(%eax),%eax
80101b42:	83 f8 01             	cmp    $0x1,%eax
80101b45:	0f 85 93 00 00 00    	jne    80101bde <iput+0xb4>
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b51:	83 e0 02             	and    $0x2,%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	0f 84 82 00 00 00    	je     80101bde <iput+0xb4>
80101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b63:	66 85 c0             	test   %ax,%ax
80101b66:	75 76                	jne    80101bde <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b6e:	83 e0 01             	and    $0x1,%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 0c                	je     80101b81 <iput+0x57>
      panic("iput busy");
80101b75:	c7 04 24 aa 8a 10 80 	movl   $0x80108aaa,(%esp)
80101b7c:	e8 56 ea ff ff       	call   801005d7 <panic>
    ip->flags |= I_BUSY;
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 40 0c             	mov    0xc(%eax),%eax
80101b87:	83 c8 01             	or     $0x1,%eax
80101b8a:	89 c2                	mov    %eax,%edx
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b92:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101b99:	e8 7e 35 00 00       	call   8010511c <release>
    itrunc(ip);
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	89 04 24             	mov    %eax,(%esp)
80101ba4:	e8 7d 01 00 00       	call   80101d26 <itrunc>
    ip->type = 0;
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb5:	89 04 24             	mov    %eax,(%esp)
80101bb8:	e8 f2 fb ff ff       	call   801017af <iupdate>
    acquire(&icache.lock);
80101bbd:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101bc4:	e8 f1 34 00 00       	call   801050ba <acquire>
    ip->flags = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	89 04 24             	mov    %eax,(%esp)
80101bd9:	e8 eb 32 00 00       	call   80104ec9 <wakeup>
  }
  ip->ref--;
80101bde:	8b 45 08             	mov    0x8(%ebp),%eax
80101be1:	8b 40 08             	mov    0x8(%eax),%eax
80101be4:	8d 50 ff             	lea    -0x1(%eax),%edx
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bed:	c7 04 24 20 2c 11 80 	movl   $0x80112c20,(%esp)
80101bf4:	e8 23 35 00 00       	call   8010511c <release>
}
80101bf9:	c9                   	leave  
80101bfa:	c3                   	ret    

80101bfb <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bfb:	55                   	push   %ebp
80101bfc:	89 e5                	mov    %esp,%ebp
80101bfe:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	89 04 24             	mov    %eax,(%esp)
80101c07:	e8 b9 fe ff ff       	call   80101ac5 <iunlock>
  iput(ip);
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	89 04 24             	mov    %eax,(%esp)
80101c12:	e8 13 ff ff ff       	call   80101b2a <iput>
}
80101c17:	c9                   	leave  
80101c18:	c3                   	ret    

80101c19 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c19:	55                   	push   %ebp
80101c1a:	89 e5                	mov    %esp,%ebp
80101c1c:	53                   	push   %ebx
80101c1d:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c20:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c24:	77 3e                	ja     80101c64 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c2c:	83 c2 04             	add    $0x4,%edx
80101c2f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c3a:	75 20                	jne    80101c5c <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3f:	8b 00                	mov    (%eax),%eax
80101c41:	89 04 24             	mov    %eax,(%esp)
80101c44:	e8 f7 f7 ff ff       	call   80101440 <balloc>
80101c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c58:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	e9 bc 00 00 00       	jmp    80101d20 <bmap+0x107>
  }
  bn -= NDIRECT;
80101c64:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c68:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c6c:	0f 87 a2 00 00 00    	ja     80101d14 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c7f:	75 19                	jne    80101c9a <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 00                	mov    (%eax),%eax
80101c86:	89 04 24             	mov    %eax,(%esp)
80101c89:	e8 b2 f7 ff ff       	call   80101440 <balloc>
80101c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c97:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9d:	8b 00                	mov    (%eax),%eax
80101c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca6:	89 04 24             	mov    %eax,(%esp)
80101ca9:	e8 f8 e4 ff ff       	call   801001a6 <bread>
80101cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb4:	83 c0 18             	add    $0x18,%eax
80101cb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cba:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc7:	01 d0                	add    %edx,%eax
80101cc9:	8b 00                	mov    (%eax),%eax
80101ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd2:	75 30                	jne    80101d04 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce7:	8b 00                	mov    (%eax),%eax
80101ce9:	89 04 24             	mov    %eax,(%esp)
80101cec:	e8 4f f7 ff ff       	call   80101440 <balloc>
80101cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf7:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cfc:	89 04 24             	mov    %eax,(%esp)
80101cff:	e8 b8 1a 00 00       	call   801037bc <log_write>
    }
    brelse(bp);
80101d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 08 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d12:	eb 0c                	jmp    80101d20 <bmap+0x107>
  }

  panic("bmap: out of range");
80101d14:	c7 04 24 b4 8a 10 80 	movl   $0x80108ab4,(%esp)
80101d1b:	e8 b7 e8 ff ff       	call   801005d7 <panic>
}
80101d20:	83 c4 24             	add    $0x24,%esp
80101d23:	5b                   	pop    %ebx
80101d24:	5d                   	pop    %ebp
80101d25:	c3                   	ret    

80101d26 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d33:	eb 44                	jmp    80101d79 <itrunc+0x53>
    if(ip->addrs[i]){
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3b:	83 c2 04             	add    $0x4,%edx
80101d3e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d42:	85 c0                	test   %eax,%eax
80101d44:	74 2f                	je     80101d75 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4c:	83 c2 04             	add    $0x4,%edx
80101d4f:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d53:	8b 45 08             	mov    0x8(%ebp),%eax
80101d56:	8b 00                	mov    (%eax),%eax
80101d58:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d5c:	89 04 24             	mov    %eax,(%esp)
80101d5f:	e8 1a f8 ff ff       	call   8010157e <bfree>
      ip->addrs[i] = 0;
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6a:	83 c2 04             	add    $0x4,%edx
80101d6d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d74:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d79:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d7d:	7e b6                	jle    80101d35 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d85:	85 c0                	test   %eax,%eax
80101d87:	0f 84 9b 00 00 00    	je     80101e28 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d93:	8b 45 08             	mov    0x8(%ebp),%eax
80101d96:	8b 00                	mov    (%eax),%eax
80101d98:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d9c:	89 04 24             	mov    %eax,(%esp)
80101d9f:	e8 02 e4 ff ff       	call   801001a6 <bread>
80101da4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101daa:	83 c0 18             	add    $0x18,%eax
80101dad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101db0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101db7:	eb 3b                	jmp    80101df4 <itrunc+0xce>
      if(a[j])
80101db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dc6:	01 d0                	add    %edx,%eax
80101dc8:	8b 00                	mov    (%eax),%eax
80101dca:	85 c0                	test   %eax,%eax
80101dcc:	74 22                	je     80101df0 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ddb:	01 d0                	add    %edx,%eax
80101ddd:	8b 10                	mov    (%eax),%edx
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	8b 00                	mov    (%eax),%eax
80101de4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101de8:	89 04 24             	mov    %eax,(%esp)
80101deb:	e8 8e f7 ff ff       	call   8010157e <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101df0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df7:	83 f8 7f             	cmp    $0x7f,%eax
80101dfa:	76 bd                	jbe    80101db9 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dff:	89 04 24             	mov    %eax,(%esp)
80101e02:	e8 10 e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e07:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0a:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	8b 00                	mov    (%eax),%eax
80101e12:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e16:	89 04 24             	mov    %eax,(%esp)
80101e19:	e8 60 f7 ff ff       	call   8010157e <bfree>
    ip->addrs[NDIRECT] = 0;
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e32:	8b 45 08             	mov    0x8(%ebp),%eax
80101e35:	89 04 24             	mov    %eax,(%esp)
80101e38:	e8 72 f9 ff ff       	call   801017af <iupdate>
}
80101e3d:	c9                   	leave  
80101e3e:	c3                   	ret    

80101e3f <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e3f:	55                   	push   %ebp
80101e40:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	8b 00                	mov    (%eax),%eax
80101e47:	89 c2                	mov    %eax,%edx
80101e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4c:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e52:	8b 50 04             	mov    0x4(%eax),%edx
80101e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e58:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e65:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e72:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	8b 50 18             	mov    0x18(%eax),%edx
80101e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e7f:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e82:	5d                   	pop    %ebp
80101e83:	c3                   	ret    

80101e84 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e84:	55                   	push   %ebp
80101e85:	89 e5                	mov    %esp,%ebp
80101e87:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e91:	66 83 f8 03          	cmp    $0x3,%ax
80101e95:	75 60                	jne    80101ef7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e97:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e9e:	66 85 c0             	test   %ax,%ax
80101ea1:	78 20                	js     80101ec3 <readi+0x3f>
80101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eaa:	66 83 f8 09          	cmp    $0x9,%ax
80101eae:	7f 13                	jg     80101ec3 <readi+0x3f>
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eb7:	98                   	cwtl   
80101eb8:	8b 04 c5 a0 2b 11 80 	mov    -0x7feed460(,%eax,8),%eax
80101ebf:	85 c0                	test   %eax,%eax
80101ec1:	75 0a                	jne    80101ecd <readi+0x49>
      return -1;
80101ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ec8:	e9 19 01 00 00       	jmp    80101fe6 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed4:	98                   	cwtl   
80101ed5:	8b 04 c5 a0 2b 11 80 	mov    -0x7feed460(,%eax,8),%eax
80101edc:	8b 55 14             	mov    0x14(%ebp),%edx
80101edf:	89 54 24 08          	mov    %edx,0x8(%esp)
80101ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eea:	8b 55 08             	mov    0x8(%ebp),%edx
80101eed:	89 14 24             	mov    %edx,(%esp)
80101ef0:	ff d0                	call   *%eax
80101ef2:	e9 ef 00 00 00       	jmp    80101fe6 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 40 18             	mov    0x18(%eax),%eax
80101efd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f00:	72 0d                	jb     80101f0f <readi+0x8b>
80101f02:	8b 45 14             	mov    0x14(%ebp),%eax
80101f05:	8b 55 10             	mov    0x10(%ebp),%edx
80101f08:	01 d0                	add    %edx,%eax
80101f0a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f0d:	73 0a                	jae    80101f19 <readi+0x95>
    return -1;
80101f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f14:	e9 cd 00 00 00       	jmp    80101fe6 <readi+0x162>
  if(off + n > ip->size)
80101f19:	8b 45 14             	mov    0x14(%ebp),%eax
80101f1c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f1f:	01 c2                	add    %eax,%edx
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	8b 40 18             	mov    0x18(%eax),%eax
80101f27:	39 c2                	cmp    %eax,%edx
80101f29:	76 0c                	jbe    80101f37 <readi+0xb3>
    n = ip->size - off;
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	8b 40 18             	mov    0x18(%eax),%eax
80101f31:	2b 45 10             	sub    0x10(%ebp),%eax
80101f34:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f3e:	e9 94 00 00 00       	jmp    80101fd7 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f43:	8b 45 10             	mov    0x10(%ebp),%eax
80101f46:	c1 e8 09             	shr    $0x9,%eax
80101f49:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	89 04 24             	mov    %eax,(%esp)
80101f53:	e8 c1 fc ff ff       	call   80101c19 <bmap>
80101f58:	8b 55 08             	mov    0x8(%ebp),%edx
80101f5b:	8b 12                	mov    (%edx),%edx
80101f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f61:	89 14 24             	mov    %edx,(%esp)
80101f64:	e8 3d e2 ff ff       	call   801001a6 <bread>
80101f69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f6c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f6f:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f74:	89 c2                	mov    %eax,%edx
80101f76:	b8 00 02 00 00       	mov    $0x200,%eax
80101f7b:	29 d0                	sub    %edx,%eax
80101f7d:	89 c2                	mov    %eax,%edx
80101f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f82:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101f85:	29 c1                	sub    %eax,%ecx
80101f87:	89 c8                	mov    %ecx,%eax
80101f89:	39 c2                	cmp    %eax,%edx
80101f8b:	0f 46 c2             	cmovbe %edx,%eax
80101f8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f99:	8d 50 10             	lea    0x10(%eax),%edx
80101f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9f:	01 d0                	add    %edx,%eax
80101fa1:	8d 50 08             	lea    0x8(%eax),%edx
80101fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fab:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb2:	89 04 24             	mov    %eax,(%esp)
80101fb5:	e8 23 34 00 00       	call   801053dd <memmove>
    brelse(bp);
80101fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fbd:	89 04 24             	mov    %eax,(%esp)
80101fc0:	e8 52 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fc8:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fce:	01 45 10             	add    %eax,0x10(%ebp)
80101fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd4:	01 45 0c             	add    %eax,0xc(%ebp)
80101fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fda:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fdd:	0f 82 60 ff ff ff    	jb     80101f43 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fe3:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fe6:	c9                   	leave  
80101fe7:	c3                   	ret    

80101fe8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fe8:	55                   	push   %ebp
80101fe9:	89 e5                	mov    %esp,%ebp
80101feb:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ff5:	66 83 f8 03          	cmp    $0x3,%ax
80101ff9:	75 60                	jne    8010205b <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102002:	66 85 c0             	test   %ax,%ax
80102005:	78 20                	js     80102027 <writei+0x3f>
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010200e:	66 83 f8 09          	cmp    $0x9,%ax
80102012:	7f 13                	jg     80102027 <writei+0x3f>
80102014:	8b 45 08             	mov    0x8(%ebp),%eax
80102017:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010201b:	98                   	cwtl   
8010201c:	8b 04 c5 a4 2b 11 80 	mov    -0x7feed45c(,%eax,8),%eax
80102023:	85 c0                	test   %eax,%eax
80102025:	75 0a                	jne    80102031 <writei+0x49>
      return -1;
80102027:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010202c:	e9 44 01 00 00       	jmp    80102175 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102038:	98                   	cwtl   
80102039:	8b 04 c5 a4 2b 11 80 	mov    -0x7feed45c(,%eax,8),%eax
80102040:	8b 55 14             	mov    0x14(%ebp),%edx
80102043:	89 54 24 08          	mov    %edx,0x8(%esp)
80102047:	8b 55 0c             	mov    0xc(%ebp),%edx
8010204a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010204e:	8b 55 08             	mov    0x8(%ebp),%edx
80102051:	89 14 24             	mov    %edx,(%esp)
80102054:	ff d0                	call   *%eax
80102056:	e9 1a 01 00 00       	jmp    80102175 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	8b 40 18             	mov    0x18(%eax),%eax
80102061:	3b 45 10             	cmp    0x10(%ebp),%eax
80102064:	72 0d                	jb     80102073 <writei+0x8b>
80102066:	8b 45 14             	mov    0x14(%ebp),%eax
80102069:	8b 55 10             	mov    0x10(%ebp),%edx
8010206c:	01 d0                	add    %edx,%eax
8010206e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102071:	73 0a                	jae    8010207d <writei+0x95>
    return -1;
80102073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102078:	e9 f8 00 00 00       	jmp    80102175 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010207d:	8b 45 14             	mov    0x14(%ebp),%eax
80102080:	8b 55 10             	mov    0x10(%ebp),%edx
80102083:	01 d0                	add    %edx,%eax
80102085:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010208a:	76 0a                	jbe    80102096 <writei+0xae>
    return -1;
8010208c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102091:	e9 df 00 00 00       	jmp    80102175 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102096:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209d:	e9 9f 00 00 00       	jmp    80102141 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020a2:	8b 45 10             	mov    0x10(%ebp),%eax
801020a5:	c1 e8 09             	shr    $0x9,%eax
801020a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	89 04 24             	mov    %eax,(%esp)
801020b2:	e8 62 fb ff ff       	call   80101c19 <bmap>
801020b7:	8b 55 08             	mov    0x8(%ebp),%edx
801020ba:	8b 12                	mov    (%edx),%edx
801020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801020c0:	89 14 24             	mov    %edx,(%esp)
801020c3:	e8 de e0 ff ff       	call   801001a6 <bread>
801020c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	89 c2                	mov    %eax,%edx
801020d5:	b8 00 02 00 00       	mov    $0x200,%eax
801020da:	29 d0                	sub    %edx,%eax
801020dc:	89 c2                	mov    %eax,%edx
801020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020e1:	8b 4d 14             	mov    0x14(%ebp),%ecx
801020e4:	29 c1                	sub    %eax,%ecx
801020e6:	89 c8                	mov    %ecx,%eax
801020e8:	39 c2                	cmp    %eax,%edx
801020ea:	0f 46 c2             	cmovbe %edx,%eax
801020ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020f0:	8b 45 10             	mov    0x10(%ebp),%eax
801020f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f8:	8d 50 10             	lea    0x10(%eax),%edx
801020fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020fe:	01 d0                	add    %edx,%eax
80102100:	8d 50 08             	lea    0x8(%eax),%edx
80102103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102106:	89 44 24 08          	mov    %eax,0x8(%esp)
8010210a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010210d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102111:	89 14 24             	mov    %edx,(%esp)
80102114:	e8 c4 32 00 00       	call   801053dd <memmove>
    log_write(bp);
80102119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211c:	89 04 24             	mov    %eax,(%esp)
8010211f:	e8 98 16 00 00       	call   801037bc <log_write>
    brelse(bp);
80102124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102127:	89 04 24             	mov    %eax,(%esp)
8010212a:	e8 e8 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010212f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102132:	01 45 f4             	add    %eax,-0xc(%ebp)
80102135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102138:	01 45 10             	add    %eax,0x10(%ebp)
8010213b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010213e:	01 45 0c             	add    %eax,0xc(%ebp)
80102141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102144:	3b 45 14             	cmp    0x14(%ebp),%eax
80102147:	0f 82 55 ff ff ff    	jb     801020a2 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010214d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102151:	74 1f                	je     80102172 <writei+0x18a>
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	8b 40 18             	mov    0x18(%eax),%eax
80102159:	3b 45 10             	cmp    0x10(%ebp),%eax
8010215c:	73 14                	jae    80102172 <writei+0x18a>
    ip->size = off;
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	8b 55 10             	mov    0x10(%ebp),%edx
80102164:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	89 04 24             	mov    %eax,(%esp)
8010216d:	e8 3d f6 ff ff       	call   801017af <iupdate>
  }
  return n;
80102172:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102175:	c9                   	leave  
80102176:	c3                   	ret    

80102177 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102177:	55                   	push   %ebp
80102178:	89 e5                	mov    %esp,%ebp
8010217a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010217d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102184:	00 
80102185:	8b 45 0c             	mov    0xc(%ebp),%eax
80102188:	89 44 24 04          	mov    %eax,0x4(%esp)
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	89 04 24             	mov    %eax,(%esp)
80102192:	e8 e9 32 00 00       	call   80105480 <strncmp>
}
80102197:	c9                   	leave  
80102198:	c3                   	ret    

80102199 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102199:	55                   	push   %ebp
8010219a:	89 e5                	mov    %esp,%ebp
8010219c:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021a6:	66 83 f8 01          	cmp    $0x1,%ax
801021aa:	74 0c                	je     801021b8 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801021ac:	c7 04 24 c7 8a 10 80 	movl   $0x80108ac7,(%esp)
801021b3:	e8 1f e4 ff ff       	call   801005d7 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021bf:	e9 88 00 00 00       	jmp    8010224c <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021cb:	00 
801021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801021d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 9f fc ff ff       	call   80101e84 <readi>
801021e5:	83 f8 10             	cmp    $0x10,%eax
801021e8:	74 0c                	je     801021f6 <dirlookup+0x5d>
      panic("dirlink read");
801021ea:	c7 04 24 d9 8a 10 80 	movl   $0x80108ad9,(%esp)
801021f1:	e8 e1 e3 ff ff       	call   801005d7 <panic>
    if(de.inum == 0)
801021f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021fa:	66 85 c0             	test   %ax,%ax
801021fd:	75 02                	jne    80102201 <dirlookup+0x68>
      continue;
801021ff:	eb 47                	jmp    80102248 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102201:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102204:	83 c0 02             	add    $0x2,%eax
80102207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010220e:	89 04 24             	mov    %eax,(%esp)
80102211:	e8 61 ff ff ff       	call   80102177 <namecmp>
80102216:	85 c0                	test   %eax,%eax
80102218:	75 2e                	jne    80102248 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010221a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010221e:	74 08                	je     80102228 <dirlookup+0x8f>
        *poff = off;
80102220:	8b 45 10             	mov    0x10(%ebp),%eax
80102223:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102226:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102228:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222c:	0f b7 c0             	movzwl %ax,%eax
8010222f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	8b 00                	mov    (%eax),%eax
80102237:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010223a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010223e:	89 04 24             	mov    %eax,(%esp)
80102241:	e8 27 f6 ff ff       	call   8010186d <iget>
80102246:	eb 18                	jmp    80102260 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102248:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010224c:	8b 45 08             	mov    0x8(%ebp),%eax
8010224f:	8b 40 18             	mov    0x18(%eax),%eax
80102252:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102255:	0f 87 69 ff ff ff    	ja     801021c4 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010225b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102260:	c9                   	leave  
80102261:	c3                   	ret    

80102262 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102262:	55                   	push   %ebp
80102263:	89 e5                	mov    %esp,%ebp
80102265:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102268:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010226f:	00 
80102270:	8b 45 0c             	mov    0xc(%ebp),%eax
80102273:	89 44 24 04          	mov    %eax,0x4(%esp)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	89 04 24             	mov    %eax,(%esp)
8010227d:	e8 17 ff ff ff       	call   80102199 <dirlookup>
80102282:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102285:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102289:	74 15                	je     801022a0 <dirlink+0x3e>
    iput(ip);
8010228b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010228e:	89 04 24             	mov    %eax,(%esp)
80102291:	e8 94 f8 ff ff       	call   80101b2a <iput>
    return -1;
80102296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010229b:	e9 b7 00 00 00       	jmp    80102357 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a7:	eb 46                	jmp    801022ef <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022b3:	00 
801022b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801022bf:	8b 45 08             	mov    0x8(%ebp),%eax
801022c2:	89 04 24             	mov    %eax,(%esp)
801022c5:	e8 ba fb ff ff       	call   80101e84 <readi>
801022ca:	83 f8 10             	cmp    $0x10,%eax
801022cd:	74 0c                	je     801022db <dirlink+0x79>
      panic("dirlink read");
801022cf:	c7 04 24 d9 8a 10 80 	movl   $0x80108ad9,(%esp)
801022d6:	e8 fc e2 ff ff       	call   801005d7 <panic>
    if(de.inum == 0)
801022db:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022df:	66 85 c0             	test   %ax,%ax
801022e2:	75 02                	jne    801022e6 <dirlink+0x84>
      break;
801022e4:	eb 16                	jmp    801022fc <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e9:	83 c0 10             	add    $0x10,%eax
801022ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	8b 40 18             	mov    0x18(%eax),%eax
801022f8:	39 c2                	cmp    %eax,%edx
801022fa:	72 ad                	jb     801022a9 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801022fc:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102303:	00 
80102304:	8b 45 0c             	mov    0xc(%ebp),%eax
80102307:	89 44 24 04          	mov    %eax,0x4(%esp)
8010230b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010230e:	83 c0 02             	add    $0x2,%eax
80102311:	89 04 24             	mov    %eax,(%esp)
80102314:	e8 bd 31 00 00       	call   801054d6 <strncpy>
  de.inum = inum;
80102319:	8b 45 10             	mov    0x10(%ebp),%eax
8010231c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102323:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010232a:	00 
8010232b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010232f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102332:	89 44 24 04          	mov    %eax,0x4(%esp)
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	89 04 24             	mov    %eax,(%esp)
8010233c:	e8 a7 fc ff ff       	call   80101fe8 <writei>
80102341:	83 f8 10             	cmp    $0x10,%eax
80102344:	74 0c                	je     80102352 <dirlink+0xf0>
    panic("dirlink");
80102346:	c7 04 24 e6 8a 10 80 	movl   $0x80108ae6,(%esp)
8010234d:	e8 85 e2 ff ff       	call   801005d7 <panic>
  
  return 0;
80102352:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102357:	c9                   	leave  
80102358:	c3                   	ret    

80102359 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102359:	55                   	push   %ebp
8010235a:	89 e5                	mov    %esp,%ebp
8010235c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010235f:	eb 04                	jmp    80102365 <skipelem+0xc>
    path++;
80102361:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	0f b6 00             	movzbl (%eax),%eax
8010236b:	3c 2f                	cmp    $0x2f,%al
8010236d:	74 f2                	je     80102361 <skipelem+0x8>
    path++;
  if(*path == 0)
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
80102372:	0f b6 00             	movzbl (%eax),%eax
80102375:	84 c0                	test   %al,%al
80102377:	75 0a                	jne    80102383 <skipelem+0x2a>
    return 0;
80102379:	b8 00 00 00 00       	mov    $0x0,%eax
8010237e:	e9 86 00 00 00       	jmp    80102409 <skipelem+0xb0>
  s = path;
80102383:	8b 45 08             	mov    0x8(%ebp),%eax
80102386:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102389:	eb 04                	jmp    8010238f <skipelem+0x36>
    path++;
8010238b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	0f b6 00             	movzbl (%eax),%eax
80102395:	3c 2f                	cmp    $0x2f,%al
80102397:	74 0a                	je     801023a3 <skipelem+0x4a>
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	84 c0                	test   %al,%al
801023a1:	75 e8                	jne    8010238b <skipelem+0x32>
    path++;
  len = path - s;
801023a3:	8b 55 08             	mov    0x8(%ebp),%edx
801023a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a9:	29 c2                	sub    %eax,%edx
801023ab:	89 d0                	mov    %edx,%eax
801023ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b0:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b4:	7e 1c                	jle    801023d2 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801023b6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023bd:	00 
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c8:	89 04 24             	mov    %eax,(%esp)
801023cb:	e8 0d 30 00 00       	call   801053dd <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023d0:	eb 2a                	jmp    801023fc <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801023d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e3:	89 04 24             	mov    %eax,(%esp)
801023e6:	e8 f2 2f 00 00       	call   801053dd <memmove>
    name[len] = 0;
801023eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f1:	01 d0                	add    %edx,%eax
801023f3:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f6:	eb 04                	jmp    801023fc <skipelem+0xa3>
    path++;
801023f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	0f b6 00             	movzbl (%eax),%eax
80102402:	3c 2f                	cmp    $0x2f,%al
80102404:	74 f2                	je     801023f8 <skipelem+0x9f>
    path++;
  return path;
80102406:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102409:	c9                   	leave  
8010240a:	c3                   	ret    

8010240b <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010240b:	55                   	push   %ebp
8010240c:	89 e5                	mov    %esp,%ebp
8010240e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102411:	8b 45 08             	mov    0x8(%ebp),%eax
80102414:	0f b6 00             	movzbl (%eax),%eax
80102417:	3c 2f                	cmp    $0x2f,%al
80102419:	75 1c                	jne    80102437 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010241b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102422:	00 
80102423:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010242a:	e8 3e f4 ff ff       	call   8010186d <iget>
8010242f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102432:	e9 af 00 00 00       	jmp    801024e6 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102437:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010243d:	8b 40 68             	mov    0x68(%eax),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 f7 f4 ff ff       	call   8010193f <idup>
80102448:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010244b:	e9 96 00 00 00       	jmp    801024e6 <namex+0xdb>
    ilock(ip);
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	89 04 24             	mov    %eax,(%esp)
80102456:	e8 16 f5 ff ff       	call   80101971 <ilock>
    if(ip->type != T_DIR){
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102462:	66 83 f8 01          	cmp    $0x1,%ax
80102466:	74 15                	je     8010247d <namex+0x72>
      iunlockput(ip);
80102468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246b:	89 04 24             	mov    %eax,(%esp)
8010246e:	e8 88 f7 ff ff       	call   80101bfb <iunlockput>
      return 0;
80102473:	b8 00 00 00 00       	mov    $0x0,%eax
80102478:	e9 a3 00 00 00       	jmp    80102520 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010247d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102481:	74 1d                	je     801024a0 <namex+0x95>
80102483:	8b 45 08             	mov    0x8(%ebp),%eax
80102486:	0f b6 00             	movzbl (%eax),%eax
80102489:	84 c0                	test   %al,%al
8010248b:	75 13                	jne    801024a0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010248d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102490:	89 04 24             	mov    %eax,(%esp)
80102493:	e8 2d f6 ff ff       	call   80101ac5 <iunlock>
      return ip;
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	e9 80 00 00 00       	jmp    80102520 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024a7:	00 
801024a8:	8b 45 10             	mov    0x10(%ebp),%eax
801024ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	89 04 24             	mov    %eax,(%esp)
801024b5:	e8 df fc ff ff       	call   80102199 <dirlookup>
801024ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c1:	75 12                	jne    801024d5 <namex+0xca>
      iunlockput(ip);
801024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c6:	89 04 24             	mov    %eax,(%esp)
801024c9:	e8 2d f7 ff ff       	call   80101bfb <iunlockput>
      return 0;
801024ce:	b8 00 00 00 00       	mov    $0x0,%eax
801024d3:	eb 4b                	jmp    80102520 <namex+0x115>
    }
    iunlockput(ip);
801024d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d8:	89 04 24             	mov    %eax,(%esp)
801024db:	e8 1b f7 ff ff       	call   80101bfb <iunlockput>
    ip = next;
801024e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024e6:	8b 45 10             	mov    0x10(%ebp),%eax
801024e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ed:	8b 45 08             	mov    0x8(%ebp),%eax
801024f0:	89 04 24             	mov    %eax,(%esp)
801024f3:	e8 61 fe ff ff       	call   80102359 <skipelem>
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 4b ff ff ff    	jne    80102450 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 12                	je     8010251d <namex+0x112>
    iput(ip);
8010250b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250e:	89 04 24             	mov    %eax,(%esp)
80102511:	e8 14 f6 ff ff       	call   80101b2a <iput>
    return 0;
80102516:	b8 00 00 00 00       	mov    $0x0,%eax
8010251b:	eb 03                	jmp    80102520 <namex+0x115>
  }
  return ip;
8010251d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102520:	c9                   	leave  
80102521:	c3                   	ret    

80102522 <namei>:

struct inode*
namei(char *path)
{
80102522:	55                   	push   %ebp
80102523:	89 e5                	mov    %esp,%ebp
80102525:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102528:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010252b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010252f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102536:	00 
80102537:	8b 45 08             	mov    0x8(%ebp),%eax
8010253a:	89 04 24             	mov    %eax,(%esp)
8010253d:	e8 c9 fe ff ff       	call   8010240b <namex>
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010254a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010254d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102551:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102558:	00 
80102559:	8b 45 08             	mov    0x8(%ebp),%eax
8010255c:	89 04 24             	mov    %eax,(%esp)
8010255f:	e8 a7 fe ff ff       	call   8010240b <namex>
}
80102564:	c9                   	leave  
80102565:	c3                   	ret    

80102566 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102566:	55                   	push   %ebp
80102567:	89 e5                	mov    %esp,%ebp
80102569:	83 ec 14             	sub    $0x14,%esp
8010256c:	8b 45 08             	mov    0x8(%ebp),%eax
8010256f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102573:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102577:	89 c2                	mov    %eax,%edx
80102579:	ec                   	in     (%dx),%al
8010257a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010257d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102581:	c9                   	leave  
80102582:	c3                   	ret    

80102583 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102583:	55                   	push   %ebp
80102584:	89 e5                	mov    %esp,%ebp
80102586:	57                   	push   %edi
80102587:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102588:	8b 55 08             	mov    0x8(%ebp),%edx
8010258b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010258e:	8b 45 10             	mov    0x10(%ebp),%eax
80102591:	89 cb                	mov    %ecx,%ebx
80102593:	89 df                	mov    %ebx,%edi
80102595:	89 c1                	mov    %eax,%ecx
80102597:	fc                   	cld    
80102598:	f3 6d                	rep insl (%dx),%es:(%edi)
8010259a:	89 c8                	mov    %ecx,%eax
8010259c:	89 fb                	mov    %edi,%ebx
8010259e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025a1:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025a4:	5b                   	pop    %ebx
801025a5:	5f                   	pop    %edi
801025a6:	5d                   	pop    %ebp
801025a7:	c3                   	ret    

801025a8 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a8:	55                   	push   %ebp
801025a9:	89 e5                	mov    %esp,%ebp
801025ab:	83 ec 08             	sub    $0x8,%esp
801025ae:	8b 55 08             	mov    0x8(%ebp),%edx
801025b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025bb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025bf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025c3:	ee                   	out    %al,(%dx)
}
801025c4:	c9                   	leave  
801025c5:	c3                   	ret    

801025c6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c6:	55                   	push   %ebp
801025c7:	89 e5                	mov    %esp,%ebp
801025c9:	56                   	push   %esi
801025ca:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025cb:	8b 55 08             	mov    0x8(%ebp),%edx
801025ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d1:	8b 45 10             	mov    0x10(%ebp),%eax
801025d4:	89 cb                	mov    %ecx,%ebx
801025d6:	89 de                	mov    %ebx,%esi
801025d8:	89 c1                	mov    %eax,%ecx
801025da:	fc                   	cld    
801025db:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025dd:	89 c8                	mov    %ecx,%eax
801025df:	89 f3                	mov    %esi,%ebx
801025e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e7:	5b                   	pop    %ebx
801025e8:	5e                   	pop    %esi
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret    

801025eb <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025f1:	90                   	nop
801025f2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025f9:	e8 68 ff ff ff       	call   80102566 <inb>
801025fe:	0f b6 c0             	movzbl %al,%eax
80102601:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102607:	25 c0 00 00 00       	and    $0xc0,%eax
8010260c:	83 f8 40             	cmp    $0x40,%eax
8010260f:	75 e1                	jne    801025f2 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102611:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102615:	74 11                	je     80102628 <idewait+0x3d>
80102617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261a:	83 e0 21             	and    $0x21,%eax
8010261d:	85 c0                	test   %eax,%eax
8010261f:	74 07                	je     80102628 <idewait+0x3d>
    return -1;
80102621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102626:	eb 05                	jmp    8010262d <idewait+0x42>
  return 0;
80102628:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <ideinit>:

void
ideinit(void)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
80102632:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102635:	c7 44 24 04 ee 8a 10 	movl   $0x80108aee,0x4(%esp)
8010263c:	80 
8010263d:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102644:	e8 50 2a 00 00       	call   80105099 <initlock>
  picenable(IRQ_IDE);
80102649:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102650:	e8 fb 18 00 00       	call   80103f50 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102655:	a1 20 43 11 80       	mov    0x80114320,%eax
8010265a:	83 e8 01             	sub    $0x1,%eax
8010265d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102661:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102668:	e8 43 04 00 00       	call   80102ab0 <ioapicenable>
  idewait(0);
8010266d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102674:	e8 72 ff ff ff       	call   801025eb <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102679:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102680:	00 
80102681:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102688:	e8 1b ff ff ff       	call   801025a8 <outb>
  for(i=0; i<1000; i++){
8010268d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102694:	eb 20                	jmp    801026b6 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102696:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010269d:	e8 c4 fe ff ff       	call   80102566 <inb>
801026a2:	84 c0                	test   %al,%al
801026a4:	74 0c                	je     801026b2 <ideinit+0x83>
      havedisk1 = 1;
801026a6:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
801026ad:	00 00 00 
      break;
801026b0:	eb 0d                	jmp    801026bf <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b6:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026bd:	7e d7                	jle    80102696 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026bf:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801026c6:	00 
801026c7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026ce:	e8 d5 fe ff ff       	call   801025a8 <outb>
}
801026d3:	c9                   	leave  
801026d4:	c3                   	ret    

801026d5 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026d5:	55                   	push   %ebp
801026d6:	89 e5                	mov    %esp,%ebp
801026d8:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801026db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026df:	75 0c                	jne    801026ed <idestart+0x18>
    panic("idestart");
801026e1:	c7 04 24 f2 8a 10 80 	movl   $0x80108af2,(%esp)
801026e8:	e8 ea de ff ff       	call   801005d7 <panic>
  if(b->blockno >= FSSIZE)
801026ed:	8b 45 08             	mov    0x8(%ebp),%eax
801026f0:	8b 40 08             	mov    0x8(%eax),%eax
801026f3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026f8:	76 0c                	jbe    80102706 <idestart+0x31>
    panic("incorrect blockno");
801026fa:	c7 04 24 fb 8a 10 80 	movl   $0x80108afb,(%esp)
80102701:	e8 d1 de ff ff       	call   801005d7 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102706:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 50 08             	mov    0x8(%eax),%edx
80102713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102716:	0f af c2             	imul   %edx,%eax
80102719:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010271c:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102720:	7e 0c                	jle    8010272e <idestart+0x59>
80102722:	c7 04 24 f2 8a 10 80 	movl   $0x80108af2,(%esp)
80102729:	e8 a9 de ff ff       	call   801005d7 <panic>
  
  idewait(0);
8010272e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102735:	e8 b1 fe ff ff       	call   801025eb <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010273a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102741:	00 
80102742:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102749:	e8 5a fe ff ff       	call   801025a8 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010274e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102751:	0f b6 c0             	movzbl %al,%eax
80102754:	89 44 24 04          	mov    %eax,0x4(%esp)
80102758:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010275f:	e8 44 fe ff ff       	call   801025a8 <outb>
  outb(0x1f3, sector & 0xff);
80102764:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102767:	0f b6 c0             	movzbl %al,%eax
8010276a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010276e:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102775:	e8 2e fe ff ff       	call   801025a8 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010277a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010277d:	c1 f8 08             	sar    $0x8,%eax
80102780:	0f b6 c0             	movzbl %al,%eax
80102783:	89 44 24 04          	mov    %eax,0x4(%esp)
80102787:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010278e:	e8 15 fe ff ff       	call   801025a8 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102796:	c1 f8 10             	sar    $0x10,%eax
80102799:	0f b6 c0             	movzbl %al,%eax
8010279c:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a0:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801027a7:	e8 fc fd ff ff       	call   801025a8 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027ac:	8b 45 08             	mov    0x8(%ebp),%eax
801027af:	8b 40 04             	mov    0x4(%eax),%eax
801027b2:	83 e0 01             	and    $0x1,%eax
801027b5:	c1 e0 04             	shl    $0x4,%eax
801027b8:	89 c2                	mov    %eax,%edx
801027ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027bd:	c1 f8 18             	sar    $0x18,%eax
801027c0:	83 e0 0f             	and    $0xf,%eax
801027c3:	09 d0                	or     %edx,%eax
801027c5:	83 c8 e0             	or     $0xffffffe0,%eax
801027c8:	0f b6 c0             	movzbl %al,%eax
801027cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801027cf:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027d6:	e8 cd fd ff ff       	call   801025a8 <outb>
  if(b->flags & B_DIRTY){
801027db:	8b 45 08             	mov    0x8(%ebp),%eax
801027de:	8b 00                	mov    (%eax),%eax
801027e0:	83 e0 04             	and    $0x4,%eax
801027e3:	85 c0                	test   %eax,%eax
801027e5:	74 34                	je     8010281b <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
801027e7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801027ee:	00 
801027ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027f6:	e8 ad fd ff ff       	call   801025a8 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	83 c0 18             	add    $0x18,%eax
80102801:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102808:	00 
80102809:	89 44 24 04          	mov    %eax,0x4(%esp)
8010280d:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102814:	e8 ad fd ff ff       	call   801025c6 <outsl>
80102819:	eb 14                	jmp    8010282f <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010281b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102822:	00 
80102823:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010282a:	e8 79 fd ff ff       	call   801025a8 <outb>
  }
}
8010282f:	c9                   	leave  
80102830:	c3                   	ret    

80102831 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102831:	55                   	push   %ebp
80102832:	89 e5                	mov    %esp,%ebp
80102834:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102837:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010283e:	e8 77 28 00 00       	call   801050ba <acquire>
  if((b = idequeue) == 0){
80102843:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102848:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010284b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010284f:	75 11                	jne    80102862 <ideintr+0x31>
    release(&idelock);
80102851:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102858:	e8 bf 28 00 00       	call   8010511c <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010285d:	e9 90 00 00 00       	jmp    801028f2 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102865:	8b 40 14             	mov    0x14(%eax),%eax
80102868:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010286d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102870:	8b 00                	mov    (%eax),%eax
80102872:	83 e0 04             	and    $0x4,%eax
80102875:	85 c0                	test   %eax,%eax
80102877:	75 2e                	jne    801028a7 <ideintr+0x76>
80102879:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102880:	e8 66 fd ff ff       	call   801025eb <idewait>
80102885:	85 c0                	test   %eax,%eax
80102887:	78 1e                	js     801028a7 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010288c:	83 c0 18             	add    $0x18,%eax
8010288f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102896:	00 
80102897:	89 44 24 04          	mov    %eax,0x4(%esp)
8010289b:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028a2:	e8 dc fc ff ff       	call   80102583 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028aa:	8b 00                	mov    (%eax),%eax
801028ac:	83 c8 02             	or     $0x2,%eax
801028af:	89 c2                	mov    %eax,%edx
801028b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b9:	8b 00                	mov    (%eax),%eax
801028bb:	83 e0 fb             	and    $0xfffffffb,%eax
801028be:	89 c2                	mov    %eax,%edx
801028c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c8:	89 04 24             	mov    %eax,(%esp)
801028cb:	e8 f9 25 00 00       	call   80104ec9 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028d0:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028d5:	85 c0                	test   %eax,%eax
801028d7:	74 0d                	je     801028e6 <ideintr+0xb5>
    idestart(idequeue);
801028d9:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028de:	89 04 24             	mov    %eax,(%esp)
801028e1:	e8 ef fd ff ff       	call   801026d5 <idestart>

  release(&idelock);
801028e6:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801028ed:	e8 2a 28 00 00       	call   8010511c <release>
}
801028f2:	c9                   	leave  
801028f3:	c3                   	ret    

801028f4 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028f4:	55                   	push   %ebp
801028f5:	89 e5                	mov    %esp,%ebp
801028f7:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028fa:	8b 45 08             	mov    0x8(%ebp),%eax
801028fd:	8b 00                	mov    (%eax),%eax
801028ff:	83 e0 01             	and    $0x1,%eax
80102902:	85 c0                	test   %eax,%eax
80102904:	75 0c                	jne    80102912 <iderw+0x1e>
    panic("iderw: buf not busy");
80102906:	c7 04 24 0d 8b 10 80 	movl   $0x80108b0d,(%esp)
8010290d:	e8 c5 dc ff ff       	call   801005d7 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102912:	8b 45 08             	mov    0x8(%ebp),%eax
80102915:	8b 00                	mov    (%eax),%eax
80102917:	83 e0 06             	and    $0x6,%eax
8010291a:	83 f8 02             	cmp    $0x2,%eax
8010291d:	75 0c                	jne    8010292b <iderw+0x37>
    panic("iderw: nothing to do");
8010291f:	c7 04 24 21 8b 10 80 	movl   $0x80108b21,(%esp)
80102926:	e8 ac dc ff ff       	call   801005d7 <panic>
  if(b->dev != 0 && !havedisk1)
8010292b:	8b 45 08             	mov    0x8(%ebp),%eax
8010292e:	8b 40 04             	mov    0x4(%eax),%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 15                	je     8010294a <iderw+0x56>
80102935:	a1 58 c6 10 80       	mov    0x8010c658,%eax
8010293a:	85 c0                	test   %eax,%eax
8010293c:	75 0c                	jne    8010294a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010293e:	c7 04 24 36 8b 10 80 	movl   $0x80108b36,(%esp)
80102945:	e8 8d dc ff ff       	call   801005d7 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010294a:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102951:	e8 64 27 00 00       	call   801050ba <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102956:	8b 45 08             	mov    0x8(%ebp),%eax
80102959:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102960:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102967:	eb 0b                	jmp    80102974 <iderw+0x80>
80102969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296c:	8b 00                	mov    (%eax),%eax
8010296e:	83 c0 14             	add    $0x14,%eax
80102971:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102977:	8b 00                	mov    (%eax),%eax
80102979:	85 c0                	test   %eax,%eax
8010297b:	75 ec                	jne    80102969 <iderw+0x75>
    ;
  *pp = b;
8010297d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102980:	8b 55 08             	mov    0x8(%ebp),%edx
80102983:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102985:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010298a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010298d:	75 0d                	jne    8010299c <iderw+0xa8>
    idestart(b);
8010298f:	8b 45 08             	mov    0x8(%ebp),%eax
80102992:	89 04 24             	mov    %eax,(%esp)
80102995:	e8 3b fd ff ff       	call   801026d5 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010299a:	eb 15                	jmp    801029b1 <iderw+0xbd>
8010299c:	eb 13                	jmp    801029b1 <iderw+0xbd>
    sleep(b, &idelock);
8010299e:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
801029a5:	80 
801029a6:	8b 45 08             	mov    0x8(%ebp),%eax
801029a9:	89 04 24             	mov    %eax,(%esp)
801029ac:	e8 3f 24 00 00       	call   80104df0 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029b1:	8b 45 08             	mov    0x8(%ebp),%eax
801029b4:	8b 00                	mov    (%eax),%eax
801029b6:	83 e0 06             	and    $0x6,%eax
801029b9:	83 f8 02             	cmp    $0x2,%eax
801029bc:	75 e0                	jne    8010299e <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
801029be:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801029c5:	e8 52 27 00 00       	call   8010511c <release>
}
801029ca:	c9                   	leave  
801029cb:	c3                   	ret    

801029cc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029cc:	55                   	push   %ebp
801029cd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029cf:	a1 f4 3b 11 80       	mov    0x80113bf4,%eax
801029d4:	8b 55 08             	mov    0x8(%ebp),%edx
801029d7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029d9:	a1 f4 3b 11 80       	mov    0x80113bf4,%eax
801029de:	8b 40 10             	mov    0x10(%eax),%eax
}
801029e1:	5d                   	pop    %ebp
801029e2:	c3                   	ret    

801029e3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029e3:	55                   	push   %ebp
801029e4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029e6:	a1 f4 3b 11 80       	mov    0x80113bf4,%eax
801029eb:	8b 55 08             	mov    0x8(%ebp),%edx
801029ee:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029f0:	a1 f4 3b 11 80       	mov    0x80113bf4,%eax
801029f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801029f8:	89 50 10             	mov    %edx,0x10(%eax)
}
801029fb:	5d                   	pop    %ebp
801029fc:	c3                   	ret    

801029fd <ioapicinit>:

void
ioapicinit(void)
{
801029fd:	55                   	push   %ebp
801029fe:	89 e5                	mov    %esp,%ebp
80102a00:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102a03:	a1 24 3d 11 80       	mov    0x80113d24,%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	75 05                	jne    80102a11 <ioapicinit+0x14>
    return;
80102a0c:	e9 9d 00 00 00       	jmp    80102aae <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a11:	c7 05 f4 3b 11 80 00 	movl   $0xfec00000,0x80113bf4
80102a18:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a22:	e8 a5 ff ff ff       	call   801029cc <ioapicread>
80102a27:	c1 e8 10             	shr    $0x10,%eax
80102a2a:	25 ff 00 00 00       	and    $0xff,%eax
80102a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a39:	e8 8e ff ff ff       	call   801029cc <ioapicread>
80102a3e:	c1 e8 18             	shr    $0x18,%eax
80102a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a44:	0f b6 05 20 3d 11 80 	movzbl 0x80113d20,%eax
80102a4b:	0f b6 c0             	movzbl %al,%eax
80102a4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a51:	74 0c                	je     80102a5f <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a53:	c7 04 24 54 8b 10 80 	movl   $0x80108b54,(%esp)
80102a5a:	e8 a4 d9 ff ff       	call   80100403 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a66:	eb 3e                	jmp    80102aa6 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6b:	83 c0 20             	add    $0x20,%eax
80102a6e:	0d 00 00 01 00       	or     $0x10000,%eax
80102a73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a76:	83 c2 08             	add    $0x8,%edx
80102a79:	01 d2                	add    %edx,%edx
80102a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a7f:	89 14 24             	mov    %edx,(%esp)
80102a82:	e8 5c ff ff ff       	call   801029e3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8a:	83 c0 08             	add    $0x8,%eax
80102a8d:	01 c0                	add    %eax,%eax
80102a8f:	83 c0 01             	add    $0x1,%eax
80102a92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a99:	00 
80102a9a:	89 04 24             	mov    %eax,(%esp)
80102a9d:	e8 41 ff ff ff       	call   801029e3 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aa2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102aac:	7e ba                	jle    80102a68 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102aae:	c9                   	leave  
80102aaf:	c3                   	ret    

80102ab0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ab0:	55                   	push   %ebp
80102ab1:	89 e5                	mov    %esp,%ebp
80102ab3:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ab6:	a1 24 3d 11 80       	mov    0x80113d24,%eax
80102abb:	85 c0                	test   %eax,%eax
80102abd:	75 02                	jne    80102ac1 <ioapicenable+0x11>
    return;
80102abf:	eb 37                	jmp    80102af8 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac4:	83 c0 20             	add    $0x20,%eax
80102ac7:	8b 55 08             	mov    0x8(%ebp),%edx
80102aca:	83 c2 08             	add    $0x8,%edx
80102acd:	01 d2                	add    %edx,%edx
80102acf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ad3:	89 14 24             	mov    %edx,(%esp)
80102ad6:	e8 08 ff ff ff       	call   801029e3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102adb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ade:	c1 e0 18             	shl    $0x18,%eax
80102ae1:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae4:	83 c2 08             	add    $0x8,%edx
80102ae7:	01 d2                	add    %edx,%edx
80102ae9:	83 c2 01             	add    $0x1,%edx
80102aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80102af0:	89 14 24             	mov    %edx,(%esp)
80102af3:	e8 eb fe ff ff       	call   801029e3 <ioapicwrite>
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp
80102afd:	8b 45 08             	mov    0x8(%ebp),%eax
80102b00:	05 00 00 00 80       	add    $0x80000000,%eax
80102b05:	5d                   	pop    %ebp
80102b06:	c3                   	ret    

80102b07 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b0d:	c7 44 24 04 86 8b 10 	movl   $0x80108b86,0x4(%esp)
80102b14:	80 
80102b15:	c7 04 24 00 3c 11 80 	movl   $0x80113c00,(%esp)
80102b1c:	e8 78 25 00 00       	call   80105099 <initlock>
  kmem.use_lock = 0;
80102b21:	c7 05 34 3c 11 80 00 	movl   $0x0,0x80113c34
80102b28:	00 00 00 
  freerange(vstart, vend);
80102b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b32:	8b 45 08             	mov    0x8(%ebp),%eax
80102b35:	89 04 24             	mov    %eax,(%esp)
80102b38:	e8 26 00 00 00       	call   80102b63 <freerange>
}
80102b3d:	c9                   	leave  
80102b3e:	c3                   	ret    

80102b3f <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4f:	89 04 24             	mov    %eax,(%esp)
80102b52:	e8 0c 00 00 00       	call   80102b63 <freerange>
  kmem.use_lock = 1;
80102b57:	c7 05 34 3c 11 80 01 	movl   $0x1,0x80113c34
80102b5e:	00 00 00 
}
80102b61:	c9                   	leave  
80102b62:	c3                   	ret    

80102b63 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b63:	55                   	push   %ebp
80102b64:	89 e5                	mov    %esp,%ebp
80102b66:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b69:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6c:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b79:	eb 12                	jmp    80102b8d <freerange+0x2a>
    kfree(p);
80102b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7e:	89 04 24             	mov    %eax,(%esp)
80102b81:	e8 16 00 00 00       	call   80102b9c <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b86:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	05 00 10 00 00       	add    $0x1000,%eax
80102b95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b98:	76 e1                	jbe    80102b7b <freerange+0x18>
    kfree(p);
}
80102b9a:	c9                   	leave  
80102b9b:	c3                   	ret    

80102b9c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b9c:	55                   	push   %ebp
80102b9d:	89 e5                	mov    %esp,%ebp
80102b9f:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102baa:	85 c0                	test   %eax,%eax
80102bac:	75 1b                	jne    80102bc9 <kfree+0x2d>
80102bae:	81 7d 08 1c 6c 11 80 	cmpl   $0x80116c1c,0x8(%ebp)
80102bb5:	72 12                	jb     80102bc9 <kfree+0x2d>
80102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bba:	89 04 24             	mov    %eax,(%esp)
80102bbd:	e8 38 ff ff ff       	call   80102afa <v2p>
80102bc2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bc7:	76 0c                	jbe    80102bd5 <kfree+0x39>
    panic("kfree");
80102bc9:	c7 04 24 8b 8b 10 80 	movl   $0x80108b8b,(%esp)
80102bd0:	e8 02 da ff ff       	call   801005d7 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bd5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102bdc:	00 
80102bdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102be4:	00 
80102be5:	8b 45 08             	mov    0x8(%ebp),%eax
80102be8:	89 04 24             	mov    %eax,(%esp)
80102beb:	e8 1e 27 00 00       	call   8010530e <memset>

  if(kmem.use_lock)
80102bf0:	a1 34 3c 11 80       	mov    0x80113c34,%eax
80102bf5:	85 c0                	test   %eax,%eax
80102bf7:	74 0c                	je     80102c05 <kfree+0x69>
    acquire(&kmem.lock);
80102bf9:	c7 04 24 00 3c 11 80 	movl   $0x80113c00,(%esp)
80102c00:	e8 b5 24 00 00       	call   801050ba <acquire>
  r = (struct run*)v;
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c0b:	8b 15 38 3c 11 80    	mov    0x80113c38,%edx
80102c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c14:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c19:	a3 38 3c 11 80       	mov    %eax,0x80113c38
  if(kmem.use_lock)
80102c1e:	a1 34 3c 11 80       	mov    0x80113c34,%eax
80102c23:	85 c0                	test   %eax,%eax
80102c25:	74 0c                	je     80102c33 <kfree+0x97>
    release(&kmem.lock);
80102c27:	c7 04 24 00 3c 11 80 	movl   $0x80113c00,(%esp)
80102c2e:	e8 e9 24 00 00       	call   8010511c <release>
}
80102c33:	c9                   	leave  
80102c34:	c3                   	ret    

80102c35 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c35:	55                   	push   %ebp
80102c36:	89 e5                	mov    %esp,%ebp
80102c38:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102c3b:	a1 34 3c 11 80       	mov    0x80113c34,%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	74 0c                	je     80102c50 <kalloc+0x1b>
    acquire(&kmem.lock);
80102c44:	c7 04 24 00 3c 11 80 	movl   $0x80113c00,(%esp)
80102c4b:	e8 6a 24 00 00       	call   801050ba <acquire>
  r = kmem.freelist;
80102c50:	a1 38 3c 11 80       	mov    0x80113c38,%eax
80102c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c5c:	74 0a                	je     80102c68 <kalloc+0x33>
    kmem.freelist = r->next;
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	8b 00                	mov    (%eax),%eax
80102c63:	a3 38 3c 11 80       	mov    %eax,0x80113c38
  if(kmem.use_lock)
80102c68:	a1 34 3c 11 80       	mov    0x80113c34,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 0c                	je     80102c7d <kalloc+0x48>
    release(&kmem.lock);
80102c71:	c7 04 24 00 3c 11 80 	movl   $0x80113c00,(%esp)
80102c78:	e8 9f 24 00 00       	call   8010511c <release>
  return (char*)r;
80102c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c82:	55                   	push   %ebp
80102c83:	89 e5                	mov    %esp,%ebp
80102c85:	83 ec 14             	sub    $0x14,%esp
80102c88:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c8f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	ec                   	in     (%dx),%al
80102c96:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c99:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ca5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102cac:	e8 d1 ff ff ff       	call   80102c82 <inb>
80102cb1:	0f b6 c0             	movzbl %al,%eax
80102cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	83 e0 01             	and    $0x1,%eax
80102cbd:	85 c0                	test   %eax,%eax
80102cbf:	75 0a                	jne    80102ccb <kbdgetc+0x2c>
    return -1;
80102cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cc6:	e9 25 01 00 00       	jmp    80102df0 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102ccb:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102cd2:	e8 ab ff ff ff       	call   80102c82 <inb>
80102cd7:	0f b6 c0             	movzbl %al,%eax
80102cda:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cdd:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ce4:	75 17                	jne    80102cfd <kbdgetc+0x5e>
    shift |= E0ESC;
80102ce6:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ceb:	83 c8 40             	or     $0x40,%eax
80102cee:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80102cf8:	e9 f3 00 00 00       	jmp    80102df0 <kbdgetc+0x151>
  } else if(data & 0x80){
80102cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d00:	25 80 00 00 00       	and    $0x80,%eax
80102d05:	85 c0                	test   %eax,%eax
80102d07:	74 45                	je     80102d4e <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d09:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d0e:	83 e0 40             	and    $0x40,%eax
80102d11:	85 c0                	test   %eax,%eax
80102d13:	75 08                	jne    80102d1d <kbdgetc+0x7e>
80102d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d18:	83 e0 7f             	and    $0x7f,%eax
80102d1b:	eb 03                	jmp    80102d20 <kbdgetc+0x81>
80102d1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d26:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d2b:	0f b6 00             	movzbl (%eax),%eax
80102d2e:	83 c8 40             	or     $0x40,%eax
80102d31:	0f b6 c0             	movzbl %al,%eax
80102d34:	f7 d0                	not    %eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d3d:	21 d0                	and    %edx,%eax
80102d3f:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102d44:	b8 00 00 00 00       	mov    $0x0,%eax
80102d49:	e9 a2 00 00 00       	jmp    80102df0 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102d4e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d53:	83 e0 40             	and    $0x40,%eax
80102d56:	85 c0                	test   %eax,%eax
80102d58:	74 14                	je     80102d6e <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d5a:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d61:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d66:	83 e0 bf             	and    $0xffffffbf,%eax
80102d69:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d71:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d76:	0f b6 00             	movzbl (%eax),%eax
80102d79:	0f b6 d0             	movzbl %al,%edx
80102d7c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d81:	09 d0                	or     %edx,%eax
80102d83:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	0f b6 d0             	movzbl %al,%edx
80102d96:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d9b:	31 d0                	xor    %edx,%eax
80102d9d:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102da2:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102da7:	83 e0 03             	and    $0x3,%eax
80102daa:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102db1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db4:	01 d0                	add    %edx,%eax
80102db6:	0f b6 00             	movzbl (%eax),%eax
80102db9:	0f b6 c0             	movzbl %al,%eax
80102dbc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dbf:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dc4:	83 e0 08             	and    $0x8,%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	74 22                	je     80102ded <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102dcb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102dcf:	76 0c                	jbe    80102ddd <kbdgetc+0x13e>
80102dd1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102dd5:	77 06                	ja     80102ddd <kbdgetc+0x13e>
      c += 'A' - 'a';
80102dd7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ddb:	eb 10                	jmp    80102ded <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ddd:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102de1:	76 0a                	jbe    80102ded <kbdgetc+0x14e>
80102de3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102de7:	77 04                	ja     80102ded <kbdgetc+0x14e>
      c += 'a' - 'A';
80102de9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ded:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102df0:	c9                   	leave  
80102df1:	c3                   	ret    

80102df2 <kbdintr>:

void
kbdintr(void)
{
80102df2:	55                   	push   %ebp
80102df3:	89 e5                	mov    %esp,%ebp
80102df5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102df8:	c7 04 24 9f 2c 10 80 	movl   $0x80102c9f,(%esp)
80102dff:	e8 61 da ff ff       	call   80100865 <consoleintr>
}
80102e04:	c9                   	leave  
80102e05:	c3                   	ret    

80102e06 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e06:	55                   	push   %ebp
80102e07:	89 e5                	mov    %esp,%ebp
80102e09:	83 ec 14             	sub    $0x14,%esp
80102e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e13:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e17:	89 c2                	mov    %eax,%edx
80102e19:	ec                   	in     (%dx),%al
80102e1a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e1d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e21:	c9                   	leave  
80102e22:	c3                   	ret    

80102e23 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e23:	55                   	push   %ebp
80102e24:	89 e5                	mov    %esp,%ebp
80102e26:	83 ec 08             	sub    $0x8,%esp
80102e29:	8b 55 08             	mov    0x8(%ebp),%edx
80102e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e2f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e33:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e36:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e3a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e3e:	ee                   	out    %al,(%dx)
}
80102e3f:	c9                   	leave  
80102e40:	c3                   	ret    

80102e41 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e41:	55                   	push   %ebp
80102e42:	89 e5                	mov    %esp,%ebp
80102e44:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e47:	9c                   	pushf  
80102e48:	58                   	pop    %eax
80102e49:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e4f:	c9                   	leave  
80102e50:	c3                   	ret    

80102e51 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e51:	55                   	push   %ebp
80102e52:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e54:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80102e59:	8b 55 08             	mov    0x8(%ebp),%edx
80102e5c:	c1 e2 02             	shl    $0x2,%edx
80102e5f:	01 c2                	add    %eax,%edx
80102e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e64:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e66:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80102e6b:	83 c0 20             	add    $0x20,%eax
80102e6e:	8b 00                	mov    (%eax),%eax
}
80102e70:	5d                   	pop    %ebp
80102e71:	c3                   	ret    

80102e72 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e72:	55                   	push   %ebp
80102e73:	89 e5                	mov    %esp,%ebp
80102e75:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102e78:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80102e7d:	85 c0                	test   %eax,%eax
80102e7f:	75 05                	jne    80102e86 <lapicinit+0x14>
    return;
80102e81:	e9 43 01 00 00       	jmp    80102fc9 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e86:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102e8d:	00 
80102e8e:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e95:	e8 b7 ff ff ff       	call   80102e51 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e9a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102ea1:	00 
80102ea2:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102ea9:	e8 a3 ff ff ff       	call   80102e51 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eae:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102eb5:	00 
80102eb6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ebd:	e8 8f ff ff ff       	call   80102e51 <lapicw>
  lapicw(TICR, 10000000); 
80102ec2:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102ec9:	00 
80102eca:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102ed1:	e8 7b ff ff ff       	call   80102e51 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ed6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102edd:	00 
80102ede:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102ee5:	e8 67 ff ff ff       	call   80102e51 <lapicw>
  lapicw(LINT1, MASKED);
80102eea:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ef1:	00 
80102ef2:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ef9:	e8 53 ff ff ff       	call   80102e51 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102efe:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80102f03:	83 c0 30             	add    $0x30,%eax
80102f06:	8b 00                	mov    (%eax),%eax
80102f08:	c1 e8 10             	shr    $0x10,%eax
80102f0b:	0f b6 c0             	movzbl %al,%eax
80102f0e:	83 f8 03             	cmp    $0x3,%eax
80102f11:	76 14                	jbe    80102f27 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f13:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f1a:	00 
80102f1b:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f22:	e8 2a ff ff ff       	call   80102e51 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f27:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f2e:	00 
80102f2f:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f36:	e8 16 ff ff ff       	call   80102e51 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f42:	00 
80102f43:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f4a:	e8 02 ff ff ff       	call   80102e51 <lapicw>
  lapicw(ESR, 0);
80102f4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f56:	00 
80102f57:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f5e:	e8 ee fe ff ff       	call   80102e51 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f72:	e8 da fe ff ff       	call   80102e51 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f7e:	00 
80102f7f:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f86:	e8 c6 fe ff ff       	call   80102e51 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f8b:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f92:	00 
80102f93:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f9a:	e8 b2 fe ff ff       	call   80102e51 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f9f:	90                   	nop
80102fa0:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80102fa5:	05 00 03 00 00       	add    $0x300,%eax
80102faa:	8b 00                	mov    (%eax),%eax
80102fac:	25 00 10 00 00       	and    $0x1000,%eax
80102fb1:	85 c0                	test   %eax,%eax
80102fb3:	75 eb                	jne    80102fa0 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fbc:	00 
80102fbd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102fc4:	e8 88 fe ff ff       	call   80102e51 <lapicw>
}
80102fc9:	c9                   	leave  
80102fca:	c3                   	ret    

80102fcb <cpunum>:

int
cpunum(void)
{
80102fcb:	55                   	push   %ebp
80102fcc:	89 e5                	mov    %esp,%ebp
80102fce:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd1:	e8 6b fe ff ff       	call   80102e41 <readeflags>
80102fd6:	25 00 02 00 00       	and    $0x200,%eax
80102fdb:	85 c0                	test   %eax,%eax
80102fdd:	74 25                	je     80103004 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102fdf:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102fe4:	8d 50 01             	lea    0x1(%eax),%edx
80102fe7:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102fed:	85 c0                	test   %eax,%eax
80102fef:	75 13                	jne    80103004 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff1:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ff8:	c7 04 24 94 8b 10 80 	movl   $0x80108b94,(%esp)
80102fff:	e8 ff d3 ff ff       	call   80100403 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103004:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80103009:	85 c0                	test   %eax,%eax
8010300b:	74 0f                	je     8010301c <cpunum+0x51>
    return lapic[ID]>>24;
8010300d:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
80103012:	83 c0 20             	add    $0x20,%eax
80103015:	8b 00                	mov    (%eax),%eax
80103017:	c1 e8 18             	shr    $0x18,%eax
8010301a:	eb 05                	jmp    80103021 <cpunum+0x56>
  return 0;
8010301c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103021:	c9                   	leave  
80103022:	c3                   	ret    

80103023 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103023:	55                   	push   %ebp
80103024:	89 e5                	mov    %esp,%ebp
80103026:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103029:	a1 3c 3c 11 80       	mov    0x80113c3c,%eax
8010302e:	85 c0                	test   %eax,%eax
80103030:	74 14                	je     80103046 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103039:	00 
8010303a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103041:	e8 0b fe ff ff       	call   80102e51 <lapicw>
}
80103046:	c9                   	leave  
80103047:	c3                   	ret    

80103048 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103048:	55                   	push   %ebp
80103049:	89 e5                	mov    %esp,%ebp
}
8010304b:	5d                   	pop    %ebp
8010304c:	c3                   	ret    

8010304d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010304d:	55                   	push   %ebp
8010304e:	89 e5                	mov    %esp,%ebp
80103050:	83 ec 1c             	sub    $0x1c,%esp
80103053:	8b 45 08             	mov    0x8(%ebp),%eax
80103056:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103059:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103060:	00 
80103061:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103068:	e8 b6 fd ff ff       	call   80102e23 <outb>
  outb(CMOS_PORT+1, 0x0A);
8010306d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103074:	00 
80103075:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010307c:	e8 a2 fd ff ff       	call   80102e23 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103081:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103088:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010308b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103090:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103093:	8d 50 02             	lea    0x2(%eax),%edx
80103096:	8b 45 0c             	mov    0xc(%ebp),%eax
80103099:	c1 e8 04             	shr    $0x4,%eax
8010309c:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010309f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030a3:	c1 e0 18             	shl    $0x18,%eax
801030a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030aa:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030b1:	e8 9b fd ff ff       	call   80102e51 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030b6:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801030bd:	00 
801030be:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030c5:	e8 87 fd ff ff       	call   80102e51 <lapicw>
  microdelay(200);
801030ca:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030d1:	e8 72 ff ff ff       	call   80103048 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030d6:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030dd:	00 
801030de:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030e5:	e8 67 fd ff ff       	call   80102e51 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ea:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801030f1:	e8 52 ff ff ff       	call   80103048 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030fd:	eb 40                	jmp    8010313f <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801030ff:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103103:	c1 e0 18             	shl    $0x18,%eax
80103106:	89 44 24 04          	mov    %eax,0x4(%esp)
8010310a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103111:	e8 3b fd ff ff       	call   80102e51 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103116:	8b 45 0c             	mov    0xc(%ebp),%eax
80103119:	c1 e8 0c             	shr    $0xc,%eax
8010311c:	80 cc 06             	or     $0x6,%ah
8010311f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103123:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010312a:	e8 22 fd ff ff       	call   80102e51 <lapicw>
    microdelay(200);
8010312f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103136:	e8 0d ff ff ff       	call   80103048 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010313b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010313f:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103143:	7e ba                	jle    801030ff <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
8010314a:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010314d:	8b 45 08             	mov    0x8(%ebp),%eax
80103150:	0f b6 c0             	movzbl %al,%eax
80103153:	89 44 24 04          	mov    %eax,0x4(%esp)
80103157:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010315e:	e8 c0 fc ff ff       	call   80102e23 <outb>
  microdelay(200);
80103163:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010316a:	e8 d9 fe ff ff       	call   80103048 <microdelay>

  return inb(CMOS_RETURN);
8010316f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103176:	e8 8b fc ff ff       	call   80102e06 <inb>
8010317b:	0f b6 c0             	movzbl %al,%eax
}
8010317e:	c9                   	leave  
8010317f:	c3                   	ret    

80103180 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103180:	55                   	push   %ebp
80103181:	89 e5                	mov    %esp,%ebp
80103183:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103186:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010318d:	e8 b5 ff ff ff       	call   80103147 <cmos_read>
80103192:	8b 55 08             	mov    0x8(%ebp),%edx
80103195:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103197:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010319e:	e8 a4 ff ff ff       	call   80103147 <cmos_read>
801031a3:	8b 55 08             	mov    0x8(%ebp),%edx
801031a6:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031a9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801031b0:	e8 92 ff ff ff       	call   80103147 <cmos_read>
801031b5:	8b 55 08             	mov    0x8(%ebp),%edx
801031b8:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031bb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801031c2:	e8 80 ff ff ff       	call   80103147 <cmos_read>
801031c7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ca:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031cd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801031d4:	e8 6e ff ff ff       	call   80103147 <cmos_read>
801031d9:	8b 55 08             	mov    0x8(%ebp),%edx
801031dc:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031df:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801031e6:	e8 5c ff ff ff       	call   80103147 <cmos_read>
801031eb:	8b 55 08             	mov    0x8(%ebp),%edx
801031ee:	89 42 14             	mov    %eax,0x14(%edx)
}
801031f1:	c9                   	leave  
801031f2:	c3                   	ret    

801031f3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031f3:	55                   	push   %ebp
801031f4:	89 e5                	mov    %esp,%ebp
801031f6:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031f9:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103200:	e8 42 ff ff ff       	call   80103147 <cmos_read>
80103205:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010320b:	83 e0 04             	and    $0x4,%eax
8010320e:	85 c0                	test   %eax,%eax
80103210:	0f 94 c0             	sete   %al
80103213:	0f b6 c0             	movzbl %al,%eax
80103216:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103219:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010321c:	89 04 24             	mov    %eax,(%esp)
8010321f:	e8 5c ff ff ff       	call   80103180 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103224:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010322b:	e8 17 ff ff ff       	call   80103147 <cmos_read>
80103230:	25 80 00 00 00       	and    $0x80,%eax
80103235:	85 c0                	test   %eax,%eax
80103237:	74 02                	je     8010323b <cmostime+0x48>
        continue;
80103239:	eb 36                	jmp    80103271 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010323b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010323e:	89 04 24             	mov    %eax,(%esp)
80103241:	e8 3a ff ff ff       	call   80103180 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103246:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010324d:	00 
8010324e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103251:	89 44 24 04          	mov    %eax,0x4(%esp)
80103255:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103258:	89 04 24             	mov    %eax,(%esp)
8010325b:	e8 25 21 00 00       	call   80105385 <memcmp>
80103260:	85 c0                	test   %eax,%eax
80103262:	75 0d                	jne    80103271 <cmostime+0x7e>
      break;
80103264:	90                   	nop
  }

  // convert
  if (bcd) {
80103265:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103269:	0f 84 ac 00 00 00    	je     8010331b <cmostime+0x128>
8010326f:	eb 02                	jmp    80103273 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103271:	eb a6                	jmp    80103219 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103273:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103276:	c1 e8 04             	shr    $0x4,%eax
80103279:	89 c2                	mov    %eax,%edx
8010327b:	89 d0                	mov    %edx,%eax
8010327d:	c1 e0 02             	shl    $0x2,%eax
80103280:	01 d0                	add    %edx,%eax
80103282:	01 c0                	add    %eax,%eax
80103284:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103287:	83 e2 0f             	and    $0xf,%edx
8010328a:	01 d0                	add    %edx,%eax
8010328c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010328f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103292:	c1 e8 04             	shr    $0x4,%eax
80103295:	89 c2                	mov    %eax,%edx
80103297:	89 d0                	mov    %edx,%eax
80103299:	c1 e0 02             	shl    $0x2,%eax
8010329c:	01 d0                	add    %edx,%eax
8010329e:	01 c0                	add    %eax,%eax
801032a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032a3:	83 e2 0f             	and    $0xf,%edx
801032a6:	01 d0                	add    %edx,%eax
801032a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032ae:	c1 e8 04             	shr    $0x4,%eax
801032b1:	89 c2                	mov    %eax,%edx
801032b3:	89 d0                	mov    %edx,%eax
801032b5:	c1 e0 02             	shl    $0x2,%eax
801032b8:	01 d0                	add    %edx,%eax
801032ba:	01 c0                	add    %eax,%eax
801032bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032bf:	83 e2 0f             	and    $0xf,%edx
801032c2:	01 d0                	add    %edx,%eax
801032c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032ca:	c1 e8 04             	shr    $0x4,%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	89 d0                	mov    %edx,%eax
801032d1:	c1 e0 02             	shl    $0x2,%eax
801032d4:	01 d0                	add    %edx,%eax
801032d6:	01 c0                	add    %eax,%eax
801032d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032db:	83 e2 0f             	and    $0xf,%edx
801032de:	01 d0                	add    %edx,%eax
801032e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032e6:	c1 e8 04             	shr    $0x4,%eax
801032e9:	89 c2                	mov    %eax,%edx
801032eb:	89 d0                	mov    %edx,%eax
801032ed:	c1 e0 02             	shl    $0x2,%eax
801032f0:	01 d0                	add    %edx,%eax
801032f2:	01 c0                	add    %eax,%eax
801032f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f7:	83 e2 0f             	and    $0xf,%edx
801032fa:	01 d0                	add    %edx,%eax
801032fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103302:	c1 e8 04             	shr    $0x4,%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	89 d0                	mov    %edx,%eax
80103309:	c1 e0 02             	shl    $0x2,%eax
8010330c:	01 d0                	add    %edx,%eax
8010330e:	01 c0                	add    %eax,%eax
80103310:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103313:	83 e2 0f             	and    $0xf,%edx
80103316:	01 d0                	add    %edx,%eax
80103318:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010331b:	8b 45 08             	mov    0x8(%ebp),%eax
8010331e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103321:	89 10                	mov    %edx,(%eax)
80103323:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103326:	89 50 04             	mov    %edx,0x4(%eax)
80103329:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010332c:	89 50 08             	mov    %edx,0x8(%eax)
8010332f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103332:	89 50 0c             	mov    %edx,0xc(%eax)
80103335:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103338:	89 50 10             	mov    %edx,0x10(%eax)
8010333b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010333e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	8b 40 14             	mov    0x14(%eax),%eax
80103347:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010334d:	8b 45 08             	mov    0x8(%ebp),%eax
80103350:	89 50 14             	mov    %edx,0x14(%eax)
}
80103353:	c9                   	leave  
80103354:	c3                   	ret    

80103355 <unixtime>:

// This is not the "real" UNIX time as it makes many
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
80103355:	55                   	push   %ebp
80103356:	89 e5                	mov    %esp,%ebp
80103358:	83 ec 38             	sub    $0x38,%esp
  struct rtcdate t;
  cmostime(&t);
8010335b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010335e:	89 04 24             	mov    %eax,(%esp)
80103361:	e8 8d fe ff ff       	call   801031f3 <cmostime>
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	69 d0 80 33 e1 01    	imul   $0x1e13380,%eax,%edx
         (t.month * 30 * 24 * 60 * 60) +
8010336f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103372:	69 c0 00 8d 27 00    	imul   $0x278d00,%eax,%eax
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
80103378:	01 c2                	add    %eax,%edx
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
8010337a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337d:	69 c0 80 51 01 00    	imul   $0x15180,%eax,%eax
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
80103383:	01 c2                	add    %eax,%edx
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
80103385:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103388:	69 c0 10 0e 00 00    	imul   $0xe10,%eax,%eax
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
8010338e:	01 c2                	add    %eax,%edx
         (t.hour * 60 * 60) +
         (t.minute * 60) +
80103390:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103393:	c1 e0 02             	shl    $0x2,%eax
80103396:	89 c1                	mov    %eax,%ecx
80103398:	c1 e1 04             	shl    $0x4,%ecx
8010339b:	29 c1                	sub    %eax,%ecx
8010339d:	89 c8                	mov    %ecx,%eax
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
8010339f:	01 c2                	add    %eax,%edx
         (t.minute * 60) +
         (t.second);
801033a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
         (t.minute * 60) +
801033a4:	01 d0                	add    %edx,%eax
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
801033a6:	2d 00 4f fe 76       	sub    $0x76fe4f00,%eax
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
         (t.minute * 60) +
         (t.second);
}
801033ab:	c9                   	leave  
801033ac:	c3                   	ret    

801033ad <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033ad:	55                   	push   %ebp
801033ae:	89 e5                	mov    %esp,%ebp
801033b0:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033b3:	c7 44 24 04 c0 8b 10 	movl   $0x80108bc0,0x4(%esp)
801033ba:	80 
801033bb:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801033c2:	e8 d2 1c 00 00       	call   80105099 <initlock>
  readsb(dev, &sb);
801033c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801033ce:	8b 45 08             	mov    0x8(%ebp),%eax
801033d1:	89 04 24             	mov    %eax,(%esp)
801033d4:	e8 d0 df ff ff       	call   801013a9 <readsb>
  log.start = sb.logstart;
801033d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033dc:	a3 74 3c 11 80       	mov    %eax,0x80113c74
  log.size = sb.nlog;
801033e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033e4:	a3 78 3c 11 80       	mov    %eax,0x80113c78
  log.dev = dev;
801033e9:	8b 45 08             	mov    0x8(%ebp),%eax
801033ec:	a3 84 3c 11 80       	mov    %eax,0x80113c84
  recover_from_log();
801033f1:	e8 9a 01 00 00       	call   80103590 <recover_from_log>
}
801033f6:	c9                   	leave  
801033f7:	c3                   	ret    

801033f8 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033f8:	55                   	push   %ebp
801033f9:	89 e5                	mov    %esp,%ebp
801033fb:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103405:	e9 8c 00 00 00       	jmp    80103496 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010340a:	8b 15 74 3c 11 80    	mov    0x80113c74,%edx
80103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103413:	01 d0                	add    %edx,%eax
80103415:	83 c0 01             	add    $0x1,%eax
80103418:	89 c2                	mov    %eax,%edx
8010341a:	a1 84 3c 11 80       	mov    0x80113c84,%eax
8010341f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103423:	89 04 24             	mov    %eax,(%esp)
80103426:	e8 7b cd ff ff       	call   801001a6 <bread>
8010342b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103431:	83 c0 10             	add    $0x10,%eax
80103434:	8b 04 85 4c 3c 11 80 	mov    -0x7feec3b4(,%eax,4),%eax
8010343b:	89 c2                	mov    %eax,%edx
8010343d:	a1 84 3c 11 80       	mov    0x80113c84,%eax
80103442:	89 54 24 04          	mov    %edx,0x4(%esp)
80103446:	89 04 24             	mov    %eax,(%esp)
80103449:	e8 58 cd ff ff       	call   801001a6 <bread>
8010344e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103454:	8d 50 18             	lea    0x18(%eax),%edx
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	83 c0 18             	add    $0x18,%eax
8010345d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103464:	00 
80103465:	89 54 24 04          	mov    %edx,0x4(%esp)
80103469:	89 04 24             	mov    %eax,(%esp)
8010346c:	e8 6c 1f 00 00       	call   801053dd <memmove>
    bwrite(dbuf);  // write dst to disk
80103471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103474:	89 04 24             	mov    %eax,(%esp)
80103477:	e8 61 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010347c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347f:	89 04 24             	mov    %eax,(%esp)
80103482:	e8 90 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348a:	89 04 24             	mov    %eax,(%esp)
8010348d:	e8 85 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 88 3c 11 80       	mov    0x80113c88,%eax
8010349b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010349e:	0f 8f 66 ff ff ff    	jg     8010340a <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034a4:	c9                   	leave  
801034a5:	c3                   	ret    

801034a6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034a6:	55                   	push   %ebp
801034a7:	89 e5                	mov    %esp,%ebp
801034a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ac:	a1 74 3c 11 80       	mov    0x80113c74,%eax
801034b1:	89 c2                	mov    %eax,%edx
801034b3:	a1 84 3c 11 80       	mov    0x80113c84,%eax
801034b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801034bc:	89 04 24             	mov    %eax,(%esp)
801034bf:	e8 e2 cc ff ff       	call   801001a6 <bread>
801034c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ca:	83 c0 18             	add    $0x18,%eax
801034cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d3:	8b 00                	mov    (%eax),%eax
801034d5:	a3 88 3c 11 80       	mov    %eax,0x80113c88
  for (i = 0; i < log.lh.n; i++) {
801034da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e1:	eb 1b                	jmp    801034fe <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801034e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034e9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034f0:	83 c2 10             	add    $0x10,%edx
801034f3:	89 04 95 4c 3c 11 80 	mov    %eax,-0x7feec3b4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034fe:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103503:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103506:	7f db                	jg     801034e3 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350b:	89 04 24             	mov    %eax,(%esp)
8010350e:	e8 04 cd ff ff       	call   80100217 <brelse>
}
80103513:	c9                   	leave  
80103514:	c3                   	ret    

80103515 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103515:	55                   	push   %ebp
80103516:	89 e5                	mov    %esp,%ebp
80103518:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010351b:	a1 74 3c 11 80       	mov    0x80113c74,%eax
80103520:	89 c2                	mov    %eax,%edx
80103522:	a1 84 3c 11 80       	mov    0x80113c84,%eax
80103527:	89 54 24 04          	mov    %edx,0x4(%esp)
8010352b:	89 04 24             	mov    %eax,(%esp)
8010352e:	e8 73 cc ff ff       	call   801001a6 <bread>
80103533:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103539:	83 c0 18             	add    $0x18,%eax
8010353c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010353f:	8b 15 88 3c 11 80    	mov    0x80113c88,%edx
80103545:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103548:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010354a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103551:	eb 1b                	jmp    8010356e <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103556:	83 c0 10             	add    $0x10,%eax
80103559:	8b 0c 85 4c 3c 11 80 	mov    -0x7feec3b4(,%eax,4),%ecx
80103560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103563:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103566:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010356a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010356e:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103573:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103576:	7f db                	jg     80103553 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010357b:	89 04 24             	mov    %eax,(%esp)
8010357e:	e8 5a cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103583:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103586:	89 04 24             	mov    %eax,(%esp)
80103589:	e8 89 cc ff ff       	call   80100217 <brelse>
}
8010358e:	c9                   	leave  
8010358f:	c3                   	ret    

80103590 <recover_from_log>:

static void
recover_from_log(void)
{
80103590:	55                   	push   %ebp
80103591:	89 e5                	mov    %esp,%ebp
80103593:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103596:	e8 0b ff ff ff       	call   801034a6 <read_head>
  install_trans(); // if committed, copy from log to disk
8010359b:	e8 58 fe ff ff       	call   801033f8 <install_trans>
  log.lh.n = 0;
801035a0:	c7 05 88 3c 11 80 00 	movl   $0x0,0x80113c88
801035a7:	00 00 00 
  write_head(); // clear the log
801035aa:	e8 66 ff ff ff       	call   80103515 <write_head>
}
801035af:	c9                   	leave  
801035b0:	c3                   	ret    

801035b1 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035b1:	55                   	push   %ebp
801035b2:	89 e5                	mov    %esp,%ebp
801035b4:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801035b7:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801035be:	e8 f7 1a 00 00       	call   801050ba <acquire>
  while(1){
    if(log.committing){
801035c3:	a1 80 3c 11 80       	mov    0x80113c80,%eax
801035c8:	85 c0                	test   %eax,%eax
801035ca:	74 16                	je     801035e2 <begin_op+0x31>
      sleep(&log, &log.lock);
801035cc:	c7 44 24 04 40 3c 11 	movl   $0x80113c40,0x4(%esp)
801035d3:	80 
801035d4:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801035db:	e8 10 18 00 00       	call   80104df0 <sleep>
801035e0:	eb 4f                	jmp    80103631 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035e2:	8b 0d 88 3c 11 80    	mov    0x80113c88,%ecx
801035e8:	a1 7c 3c 11 80       	mov    0x80113c7c,%eax
801035ed:	8d 50 01             	lea    0x1(%eax),%edx
801035f0:	89 d0                	mov    %edx,%eax
801035f2:	c1 e0 02             	shl    $0x2,%eax
801035f5:	01 d0                	add    %edx,%eax
801035f7:	01 c0                	add    %eax,%eax
801035f9:	01 c8                	add    %ecx,%eax
801035fb:	83 f8 1e             	cmp    $0x1e,%eax
801035fe:	7e 16                	jle    80103616 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103600:	c7 44 24 04 40 3c 11 	movl   $0x80113c40,0x4(%esp)
80103607:	80 
80103608:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
8010360f:	e8 dc 17 00 00       	call   80104df0 <sleep>
80103614:	eb 1b                	jmp    80103631 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103616:	a1 7c 3c 11 80       	mov    0x80113c7c,%eax
8010361b:	83 c0 01             	add    $0x1,%eax
8010361e:	a3 7c 3c 11 80       	mov    %eax,0x80113c7c
      release(&log.lock);
80103623:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
8010362a:	e8 ed 1a 00 00       	call   8010511c <release>
      break;
8010362f:	eb 02                	jmp    80103633 <begin_op+0x82>
    }
  }
80103631:	eb 90                	jmp    801035c3 <begin_op+0x12>
}
80103633:	c9                   	leave  
80103634:	c3                   	ret    

80103635 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103635:	55                   	push   %ebp
80103636:	89 e5                	mov    %esp,%ebp
80103638:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010363b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103642:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
80103649:	e8 6c 1a 00 00       	call   801050ba <acquire>
  log.outstanding -= 1;
8010364e:	a1 7c 3c 11 80       	mov    0x80113c7c,%eax
80103653:	83 e8 01             	sub    $0x1,%eax
80103656:	a3 7c 3c 11 80       	mov    %eax,0x80113c7c
  if(log.committing)
8010365b:	a1 80 3c 11 80       	mov    0x80113c80,%eax
80103660:	85 c0                	test   %eax,%eax
80103662:	74 0c                	je     80103670 <end_op+0x3b>
    panic("log.committing");
80103664:	c7 04 24 c4 8b 10 80 	movl   $0x80108bc4,(%esp)
8010366b:	e8 67 cf ff ff       	call   801005d7 <panic>
  if(log.outstanding == 0){
80103670:	a1 7c 3c 11 80       	mov    0x80113c7c,%eax
80103675:	85 c0                	test   %eax,%eax
80103677:	75 13                	jne    8010368c <end_op+0x57>
    do_commit = 1;
80103679:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103680:	c7 05 80 3c 11 80 01 	movl   $0x1,0x80113c80
80103687:	00 00 00 
8010368a:	eb 0c                	jmp    80103698 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010368c:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
80103693:	e8 31 18 00 00       	call   80104ec9 <wakeup>
  }
  release(&log.lock);
80103698:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
8010369f:	e8 78 1a 00 00       	call   8010511c <release>

  if(do_commit){
801036a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036a8:	74 33                	je     801036dd <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036aa:	e8 de 00 00 00       	call   8010378d <commit>
    acquire(&log.lock);
801036af:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801036b6:	e8 ff 19 00 00       	call   801050ba <acquire>
    log.committing = 0;
801036bb:	c7 05 80 3c 11 80 00 	movl   $0x0,0x80113c80
801036c2:	00 00 00 
    wakeup(&log);
801036c5:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801036cc:	e8 f8 17 00 00       	call   80104ec9 <wakeup>
    release(&log.lock);
801036d1:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
801036d8:	e8 3f 1a 00 00       	call   8010511c <release>
  }
}
801036dd:	c9                   	leave  
801036de:	c3                   	ret    

801036df <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036df:	55                   	push   %ebp
801036e0:	89 e5                	mov    %esp,%ebp
801036e2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ec:	e9 8c 00 00 00       	jmp    8010377d <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036f1:	8b 15 74 3c 11 80    	mov    0x80113c74,%edx
801036f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fa:	01 d0                	add    %edx,%eax
801036fc:	83 c0 01             	add    $0x1,%eax
801036ff:	89 c2                	mov    %eax,%edx
80103701:	a1 84 3c 11 80       	mov    0x80113c84,%eax
80103706:	89 54 24 04          	mov    %edx,0x4(%esp)
8010370a:	89 04 24             	mov    %eax,(%esp)
8010370d:	e8 94 ca ff ff       	call   801001a6 <bread>
80103712:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103718:	83 c0 10             	add    $0x10,%eax
8010371b:	8b 04 85 4c 3c 11 80 	mov    -0x7feec3b4(,%eax,4),%eax
80103722:	89 c2                	mov    %eax,%edx
80103724:	a1 84 3c 11 80       	mov    0x80113c84,%eax
80103729:	89 54 24 04          	mov    %edx,0x4(%esp)
8010372d:	89 04 24             	mov    %eax,(%esp)
80103730:	e8 71 ca ff ff       	call   801001a6 <bread>
80103735:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103738:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010373b:	8d 50 18             	lea    0x18(%eax),%edx
8010373e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103741:	83 c0 18             	add    $0x18,%eax
80103744:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010374b:	00 
8010374c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103750:	89 04 24             	mov    %eax,(%esp)
80103753:	e8 85 1c 00 00       	call   801053dd <memmove>
    bwrite(to);  // write the log
80103758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010375b:	89 04 24             	mov    %eax,(%esp)
8010375e:	e8 7a ca ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103763:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103766:	89 04 24             	mov    %eax,(%esp)
80103769:	e8 a9 ca ff ff       	call   80100217 <brelse>
    brelse(to);
8010376e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103771:	89 04 24             	mov    %eax,(%esp)
80103774:	e8 9e ca ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103779:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010377d:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103782:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103785:	0f 8f 66 ff ff ff    	jg     801036f1 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010378b:	c9                   	leave  
8010378c:	c3                   	ret    

8010378d <commit>:

static void
commit()
{
8010378d:	55                   	push   %ebp
8010378e:	89 e5                	mov    %esp,%ebp
80103790:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103793:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	7e 1e                	jle    801037ba <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010379c:	e8 3e ff ff ff       	call   801036df <write_log>
    write_head();    // Write header to disk -- the real commit
801037a1:	e8 6f fd ff ff       	call   80103515 <write_head>
    install_trans(); // Now install writes to home locations
801037a6:	e8 4d fc ff ff       	call   801033f8 <install_trans>
    log.lh.n = 0; 
801037ab:	c7 05 88 3c 11 80 00 	movl   $0x0,0x80113c88
801037b2:	00 00 00 
    write_head();    // Erase the transaction from the log
801037b5:	e8 5b fd ff ff       	call   80103515 <write_head>
  }
}
801037ba:	c9                   	leave  
801037bb:	c3                   	ret    

801037bc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037bc:	55                   	push   %ebp
801037bd:	89 e5                	mov    %esp,%ebp
801037bf:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037c2:	a1 88 3c 11 80       	mov    0x80113c88,%eax
801037c7:	83 f8 1d             	cmp    $0x1d,%eax
801037ca:	7f 12                	jg     801037de <log_write+0x22>
801037cc:	a1 88 3c 11 80       	mov    0x80113c88,%eax
801037d1:	8b 15 78 3c 11 80    	mov    0x80113c78,%edx
801037d7:	83 ea 01             	sub    $0x1,%edx
801037da:	39 d0                	cmp    %edx,%eax
801037dc:	7c 0c                	jl     801037ea <log_write+0x2e>
    panic("too big a transaction");
801037de:	c7 04 24 d3 8b 10 80 	movl   $0x80108bd3,(%esp)
801037e5:	e8 ed cd ff ff       	call   801005d7 <panic>
  if (log.outstanding < 1)
801037ea:	a1 7c 3c 11 80       	mov    0x80113c7c,%eax
801037ef:	85 c0                	test   %eax,%eax
801037f1:	7f 0c                	jg     801037ff <log_write+0x43>
    panic("log_write outside of trans");
801037f3:	c7 04 24 e9 8b 10 80 	movl   $0x80108be9,(%esp)
801037fa:	e8 d8 cd ff ff       	call   801005d7 <panic>

  acquire(&log.lock);
801037ff:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
80103806:	e8 af 18 00 00       	call   801050ba <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010380b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103812:	eb 1f                	jmp    80103833 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103817:	83 c0 10             	add    $0x10,%eax
8010381a:	8b 04 85 4c 3c 11 80 	mov    -0x7feec3b4(,%eax,4),%eax
80103821:	89 c2                	mov    %eax,%edx
80103823:	8b 45 08             	mov    0x8(%ebp),%eax
80103826:	8b 40 08             	mov    0x8(%eax),%eax
80103829:	39 c2                	cmp    %eax,%edx
8010382b:	75 02                	jne    8010382f <log_write+0x73>
      break;
8010382d:	eb 0e                	jmp    8010383d <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010382f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103833:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103838:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010383b:	7f d7                	jg     80103814 <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
8010383d:	8b 45 08             	mov    0x8(%ebp),%eax
80103840:	8b 40 08             	mov    0x8(%eax),%eax
80103843:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103846:	83 c2 10             	add    $0x10,%edx
80103849:	89 04 95 4c 3c 11 80 	mov    %eax,-0x7feec3b4(,%edx,4)
  if (i == log.lh.n)
80103850:	a1 88 3c 11 80       	mov    0x80113c88,%eax
80103855:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103858:	75 0d                	jne    80103867 <log_write+0xab>
    log.lh.n++;
8010385a:	a1 88 3c 11 80       	mov    0x80113c88,%eax
8010385f:	83 c0 01             	add    $0x1,%eax
80103862:	a3 88 3c 11 80       	mov    %eax,0x80113c88
  b->flags |= B_DIRTY; // prevent eviction
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	8b 00                	mov    (%eax),%eax
8010386c:	83 c8 04             	or     $0x4,%eax
8010386f:	89 c2                	mov    %eax,%edx
80103871:	8b 45 08             	mov    0x8(%ebp),%eax
80103874:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103876:	c7 04 24 40 3c 11 80 	movl   $0x80113c40,(%esp)
8010387d:	e8 9a 18 00 00       	call   8010511c <release>
}
80103882:	c9                   	leave  
80103883:	c3                   	ret    

80103884 <v2p>:
80103884:	55                   	push   %ebp
80103885:	89 e5                	mov    %esp,%ebp
80103887:	8b 45 08             	mov    0x8(%ebp),%eax
8010388a:	05 00 00 00 80       	add    $0x80000000,%eax
8010388f:	5d                   	pop    %ebp
80103890:	c3                   	ret    

80103891 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	8b 45 08             	mov    0x8(%ebp),%eax
80103897:	05 00 00 00 80       	add    $0x80000000,%eax
8010389c:	5d                   	pop    %ebp
8010389d:	c3                   	ret    

8010389e <xchg>:
    return ret;
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010389e:	55                   	push   %ebp
8010389f:	89 e5                	mov    %esp,%ebp
801038a1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038a4:	8b 55 08             	mov    0x8(%ebp),%edx
801038a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801038aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038ad:	f0 87 02             	lock xchg %eax,(%edx)
801038b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038b6:	c9                   	leave  
801038b7:	c3                   	ret    

801038b8 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038b8:	55                   	push   %ebp
801038b9:	89 e5                	mov    %esp,%ebp
801038bb:	83 e4 f0             	and    $0xfffffff0,%esp
801038be:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038c1:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801038c8:	80 
801038c9:	c7 04 24 1c 6c 11 80 	movl   $0x80116c1c,(%esp)
801038d0:	e8 32 f2 ff ff       	call   80102b07 <kinit1>
  kvmalloc();      // kernel page table
801038d5:	e8 bb 48 00 00       	call   80108195 <kvmalloc>
  mpinit();        // collect info about this machine
801038da:	e8 41 04 00 00       	call   80103d20 <mpinit>
  lapicinit();
801038df:	e8 8e f5 ff ff       	call   80102e72 <lapicinit>
  seginit();       // set up segments
801038e4:	e8 3f 42 00 00       	call   80107b28 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038e9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038ef:	0f b6 00             	movzbl (%eax),%eax
801038f2:	0f b6 c0             	movzbl %al,%eax
801038f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801038f9:	c7 04 24 04 8c 10 80 	movl   $0x80108c04,(%esp)
80103900:	e8 fe ca ff ff       	call   80100403 <cprintf>
  picinit();       // interrupt controller
80103905:	e8 74 06 00 00       	call   80103f7e <picinit>
  ioapicinit();    // another interrupt controller
8010390a:	e8 ee f0 ff ff       	call   801029fd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010390f:	e8 39 d2 ff ff       	call   80100b4d <consoleinit>
  uartinit();      // serial port
80103914:	e8 1e 33 00 00       	call   80106c37 <uartinit>
  pinit();         // process table
80103919:	e8 70 0b 00 00       	call   8010448e <pinit>
  tvinit();        // trap vectors
8010391e:	e8 c6 2e 00 00       	call   801067e9 <tvinit>
  binit();         // buffer cache
80103923:	e8 0c c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103928:	e8 95 d6 ff ff       	call   80100fc2 <fileinit>
  ideinit();       // disk
8010392d:	e8 fd ec ff ff       	call   8010262f <ideinit>
  if(!ismp)
80103932:	a1 24 3d 11 80       	mov    0x80113d24,%eax
80103937:	85 c0                	test   %eax,%eax
80103939:	75 05                	jne    80103940 <main+0x88>
    timerinit();   // uniprocessor timer
8010393b:	e8 f4 2d 00 00       	call   80106734 <timerinit>
  startothers();   // start other processors
80103940:	e8 7f 00 00 00       	call   801039c4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103945:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010394c:	8e 
8010394d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103954:	e8 e6 f1 ff ff       	call   80102b3f <kinit2>
  userinit();      // first user process
80103959:	e8 58 0c 00 00       	call   801045b6 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010395e:	e8 1a 00 00 00       	call   8010397d <mpmain>

80103963 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103963:	55                   	push   %ebp
80103964:	89 e5                	mov    %esp,%ebp
80103966:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103969:	e8 3e 48 00 00       	call   801081ac <switchkvm>
  seginit();
8010396e:	e8 b5 41 00 00       	call   80107b28 <seginit>
  lapicinit();
80103973:	e8 fa f4 ff ff       	call   80102e72 <lapicinit>
  mpmain();
80103978:	e8 00 00 00 00       	call   8010397d <mpmain>

8010397d <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010397d:	55                   	push   %ebp
8010397e:	89 e5                	mov    %esp,%ebp
80103980:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103983:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103989:	0f b6 00             	movzbl (%eax),%eax
8010398c:	0f b6 c0             	movzbl %al,%eax
8010398f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103993:	c7 04 24 1b 8c 10 80 	movl   $0x80108c1b,(%esp)
8010399a:	e8 64 ca ff ff       	call   80100403 <cprintf>
  idtinit();       // load idt register
8010399f:	e8 b9 2f 00 00       	call   8010695d <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039aa:	05 a8 00 00 00       	add    $0xa8,%eax
801039af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801039b6:	00 
801039b7:	89 04 24             	mov    %eax,(%esp)
801039ba:	e8 df fe ff ff       	call   8010389e <xchg>
  scheduler();     // start running processes
801039bf:	e8 63 11 00 00       	call   80104b27 <scheduler>

801039c4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039c4:	55                   	push   %ebp
801039c5:	89 e5                	mov    %esp,%ebp
801039c7:	53                   	push   %ebx
801039c8:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039cb:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801039d2:	e8 ba fe ff ff       	call   80103891 <p2v>
801039d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039da:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039df:	89 44 24 08          	mov    %eax,0x8(%esp)
801039e3:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
801039ea:	80 
801039eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ee:	89 04 24             	mov    %eax,(%esp)
801039f1:	e8 e7 19 00 00       	call   801053dd <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801039f6:	c7 45 f4 40 3d 11 80 	movl   $0x80113d40,-0xc(%ebp)
801039fd:	e9 85 00 00 00       	jmp    80103a87 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103a02:	e8 c4 f5 ff ff       	call   80102fcb <cpunum>
80103a07:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a0d:	05 40 3d 11 80       	add    $0x80113d40,%eax
80103a12:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a15:	75 02                	jne    80103a19 <startothers+0x55>
      continue;
80103a17:	eb 67                	jmp    80103a80 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a19:	e8 17 f2 ff ff       	call   80102c35 <kalloc>
80103a1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a24:	83 e8 04             	sub    $0x4,%eax
80103a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a30:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a35:	83 e8 08             	sub    $0x8,%eax
80103a38:	c7 00 63 39 10 80    	movl   $0x80103963,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a41:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a44:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103a4b:	e8 34 fe ff ff       	call   80103884 <v2p>
80103a50:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a55:	89 04 24             	mov    %eax,(%esp)
80103a58:	e8 27 fe ff ff       	call   80103884 <v2p>
80103a5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a60:	0f b6 12             	movzbl (%edx),%edx
80103a63:	0f b6 d2             	movzbl %dl,%edx
80103a66:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a6a:	89 14 24             	mov    %edx,(%esp)
80103a6d:	e8 db f5 ff ff       	call   8010304d <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a72:	90                   	nop
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a7c:	85 c0                	test   %eax,%eax
80103a7e:	74 f3                	je     80103a73 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a80:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a87:	a1 20 43 11 80       	mov    0x80114320,%eax
80103a8c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a92:	05 40 3d 11 80       	add    $0x80113d40,%eax
80103a97:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a9a:	0f 87 62 ff ff ff    	ja     80103a02 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103aa0:	83 c4 24             	add    $0x24,%esp
80103aa3:	5b                   	pop    %ebx
80103aa4:	5d                   	pop    %ebp
80103aa5:	c3                   	ret    

80103aa6 <p2v>:
80103aa6:	55                   	push   %ebp
80103aa7:	89 e5                	mov    %esp,%ebp
80103aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80103aac:	05 00 00 00 80       	add    $0x80000000,%eax
80103ab1:	5d                   	pop    %ebp
80103ab2:	c3                   	ret    

80103ab3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ab3:	55                   	push   %ebp
80103ab4:	89 e5                	mov    %esp,%ebp
80103ab6:	83 ec 14             	sub    $0x14,%esp
80103ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80103abc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ac0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ac4:	89 c2                	mov    %eax,%edx
80103ac6:	ec                   	in     (%dx),%al
80103ac7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103aca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ace:	c9                   	leave  
80103acf:	c3                   	ret    

80103ad0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ad0:	55                   	push   %ebp
80103ad1:	89 e5                	mov    %esp,%ebp
80103ad3:	83 ec 08             	sub    $0x8,%esp
80103ad6:	8b 55 08             	mov    0x8(%ebp),%edx
80103ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103adc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ae0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ae3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ae7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aeb:	ee                   	out    %al,(%dx)
}
80103aec:	c9                   	leave  
80103aed:	c3                   	ret    

80103aee <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103aee:	55                   	push   %ebp
80103aef:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103af1:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103af6:	89 c2                	mov    %eax,%edx
80103af8:	b8 40 3d 11 80       	mov    $0x80113d40,%eax
80103afd:	29 c2                	sub    %eax,%edx
80103aff:	89 d0                	mov    %edx,%eax
80103b01:	c1 f8 02             	sar    $0x2,%eax
80103b04:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b0a:	5d                   	pop    %ebp
80103b0b:	c3                   	ret    

80103b0c <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b0c:	55                   	push   %ebp
80103b0d:	89 e5                	mov    %esp,%ebp
80103b0f:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b12:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b20:	eb 15                	jmp    80103b37 <sum+0x2b>
    sum += addr[i];
80103b22:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b25:	8b 45 08             	mov    0x8(%ebp),%eax
80103b28:	01 d0                	add    %edx,%eax
80103b2a:	0f b6 00             	movzbl (%eax),%eax
80103b2d:	0f b6 c0             	movzbl %al,%eax
80103b30:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b33:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b3a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b3d:	7c e3                	jl     80103b22 <sum+0x16>
    sum += addr[i];
  return sum;
80103b3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b42:	c9                   	leave  
80103b43:	c3                   	ret    

80103b44 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b44:	55                   	push   %ebp
80103b45:	89 e5                	mov    %esp,%ebp
80103b47:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b4d:	89 04 24             	mov    %eax,(%esp)
80103b50:	e8 51 ff ff ff       	call   80103aa6 <p2v>
80103b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b58:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5e:	01 d0                	add    %edx,%eax
80103b60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b69:	eb 3f                	jmp    80103baa <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b6b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b72:	00 
80103b73:	c7 44 24 04 2c 8c 10 	movl   $0x80108c2c,0x4(%esp)
80103b7a:	80 
80103b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7e:	89 04 24             	mov    %eax,(%esp)
80103b81:	e8 ff 17 00 00       	call   80105385 <memcmp>
80103b86:	85 c0                	test   %eax,%eax
80103b88:	75 1c                	jne    80103ba6 <mpsearch1+0x62>
80103b8a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b91:	00 
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	89 04 24             	mov    %eax,(%esp)
80103b98:	e8 6f ff ff ff       	call   80103b0c <sum>
80103b9d:	84 c0                	test   %al,%al
80103b9f:	75 05                	jne    80103ba6 <mpsearch1+0x62>
      return (struct mp*)p;
80103ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba4:	eb 11                	jmp    80103bb7 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bb0:	72 b9                	jb     80103b6b <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bb7:	c9                   	leave  
80103bb8:	c3                   	ret    

80103bb9 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bb9:	55                   	push   %ebp
80103bba:	89 e5                	mov    %esp,%ebp
80103bbc:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bbf:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc9:	83 c0 0f             	add    $0xf,%eax
80103bcc:	0f b6 00             	movzbl (%eax),%eax
80103bcf:	0f b6 c0             	movzbl %al,%eax
80103bd2:	c1 e0 08             	shl    $0x8,%eax
80103bd5:	89 c2                	mov    %eax,%edx
80103bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bda:	83 c0 0e             	add    $0xe,%eax
80103bdd:	0f b6 00             	movzbl (%eax),%eax
80103be0:	0f b6 c0             	movzbl %al,%eax
80103be3:	09 d0                	or     %edx,%eax
80103be5:	c1 e0 04             	shl    $0x4,%eax
80103be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bef:	74 21                	je     80103c12 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bf1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103bf8:	00 
80103bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfc:	89 04 24             	mov    %eax,(%esp)
80103bff:	e8 40 ff ff ff       	call   80103b44 <mpsearch1>
80103c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c07:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c0b:	74 50                	je     80103c5d <mpsearch+0xa4>
      return mp;
80103c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c10:	eb 5f                	jmp    80103c71 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c15:	83 c0 14             	add    $0x14,%eax
80103c18:	0f b6 00             	movzbl (%eax),%eax
80103c1b:	0f b6 c0             	movzbl %al,%eax
80103c1e:	c1 e0 08             	shl    $0x8,%eax
80103c21:	89 c2                	mov    %eax,%edx
80103c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c26:	83 c0 13             	add    $0x13,%eax
80103c29:	0f b6 00             	movzbl (%eax),%eax
80103c2c:	0f b6 c0             	movzbl %al,%eax
80103c2f:	09 d0                	or     %edx,%eax
80103c31:	c1 e0 0a             	shl    $0xa,%eax
80103c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3a:	2d 00 04 00 00       	sub    $0x400,%eax
80103c3f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c46:	00 
80103c47:	89 04 24             	mov    %eax,(%esp)
80103c4a:	e8 f5 fe ff ff       	call   80103b44 <mpsearch1>
80103c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c52:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c56:	74 05                	je     80103c5d <mpsearch+0xa4>
      return mp;
80103c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c5b:	eb 14                	jmp    80103c71 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c5d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c64:	00 
80103c65:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c6c:	e8 d3 fe ff ff       	call   80103b44 <mpsearch1>
}
80103c71:	c9                   	leave  
80103c72:	c3                   	ret    

80103c73 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c73:	55                   	push   %ebp
80103c74:	89 e5                	mov    %esp,%ebp
80103c76:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c79:	e8 3b ff ff ff       	call   80103bb9 <mpsearch>
80103c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c85:	74 0a                	je     80103c91 <mpconfig+0x1e>
80103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8a:	8b 40 04             	mov    0x4(%eax),%eax
80103c8d:	85 c0                	test   %eax,%eax
80103c8f:	75 0a                	jne    80103c9b <mpconfig+0x28>
    return 0;
80103c91:	b8 00 00 00 00       	mov    $0x0,%eax
80103c96:	e9 83 00 00 00       	jmp    80103d1e <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	8b 40 04             	mov    0x4(%eax),%eax
80103ca1:	89 04 24             	mov    %eax,(%esp)
80103ca4:	e8 fd fd ff ff       	call   80103aa6 <p2v>
80103ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cac:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103cb3:	00 
80103cb4:	c7 44 24 04 31 8c 10 	movl   $0x80108c31,0x4(%esp)
80103cbb:	80 
80103cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbf:	89 04 24             	mov    %eax,(%esp)
80103cc2:	e8 be 16 00 00       	call   80105385 <memcmp>
80103cc7:	85 c0                	test   %eax,%eax
80103cc9:	74 07                	je     80103cd2 <mpconfig+0x5f>
    return 0;
80103ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd0:	eb 4c                	jmp    80103d1e <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cd9:	3c 01                	cmp    $0x1,%al
80103cdb:	74 12                	je     80103cef <mpconfig+0x7c>
80103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ce4:	3c 04                	cmp    $0x4,%al
80103ce6:	74 07                	je     80103cef <mpconfig+0x7c>
    return 0;
80103ce8:	b8 00 00 00 00       	mov    $0x0,%eax
80103ced:	eb 2f                	jmp    80103d1e <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cf6:	0f b7 c0             	movzwl %ax,%eax
80103cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d00:	89 04 24             	mov    %eax,(%esp)
80103d03:	e8 04 fe ff ff       	call   80103b0c <sum>
80103d08:	84 c0                	test   %al,%al
80103d0a:	74 07                	je     80103d13 <mpconfig+0xa0>
    return 0;
80103d0c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d11:	eb 0b                	jmp    80103d1e <mpconfig+0xab>
  *pmp = mp;
80103d13:	8b 45 08             	mov    0x8(%ebp),%eax
80103d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d19:	89 10                	mov    %edx,(%eax)
  return conf;
80103d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d1e:	c9                   	leave  
80103d1f:	c3                   	ret    

80103d20 <mpinit>:

void
mpinit(void)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d26:	c7 05 64 c6 10 80 40 	movl   $0x80113d40,0x8010c664
80103d2d:	3d 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d30:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d33:	89 04 24             	mov    %eax,(%esp)
80103d36:	e8 38 ff ff ff       	call   80103c73 <mpconfig>
80103d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d42:	75 05                	jne    80103d49 <mpinit+0x29>
    return;
80103d44:	e9 9c 01 00 00       	jmp    80103ee5 <mpinit+0x1c5>
  ismp = 1;
80103d49:	c7 05 24 3d 11 80 01 	movl   $0x1,0x80113d24
80103d50:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d56:	8b 40 24             	mov    0x24(%eax),%eax
80103d59:	a3 3c 3c 11 80       	mov    %eax,0x80113c3c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d61:	83 c0 2c             	add    $0x2c,%eax
80103d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6e:	0f b7 d0             	movzwl %ax,%edx
80103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d74:	01 d0                	add    %edx,%eax
80103d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d79:	e9 f4 00 00 00       	jmp    80103e72 <mpinit+0x152>
    switch(*p){
80103d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d81:	0f b6 00             	movzbl (%eax),%eax
80103d84:	0f b6 c0             	movzbl %al,%eax
80103d87:	83 f8 04             	cmp    $0x4,%eax
80103d8a:	0f 87 bf 00 00 00    	ja     80103e4f <mpinit+0x12f>
80103d90:	8b 04 85 74 8c 10 80 	mov    -0x7fef738c(,%eax,4),%eax
80103d97:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103da2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103da6:	0f b6 d0             	movzbl %al,%edx
80103da9:	a1 20 43 11 80       	mov    0x80114320,%eax
80103dae:	39 c2                	cmp    %eax,%edx
80103db0:	74 2d                	je     80103ddf <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103db5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103db9:	0f b6 d0             	movzbl %al,%edx
80103dbc:	a1 20 43 11 80       	mov    0x80114320,%eax
80103dc1:	89 54 24 08          	mov    %edx,0x8(%esp)
80103dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc9:	c7 04 24 36 8c 10 80 	movl   $0x80108c36,(%esp)
80103dd0:	e8 2e c6 ff ff       	call   80100403 <cprintf>
        ismp = 0;
80103dd5:	c7 05 24 3d 11 80 00 	movl   $0x0,0x80113d24
80103ddc:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ddf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103de2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103de6:	0f b6 c0             	movzbl %al,%eax
80103de9:	83 e0 02             	and    $0x2,%eax
80103dec:	85 c0                	test   %eax,%eax
80103dee:	74 15                	je     80103e05 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103df0:	a1 20 43 11 80       	mov    0x80114320,%eax
80103df5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dfb:	05 40 3d 11 80       	add    $0x80113d40,%eax
80103e00:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e05:	8b 15 20 43 11 80    	mov    0x80114320,%edx
80103e0b:	a1 20 43 11 80       	mov    0x80114320,%eax
80103e10:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103e16:	81 c2 40 3d 11 80    	add    $0x80113d40,%edx
80103e1c:	88 02                	mov    %al,(%edx)
      ncpu++;
80103e1e:	a1 20 43 11 80       	mov    0x80114320,%eax
80103e23:	83 c0 01             	add    $0x1,%eax
80103e26:	a3 20 43 11 80       	mov    %eax,0x80114320
      p += sizeof(struct mpproc);
80103e2b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e2f:	eb 41                	jmp    80103e72 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e3a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e3e:	a2 20 3d 11 80       	mov    %al,0x80113d20
      p += sizeof(struct mpioapic);
80103e43:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e47:	eb 29                	jmp    80103e72 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e49:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e4d:	eb 23                	jmp    80103e72 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e52:	0f b6 00             	movzbl (%eax),%eax
80103e55:	0f b6 c0             	movzbl %al,%eax
80103e58:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e5c:	c7 04 24 54 8c 10 80 	movl   $0x80108c54,(%esp)
80103e63:	e8 9b c5 ff ff       	call   80100403 <cprintf>
      ismp = 0;
80103e68:	c7 05 24 3d 11 80 00 	movl   $0x0,0x80113d24
80103e6f:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e75:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e78:	0f 82 00 ff ff ff    	jb     80103d7e <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e7e:	a1 24 3d 11 80       	mov    0x80113d24,%eax
80103e83:	85 c0                	test   %eax,%eax
80103e85:	75 1d                	jne    80103ea4 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e87:	c7 05 20 43 11 80 01 	movl   $0x1,0x80114320
80103e8e:	00 00 00 
    lapic = 0;
80103e91:	c7 05 3c 3c 11 80 00 	movl   $0x0,0x80113c3c
80103e98:	00 00 00 
    ioapicid = 0;
80103e9b:	c6 05 20 3d 11 80 00 	movb   $0x0,0x80113d20
    return;
80103ea2:	eb 41                	jmp    80103ee5 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ea7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103eab:	84 c0                	test   %al,%al
80103ead:	74 36                	je     80103ee5 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103eaf:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103eb6:	00 
80103eb7:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103ebe:	e8 0d fc ff ff       	call   80103ad0 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ec3:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103eca:	e8 e4 fb ff ff       	call   80103ab3 <inb>
80103ecf:	83 c8 01             	or     $0x1,%eax
80103ed2:	0f b6 c0             	movzbl %al,%eax
80103ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ed9:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103ee0:	e8 eb fb ff ff       	call   80103ad0 <outb>
  }
}
80103ee5:	c9                   	leave  
80103ee6:	c3                   	ret    

80103ee7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ee7:	55                   	push   %ebp
80103ee8:	89 e5                	mov    %esp,%ebp
80103eea:	83 ec 08             	sub    $0x8,%esp
80103eed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ef7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103efa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103efe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f02:	ee                   	out    %al,(%dx)
}
80103f03:	c9                   	leave  
80103f04:	c3                   	ret    

80103f05 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	83 ec 0c             	sub    $0xc,%esp
80103f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f16:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103f1c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f20:	0f b6 c0             	movzbl %al,%eax
80103f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f27:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f2e:	e8 b4 ff ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103f33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f37:	66 c1 e8 08          	shr    $0x8,%ax
80103f3b:	0f b6 c0             	movzbl %al,%eax
80103f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f42:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f49:	e8 99 ff ff ff       	call   80103ee7 <outb>
}
80103f4e:	c9                   	leave  
80103f4f:	c3                   	ret    

80103f50 <picenable>:

void
picenable(int irq)
{
80103f50:	55                   	push   %ebp
80103f51:	89 e5                	mov    %esp,%ebp
80103f53:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103f56:	8b 45 08             	mov    0x8(%ebp),%eax
80103f59:	ba 01 00 00 00       	mov    $0x1,%edx
80103f5e:	89 c1                	mov    %eax,%ecx
80103f60:	d3 e2                	shl    %cl,%edx
80103f62:	89 d0                	mov    %edx,%eax
80103f64:	f7 d0                	not    %eax
80103f66:	89 c2                	mov    %eax,%edx
80103f68:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f6f:	21 d0                	and    %edx,%eax
80103f71:	0f b7 c0             	movzwl %ax,%eax
80103f74:	89 04 24             	mov    %eax,(%esp)
80103f77:	e8 89 ff ff ff       	call   80103f05 <picsetmask>
}
80103f7c:	c9                   	leave  
80103f7d:	c3                   	ret    

80103f7e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f7e:	55                   	push   %ebp
80103f7f:	89 e5                	mov    %esp,%ebp
80103f81:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f84:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f8b:	00 
80103f8c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f93:	e8 4f ff ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, 0xFF);
80103f98:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f9f:	00 
80103fa0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103fa7:	e8 3b ff ff ff       	call   80103ee7 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fac:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103fb3:	00 
80103fb4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103fbb:	e8 27 ff ff ff       	call   80103ee7 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103fc7:	00 
80103fc8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fcf:	e8 13 ff ff ff       	call   80103ee7 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fd4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103fdb:	00 
80103fdc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fe3:	e8 ff fe ff ff       	call   80103ee7 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fe8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103fef:	00 
80103ff0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ff7:	e8 eb fe ff ff       	call   80103ee7 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ffc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104003:	00 
80104004:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010400b:	e8 d7 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104010:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104017:	00 
80104018:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010401f:	e8 c3 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104024:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010402b:	00 
8010402c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104033:	e8 af fe ff ff       	call   80103ee7 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104038:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010403f:	00 
80104040:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104047:	e8 9b fe ff ff       	call   80103ee7 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010404c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104053:	00 
80104054:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010405b:	e8 87 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104060:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104067:	00 
80104068:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010406f:	e8 73 fe ff ff       	call   80103ee7 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104074:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
8010407b:	00 
8010407c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104083:	e8 5f fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104088:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010408f:	00 
80104090:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104097:	e8 4b fe ff ff       	call   80103ee7 <outb>

  if(irqmask != 0xFFFF)
8010409c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040a3:	66 83 f8 ff          	cmp    $0xffff,%ax
801040a7:	74 12                	je     801040bb <picinit+0x13d>
    picsetmask(irqmask);
801040a9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040b0:	0f b7 c0             	movzwl %ax,%eax
801040b3:	89 04 24             	mov    %eax,(%esp)
801040b6:	e8 4a fe ff ff       	call   80103f05 <picsetmask>
}
801040bb:	c9                   	leave  
801040bc:	c3                   	ret    

801040bd <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040bd:	55                   	push   %ebp
801040be:	89 e5                	mov    %esp,%ebp
801040c0:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
801040c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d6:	8b 10                	mov    (%eax),%edx
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040dd:	e8 fc ce ff ff       	call   80100fde <filealloc>
801040e2:	8b 55 08             	mov    0x8(%ebp),%edx
801040e5:	89 02                	mov    %eax,(%edx)
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 00                	mov    (%eax),%eax
801040ec:	85 c0                	test   %eax,%eax
801040ee:	0f 84 c8 00 00 00    	je     801041bc <pipealloc+0xff>
801040f4:	e8 e5 ce ff ff       	call   80100fde <filealloc>
801040f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801040fc:	89 02                	mov    %eax,(%edx)
801040fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104101:	8b 00                	mov    (%eax),%eax
80104103:	85 c0                	test   %eax,%eax
80104105:	0f 84 b1 00 00 00    	je     801041bc <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010410b:	e8 25 eb ff ff       	call   80102c35 <kalloc>
80104110:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104113:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104117:	75 05                	jne    8010411e <pipealloc+0x61>
    goto bad;
80104119:	e9 9e 00 00 00       	jmp    801041bc <pipealloc+0xff>
  p->readopen = 1;
8010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104121:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104128:	00 00 00 
  p->writeopen = 1;
8010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104135:	00 00 00 
  p->nwrite = 0;
80104138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104142:	00 00 00 
  p->nread = 0;
80104145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104148:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010414f:	00 00 00 
  initlock(&p->lock, "pipe");
80104152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104155:	c7 44 24 04 88 8c 10 	movl   $0x80108c88,0x4(%esp)
8010415c:	80 
8010415d:	89 04 24             	mov    %eax,(%esp)
80104160:	e8 34 0f 00 00       	call   80105099 <initlock>
  (*f0)->type = FD_PIPE;
80104165:	8b 45 08             	mov    0x8(%ebp),%eax
80104168:	8b 00                	mov    (%eax),%eax
8010416a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	8b 00                	mov    (%eax),%eax
80104175:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	8b 00                	mov    (%eax),%eax
8010417e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	8b 00                	mov    (%eax),%eax
80104187:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010418d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104190:	8b 00                	mov    (%eax),%eax
80104192:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010419b:	8b 00                	mov    (%eax),%eax
8010419d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a4:	8b 00                	mov    (%eax),%eax
801041a6:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ad:	8b 00                	mov    (%eax),%eax
801041af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b2:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041b5:	b8 00 00 00 00       	mov    $0x0,%eax
801041ba:	eb 42                	jmp    801041fe <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801041bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041c0:	74 0b                	je     801041cd <pipealloc+0x110>
    kfree((char*)p);
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	89 04 24             	mov    %eax,(%esp)
801041c8:	e8 cf e9 ff ff       	call   80102b9c <kfree>
  if(*f0)
801041cd:	8b 45 08             	mov    0x8(%ebp),%eax
801041d0:	8b 00                	mov    (%eax),%eax
801041d2:	85 c0                	test   %eax,%eax
801041d4:	74 0d                	je     801041e3 <pipealloc+0x126>
    fileclose(*f0);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	8b 00                	mov    (%eax),%eax
801041db:	89 04 24             	mov    %eax,(%esp)
801041de:	e8 a3 ce ff ff       	call   80101086 <fileclose>
  if(*f1)
801041e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e6:	8b 00                	mov    (%eax),%eax
801041e8:	85 c0                	test   %eax,%eax
801041ea:	74 0d                	je     801041f9 <pipealloc+0x13c>
    fileclose(*f1);
801041ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ef:	8b 00                	mov    (%eax),%eax
801041f1:	89 04 24             	mov    %eax,(%esp)
801041f4:	e8 8d ce ff ff       	call   80101086 <fileclose>
  return -1;
801041f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041fe:	c9                   	leave  
801041ff:	c3                   	ret    

80104200 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104200:	55                   	push   %ebp
80104201:	89 e5                	mov    %esp,%ebp
80104203:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	89 04 24             	mov    %eax,(%esp)
8010420c:	e8 a9 0e 00 00       	call   801050ba <acquire>
  if(writable){
80104211:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104215:	74 1f                	je     80104236 <pipeclose+0x36>
    p->writeopen = 0;
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104221:	00 00 00 
    wakeup(&p->nread);
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	05 34 02 00 00       	add    $0x234,%eax
8010422c:	89 04 24             	mov    %eax,(%esp)
8010422f:	e8 95 0c 00 00       	call   80104ec9 <wakeup>
80104234:	eb 1d                	jmp    80104253 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104236:	8b 45 08             	mov    0x8(%ebp),%eax
80104239:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104240:	00 00 00 
    wakeup(&p->nwrite);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	05 38 02 00 00       	add    $0x238,%eax
8010424b:	89 04 24             	mov    %eax,(%esp)
8010424e:	e8 76 0c 00 00       	call   80104ec9 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010425c:	85 c0                	test   %eax,%eax
8010425e:	75 25                	jne    80104285 <pipeclose+0x85>
80104260:	8b 45 08             	mov    0x8(%ebp),%eax
80104263:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104269:	85 c0                	test   %eax,%eax
8010426b:	75 18                	jne    80104285 <pipeclose+0x85>
    release(&p->lock);
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	89 04 24             	mov    %eax,(%esp)
80104273:	e8 a4 0e 00 00       	call   8010511c <release>
    kfree((char*)p);
80104278:	8b 45 08             	mov    0x8(%ebp),%eax
8010427b:	89 04 24             	mov    %eax,(%esp)
8010427e:	e8 19 e9 ff ff       	call   80102b9c <kfree>
80104283:	eb 0b                	jmp    80104290 <pipeclose+0x90>
  } else
    release(&p->lock);
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	89 04 24             	mov    %eax,(%esp)
8010428b:	e8 8c 0e 00 00       	call   8010511c <release>
}
80104290:	c9                   	leave  
80104291:	c3                   	ret    

80104292 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104292:	55                   	push   %ebp
80104293:	89 e5                	mov    %esp,%ebp
80104295:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104298:	8b 45 08             	mov    0x8(%ebp),%eax
8010429b:	89 04 24             	mov    %eax,(%esp)
8010429e:	e8 17 0e 00 00       	call   801050ba <acquire>
  for(i = 0; i < n; i++){
801042a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042aa:	e9 a6 00 00 00       	jmp    80104355 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042af:	eb 57                	jmp    80104308 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801042b1:	8b 45 08             	mov    0x8(%ebp),%eax
801042b4:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	74 0d                	je     801042cb <pipewrite+0x39>
801042be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042c4:	8b 40 24             	mov    0x24(%eax),%eax
801042c7:	85 c0                	test   %eax,%eax
801042c9:	74 15                	je     801042e0 <pipewrite+0x4e>
        release(&p->lock);
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	89 04 24             	mov    %eax,(%esp)
801042d1:	e8 46 0e 00 00       	call   8010511c <release>
        return -1;
801042d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042db:	e9 9f 00 00 00       	jmp    8010437f <pipewrite+0xed>
      }
      wakeup(&p->nread);
801042e0:	8b 45 08             	mov    0x8(%ebp),%eax
801042e3:	05 34 02 00 00       	add    $0x234,%eax
801042e8:	89 04 24             	mov    %eax,(%esp)
801042eb:	e8 d9 0b 00 00       	call   80104ec9 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 55 08             	mov    0x8(%ebp),%edx
801042f6:	81 c2 38 02 00 00    	add    $0x238,%edx
801042fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104300:	89 14 24             	mov    %edx,(%esp)
80104303:	e8 e8 0a 00 00       	call   80104df0 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104308:	8b 45 08             	mov    0x8(%ebp),%eax
8010430b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104311:	8b 45 08             	mov    0x8(%ebp),%eax
80104314:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010431a:	05 00 02 00 00       	add    $0x200,%eax
8010431f:	39 c2                	cmp    %eax,%edx
80104321:	74 8e                	je     801042b1 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432c:	8d 48 01             	lea    0x1(%eax),%ecx
8010432f:	8b 55 08             	mov    0x8(%ebp),%edx
80104332:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104338:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433d:	89 c1                	mov    %eax,%ecx
8010433f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104342:	8b 45 0c             	mov    0xc(%ebp),%eax
80104345:	01 d0                	add    %edx,%eax
80104347:	0f b6 10             	movzbl (%eax),%edx
8010434a:	8b 45 08             	mov    0x8(%ebp),%eax
8010434d:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	3b 45 10             	cmp    0x10(%ebp),%eax
8010435b:	0f 8c 4e ff ff ff    	jl     801042af <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	05 34 02 00 00       	add    $0x234,%eax
80104369:	89 04 24             	mov    %eax,(%esp)
8010436c:	e8 58 0b 00 00       	call   80104ec9 <wakeup>
  release(&p->lock);
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	89 04 24             	mov    %eax,(%esp)
80104377:	e8 a0 0d 00 00       	call   8010511c <release>
  return n;
8010437c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010437f:	c9                   	leave  
80104380:	c3                   	ret    

80104381 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104381:	55                   	push   %ebp
80104382:	89 e5                	mov    %esp,%ebp
80104384:	53                   	push   %ebx
80104385:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104388:	8b 45 08             	mov    0x8(%ebp),%eax
8010438b:	89 04 24             	mov    %eax,(%esp)
8010438e:	e8 27 0d 00 00       	call   801050ba <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	eb 3a                	jmp    801043cf <piperead+0x4e>
    if(proc->killed){
80104395:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439b:	8b 40 24             	mov    0x24(%eax),%eax
8010439e:	85 c0                	test   %eax,%eax
801043a0:	74 15                	je     801043b7 <piperead+0x36>
      release(&p->lock);
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	89 04 24             	mov    %eax,(%esp)
801043a8:	e8 6f 0d 00 00       	call   8010511c <release>
      return -1;
801043ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b2:	e9 b5 00 00 00       	jmp    8010446c <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043b7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ba:	8b 55 08             	mov    0x8(%ebp),%edx
801043bd:	81 c2 34 02 00 00    	add    $0x234,%edx
801043c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801043c7:	89 14 24             	mov    %edx,(%esp)
801043ca:	e8 21 0a 00 00       	call   80104df0 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043cf:	8b 45 08             	mov    0x8(%ebp),%eax
801043d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043d8:	8b 45 08             	mov    0x8(%ebp),%eax
801043db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e1:	39 c2                	cmp    %eax,%edx
801043e3:	75 0d                	jne    801043f2 <piperead+0x71>
801043e5:	8b 45 08             	mov    0x8(%ebp),%eax
801043e8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043ee:	85 c0                	test   %eax,%eax
801043f0:	75 a3                	jne    80104395 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043f9:	eb 4b                	jmp    80104446 <piperead+0xc5>
    if(p->nread == p->nwrite)
801043fb:	8b 45 08             	mov    0x8(%ebp),%eax
801043fe:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104404:	8b 45 08             	mov    0x8(%ebp),%eax
80104407:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010440d:	39 c2                	cmp    %eax,%edx
8010440f:	75 02                	jne    80104413 <piperead+0x92>
      break;
80104411:	eb 3b                	jmp    8010444e <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104416:	8b 45 0c             	mov    0xc(%ebp),%eax
80104419:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010441c:	8b 45 08             	mov    0x8(%ebp),%eax
8010441f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104425:	8d 48 01             	lea    0x1(%eax),%ecx
80104428:	8b 55 08             	mov    0x8(%ebp),%edx
8010442b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104431:	25 ff 01 00 00       	and    $0x1ff,%eax
80104436:	89 c2                	mov    %eax,%edx
80104438:	8b 45 08             	mov    0x8(%ebp),%eax
8010443b:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104440:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104442:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	3b 45 10             	cmp    0x10(%ebp),%eax
8010444c:	7c ad                	jl     801043fb <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010444e:	8b 45 08             	mov    0x8(%ebp),%eax
80104451:	05 38 02 00 00       	add    $0x238,%eax
80104456:	89 04 24             	mov    %eax,(%esp)
80104459:	e8 6b 0a 00 00       	call   80104ec9 <wakeup>
  release(&p->lock);
8010445e:	8b 45 08             	mov    0x8(%ebp),%eax
80104461:	89 04 24             	mov    %eax,(%esp)
80104464:	e8 b3 0c 00 00       	call   8010511c <release>
  return i;
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010446c:	83 c4 24             	add    $0x24,%esp
8010446f:	5b                   	pop    %ebx
80104470:	5d                   	pop    %ebp
80104471:	c3                   	ret    

80104472 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104472:	55                   	push   %ebp
80104473:	89 e5                	mov    %esp,%ebp
80104475:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104478:	9c                   	pushf  
80104479:	58                   	pop    %eax
8010447a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010447d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104480:	c9                   	leave  
80104481:	c3                   	ret    

80104482 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104482:	55                   	push   %ebp
80104483:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104485:	fb                   	sti    
}
80104486:	5d                   	pop    %ebp
80104487:	c3                   	ret    

80104488 <hlt>:

static inline void
hlt(void)
{
80104488:	55                   	push   %ebp
80104489:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
8010448b:	f4                   	hlt    
}
8010448c:	5d                   	pop    %ebp
8010448d:	c3                   	ret    

8010448e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010448e:	55                   	push   %ebp
8010448f:	89 e5                	mov    %esp,%ebp
80104491:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104494:	c7 44 24 04 8d 8c 10 	movl   $0x80108c8d,0x4(%esp)
8010449b:	80 
8010449c:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
801044a3:	e8 f1 0b 00 00       	call   80105099 <initlock>
  // Seed RNG with current time
  sgenrand(unixtime());
801044a8:	e8 a8 ee ff ff       	call   80103355 <unixtime>
801044ad:	89 04 24             	mov    %eax,(%esp)
801044b0:	e8 ba 33 00 00       	call   8010786f <sgenrand>
}
801044b5:	c9                   	leave  
801044b6:	c3                   	ret    

801044b7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044b7:	55                   	push   %ebp
801044b8:	89 e5                	mov    %esp,%ebp
801044ba:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044bd:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
801044c4:	e8 f1 0b 00 00       	call   801050ba <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c9:	c7 45 f4 74 43 11 80 	movl   $0x80114374,-0xc(%ebp)
801044d0:	eb 50                	jmp    80104522 <allocproc+0x6b>
    if(p->state == UNUSED)
801044d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d5:	8b 40 0c             	mov    0xc(%eax),%eax
801044d8:	85 c0                	test   %eax,%eax
801044da:	75 42                	jne    8010451e <allocproc+0x67>
      goto found;
801044dc:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044e7:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801044ec:	8d 50 01             	lea    0x1(%eax),%edx
801044ef:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801044f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f8:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044fb:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104502:	e8 15 0c 00 00       	call   8010511c <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104507:	e8 29 e7 ff ff       	call   80102c35 <kalloc>
8010450c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450f:	89 42 08             	mov    %eax,0x8(%edx)
80104512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104515:	8b 40 08             	mov    0x8(%eax),%eax
80104518:	85 c0                	test   %eax,%eax
8010451a:	75 33                	jne    8010454f <allocproc+0x98>
8010451c:	eb 20                	jmp    8010453e <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010451e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104522:	81 7d f4 74 63 11 80 	cmpl   $0x80116374,-0xc(%ebp)
80104529:	72 a7                	jb     801044d2 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010452b:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104532:	e8 e5 0b 00 00       	call   8010511c <release>
  return 0;
80104537:	b8 00 00 00 00       	mov    $0x0,%eax
8010453c:	eb 76                	jmp    801045b4 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010453e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104541:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104548:	b8 00 00 00 00       	mov    $0x0,%eax
8010454d:	eb 65                	jmp    801045b4 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	8b 40 08             	mov    0x8(%eax),%eax
80104555:	05 00 10 00 00       	add    $0x1000,%eax
8010455a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010455d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104564:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104567:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010456a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010456e:	ba a4 67 10 80       	mov    $0x801067a4,%edx
80104573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104576:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104578:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010457c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104582:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104588:	8b 40 1c             	mov    0x1c(%eax),%eax
8010458b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104592:	00 
80104593:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010459a:	00 
8010459b:	89 04 24             	mov    %eax,(%esp)
8010459e:	e8 6b 0d 00 00       	call   8010530e <memset>
  p->context->eip = (uint)forkret;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801045a9:	ba b1 4d 10 80       	mov    $0x80104db1,%edx
801045ae:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045b4:	c9                   	leave  
801045b5:	c3                   	ret    

801045b6 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045b6:	55                   	push   %ebp
801045b7:	89 e5                	mov    %esp,%ebp
801045b9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045bc:	e8 f6 fe ff ff       	call   801044b7 <allocproc>
801045c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c7:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801045cc:	e8 07 3b 00 00       	call   801080d8 <setupkvm>
801045d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d4:	89 42 04             	mov    %eax,0x4(%edx)
801045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045da:	8b 40 04             	mov    0x4(%eax),%eax
801045dd:	85 c0                	test   %eax,%eax
801045df:	75 0c                	jne    801045ed <userinit+0x37>
    panic("userinit: out of memory?");
801045e1:	c7 04 24 94 8c 10 80 	movl   $0x80108c94,(%esp)
801045e8:	e8 ea bf ff ff       	call   801005d7 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045ed:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f5:	8b 40 04             	mov    0x4(%eax),%eax
801045f8:	89 54 24 08          	mov    %edx,0x8(%esp)
801045fc:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
80104603:	80 
80104604:	89 04 24             	mov    %eax,(%esp)
80104607:	e8 24 3d 00 00       	call   80108330 <inituvm>
  p->sz = PGSIZE;
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104618:	8b 40 18             	mov    0x18(%eax),%eax
8010461b:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104622:	00 
80104623:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010462a:	00 
8010462b:	89 04 24             	mov    %eax,(%esp)
8010462e:	e8 db 0c 00 00       	call   8010530e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104636:	8b 40 18             	mov    0x18(%eax),%eax
80104639:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104642:	8b 40 18             	mov    0x18(%eax),%eax
80104645:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 18             	mov    0x18(%eax),%eax
80104651:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104654:	8b 52 18             	mov    0x18(%edx),%edx
80104657:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010465b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010465f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104662:	8b 40 18             	mov    0x18(%eax),%eax
80104665:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104668:	8b 52 18             	mov    0x18(%edx),%edx
8010466b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010466f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104676:	8b 40 18             	mov    0x18(%eax),%eax
80104679:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 40 18             	mov    0x18(%eax),%eax
80104686:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104690:	8b 40 18             	mov    0x18(%eax),%eax
80104693:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469d:	83 c0 6c             	add    $0x6c,%eax
801046a0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046a7:	00 
801046a8:	c7 44 24 04 ad 8c 10 	movl   $0x80108cad,0x4(%esp)
801046af:	80 
801046b0:	89 04 24             	mov    %eax,(%esp)
801046b3:	e8 76 0e 00 00       	call   8010552e <safestrcpy>
  p->cwd = namei("/");
801046b8:	c7 04 24 b6 8c 10 80 	movl   $0x80108cb6,(%esp)
801046bf:	e8 5e de ff ff       	call   80102522 <namei>
801046c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c7:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046d4:	c9                   	leave  
801046d5:	c3                   	ret    

801046d6 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046d6:	55                   	push   %ebp
801046d7:	89 e5                	mov    %esp,%ebp
801046d9:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801046dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e2:	8b 00                	mov    (%eax),%eax
801046e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046eb:	7e 34                	jle    80104721 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046ed:	8b 55 08             	mov    0x8(%ebp),%edx
801046f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f3:	01 c2                	add    %eax,%edx
801046f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fb:	8b 40 04             	mov    0x4(%eax),%eax
801046fe:	89 54 24 08          	mov    %edx,0x8(%esp)
80104702:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104705:	89 54 24 04          	mov    %edx,0x4(%esp)
80104709:	89 04 24             	mov    %eax,(%esp)
8010470c:	e8 95 3d 00 00       	call   801084a6 <allocuvm>
80104711:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104714:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104718:	75 41                	jne    8010475b <growproc+0x85>
      return -1;
8010471a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471f:	eb 58                	jmp    80104779 <growproc+0xa3>
  } else if(n < 0){
80104721:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104725:	79 34                	jns    8010475b <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104727:	8b 55 08             	mov    0x8(%ebp),%edx
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	01 c2                	add    %eax,%edx
8010472f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104735:	8b 40 04             	mov    0x4(%eax),%eax
80104738:	89 54 24 08          	mov    %edx,0x8(%esp)
8010473c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010473f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104743:	89 04 24             	mov    %eax,(%esp)
80104746:	e8 35 3e 00 00       	call   80108580 <deallocuvm>
8010474b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010474e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104752:	75 07                	jne    8010475b <growproc+0x85>
      return -1;
80104754:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104759:	eb 1e                	jmp    80104779 <growproc+0xa3>
  }
  proc->sz = sz;
8010475b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104764:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476c:	89 04 24             	mov    %eax,(%esp)
8010476f:	e8 55 3a 00 00       	call   801081c9 <switchuvm>
  return 0;
80104774:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104779:	c9                   	leave  
8010477a:	c3                   	ret    

8010477b <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010477b:	55                   	push   %ebp
8010477c:	89 e5                	mov    %esp,%ebp
8010477e:	57                   	push   %edi
8010477f:	56                   	push   %esi
80104780:	53                   	push   %ebx
80104781:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104784:	e8 2e fd ff ff       	call   801044b7 <allocproc>
80104789:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010478c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104790:	75 0a                	jne    8010479c <fork+0x21>
    return -1;
80104792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104797:	e9 52 01 00 00       	jmp    801048ee <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010479c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a2:	8b 10                	mov    (%eax),%edx
801047a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047aa:	8b 40 04             	mov    0x4(%eax),%eax
801047ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801047b1:	89 04 24             	mov    %eax,(%esp)
801047b4:	e8 63 3f 00 00       	call   8010871c <copyuvm>
801047b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047bc:	89 42 04             	mov    %eax,0x4(%edx)
801047bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c2:	8b 40 04             	mov    0x4(%eax),%eax
801047c5:	85 c0                	test   %eax,%eax
801047c7:	75 2c                	jne    801047f5 <fork+0x7a>
    kfree(np->kstack);
801047c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cc:	8b 40 08             	mov    0x8(%eax),%eax
801047cf:	89 04 24             	mov    %eax,(%esp)
801047d2:	e8 c5 e3 ff ff       	call   80102b9c <kfree>
    np->kstack = 0;
801047d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f0:	e9 f9 00 00 00       	jmp    801048ee <fork+0x173>
  }
  np->sz = proc->sz;
801047f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fb:	8b 10                	mov    (%eax),%edx
801047fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104800:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104802:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104809:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010480f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104812:	8b 50 18             	mov    0x18(%eax),%edx
80104815:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481b:	8b 40 18             	mov    0x18(%eax),%eax
8010481e:	89 c3                	mov    %eax,%ebx
80104820:	b8 13 00 00 00       	mov    $0x13,%eax
80104825:	89 d7                	mov    %edx,%edi
80104827:	89 de                	mov    %ebx,%esi
80104829:	89 c1                	mov    %eax,%ecx
8010482b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010482d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104830:	8b 40 18             	mov    0x18(%eax),%eax
80104833:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010483a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104841:	eb 3d                	jmp    80104880 <fork+0x105>
    if(proc->ofile[i])
80104843:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104849:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010484c:	83 c2 08             	add    $0x8,%edx
8010484f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104853:	85 c0                	test   %eax,%eax
80104855:	74 25                	je     8010487c <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104860:	83 c2 08             	add    $0x8,%edx
80104863:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104867:	89 04 24             	mov    %eax,(%esp)
8010486a:	e8 cf c7 ff ff       	call   8010103e <filedup>
8010486f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104872:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104875:	83 c1 08             	add    $0x8,%ecx
80104878:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010487c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104880:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104884:	7e bd                	jle    80104843 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104886:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488c:	8b 40 68             	mov    0x68(%eax),%eax
8010488f:	89 04 24             	mov    %eax,(%esp)
80104892:	e8 a8 d0 ff ff       	call   8010193f <idup>
80104897:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010489a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	8d 50 6c             	lea    0x6c(%eax),%edx
801048a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a9:	83 c0 6c             	add    $0x6c,%eax
801048ac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048b3:	00 
801048b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b8:	89 04 24             	mov    %eax,(%esp)
801048bb:	e8 6e 0c 00 00       	call   8010552e <safestrcpy>
 
  pid = np->pid;
801048c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c3:	8b 40 10             	mov    0x10(%eax),%eax
801048c6:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048c9:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
801048d0:	e8 e5 07 00 00       	call   801050ba <acquire>
  np->state = RUNNABLE;
801048d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048df:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
801048e6:	e8 31 08 00 00       	call   8010511c <release>
  
  return pid;
801048eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048ee:	83 c4 2c             	add    $0x2c,%esp
801048f1:	5b                   	pop    %ebx
801048f2:	5e                   	pop    %esi
801048f3:	5f                   	pop    %edi
801048f4:	5d                   	pop    %ebp
801048f5:	c3                   	ret    

801048f6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048f6:	55                   	push   %ebp
801048f7:	89 e5                	mov    %esp,%ebp
801048f9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048fc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104903:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104908:	39 c2                	cmp    %eax,%edx
8010490a:	75 0c                	jne    80104918 <exit+0x22>
    panic("init exiting");
8010490c:	c7 04 24 b8 8c 10 80 	movl   $0x80108cb8,(%esp)
80104913:	e8 bf bc ff ff       	call   801005d7 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104918:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010491f:	eb 44                	jmp    80104965 <exit+0x6f>
    if(proc->ofile[fd]){
80104921:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104927:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010492a:	83 c2 08             	add    $0x8,%edx
8010492d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104931:	85 c0                	test   %eax,%eax
80104933:	74 2c                	je     80104961 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104935:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010493e:	83 c2 08             	add    $0x8,%edx
80104941:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104945:	89 04 24             	mov    %eax,(%esp)
80104948:	e8 39 c7 ff ff       	call   80101086 <fileclose>
      proc->ofile[fd] = 0;
8010494d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104953:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104956:	83 c2 08             	add    $0x8,%edx
80104959:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104960:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104961:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104965:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104969:	7e b6                	jle    80104921 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010496b:	e8 41 ec ff ff       	call   801035b1 <begin_op>
  iput(proc->cwd);
80104970:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104976:	8b 40 68             	mov    0x68(%eax),%eax
80104979:	89 04 24             	mov    %eax,(%esp)
8010497c:	e8 a9 d1 ff ff       	call   80101b2a <iput>
  end_op();
80104981:	e8 af ec ff ff       	call   80103635 <end_op>
  proc->cwd = 0;
80104986:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104993:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
8010499a:	e8 1b 07 00 00       	call   801050ba <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010499f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a5:	8b 40 14             	mov    0x14(%eax),%eax
801049a8:	89 04 24             	mov    %eax,(%esp)
801049ab:	e8 db 04 00 00       	call   80104e8b <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b0:	c7 45 f4 74 43 11 80 	movl   $0x80114374,-0xc(%ebp)
801049b7:	eb 38                	jmp    801049f1 <exit+0xfb>
    if(p->parent == proc){
801049b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bc:	8b 50 14             	mov    0x14(%eax),%edx
801049bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c5:	39 c2                	cmp    %eax,%edx
801049c7:	75 24                	jne    801049ed <exit+0xf7>
      p->parent = initproc;
801049c9:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d8:	8b 40 0c             	mov    0xc(%eax),%eax
801049db:	83 f8 05             	cmp    $0x5,%eax
801049de:	75 0d                	jne    801049ed <exit+0xf7>
        wakeup1(initproc);
801049e0:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801049e5:	89 04 24             	mov    %eax,(%esp)
801049e8:	e8 9e 04 00 00       	call   80104e8b <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049ed:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049f1:	81 7d f4 74 63 11 80 	cmpl   $0x80116374,-0xc(%ebp)
801049f8:	72 bf                	jb     801049b9 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a00:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a07:	e8 c1 02 00 00       	call   80104ccd <sched>
  panic("zombie exit");
80104a0c:	c7 04 24 c5 8c 10 80 	movl   $0x80108cc5,(%esp)
80104a13:	e8 bf bb ff ff       	call   801005d7 <panic>

80104a18 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a18:	55                   	push   %ebp
80104a19:	89 e5                	mov    %esp,%ebp
80104a1b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a1e:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104a25:	e8 90 06 00 00       	call   801050ba <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a31:	c7 45 f4 74 43 11 80 	movl   $0x80114374,-0xc(%ebp)
80104a38:	e9 9a 00 00 00       	jmp    80104ad7 <wait+0xbf>
      if(p->parent != proc)
80104a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a40:	8b 50 14             	mov    0x14(%eax),%edx
80104a43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a49:	39 c2                	cmp    %eax,%edx
80104a4b:	74 05                	je     80104a52 <wait+0x3a>
        continue;
80104a4d:	e9 81 00 00 00       	jmp    80104ad3 <wait+0xbb>
      havekids = 1;
80104a52:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5f:	83 f8 05             	cmp    $0x5,%eax
80104a62:	75 6f                	jne    80104ad3 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a67:	8b 40 10             	mov    0x10(%eax),%eax
80104a6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 40 08             	mov    0x8(%eax),%eax
80104a73:	89 04 24             	mov    %eax,(%esp)
80104a76:	e8 21 e1 ff ff       	call   80102b9c <kfree>
        p->kstack = 0;
80104a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a88:	8b 40 04             	mov    0x4(%eax),%eax
80104a8b:	89 04 24             	mov    %eax,(%esp)
80104a8e:	e8 a9 3b 00 00       	call   8010863c <freevm>
        p->state = UNUSED;
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aaa:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab4:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104ac2:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104ac9:	e8 4e 06 00 00       	call   8010511c <release>
        return pid;
80104ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad1:	eb 52                	jmp    80104b25 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad3:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104ad7:	81 7d f4 74 63 11 80 	cmpl   $0x80116374,-0xc(%ebp)
80104ade:	0f 82 59 ff ff ff    	jb     80104a3d <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ae4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ae8:	74 0d                	je     80104af7 <wait+0xdf>
80104aea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af0:	8b 40 24             	mov    0x24(%eax),%eax
80104af3:	85 c0                	test   %eax,%eax
80104af5:	74 13                	je     80104b0a <wait+0xf2>
      release(&ptable.lock);
80104af7:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104afe:	e8 19 06 00 00       	call   8010511c <release>
      return -1;
80104b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b08:	eb 1b                	jmp    80104b25 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b10:	c7 44 24 04 40 43 11 	movl   $0x80114340,0x4(%esp)
80104b17:	80 
80104b18:	89 04 24             	mov    %eax,(%esp)
80104b1b:	e8 d0 02 00 00       	call   80104df0 <sleep>
  }
80104b20:	e9 05 ff ff ff       	jmp    80104a2a <wait+0x12>
}
80104b25:	c9                   	leave  
80104b26:	c3                   	ret    

80104b27 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b27:	55                   	push   %ebp
80104b28:	89 e5                	mov    %esp,%ebp
80104b2a:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  int foundproc = 1;
80104b2d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  
  long total_tickets = 0;
80104b34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  long winner_tickets = 0;
80104b3b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  long counter = 0;
80104b42:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  int not_first_time_run = -1;
80104b49:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  int got_a_winner = -1;
80104b50:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  int already_run = -1;
80104b57:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b5e:	e8 1f f9 ff ff       	call   80104482 <sti>

    if (!foundproc) hlt();
80104b63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b67:	75 05                	jne    80104b6e <scheduler+0x47>
80104b69:	e8 1a f9 ff ff       	call   80104488 <hlt>

    if (not_first_time_run == 1){
80104b6e:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
80104b72:	75 31                	jne    80104ba5 <scheduler+0x7e>
      foundproc = 0;
80104b74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      winner_tickets = random_at_most(total_tickets);
80104b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b7e:	89 04 24             	mov    %eax,(%esp)
80104b81:	e8 d3 2e 00 00       	call   80107a59 <random_at_most>
80104b86:	89 45 e8             	mov    %eax,-0x18(%ebp)
      total_tickets = 0;
80104b89:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      counter = 0;
80104b90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      got_a_winner = -1;
80104b97:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
      already_run = -1;
80104b9e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
    }

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ba5:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104bac:	e8 09 05 00 00       	call   801050ba <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb1:	c7 45 f4 74 43 11 80 	movl   $0x80114374,-0xc(%ebp)
80104bb8:	e9 eb 00 00 00       	jmp    80104ca8 <scheduler+0x181>
      if(p->state != RUNNABLE)
80104bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc3:	83 f8 03             	cmp    $0x3,%eax
80104bc6:	74 05                	je     80104bcd <scheduler+0xa6>
        continue;
80104bc8:	e9 d7 00 00 00       	jmp    80104ca4 <scheduler+0x17d>
      
      if((not_first_time_run == -1) && (p->state == RUNNABLE)){
80104bcd:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
80104bd1:	75 19                	jne    80104bec <scheduler+0xc5>
80104bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd6:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd9:	83 f8 03             	cmp    $0x3,%eax
80104bdc:	75 0e                	jne    80104bec <scheduler+0xc5>
        total_tickets = total_tickets + p->tickets;
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	8b 40 7c             	mov    0x7c(%eax),%eax
80104be4:	01 45 ec             	add    %eax,-0x14(%ebp)
        continue;
80104be7:	e9 b8 00 00 00       	jmp    80104ca4 <scheduler+0x17d>
      }
      
      counter = counter + p->tickets;
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	8b 40 7c             	mov    0x7c(%eax),%eax
80104bf2:	01 45 e4             	add    %eax,-0x1c(%ebp)
      
      if (counter < winner_tickets){
80104bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104bf8:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104bfb:	7d 0e                	jge    80104c0b <scheduler+0xe4>
        total_tickets = total_tickets + p->tickets;
80104bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c00:	8b 40 7c             	mov    0x7c(%eax),%eax
80104c03:	01 45 ec             	add    %eax,-0x14(%ebp)
        continue;
80104c06:	e9 99 00 00 00       	jmp    80104ca4 <scheduler+0x17d>
      }
      
      got_a_winner = 1;
80104c0b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)

      if ((got_a_winner == 1) && (already_run == 1)){
80104c12:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80104c16:	75 11                	jne    80104c29 <scheduler+0x102>
80104c18:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
80104c1c:	75 0b                	jne    80104c29 <scheduler+0x102>
        total_tickets = total_tickets + p->tickets;
80104c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c21:	8b 40 7c             	mov    0x7c(%eax),%eax
80104c24:	01 45 ec             	add    %eax,-0x14(%ebp)
        continue;
80104c27:	eb 7b                	jmp    80104ca4 <scheduler+0x17d>
      }
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      if ((got_a_winner == 1) && (already_run == -1)){
80104c29:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
80104c2d:	75 56                	jne    80104c85 <scheduler+0x15e>
80104c2f:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80104c33:	75 50                	jne    80104c85 <scheduler+0x15e>
        foundproc = 1;
80104c35:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        proc = p;
80104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3f:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
80104c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c48:	89 04 24             	mov    %eax,(%esp)
80104c4b:	e8 79 35 00 00       	call   801081c9 <switchuvm>
        p->state = RUNNING;
80104c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c53:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&cpu->scheduler, proc->context);
80104c5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c60:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c63:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c6a:	83 c2 04             	add    $0x4,%edx
80104c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c71:	89 14 24             	mov    %edx,(%esp)
80104c74:	e8 26 09 00 00       	call   8010559f <swtch>
        switchkvm();
80104c79:	e8 2e 35 00 00       	call   801081ac <switchkvm>
        already_run = 1;
80104c7e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
      }
      
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      if (p->state == RUNNABLE){
80104c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c88:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8b:	83 f8 03             	cmp    $0x3,%eax
80104c8e:	75 09                	jne    80104c99 <scheduler+0x172>
        total_tickets = total_tickets + p->tickets;
80104c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c93:	8b 40 7c             	mov    0x7c(%eax),%eax
80104c96:	01 45 ec             	add    %eax,-0x14(%ebp)
      }
      
      proc = 0;
80104c99:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ca0:	00 00 00 00 
      already_run = -1;
    }

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104ca8:	81 7d f4 74 63 11 80 	cmpl   $0x80116374,-0xc(%ebp)
80104caf:	0f 82 08 ff ff ff    	jb     80104bbd <scheduler+0x96>
        total_tickets = total_tickets + p->tickets;
      }
      
      proc = 0;
    }
    release(&ptable.lock);
80104cb5:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104cbc:	e8 5b 04 00 00       	call   8010511c <release>
    
    not_first_time_run = 1;
80104cc1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  }
80104cc8:	e9 91 fe ff ff       	jmp    80104b5e <scheduler+0x37>

80104ccd <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ccd:	55                   	push   %ebp
80104cce:	89 e5                	mov    %esp,%ebp
80104cd0:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104cd3:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104cda:	e8 05 05 00 00       	call   801051e4 <holding>
80104cdf:	85 c0                	test   %eax,%eax
80104ce1:	75 0c                	jne    80104cef <sched+0x22>
    panic("sched ptable.lock");
80104ce3:	c7 04 24 d1 8c 10 80 	movl   $0x80108cd1,(%esp)
80104cea:	e8 e8 b8 ff ff       	call   801005d7 <panic>
  if(cpu->ncli != 1)
80104cef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cf5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104cfb:	83 f8 01             	cmp    $0x1,%eax
80104cfe:	74 0c                	je     80104d0c <sched+0x3f>
    panic("sched locks");
80104d00:	c7 04 24 e3 8c 10 80 	movl   $0x80108ce3,(%esp)
80104d07:	e8 cb b8 ff ff       	call   801005d7 <panic>
  if(proc->state == RUNNING)
80104d0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d12:	8b 40 0c             	mov    0xc(%eax),%eax
80104d15:	83 f8 04             	cmp    $0x4,%eax
80104d18:	75 0c                	jne    80104d26 <sched+0x59>
    panic("sched running");
80104d1a:	c7 04 24 ef 8c 10 80 	movl   $0x80108cef,(%esp)
80104d21:	e8 b1 b8 ff ff       	call   801005d7 <panic>
  if(readeflags()&FL_IF)
80104d26:	e8 47 f7 ff ff       	call   80104472 <readeflags>
80104d2b:	25 00 02 00 00       	and    $0x200,%eax
80104d30:	85 c0                	test   %eax,%eax
80104d32:	74 0c                	je     80104d40 <sched+0x73>
    panic("sched interruptible");
80104d34:	c7 04 24 fd 8c 10 80 	movl   $0x80108cfd,(%esp)
80104d3b:	e8 97 b8 ff ff       	call   801005d7 <panic>
  intena = cpu->intena;
80104d40:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d46:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d55:	8b 40 04             	mov    0x4(%eax),%eax
80104d58:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d5f:	83 c2 1c             	add    $0x1c,%edx
80104d62:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d66:	89 14 24             	mov    %edx,(%esp)
80104d69:	e8 31 08 00 00       	call   8010559f <swtch>
  cpu->intena = intena;
80104d6e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d77:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d7d:	c9                   	leave  
80104d7e:	c3                   	ret    

80104d7f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d7f:	55                   	push   %ebp
80104d80:	89 e5                	mov    %esp,%ebp
80104d82:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d85:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104d8c:	e8 29 03 00 00       	call   801050ba <acquire>
  proc->state = RUNNABLE;
80104d91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d97:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d9e:	e8 2a ff ff ff       	call   80104ccd <sched>
  release(&ptable.lock);
80104da3:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104daa:	e8 6d 03 00 00       	call   8010511c <release>
}
80104daf:	c9                   	leave  
80104db0:	c3                   	ret    

80104db1 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104db1:	55                   	push   %ebp
80104db2:	89 e5                	mov    %esp,%ebp
80104db4:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104db7:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104dbe:	e8 59 03 00 00       	call   8010511c <release>

  if (first) {
80104dc3:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104dc8:	85 c0                	test   %eax,%eax
80104dca:	74 22                	je     80104dee <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104dcc:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104dd3:	00 00 00 
    iinit(ROOTDEV);
80104dd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ddd:	e8 67 c8 ff ff       	call   80101649 <iinit>
    initlog(ROOTDEV);
80104de2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104de9:	e8 bf e5 ff ff       	call   801033ad <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104dee:	c9                   	leave  
80104def:	c3                   	ret    

80104df0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
80104df3:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104df6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfc:	85 c0                	test   %eax,%eax
80104dfe:	75 0c                	jne    80104e0c <sleep+0x1c>
    panic("sleep");
80104e00:	c7 04 24 11 8d 10 80 	movl   $0x80108d11,(%esp)
80104e07:	e8 cb b7 ff ff       	call   801005d7 <panic>

  if(lk == 0)
80104e0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e10:	75 0c                	jne    80104e1e <sleep+0x2e>
    panic("sleep without lk");
80104e12:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
80104e19:	e8 b9 b7 ff ff       	call   801005d7 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e1e:	81 7d 0c 40 43 11 80 	cmpl   $0x80114340,0xc(%ebp)
80104e25:	74 17                	je     80104e3e <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e27:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104e2e:	e8 87 02 00 00       	call   801050ba <acquire>
    release(lk);
80104e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e36:	89 04 24             	mov    %eax,(%esp)
80104e39:	e8 de 02 00 00       	call   8010511c <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e44:	8b 55 08             	mov    0x8(%ebp),%edx
80104e47:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e50:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e57:	e8 71 fe ff ff       	call   80104ccd <sched>

  // Tidy up.
  proc->chan = 0;
80104e5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e62:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e69:	81 7d 0c 40 43 11 80 	cmpl   $0x80114340,0xc(%ebp)
80104e70:	74 17                	je     80104e89 <sleep+0x99>
    release(&ptable.lock);
80104e72:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104e79:	e8 9e 02 00 00       	call   8010511c <release>
    acquire(lk);
80104e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e81:	89 04 24             	mov    %eax,(%esp)
80104e84:	e8 31 02 00 00       	call   801050ba <acquire>
  }
}
80104e89:	c9                   	leave  
80104e8a:	c3                   	ret    

80104e8b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e8b:	55                   	push   %ebp
80104e8c:	89 e5                	mov    %esp,%ebp
80104e8e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e91:	c7 45 fc 74 43 11 80 	movl   $0x80114374,-0x4(%ebp)
80104e98:	eb 24                	jmp    80104ebe <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9d:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea0:	83 f8 02             	cmp    $0x2,%eax
80104ea3:	75 15                	jne    80104eba <wakeup1+0x2f>
80104ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea8:	8b 40 20             	mov    0x20(%eax),%eax
80104eab:	3b 45 08             	cmp    0x8(%ebp),%eax
80104eae:	75 0a                	jne    80104eba <wakeup1+0x2f>
      p->state = RUNNABLE;
80104eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104eba:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104ebe:	81 7d fc 74 63 11 80 	cmpl   $0x80116374,-0x4(%ebp)
80104ec5:	72 d3                	jb     80104e9a <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ec7:	c9                   	leave  
80104ec8:	c3                   	ret    

80104ec9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ec9:	55                   	push   %ebp
80104eca:	89 e5                	mov    %esp,%ebp
80104ecc:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ecf:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104ed6:	e8 df 01 00 00       	call   801050ba <acquire>
  wakeup1(chan);
80104edb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ede:	89 04 24             	mov    %eax,(%esp)
80104ee1:	e8 a5 ff ff ff       	call   80104e8b <wakeup1>
  release(&ptable.lock);
80104ee6:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104eed:	e8 2a 02 00 00       	call   8010511c <release>
}
80104ef2:	c9                   	leave  
80104ef3:	c3                   	ret    

80104ef4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104efa:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104f01:	e8 b4 01 00 00       	call   801050ba <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f06:	c7 45 f4 74 43 11 80 	movl   $0x80114374,-0xc(%ebp)
80104f0d:	eb 41                	jmp    80104f50 <kill+0x5c>
    if(p->pid == pid){
80104f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f12:	8b 40 10             	mov    0x10(%eax),%eax
80104f15:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f18:	75 32                	jne    80104f4c <kill+0x58>
      p->killed = 1;
80104f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f27:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2a:	83 f8 02             	cmp    $0x2,%eax
80104f2d:	75 0a                	jne    80104f39 <kill+0x45>
        p->state = RUNNABLE;
80104f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f32:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f39:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104f40:	e8 d7 01 00 00       	call   8010511c <release>
      return 0;
80104f45:	b8 00 00 00 00       	mov    $0x0,%eax
80104f4a:	eb 1e                	jmp    80104f6a <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f4c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104f50:	81 7d f4 74 63 11 80 	cmpl   $0x80116374,-0xc(%ebp)
80104f57:	72 b6                	jb     80104f0f <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f59:	c7 04 24 40 43 11 80 	movl   $0x80114340,(%esp)
80104f60:	e8 b7 01 00 00       	call   8010511c <release>
  return -1;
80104f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f6a:	c9                   	leave  
80104f6b:	c3                   	ret    

80104f6c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f6c:	55                   	push   %ebp
80104f6d:	89 e5                	mov    %esp,%ebp
80104f6f:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f72:	c7 45 f0 74 43 11 80 	movl   $0x80114374,-0x10(%ebp)
80104f79:	e9 d6 00 00 00       	jmp    80105054 <procdump+0xe8>
    if(p->state == UNUSED)
80104f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f81:	8b 40 0c             	mov    0xc(%eax),%eax
80104f84:	85 c0                	test   %eax,%eax
80104f86:	75 05                	jne    80104f8d <procdump+0x21>
      continue;
80104f88:	e9 c3 00 00 00       	jmp    80105050 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f90:	8b 40 0c             	mov    0xc(%eax),%eax
80104f93:	83 f8 05             	cmp    $0x5,%eax
80104f96:	77 23                	ja     80104fbb <procdump+0x4f>
80104f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f9e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104fa5:	85 c0                	test   %eax,%eax
80104fa7:	74 12                	je     80104fbb <procdump+0x4f>
      state = states[p->state];
80104fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fac:	8b 40 0c             	mov    0xc(%eax),%eax
80104faf:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fb9:	eb 07                	jmp    80104fc2 <procdump+0x56>
    else
      state = "???";
80104fbb:	c7 45 ec 28 8d 10 80 	movl   $0x80108d28,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc5:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcb:	8b 40 10             	mov    0x10(%eax),%eax
80104fce:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd5:	89 54 24 08          	mov    %edx,0x8(%esp)
80104fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fdd:	c7 04 24 2c 8d 10 80 	movl   $0x80108d2c,(%esp)
80104fe4:	e8 1a b4 ff ff       	call   80100403 <cprintf>
    if(p->state == SLEEPING){
80104fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fec:	8b 40 0c             	mov    0xc(%eax),%eax
80104fef:	83 f8 02             	cmp    $0x2,%eax
80104ff2:	75 50                	jne    80105044 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ffa:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffd:	83 c0 08             	add    $0x8,%eax
80105000:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105003:	89 54 24 04          	mov    %edx,0x4(%esp)
80105007:	89 04 24             	mov    %eax,(%esp)
8010500a:	e8 5c 01 00 00       	call   8010516b <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010500f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105016:	eb 1b                	jmp    80105033 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80105018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010501f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105023:	c7 04 24 35 8d 10 80 	movl   $0x80108d35,(%esp)
8010502a:	e8 d4 b3 ff ff       	call   80100403 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010502f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105033:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105037:	7f 0b                	jg     80105044 <procdump+0xd8>
80105039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105040:	85 c0                	test   %eax,%eax
80105042:	75 d4                	jne    80105018 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105044:	c7 04 24 39 8d 10 80 	movl   $0x80108d39,(%esp)
8010504b:	e8 b3 b3 ff ff       	call   80100403 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105050:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80105054:	81 7d f0 74 63 11 80 	cmpl   $0x80116374,-0x10(%ebp)
8010505b:	0f 82 1d ff ff ff    	jb     80104f7e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105061:	c9                   	leave  
80105062:	c3                   	ret    

80105063 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
80105066:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105069:	9c                   	pushf  
8010506a:	58                   	pop    %eax
8010506b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010506e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105071:	c9                   	leave  
80105072:	c3                   	ret    

80105073 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105073:	55                   	push   %ebp
80105074:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105076:	fa                   	cli    
}
80105077:	5d                   	pop    %ebp
80105078:	c3                   	ret    

80105079 <sti>:

static inline void
sti(void)
{
80105079:	55                   	push   %ebp
8010507a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010507c:	fb                   	sti    
}
8010507d:	5d                   	pop    %ebp
8010507e:	c3                   	ret    

8010507f <xchg>:
    return ret;
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010507f:	55                   	push   %ebp
80105080:	89 e5                	mov    %esp,%ebp
80105082:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105085:	8b 55 08             	mov    0x8(%ebp),%edx
80105088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010508e:	f0 87 02             	lock xchg %eax,(%edx)
80105091:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105094:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105097:	c9                   	leave  
80105098:	c3                   	ret    

80105099 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105099:	55                   	push   %ebp
8010509a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010509c:	8b 45 08             	mov    0x8(%ebp),%eax
8010509f:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a2:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050a5:	8b 45 08             	mov    0x8(%ebp),%eax
801050a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050b8:	5d                   	pop    %ebp
801050b9:	c3                   	ret    

801050ba <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050ba:	55                   	push   %ebp
801050bb:	89 e5                	mov    %esp,%ebp
801050bd:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050c0:	e8 49 01 00 00       	call   8010520e <pushcli>
  if(holding(lk))
801050c5:	8b 45 08             	mov    0x8(%ebp),%eax
801050c8:	89 04 24             	mov    %eax,(%esp)
801050cb:	e8 14 01 00 00       	call   801051e4 <holding>
801050d0:	85 c0                	test   %eax,%eax
801050d2:	74 0c                	je     801050e0 <acquire+0x26>
    panic("acquire");
801050d4:	c7 04 24 65 8d 10 80 	movl   $0x80108d65,(%esp)
801050db:	e8 f7 b4 ff ff       	call   801005d7 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050e0:	90                   	nop
801050e1:	8b 45 08             	mov    0x8(%ebp),%eax
801050e4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050eb:	00 
801050ec:	89 04 24             	mov    %eax,(%esp)
801050ef:	e8 8b ff ff ff       	call   8010507f <xchg>
801050f4:	85 c0                	test   %eax,%eax
801050f6:	75 e9                	jne    801050e1 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050f8:	8b 45 08             	mov    0x8(%ebp),%eax
801050fb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105102:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	83 c0 0c             	add    $0xc,%eax
8010510b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010510f:	8d 45 08             	lea    0x8(%ebp),%eax
80105112:	89 04 24             	mov    %eax,(%esp)
80105115:	e8 51 00 00 00       	call   8010516b <getcallerpcs>
}
8010511a:	c9                   	leave  
8010511b:	c3                   	ret    

8010511c <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010511c:	55                   	push   %ebp
8010511d:	89 e5                	mov    %esp,%ebp
8010511f:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105122:	8b 45 08             	mov    0x8(%ebp),%eax
80105125:	89 04 24             	mov    %eax,(%esp)
80105128:	e8 b7 00 00 00       	call   801051e4 <holding>
8010512d:	85 c0                	test   %eax,%eax
8010512f:	75 0c                	jne    8010513d <release+0x21>
    panic("release");
80105131:	c7 04 24 6d 8d 10 80 	movl   $0x80108d6d,(%esp)
80105138:	e8 9a b4 ff ff       	call   801005d7 <panic>

  lk->pcs[0] = 0;
8010513d:	8b 45 08             	mov    0x8(%ebp),%eax
80105140:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105147:	8b 45 08             	mov    0x8(%ebp),%eax
8010514a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105151:	8b 45 08             	mov    0x8(%ebp),%eax
80105154:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010515b:	00 
8010515c:	89 04 24             	mov    %eax,(%esp)
8010515f:	e8 1b ff ff ff       	call   8010507f <xchg>

  popcli();
80105164:	e8 e9 00 00 00       	call   80105252 <popcli>
}
80105169:	c9                   	leave  
8010516a:	c3                   	ret    

8010516b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
8010516e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105171:	8b 45 08             	mov    0x8(%ebp),%eax
80105174:	83 e8 08             	sub    $0x8,%eax
80105177:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010517a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105181:	eb 38                	jmp    801051bb <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105183:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105187:	74 38                	je     801051c1 <getcallerpcs+0x56>
80105189:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105190:	76 2f                	jbe    801051c1 <getcallerpcs+0x56>
80105192:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105196:	74 29                	je     801051c1 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105198:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010519b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a5:	01 c2                	add    %eax,%edx
801051a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051aa:	8b 40 04             	mov    0x4(%eax),%eax
801051ad:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b2:	8b 00                	mov    (%eax),%eax
801051b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051b7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051bb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051bf:	7e c2                	jle    80105183 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051c1:	eb 19                	jmp    801051dc <getcallerpcs+0x71>
    pcs[i] = 0;
801051c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801051d0:	01 d0                	add    %edx,%eax
801051d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051d8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051dc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051e0:	7e e1                	jle    801051c3 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801051e2:	c9                   	leave  
801051e3:	c3                   	ret    

801051e4 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051e4:	55                   	push   %ebp
801051e5:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051e7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ea:	8b 00                	mov    (%eax),%eax
801051ec:	85 c0                	test   %eax,%eax
801051ee:	74 17                	je     80105207 <holding+0x23>
801051f0:	8b 45 08             	mov    0x8(%ebp),%eax
801051f3:	8b 50 08             	mov    0x8(%eax),%edx
801051f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051fc:	39 c2                	cmp    %eax,%edx
801051fe:	75 07                	jne    80105207 <holding+0x23>
80105200:	b8 01 00 00 00       	mov    $0x1,%eax
80105205:	eb 05                	jmp    8010520c <holding+0x28>
80105207:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010520c:	5d                   	pop    %ebp
8010520d:	c3                   	ret    

8010520e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010520e:	55                   	push   %ebp
8010520f:	89 e5                	mov    %esp,%ebp
80105211:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105214:	e8 4a fe ff ff       	call   80105063 <readeflags>
80105219:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010521c:	e8 52 fe ff ff       	call   80105073 <cli>
  if(cpu->ncli++ == 0)
80105221:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105228:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010522e:	8d 48 01             	lea    0x1(%eax),%ecx
80105231:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105237:	85 c0                	test   %eax,%eax
80105239:	75 15                	jne    80105250 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010523b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105241:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105244:	81 e2 00 02 00 00    	and    $0x200,%edx
8010524a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105250:	c9                   	leave  
80105251:	c3                   	ret    

80105252 <popcli>:

void
popcli(void)
{
80105252:	55                   	push   %ebp
80105253:	89 e5                	mov    %esp,%ebp
80105255:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105258:	e8 06 fe ff ff       	call   80105063 <readeflags>
8010525d:	25 00 02 00 00       	and    $0x200,%eax
80105262:	85 c0                	test   %eax,%eax
80105264:	74 0c                	je     80105272 <popcli+0x20>
    panic("popcli - interruptible");
80105266:	c7 04 24 75 8d 10 80 	movl   $0x80108d75,(%esp)
8010526d:	e8 65 b3 ff ff       	call   801005d7 <panic>
  if(--cpu->ncli < 0)
80105272:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105278:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010527e:	83 ea 01             	sub    $0x1,%edx
80105281:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105287:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010528d:	85 c0                	test   %eax,%eax
8010528f:	79 0c                	jns    8010529d <popcli+0x4b>
    panic("popcli");
80105291:	c7 04 24 8c 8d 10 80 	movl   $0x80108d8c,(%esp)
80105298:	e8 3a b3 ff ff       	call   801005d7 <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010529d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052a9:	85 c0                	test   %eax,%eax
801052ab:	75 15                	jne    801052c2 <popcli+0x70>
801052ad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052b3:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052b9:	85 c0                	test   %eax,%eax
801052bb:	74 05                	je     801052c2 <popcli+0x70>
    sti();
801052bd:	e8 b7 fd ff ff       	call   80105079 <sti>
}
801052c2:	c9                   	leave  
801052c3:	c3                   	ret    

801052c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052c4:	55                   	push   %ebp
801052c5:	89 e5                	mov    %esp,%ebp
801052c7:	57                   	push   %edi
801052c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052cc:	8b 55 10             	mov    0x10(%ebp),%edx
801052cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d2:	89 cb                	mov    %ecx,%ebx
801052d4:	89 df                	mov    %ebx,%edi
801052d6:	89 d1                	mov    %edx,%ecx
801052d8:	fc                   	cld    
801052d9:	f3 aa                	rep stos %al,%es:(%edi)
801052db:	89 ca                	mov    %ecx,%edx
801052dd:	89 fb                	mov    %edi,%ebx
801052df:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052e5:	5b                   	pop    %ebx
801052e6:	5f                   	pop    %edi
801052e7:	5d                   	pop    %ebp
801052e8:	c3                   	ret    

801052e9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052e9:	55                   	push   %ebp
801052ea:	89 e5                	mov    %esp,%ebp
801052ec:	57                   	push   %edi
801052ed:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052f1:	8b 55 10             	mov    0x10(%ebp),%edx
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	89 cb                	mov    %ecx,%ebx
801052f9:	89 df                	mov    %ebx,%edi
801052fb:	89 d1                	mov    %edx,%ecx
801052fd:	fc                   	cld    
801052fe:	f3 ab                	rep stos %eax,%es:(%edi)
80105300:	89 ca                	mov    %ecx,%edx
80105302:	89 fb                	mov    %edi,%ebx
80105304:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105307:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010530a:	5b                   	pop    %ebx
8010530b:	5f                   	pop    %edi
8010530c:	5d                   	pop    %ebp
8010530d:	c3                   	ret    

8010530e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010530e:	55                   	push   %ebp
8010530f:	89 e5                	mov    %esp,%ebp
80105311:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105314:	8b 45 08             	mov    0x8(%ebp),%eax
80105317:	83 e0 03             	and    $0x3,%eax
8010531a:	85 c0                	test   %eax,%eax
8010531c:	75 49                	jne    80105367 <memset+0x59>
8010531e:	8b 45 10             	mov    0x10(%ebp),%eax
80105321:	83 e0 03             	and    $0x3,%eax
80105324:	85 c0                	test   %eax,%eax
80105326:	75 3f                	jne    80105367 <memset+0x59>
    c &= 0xFF;
80105328:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010532f:	8b 45 10             	mov    0x10(%ebp),%eax
80105332:	c1 e8 02             	shr    $0x2,%eax
80105335:	89 c2                	mov    %eax,%edx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	c1 e0 18             	shl    $0x18,%eax
8010533d:	89 c1                	mov    %eax,%ecx
8010533f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105342:	c1 e0 10             	shl    $0x10,%eax
80105345:	09 c1                	or     %eax,%ecx
80105347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534a:	c1 e0 08             	shl    $0x8,%eax
8010534d:	09 c8                	or     %ecx,%eax
8010534f:	0b 45 0c             	or     0xc(%ebp),%eax
80105352:	89 54 24 08          	mov    %edx,0x8(%esp)
80105356:	89 44 24 04          	mov    %eax,0x4(%esp)
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	89 04 24             	mov    %eax,(%esp)
80105360:	e8 84 ff ff ff       	call   801052e9 <stosl>
80105365:	eb 19                	jmp    80105380 <memset+0x72>
  } else
    stosb(dst, c, n);
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010536e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105371:	89 44 24 04          	mov    %eax,0x4(%esp)
80105375:	8b 45 08             	mov    0x8(%ebp),%eax
80105378:	89 04 24             	mov    %eax,(%esp)
8010537b:	e8 44 ff ff ff       	call   801052c4 <stosb>
  return dst;
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105383:	c9                   	leave  
80105384:	c3                   	ret    

80105385 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
80105388:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010538b:	8b 45 08             	mov    0x8(%ebp),%eax
8010538e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105391:	8b 45 0c             	mov    0xc(%ebp),%eax
80105394:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105397:	eb 30                	jmp    801053c9 <memcmp+0x44>
    if(*s1 != *s2)
80105399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539c:	0f b6 10             	movzbl (%eax),%edx
8010539f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a2:	0f b6 00             	movzbl (%eax),%eax
801053a5:	38 c2                	cmp    %al,%dl
801053a7:	74 18                	je     801053c1 <memcmp+0x3c>
      return *s1 - *s2;
801053a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ac:	0f b6 00             	movzbl (%eax),%eax
801053af:	0f b6 d0             	movzbl %al,%edx
801053b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b5:	0f b6 00             	movzbl (%eax),%eax
801053b8:	0f b6 c0             	movzbl %al,%eax
801053bb:	29 c2                	sub    %eax,%edx
801053bd:	89 d0                	mov    %edx,%eax
801053bf:	eb 1a                	jmp    801053db <memcmp+0x56>
    s1++, s2++;
801053c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053c5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053c9:	8b 45 10             	mov    0x10(%ebp),%eax
801053cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801053cf:	89 55 10             	mov    %edx,0x10(%ebp)
801053d2:	85 c0                	test   %eax,%eax
801053d4:	75 c3                	jne    80105399 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053db:	c9                   	leave  
801053dc:	c3                   	ret    

801053dd <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053dd:	55                   	push   %ebp
801053de:	89 e5                	mov    %esp,%ebp
801053e0:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f5:	73 3d                	jae    80105434 <memmove+0x57>
801053f7:	8b 45 10             	mov    0x10(%ebp),%eax
801053fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fd:	01 d0                	add    %edx,%eax
801053ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105402:	76 30                	jbe    80105434 <memmove+0x57>
    s += n;
80105404:	8b 45 10             	mov    0x10(%ebp),%eax
80105407:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010540a:	8b 45 10             	mov    0x10(%ebp),%eax
8010540d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105410:	eb 13                	jmp    80105425 <memmove+0x48>
      *--d = *--s;
80105412:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105416:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010541a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010541d:	0f b6 10             	movzbl (%eax),%edx
80105420:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105423:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105425:	8b 45 10             	mov    0x10(%ebp),%eax
80105428:	8d 50 ff             	lea    -0x1(%eax),%edx
8010542b:	89 55 10             	mov    %edx,0x10(%ebp)
8010542e:	85 c0                	test   %eax,%eax
80105430:	75 e0                	jne    80105412 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105432:	eb 26                	jmp    8010545a <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105434:	eb 17                	jmp    8010544d <memmove+0x70>
      *d++ = *s++;
80105436:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105439:	8d 50 01             	lea    0x1(%eax),%edx
8010543c:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010543f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105442:	8d 4a 01             	lea    0x1(%edx),%ecx
80105445:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105448:	0f b6 12             	movzbl (%edx),%edx
8010544b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010544d:	8b 45 10             	mov    0x10(%ebp),%eax
80105450:	8d 50 ff             	lea    -0x1(%eax),%edx
80105453:	89 55 10             	mov    %edx,0x10(%ebp)
80105456:	85 c0                	test   %eax,%eax
80105458:	75 dc                	jne    80105436 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010545d:	c9                   	leave  
8010545e:	c3                   	ret    

8010545f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010545f:	55                   	push   %ebp
80105460:	89 e5                	mov    %esp,%ebp
80105462:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105465:	8b 45 10             	mov    0x10(%ebp),%eax
80105468:	89 44 24 08          	mov    %eax,0x8(%esp)
8010546c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105473:	8b 45 08             	mov    0x8(%ebp),%eax
80105476:	89 04 24             	mov    %eax,(%esp)
80105479:	e8 5f ff ff ff       	call   801053dd <memmove>
}
8010547e:	c9                   	leave  
8010547f:	c3                   	ret    

80105480 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105483:	eb 0c                	jmp    80105491 <strncmp+0x11>
    n--, p++, q++;
80105485:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105489:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010548d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105491:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105495:	74 1a                	je     801054b1 <strncmp+0x31>
80105497:	8b 45 08             	mov    0x8(%ebp),%eax
8010549a:	0f b6 00             	movzbl (%eax),%eax
8010549d:	84 c0                	test   %al,%al
8010549f:	74 10                	je     801054b1 <strncmp+0x31>
801054a1:	8b 45 08             	mov    0x8(%ebp),%eax
801054a4:	0f b6 10             	movzbl (%eax),%edx
801054a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054aa:	0f b6 00             	movzbl (%eax),%eax
801054ad:	38 c2                	cmp    %al,%dl
801054af:	74 d4                	je     80105485 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b5:	75 07                	jne    801054be <strncmp+0x3e>
    return 0;
801054b7:	b8 00 00 00 00       	mov    $0x0,%eax
801054bc:	eb 16                	jmp    801054d4 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054be:	8b 45 08             	mov    0x8(%ebp),%eax
801054c1:	0f b6 00             	movzbl (%eax),%eax
801054c4:	0f b6 d0             	movzbl %al,%edx
801054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ca:	0f b6 00             	movzbl (%eax),%eax
801054cd:	0f b6 c0             	movzbl %al,%eax
801054d0:	29 c2                	sub    %eax,%edx
801054d2:	89 d0                	mov    %edx,%eax
}
801054d4:	5d                   	pop    %ebp
801054d5:	c3                   	ret    

801054d6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054d6:	55                   	push   %ebp
801054d7:	89 e5                	mov    %esp,%ebp
801054d9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054e2:	90                   	nop
801054e3:	8b 45 10             	mov    0x10(%ebp),%eax
801054e6:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e9:	89 55 10             	mov    %edx,0x10(%ebp)
801054ec:	85 c0                	test   %eax,%eax
801054ee:	7e 1e                	jle    8010550e <strncpy+0x38>
801054f0:	8b 45 08             	mov    0x8(%ebp),%eax
801054f3:	8d 50 01             	lea    0x1(%eax),%edx
801054f6:	89 55 08             	mov    %edx,0x8(%ebp)
801054f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801054fc:	8d 4a 01             	lea    0x1(%edx),%ecx
801054ff:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105502:	0f b6 12             	movzbl (%edx),%edx
80105505:	88 10                	mov    %dl,(%eax)
80105507:	0f b6 00             	movzbl (%eax),%eax
8010550a:	84 c0                	test   %al,%al
8010550c:	75 d5                	jne    801054e3 <strncpy+0xd>
    ;
  while(n-- > 0)
8010550e:	eb 0c                	jmp    8010551c <strncpy+0x46>
    *s++ = 0;
80105510:	8b 45 08             	mov    0x8(%ebp),%eax
80105513:	8d 50 01             	lea    0x1(%eax),%edx
80105516:	89 55 08             	mov    %edx,0x8(%ebp)
80105519:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010551c:	8b 45 10             	mov    0x10(%ebp),%eax
8010551f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105522:	89 55 10             	mov    %edx,0x10(%ebp)
80105525:	85 c0                	test   %eax,%eax
80105527:	7f e7                	jg     80105510 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105529:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010552e:	55                   	push   %ebp
8010552f:	89 e5                	mov    %esp,%ebp
80105531:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010553a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010553e:	7f 05                	jg     80105545 <safestrcpy+0x17>
    return os;
80105540:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105543:	eb 31                	jmp    80105576 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105545:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105549:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554d:	7e 1e                	jle    8010556d <safestrcpy+0x3f>
8010554f:	8b 45 08             	mov    0x8(%ebp),%eax
80105552:	8d 50 01             	lea    0x1(%eax),%edx
80105555:	89 55 08             	mov    %edx,0x8(%ebp)
80105558:	8b 55 0c             	mov    0xc(%ebp),%edx
8010555b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010555e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105561:	0f b6 12             	movzbl (%edx),%edx
80105564:	88 10                	mov    %dl,(%eax)
80105566:	0f b6 00             	movzbl (%eax),%eax
80105569:	84 c0                	test   %al,%al
8010556b:	75 d8                	jne    80105545 <safestrcpy+0x17>
    ;
  *s = 0;
8010556d:	8b 45 08             	mov    0x8(%ebp),%eax
80105570:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105573:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105576:	c9                   	leave  
80105577:	c3                   	ret    

80105578 <strlen>:

int
strlen(const char *s)
{
80105578:	55                   	push   %ebp
80105579:	89 e5                	mov    %esp,%ebp
8010557b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010557e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105585:	eb 04                	jmp    8010558b <strlen+0x13>
80105587:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010558b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010558e:	8b 45 08             	mov    0x8(%ebp),%eax
80105591:	01 d0                	add    %edx,%eax
80105593:	0f b6 00             	movzbl (%eax),%eax
80105596:	84 c0                	test   %al,%al
80105598:	75 ed                	jne    80105587 <strlen+0xf>
    ;
  return n;
8010559a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010559d:	c9                   	leave  
8010559e:	c3                   	ret    

8010559f <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010559f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055a3:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055a7:	55                   	push   %ebp
  pushl %ebx
801055a8:	53                   	push   %ebx
  pushl %esi
801055a9:	56                   	push   %esi
  pushl %edi
801055aa:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055ab:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055ad:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055af:	5f                   	pop    %edi
  popl %esi
801055b0:	5e                   	pop    %esi
  popl %ebx
801055b1:	5b                   	pop    %ebx
  popl %ebp
801055b2:	5d                   	pop    %ebp
  ret
801055b3:	c3                   	ret    

801055b4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055b4:	55                   	push   %ebp
801055b5:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bd:	8b 00                	mov    (%eax),%eax
801055bf:	3b 45 08             	cmp    0x8(%ebp),%eax
801055c2:	76 12                	jbe    801055d6 <fetchint+0x22>
801055c4:	8b 45 08             	mov    0x8(%ebp),%eax
801055c7:	8d 50 04             	lea    0x4(%eax),%edx
801055ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d0:	8b 00                	mov    (%eax),%eax
801055d2:	39 c2                	cmp    %eax,%edx
801055d4:	76 07                	jbe    801055dd <fetchint+0x29>
    return -1;
801055d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055db:	eb 0f                	jmp    801055ec <fetchint+0x38>
  *ip = *(int*)(addr);
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	8b 10                	mov    (%eax),%edx
801055e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e5:	89 10                	mov    %edx,(%eax)
  return 0;
801055e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ec:	5d                   	pop    %ebp
801055ed:	c3                   	ret    

801055ee <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055ee:	55                   	push   %ebp
801055ef:	89 e5                	mov    %esp,%ebp
801055f1:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055fa:	8b 00                	mov    (%eax),%eax
801055fc:	3b 45 08             	cmp    0x8(%ebp),%eax
801055ff:	77 07                	ja     80105608 <fetchstr+0x1a>
    return -1;
80105601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105606:	eb 46                	jmp    8010564e <fetchstr+0x60>
  *pp = (char*)addr;
80105608:	8b 55 08             	mov    0x8(%ebp),%edx
8010560b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105610:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105616:	8b 00                	mov    (%eax),%eax
80105618:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010561b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561e:	8b 00                	mov    (%eax),%eax
80105620:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105623:	eb 1c                	jmp    80105641 <fetchstr+0x53>
    if(*s == 0)
80105625:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105628:	0f b6 00             	movzbl (%eax),%eax
8010562b:	84 c0                	test   %al,%al
8010562d:	75 0e                	jne    8010563d <fetchstr+0x4f>
      return s - *pp;
8010562f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105632:	8b 45 0c             	mov    0xc(%ebp),%eax
80105635:	8b 00                	mov    (%eax),%eax
80105637:	29 c2                	sub    %eax,%edx
80105639:	89 d0                	mov    %edx,%eax
8010563b:	eb 11                	jmp    8010564e <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010563d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105641:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105644:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105647:	72 dc                	jb     80105625 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105649:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010564e:	c9                   	leave  
8010564f:	c3                   	ret    

80105650 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105650:	55                   	push   %ebp
80105651:	89 e5                	mov    %esp,%ebp
80105653:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105656:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565c:	8b 40 18             	mov    0x18(%eax),%eax
8010565f:	8b 50 44             	mov    0x44(%eax),%edx
80105662:	8b 45 08             	mov    0x8(%ebp),%eax
80105665:	c1 e0 02             	shl    $0x2,%eax
80105668:	01 d0                	add    %edx,%eax
8010566a:	8d 50 04             	lea    0x4(%eax),%edx
8010566d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105670:	89 44 24 04          	mov    %eax,0x4(%esp)
80105674:	89 14 24             	mov    %edx,(%esp)
80105677:	e8 38 ff ff ff       	call   801055b4 <fetchint>
}
8010567c:	c9                   	leave  
8010567d:	c3                   	ret    

8010567e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010567e:	55                   	push   %ebp
8010567f:	89 e5                	mov    %esp,%ebp
80105681:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105684:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105687:	89 44 24 04          	mov    %eax,0x4(%esp)
8010568b:	8b 45 08             	mov    0x8(%ebp),%eax
8010568e:	89 04 24             	mov    %eax,(%esp)
80105691:	e8 ba ff ff ff       	call   80105650 <argint>
80105696:	85 c0                	test   %eax,%eax
80105698:	79 07                	jns    801056a1 <argptr+0x23>
    return -1;
8010569a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569f:	eb 3d                	jmp    801056de <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a4:	89 c2                	mov    %eax,%edx
801056a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ac:	8b 00                	mov    (%eax),%eax
801056ae:	39 c2                	cmp    %eax,%edx
801056b0:	73 16                	jae    801056c8 <argptr+0x4a>
801056b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056b5:	89 c2                	mov    %eax,%edx
801056b7:	8b 45 10             	mov    0x10(%ebp),%eax
801056ba:	01 c2                	add    %eax,%edx
801056bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c2:	8b 00                	mov    (%eax),%eax
801056c4:	39 c2                	cmp    %eax,%edx
801056c6:	76 07                	jbe    801056cf <argptr+0x51>
    return -1;
801056c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cd:	eb 0f                	jmp    801056de <argptr+0x60>
  *pp = (char*)i;
801056cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d2:	89 c2                	mov    %eax,%edx
801056d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d7:	89 10                	mov    %edx,(%eax)
  return 0;
801056d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056de:	c9                   	leave  
801056df:	c3                   	ret    

801056e0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056e0:	55                   	push   %ebp
801056e1:	89 e5                	mov    %esp,%ebp
801056e3:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ed:	8b 45 08             	mov    0x8(%ebp),%eax
801056f0:	89 04 24             	mov    %eax,(%esp)
801056f3:	e8 58 ff ff ff       	call   80105650 <argint>
801056f8:	85 c0                	test   %eax,%eax
801056fa:	79 07                	jns    80105703 <argstr+0x23>
    return -1;
801056fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105701:	eb 12                	jmp    80105715 <argstr+0x35>
  return fetchstr(addr, pp);
80105703:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105706:	8b 55 0c             	mov    0xc(%ebp),%edx
80105709:	89 54 24 04          	mov    %edx,0x4(%esp)
8010570d:	89 04 24             	mov    %eax,(%esp)
80105710:	e8 d9 fe ff ff       	call   801055ee <fetchstr>
}
80105715:	c9                   	leave  
80105716:	c3                   	ret    

80105717 <syscall>:
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
80105717:	55                   	push   %ebp
80105718:	89 e5                	mov    %esp,%ebp
8010571a:	53                   	push   %ebx
8010571b:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010571e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105724:	8b 40 18             	mov    0x18(%eax),%eax
80105727:	8b 40 1c             	mov    0x1c(%eax),%eax
8010572a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010572d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105731:	7e 30                	jle    80105763 <syscall+0x4c>
80105733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105736:	83 f8 17             	cmp    $0x17,%eax
80105739:	77 28                	ja     80105763 <syscall+0x4c>
8010573b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573e:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105745:	85 c0                	test   %eax,%eax
80105747:	74 1a                	je     80105763 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105749:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574f:	8b 58 18             	mov    0x18(%eax),%ebx
80105752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105755:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010575c:	ff d0                	call   *%eax
8010575e:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105761:	eb 3d                	jmp    801057a0 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105769:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010576c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105772:	8b 40 10             	mov    0x10(%eax),%eax
80105775:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105778:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010577c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105780:	89 44 24 04          	mov    %eax,0x4(%esp)
80105784:	c7 04 24 93 8d 10 80 	movl   $0x80108d93,(%esp)
8010578b:	e8 73 ac ff ff       	call   80100403 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105790:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105796:	8b 40 18             	mov    0x18(%eax),%eax
80105799:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057a0:	83 c4 24             	add    $0x24,%esp
801057a3:	5b                   	pop    %ebx
801057a4:	5d                   	pop    %ebp
801057a5:	c3                   	ret    

801057a6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057a6:	55                   	push   %ebp
801057a7:	89 e5                	mov    %esp,%ebp
801057a9:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057af:	89 44 24 04          	mov    %eax,0x4(%esp)
801057b3:	8b 45 08             	mov    0x8(%ebp),%eax
801057b6:	89 04 24             	mov    %eax,(%esp)
801057b9:	e8 92 fe ff ff       	call   80105650 <argint>
801057be:	85 c0                	test   %eax,%eax
801057c0:	79 07                	jns    801057c9 <argfd+0x23>
    return -1;
801057c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c7:	eb 50                	jmp    80105819 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801057c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057cc:	85 c0                	test   %eax,%eax
801057ce:	78 21                	js     801057f1 <argfd+0x4b>
801057d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d3:	83 f8 0f             	cmp    $0xf,%eax
801057d6:	7f 19                	jg     801057f1 <argfd+0x4b>
801057d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057e1:	83 c2 08             	add    $0x8,%edx
801057e4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057ef:	75 07                	jne    801057f8 <argfd+0x52>
    return -1;
801057f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f6:	eb 21                	jmp    80105819 <argfd+0x73>
  if(pfd)
801057f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057fc:	74 08                	je     80105806 <argfd+0x60>
    *pfd = fd;
801057fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105801:	8b 45 0c             	mov    0xc(%ebp),%eax
80105804:	89 10                	mov    %edx,(%eax)
  if(pf)
80105806:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010580a:	74 08                	je     80105814 <argfd+0x6e>
    *pf = f;
8010580c:	8b 45 10             	mov    0x10(%ebp),%eax
8010580f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105812:	89 10                	mov    %edx,(%eax)
  return 0;
80105814:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105819:	c9                   	leave  
8010581a:	c3                   	ret    

8010581b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010581b:	55                   	push   %ebp
8010581c:	89 e5                	mov    %esp,%ebp
8010581e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105821:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105828:	eb 30                	jmp    8010585a <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010582a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105830:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105833:	83 c2 08             	add    $0x8,%edx
80105836:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010583a:	85 c0                	test   %eax,%eax
8010583c:	75 18                	jne    80105856 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010583e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105844:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105847:	8d 4a 08             	lea    0x8(%edx),%ecx
8010584a:	8b 55 08             	mov    0x8(%ebp),%edx
8010584d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105851:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105854:	eb 0f                	jmp    80105865 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105856:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010585a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010585e:	7e ca                	jle    8010582a <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105865:	c9                   	leave  
80105866:	c3                   	ret    

80105867 <sys_dup>:

int
sys_dup(void)
{
80105867:	55                   	push   %ebp
80105868:	89 e5                	mov    %esp,%ebp
8010586a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010586d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105870:	89 44 24 08          	mov    %eax,0x8(%esp)
80105874:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010587b:	00 
8010587c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105883:	e8 1e ff ff ff       	call   801057a6 <argfd>
80105888:	85 c0                	test   %eax,%eax
8010588a:	79 07                	jns    80105893 <sys_dup+0x2c>
    return -1;
8010588c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105891:	eb 29                	jmp    801058bc <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105896:	89 04 24             	mov    %eax,(%esp)
80105899:	e8 7d ff ff ff       	call   8010581b <fdalloc>
8010589e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a5:	79 07                	jns    801058ae <sys_dup+0x47>
    return -1;
801058a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ac:	eb 0e                	jmp    801058bc <sys_dup+0x55>
  filedup(f);
801058ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b1:	89 04 24             	mov    %eax,(%esp)
801058b4:	e8 85 b7 ff ff       	call   8010103e <filedup>
  return fd;
801058b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058bc:	c9                   	leave  
801058bd:	c3                   	ret    

801058be <sys_read>:

int
sys_read(void)
{
801058be:	55                   	push   %ebp
801058bf:	89 e5                	mov    %esp,%ebp
801058c1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801058cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058d2:	00 
801058d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058da:	e8 c7 fe ff ff       	call   801057a6 <argfd>
801058df:	85 c0                	test   %eax,%eax
801058e1:	78 35                	js     80105918 <sys_read+0x5a>
801058e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058f1:	e8 5a fd ff ff       	call   80105650 <argint>
801058f6:	85 c0                	test   %eax,%eax
801058f8:	78 1e                	js     80105918 <sys_read+0x5a>
801058fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105901:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105904:	89 44 24 04          	mov    %eax,0x4(%esp)
80105908:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010590f:	e8 6a fd ff ff       	call   8010567e <argptr>
80105914:	85 c0                	test   %eax,%eax
80105916:	79 07                	jns    8010591f <sys_read+0x61>
    return -1;
80105918:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591d:	eb 19                	jmp    80105938 <sys_read+0x7a>
  return fileread(f, p, n);
8010591f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105922:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010592c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105930:	89 04 24             	mov    %eax,(%esp)
80105933:	e8 73 b8 ff ff       	call   801011ab <fileread>
}
80105938:	c9                   	leave  
80105939:	c3                   	ret    

8010593a <sys_write>:

int
sys_write(void)
{
8010593a:	55                   	push   %ebp
8010593b:	89 e5                	mov    %esp,%ebp
8010593d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105940:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105943:	89 44 24 08          	mov    %eax,0x8(%esp)
80105947:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010594e:	00 
8010594f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105956:	e8 4b fe ff ff       	call   801057a6 <argfd>
8010595b:	85 c0                	test   %eax,%eax
8010595d:	78 35                	js     80105994 <sys_write+0x5a>
8010595f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105962:	89 44 24 04          	mov    %eax,0x4(%esp)
80105966:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010596d:	e8 de fc ff ff       	call   80105650 <argint>
80105972:	85 c0                	test   %eax,%eax
80105974:	78 1e                	js     80105994 <sys_write+0x5a>
80105976:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105979:	89 44 24 08          	mov    %eax,0x8(%esp)
8010597d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105980:	89 44 24 04          	mov    %eax,0x4(%esp)
80105984:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010598b:	e8 ee fc ff ff       	call   8010567e <argptr>
80105990:	85 c0                	test   %eax,%eax
80105992:	79 07                	jns    8010599b <sys_write+0x61>
    return -1;
80105994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105999:	eb 19                	jmp    801059b4 <sys_write+0x7a>
  return filewrite(f, p, n);
8010599b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010599e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801059ac:	89 04 24             	mov    %eax,(%esp)
801059af:	e8 b3 b8 ff ff       	call   80101267 <filewrite>
}
801059b4:	c9                   	leave  
801059b5:	c3                   	ret    

801059b6 <sys_close>:

int
sys_close(void)
{
801059b6:	55                   	push   %ebp
801059b7:	89 e5                	mov    %esp,%ebp
801059b9:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801059bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059d1:	e8 d0 fd ff ff       	call   801057a6 <argfd>
801059d6:	85 c0                	test   %eax,%eax
801059d8:	79 07                	jns    801059e1 <sys_close+0x2b>
    return -1;
801059da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059df:	eb 24                	jmp    80105a05 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801059e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059ea:	83 c2 08             	add    $0x8,%edx
801059ed:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059f4:	00 
  fileclose(f);
801059f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f8:	89 04 24             	mov    %eax,(%esp)
801059fb:	e8 86 b6 ff ff       	call   80101086 <fileclose>
  return 0;
80105a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a05:	c9                   	leave  
80105a06:	c3                   	ret    

80105a07 <sys_fstat>:

int
sys_fstat(void)
{
80105a07:	55                   	push   %ebp
80105a08:	89 e5                	mov    %esp,%ebp
80105a0a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a10:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a1b:	00 
80105a1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a23:	e8 7e fd ff ff       	call   801057a6 <argfd>
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	78 1f                	js     80105a4b <sys_fstat+0x44>
80105a2c:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a33:	00 
80105a34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a37:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a42:	e8 37 fc ff ff       	call   8010567e <argptr>
80105a47:	85 c0                	test   %eax,%eax
80105a49:	79 07                	jns    80105a52 <sys_fstat+0x4b>
    return -1;
80105a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a50:	eb 12                	jmp    80105a64 <sys_fstat+0x5d>
  return filestat(f, st);
80105a52:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a58:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a5c:	89 04 24             	mov    %eax,(%esp)
80105a5f:	e8 f8 b6 ff ff       	call   8010115c <filestat>
}
80105a64:	c9                   	leave  
80105a65:	c3                   	ret    

80105a66 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a66:	55                   	push   %ebp
80105a67:	89 e5                	mov    %esp,%ebp
80105a69:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a6c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a7a:	e8 61 fc ff ff       	call   801056e0 <argstr>
80105a7f:	85 c0                	test   %eax,%eax
80105a81:	78 17                	js     80105a9a <sys_link+0x34>
80105a83:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a91:	e8 4a fc ff ff       	call   801056e0 <argstr>
80105a96:	85 c0                	test   %eax,%eax
80105a98:	79 0a                	jns    80105aa4 <sys_link+0x3e>
    return -1;
80105a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9f:	e9 42 01 00 00       	jmp    80105be6 <sys_link+0x180>

  begin_op();
80105aa4:	e8 08 db ff ff       	call   801035b1 <begin_op>
  if((ip = namei(old)) == 0){
80105aa9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105aac:	89 04 24             	mov    %eax,(%esp)
80105aaf:	e8 6e ca ff ff       	call   80102522 <namei>
80105ab4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ab7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105abb:	75 0f                	jne    80105acc <sys_link+0x66>
    end_op();
80105abd:	e8 73 db ff ff       	call   80103635 <end_op>
    return -1;
80105ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac7:	e9 1a 01 00 00       	jmp    80105be6 <sys_link+0x180>
  }

  ilock(ip);
80105acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acf:	89 04 24             	mov    %eax,(%esp)
80105ad2:	e8 9a be ff ff       	call   80101971 <ilock>
  if(ip->type == T_DIR){
80105ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ada:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ade:	66 83 f8 01          	cmp    $0x1,%ax
80105ae2:	75 1a                	jne    80105afe <sys_link+0x98>
    iunlockput(ip);
80105ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae7:	89 04 24             	mov    %eax,(%esp)
80105aea:	e8 0c c1 ff ff       	call   80101bfb <iunlockput>
    end_op();
80105aef:	e8 41 db ff ff       	call   80103635 <end_op>
    return -1;
80105af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af9:	e9 e8 00 00 00       	jmp    80105be6 <sys_link+0x180>
  }

  ip->nlink++;
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b05:	8d 50 01             	lea    0x1(%eax),%edx
80105b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b12:	89 04 24             	mov    %eax,(%esp)
80105b15:	e8 95 bc ff ff       	call   801017af <iupdate>
  iunlock(ip);
80105b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1d:	89 04 24             	mov    %eax,(%esp)
80105b20:	e8 a0 bf ff ff       	call   80101ac5 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b28:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b2f:	89 04 24             	mov    %eax,(%esp)
80105b32:	e8 0d ca ff ff       	call   80102544 <nameiparent>
80105b37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3e:	75 02                	jne    80105b42 <sys_link+0xdc>
    goto bad;
80105b40:	eb 68                	jmp    80105baa <sys_link+0x144>
  ilock(dp);
80105b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b45:	89 04 24             	mov    %eax,(%esp)
80105b48:	e8 24 be ff ff       	call   80101971 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b50:	8b 10                	mov    (%eax),%edx
80105b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b55:	8b 00                	mov    (%eax),%eax
80105b57:	39 c2                	cmp    %eax,%edx
80105b59:	75 20                	jne    80105b7b <sys_link+0x115>
80105b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5e:	8b 40 04             	mov    0x4(%eax),%eax
80105b61:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b65:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6f:	89 04 24             	mov    %eax,(%esp)
80105b72:	e8 eb c6 ff ff       	call   80102262 <dirlink>
80105b77:	85 c0                	test   %eax,%eax
80105b79:	79 0d                	jns    80105b88 <sys_link+0x122>
    iunlockput(dp);
80105b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7e:	89 04 24             	mov    %eax,(%esp)
80105b81:	e8 75 c0 ff ff       	call   80101bfb <iunlockput>
    goto bad;
80105b86:	eb 22                	jmp    80105baa <sys_link+0x144>
  }
  iunlockput(dp);
80105b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8b:	89 04 24             	mov    %eax,(%esp)
80105b8e:	e8 68 c0 ff ff       	call   80101bfb <iunlockput>
  iput(ip);
80105b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b96:	89 04 24             	mov    %eax,(%esp)
80105b99:	e8 8c bf ff ff       	call   80101b2a <iput>

  end_op();
80105b9e:	e8 92 da ff ff       	call   80103635 <end_op>

  return 0;
80105ba3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba8:	eb 3c                	jmp    80105be6 <sys_link+0x180>

bad:
  ilock(ip);
80105baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bad:	89 04 24             	mov    %eax,(%esp)
80105bb0:	e8 bc bd ff ff       	call   80101971 <ilock>
  ip->nlink--;
80105bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bbc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc9:	89 04 24             	mov    %eax,(%esp)
80105bcc:	e8 de bb ff ff       	call   801017af <iupdate>
  iunlockput(ip);
80105bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 1f c0 ff ff       	call   80101bfb <iunlockput>
  end_op();
80105bdc:	e8 54 da ff ff       	call   80103635 <end_op>
  return -1;
80105be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bee:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105bf5:	eb 4b                	jmp    80105c42 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c01:	00 
80105c02:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c06:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c09:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c10:	89 04 24             	mov    %eax,(%esp)
80105c13:	e8 6c c2 ff ff       	call   80101e84 <readi>
80105c18:	83 f8 10             	cmp    $0x10,%eax
80105c1b:	74 0c                	je     80105c29 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c1d:	c7 04 24 af 8d 10 80 	movl   $0x80108daf,(%esp)
80105c24:	e8 ae a9 ff ff       	call   801005d7 <panic>
    if(de.inum != 0)
80105c29:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c2d:	66 85 c0             	test   %ax,%ax
80105c30:	74 07                	je     80105c39 <isdirempty+0x51>
      return 0;
80105c32:	b8 00 00 00 00       	mov    $0x0,%eax
80105c37:	eb 1b                	jmp    80105c54 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3c:	83 c0 10             	add    $0x10,%eax
80105c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c45:	8b 45 08             	mov    0x8(%ebp),%eax
80105c48:	8b 40 18             	mov    0x18(%eax),%eax
80105c4b:	39 c2                	cmp    %eax,%edx
80105c4d:	72 a8                	jb     80105bf7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c4f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c54:	c9                   	leave  
80105c55:	c3                   	ret    

80105c56 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c56:	55                   	push   %ebp
80105c57:	89 e5                	mov    %esp,%ebp
80105c59:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c5c:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c6a:	e8 71 fa ff ff       	call   801056e0 <argstr>
80105c6f:	85 c0                	test   %eax,%eax
80105c71:	79 0a                	jns    80105c7d <sys_unlink+0x27>
    return -1;
80105c73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c78:	e9 af 01 00 00       	jmp    80105e2c <sys_unlink+0x1d6>

  begin_op();
80105c7d:	e8 2f d9 ff ff       	call   801035b1 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c82:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c85:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c88:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c8c:	89 04 24             	mov    %eax,(%esp)
80105c8f:	e8 b0 c8 ff ff       	call   80102544 <nameiparent>
80105c94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c9b:	75 0f                	jne    80105cac <sys_unlink+0x56>
    end_op();
80105c9d:	e8 93 d9 ff ff       	call   80103635 <end_op>
    return -1;
80105ca2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca7:	e9 80 01 00 00       	jmp    80105e2c <sys_unlink+0x1d6>
  }

  ilock(dp);
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	89 04 24             	mov    %eax,(%esp)
80105cb2:	e8 ba bc ff ff       	call   80101971 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cb7:	c7 44 24 04 c1 8d 10 	movl   $0x80108dc1,0x4(%esp)
80105cbe:	80 
80105cbf:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cc2:	89 04 24             	mov    %eax,(%esp)
80105cc5:	e8 ad c4 ff ff       	call   80102177 <namecmp>
80105cca:	85 c0                	test   %eax,%eax
80105ccc:	0f 84 45 01 00 00    	je     80105e17 <sys_unlink+0x1c1>
80105cd2:	c7 44 24 04 c3 8d 10 	movl   $0x80108dc3,0x4(%esp)
80105cd9:	80 
80105cda:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cdd:	89 04 24             	mov    %eax,(%esp)
80105ce0:	e8 92 c4 ff ff       	call   80102177 <namecmp>
80105ce5:	85 c0                	test   %eax,%eax
80105ce7:	0f 84 2a 01 00 00    	je     80105e17 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ced:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105cf0:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfe:	89 04 24             	mov    %eax,(%esp)
80105d01:	e8 93 c4 ff ff       	call   80102199 <dirlookup>
80105d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d0d:	75 05                	jne    80105d14 <sys_unlink+0xbe>
    goto bad;
80105d0f:	e9 03 01 00 00       	jmp    80105e17 <sys_unlink+0x1c1>
  ilock(ip);
80105d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d17:	89 04 24             	mov    %eax,(%esp)
80105d1a:	e8 52 bc ff ff       	call   80101971 <ilock>

  if(ip->nlink < 1)
80105d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d22:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d26:	66 85 c0             	test   %ax,%ax
80105d29:	7f 0c                	jg     80105d37 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d2b:	c7 04 24 c6 8d 10 80 	movl   $0x80108dc6,(%esp)
80105d32:	e8 a0 a8 ff ff       	call   801005d7 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d3e:	66 83 f8 01          	cmp    $0x1,%ax
80105d42:	75 1f                	jne    80105d63 <sys_unlink+0x10d>
80105d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d47:	89 04 24             	mov    %eax,(%esp)
80105d4a:	e8 99 fe ff ff       	call   80105be8 <isdirempty>
80105d4f:	85 c0                	test   %eax,%eax
80105d51:	75 10                	jne    80105d63 <sys_unlink+0x10d>
    iunlockput(ip);
80105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d56:	89 04 24             	mov    %eax,(%esp)
80105d59:	e8 9d be ff ff       	call   80101bfb <iunlockput>
    goto bad;
80105d5e:	e9 b4 00 00 00       	jmp    80105e17 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105d63:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105d6a:	00 
80105d6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d72:	00 
80105d73:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d76:	89 04 24             	mov    %eax,(%esp)
80105d79:	e8 90 f5 ff ff       	call   8010530e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d7e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d81:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d88:	00 
80105d89:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d97:	89 04 24             	mov    %eax,(%esp)
80105d9a:	e8 49 c2 ff ff       	call   80101fe8 <writei>
80105d9f:	83 f8 10             	cmp    $0x10,%eax
80105da2:	74 0c                	je     80105db0 <sys_unlink+0x15a>
    panic("unlink: writei");
80105da4:	c7 04 24 d8 8d 10 80 	movl   $0x80108dd8,(%esp)
80105dab:	e8 27 a8 ff ff       	call   801005d7 <panic>
  if(ip->type == T_DIR){
80105db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105db7:	66 83 f8 01          	cmp    $0x1,%ax
80105dbb:	75 1c                	jne    80105dd9 <sys_unlink+0x183>
    dp->nlink--;
80105dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dc4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dca:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	89 04 24             	mov    %eax,(%esp)
80105dd4:	e8 d6 b9 ff ff       	call   801017af <iupdate>
  }
  iunlockput(dp);
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	89 04 24             	mov    %eax,(%esp)
80105ddf:	e8 17 be ff ff       	call   80101bfb <iunlockput>

  ip->nlink--;
80105de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105deb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df8:	89 04 24             	mov    %eax,(%esp)
80105dfb:	e8 af b9 ff ff       	call   801017af <iupdate>
  iunlockput(ip);
80105e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e03:	89 04 24             	mov    %eax,(%esp)
80105e06:	e8 f0 bd ff ff       	call   80101bfb <iunlockput>

  end_op();
80105e0b:	e8 25 d8 ff ff       	call   80103635 <end_op>

  return 0;
80105e10:	b8 00 00 00 00       	mov    $0x0,%eax
80105e15:	eb 15                	jmp    80105e2c <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	89 04 24             	mov    %eax,(%esp)
80105e1d:	e8 d9 bd ff ff       	call   80101bfb <iunlockput>
  end_op();
80105e22:	e8 0e d8 ff ff       	call   80103635 <end_op>
  return -1;
80105e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e2c:	c9                   	leave  
80105e2d:	c3                   	ret    

80105e2e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e2e:	55                   	push   %ebp
80105e2f:	89 e5                	mov    %esp,%ebp
80105e31:	83 ec 48             	sub    $0x48,%esp
80105e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e37:	8b 55 10             	mov    0x10(%ebp),%edx
80105e3a:	8b 45 14             	mov    0x14(%ebp),%eax
80105e3d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e41:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e45:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e49:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e50:	8b 45 08             	mov    0x8(%ebp),%eax
80105e53:	89 04 24             	mov    %eax,(%esp)
80105e56:	e8 e9 c6 ff ff       	call   80102544 <nameiparent>
80105e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e62:	75 0a                	jne    80105e6e <create+0x40>
    return 0;
80105e64:	b8 00 00 00 00       	mov    $0x0,%eax
80105e69:	e9 7e 01 00 00       	jmp    80105fec <create+0x1be>
  ilock(dp);
80105e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e71:	89 04 24             	mov    %eax,(%esp)
80105e74:	e8 f8 ba ff ff       	call   80101971 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e79:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e80:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e83:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	89 04 24             	mov    %eax,(%esp)
80105e8d:	e8 07 c3 ff ff       	call   80102199 <dirlookup>
80105e92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e99:	74 47                	je     80105ee2 <create+0xb4>
    iunlockput(dp);
80105e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9e:	89 04 24             	mov    %eax,(%esp)
80105ea1:	e8 55 bd ff ff       	call   80101bfb <iunlockput>
    ilock(ip);
80105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea9:	89 04 24             	mov    %eax,(%esp)
80105eac:	e8 c0 ba ff ff       	call   80101971 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105eb1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105eb6:	75 15                	jne    80105ecd <create+0x9f>
80105eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ebf:	66 83 f8 02          	cmp    $0x2,%ax
80105ec3:	75 08                	jne    80105ecd <create+0x9f>
      return ip;
80105ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec8:	e9 1f 01 00 00       	jmp    80105fec <create+0x1be>
    iunlockput(ip);
80105ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed0:	89 04 24             	mov    %eax,(%esp)
80105ed3:	e8 23 bd ff ff       	call   80101bfb <iunlockput>
    return 0;
80105ed8:	b8 00 00 00 00       	mov    $0x0,%eax
80105edd:	e9 0a 01 00 00       	jmp    80105fec <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ee2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee9:	8b 00                	mov    (%eax),%eax
80105eeb:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eef:	89 04 24             	mov    %eax,(%esp)
80105ef2:	e8 e3 b7 ff ff       	call   801016da <ialloc>
80105ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105efa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105efe:	75 0c                	jne    80105f0c <create+0xde>
    panic("create: ialloc");
80105f00:	c7 04 24 e7 8d 10 80 	movl   $0x80108de7,(%esp)
80105f07:	e8 cb a6 ff ff       	call   801005d7 <panic>

  ilock(ip);
80105f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0f:	89 04 24             	mov    %eax,(%esp)
80105f12:	e8 5a ba ff ff       	call   80101971 <ilock>
  ip->major = major;
80105f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f1e:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f25:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f29:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f30:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	89 04 24             	mov    %eax,(%esp)
80105f3c:	e8 6e b8 ff ff       	call   801017af <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f41:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f46:	75 6a                	jne    80105fb2 <create+0x184>
    dp->nlink++;  // for ".."
80105f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f4f:	8d 50 01             	lea    0x1(%eax),%edx
80105f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f55:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5c:	89 04 24             	mov    %eax,(%esp)
80105f5f:	e8 4b b8 ff ff       	call   801017af <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f67:	8b 40 04             	mov    0x4(%eax),%eax
80105f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f6e:	c7 44 24 04 c1 8d 10 	movl   $0x80108dc1,0x4(%esp)
80105f75:	80 
80105f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f79:	89 04 24             	mov    %eax,(%esp)
80105f7c:	e8 e1 c2 ff ff       	call   80102262 <dirlink>
80105f81:	85 c0                	test   %eax,%eax
80105f83:	78 21                	js     80105fa6 <create+0x178>
80105f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f88:	8b 40 04             	mov    0x4(%eax),%eax
80105f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f8f:	c7 44 24 04 c3 8d 10 	movl   $0x80108dc3,0x4(%esp)
80105f96:	80 
80105f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9a:	89 04 24             	mov    %eax,(%esp)
80105f9d:	e8 c0 c2 ff ff       	call   80102262 <dirlink>
80105fa2:	85 c0                	test   %eax,%eax
80105fa4:	79 0c                	jns    80105fb2 <create+0x184>
      panic("create dots");
80105fa6:	c7 04 24 f6 8d 10 80 	movl   $0x80108df6,(%esp)
80105fad:	e8 25 a6 ff ff       	call   801005d7 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	8b 40 04             	mov    0x4(%eax),%eax
80105fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fbc:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	89 04 24             	mov    %eax,(%esp)
80105fc9:	e8 94 c2 ff ff       	call   80102262 <dirlink>
80105fce:	85 c0                	test   %eax,%eax
80105fd0:	79 0c                	jns    80105fde <create+0x1b0>
    panic("create: dirlink");
80105fd2:	c7 04 24 02 8e 10 80 	movl   $0x80108e02,(%esp)
80105fd9:	e8 f9 a5 ff ff       	call   801005d7 <panic>

  iunlockput(dp);
80105fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe1:	89 04 24             	mov    %eax,(%esp)
80105fe4:	e8 12 bc ff ff       	call   80101bfb <iunlockput>

  return ip;
80105fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105fec:	c9                   	leave  
80105fed:	c3                   	ret    

80105fee <sys_open>:

int
sys_open(void)
{
80105fee:	55                   	push   %ebp
80105fef:	89 e5                	mov    %esp,%ebp
80105ff1:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ff4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ffb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106002:	e8 d9 f6 ff ff       	call   801056e0 <argstr>
80106007:	85 c0                	test   %eax,%eax
80106009:	78 17                	js     80106022 <sys_open+0x34>
8010600b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010600e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106012:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106019:	e8 32 f6 ff ff       	call   80105650 <argint>
8010601e:	85 c0                	test   %eax,%eax
80106020:	79 0a                	jns    8010602c <sys_open+0x3e>
    return -1;
80106022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106027:	e9 5c 01 00 00       	jmp    80106188 <sys_open+0x19a>

  begin_op();
8010602c:	e8 80 d5 ff ff       	call   801035b1 <begin_op>

  if(omode & O_CREATE){
80106031:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106034:	25 00 02 00 00       	and    $0x200,%eax
80106039:	85 c0                	test   %eax,%eax
8010603b:	74 3b                	je     80106078 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010603d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106040:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106047:	00 
80106048:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010604f:	00 
80106050:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106057:	00 
80106058:	89 04 24             	mov    %eax,(%esp)
8010605b:	e8 ce fd ff ff       	call   80105e2e <create>
80106060:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106063:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106067:	75 6b                	jne    801060d4 <sys_open+0xe6>
      end_op();
80106069:	e8 c7 d5 ff ff       	call   80103635 <end_op>
      return -1;
8010606e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106073:	e9 10 01 00 00       	jmp    80106188 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106078:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010607b:	89 04 24             	mov    %eax,(%esp)
8010607e:	e8 9f c4 ff ff       	call   80102522 <namei>
80106083:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106086:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010608a:	75 0f                	jne    8010609b <sys_open+0xad>
      end_op();
8010608c:	e8 a4 d5 ff ff       	call   80103635 <end_op>
      return -1;
80106091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106096:	e9 ed 00 00 00       	jmp    80106188 <sys_open+0x19a>
    }
    ilock(ip);
8010609b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609e:	89 04 24             	mov    %eax,(%esp)
801060a1:	e8 cb b8 ff ff       	call   80101971 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060ad:	66 83 f8 01          	cmp    $0x1,%ax
801060b1:	75 21                	jne    801060d4 <sys_open+0xe6>
801060b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b6:	85 c0                	test   %eax,%eax
801060b8:	74 1a                	je     801060d4 <sys_open+0xe6>
      iunlockput(ip);
801060ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bd:	89 04 24             	mov    %eax,(%esp)
801060c0:	e8 36 bb ff ff       	call   80101bfb <iunlockput>
      end_op();
801060c5:	e8 6b d5 ff ff       	call   80103635 <end_op>
      return -1;
801060ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060cf:	e9 b4 00 00 00       	jmp    80106188 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060d4:	e8 05 af ff ff       	call   80100fde <filealloc>
801060d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060e0:	74 14                	je     801060f6 <sys_open+0x108>
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	89 04 24             	mov    %eax,(%esp)
801060e8:	e8 2e f7 ff ff       	call   8010581b <fdalloc>
801060ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060f4:	79 28                	jns    8010611e <sys_open+0x130>
    if(f)
801060f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060fa:	74 0b                	je     80106107 <sys_open+0x119>
      fileclose(f);
801060fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ff:	89 04 24             	mov    %eax,(%esp)
80106102:	e8 7f af ff ff       	call   80101086 <fileclose>
    iunlockput(ip);
80106107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610a:	89 04 24             	mov    %eax,(%esp)
8010610d:	e8 e9 ba ff ff       	call   80101bfb <iunlockput>
    end_op();
80106112:	e8 1e d5 ff ff       	call   80103635 <end_op>
    return -1;
80106117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611c:	eb 6a                	jmp    80106188 <sys_open+0x19a>
  }
  iunlock(ip);
8010611e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106121:	89 04 24             	mov    %eax,(%esp)
80106124:	e8 9c b9 ff ff       	call   80101ac5 <iunlock>
  end_op();
80106129:	e8 07 d5 ff ff       	call   80103635 <end_op>

  f->type = FD_INODE;
8010612e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106131:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106137:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010613d:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106143:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010614a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010614d:	83 e0 01             	and    $0x1,%eax
80106150:	85 c0                	test   %eax,%eax
80106152:	0f 94 c0             	sete   %al
80106155:	89 c2                	mov    %eax,%edx
80106157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615a:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010615d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106160:	83 e0 01             	and    $0x1,%eax
80106163:	85 c0                	test   %eax,%eax
80106165:	75 0a                	jne    80106171 <sys_open+0x183>
80106167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616a:	83 e0 02             	and    $0x2,%eax
8010616d:	85 c0                	test   %eax,%eax
8010616f:	74 07                	je     80106178 <sys_open+0x18a>
80106171:	b8 01 00 00 00       	mov    $0x1,%eax
80106176:	eb 05                	jmp    8010617d <sys_open+0x18f>
80106178:	b8 00 00 00 00       	mov    $0x0,%eax
8010617d:	89 c2                	mov    %eax,%edx
8010617f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106182:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106185:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106188:	c9                   	leave  
80106189:	c3                   	ret    

8010618a <sys_mkdir>:

int
sys_mkdir(void)
{
8010618a:	55                   	push   %ebp
8010618b:	89 e5                	mov    %esp,%ebp
8010618d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106190:	e8 1c d4 ff ff       	call   801035b1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106195:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106198:	89 44 24 04          	mov    %eax,0x4(%esp)
8010619c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061a3:	e8 38 f5 ff ff       	call   801056e0 <argstr>
801061a8:	85 c0                	test   %eax,%eax
801061aa:	78 2c                	js     801061d8 <sys_mkdir+0x4e>
801061ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061b6:	00 
801061b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061be:	00 
801061bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061c6:	00 
801061c7:	89 04 24             	mov    %eax,(%esp)
801061ca:	e8 5f fc ff ff       	call   80105e2e <create>
801061cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d6:	75 0c                	jne    801061e4 <sys_mkdir+0x5a>
    end_op();
801061d8:	e8 58 d4 ff ff       	call   80103635 <end_op>
    return -1;
801061dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e2:	eb 15                	jmp    801061f9 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801061e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e7:	89 04 24             	mov    %eax,(%esp)
801061ea:	e8 0c ba ff ff       	call   80101bfb <iunlockput>
  end_op();
801061ef:	e8 41 d4 ff ff       	call   80103635 <end_op>
  return 0;
801061f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f9:	c9                   	leave  
801061fa:	c3                   	ret    

801061fb <sys_mknod>:

int
sys_mknod(void)
{
801061fb:	55                   	push   %ebp
801061fc:	89 e5                	mov    %esp,%ebp
801061fe:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106201:	e8 ab d3 ff ff       	call   801035b1 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106206:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106209:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106214:	e8 c7 f4 ff ff       	call   801056e0 <argstr>
80106219:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106220:	78 5e                	js     80106280 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106222:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106225:	89 44 24 04          	mov    %eax,0x4(%esp)
80106229:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106230:	e8 1b f4 ff ff       	call   80105650 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106235:	85 c0                	test   %eax,%eax
80106237:	78 47                	js     80106280 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106239:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010623c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106240:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106247:	e8 04 f4 ff ff       	call   80105650 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010624c:	85 c0                	test   %eax,%eax
8010624e:	78 30                	js     80106280 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106253:	0f bf c8             	movswl %ax,%ecx
80106256:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106259:	0f bf d0             	movswl %ax,%edx
8010625c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010625f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106263:	89 54 24 08          	mov    %edx,0x8(%esp)
80106267:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010626e:	00 
8010626f:	89 04 24             	mov    %eax,(%esp)
80106272:	e8 b7 fb ff ff       	call   80105e2e <create>
80106277:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010627a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010627e:	75 0c                	jne    8010628c <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106280:	e8 b0 d3 ff ff       	call   80103635 <end_op>
    return -1;
80106285:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628a:	eb 15                	jmp    801062a1 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010628c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628f:	89 04 24             	mov    %eax,(%esp)
80106292:	e8 64 b9 ff ff       	call   80101bfb <iunlockput>
  end_op();
80106297:	e8 99 d3 ff ff       	call   80103635 <end_op>
  return 0;
8010629c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a1:	c9                   	leave  
801062a2:	c3                   	ret    

801062a3 <sys_chdir>:

int
sys_chdir(void)
{
801062a3:	55                   	push   %ebp
801062a4:	89 e5                	mov    %esp,%ebp
801062a6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062a9:	e8 03 d3 ff ff       	call   801035b1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062bc:	e8 1f f4 ff ff       	call   801056e0 <argstr>
801062c1:	85 c0                	test   %eax,%eax
801062c3:	78 14                	js     801062d9 <sys_chdir+0x36>
801062c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c8:	89 04 24             	mov    %eax,(%esp)
801062cb:	e8 52 c2 ff ff       	call   80102522 <namei>
801062d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d7:	75 0c                	jne    801062e5 <sys_chdir+0x42>
    end_op();
801062d9:	e8 57 d3 ff ff       	call   80103635 <end_op>
    return -1;
801062de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e3:	eb 61                	jmp    80106346 <sys_chdir+0xa3>
  }
  ilock(ip);
801062e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e8:	89 04 24             	mov    %eax,(%esp)
801062eb:	e8 81 b6 ff ff       	call   80101971 <ilock>
  if(ip->type != T_DIR){
801062f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062f7:	66 83 f8 01          	cmp    $0x1,%ax
801062fb:	74 17                	je     80106314 <sys_chdir+0x71>
    iunlockput(ip);
801062fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106300:	89 04 24             	mov    %eax,(%esp)
80106303:	e8 f3 b8 ff ff       	call   80101bfb <iunlockput>
    end_op();
80106308:	e8 28 d3 ff ff       	call   80103635 <end_op>
    return -1;
8010630d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106312:	eb 32                	jmp    80106346 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106317:	89 04 24             	mov    %eax,(%esp)
8010631a:	e8 a6 b7 ff ff       	call   80101ac5 <iunlock>
  iput(proc->cwd);
8010631f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106325:	8b 40 68             	mov    0x68(%eax),%eax
80106328:	89 04 24             	mov    %eax,(%esp)
8010632b:	e8 fa b7 ff ff       	call   80101b2a <iput>
  end_op();
80106330:	e8 00 d3 ff ff       	call   80103635 <end_op>
  proc->cwd = ip;
80106335:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010633e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106341:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106346:	c9                   	leave  
80106347:	c3                   	ret    

80106348 <sys_exec>:

int
sys_exec(void)
{
80106348:	55                   	push   %ebp
80106349:	89 e5                	mov    %esp,%ebp
8010634b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106351:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106354:	89 44 24 04          	mov    %eax,0x4(%esp)
80106358:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010635f:	e8 7c f3 ff ff       	call   801056e0 <argstr>
80106364:	85 c0                	test   %eax,%eax
80106366:	78 1a                	js     80106382 <sys_exec+0x3a>
80106368:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010636e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106372:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106379:	e8 d2 f2 ff ff       	call   80105650 <argint>
8010637e:	85 c0                	test   %eax,%eax
80106380:	79 0a                	jns    8010638c <sys_exec+0x44>
    return -1;
80106382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106387:	e9 c8 00 00 00       	jmp    80106454 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010638c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106393:	00 
80106394:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010639b:	00 
8010639c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063a2:	89 04 24             	mov    %eax,(%esp)
801063a5:	e8 64 ef ff ff       	call   8010530e <memset>
  for(i=0;; i++){
801063aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b4:	83 f8 1f             	cmp    $0x1f,%eax
801063b7:	76 0a                	jbe    801063c3 <sys_exec+0x7b>
      return -1;
801063b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063be:	e9 91 00 00 00       	jmp    80106454 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c6:	c1 e0 02             	shl    $0x2,%eax
801063c9:	89 c2                	mov    %eax,%edx
801063cb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063d1:	01 c2                	add    %eax,%edx
801063d3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801063dd:	89 14 24             	mov    %edx,(%esp)
801063e0:	e8 cf f1 ff ff       	call   801055b4 <fetchint>
801063e5:	85 c0                	test   %eax,%eax
801063e7:	79 07                	jns    801063f0 <sys_exec+0xa8>
      return -1;
801063e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ee:	eb 64                	jmp    80106454 <sys_exec+0x10c>
    if(uarg == 0){
801063f0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063f6:	85 c0                	test   %eax,%eax
801063f8:	75 26                	jne    80106420 <sys_exec+0xd8>
      argv[i] = 0;
801063fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fd:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106404:	00 00 00 00 
      break;
80106408:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106412:	89 54 24 04          	mov    %edx,0x4(%esp)
80106416:	89 04 24             	mov    %eax,(%esp)
80106419:	e8 89 a7 ff ff       	call   80100ba7 <exec>
8010641e:	eb 34                	jmp    80106454 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106420:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106426:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106429:	c1 e2 02             	shl    $0x2,%edx
8010642c:	01 c2                	add    %eax,%edx
8010642e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106434:	89 54 24 04          	mov    %edx,0x4(%esp)
80106438:	89 04 24             	mov    %eax,(%esp)
8010643b:	e8 ae f1 ff ff       	call   801055ee <fetchstr>
80106440:	85 c0                	test   %eax,%eax
80106442:	79 07                	jns    8010644b <sys_exec+0x103>
      return -1;
80106444:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106449:	eb 09                	jmp    80106454 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010644b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010644f:	e9 5d ff ff ff       	jmp    801063b1 <sys_exec+0x69>
  return exec(path, argv);
}
80106454:	c9                   	leave  
80106455:	c3                   	ret    

80106456 <sys_pipe>:

int
sys_pipe(void)
{
80106456:	55                   	push   %ebp
80106457:	89 e5                	mov    %esp,%ebp
80106459:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010645c:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106463:	00 
80106464:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106467:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106472:	e8 07 f2 ff ff       	call   8010567e <argptr>
80106477:	85 c0                	test   %eax,%eax
80106479:	79 0a                	jns    80106485 <sys_pipe+0x2f>
    return -1;
8010647b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106480:	e9 9b 00 00 00       	jmp    80106520 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106485:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106488:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010648f:	89 04 24             	mov    %eax,(%esp)
80106492:	e8 26 dc ff ff       	call   801040bd <pipealloc>
80106497:	85 c0                	test   %eax,%eax
80106499:	79 07                	jns    801064a2 <sys_pipe+0x4c>
    return -1;
8010649b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a0:	eb 7e                	jmp    80106520 <sys_pipe+0xca>
  fd0 = -1;
801064a2:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ac:	89 04 24             	mov    %eax,(%esp)
801064af:	e8 67 f3 ff ff       	call   8010581b <fdalloc>
801064b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064bb:	78 14                	js     801064d1 <sys_pipe+0x7b>
801064bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c0:	89 04 24             	mov    %eax,(%esp)
801064c3:	e8 53 f3 ff ff       	call   8010581b <fdalloc>
801064c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064cf:	79 37                	jns    80106508 <sys_pipe+0xb2>
    if(fd0 >= 0)
801064d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d5:	78 14                	js     801064eb <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801064d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064e0:	83 c2 08             	add    $0x8,%edx
801064e3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064ea:	00 
    fileclose(rf);
801064eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ee:	89 04 24             	mov    %eax,(%esp)
801064f1:	e8 90 ab ff ff       	call   80101086 <fileclose>
    fileclose(wf);
801064f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f9:	89 04 24             	mov    %eax,(%esp)
801064fc:	e8 85 ab ff ff       	call   80101086 <fileclose>
    return -1;
80106501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106506:	eb 18                	jmp    80106520 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106508:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010650b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010650e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106513:	8d 50 04             	lea    0x4(%eax),%edx
80106516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106519:	89 02                	mov    %eax,(%edx)
  return 0;
8010651b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106520:	c9                   	leave  
80106521:	c3                   	ret    

80106522 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106522:	55                   	push   %ebp
80106523:	89 e5                	mov    %esp,%ebp
80106525:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106528:	e8 4e e2 ff ff       	call   8010477b <fork>
}
8010652d:	c9                   	leave  
8010652e:	c3                   	ret    

8010652f <sys_exit>:

int
sys_exit(void)
{
8010652f:	55                   	push   %ebp
80106530:	89 e5                	mov    %esp,%ebp
80106532:	83 ec 08             	sub    $0x8,%esp
  exit();
80106535:	e8 bc e3 ff ff       	call   801048f6 <exit>
  return 0;  // not reached
8010653a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010653f:	c9                   	leave  
80106540:	c3                   	ret    

80106541 <sys_wait>:

int
sys_wait(void)
{
80106541:	55                   	push   %ebp
80106542:	89 e5                	mov    %esp,%ebp
80106544:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106547:	e8 cc e4 ff ff       	call   80104a18 <wait>
}
8010654c:	c9                   	leave  
8010654d:	c3                   	ret    

8010654e <sys_kill>:

int
sys_kill(void)
{
8010654e:	55                   	push   %ebp
8010654f:	89 e5                	mov    %esp,%ebp
80106551:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106554:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106557:	89 44 24 04          	mov    %eax,0x4(%esp)
8010655b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106562:	e8 e9 f0 ff ff       	call   80105650 <argint>
80106567:	85 c0                	test   %eax,%eax
80106569:	79 07                	jns    80106572 <sys_kill+0x24>
    return -1;
8010656b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106570:	eb 0b                	jmp    8010657d <sys_kill+0x2f>
  return kill(pid);
80106572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106575:	89 04 24             	mov    %eax,(%esp)
80106578:	e8 77 e9 ff ff       	call   80104ef4 <kill>
}
8010657d:	c9                   	leave  
8010657e:	c3                   	ret    

8010657f <sys_getpid>:

int
sys_getpid(void)
{
8010657f:	55                   	push   %ebp
80106580:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106582:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106588:	8b 40 10             	mov    0x10(%eax),%eax
}
8010658b:	5d                   	pop    %ebp
8010658c:	c3                   	ret    

8010658d <sys_sbrk>:

int
sys_sbrk(void)
{
8010658d:	55                   	push   %ebp
8010658e:	89 e5                	mov    %esp,%ebp
80106590:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106593:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106596:	89 44 24 04          	mov    %eax,0x4(%esp)
8010659a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065a1:	e8 aa f0 ff ff       	call   80105650 <argint>
801065a6:	85 c0                	test   %eax,%eax
801065a8:	79 07                	jns    801065b1 <sys_sbrk+0x24>
    return -1;
801065aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065af:	eb 24                	jmp    801065d5 <sys_sbrk+0x48>
  addr = proc->sz;
801065b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065b7:	8b 00                	mov    (%eax),%eax
801065b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bf:	89 04 24             	mov    %eax,(%esp)
801065c2:	e8 0f e1 ff ff       	call   801046d6 <growproc>
801065c7:	85 c0                	test   %eax,%eax
801065c9:	79 07                	jns    801065d2 <sys_sbrk+0x45>
    return -1;
801065cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d0:	eb 03                	jmp    801065d5 <sys_sbrk+0x48>
  return addr;
801065d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065d5:	c9                   	leave  
801065d6:	c3                   	ret    

801065d7 <sys_sleep>:

int
sys_sleep(void)
{
801065d7:	55                   	push   %ebp
801065d8:	89 e5                	mov    %esp,%ebp
801065da:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065eb:	e8 60 f0 ff ff       	call   80105650 <argint>
801065f0:	85 c0                	test   %eax,%eax
801065f2:	79 07                	jns    801065fb <sys_sleep+0x24>
    return -1;
801065f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f9:	eb 6c                	jmp    80106667 <sys_sleep+0x90>
  acquire(&tickslock);
801065fb:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
80106602:	e8 b3 ea ff ff       	call   801050ba <acquire>
  ticks0 = ticks;
80106607:	a1 c0 6b 11 80       	mov    0x80116bc0,%eax
8010660c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010660f:	eb 34                	jmp    80106645 <sys_sleep+0x6e>
    if(proc->killed){
80106611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106617:	8b 40 24             	mov    0x24(%eax),%eax
8010661a:	85 c0                	test   %eax,%eax
8010661c:	74 13                	je     80106631 <sys_sleep+0x5a>
      release(&tickslock);
8010661e:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
80106625:	e8 f2 ea ff ff       	call   8010511c <release>
      return -1;
8010662a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662f:	eb 36                	jmp    80106667 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106631:	c7 44 24 04 80 63 11 	movl   $0x80116380,0x4(%esp)
80106638:	80 
80106639:	c7 04 24 c0 6b 11 80 	movl   $0x80116bc0,(%esp)
80106640:	e8 ab e7 ff ff       	call   80104df0 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106645:	a1 c0 6b 11 80       	mov    0x80116bc0,%eax
8010664a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010664d:	89 c2                	mov    %eax,%edx
8010664f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106652:	39 c2                	cmp    %eax,%edx
80106654:	72 bb                	jb     80106611 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106656:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
8010665d:	e8 ba ea ff ff       	call   8010511c <release>
  return 0;
80106662:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106667:	c9                   	leave  
80106668:	c3                   	ret    

80106669 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106669:	55                   	push   %ebp
8010666a:	89 e5                	mov    %esp,%ebp
8010666c:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010666f:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
80106676:	e8 3f ea ff ff       	call   801050ba <acquire>
  xticks = ticks;
8010667b:	a1 c0 6b 11 80       	mov    0x80116bc0,%eax
80106680:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106683:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
8010668a:	e8 8d ea ff ff       	call   8010511c <release>
  return xticks;
8010668f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106692:	c9                   	leave  
80106693:	c3                   	ret    

80106694 <sys_gettime>:

int
sys_gettime(void) {
80106694:	55                   	push   %ebp
80106695:	89 e5                	mov    %esp,%ebp
80106697:	83 ec 28             	sub    $0x28,%esp
  struct rtcdate *d;
  if (argptr(0, (char **)&d, sizeof(struct rtcdate)) < 0)
8010669a:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801066a1:	00 
801066a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066b0:	e8 c9 ef ff ff       	call   8010567e <argptr>
801066b5:	85 c0                	test   %eax,%eax
801066b7:	79 07                	jns    801066c0 <sys_gettime+0x2c>
      return -1;
801066b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066be:	eb 10                	jmp    801066d0 <sys_gettime+0x3c>
  cmostime(d);
801066c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c3:	89 04 24             	mov    %eax,(%esp)
801066c6:	e8 28 cb ff ff       	call   801031f3 <cmostime>
  return 0;
801066cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066d0:	c9                   	leave  
801066d1:	c3                   	ret    

801066d2 <sys_settickets>:

int
sys_settickets(void) {
801066d2:	55                   	push   %ebp
801066d3:	89 e5                	mov    %esp,%ebp
801066d5:	83 ec 28             	sub    $0x28,%esp
  int n;
  if (argint(0, &n) < 0){
801066d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066db:	89 44 24 04          	mov    %eax,0x4(%esp)
801066df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066e6:	e8 65 ef ff ff       	call   80105650 <argint>
801066eb:	85 c0                	test   %eax,%eax
801066ed:	79 14                	jns    80106703 <sys_settickets+0x31>
    proc->tickets = 20;
801066ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066f5:	c7 40 7c 14 00 00 00 	movl   $0x14,0x7c(%eax)
    return -1;
801066fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106701:	eb 11                	jmp    80106714 <sys_settickets+0x42>
  }
  proc->tickets = n;
80106703:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106709:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010670c:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010670f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106714:	c9                   	leave  
80106715:	c3                   	ret    

80106716 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 08             	sub    $0x8,%esp
8010671c:	8b 55 08             	mov    0x8(%ebp),%edx
8010671f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106722:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106726:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106729:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010672d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106731:	ee                   	out    %al,(%dx)
}
80106732:	c9                   	leave  
80106733:	c3                   	ret    

80106734 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106734:	55                   	push   %ebp
80106735:	89 e5                	mov    %esp,%ebp
80106737:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010673a:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106741:	00 
80106742:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106749:	e8 c8 ff ff ff       	call   80106716 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010674e:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106755:	00 
80106756:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010675d:	e8 b4 ff ff ff       	call   80106716 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106762:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106769:	00 
8010676a:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106771:	e8 a0 ff ff ff       	call   80106716 <outb>
  picenable(IRQ_TIMER);
80106776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677d:	e8 ce d7 ff ff       	call   80103f50 <picenable>
}
80106782:	c9                   	leave  
80106783:	c3                   	ret    

80106784 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106784:	1e                   	push   %ds
  pushl %es
80106785:	06                   	push   %es
  pushl %fs
80106786:	0f a0                	push   %fs
  pushl %gs
80106788:	0f a8                	push   %gs
  pushal
8010678a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010678b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010678f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106791:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106793:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106797:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106799:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010679b:	54                   	push   %esp
  call trap
8010679c:	e8 d8 01 00 00       	call   80106979 <trap>
  addl $4, %esp
801067a1:	83 c4 04             	add    $0x4,%esp

801067a4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067a4:	61                   	popa   
  popl %gs
801067a5:	0f a9                	pop    %gs
  popl %fs
801067a7:	0f a1                	pop    %fs
  popl %es
801067a9:	07                   	pop    %es
  popl %ds
801067aa:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067ab:	83 c4 08             	add    $0x8,%esp
  iret
801067ae:	cf                   	iret   

801067af <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067af:	55                   	push   %ebp
801067b0:	89 e5                	mov    %esp,%ebp
801067b2:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b8:	83 e8 01             	sub    $0x1,%eax
801067bb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067bf:	8b 45 08             	mov    0x8(%ebp),%eax
801067c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067c6:	8b 45 08             	mov    0x8(%ebp),%eax
801067c9:	c1 e8 10             	shr    $0x10,%eax
801067cc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067d0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067d3:	0f 01 18             	lidtl  (%eax)
}
801067d6:	c9                   	leave  
801067d7:	c3                   	ret    

801067d8 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067d8:	55                   	push   %ebp
801067d9:	89 e5                	mov    %esp,%ebp
801067db:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067de:	0f 20 d0             	mov    %cr2,%eax
801067e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067e7:	c9                   	leave  
801067e8:	c3                   	ret    

801067e9 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067e9:	55                   	push   %ebp
801067ea:	89 e5                	mov    %esp,%ebp
801067ec:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067f6:	e9 c3 00 00 00       	jmp    801068be <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fe:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106805:	89 c2                	mov    %eax,%edx
80106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680a:	66 89 14 c5 c0 63 11 	mov    %dx,-0x7fee9c40(,%eax,8)
80106811:	80 
80106812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106815:	66 c7 04 c5 c2 63 11 	movw   $0x8,-0x7fee9c3e(,%eax,8)
8010681c:	80 08 00 
8010681f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106822:	0f b6 14 c5 c4 63 11 	movzbl -0x7fee9c3c(,%eax,8),%edx
80106829:	80 
8010682a:	83 e2 e0             	and    $0xffffffe0,%edx
8010682d:	88 14 c5 c4 63 11 80 	mov    %dl,-0x7fee9c3c(,%eax,8)
80106834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106837:	0f b6 14 c5 c4 63 11 	movzbl -0x7fee9c3c(,%eax,8),%edx
8010683e:	80 
8010683f:	83 e2 1f             	and    $0x1f,%edx
80106842:	88 14 c5 c4 63 11 80 	mov    %dl,-0x7fee9c3c(,%eax,8)
80106849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684c:	0f b6 14 c5 c5 63 11 	movzbl -0x7fee9c3b(,%eax,8),%edx
80106853:	80 
80106854:	83 e2 f0             	and    $0xfffffff0,%edx
80106857:	83 ca 0e             	or     $0xe,%edx
8010685a:	88 14 c5 c5 63 11 80 	mov    %dl,-0x7fee9c3b(,%eax,8)
80106861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106864:	0f b6 14 c5 c5 63 11 	movzbl -0x7fee9c3b(,%eax,8),%edx
8010686b:	80 
8010686c:	83 e2 ef             	and    $0xffffffef,%edx
8010686f:	88 14 c5 c5 63 11 80 	mov    %dl,-0x7fee9c3b(,%eax,8)
80106876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106879:	0f b6 14 c5 c5 63 11 	movzbl -0x7fee9c3b(,%eax,8),%edx
80106880:	80 
80106881:	83 e2 9f             	and    $0xffffff9f,%edx
80106884:	88 14 c5 c5 63 11 80 	mov    %dl,-0x7fee9c3b(,%eax,8)
8010688b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688e:	0f b6 14 c5 c5 63 11 	movzbl -0x7fee9c3b(,%eax,8),%edx
80106895:	80 
80106896:	83 ca 80             	or     $0xffffff80,%edx
80106899:	88 14 c5 c5 63 11 80 	mov    %dl,-0x7fee9c3b(,%eax,8)
801068a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a3:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
801068aa:	c1 e8 10             	shr    $0x10,%eax
801068ad:	89 c2                	mov    %eax,%edx
801068af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b2:	66 89 14 c5 c6 63 11 	mov    %dx,-0x7fee9c3a(,%eax,8)
801068b9:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068be:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068c5:	0f 8e 30 ff ff ff    	jle    801067fb <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068cb:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
801068d0:	66 a3 c0 65 11 80    	mov    %ax,0x801165c0
801068d6:	66 c7 05 c2 65 11 80 	movw   $0x8,0x801165c2
801068dd:	08 00 
801068df:	0f b6 05 c4 65 11 80 	movzbl 0x801165c4,%eax
801068e6:	83 e0 e0             	and    $0xffffffe0,%eax
801068e9:	a2 c4 65 11 80       	mov    %al,0x801165c4
801068ee:	0f b6 05 c4 65 11 80 	movzbl 0x801165c4,%eax
801068f5:	83 e0 1f             	and    $0x1f,%eax
801068f8:	a2 c4 65 11 80       	mov    %al,0x801165c4
801068fd:	0f b6 05 c5 65 11 80 	movzbl 0x801165c5,%eax
80106904:	83 c8 0f             	or     $0xf,%eax
80106907:	a2 c5 65 11 80       	mov    %al,0x801165c5
8010690c:	0f b6 05 c5 65 11 80 	movzbl 0x801165c5,%eax
80106913:	83 e0 ef             	and    $0xffffffef,%eax
80106916:	a2 c5 65 11 80       	mov    %al,0x801165c5
8010691b:	0f b6 05 c5 65 11 80 	movzbl 0x801165c5,%eax
80106922:	83 c8 60             	or     $0x60,%eax
80106925:	a2 c5 65 11 80       	mov    %al,0x801165c5
8010692a:	0f b6 05 c5 65 11 80 	movzbl 0x801165c5,%eax
80106931:	83 c8 80             	or     $0xffffff80,%eax
80106934:	a2 c5 65 11 80       	mov    %al,0x801165c5
80106939:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
8010693e:	c1 e8 10             	shr    $0x10,%eax
80106941:	66 a3 c6 65 11 80    	mov    %ax,0x801165c6
  
  initlock(&tickslock, "time");
80106947:	c7 44 24 04 14 8e 10 	movl   $0x80108e14,0x4(%esp)
8010694e:	80 
8010694f:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
80106956:	e8 3e e7 ff ff       	call   80105099 <initlock>
}
8010695b:	c9                   	leave  
8010695c:	c3                   	ret    

8010695d <idtinit>:

void
idtinit(void)
{
8010695d:	55                   	push   %ebp
8010695e:	89 e5                	mov    %esp,%ebp
80106960:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106963:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010696a:	00 
8010696b:	c7 04 24 c0 63 11 80 	movl   $0x801163c0,(%esp)
80106972:	e8 38 fe ff ff       	call   801067af <lidt>
}
80106977:	c9                   	leave  
80106978:	c3                   	ret    

80106979 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106979:	55                   	push   %ebp
8010697a:	89 e5                	mov    %esp,%ebp
8010697c:	57                   	push   %edi
8010697d:	56                   	push   %esi
8010697e:	53                   	push   %ebx
8010697f:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106982:	8b 45 08             	mov    0x8(%ebp),%eax
80106985:	8b 40 30             	mov    0x30(%eax),%eax
80106988:	83 f8 40             	cmp    $0x40,%eax
8010698b:	75 3f                	jne    801069cc <trap+0x53>
    if(proc->killed)
8010698d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106993:	8b 40 24             	mov    0x24(%eax),%eax
80106996:	85 c0                	test   %eax,%eax
80106998:	74 05                	je     8010699f <trap+0x26>
      exit();
8010699a:	e8 57 df ff ff       	call   801048f6 <exit>
    proc->tf = tf;
8010699f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a5:	8b 55 08             	mov    0x8(%ebp),%edx
801069a8:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801069ab:	e8 67 ed ff ff       	call   80105717 <syscall>
    if(proc->killed)
801069b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069b6:	8b 40 24             	mov    0x24(%eax),%eax
801069b9:	85 c0                	test   %eax,%eax
801069bb:	74 0a                	je     801069c7 <trap+0x4e>
      exit();
801069bd:	e8 34 df ff ff       	call   801048f6 <exit>
    return;
801069c2:	e9 2d 02 00 00       	jmp    80106bf4 <trap+0x27b>
801069c7:	e9 28 02 00 00       	jmp    80106bf4 <trap+0x27b>
  }

  switch(tf->trapno){
801069cc:	8b 45 08             	mov    0x8(%ebp),%eax
801069cf:	8b 40 30             	mov    0x30(%eax),%eax
801069d2:	83 e8 20             	sub    $0x20,%eax
801069d5:	83 f8 1f             	cmp    $0x1f,%eax
801069d8:	0f 87 bc 00 00 00    	ja     80106a9a <trap+0x121>
801069de:	8b 04 85 bc 8e 10 80 	mov    -0x7fef7144(,%eax,4),%eax
801069e5:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069ed:	0f b6 00             	movzbl (%eax),%eax
801069f0:	84 c0                	test   %al,%al
801069f2:	75 31                	jne    80106a25 <trap+0xac>
      acquire(&tickslock);
801069f4:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
801069fb:	e8 ba e6 ff ff       	call   801050ba <acquire>
      ticks++;
80106a00:	a1 c0 6b 11 80       	mov    0x80116bc0,%eax
80106a05:	83 c0 01             	add    $0x1,%eax
80106a08:	a3 c0 6b 11 80       	mov    %eax,0x80116bc0
      wakeup(&ticks);
80106a0d:	c7 04 24 c0 6b 11 80 	movl   $0x80116bc0,(%esp)
80106a14:	e8 b0 e4 ff ff       	call   80104ec9 <wakeup>
      release(&tickslock);
80106a19:	c7 04 24 80 63 11 80 	movl   $0x80116380,(%esp)
80106a20:	e8 f7 e6 ff ff       	call   8010511c <release>
    }
    lapiceoi();
80106a25:	e8 f9 c5 ff ff       	call   80103023 <lapiceoi>
    break;
80106a2a:	e9 41 01 00 00       	jmp    80106b70 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a2f:	e8 fd bd ff ff       	call   80102831 <ideintr>
    lapiceoi();
80106a34:	e8 ea c5 ff ff       	call   80103023 <lapiceoi>
    break;
80106a39:	e9 32 01 00 00       	jmp    80106b70 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a3e:	e8 af c3 ff ff       	call   80102df2 <kbdintr>
    lapiceoi();
80106a43:	e8 db c5 ff ff       	call   80103023 <lapiceoi>
    break;
80106a48:	e9 23 01 00 00       	jmp    80106b70 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a4d:	e8 97 03 00 00       	call   80106de9 <uartintr>
    lapiceoi();
80106a52:	e8 cc c5 ff ff       	call   80103023 <lapiceoi>
    break;
80106a57:	e9 14 01 00 00       	jmp    80106b70 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5f:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a62:	8b 45 08             	mov    0x8(%ebp),%eax
80106a65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a69:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a6c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a72:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a75:	0f b6 c0             	movzbl %al,%eax
80106a78:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a7c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a80:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a84:	c7 04 24 1c 8e 10 80 	movl   $0x80108e1c,(%esp)
80106a8b:	e8 73 99 ff ff       	call   80100403 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a90:	e8 8e c5 ff ff       	call   80103023 <lapiceoi>
    break;
80106a95:	e9 d6 00 00 00       	jmp    80106b70 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa0:	85 c0                	test   %eax,%eax
80106aa2:	74 11                	je     80106ab5 <trap+0x13c>
80106aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aab:	0f b7 c0             	movzwl %ax,%eax
80106aae:	83 e0 03             	and    $0x3,%eax
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	75 46                	jne    80106afb <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ab5:	e8 1e fd ff ff       	call   801067d8 <rcr2>
80106aba:	8b 55 08             	mov    0x8(%ebp),%edx
80106abd:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ac0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ac7:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aca:	0f b6 ca             	movzbl %dl,%ecx
80106acd:	8b 55 08             	mov    0x8(%ebp),%edx
80106ad0:	8b 52 30             	mov    0x30(%edx),%edx
80106ad3:	89 44 24 10          	mov    %eax,0x10(%esp)
80106ad7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106adb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106adf:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ae3:	c7 04 24 40 8e 10 80 	movl   $0x80108e40,(%esp)
80106aea:	e8 14 99 ff ff       	call   80100403 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106aef:	c7 04 24 72 8e 10 80 	movl   $0x80108e72,(%esp)
80106af6:	e8 dc 9a ff ff       	call   801005d7 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106afb:	e8 d8 fc ff ff       	call   801067d8 <rcr2>
80106b00:	89 c2                	mov    %eax,%edx
80106b02:	8b 45 08             	mov    0x8(%ebp),%eax
80106b05:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b08:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b0e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b11:	0f b6 f0             	movzbl %al,%esi
80106b14:	8b 45 08             	mov    0x8(%ebp),%eax
80106b17:	8b 58 34             	mov    0x34(%eax),%ebx
80106b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1d:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b26:	83 c0 6c             	add    $0x6c,%eax
80106b29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b32:	8b 40 10             	mov    0x10(%eax),%eax
80106b35:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b39:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b3d:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b41:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b45:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106b4c:	89 74 24 08          	mov    %esi,0x8(%esp)
80106b50:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b54:	c7 04 24 78 8e 10 80 	movl   $0x80108e78,(%esp)
80106b5b:	e8 a3 98 ff ff       	call   80100403 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b66:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b6d:	eb 01                	jmp    80106b70 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b6f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b76:	85 c0                	test   %eax,%eax
80106b78:	74 24                	je     80106b9e <trap+0x225>
80106b7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b80:	8b 40 24             	mov    0x24(%eax),%eax
80106b83:	85 c0                	test   %eax,%eax
80106b85:	74 17                	je     80106b9e <trap+0x225>
80106b87:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b8e:	0f b7 c0             	movzwl %ax,%eax
80106b91:	83 e0 03             	and    $0x3,%eax
80106b94:	83 f8 03             	cmp    $0x3,%eax
80106b97:	75 05                	jne    80106b9e <trap+0x225>
    exit();
80106b99:	e8 58 dd ff ff       	call   801048f6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba4:	85 c0                	test   %eax,%eax
80106ba6:	74 1e                	je     80106bc6 <trap+0x24d>
80106ba8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bae:	8b 40 0c             	mov    0xc(%eax),%eax
80106bb1:	83 f8 04             	cmp    $0x4,%eax
80106bb4:	75 10                	jne    80106bc6 <trap+0x24d>
80106bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb9:	8b 40 30             	mov    0x30(%eax),%eax
80106bbc:	83 f8 20             	cmp    $0x20,%eax
80106bbf:	75 05                	jne    80106bc6 <trap+0x24d>
    yield();
80106bc1:	e8 b9 e1 ff ff       	call   80104d7f <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bcc:	85 c0                	test   %eax,%eax
80106bce:	74 24                	je     80106bf4 <trap+0x27b>
80106bd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bd6:	8b 40 24             	mov    0x24(%eax),%eax
80106bd9:	85 c0                	test   %eax,%eax
80106bdb:	74 17                	je     80106bf4 <trap+0x27b>
80106bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106be0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106be4:	0f b7 c0             	movzwl %ax,%eax
80106be7:	83 e0 03             	and    $0x3,%eax
80106bea:	83 f8 03             	cmp    $0x3,%eax
80106bed:	75 05                	jne    80106bf4 <trap+0x27b>
    exit();
80106bef:	e8 02 dd ff ff       	call   801048f6 <exit>
}
80106bf4:	83 c4 3c             	add    $0x3c,%esp
80106bf7:	5b                   	pop    %ebx
80106bf8:	5e                   	pop    %esi
80106bf9:	5f                   	pop    %edi
80106bfa:	5d                   	pop    %ebp
80106bfb:	c3                   	ret    

80106bfc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bfc:	55                   	push   %ebp
80106bfd:	89 e5                	mov    %esp,%ebp
80106bff:	83 ec 14             	sub    $0x14,%esp
80106c02:	8b 45 08             	mov    0x8(%ebp),%eax
80106c05:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c09:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c0d:	89 c2                	mov    %eax,%edx
80106c0f:	ec                   	in     (%dx),%al
80106c10:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c13:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c17:	c9                   	leave  
80106c18:	c3                   	ret    

80106c19 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c19:	55                   	push   %ebp
80106c1a:	89 e5                	mov    %esp,%ebp
80106c1c:	83 ec 08             	sub    $0x8,%esp
80106c1f:	8b 55 08             	mov    0x8(%ebp),%edx
80106c22:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c25:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c29:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c2c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c30:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c34:	ee                   	out    %al,(%dx)
}
80106c35:	c9                   	leave  
80106c36:	c3                   	ret    

80106c37 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c37:	55                   	push   %ebp
80106c38:	89 e5                	mov    %esp,%ebp
80106c3a:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c44:	00 
80106c45:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c4c:	e8 c8 ff ff ff       	call   80106c19 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c51:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c58:	00 
80106c59:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c60:	e8 b4 ff ff ff       	call   80106c19 <outb>
  outb(COM1+0, 115200/9600);
80106c65:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c6c:	00 
80106c6d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c74:	e8 a0 ff ff ff       	call   80106c19 <outb>
  outb(COM1+1, 0);
80106c79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c80:	00 
80106c81:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c88:	e8 8c ff ff ff       	call   80106c19 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c8d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c94:	00 
80106c95:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c9c:	e8 78 ff ff ff       	call   80106c19 <outb>
  outb(COM1+4, 0);
80106ca1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ca8:	00 
80106ca9:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106cb0:	e8 64 ff ff ff       	call   80106c19 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cb5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cbc:	00 
80106cbd:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cc4:	e8 50 ff ff ff       	call   80106c19 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cc9:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cd0:	e8 27 ff ff ff       	call   80106bfc <inb>
80106cd5:	3c ff                	cmp    $0xff,%al
80106cd7:	75 02                	jne    80106cdb <uartinit+0xa4>
    return;
80106cd9:	eb 6a                	jmp    80106d45 <uartinit+0x10e>
  uart = 1;
80106cdb:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80106ce2:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ce5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106cec:	e8 0b ff ff ff       	call   80106bfc <inb>
  inb(COM1+0);
80106cf1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf8:	e8 ff fe ff ff       	call   80106bfc <inb>
  picenable(IRQ_COM1);
80106cfd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d04:	e8 47 d2 ff ff       	call   80103f50 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d10:	00 
80106d11:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d18:	e8 93 bd ff ff       	call   80102ab0 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d1d:	c7 45 f4 3c 8f 10 80 	movl   $0x80108f3c,-0xc(%ebp)
80106d24:	eb 15                	jmp    80106d3b <uartinit+0x104>
    uartputc(*p);
80106d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d29:	0f b6 00             	movzbl (%eax),%eax
80106d2c:	0f be c0             	movsbl %al,%eax
80106d2f:	89 04 24             	mov    %eax,(%esp)
80106d32:	e8 10 00 00 00       	call   80106d47 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d3e:	0f b6 00             	movzbl (%eax),%eax
80106d41:	84 c0                	test   %al,%al
80106d43:	75 e1                	jne    80106d26 <uartinit+0xef>
    uartputc(*p);
}
80106d45:	c9                   	leave  
80106d46:	c3                   	ret    

80106d47 <uartputc>:

void
uartputc(int c)
{
80106d47:	55                   	push   %ebp
80106d48:	89 e5                	mov    %esp,%ebp
80106d4a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d4d:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80106d52:	85 c0                	test   %eax,%eax
80106d54:	75 02                	jne    80106d58 <uartputc+0x11>
    return;
80106d56:	eb 4b                	jmp    80106da3 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d5f:	eb 10                	jmp    80106d71 <uartputc+0x2a>
    microdelay(10);
80106d61:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d68:	e8 db c2 ff ff       	call   80103048 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d71:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d75:	7f 16                	jg     80106d8d <uartputc+0x46>
80106d77:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d7e:	e8 79 fe ff ff       	call   80106bfc <inb>
80106d83:	0f b6 c0             	movzbl %al,%eax
80106d86:	83 e0 20             	and    $0x20,%eax
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	74 d4                	je     80106d61 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d90:	0f b6 c0             	movzbl %al,%eax
80106d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d97:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d9e:	e8 76 fe ff ff       	call   80106c19 <outb>
}
80106da3:	c9                   	leave  
80106da4:	c3                   	ret    

80106da5 <uartgetc>:

static int
uartgetc(void)
{
80106da5:	55                   	push   %ebp
80106da6:	89 e5                	mov    %esp,%ebp
80106da8:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106dab:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80106db0:	85 c0                	test   %eax,%eax
80106db2:	75 07                	jne    80106dbb <uartgetc+0x16>
    return -1;
80106db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db9:	eb 2c                	jmp    80106de7 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106dbb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dc2:	e8 35 fe ff ff       	call   80106bfc <inb>
80106dc7:	0f b6 c0             	movzbl %al,%eax
80106dca:	83 e0 01             	and    $0x1,%eax
80106dcd:	85 c0                	test   %eax,%eax
80106dcf:	75 07                	jne    80106dd8 <uartgetc+0x33>
    return -1;
80106dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd6:	eb 0f                	jmp    80106de7 <uartgetc+0x42>
  return inb(COM1+0);
80106dd8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ddf:	e8 18 fe ff ff       	call   80106bfc <inb>
80106de4:	0f b6 c0             	movzbl %al,%eax
}
80106de7:	c9                   	leave  
80106de8:	c3                   	ret    

80106de9 <uartintr>:

void
uartintr(void)
{
80106de9:	55                   	push   %ebp
80106dea:	89 e5                	mov    %esp,%ebp
80106dec:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106def:	c7 04 24 a5 6d 10 80 	movl   $0x80106da5,(%esp)
80106df6:	e8 6a 9a ff ff       	call   80100865 <consoleintr>
}
80106dfb:	c9                   	leave  
80106dfc:	c3                   	ret    

80106dfd <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $0
80106dff:	6a 00                	push   $0x0
  jmp alltraps
80106e01:	e9 7e f9 ff ff       	jmp    80106784 <alltraps>

80106e06 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $1
80106e08:	6a 01                	push   $0x1
  jmp alltraps
80106e0a:	e9 75 f9 ff ff       	jmp    80106784 <alltraps>

80106e0f <vector2>:
.globl vector2
vector2:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $2
80106e11:	6a 02                	push   $0x2
  jmp alltraps
80106e13:	e9 6c f9 ff ff       	jmp    80106784 <alltraps>

80106e18 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $3
80106e1a:	6a 03                	push   $0x3
  jmp alltraps
80106e1c:	e9 63 f9 ff ff       	jmp    80106784 <alltraps>

80106e21 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $4
80106e23:	6a 04                	push   $0x4
  jmp alltraps
80106e25:	e9 5a f9 ff ff       	jmp    80106784 <alltraps>

80106e2a <vector5>:
.globl vector5
vector5:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $5
80106e2c:	6a 05                	push   $0x5
  jmp alltraps
80106e2e:	e9 51 f9 ff ff       	jmp    80106784 <alltraps>

80106e33 <vector6>:
.globl vector6
vector6:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $6
80106e35:	6a 06                	push   $0x6
  jmp alltraps
80106e37:	e9 48 f9 ff ff       	jmp    80106784 <alltraps>

80106e3c <vector7>:
.globl vector7
vector7:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $7
80106e3e:	6a 07                	push   $0x7
  jmp alltraps
80106e40:	e9 3f f9 ff ff       	jmp    80106784 <alltraps>

80106e45 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e45:	6a 08                	push   $0x8
  jmp alltraps
80106e47:	e9 38 f9 ff ff       	jmp    80106784 <alltraps>

80106e4c <vector9>:
.globl vector9
vector9:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $9
80106e4e:	6a 09                	push   $0x9
  jmp alltraps
80106e50:	e9 2f f9 ff ff       	jmp    80106784 <alltraps>

80106e55 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e55:	6a 0a                	push   $0xa
  jmp alltraps
80106e57:	e9 28 f9 ff ff       	jmp    80106784 <alltraps>

80106e5c <vector11>:
.globl vector11
vector11:
  pushl $11
80106e5c:	6a 0b                	push   $0xb
  jmp alltraps
80106e5e:	e9 21 f9 ff ff       	jmp    80106784 <alltraps>

80106e63 <vector12>:
.globl vector12
vector12:
  pushl $12
80106e63:	6a 0c                	push   $0xc
  jmp alltraps
80106e65:	e9 1a f9 ff ff       	jmp    80106784 <alltraps>

80106e6a <vector13>:
.globl vector13
vector13:
  pushl $13
80106e6a:	6a 0d                	push   $0xd
  jmp alltraps
80106e6c:	e9 13 f9 ff ff       	jmp    80106784 <alltraps>

80106e71 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e71:	6a 0e                	push   $0xe
  jmp alltraps
80106e73:	e9 0c f9 ff ff       	jmp    80106784 <alltraps>

80106e78 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $15
80106e7a:	6a 0f                	push   $0xf
  jmp alltraps
80106e7c:	e9 03 f9 ff ff       	jmp    80106784 <alltraps>

80106e81 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $16
80106e83:	6a 10                	push   $0x10
  jmp alltraps
80106e85:	e9 fa f8 ff ff       	jmp    80106784 <alltraps>

80106e8a <vector17>:
.globl vector17
vector17:
  pushl $17
80106e8a:	6a 11                	push   $0x11
  jmp alltraps
80106e8c:	e9 f3 f8 ff ff       	jmp    80106784 <alltraps>

80106e91 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $18
80106e93:	6a 12                	push   $0x12
  jmp alltraps
80106e95:	e9 ea f8 ff ff       	jmp    80106784 <alltraps>

80106e9a <vector19>:
.globl vector19
vector19:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $19
80106e9c:	6a 13                	push   $0x13
  jmp alltraps
80106e9e:	e9 e1 f8 ff ff       	jmp    80106784 <alltraps>

80106ea3 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $20
80106ea5:	6a 14                	push   $0x14
  jmp alltraps
80106ea7:	e9 d8 f8 ff ff       	jmp    80106784 <alltraps>

80106eac <vector21>:
.globl vector21
vector21:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $21
80106eae:	6a 15                	push   $0x15
  jmp alltraps
80106eb0:	e9 cf f8 ff ff       	jmp    80106784 <alltraps>

80106eb5 <vector22>:
.globl vector22
vector22:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $22
80106eb7:	6a 16                	push   $0x16
  jmp alltraps
80106eb9:	e9 c6 f8 ff ff       	jmp    80106784 <alltraps>

80106ebe <vector23>:
.globl vector23
vector23:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $23
80106ec0:	6a 17                	push   $0x17
  jmp alltraps
80106ec2:	e9 bd f8 ff ff       	jmp    80106784 <alltraps>

80106ec7 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $24
80106ec9:	6a 18                	push   $0x18
  jmp alltraps
80106ecb:	e9 b4 f8 ff ff       	jmp    80106784 <alltraps>

80106ed0 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $25
80106ed2:	6a 19                	push   $0x19
  jmp alltraps
80106ed4:	e9 ab f8 ff ff       	jmp    80106784 <alltraps>

80106ed9 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $26
80106edb:	6a 1a                	push   $0x1a
  jmp alltraps
80106edd:	e9 a2 f8 ff ff       	jmp    80106784 <alltraps>

80106ee2 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $27
80106ee4:	6a 1b                	push   $0x1b
  jmp alltraps
80106ee6:	e9 99 f8 ff ff       	jmp    80106784 <alltraps>

80106eeb <vector28>:
.globl vector28
vector28:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $28
80106eed:	6a 1c                	push   $0x1c
  jmp alltraps
80106eef:	e9 90 f8 ff ff       	jmp    80106784 <alltraps>

80106ef4 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $29
80106ef6:	6a 1d                	push   $0x1d
  jmp alltraps
80106ef8:	e9 87 f8 ff ff       	jmp    80106784 <alltraps>

80106efd <vector30>:
.globl vector30
vector30:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $30
80106eff:	6a 1e                	push   $0x1e
  jmp alltraps
80106f01:	e9 7e f8 ff ff       	jmp    80106784 <alltraps>

80106f06 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $31
80106f08:	6a 1f                	push   $0x1f
  jmp alltraps
80106f0a:	e9 75 f8 ff ff       	jmp    80106784 <alltraps>

80106f0f <vector32>:
.globl vector32
vector32:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $32
80106f11:	6a 20                	push   $0x20
  jmp alltraps
80106f13:	e9 6c f8 ff ff       	jmp    80106784 <alltraps>

80106f18 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $33
80106f1a:	6a 21                	push   $0x21
  jmp alltraps
80106f1c:	e9 63 f8 ff ff       	jmp    80106784 <alltraps>

80106f21 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $34
80106f23:	6a 22                	push   $0x22
  jmp alltraps
80106f25:	e9 5a f8 ff ff       	jmp    80106784 <alltraps>

80106f2a <vector35>:
.globl vector35
vector35:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $35
80106f2c:	6a 23                	push   $0x23
  jmp alltraps
80106f2e:	e9 51 f8 ff ff       	jmp    80106784 <alltraps>

80106f33 <vector36>:
.globl vector36
vector36:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $36
80106f35:	6a 24                	push   $0x24
  jmp alltraps
80106f37:	e9 48 f8 ff ff       	jmp    80106784 <alltraps>

80106f3c <vector37>:
.globl vector37
vector37:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $37
80106f3e:	6a 25                	push   $0x25
  jmp alltraps
80106f40:	e9 3f f8 ff ff       	jmp    80106784 <alltraps>

80106f45 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $38
80106f47:	6a 26                	push   $0x26
  jmp alltraps
80106f49:	e9 36 f8 ff ff       	jmp    80106784 <alltraps>

80106f4e <vector39>:
.globl vector39
vector39:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $39
80106f50:	6a 27                	push   $0x27
  jmp alltraps
80106f52:	e9 2d f8 ff ff       	jmp    80106784 <alltraps>

80106f57 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $40
80106f59:	6a 28                	push   $0x28
  jmp alltraps
80106f5b:	e9 24 f8 ff ff       	jmp    80106784 <alltraps>

80106f60 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $41
80106f62:	6a 29                	push   $0x29
  jmp alltraps
80106f64:	e9 1b f8 ff ff       	jmp    80106784 <alltraps>

80106f69 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $42
80106f6b:	6a 2a                	push   $0x2a
  jmp alltraps
80106f6d:	e9 12 f8 ff ff       	jmp    80106784 <alltraps>

80106f72 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $43
80106f74:	6a 2b                	push   $0x2b
  jmp alltraps
80106f76:	e9 09 f8 ff ff       	jmp    80106784 <alltraps>

80106f7b <vector44>:
.globl vector44
vector44:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $44
80106f7d:	6a 2c                	push   $0x2c
  jmp alltraps
80106f7f:	e9 00 f8 ff ff       	jmp    80106784 <alltraps>

80106f84 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $45
80106f86:	6a 2d                	push   $0x2d
  jmp alltraps
80106f88:	e9 f7 f7 ff ff       	jmp    80106784 <alltraps>

80106f8d <vector46>:
.globl vector46
vector46:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $46
80106f8f:	6a 2e                	push   $0x2e
  jmp alltraps
80106f91:	e9 ee f7 ff ff       	jmp    80106784 <alltraps>

80106f96 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $47
80106f98:	6a 2f                	push   $0x2f
  jmp alltraps
80106f9a:	e9 e5 f7 ff ff       	jmp    80106784 <alltraps>

80106f9f <vector48>:
.globl vector48
vector48:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $48
80106fa1:	6a 30                	push   $0x30
  jmp alltraps
80106fa3:	e9 dc f7 ff ff       	jmp    80106784 <alltraps>

80106fa8 <vector49>:
.globl vector49
vector49:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $49
80106faa:	6a 31                	push   $0x31
  jmp alltraps
80106fac:	e9 d3 f7 ff ff       	jmp    80106784 <alltraps>

80106fb1 <vector50>:
.globl vector50
vector50:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $50
80106fb3:	6a 32                	push   $0x32
  jmp alltraps
80106fb5:	e9 ca f7 ff ff       	jmp    80106784 <alltraps>

80106fba <vector51>:
.globl vector51
vector51:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $51
80106fbc:	6a 33                	push   $0x33
  jmp alltraps
80106fbe:	e9 c1 f7 ff ff       	jmp    80106784 <alltraps>

80106fc3 <vector52>:
.globl vector52
vector52:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $52
80106fc5:	6a 34                	push   $0x34
  jmp alltraps
80106fc7:	e9 b8 f7 ff ff       	jmp    80106784 <alltraps>

80106fcc <vector53>:
.globl vector53
vector53:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $53
80106fce:	6a 35                	push   $0x35
  jmp alltraps
80106fd0:	e9 af f7 ff ff       	jmp    80106784 <alltraps>

80106fd5 <vector54>:
.globl vector54
vector54:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $54
80106fd7:	6a 36                	push   $0x36
  jmp alltraps
80106fd9:	e9 a6 f7 ff ff       	jmp    80106784 <alltraps>

80106fde <vector55>:
.globl vector55
vector55:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $55
80106fe0:	6a 37                	push   $0x37
  jmp alltraps
80106fe2:	e9 9d f7 ff ff       	jmp    80106784 <alltraps>

80106fe7 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $56
80106fe9:	6a 38                	push   $0x38
  jmp alltraps
80106feb:	e9 94 f7 ff ff       	jmp    80106784 <alltraps>

80106ff0 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $57
80106ff2:	6a 39                	push   $0x39
  jmp alltraps
80106ff4:	e9 8b f7 ff ff       	jmp    80106784 <alltraps>

80106ff9 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $58
80106ffb:	6a 3a                	push   $0x3a
  jmp alltraps
80106ffd:	e9 82 f7 ff ff       	jmp    80106784 <alltraps>

80107002 <vector59>:
.globl vector59
vector59:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $59
80107004:	6a 3b                	push   $0x3b
  jmp alltraps
80107006:	e9 79 f7 ff ff       	jmp    80106784 <alltraps>

8010700b <vector60>:
.globl vector60
vector60:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $60
8010700d:	6a 3c                	push   $0x3c
  jmp alltraps
8010700f:	e9 70 f7 ff ff       	jmp    80106784 <alltraps>

80107014 <vector61>:
.globl vector61
vector61:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $61
80107016:	6a 3d                	push   $0x3d
  jmp alltraps
80107018:	e9 67 f7 ff ff       	jmp    80106784 <alltraps>

8010701d <vector62>:
.globl vector62
vector62:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $62
8010701f:	6a 3e                	push   $0x3e
  jmp alltraps
80107021:	e9 5e f7 ff ff       	jmp    80106784 <alltraps>

80107026 <vector63>:
.globl vector63
vector63:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $63
80107028:	6a 3f                	push   $0x3f
  jmp alltraps
8010702a:	e9 55 f7 ff ff       	jmp    80106784 <alltraps>

8010702f <vector64>:
.globl vector64
vector64:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $64
80107031:	6a 40                	push   $0x40
  jmp alltraps
80107033:	e9 4c f7 ff ff       	jmp    80106784 <alltraps>

80107038 <vector65>:
.globl vector65
vector65:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $65
8010703a:	6a 41                	push   $0x41
  jmp alltraps
8010703c:	e9 43 f7 ff ff       	jmp    80106784 <alltraps>

80107041 <vector66>:
.globl vector66
vector66:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $66
80107043:	6a 42                	push   $0x42
  jmp alltraps
80107045:	e9 3a f7 ff ff       	jmp    80106784 <alltraps>

8010704a <vector67>:
.globl vector67
vector67:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $67
8010704c:	6a 43                	push   $0x43
  jmp alltraps
8010704e:	e9 31 f7 ff ff       	jmp    80106784 <alltraps>

80107053 <vector68>:
.globl vector68
vector68:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $68
80107055:	6a 44                	push   $0x44
  jmp alltraps
80107057:	e9 28 f7 ff ff       	jmp    80106784 <alltraps>

8010705c <vector69>:
.globl vector69
vector69:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $69
8010705e:	6a 45                	push   $0x45
  jmp alltraps
80107060:	e9 1f f7 ff ff       	jmp    80106784 <alltraps>

80107065 <vector70>:
.globl vector70
vector70:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $70
80107067:	6a 46                	push   $0x46
  jmp alltraps
80107069:	e9 16 f7 ff ff       	jmp    80106784 <alltraps>

8010706e <vector71>:
.globl vector71
vector71:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $71
80107070:	6a 47                	push   $0x47
  jmp alltraps
80107072:	e9 0d f7 ff ff       	jmp    80106784 <alltraps>

80107077 <vector72>:
.globl vector72
vector72:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $72
80107079:	6a 48                	push   $0x48
  jmp alltraps
8010707b:	e9 04 f7 ff ff       	jmp    80106784 <alltraps>

80107080 <vector73>:
.globl vector73
vector73:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $73
80107082:	6a 49                	push   $0x49
  jmp alltraps
80107084:	e9 fb f6 ff ff       	jmp    80106784 <alltraps>

80107089 <vector74>:
.globl vector74
vector74:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $74
8010708b:	6a 4a                	push   $0x4a
  jmp alltraps
8010708d:	e9 f2 f6 ff ff       	jmp    80106784 <alltraps>

80107092 <vector75>:
.globl vector75
vector75:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $75
80107094:	6a 4b                	push   $0x4b
  jmp alltraps
80107096:	e9 e9 f6 ff ff       	jmp    80106784 <alltraps>

8010709b <vector76>:
.globl vector76
vector76:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $76
8010709d:	6a 4c                	push   $0x4c
  jmp alltraps
8010709f:	e9 e0 f6 ff ff       	jmp    80106784 <alltraps>

801070a4 <vector77>:
.globl vector77
vector77:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $77
801070a6:	6a 4d                	push   $0x4d
  jmp alltraps
801070a8:	e9 d7 f6 ff ff       	jmp    80106784 <alltraps>

801070ad <vector78>:
.globl vector78
vector78:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $78
801070af:	6a 4e                	push   $0x4e
  jmp alltraps
801070b1:	e9 ce f6 ff ff       	jmp    80106784 <alltraps>

801070b6 <vector79>:
.globl vector79
vector79:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $79
801070b8:	6a 4f                	push   $0x4f
  jmp alltraps
801070ba:	e9 c5 f6 ff ff       	jmp    80106784 <alltraps>

801070bf <vector80>:
.globl vector80
vector80:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $80
801070c1:	6a 50                	push   $0x50
  jmp alltraps
801070c3:	e9 bc f6 ff ff       	jmp    80106784 <alltraps>

801070c8 <vector81>:
.globl vector81
vector81:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $81
801070ca:	6a 51                	push   $0x51
  jmp alltraps
801070cc:	e9 b3 f6 ff ff       	jmp    80106784 <alltraps>

801070d1 <vector82>:
.globl vector82
vector82:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $82
801070d3:	6a 52                	push   $0x52
  jmp alltraps
801070d5:	e9 aa f6 ff ff       	jmp    80106784 <alltraps>

801070da <vector83>:
.globl vector83
vector83:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $83
801070dc:	6a 53                	push   $0x53
  jmp alltraps
801070de:	e9 a1 f6 ff ff       	jmp    80106784 <alltraps>

801070e3 <vector84>:
.globl vector84
vector84:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $84
801070e5:	6a 54                	push   $0x54
  jmp alltraps
801070e7:	e9 98 f6 ff ff       	jmp    80106784 <alltraps>

801070ec <vector85>:
.globl vector85
vector85:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $85
801070ee:	6a 55                	push   $0x55
  jmp alltraps
801070f0:	e9 8f f6 ff ff       	jmp    80106784 <alltraps>

801070f5 <vector86>:
.globl vector86
vector86:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $86
801070f7:	6a 56                	push   $0x56
  jmp alltraps
801070f9:	e9 86 f6 ff ff       	jmp    80106784 <alltraps>

801070fe <vector87>:
.globl vector87
vector87:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $87
80107100:	6a 57                	push   $0x57
  jmp alltraps
80107102:	e9 7d f6 ff ff       	jmp    80106784 <alltraps>

80107107 <vector88>:
.globl vector88
vector88:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $88
80107109:	6a 58                	push   $0x58
  jmp alltraps
8010710b:	e9 74 f6 ff ff       	jmp    80106784 <alltraps>

80107110 <vector89>:
.globl vector89
vector89:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $89
80107112:	6a 59                	push   $0x59
  jmp alltraps
80107114:	e9 6b f6 ff ff       	jmp    80106784 <alltraps>

80107119 <vector90>:
.globl vector90
vector90:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $90
8010711b:	6a 5a                	push   $0x5a
  jmp alltraps
8010711d:	e9 62 f6 ff ff       	jmp    80106784 <alltraps>

80107122 <vector91>:
.globl vector91
vector91:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $91
80107124:	6a 5b                	push   $0x5b
  jmp alltraps
80107126:	e9 59 f6 ff ff       	jmp    80106784 <alltraps>

8010712b <vector92>:
.globl vector92
vector92:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $92
8010712d:	6a 5c                	push   $0x5c
  jmp alltraps
8010712f:	e9 50 f6 ff ff       	jmp    80106784 <alltraps>

80107134 <vector93>:
.globl vector93
vector93:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $93
80107136:	6a 5d                	push   $0x5d
  jmp alltraps
80107138:	e9 47 f6 ff ff       	jmp    80106784 <alltraps>

8010713d <vector94>:
.globl vector94
vector94:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $94
8010713f:	6a 5e                	push   $0x5e
  jmp alltraps
80107141:	e9 3e f6 ff ff       	jmp    80106784 <alltraps>

80107146 <vector95>:
.globl vector95
vector95:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $95
80107148:	6a 5f                	push   $0x5f
  jmp alltraps
8010714a:	e9 35 f6 ff ff       	jmp    80106784 <alltraps>

8010714f <vector96>:
.globl vector96
vector96:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $96
80107151:	6a 60                	push   $0x60
  jmp alltraps
80107153:	e9 2c f6 ff ff       	jmp    80106784 <alltraps>

80107158 <vector97>:
.globl vector97
vector97:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $97
8010715a:	6a 61                	push   $0x61
  jmp alltraps
8010715c:	e9 23 f6 ff ff       	jmp    80106784 <alltraps>

80107161 <vector98>:
.globl vector98
vector98:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $98
80107163:	6a 62                	push   $0x62
  jmp alltraps
80107165:	e9 1a f6 ff ff       	jmp    80106784 <alltraps>

8010716a <vector99>:
.globl vector99
vector99:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $99
8010716c:	6a 63                	push   $0x63
  jmp alltraps
8010716e:	e9 11 f6 ff ff       	jmp    80106784 <alltraps>

80107173 <vector100>:
.globl vector100
vector100:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $100
80107175:	6a 64                	push   $0x64
  jmp alltraps
80107177:	e9 08 f6 ff ff       	jmp    80106784 <alltraps>

8010717c <vector101>:
.globl vector101
vector101:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $101
8010717e:	6a 65                	push   $0x65
  jmp alltraps
80107180:	e9 ff f5 ff ff       	jmp    80106784 <alltraps>

80107185 <vector102>:
.globl vector102
vector102:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $102
80107187:	6a 66                	push   $0x66
  jmp alltraps
80107189:	e9 f6 f5 ff ff       	jmp    80106784 <alltraps>

8010718e <vector103>:
.globl vector103
vector103:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $103
80107190:	6a 67                	push   $0x67
  jmp alltraps
80107192:	e9 ed f5 ff ff       	jmp    80106784 <alltraps>

80107197 <vector104>:
.globl vector104
vector104:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $104
80107199:	6a 68                	push   $0x68
  jmp alltraps
8010719b:	e9 e4 f5 ff ff       	jmp    80106784 <alltraps>

801071a0 <vector105>:
.globl vector105
vector105:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $105
801071a2:	6a 69                	push   $0x69
  jmp alltraps
801071a4:	e9 db f5 ff ff       	jmp    80106784 <alltraps>

801071a9 <vector106>:
.globl vector106
vector106:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $106
801071ab:	6a 6a                	push   $0x6a
  jmp alltraps
801071ad:	e9 d2 f5 ff ff       	jmp    80106784 <alltraps>

801071b2 <vector107>:
.globl vector107
vector107:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $107
801071b4:	6a 6b                	push   $0x6b
  jmp alltraps
801071b6:	e9 c9 f5 ff ff       	jmp    80106784 <alltraps>

801071bb <vector108>:
.globl vector108
vector108:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $108
801071bd:	6a 6c                	push   $0x6c
  jmp alltraps
801071bf:	e9 c0 f5 ff ff       	jmp    80106784 <alltraps>

801071c4 <vector109>:
.globl vector109
vector109:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $109
801071c6:	6a 6d                	push   $0x6d
  jmp alltraps
801071c8:	e9 b7 f5 ff ff       	jmp    80106784 <alltraps>

801071cd <vector110>:
.globl vector110
vector110:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $110
801071cf:	6a 6e                	push   $0x6e
  jmp alltraps
801071d1:	e9 ae f5 ff ff       	jmp    80106784 <alltraps>

801071d6 <vector111>:
.globl vector111
vector111:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $111
801071d8:	6a 6f                	push   $0x6f
  jmp alltraps
801071da:	e9 a5 f5 ff ff       	jmp    80106784 <alltraps>

801071df <vector112>:
.globl vector112
vector112:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $112
801071e1:	6a 70                	push   $0x70
  jmp alltraps
801071e3:	e9 9c f5 ff ff       	jmp    80106784 <alltraps>

801071e8 <vector113>:
.globl vector113
vector113:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $113
801071ea:	6a 71                	push   $0x71
  jmp alltraps
801071ec:	e9 93 f5 ff ff       	jmp    80106784 <alltraps>

801071f1 <vector114>:
.globl vector114
vector114:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $114
801071f3:	6a 72                	push   $0x72
  jmp alltraps
801071f5:	e9 8a f5 ff ff       	jmp    80106784 <alltraps>

801071fa <vector115>:
.globl vector115
vector115:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $115
801071fc:	6a 73                	push   $0x73
  jmp alltraps
801071fe:	e9 81 f5 ff ff       	jmp    80106784 <alltraps>

80107203 <vector116>:
.globl vector116
vector116:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $116
80107205:	6a 74                	push   $0x74
  jmp alltraps
80107207:	e9 78 f5 ff ff       	jmp    80106784 <alltraps>

8010720c <vector117>:
.globl vector117
vector117:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $117
8010720e:	6a 75                	push   $0x75
  jmp alltraps
80107210:	e9 6f f5 ff ff       	jmp    80106784 <alltraps>

80107215 <vector118>:
.globl vector118
vector118:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $118
80107217:	6a 76                	push   $0x76
  jmp alltraps
80107219:	e9 66 f5 ff ff       	jmp    80106784 <alltraps>

8010721e <vector119>:
.globl vector119
vector119:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $119
80107220:	6a 77                	push   $0x77
  jmp alltraps
80107222:	e9 5d f5 ff ff       	jmp    80106784 <alltraps>

80107227 <vector120>:
.globl vector120
vector120:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $120
80107229:	6a 78                	push   $0x78
  jmp alltraps
8010722b:	e9 54 f5 ff ff       	jmp    80106784 <alltraps>

80107230 <vector121>:
.globl vector121
vector121:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $121
80107232:	6a 79                	push   $0x79
  jmp alltraps
80107234:	e9 4b f5 ff ff       	jmp    80106784 <alltraps>

80107239 <vector122>:
.globl vector122
vector122:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $122
8010723b:	6a 7a                	push   $0x7a
  jmp alltraps
8010723d:	e9 42 f5 ff ff       	jmp    80106784 <alltraps>

80107242 <vector123>:
.globl vector123
vector123:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $123
80107244:	6a 7b                	push   $0x7b
  jmp alltraps
80107246:	e9 39 f5 ff ff       	jmp    80106784 <alltraps>

8010724b <vector124>:
.globl vector124
vector124:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $124
8010724d:	6a 7c                	push   $0x7c
  jmp alltraps
8010724f:	e9 30 f5 ff ff       	jmp    80106784 <alltraps>

80107254 <vector125>:
.globl vector125
vector125:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $125
80107256:	6a 7d                	push   $0x7d
  jmp alltraps
80107258:	e9 27 f5 ff ff       	jmp    80106784 <alltraps>

8010725d <vector126>:
.globl vector126
vector126:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $126
8010725f:	6a 7e                	push   $0x7e
  jmp alltraps
80107261:	e9 1e f5 ff ff       	jmp    80106784 <alltraps>

80107266 <vector127>:
.globl vector127
vector127:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $127
80107268:	6a 7f                	push   $0x7f
  jmp alltraps
8010726a:	e9 15 f5 ff ff       	jmp    80106784 <alltraps>

8010726f <vector128>:
.globl vector128
vector128:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $128
80107271:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107276:	e9 09 f5 ff ff       	jmp    80106784 <alltraps>

8010727b <vector129>:
.globl vector129
vector129:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $129
8010727d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107282:	e9 fd f4 ff ff       	jmp    80106784 <alltraps>

80107287 <vector130>:
.globl vector130
vector130:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $130
80107289:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010728e:	e9 f1 f4 ff ff       	jmp    80106784 <alltraps>

80107293 <vector131>:
.globl vector131
vector131:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $131
80107295:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010729a:	e9 e5 f4 ff ff       	jmp    80106784 <alltraps>

8010729f <vector132>:
.globl vector132
vector132:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $132
801072a1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072a6:	e9 d9 f4 ff ff       	jmp    80106784 <alltraps>

801072ab <vector133>:
.globl vector133
vector133:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $133
801072ad:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072b2:	e9 cd f4 ff ff       	jmp    80106784 <alltraps>

801072b7 <vector134>:
.globl vector134
vector134:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $134
801072b9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072be:	e9 c1 f4 ff ff       	jmp    80106784 <alltraps>

801072c3 <vector135>:
.globl vector135
vector135:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $135
801072c5:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072ca:	e9 b5 f4 ff ff       	jmp    80106784 <alltraps>

801072cf <vector136>:
.globl vector136
vector136:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $136
801072d1:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072d6:	e9 a9 f4 ff ff       	jmp    80106784 <alltraps>

801072db <vector137>:
.globl vector137
vector137:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $137
801072dd:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072e2:	e9 9d f4 ff ff       	jmp    80106784 <alltraps>

801072e7 <vector138>:
.globl vector138
vector138:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $138
801072e9:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072ee:	e9 91 f4 ff ff       	jmp    80106784 <alltraps>

801072f3 <vector139>:
.globl vector139
vector139:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $139
801072f5:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072fa:	e9 85 f4 ff ff       	jmp    80106784 <alltraps>

801072ff <vector140>:
.globl vector140
vector140:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $140
80107301:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107306:	e9 79 f4 ff ff       	jmp    80106784 <alltraps>

8010730b <vector141>:
.globl vector141
vector141:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $141
8010730d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107312:	e9 6d f4 ff ff       	jmp    80106784 <alltraps>

80107317 <vector142>:
.globl vector142
vector142:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $142
80107319:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010731e:	e9 61 f4 ff ff       	jmp    80106784 <alltraps>

80107323 <vector143>:
.globl vector143
vector143:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $143
80107325:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010732a:	e9 55 f4 ff ff       	jmp    80106784 <alltraps>

8010732f <vector144>:
.globl vector144
vector144:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $144
80107331:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107336:	e9 49 f4 ff ff       	jmp    80106784 <alltraps>

8010733b <vector145>:
.globl vector145
vector145:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $145
8010733d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107342:	e9 3d f4 ff ff       	jmp    80106784 <alltraps>

80107347 <vector146>:
.globl vector146
vector146:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $146
80107349:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010734e:	e9 31 f4 ff ff       	jmp    80106784 <alltraps>

80107353 <vector147>:
.globl vector147
vector147:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $147
80107355:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010735a:	e9 25 f4 ff ff       	jmp    80106784 <alltraps>

8010735f <vector148>:
.globl vector148
vector148:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $148
80107361:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107366:	e9 19 f4 ff ff       	jmp    80106784 <alltraps>

8010736b <vector149>:
.globl vector149
vector149:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $149
8010736d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107372:	e9 0d f4 ff ff       	jmp    80106784 <alltraps>

80107377 <vector150>:
.globl vector150
vector150:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $150
80107379:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010737e:	e9 01 f4 ff ff       	jmp    80106784 <alltraps>

80107383 <vector151>:
.globl vector151
vector151:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $151
80107385:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010738a:	e9 f5 f3 ff ff       	jmp    80106784 <alltraps>

8010738f <vector152>:
.globl vector152
vector152:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $152
80107391:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107396:	e9 e9 f3 ff ff       	jmp    80106784 <alltraps>

8010739b <vector153>:
.globl vector153
vector153:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $153
8010739d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073a2:	e9 dd f3 ff ff       	jmp    80106784 <alltraps>

801073a7 <vector154>:
.globl vector154
vector154:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $154
801073a9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073ae:	e9 d1 f3 ff ff       	jmp    80106784 <alltraps>

801073b3 <vector155>:
.globl vector155
vector155:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $155
801073b5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073ba:	e9 c5 f3 ff ff       	jmp    80106784 <alltraps>

801073bf <vector156>:
.globl vector156
vector156:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $156
801073c1:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073c6:	e9 b9 f3 ff ff       	jmp    80106784 <alltraps>

801073cb <vector157>:
.globl vector157
vector157:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $157
801073cd:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073d2:	e9 ad f3 ff ff       	jmp    80106784 <alltraps>

801073d7 <vector158>:
.globl vector158
vector158:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $158
801073d9:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073de:	e9 a1 f3 ff ff       	jmp    80106784 <alltraps>

801073e3 <vector159>:
.globl vector159
vector159:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $159
801073e5:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073ea:	e9 95 f3 ff ff       	jmp    80106784 <alltraps>

801073ef <vector160>:
.globl vector160
vector160:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $160
801073f1:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073f6:	e9 89 f3 ff ff       	jmp    80106784 <alltraps>

801073fb <vector161>:
.globl vector161
vector161:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $161
801073fd:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107402:	e9 7d f3 ff ff       	jmp    80106784 <alltraps>

80107407 <vector162>:
.globl vector162
vector162:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $162
80107409:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010740e:	e9 71 f3 ff ff       	jmp    80106784 <alltraps>

80107413 <vector163>:
.globl vector163
vector163:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $163
80107415:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010741a:	e9 65 f3 ff ff       	jmp    80106784 <alltraps>

8010741f <vector164>:
.globl vector164
vector164:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $164
80107421:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107426:	e9 59 f3 ff ff       	jmp    80106784 <alltraps>

8010742b <vector165>:
.globl vector165
vector165:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $165
8010742d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107432:	e9 4d f3 ff ff       	jmp    80106784 <alltraps>

80107437 <vector166>:
.globl vector166
vector166:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $166
80107439:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010743e:	e9 41 f3 ff ff       	jmp    80106784 <alltraps>

80107443 <vector167>:
.globl vector167
vector167:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $167
80107445:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010744a:	e9 35 f3 ff ff       	jmp    80106784 <alltraps>

8010744f <vector168>:
.globl vector168
vector168:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $168
80107451:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107456:	e9 29 f3 ff ff       	jmp    80106784 <alltraps>

8010745b <vector169>:
.globl vector169
vector169:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $169
8010745d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107462:	e9 1d f3 ff ff       	jmp    80106784 <alltraps>

80107467 <vector170>:
.globl vector170
vector170:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $170
80107469:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010746e:	e9 11 f3 ff ff       	jmp    80106784 <alltraps>

80107473 <vector171>:
.globl vector171
vector171:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $171
80107475:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010747a:	e9 05 f3 ff ff       	jmp    80106784 <alltraps>

8010747f <vector172>:
.globl vector172
vector172:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $172
80107481:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107486:	e9 f9 f2 ff ff       	jmp    80106784 <alltraps>

8010748b <vector173>:
.globl vector173
vector173:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $173
8010748d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107492:	e9 ed f2 ff ff       	jmp    80106784 <alltraps>

80107497 <vector174>:
.globl vector174
vector174:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $174
80107499:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010749e:	e9 e1 f2 ff ff       	jmp    80106784 <alltraps>

801074a3 <vector175>:
.globl vector175
vector175:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $175
801074a5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074aa:	e9 d5 f2 ff ff       	jmp    80106784 <alltraps>

801074af <vector176>:
.globl vector176
vector176:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $176
801074b1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074b6:	e9 c9 f2 ff ff       	jmp    80106784 <alltraps>

801074bb <vector177>:
.globl vector177
vector177:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $177
801074bd:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074c2:	e9 bd f2 ff ff       	jmp    80106784 <alltraps>

801074c7 <vector178>:
.globl vector178
vector178:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $178
801074c9:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074ce:	e9 b1 f2 ff ff       	jmp    80106784 <alltraps>

801074d3 <vector179>:
.globl vector179
vector179:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $179
801074d5:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074da:	e9 a5 f2 ff ff       	jmp    80106784 <alltraps>

801074df <vector180>:
.globl vector180
vector180:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $180
801074e1:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074e6:	e9 99 f2 ff ff       	jmp    80106784 <alltraps>

801074eb <vector181>:
.globl vector181
vector181:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $181
801074ed:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074f2:	e9 8d f2 ff ff       	jmp    80106784 <alltraps>

801074f7 <vector182>:
.globl vector182
vector182:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $182
801074f9:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074fe:	e9 81 f2 ff ff       	jmp    80106784 <alltraps>

80107503 <vector183>:
.globl vector183
vector183:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $183
80107505:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010750a:	e9 75 f2 ff ff       	jmp    80106784 <alltraps>

8010750f <vector184>:
.globl vector184
vector184:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $184
80107511:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107516:	e9 69 f2 ff ff       	jmp    80106784 <alltraps>

8010751b <vector185>:
.globl vector185
vector185:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $185
8010751d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107522:	e9 5d f2 ff ff       	jmp    80106784 <alltraps>

80107527 <vector186>:
.globl vector186
vector186:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $186
80107529:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010752e:	e9 51 f2 ff ff       	jmp    80106784 <alltraps>

80107533 <vector187>:
.globl vector187
vector187:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $187
80107535:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010753a:	e9 45 f2 ff ff       	jmp    80106784 <alltraps>

8010753f <vector188>:
.globl vector188
vector188:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $188
80107541:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107546:	e9 39 f2 ff ff       	jmp    80106784 <alltraps>

8010754b <vector189>:
.globl vector189
vector189:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $189
8010754d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107552:	e9 2d f2 ff ff       	jmp    80106784 <alltraps>

80107557 <vector190>:
.globl vector190
vector190:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $190
80107559:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010755e:	e9 21 f2 ff ff       	jmp    80106784 <alltraps>

80107563 <vector191>:
.globl vector191
vector191:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $191
80107565:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010756a:	e9 15 f2 ff ff       	jmp    80106784 <alltraps>

8010756f <vector192>:
.globl vector192
vector192:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $192
80107571:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107576:	e9 09 f2 ff ff       	jmp    80106784 <alltraps>

8010757b <vector193>:
.globl vector193
vector193:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $193
8010757d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107582:	e9 fd f1 ff ff       	jmp    80106784 <alltraps>

80107587 <vector194>:
.globl vector194
vector194:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $194
80107589:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010758e:	e9 f1 f1 ff ff       	jmp    80106784 <alltraps>

80107593 <vector195>:
.globl vector195
vector195:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $195
80107595:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010759a:	e9 e5 f1 ff ff       	jmp    80106784 <alltraps>

8010759f <vector196>:
.globl vector196
vector196:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $196
801075a1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075a6:	e9 d9 f1 ff ff       	jmp    80106784 <alltraps>

801075ab <vector197>:
.globl vector197
vector197:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $197
801075ad:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075b2:	e9 cd f1 ff ff       	jmp    80106784 <alltraps>

801075b7 <vector198>:
.globl vector198
vector198:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $198
801075b9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075be:	e9 c1 f1 ff ff       	jmp    80106784 <alltraps>

801075c3 <vector199>:
.globl vector199
vector199:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $199
801075c5:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075ca:	e9 b5 f1 ff ff       	jmp    80106784 <alltraps>

801075cf <vector200>:
.globl vector200
vector200:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $200
801075d1:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075d6:	e9 a9 f1 ff ff       	jmp    80106784 <alltraps>

801075db <vector201>:
.globl vector201
vector201:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $201
801075dd:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075e2:	e9 9d f1 ff ff       	jmp    80106784 <alltraps>

801075e7 <vector202>:
.globl vector202
vector202:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $202
801075e9:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075ee:	e9 91 f1 ff ff       	jmp    80106784 <alltraps>

801075f3 <vector203>:
.globl vector203
vector203:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $203
801075f5:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075fa:	e9 85 f1 ff ff       	jmp    80106784 <alltraps>

801075ff <vector204>:
.globl vector204
vector204:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $204
80107601:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107606:	e9 79 f1 ff ff       	jmp    80106784 <alltraps>

8010760b <vector205>:
.globl vector205
vector205:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $205
8010760d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107612:	e9 6d f1 ff ff       	jmp    80106784 <alltraps>

80107617 <vector206>:
.globl vector206
vector206:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $206
80107619:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010761e:	e9 61 f1 ff ff       	jmp    80106784 <alltraps>

80107623 <vector207>:
.globl vector207
vector207:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $207
80107625:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010762a:	e9 55 f1 ff ff       	jmp    80106784 <alltraps>

8010762f <vector208>:
.globl vector208
vector208:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $208
80107631:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107636:	e9 49 f1 ff ff       	jmp    80106784 <alltraps>

8010763b <vector209>:
.globl vector209
vector209:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $209
8010763d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107642:	e9 3d f1 ff ff       	jmp    80106784 <alltraps>

80107647 <vector210>:
.globl vector210
vector210:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $210
80107649:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010764e:	e9 31 f1 ff ff       	jmp    80106784 <alltraps>

80107653 <vector211>:
.globl vector211
vector211:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $211
80107655:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010765a:	e9 25 f1 ff ff       	jmp    80106784 <alltraps>

8010765f <vector212>:
.globl vector212
vector212:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $212
80107661:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107666:	e9 19 f1 ff ff       	jmp    80106784 <alltraps>

8010766b <vector213>:
.globl vector213
vector213:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $213
8010766d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107672:	e9 0d f1 ff ff       	jmp    80106784 <alltraps>

80107677 <vector214>:
.globl vector214
vector214:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $214
80107679:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010767e:	e9 01 f1 ff ff       	jmp    80106784 <alltraps>

80107683 <vector215>:
.globl vector215
vector215:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $215
80107685:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010768a:	e9 f5 f0 ff ff       	jmp    80106784 <alltraps>

8010768f <vector216>:
.globl vector216
vector216:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $216
80107691:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107696:	e9 e9 f0 ff ff       	jmp    80106784 <alltraps>

8010769b <vector217>:
.globl vector217
vector217:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $217
8010769d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076a2:	e9 dd f0 ff ff       	jmp    80106784 <alltraps>

801076a7 <vector218>:
.globl vector218
vector218:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $218
801076a9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076ae:	e9 d1 f0 ff ff       	jmp    80106784 <alltraps>

801076b3 <vector219>:
.globl vector219
vector219:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $219
801076b5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076ba:	e9 c5 f0 ff ff       	jmp    80106784 <alltraps>

801076bf <vector220>:
.globl vector220
vector220:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $220
801076c1:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076c6:	e9 b9 f0 ff ff       	jmp    80106784 <alltraps>

801076cb <vector221>:
.globl vector221
vector221:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $221
801076cd:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076d2:	e9 ad f0 ff ff       	jmp    80106784 <alltraps>

801076d7 <vector222>:
.globl vector222
vector222:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $222
801076d9:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076de:	e9 a1 f0 ff ff       	jmp    80106784 <alltraps>

801076e3 <vector223>:
.globl vector223
vector223:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $223
801076e5:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076ea:	e9 95 f0 ff ff       	jmp    80106784 <alltraps>

801076ef <vector224>:
.globl vector224
vector224:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $224
801076f1:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076f6:	e9 89 f0 ff ff       	jmp    80106784 <alltraps>

801076fb <vector225>:
.globl vector225
vector225:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $225
801076fd:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107702:	e9 7d f0 ff ff       	jmp    80106784 <alltraps>

80107707 <vector226>:
.globl vector226
vector226:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $226
80107709:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010770e:	e9 71 f0 ff ff       	jmp    80106784 <alltraps>

80107713 <vector227>:
.globl vector227
vector227:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $227
80107715:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010771a:	e9 65 f0 ff ff       	jmp    80106784 <alltraps>

8010771f <vector228>:
.globl vector228
vector228:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $228
80107721:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107726:	e9 59 f0 ff ff       	jmp    80106784 <alltraps>

8010772b <vector229>:
.globl vector229
vector229:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $229
8010772d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107732:	e9 4d f0 ff ff       	jmp    80106784 <alltraps>

80107737 <vector230>:
.globl vector230
vector230:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $230
80107739:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010773e:	e9 41 f0 ff ff       	jmp    80106784 <alltraps>

80107743 <vector231>:
.globl vector231
vector231:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $231
80107745:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010774a:	e9 35 f0 ff ff       	jmp    80106784 <alltraps>

8010774f <vector232>:
.globl vector232
vector232:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $232
80107751:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107756:	e9 29 f0 ff ff       	jmp    80106784 <alltraps>

8010775b <vector233>:
.globl vector233
vector233:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $233
8010775d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107762:	e9 1d f0 ff ff       	jmp    80106784 <alltraps>

80107767 <vector234>:
.globl vector234
vector234:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $234
80107769:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010776e:	e9 11 f0 ff ff       	jmp    80106784 <alltraps>

80107773 <vector235>:
.globl vector235
vector235:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $235
80107775:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010777a:	e9 05 f0 ff ff       	jmp    80106784 <alltraps>

8010777f <vector236>:
.globl vector236
vector236:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $236
80107781:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107786:	e9 f9 ef ff ff       	jmp    80106784 <alltraps>

8010778b <vector237>:
.globl vector237
vector237:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $237
8010778d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107792:	e9 ed ef ff ff       	jmp    80106784 <alltraps>

80107797 <vector238>:
.globl vector238
vector238:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $238
80107799:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010779e:	e9 e1 ef ff ff       	jmp    80106784 <alltraps>

801077a3 <vector239>:
.globl vector239
vector239:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $239
801077a5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077aa:	e9 d5 ef ff ff       	jmp    80106784 <alltraps>

801077af <vector240>:
.globl vector240
vector240:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $240
801077b1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077b6:	e9 c9 ef ff ff       	jmp    80106784 <alltraps>

801077bb <vector241>:
.globl vector241
vector241:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $241
801077bd:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077c2:	e9 bd ef ff ff       	jmp    80106784 <alltraps>

801077c7 <vector242>:
.globl vector242
vector242:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $242
801077c9:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077ce:	e9 b1 ef ff ff       	jmp    80106784 <alltraps>

801077d3 <vector243>:
.globl vector243
vector243:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $243
801077d5:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077da:	e9 a5 ef ff ff       	jmp    80106784 <alltraps>

801077df <vector244>:
.globl vector244
vector244:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $244
801077e1:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077e6:	e9 99 ef ff ff       	jmp    80106784 <alltraps>

801077eb <vector245>:
.globl vector245
vector245:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $245
801077ed:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077f2:	e9 8d ef ff ff       	jmp    80106784 <alltraps>

801077f7 <vector246>:
.globl vector246
vector246:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $246
801077f9:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077fe:	e9 81 ef ff ff       	jmp    80106784 <alltraps>

80107803 <vector247>:
.globl vector247
vector247:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $247
80107805:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010780a:	e9 75 ef ff ff       	jmp    80106784 <alltraps>

8010780f <vector248>:
.globl vector248
vector248:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $248
80107811:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107816:	e9 69 ef ff ff       	jmp    80106784 <alltraps>

8010781b <vector249>:
.globl vector249
vector249:
  pushl $0
8010781b:	6a 00                	push   $0x0
  pushl $249
8010781d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107822:	e9 5d ef ff ff       	jmp    80106784 <alltraps>

80107827 <vector250>:
.globl vector250
vector250:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $250
80107829:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010782e:	e9 51 ef ff ff       	jmp    80106784 <alltraps>

80107833 <vector251>:
.globl vector251
vector251:
  pushl $0
80107833:	6a 00                	push   $0x0
  pushl $251
80107835:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010783a:	e9 45 ef ff ff       	jmp    80106784 <alltraps>

8010783f <vector252>:
.globl vector252
vector252:
  pushl $0
8010783f:	6a 00                	push   $0x0
  pushl $252
80107841:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107846:	e9 39 ef ff ff       	jmp    80106784 <alltraps>

8010784b <vector253>:
.globl vector253
vector253:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $253
8010784d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107852:	e9 2d ef ff ff       	jmp    80106784 <alltraps>

80107857 <vector254>:
.globl vector254
vector254:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $254
80107859:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010785e:	e9 21 ef ff ff       	jmp    80106784 <alltraps>

80107863 <vector255>:
.globl vector255
vector255:
  pushl $0
80107863:	6a 00                	push   $0x0
  pushl $255
80107865:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010786a:	e9 15 ef ff ff       	jmp    80106784 <alltraps>

8010786f <sgenrand>:
static int mti=N+1; /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void
sgenrand(unsigned long seed)
{
8010786f:	55                   	push   %ebp
80107870:	89 e5                	mov    %esp,%ebp
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0]= seed & 0xffffffff;
80107872:	8b 45 08             	mov    0x8(%ebp),%eax
80107875:	a3 80 c6 10 80       	mov    %eax,0x8010c680
    for (mti=1; mti<N; mti++)
8010787a:	c7 05 a0 c4 10 80 01 	movl   $0x1,0x8010c4a0
80107881:	00 00 00 
80107884:	eb 2f                	jmp    801078b5 <sgenrand+0x46>
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
80107886:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
8010788b:	8b 15 a0 c4 10 80    	mov    0x8010c4a0,%edx
80107891:	83 ea 01             	sub    $0x1,%edx
80107894:	8b 14 95 80 c6 10 80 	mov    -0x7fef3980(,%edx,4),%edx
8010789b:	69 d2 cd 0d 01 00    	imul   $0x10dcd,%edx,%edx
801078a1:	89 14 85 80 c6 10 80 	mov    %edx,-0x7fef3980(,%eax,4)
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0]= seed & 0xffffffff;
    for (mti=1; mti<N; mti++)
801078a8:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
801078ad:	83 c0 01             	add    $0x1,%eax
801078b0:	a3 a0 c4 10 80       	mov    %eax,0x8010c4a0
801078b5:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
801078ba:	3d 6f 02 00 00       	cmp    $0x26f,%eax
801078bf:	7e c5                	jle    80107886 <sgenrand+0x17>
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
}
801078c1:	5d                   	pop    %ebp
801078c2:	c3                   	ret    

801078c3 <genrand>:

long /* for integer generation */
genrand()
{
801078c3:	55                   	push   %ebp
801078c4:	89 e5                	mov    %esp,%ebp
801078c6:	83 ec 14             	sub    $0x14,%esp
    unsigned long y;
    static unsigned long mag01[2]={0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N) { /* generate N words at one time */
801078c9:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
801078ce:	3d 6f 02 00 00       	cmp    $0x26f,%eax
801078d3:	0f 8e 30 01 00 00    	jle    80107a09 <genrand+0x146>
        int kk;

        if (mti == N+1)   /* if sgenrand() has not been called, */
801078d9:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
801078de:	3d 71 02 00 00       	cmp    $0x271,%eax
801078e3:	75 0c                	jne    801078f1 <genrand+0x2e>
            sgenrand(4357); /* a default initial seed is used   */
801078e5:	c7 04 24 05 11 00 00 	movl   $0x1105,(%esp)
801078ec:	e8 7e ff ff ff       	call   8010786f <sgenrand>

        for (kk=0;kk<N-M;kk++) {
801078f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801078f8:	eb 5b                	jmp    80107955 <genrand+0x92>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
801078fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801078fd:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
80107904:	25 00 00 00 80       	and    $0x80000000,%eax
80107909:	89 c2                	mov    %eax,%edx
8010790b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010790e:	83 c0 01             	add    $0x1,%eax
80107911:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
80107918:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
8010791d:	09 d0                	or     %edx,%eax
8010791f:	89 45 f8             	mov    %eax,-0x8(%ebp)
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
80107922:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107925:	05 8d 01 00 00       	add    $0x18d,%eax
8010792a:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
80107931:	8b 55 f8             	mov    -0x8(%ebp),%edx
80107934:	d1 ea                	shr    %edx
80107936:	31 c2                	xor    %eax,%edx
80107938:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010793b:	83 e0 01             	and    $0x1,%eax
8010793e:	8b 04 85 a4 c4 10 80 	mov    -0x7fef3b5c(,%eax,4),%eax
80107945:	31 c2                	xor    %eax,%edx
80107947:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010794a:	89 14 85 80 c6 10 80 	mov    %edx,-0x7fef3980(,%eax,4)
        int kk;

        if (mti == N+1)   /* if sgenrand() has not been called, */
            sgenrand(4357); /* a default initial seed is used   */

        for (kk=0;kk<N-M;kk++) {
80107951:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107955:	81 7d fc e2 00 00 00 	cmpl   $0xe2,-0x4(%ebp)
8010795c:	7e 9c                	jle    801078fa <genrand+0x37>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        for (;kk<N-1;kk++) {
8010795e:	eb 5b                	jmp    801079bb <genrand+0xf8>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
80107960:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107963:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
8010796a:	25 00 00 00 80       	and    $0x80000000,%eax
8010796f:	89 c2                	mov    %eax,%edx
80107971:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107974:	83 c0 01             	add    $0x1,%eax
80107977:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
8010797e:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
80107983:	09 d0                	or     %edx,%eax
80107985:	89 45 f8             	mov    %eax,-0x8(%ebp)
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
80107988:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010798b:	2d e3 00 00 00       	sub    $0xe3,%eax
80107990:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
80107997:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010799a:	d1 ea                	shr    %edx
8010799c:	31 c2                	xor    %eax,%edx
8010799e:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079a1:	83 e0 01             	and    $0x1,%eax
801079a4:	8b 04 85 a4 c4 10 80 	mov    -0x7fef3b5c(,%eax,4),%eax
801079ab:	31 c2                	xor    %eax,%edx
801079ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801079b0:	89 14 85 80 c6 10 80 	mov    %edx,-0x7fef3980(,%eax,4)

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        for (;kk<N-1;kk++) {
801079b7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801079bb:	81 7d fc 6e 02 00 00 	cmpl   $0x26e,-0x4(%ebp)
801079c2:	7e 9c                	jle    80107960 <genrand+0x9d>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
801079c4:	a1 3c d0 10 80       	mov    0x8010d03c,%eax
801079c9:	25 00 00 00 80       	and    $0x80000000,%eax
801079ce:	89 c2                	mov    %eax,%edx
801079d0:	a1 80 c6 10 80       	mov    0x8010c680,%eax
801079d5:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
801079da:	09 d0                	or     %edx,%eax
801079dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1];
801079df:	a1 b0 cc 10 80       	mov    0x8010ccb0,%eax
801079e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
801079e7:	d1 ea                	shr    %edx
801079e9:	31 c2                	xor    %eax,%edx
801079eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079ee:	83 e0 01             	and    $0x1,%eax
801079f1:	8b 04 85 a4 c4 10 80 	mov    -0x7fef3b5c(,%eax,4),%eax
801079f8:	31 d0                	xor    %edx,%eax
801079fa:	a3 3c d0 10 80       	mov    %eax,0x8010d03c

        mti = 0;
801079ff:	c7 05 a0 c4 10 80 00 	movl   $0x0,0x8010c4a0
80107a06:	00 00 00 
    }
  
    y = mt[mti++];
80107a09:	a1 a0 c4 10 80       	mov    0x8010c4a0,%eax
80107a0e:	8d 50 01             	lea    0x1(%eax),%edx
80107a11:	89 15 a0 c4 10 80    	mov    %edx,0x8010c4a0
80107a17:	8b 04 85 80 c6 10 80 	mov    -0x7fef3980(,%eax,4),%eax
80107a1e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_U(y);
80107a21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a24:	c1 e8 0b             	shr    $0xb,%eax
80107a27:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
80107a2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a2d:	c1 e0 07             	shl    $0x7,%eax
80107a30:	25 80 56 2c 9d       	and    $0x9d2c5680,%eax
80107a35:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
80107a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a3b:	c1 e0 0f             	shl    $0xf,%eax
80107a3e:	25 00 00 c6 ef       	and    $0xefc60000,%eax
80107a43:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_L(y);
80107a46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a49:	c1 e8 12             	shr    $0x12,%eax
80107a4c:	31 45 f8             	xor    %eax,-0x8(%ebp)

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
80107a4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a52:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
80107a57:	c9                   	leave  
80107a58:	c3                   	ret    

80107a59 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max) {
80107a59:	55                   	push   %ebp
80107a5a:	89 e5                	mov    %esp,%ebp
80107a5c:	83 ec 20             	sub    $0x20,%esp
  unsigned long
    // max <= RAND_MAX < ULONG_MAX, so this is okay.
    num_bins = (unsigned long) max + 1,
80107a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a62:	83 c0 01             	add    $0x1,%eax
80107a65:	89 45 fc             	mov    %eax,-0x4(%ebp)
    num_rand = (unsigned long) RAND_MAX + 1,
80107a68:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
    bin_size = num_rand / num_bins,
80107a6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a72:	ba 00 00 00 00       	mov    $0x0,%edx
80107a77:	f7 75 fc             	divl   -0x4(%ebp)
80107a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    defect   = num_rand % num_bins;
80107a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a80:	ba 00 00 00 00       	mov    $0x0,%edx
80107a85:	f7 75 fc             	divl   -0x4(%ebp)
80107a88:	89 55 f0             	mov    %edx,-0x10(%ebp)

  long x;
  do {
   x = genrand();
80107a8b:	e8 33 fe ff ff       	call   801078c3 <genrand>
80107a90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }
  // This is carefully written not to overflow
  while (num_rand - defect <= (unsigned long)x);
80107a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a96:	8b 55 f8             	mov    -0x8(%ebp),%edx
80107a99:	29 c2                	sub    %eax,%edx
80107a9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a9e:	39 c2                	cmp    %eax,%edx
80107aa0:	76 e9                	jbe    80107a8b <random_at_most+0x32>

  // Truncated division is intentional
  return x/bin_size;
80107aa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aa5:	ba 00 00 00 00       	mov    $0x0,%edx
80107aaa:	f7 75 f4             	divl   -0xc(%ebp)
}
80107aad:	c9                   	leave  
80107aae:	c3                   	ret    

80107aaf <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107aaf:	55                   	push   %ebp
80107ab0:	89 e5                	mov    %esp,%ebp
80107ab2:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ab8:	83 e8 01             	sub    $0x1,%eax
80107abb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107abf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac9:	c1 e8 10             	shr    $0x10,%eax
80107acc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107ad0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107ad3:	0f 01 10             	lgdtl  (%eax)
}
80107ad6:	c9                   	leave  
80107ad7:	c3                   	ret    

80107ad8 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107ad8:	55                   	push   %ebp
80107ad9:	89 e5                	mov    %esp,%ebp
80107adb:	83 ec 04             	sub    $0x4,%esp
80107ade:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ae5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ae9:	0f 00 d8             	ltr    %ax
}
80107aec:	c9                   	leave  
80107aed:	c3                   	ret    

80107aee <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107aee:	55                   	push   %ebp
80107aef:	89 e5                	mov    %esp,%ebp
80107af1:	83 ec 04             	sub    $0x4,%esp
80107af4:	8b 45 08             	mov    0x8(%ebp),%eax
80107af7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107afb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107aff:	8e e8                	mov    %eax,%gs
}
80107b01:	c9                   	leave  
80107b02:	c3                   	ret    

80107b03 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107b03:	55                   	push   %ebp
80107b04:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b06:	8b 45 08             	mov    0x8(%ebp),%eax
80107b09:	0f 22 d8             	mov    %eax,%cr3
}
80107b0c:	5d                   	pop    %ebp
80107b0d:	c3                   	ret    

80107b0e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107b0e:	55                   	push   %ebp
80107b0f:	89 e5                	mov    %esp,%ebp
80107b11:	8b 45 08             	mov    0x8(%ebp),%eax
80107b14:	05 00 00 00 80       	add    $0x80000000,%eax
80107b19:	5d                   	pop    %ebp
80107b1a:	c3                   	ret    

80107b1b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107b1b:	55                   	push   %ebp
80107b1c:	89 e5                	mov    %esp,%ebp
80107b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b21:	05 00 00 00 80       	add    $0x80000000,%eax
80107b26:	5d                   	pop    %ebp
80107b27:	c3                   	ret    

80107b28 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b28:	55                   	push   %ebp
80107b29:	89 e5                	mov    %esp,%ebp
80107b2b:	53                   	push   %ebx
80107b2c:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107b2f:	e8 97 b4 ff ff       	call   80102fcb <cpunum>
80107b34:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107b3a:	05 40 3d 11 80       	add    $0x80113d40,%eax
80107b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b45:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b62:	83 e2 f0             	and    $0xfffffff0,%edx
80107b65:	83 ca 0a             	or     $0xa,%edx
80107b68:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b72:	83 ca 10             	or     $0x10,%edx
80107b75:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b7f:	83 e2 9f             	and    $0xffffff9f,%edx
80107b82:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b8c:	83 ca 80             	or     $0xffffff80,%edx
80107b8f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b99:	83 ca 0f             	or     $0xf,%edx
80107b9c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ba6:	83 e2 ef             	and    $0xffffffef,%edx
80107ba9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bb3:	83 e2 df             	and    $0xffffffdf,%edx
80107bb6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bc0:	83 ca 40             	or     $0x40,%edx
80107bc3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bcd:	83 ca 80             	or     $0xffffff80,%edx
80107bd0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdd:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107be4:	ff ff 
80107be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107bf0:	00 00 
80107bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf5:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c06:	83 e2 f0             	and    $0xfffffff0,%edx
80107c09:	83 ca 02             	or     $0x2,%edx
80107c0c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c1c:	83 ca 10             	or     $0x10,%edx
80107c1f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c28:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c2f:	83 e2 9f             	and    $0xffffff9f,%edx
80107c32:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c42:	83 ca 80             	or     $0xffffff80,%edx
80107c45:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c55:	83 ca 0f             	or     $0xf,%edx
80107c58:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c68:	83 e2 ef             	and    $0xffffffef,%edx
80107c6b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c7b:	83 e2 df             	and    $0xffffffdf,%edx
80107c7e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c87:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c8e:	83 ca 40             	or     $0x40,%edx
80107c91:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ca1:	83 ca 80             	or     $0xffffff80,%edx
80107ca4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107cbe:	ff ff 
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107cca:	00 00 
80107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccf:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ce0:	83 e2 f0             	and    $0xfffffff0,%edx
80107ce3:	83 ca 0a             	or     $0xa,%edx
80107ce6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cf6:	83 ca 10             	or     $0x10,%edx
80107cf9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d09:	83 ca 60             	or     $0x60,%edx
80107d0c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d15:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d1c:	83 ca 80             	or     $0xffffff80,%edx
80107d1f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d28:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d2f:	83 ca 0f             	or     $0xf,%edx
80107d32:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d42:	83 e2 ef             	and    $0xffffffef,%edx
80107d45:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d55:	83 e2 df             	and    $0xffffffdf,%edx
80107d58:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d61:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d68:	83 ca 40             	or     $0x40,%edx
80107d6b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d74:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d7b:	83 ca 80             	or     $0xffffff80,%edx
80107d7e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d87:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d91:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d98:	ff ff 
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107da4:	00 00 
80107da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da9:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107dba:	83 e2 f0             	and    $0xfffffff0,%edx
80107dbd:	83 ca 02             	or     $0x2,%edx
80107dc0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107dd0:	83 ca 10             	or     $0x10,%edx
80107dd3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107de3:	83 ca 60             	or     $0x60,%edx
80107de6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107def:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107df6:	83 ca 80             	or     $0xffffff80,%edx
80107df9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e02:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e09:	83 ca 0f             	or     $0xf,%edx
80107e0c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e15:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e1c:	83 e2 ef             	and    $0xffffffef,%edx
80107e1f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e2f:	83 e2 df             	and    $0xffffffdf,%edx
80107e32:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e42:	83 ca 40             	or     $0x40,%edx
80107e45:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e55:	83 ca 80             	or     $0xffffff80,%edx
80107e58:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e61:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	05 b4 00 00 00       	add    $0xb4,%eax
80107e70:	89 c3                	mov    %eax,%ebx
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	05 b4 00 00 00       	add    $0xb4,%eax
80107e7a:	c1 e8 10             	shr    $0x10,%eax
80107e7d:	89 c1                	mov    %eax,%ecx
80107e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e82:	05 b4 00 00 00       	add    $0xb4,%eax
80107e87:	c1 e8 18             	shr    $0x18,%eax
80107e8a:	89 c2                	mov    %eax,%edx
80107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8f:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e96:	00 00 
80107e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9b:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107eb5:	83 e1 f0             	and    $0xfffffff0,%ecx
80107eb8:	83 c9 02             	or     $0x2,%ecx
80107ebb:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec4:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ecb:	83 c9 10             	or     $0x10,%ecx
80107ece:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ede:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ee1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eea:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ef1:	83 c9 80             	or     $0xffffff80,%ecx
80107ef4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efd:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f04:	83 e1 f0             	and    $0xfffffff0,%ecx
80107f07:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f10:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f17:	83 e1 ef             	and    $0xffffffef,%ecx
80107f1a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f23:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f2a:	83 e1 df             	and    $0xffffffdf,%ecx
80107f2d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f36:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f3d:	83 c9 40             	or     $0x40,%ecx
80107f40:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f49:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f50:	83 c9 80             	or     $0xffffff80,%ecx
80107f53:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f65:	83 c0 70             	add    $0x70,%eax
80107f68:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107f6f:	00 
80107f70:	89 04 24             	mov    %eax,(%esp)
80107f73:	e8 37 fb ff ff       	call   80107aaf <lgdt>
  loadgs(SEG_KCPU << 3);
80107f78:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107f7f:	e8 6a fb ff ff       	call   80107aee <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f87:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f8d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f94:	00 00 00 00 
}
80107f98:	83 c4 24             	add    $0x24,%esp
80107f9b:	5b                   	pop    %ebx
80107f9c:	5d                   	pop    %ebp
80107f9d:	c3                   	ret    

80107f9e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f9e:	55                   	push   %ebp
80107f9f:	89 e5                	mov    %esp,%ebp
80107fa1:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa7:	c1 e8 16             	shr    $0x16,%eax
80107faa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb4:	01 d0                	add    %edx,%eax
80107fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fbc:	8b 00                	mov    (%eax),%eax
80107fbe:	83 e0 01             	and    $0x1,%eax
80107fc1:	85 c0                	test   %eax,%eax
80107fc3:	74 17                	je     80107fdc <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc8:	8b 00                	mov    (%eax),%eax
80107fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fcf:	89 04 24             	mov    %eax,(%esp)
80107fd2:	e8 44 fb ff ff       	call   80107b1b <p2v>
80107fd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fda:	eb 4b                	jmp    80108027 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fdc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fe0:	74 0e                	je     80107ff0 <walkpgdir+0x52>
80107fe2:	e8 4e ac ff ff       	call   80102c35 <kalloc>
80107fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fee:	75 07                	jne    80107ff7 <walkpgdir+0x59>
      return 0;
80107ff0:	b8 00 00 00 00       	mov    $0x0,%eax
80107ff5:	eb 47                	jmp    8010803e <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ff7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ffe:	00 
80107fff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108006:	00 
80108007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800a:	89 04 24             	mov    %eax,(%esp)
8010800d:	e8 fc d2 ff ff       	call   8010530e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108015:	89 04 24             	mov    %eax,(%esp)
80108018:	e8 f1 fa ff ff       	call   80107b0e <v2p>
8010801d:	83 c8 07             	or     $0x7,%eax
80108020:	89 c2                	mov    %eax,%edx
80108022:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108025:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108027:	8b 45 0c             	mov    0xc(%ebp),%eax
8010802a:	c1 e8 0c             	shr    $0xc,%eax
8010802d:	25 ff 03 00 00       	and    $0x3ff,%eax
80108032:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803c:	01 d0                	add    %edx,%eax
}
8010803e:	c9                   	leave  
8010803f:	c3                   	ret    

80108040 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108040:	55                   	push   %ebp
80108041:	89 e5                	mov    %esp,%ebp
80108043:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108046:	8b 45 0c             	mov    0xc(%ebp),%eax
80108049:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010804e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108051:	8b 55 0c             	mov    0xc(%ebp),%edx
80108054:	8b 45 10             	mov    0x10(%ebp),%eax
80108057:	01 d0                	add    %edx,%eax
80108059:	83 e8 01             	sub    $0x1,%eax
8010805c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108061:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108064:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010806b:	00 
8010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108073:	8b 45 08             	mov    0x8(%ebp),%eax
80108076:	89 04 24             	mov    %eax,(%esp)
80108079:	e8 20 ff ff ff       	call   80107f9e <walkpgdir>
8010807e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108081:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108085:	75 07                	jne    8010808e <mappages+0x4e>
      return -1;
80108087:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010808c:	eb 48                	jmp    801080d6 <mappages+0x96>
    if(*pte & PTE_P)
8010808e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108091:	8b 00                	mov    (%eax),%eax
80108093:	83 e0 01             	and    $0x1,%eax
80108096:	85 c0                	test   %eax,%eax
80108098:	74 0c                	je     801080a6 <mappages+0x66>
      panic("remap");
8010809a:	c7 04 24 44 8f 10 80 	movl   $0x80108f44,(%esp)
801080a1:	e8 31 85 ff ff       	call   801005d7 <panic>
    *pte = pa | perm | PTE_P;
801080a6:	8b 45 18             	mov    0x18(%ebp),%eax
801080a9:	0b 45 14             	or     0x14(%ebp),%eax
801080ac:	83 c8 01             	or     $0x1,%eax
801080af:	89 c2                	mov    %eax,%edx
801080b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801080b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080bc:	75 08                	jne    801080c6 <mappages+0x86>
      break;
801080be:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801080bf:	b8 00 00 00 00       	mov    $0x0,%eax
801080c4:	eb 10                	jmp    801080d6 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801080c6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080cd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801080d4:	eb 8e                	jmp    80108064 <mappages+0x24>
  return 0;
}
801080d6:	c9                   	leave  
801080d7:	c3                   	ret    

801080d8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080d8:	55                   	push   %ebp
801080d9:	89 e5                	mov    %esp,%ebp
801080db:	53                   	push   %ebx
801080dc:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080df:	e8 51 ab ff ff       	call   80102c35 <kalloc>
801080e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080eb:	75 0a                	jne    801080f7 <setupkvm+0x1f>
    return 0;
801080ed:	b8 00 00 00 00       	mov    $0x0,%eax
801080f2:	e9 98 00 00 00       	jmp    8010818f <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801080f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080fe:	00 
801080ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108106:	00 
80108107:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010810a:	89 04 24             	mov    %eax,(%esp)
8010810d:	e8 fc d1 ff ff       	call   8010530e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108112:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108119:	e8 fd f9 ff ff       	call   80107b1b <p2v>
8010811e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108123:	76 0c                	jbe    80108131 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108125:	c7 04 24 4a 8f 10 80 	movl   $0x80108f4a,(%esp)
8010812c:	e8 a6 84 ff ff       	call   801005d7 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108131:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108138:	eb 49                	jmp    80108183 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010813a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813d:	8b 48 0c             	mov    0xc(%eax),%ecx
80108140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108143:	8b 50 04             	mov    0x4(%eax),%edx
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	8b 58 08             	mov    0x8(%eax),%ebx
8010814c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814f:	8b 40 04             	mov    0x4(%eax),%eax
80108152:	29 c3                	sub    %eax,%ebx
80108154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108157:	8b 00                	mov    (%eax),%eax
80108159:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010815d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108161:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108165:	89 44 24 04          	mov    %eax,0x4(%esp)
80108169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816c:	89 04 24             	mov    %eax,(%esp)
8010816f:	e8 cc fe ff ff       	call   80108040 <mappages>
80108174:	85 c0                	test   %eax,%eax
80108176:	79 07                	jns    8010817f <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108178:	b8 00 00 00 00       	mov    $0x0,%eax
8010817d:	eb 10                	jmp    8010818f <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010817f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108183:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
8010818a:	72 ae                	jb     8010813a <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010818c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010818f:	83 c4 34             	add    $0x34,%esp
80108192:	5b                   	pop    %ebx
80108193:	5d                   	pop    %ebp
80108194:	c3                   	ret    

80108195 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108195:	55                   	push   %ebp
80108196:	89 e5                	mov    %esp,%ebp
80108198:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010819b:	e8 38 ff ff ff       	call   801080d8 <setupkvm>
801081a0:	a3 18 6c 11 80       	mov    %eax,0x80116c18
  switchkvm();
801081a5:	e8 02 00 00 00       	call   801081ac <switchkvm>
}
801081aa:	c9                   	leave  
801081ab:	c3                   	ret    

801081ac <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801081ac:	55                   	push   %ebp
801081ad:	89 e5                	mov    %esp,%ebp
801081af:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801081b2:	a1 18 6c 11 80       	mov    0x80116c18,%eax
801081b7:	89 04 24             	mov    %eax,(%esp)
801081ba:	e8 4f f9 ff ff       	call   80107b0e <v2p>
801081bf:	89 04 24             	mov    %eax,(%esp)
801081c2:	e8 3c f9 ff ff       	call   80107b03 <lcr3>
}
801081c7:	c9                   	leave  
801081c8:	c3                   	ret    

801081c9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081c9:	55                   	push   %ebp
801081ca:	89 e5                	mov    %esp,%ebp
801081cc:	53                   	push   %ebx
801081cd:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801081d0:	e8 39 d0 ff ff       	call   8010520e <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801081d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081db:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081e2:	83 c2 08             	add    $0x8,%edx
801081e5:	89 d3                	mov    %edx,%ebx
801081e7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081ee:	83 c2 08             	add    $0x8,%edx
801081f1:	c1 ea 10             	shr    $0x10,%edx
801081f4:	89 d1                	mov    %edx,%ecx
801081f6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081fd:	83 c2 08             	add    $0x8,%edx
80108200:	c1 ea 18             	shr    $0x18,%edx
80108203:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010820a:	67 00 
8010820c:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108213:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108219:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108220:	83 e1 f0             	and    $0xfffffff0,%ecx
80108223:	83 c9 09             	or     $0x9,%ecx
80108226:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010822c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108233:	83 c9 10             	or     $0x10,%ecx
80108236:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010823c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108243:	83 e1 9f             	and    $0xffffff9f,%ecx
80108246:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010824c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108253:	83 c9 80             	or     $0xffffff80,%ecx
80108256:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010825c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108263:	83 e1 f0             	and    $0xfffffff0,%ecx
80108266:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010826c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108273:	83 e1 ef             	and    $0xffffffef,%ecx
80108276:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010827c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108283:	83 e1 df             	and    $0xffffffdf,%ecx
80108286:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010828c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108293:	83 c9 40             	or     $0x40,%ecx
80108296:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010829c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801082a3:	83 e1 7f             	and    $0x7f,%ecx
801082a6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801082ac:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801082b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082b8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082bf:	83 e2 ef             	and    $0xffffffef,%edx
801082c2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801082c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082ce:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801082d4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082da:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801082e1:	8b 52 08             	mov    0x8(%edx),%edx
801082e4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801082ea:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801082ed:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801082f4:	e8 df f7 ff ff       	call   80107ad8 <ltr>
  if(p->pgdir == 0)
801082f9:	8b 45 08             	mov    0x8(%ebp),%eax
801082fc:	8b 40 04             	mov    0x4(%eax),%eax
801082ff:	85 c0                	test   %eax,%eax
80108301:	75 0c                	jne    8010830f <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108303:	c7 04 24 5b 8f 10 80 	movl   $0x80108f5b,(%esp)
8010830a:	e8 c8 82 ff ff       	call   801005d7 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010830f:	8b 45 08             	mov    0x8(%ebp),%eax
80108312:	8b 40 04             	mov    0x4(%eax),%eax
80108315:	89 04 24             	mov    %eax,(%esp)
80108318:	e8 f1 f7 ff ff       	call   80107b0e <v2p>
8010831d:	89 04 24             	mov    %eax,(%esp)
80108320:	e8 de f7 ff ff       	call   80107b03 <lcr3>
  popcli();
80108325:	e8 28 cf ff ff       	call   80105252 <popcli>
}
8010832a:	83 c4 14             	add    $0x14,%esp
8010832d:	5b                   	pop    %ebx
8010832e:	5d                   	pop    %ebp
8010832f:	c3                   	ret    

80108330 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108330:	55                   	push   %ebp
80108331:	89 e5                	mov    %esp,%ebp
80108333:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108336:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010833d:	76 0c                	jbe    8010834b <inituvm+0x1b>
    panic("inituvm: more than a page");
8010833f:	c7 04 24 6f 8f 10 80 	movl   $0x80108f6f,(%esp)
80108346:	e8 8c 82 ff ff       	call   801005d7 <panic>
  mem = kalloc();
8010834b:	e8 e5 a8 ff ff       	call   80102c35 <kalloc>
80108350:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108353:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010835a:	00 
8010835b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108362:	00 
80108363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108366:	89 04 24             	mov    %eax,(%esp)
80108369:	e8 a0 cf ff ff       	call   8010530e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010836e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108371:	89 04 24             	mov    %eax,(%esp)
80108374:	e8 95 f7 ff ff       	call   80107b0e <v2p>
80108379:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108380:	00 
80108381:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108385:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010838c:	00 
8010838d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108394:	00 
80108395:	8b 45 08             	mov    0x8(%ebp),%eax
80108398:	89 04 24             	mov    %eax,(%esp)
8010839b:	e8 a0 fc ff ff       	call   80108040 <mappages>
  memmove(mem, init, sz);
801083a0:	8b 45 10             	mov    0x10(%ebp),%eax
801083a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801083a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801083ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b1:	89 04 24             	mov    %eax,(%esp)
801083b4:	e8 24 d0 ff ff       	call   801053dd <memmove>
}
801083b9:	c9                   	leave  
801083ba:	c3                   	ret    

801083bb <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083bb:	55                   	push   %ebp
801083bc:	89 e5                	mov    %esp,%ebp
801083be:	53                   	push   %ebx
801083bf:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c5:	25 ff 0f 00 00       	and    $0xfff,%eax
801083ca:	85 c0                	test   %eax,%eax
801083cc:	74 0c                	je     801083da <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801083ce:	c7 04 24 8c 8f 10 80 	movl   $0x80108f8c,(%esp)
801083d5:	e8 fd 81 ff ff       	call   801005d7 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083e1:	e9 a9 00 00 00       	jmp    8010848f <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801083ec:	01 d0                	add    %edx,%eax
801083ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083f5:	00 
801083f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801083fa:	8b 45 08             	mov    0x8(%ebp),%eax
801083fd:	89 04 24             	mov    %eax,(%esp)
80108400:	e8 99 fb ff ff       	call   80107f9e <walkpgdir>
80108405:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108408:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010840c:	75 0c                	jne    8010841a <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010840e:	c7 04 24 af 8f 10 80 	movl   $0x80108faf,(%esp)
80108415:	e8 bd 81 ff ff       	call   801005d7 <panic>
    pa = PTE_ADDR(*pte);
8010841a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841d:	8b 00                	mov    (%eax),%eax
8010841f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108424:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	8b 55 18             	mov    0x18(%ebp),%edx
8010842d:	29 c2                	sub    %eax,%edx
8010842f:	89 d0                	mov    %edx,%eax
80108431:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108436:	77 0f                	ja     80108447 <loaduvm+0x8c>
      n = sz - i;
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	8b 55 18             	mov    0x18(%ebp),%edx
8010843e:	29 c2                	sub    %eax,%edx
80108440:	89 d0                	mov    %edx,%eax
80108442:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108445:	eb 07                	jmp    8010844e <loaduvm+0x93>
    else
      n = PGSIZE;
80108447:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	8b 55 14             	mov    0x14(%ebp),%edx
80108454:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108457:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010845a:	89 04 24             	mov    %eax,(%esp)
8010845d:	e8 b9 f6 ff ff       	call   80107b1b <p2v>
80108462:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108465:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010846d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108471:	8b 45 10             	mov    0x10(%ebp),%eax
80108474:	89 04 24             	mov    %eax,(%esp)
80108477:	e8 08 9a ff ff       	call   80101e84 <readi>
8010847c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010847f:	74 07                	je     80108488 <loaduvm+0xcd>
      return -1;
80108481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108486:	eb 18                	jmp    801084a0 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108488:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010848f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108492:	3b 45 18             	cmp    0x18(%ebp),%eax
80108495:	0f 82 4b ff ff ff    	jb     801083e6 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010849b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084a0:	83 c4 24             	add    $0x24,%esp
801084a3:	5b                   	pop    %ebx
801084a4:	5d                   	pop    %ebp
801084a5:	c3                   	ret    

801084a6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084a6:	55                   	push   %ebp
801084a7:	89 e5                	mov    %esp,%ebp
801084a9:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801084ac:	8b 45 10             	mov    0x10(%ebp),%eax
801084af:	85 c0                	test   %eax,%eax
801084b1:	79 0a                	jns    801084bd <allocuvm+0x17>
    return 0;
801084b3:	b8 00 00 00 00       	mov    $0x0,%eax
801084b8:	e9 c1 00 00 00       	jmp    8010857e <allocuvm+0xd8>
  if(newsz < oldsz)
801084bd:	8b 45 10             	mov    0x10(%ebp),%eax
801084c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084c3:	73 08                	jae    801084cd <allocuvm+0x27>
    return oldsz;
801084c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c8:	e9 b1 00 00 00       	jmp    8010857e <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801084cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d0:	05 ff 0f 00 00       	add    $0xfff,%eax
801084d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084dd:	e9 8d 00 00 00       	jmp    8010856f <allocuvm+0xc9>
    mem = kalloc();
801084e2:	e8 4e a7 ff ff       	call   80102c35 <kalloc>
801084e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084ee:	75 2c                	jne    8010851c <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801084f0:	c7 04 24 cd 8f 10 80 	movl   $0x80108fcd,(%esp)
801084f7:	e8 07 7f ff ff       	call   80100403 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801084fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80108503:	8b 45 10             	mov    0x10(%ebp),%eax
80108506:	89 44 24 04          	mov    %eax,0x4(%esp)
8010850a:	8b 45 08             	mov    0x8(%ebp),%eax
8010850d:	89 04 24             	mov    %eax,(%esp)
80108510:	e8 6b 00 00 00       	call   80108580 <deallocuvm>
      return 0;
80108515:	b8 00 00 00 00       	mov    $0x0,%eax
8010851a:	eb 62                	jmp    8010857e <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010851c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108523:	00 
80108524:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010852b:	00 
8010852c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010852f:	89 04 24             	mov    %eax,(%esp)
80108532:	e8 d7 cd ff ff       	call   8010530e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853a:	89 04 24             	mov    %eax,(%esp)
8010853d:	e8 cc f5 ff ff       	call   80107b0e <v2p>
80108542:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108545:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010854c:	00 
8010854d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108551:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108558:	00 
80108559:	89 54 24 04          	mov    %edx,0x4(%esp)
8010855d:	8b 45 08             	mov    0x8(%ebp),%eax
80108560:	89 04 24             	mov    %eax,(%esp)
80108563:	e8 d8 fa ff ff       	call   80108040 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108568:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010856f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108572:	3b 45 10             	cmp    0x10(%ebp),%eax
80108575:	0f 82 67 ff ff ff    	jb     801084e2 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010857b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010857e:	c9                   	leave  
8010857f:	c3                   	ret    

80108580 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
80108583:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108586:	8b 45 10             	mov    0x10(%ebp),%eax
80108589:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010858c:	72 08                	jb     80108596 <deallocuvm+0x16>
    return oldsz;
8010858e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108591:	e9 a4 00 00 00       	jmp    8010863a <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108596:	8b 45 10             	mov    0x10(%ebp),%eax
80108599:	05 ff 0f 00 00       	add    $0xfff,%eax
8010859e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085a6:	e9 80 00 00 00       	jmp    8010862b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085b5:	00 
801085b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801085ba:	8b 45 08             	mov    0x8(%ebp),%eax
801085bd:	89 04 24             	mov    %eax,(%esp)
801085c0:	e8 d9 f9 ff ff       	call   80107f9e <walkpgdir>
801085c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085cc:	75 09                	jne    801085d7 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801085ce:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801085d5:	eb 4d                	jmp    80108624 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801085d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085da:	8b 00                	mov    (%eax),%eax
801085dc:	83 e0 01             	and    $0x1,%eax
801085df:	85 c0                	test   %eax,%eax
801085e1:	74 41                	je     80108624 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801085e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e6:	8b 00                	mov    (%eax),%eax
801085e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085f4:	75 0c                	jne    80108602 <deallocuvm+0x82>
        panic("kfree");
801085f6:	c7 04 24 e5 8f 10 80 	movl   $0x80108fe5,(%esp)
801085fd:	e8 d5 7f ff ff       	call   801005d7 <panic>
      char *v = p2v(pa);
80108602:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108605:	89 04 24             	mov    %eax,(%esp)
80108608:	e8 0e f5 ff ff       	call   80107b1b <p2v>
8010860d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108610:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108613:	89 04 24             	mov    %eax,(%esp)
80108616:	e8 81 a5 ff ff       	call   80102b9c <kfree>
      *pte = 0;
8010861b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108624:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108631:	0f 82 74 ff ff ff    	jb     801085ab <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108637:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010863a:	c9                   	leave  
8010863b:	c3                   	ret    

8010863c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010863c:	55                   	push   %ebp
8010863d:	89 e5                	mov    %esp,%ebp
8010863f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108642:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108646:	75 0c                	jne    80108654 <freevm+0x18>
    panic("freevm: no pgdir");
80108648:	c7 04 24 eb 8f 10 80 	movl   $0x80108feb,(%esp)
8010864f:	e8 83 7f ff ff       	call   801005d7 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108654:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010865b:	00 
8010865c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108663:	80 
80108664:	8b 45 08             	mov    0x8(%ebp),%eax
80108667:	89 04 24             	mov    %eax,(%esp)
8010866a:	e8 11 ff ff ff       	call   80108580 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010866f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108676:	eb 48                	jmp    801086c0 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108682:	8b 45 08             	mov    0x8(%ebp),%eax
80108685:	01 d0                	add    %edx,%eax
80108687:	8b 00                	mov    (%eax),%eax
80108689:	83 e0 01             	and    $0x1,%eax
8010868c:	85 c0                	test   %eax,%eax
8010868e:	74 2c                	je     801086bc <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108693:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010869a:	8b 45 08             	mov    0x8(%ebp),%eax
8010869d:	01 d0                	add    %edx,%eax
8010869f:	8b 00                	mov    (%eax),%eax
801086a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a6:	89 04 24             	mov    %eax,(%esp)
801086a9:	e8 6d f4 ff ff       	call   80107b1b <p2v>
801086ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b4:	89 04 24             	mov    %eax,(%esp)
801086b7:	e8 e0 a4 ff ff       	call   80102b9c <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801086bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086c0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086c7:	76 af                	jbe    80108678 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801086c9:	8b 45 08             	mov    0x8(%ebp),%eax
801086cc:	89 04 24             	mov    %eax,(%esp)
801086cf:	e8 c8 a4 ff ff       	call   80102b9c <kfree>
}
801086d4:	c9                   	leave  
801086d5:	c3                   	ret    

801086d6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086d6:	55                   	push   %ebp
801086d7:	89 e5                	mov    %esp,%ebp
801086d9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086e3:	00 
801086e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801086eb:	8b 45 08             	mov    0x8(%ebp),%eax
801086ee:	89 04 24             	mov    %eax,(%esp)
801086f1:	e8 a8 f8 ff ff       	call   80107f9e <walkpgdir>
801086f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086fd:	75 0c                	jne    8010870b <clearpteu+0x35>
    panic("clearpteu");
801086ff:	c7 04 24 fc 8f 10 80 	movl   $0x80108ffc,(%esp)
80108706:	e8 cc 7e ff ff       	call   801005d7 <panic>
  *pte &= ~PTE_U;
8010870b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870e:	8b 00                	mov    (%eax),%eax
80108710:	83 e0 fb             	and    $0xfffffffb,%eax
80108713:	89 c2                	mov    %eax,%edx
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	89 10                	mov    %edx,(%eax)
}
8010871a:	c9                   	leave  
8010871b:	c3                   	ret    

8010871c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010871c:	55                   	push   %ebp
8010871d:	89 e5                	mov    %esp,%ebp
8010871f:	53                   	push   %ebx
80108720:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108723:	e8 b0 f9 ff ff       	call   801080d8 <setupkvm>
80108728:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010872b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010872f:	75 0a                	jne    8010873b <copyuvm+0x1f>
    return 0;
80108731:	b8 00 00 00 00       	mov    $0x0,%eax
80108736:	e9 fd 00 00 00       	jmp    80108838 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010873b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108742:	e9 d0 00 00 00       	jmp    80108817 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108751:	00 
80108752:	89 44 24 04          	mov    %eax,0x4(%esp)
80108756:	8b 45 08             	mov    0x8(%ebp),%eax
80108759:	89 04 24             	mov    %eax,(%esp)
8010875c:	e8 3d f8 ff ff       	call   80107f9e <walkpgdir>
80108761:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108764:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108768:	75 0c                	jne    80108776 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010876a:	c7 04 24 06 90 10 80 	movl   $0x80109006,(%esp)
80108771:	e8 61 7e ff ff       	call   801005d7 <panic>
    if(!(*pte & PTE_P))
80108776:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108779:	8b 00                	mov    (%eax),%eax
8010877b:	83 e0 01             	and    $0x1,%eax
8010877e:	85 c0                	test   %eax,%eax
80108780:	75 0c                	jne    8010878e <copyuvm+0x72>
      panic("copyuvm: page not present");
80108782:	c7 04 24 20 90 10 80 	movl   $0x80109020,(%esp)
80108789:	e8 49 7e ff ff       	call   801005d7 <panic>
    pa = PTE_ADDR(*pte);
8010878e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108791:	8b 00                	mov    (%eax),%eax
80108793:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108798:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010879b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879e:	8b 00                	mov    (%eax),%eax
801087a0:	25 ff 0f 00 00       	and    $0xfff,%eax
801087a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087a8:	e8 88 a4 ff ff       	call   80102c35 <kalloc>
801087ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087b4:	75 02                	jne    801087b8 <copyuvm+0x9c>
      goto bad;
801087b6:	eb 70                	jmp    80108828 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801087b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087bb:	89 04 24             	mov    %eax,(%esp)
801087be:	e8 58 f3 ff ff       	call   80107b1b <p2v>
801087c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087ca:	00 
801087cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801087cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d2:	89 04 24             	mov    %eax,(%esp)
801087d5:	e8 03 cc ff ff       	call   801053dd <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801087da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801087dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087e0:	89 04 24             	mov    %eax,(%esp)
801087e3:	e8 26 f3 ff ff       	call   80107b0e <v2p>
801087e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087eb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801087ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
801087f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087fa:	00 
801087fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801087ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108802:	89 04 24             	mov    %eax,(%esp)
80108805:	e8 36 f8 ff ff       	call   80108040 <mappages>
8010880a:	85 c0                	test   %eax,%eax
8010880c:	79 02                	jns    80108810 <copyuvm+0xf4>
      goto bad;
8010880e:	eb 18                	jmp    80108828 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108810:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010881d:	0f 82 24 ff ff ff    	jb     80108747 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108826:	eb 10                	jmp    80108838 <copyuvm+0x11c>

bad:
  freevm(d);
80108828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882b:	89 04 24             	mov    %eax,(%esp)
8010882e:	e8 09 fe ff ff       	call   8010863c <freevm>
  return 0;
80108833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108838:	83 c4 44             	add    $0x44,%esp
8010883b:	5b                   	pop    %ebx
8010883c:	5d                   	pop    %ebp
8010883d:	c3                   	ret    

8010883e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010883e:	55                   	push   %ebp
8010883f:	89 e5                	mov    %esp,%ebp
80108841:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108844:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010884b:	00 
8010884c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010884f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108853:	8b 45 08             	mov    0x8(%ebp),%eax
80108856:	89 04 24             	mov    %eax,(%esp)
80108859:	e8 40 f7 ff ff       	call   80107f9e <walkpgdir>
8010885e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108864:	8b 00                	mov    (%eax),%eax
80108866:	83 e0 01             	and    $0x1,%eax
80108869:	85 c0                	test   %eax,%eax
8010886b:	75 07                	jne    80108874 <uva2ka+0x36>
    return 0;
8010886d:	b8 00 00 00 00       	mov    $0x0,%eax
80108872:	eb 25                	jmp    80108899 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108877:	8b 00                	mov    (%eax),%eax
80108879:	83 e0 04             	and    $0x4,%eax
8010887c:	85 c0                	test   %eax,%eax
8010887e:	75 07                	jne    80108887 <uva2ka+0x49>
    return 0;
80108880:	b8 00 00 00 00       	mov    $0x0,%eax
80108885:	eb 12                	jmp    80108899 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888a:	8b 00                	mov    (%eax),%eax
8010888c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108891:	89 04 24             	mov    %eax,(%esp)
80108894:	e8 82 f2 ff ff       	call   80107b1b <p2v>
}
80108899:	c9                   	leave  
8010889a:	c3                   	ret    

8010889b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010889b:	55                   	push   %ebp
8010889c:	89 e5                	mov    %esp,%ebp
8010889e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088a1:	8b 45 10             	mov    0x10(%ebp),%eax
801088a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088a7:	e9 87 00 00 00       	jmp    80108933 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801088ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801088af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801088be:	8b 45 08             	mov    0x8(%ebp),%eax
801088c1:	89 04 24             	mov    %eax,(%esp)
801088c4:	e8 75 ff ff ff       	call   8010883e <uva2ka>
801088c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088d0:	75 07                	jne    801088d9 <copyout+0x3e>
      return -1;
801088d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088d7:	eb 69                	jmp    80108942 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801088d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801088dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801088df:	29 c2                	sub    %eax,%edx
801088e1:	89 d0                	mov    %edx,%eax
801088e3:	05 00 10 00 00       	add    $0x1000,%eax
801088e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ee:	3b 45 14             	cmp    0x14(%ebp),%eax
801088f1:	76 06                	jbe    801088f9 <copyout+0x5e>
      n = len;
801088f3:	8b 45 14             	mov    0x14(%ebp),%eax
801088f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801088ff:	29 c2                	sub    %eax,%edx
80108901:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108904:	01 c2                	add    %eax,%edx
80108906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108909:	89 44 24 08          	mov    %eax,0x8(%esp)
8010890d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108910:	89 44 24 04          	mov    %eax,0x4(%esp)
80108914:	89 14 24             	mov    %edx,(%esp)
80108917:	e8 c1 ca ff ff       	call   801053dd <memmove>
    len -= n;
8010891c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108925:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108928:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010892b:	05 00 10 00 00       	add    $0x1000,%eax
80108930:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108933:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108937:	0f 85 6f ff ff ff    	jne    801088ac <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010893d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108942:	c9                   	leave  
80108943:	c3                   	ret    
