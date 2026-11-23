; C2 normal compilation of Variants.loop (Variants loop-warm)
   0:	89 84 24 00 c0 fe ff 	mov    DWORD PTR [rsp-0x14000],eax
   7:	55                   	push   rbp
   8:	48 83 ec 20          	sub    rsp,0x20
   c:	41 81 7f 20 01 00 00 	cmp    DWORD PTR [r15+0x20],0x1
  13:	00 
  14:	0f 85 fe 01 00 00    	jne    0x218
  1a:	44 8b d6             	mov    r10d,esi
  1d:	83 fe 01             	cmp    esi,0x1
  20:	0f 8c b3 01 00 00    	jl     0x1d9
  26:	81 fe fe ff ff 7f    	cmp    esi,0x7ffffffe
  2c:	0f 8f ad 01 00 00    	jg     0x1df
  32:	44 8d 4e 01          	lea    r9d,[rsi+0x1]
  36:	4d 63 d9             	movsxd r11,r9d
  39:	49 83 c3 f1          	add    r11,0xfffffffffffffff1
  3d:	bb 02 00 00 00       	mov    ebx,0x2
  42:	49 c7 c0 00 00 00 80 	mov    r8,0xffffffff80000000
  49:	49 81 fb 00 00 00 80 	cmp    r11,0xffffffff80000000
  50:	4d 0f 4c d8          	cmovl  r11,r8
  54:	41 8b cb             	mov    ecx,r11d
  57:	83 f9 02             	cmp    ecx,0x2
  5a:	0f 8e 98 01 00 00    	jle    0x1f8
  60:	c5 fb 10 0d 78 ff ff 	vmovsd xmm1,QWORD PTR [rip+0xffffffffffffff78]        # 0xffffffffffffffe0
  67:	ff 
  68:	ba 80 3e 00 00       	mov    edx,0x3e80
  6d:	33 ff                	xor    edi,edi
  6f:	8b c1                	mov    eax,ecx
  71:	2b c3                	sub    eax,ebx
  73:	3b cb                	cmp    ecx,ebx
  75:	0f 4c c7             	cmovl  eax,edi
  78:	3d 80 3e 00 00       	cmp    eax,0x3e80
  7d:	0f 47 c2             	cmova  eax,edx
  80:	03 c3                	add    eax,ebx
  82:	44 8d 5b 0f          	lea    r11d,[rbx+0xf]
  86:	44 8d 43 0b          	lea    r8d,[rbx+0xb]
  8a:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  8e:	c4 c1 6b 2a d3       	vcvtsi2sd xmm2,xmm2,r11d
  93:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  97:	c4 c1 63 2a d8       	vcvtsi2sd xmm3,xmm3,r8d
  9c:	44 8d 5b 0e          	lea    r11d,[rbx+0xe]
  a0:	44 8d 43 0d          	lea    r8d,[rbx+0xd]
  a4:	c5 d9 ef e4          	vpxor  xmm4,xmm4,xmm4
  a8:	c4 c1 5b 2a e3       	vcvtsi2sd xmm4,xmm4,r11d
  ad:	c5 d1 ef ed          	vpxor  xmm5,xmm5,xmm5
  b1:	c4 c1 53 2a e8       	vcvtsi2sd xmm5,xmm5,r8d
  b6:	44 8d 5b 0c          	lea    r11d,[rbx+0xc]
  ba:	44 8d 43 09          	lea    r8d,[rbx+0x9]
  be:	c5 c9 ef f6          	vpxor  xmm6,xmm6,xmm6
  c2:	c4 c1 4b 2a f3       	vcvtsi2sd xmm6,xmm6,r11d
  c7:	c5 c1 ef ff          	vpxor  xmm7,xmm7,xmm7
  cb:	c4 c1 43 2a f8       	vcvtsi2sd xmm7,xmm7,r8d
  d0:	44 8d 5b 01          	lea    r11d,[rbx+0x1]
  d4:	44 8d 43 02          	lea    r8d,[rbx+0x2]
  d8:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  dc:	c4 c1 7b 2a c3       	vcvtsi2sd xmm0,xmm0,r11d
  e1:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  e5:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  e9:	c4 c1 73 2a c8       	vcvtsi2sd xmm1,xmm1,r8d
  ee:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  f2:	44 8d 5b 03          	lea    r11d,[rbx+0x3]
  f6:	44 8d 43 04          	lea    r8d,[rbx+0x4]
  fa:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  fe:	c4 c1 73 2a cb       	vcvtsi2sd xmm1,xmm1,r11d
 103:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 107:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 10b:	c4 c1 73 2a c8       	vcvtsi2sd xmm1,xmm1,r8d
 110:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 114:	44 8d 5b 05          	lea    r11d,[rbx+0x5]
 118:	44 8d 43 06          	lea    r8d,[rbx+0x6]
 11c:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 120:	c4 c1 73 2a cb       	vcvtsi2sd xmm1,xmm1,r11d
 125:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 129:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 12d:	c4 c1 73 2a c8       	vcvtsi2sd xmm1,xmm1,r8d
 132:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 136:	44 8d 5b 07          	lea    r11d,[rbx+0x7]
 13a:	44 8d 43 08          	lea    r8d,[rbx+0x8]
 13e:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 142:	c4 c1 73 2a cb       	vcvtsi2sd xmm1,xmm1,r11d
 147:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 14b:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 14f:	c4 c1 73 2a c8       	vcvtsi2sd xmm1,xmm1,r8d
 154:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 158:	c5 c3 58 c0          	vaddsd xmm0,xmm7,xmm0
 15c:	44 8d 5b 0a          	lea    r11d,[rbx+0xa]
 160:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 164:	c4 c1 73 2a cb       	vcvtsi2sd xmm1,xmm1,r11d
 169:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 16d:	c5 fb 58 c3          	vaddsd xmm0,xmm0,xmm3
 171:	c5 cb 58 c0          	vaddsd xmm0,xmm6,xmm0
 175:	c5 d3 58 c0          	vaddsd xmm0,xmm5,xmm0
 179:	c5 db 58 c0          	vaddsd xmm0,xmm4,xmm0
 17d:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
 181:	83 c3 10             	add    ebx,0x10
 184:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 188:	c5 f3 2a cb          	vcvtsi2sd xmm1,xmm1,ebx
 18c:	c5 f3 58 c8          	vaddsd xmm1,xmm1,xmm0
 190:	3b d8                	cmp    ebx,eax
 192:	0f 8c ea fe ff ff    	jl     0x82
 198:	4d 8b 5f 30          	mov    r11,QWORD PTR [r15+0x30]
 19c:	41 85 03             	test   DWORD PTR [r11],eax
 19f:	3b d9                	cmp    ebx,ecx
 1a1:	0f 8c c8 fe ff ff    	jl     0x6f
 1a7:	41 3b d9             	cmp    ebx,r9d
 1aa:	7d 1d                	jge    0x1c9
 1ac:	44 8b db             	mov    r11d,ebx
 1af:	90                   	nop
 1b0:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
 1b4:	c5 f3 2a cb          	vcvtsi2sd xmm1,xmm1,ebx
 1b8:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 1bc:	41 ff c3             	inc    r11d
 1bf:	45 3b d9             	cmp    r11d,r9d
 1c2:	7d 05                	jge    0x1c9
 1c4:	41 8b db             	mov    ebx,r11d
 1c7:	eb e7                	jmp    0x1b0
 1c9:	48 83 c4 20          	add    rsp,0x20
 1cd:	5d                   	pop    rbp
 1ce:	49 3b 67 28          	cmp    rsp,QWORD PTR [r15+0x28]
 1d2:	0f 87 2a 00 00 00    	ja     0x202
 1d8:	c3                   	ret
 1d9:	c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 1dd:	eb ea                	jmp    0x1c9
 1df:	be 66 ff ff ff       	mov    esi,0xffffff66
 1e4:	44 89 14 24          	mov    DWORD PTR [rsp],r10d
 1e8:	66 66 90             	data16 xchg ax,ax
 1eb:	e8 d0 0b 9e ff       	call   0xffffffffff9e0dc0
 1f0:	0f 1f 84 00 08 03 00 	nop    DWORD PTR [rax+rax*1+0x1000308]
 1f7:	01 
 1f8:	c5 fb 10 05 e8 fd ff 	vmovsd xmm0,QWORD PTR [rip+0xfffffffffffffde8]        # 0xffffffffffffffe8
 1ff:	ff 
 200:	eb a5                	jmp    0x1a7
 202:	49 ba 6e f0 1b 68 83 	movabs r10,0x7f83681bf06e
 209:	7f 00 00 
 20c:	4d 89 97 38 05 00 00 	mov    QWORD PTR [r15+0x538],r10
 213:	e9 a8 e7 90 ff       	jmp    0xffffffffff90e9c0
 218:	e8 a3 3e 8f ff       	call   0xffffffffff8f40c0
 21d:	e9 f8 fd ff ff       	jmp    0x1a
 222:	f4                   	hlt
 223:	f4                   	hlt
 224:	f4                   	hlt
 225:	f4                   	hlt
 226:	f4                   	hlt
 227:	f4                   	hlt
 228:	e9 93 0e 9e ff       	jmp    0xffffffffff9e10c0
 22d:	e8 00 00 00 00       	call   0x232
 232:	48 83 2c 24 05       	sub    QWORD PTR [rsp],0x5
 237:	e9 84 ea 90 ff       	jmp    0xffffffffff90ecc0
 23c:	f4                   	hlt
 23d:	f4                   	hlt
 23e:	f4                   	hlt
 23f:	f4                   	hlt
