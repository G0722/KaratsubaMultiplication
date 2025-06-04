//////////////////////////
//                      //
//  main                //
//                      //
//////////////////////////
main:
	subi  sp, sp, #16

	// Test the partitioned algoirthm 
	lda  x2, array_D
	lda  x1, array_C
	lda  x0, array_R
	bl MakeCumulative  // x3 gets k
	stur x3, [sp, #0]  // store k
	ldur x5, [x2, #8]  // x5 gets I[1]
	subi x5, x5, #1    // x5 gets I[1]-1, i.e., the degree
	stur x5, [sp, #8]  // store d
	bl BinaryPartitioning  // x4 gets the address for results
	
	// lines below print coefficients of result from lowest to highest degree
	ldur x3, [sp, #0]  // load k
	ldur x5, [sp, #8]  // load d
	// Prepare to call print
	add x1, x4, xzr    // x1 gets address of result array
	mul  x2, x3, x5    // x2 gets k*d, the degree of the product
	addi x3, xzr, #44  // x3 gets the comma char (ascii 44) for the delimiter
	bl PrintResult
	addi sp, sp, #16
	stop	// program ends


//////////////////////////
//                      //
//  InitZeros           //
//                      //
//////////////////////////
InitZeros:
// input:
// x0: address of (pointer to) the first symbol of input array
// output:
// x1: value specifying the degree for values that will be set to 0
	// Callee's tasks and responsibilities
	SUBI SP, SP, #16	// allocate 2 spots
	STUR FP, [SP, #8]	// caller's FP at bottom
	STUR LR, [SP, #0]	// caller's LR
	ADDI FP, SP, #8		// update the frame pointer

	ADDI X9, X1, #1		// d+1 reference
	ADDI X10, XZR, #0	// loop counter i = 0

	loop:
		CMP X10, X9	// is i < d+1?
		B.GE endInitZeros

		STUR XZR, [X0, #0]	// store 0 in X0
		ADDI X10, X10, #1	// i++
		ADDI X0, X0, #8		// move to the next value in array
		B loop			// repeat

	endInitZeros:
	LDUR FP, [SP, #8]	// restore frame pointer
	STUR LR, [SP, #0]	// restore caller's LR
	ADDI SP, SP, #16	// deallocate 2 spots from stack
  	BR LR


//////////////////////////
//                      //
//  MakeCumulative      //
//                      //
//////////////////////////
MakeCumulative:
// input:
// x2: address to the first degree of the array D
// output:
// x3: value of the total number of polynomials in the input, k
	// perform duties of callee
	SUBI SP, SP, #24	// allocate stack
	STUR FP, [SP, #16]	// save the caller's FP
	STUR LR, [SP, #8]	// save the caller's LR
	STUR X2, [SP, #0]	// save the argument D
	ADDI FP, SP, #16	// update the FP
	
	MOV X9, XZR		// X9: loop counter (i = 0)
	MOV X10, XZR		// X10: (c = 0)
	MOV X11, X2		// X11: address D (temp)
	STUR XZR, [X11, #0]	// D[0] = 0
	ADDI X9, X9, #1		// i = i+1
	ADDI X11, X11, #8	// address D+1
	
	mc_loop:
		LDUR X12, [X11, #0]	// X12: D[i]
		ADDIS X13, X12, #1	// is (D[i] + 1 == 0) or (D[i] == -1)?
		CBZ X13, end_mc_loop	// exit loop if it is true
		
		// otherwise stay in the loop
		ADD X12, X12, X10	// X12: D[i]+c
		ADDI X12, X12, #1	// X12: D[i]+c+1
		STUR X12, [X11, #0]	// D[i] = D[i]+c+1
		LDUR X10, [X11, #0]	// X10: c = D[i]
		ADDI X11, X11, #8	// X11: address of next element in D
		ADDI X9, X9, #1		// X9: i = i+1
		B mc_loop

	end_mc_loop: MOV X3, X9		// return i through X3
	LDUR FP, [SP, #16]	// restore caller FP
	LDUR LR, [SP, #8]	// restore caller LR
	ADDI SP, SP, #24	// deallocate stack
	BR LR			// return


//////////////////////////
//                      //
//  ComputeAuxiliary    //
//                      //
//////////////////////////
ComputeAuxiliary:
// input:
// x1: address of the first coefficient of the input polynomial
// x2: degree value of the input polynomial
// x3: address to save the result p1(x)+p2(x)
// output:
// This function does not return anything.
	// perform callee responsibility
	SUBI SP, SP, #40	// allocate space for stack frame
	STUR FP, [SP, #32]	// save caller's frame pointer
	STUR LR, [SP, #24]	// save caller's LR
	ADDI FP, SP, #32	// update frame pointer to current stack frame
	
	STUR X1, [SP, #16]	// store X1: address P
	STUR X2, [SP, #8]	// store X2: degree d
	STUR X3, [SP, #0]	// store X3: address R
	
	MOV X16, X3	// X16 = temp ptr for R to iterate
	MOV X17, X1	// X17 = temp ptr for P to iterate

	LSR X9, X2, #1		// X9 = floor(d/2)
	LSL X9, X9, #1		// X9 = floor(d/2)*2

	// is 2*floor(d/2) == d? If yes, it's even, divide by 2.
	// Otherwise, it's odd, so add 1, then divide by 2.
	CMP X9, X2
	B.EQ c_even
	ADDI X9, X2, #1
	LSR X9, X9, #1
	B b_loop
	
	c_even: 
	LSR X9, X2, #1
	// the lines above computes m, the ceiling of d/2. (for example if d is 3, then ceil(d/2) = 2)

	b_loop: MOV X10, XZR	// loop counter i = 0
	c_loop:
		CMP X10, X9		// is i < m
		B.EQ endloop	// end loop if i >= m
		
		LDUR X11, [X17, #0]	// X11 = P[i]
		ADD X12, X10, X9	// X12 = i+m

		LSL X12, X12, #3	// 8*(i+m)
		ADD X12, X12, X1	// pointer P+i+m
		LDUR X12, [X12, #0]	// X12 = P[i+m]
		ADD X12, X12, X11	// X12 = P[i] + P[i+m]
		STUR X12, [X16, #0]	// R[i] = P[i] + P[i+m]

		ADDI X10, X10, #1	// i++
		ADDI X16, X16, #8	// X16 = ptr to next R[i]
		ADDI X17, X17, #8	// X17 = ptr to next P[i]
		B c_loop
	endloop:
	
	LSL X13, X9, #1		// X13 = 2m-1
	SUBI X13, X13, #1	


	LSL X14, X9, #3		// X14 = 8*m
	LDUR X3, [SP, #0]	// load address R
	ADD X14, X3, X14	// X14 = pointer R+m
	
	LDUR X2, [SP, #8]	// load degree d
	CMP X2, X13		// is d > 2m-1?

	B.LE comp_else
		// case: d > 2m-1
		LSL X15, X2, #3
		LDUR X1, [SP, #16]	// load address P
		ADD X15, X15, X1	// X15 = pointer P+d
		LDUR X15, [X15, #0]	// X15 = P[d]
		STUR X15, [X14, #0]	// R[m] = P[d]
		B endComputeAuxiliary

	comp_else: 	// else case
		STUR XZR, [X14, #0]	// R[m] = 0
	
	endComputeAuxiliary:
	LDUR LR, [SP, #24]	// restore LR of caller
	LDUR FP, [SP, #32]	// restore FP of caller
	ADDI SP, SP, #40	// deallocate the stack
	BR LR



//////////////////////////
//                      //
//  NaiveMult           //
//                      //
//////////////////////////
NaiveMult:
// input:
// x0: address to write the coefficients of the resulting product
// x1: address to the first coefficient in p(x)
// x2: address to the first coefficient in q(x)
// x3: the value of the degrees of p(x) and q(x), d
// output:
// This function does not return anything.
	// perform callee's initial responsibilties
	SUBI SP, SP, #32	// allocate 4 spots
	STUR FP, [SP, #16]	// save caller's FP
	STUR LR, [SP, #24]	// save caller's LR
	ADDI FP, SP, #24	// update the frame pointer
	
	// perform caller's initial responsibilies
	STUR X0, [SP, #0]	// save our X0
	STUR X1, [SP, #8]	// save our X1
	MOV X1, X3		// X1 param to InitZero = d
	LSL X1, X1, #1		// X1 = dr = 2d
	
	BL InitZeros		// call InitZero(R, dr)
	
	LDUR X0, [SP, #0]	// restore X0
	LDUR X1, [SP, #8]	// restore X1
	
	MOV X9, XZR		// X9 (outerLoopCounter = 0)
	// for (int i = 0; i <= d; i++)
	//	for (int j = 0; j <= d; j++)
	//		R[i+j] = R[i+j] + P[i] * Q[j]
	outerLoop:
		CMP X9, X3		// is i <= d
		B.GT endOuterLoop	// end loop condition
		MOV X10, XZR		// X10 (innerLoopCounter = 0)
		innerLoop:
			CMP X10, X3		// is j <= d?
			B.GT endInnerLoop	// end innerLoop
			LSL X11, X9, #3		// X11 = i*8
			LSL X12, X10, #3	// X12 = j*8
			ADD X15, X11, X12	// X15 = 8*(i+j)
			
			ADD X11, X11, X1	// X11 = ptr to P+i
			ADD X12, X12, X2	// X12 = ptr to Q+j

			LDUR X13, [X11, #0]	// X13 = P[i]
			LDUR X14, [X12, #0]	// X14 = Q[j]
			
			ADD X15, X15, X0	// X15 = ptr to R[i+j]
			LDUR X16, [X15, #0]	// X16 = R[i+j]
			MUL X13, X13, X14	// X13 = P[i] * Q[j]
			ADD X16, X16, X13	// X16 = R[i+j] + P[i]*Q[j]
			STUR X16, [X15, #0]	// R[i+j] = R[i+j] + P[i]*Q[j]
			
			ADDI X10, X10, #1	// j++
			B innerLoop
		endInnerLoop:
		ADDI X9, X9, #1		// i++
		B outerLoop
	endOuterLoop:
	
	// perform callee's final responsibilities
	LDUR FP, [SP, #16]	// restore FP
	LDUR LR, [SP, #24]	// restore LR
	ADDI SP, SP, #32	// deallocate SP
	BR LR


//////////////////////////
//                      //
//  KaratsubaMult        //
//                      //
//////////////////////////
KaratsubaMult:
// input:
// x0: address to write the coefficients of the resulting product
// x1: address to the first coefficient in p(x)
// x2: address to the first coefficient in q(x)
// x3: the value of the degrees of p(x) and q(x), d
// output:
// This function does not return anything.
	SUBI SP, SP, #104	// allocate stack frame
	STUR FP, [SP, #96]	// save FP of caller
	STUR LR, [SP, #88]	// save LR of caller
	ADDI FP, SP, #96	// update FP
	// save callee's arguments
	STUR X0, [SP, #80]	// save addr. R
	STUR X1, [SP, #72]	// save addr. P
	STUR X2, [SP, #64]	// save addr. Q
	STUR X3, [SP, #56]	// save degree d
	
	CMPI X3, #2 	// if d < 2, do naive multiplication
	B.LT Naive
	
	// case where d >= 2
	LSR X9, X3, #1		// X9 = floor(d/2)
	LSL X9, X9, #1		// X9 = floor(d/2)*2

	// is 2*floor(d/2) == d? If yes, it's even, divide by 2.
	// Otherwise, it's odd, so add 1, then divide by 2.
	CMP X9, X3
	B.EQ k_even
	ADDI X9, X3, #1
	LSR X9, X9, #1
	B lll

	k_even: LSR X9, X3, #1
	// the lines above computes ceiling of d/2

	lll: LSL X10, X3, #1		// X10 = dr = 2d
	
	STUR X9, [SP, #48]	// save m
	STUR X10,[SP, #40]	// save dr

	// compute P0
	ADDI X11, X10, #1	// X11 = dr+1
	LSL X11, X11, #3	// X11 = 8*(dr+1)
	LDUR X0, [SP, #80]	// X0 = address R
	ADD X11, X11, X0	// X11 =  address P0 = R + dr + 1
	
	// compute Q0
	ADDI X12, X9, #1	// X12 = m+1
	LSL X12, X12, #3	// X12 = 8*(m+1)
	ADD X12, X12, X11	// X12 = address Q0 = P0 + m + 1

	// compute R1
	ADDI X13, X9, #1	// X13 = m+1
	LSL X13, X13, #3	// X13 = 8*(m+1)
	ADD X13, X13, X12	// X13 = address R1 = Q0 + m + 1

	// compute R2
	SUBI X14, X9, #1	// X14 = m-1
	LSL X14, X14, #1	// X14 = 2(m-1)
	ADDI X14, X14, #1	// X14 = 2(m-1)+1
	LSL X14, X14, #3	// 8(2(m-1)+1)
	ADD X14, X14, X13	// X14 = address R2 = R1 + 2(m-1)+1

	// compute R3
	SUB X15, X3, X9		// X15 = d-m
	LSL X15, X15, #1	// X15 = 2(d-m)
	ADDI X15, X15, #1	// X15 = 2(d-m)+1
	LSL X15, X15, #3	// 8(2(d-m)+1)
	ADD X15, X15, X14	// X15 = address R3 = R2 + 2(d-m)+1
	
	// save P0, Q0, R1, R2, R3 in stack frame
	STUR X11, [SP, #32]
	STUR X12, [SP, #24]
	STUR X13, [SP, #16]
	STUR X14, [SP, #8]
	STUR X15, [SP, #0]
	
	LDUR X1, [SP, #72]	// X1 = address P
	LDUR X2, [SP, #56]	// X2 = degree d
	LDUR X3, [SP, #32]	// X3 = address P0
	// parameters loaded for ComputeAuxiliary(P,d,P0)
	BL ComputeAuxiliary

	LDUR X1, [SP, #64]	// X1 = address Q
	LDUR X2, [SP, #56]	// X2 = degree d
	LDUR X3, [SP, #24]	// X3 = address Q0
	BL ComputeAuxiliary	// call ComputeAuxiliary(Q,d,Q0)
	
	LDUR X0, [SP, #16]	// load parameter R1
	LDUR X1, [SP, #72]	// load parameter P
	LDUR X2, [SP, #64]	// load parameter Q
	LDUR X3, [SP, #48]	// load parameter m-1
	SUBI X3, X3, #1
	BL KaratsubaMult	// recursive call KaratsubaMult(R1, P, Q, m-1)

	LDUR X0, [SP, #8]	// load parameter R2
	LDUR X4, [SP, #48]	// X4: m
	LSL X4, X4, #3		// X4: 8*m
	LDUR X1, [SP, #72]	// X1: address P
	ADD X1, X1, X4		// X1: loaded address P+m
	
	LDUR X2, [SP, #64]	// X2: address Q
	ADD X2, X2, X4		// X2: loaded address Q+m
	
	LDUR X4, [SP, #48]	// load parameter d-m
	LDUR X3, [SP, #56]
	SUB X3, X3, X4
	BL KaratsubaMult	// recursive call KaratsubaMult(R2, P+m, Q+m, d-m)

	LDUR X0, [SP, #0]	// load parameter R3
	LDUR X1, [SP, #32]	// load parameter P0
	LDUR X2, [SP, #24]	// load parameter Q0
	LDUR X3, [SP, #48]	// load parameter m
	BL KaratsubaMult	// recursive call KaratsubaMult(R3, P0, Q0, m)
	
	LDUR X0, [SP, #80]	// load parameter R
	LDUR X1, [SP, #40]	// load parameter dr
	BL InitZeros		// call InitZeros(R, dr)
	
	LDUR X9, [SP, #48]	// load m
	LDUR X10,[SP, #40]	// load dr
	
	LSL X11, X9, #1		// X11: 2m
	SUBI X11, X11, #1	// X11: 2m-1 (exit loop when i = 2(m-1)+1 = 2m-1)
	LDUR X12, [SP, #80]	// X12: R ptr
	LDUR X13, [SP, #16]	// X13: R1 ptr
	LDUR X14, [SP, #0]	// X14: R3 ptr

	MOV X8, XZR	// X8: i = 0
	
	kloop1:
		CMP X8, X11
		B.EQ end_kloop1
		LDUR X15, [X12, #0]	// load R[i]
		LDUR X16, [X13, #0]	// load R1[i]
		LDUR X17, [X14, #0]	// load R3[i]
		ADD X15, X15, X16	// X15: R[i] + R1[i]
		SUB X17, X17, X16	// X17: R3[i] - R1[i]
		STUR X15, [X12, #0]	// R[i] = R[i] + R1[i]
		STUR X17, [X14, #0]	// R3[i] = R3[i] - R1[i]
		ADDI X12, X12, #8	// point to next element of R
		ADDI X13, X13, #8	// point to next element of R1
		ADDI X14, X14, #8	// point to next element of R3
		ADDI X8, X8, #1		// i = i+1
		B kloop1
	end_kloop1:
	
	LDUR X11, [SP, #56]	// load d
	SUB X11, X11, X9	// X11: d-m
	LSL X11, X11, #1	// X11: 2(d-m)+1
	ADDI X11, X11, #1

	LDUR X12, [SP, #80]	// X12: R ptr
	LDUR X13, [SP, #8]	// X13: R2 ptr
	LDUR X14, [SP, #0]	// X14: R3 ptr
	LSL X15, X9, #4		// X15: 8*2m
	ADD X12, X12, X15	// X12: address R+2m
	
	MOV X8, XZR

	kloop2:
		CMP X8, X11			// is i == 2(d-m)+1
		B.EQ end_kloop2		// end loop if i > 2(d-m)
		LDUR X15, [X12, #0]	// X15: R[i+2m]
		LDUR X16, [X13, #0]	// X16: R2[i]
		LDUR X17, [X14, #0]	// X17: R3[i]
		ADD X15, X15, X16	// X15: R[i+2m] + R2[i]
		SUB X17, X17, X16	// X17: R3[i] - R2[i]
		STUR X15, [X12, #0]	// R[i+2m] = R[i+2m] + R2[i]
		STUR X17, [X14, #0]	// R3[i] = R3[i] - R2[i]
		ADDI X12, X12, #8	// update addr. to R+i+2m+1
		ADDI X13, X13, #8	// update addr. to R2+i+1
		ADDI X14, X14, #8	// update addr. to R3+i+1
		ADDI X8, X8, #1		// i = i+1
		B kloop2
	end_kloop2:
	
	LSL X11, X9, #1		// X11: 2m
	ADDI X11, X11, #1	// X11: 2m+1

	LDUR X12, [SP, #80]	// X12: R ptr
	LDUR X13, [SP, #0]	// X13: R3 ptr
	LSL X14, X9, #3		// X14: 8*m
	ADD X12, X12, X14	// ptr to R + m
	
	MOV X8, XZR
	
	kloop3: 
		CMP X8, X11			// is i == 2m+1?
		B.EQ end_kloop3		// end loop if i > 2m
		LDUR X14, [X12, #0]	// X14: R[i+m]
		LDUR X15, [X13, #0]	// X15: R3[i]
		ADD X14, X14, X15	// X14: R[i+m] + R3[i]
		STUR X14, [X12, #0]	// R[i+m] = R[i+m] + R3[i]
		ADDI X8, X8, #1		// i = i+1
		ADDI X12, X12, #8	// update addr. to R+m+i+1
		ADDI X13, X13, #8	// update addr. to R3+i+1
		B kloop3
	end_kloop3:
	B endK	// jump to the end of KaratsubaMult
		
	Naive:
		// load arguments for NaiveMult
		LDUR X0, [SP, #80]	// X0: loaded address R
		LDUR X1, [SP, #72]	// X1: loaded address P
		LDUR X2, [SP, #64]	// X2: loaded address Q
		LDUR X3, [SP, #56]	// X3: loaded degree d
		BL NaiveMult		// call NaiveMult(R, P, Q, d)
	endK:
		LDUR FP, [SP, #96]	// restore FP of caller
		LDUR LR, [SP, #88]	// restore LR of caller		
		ADDI SP, SP, #104	// deallocate stack
		BR LR



//////////////////////////
//                      //
//  BinaryPartitioning  //
//                      //
//////////////////////////
BinaryPartitioning:
// input:
// x0: address to write the intermediate results
// x1: address of the first value in the input coefficient array
// x2: address of the first value in the cumulative index array
// x3: value of the total number of polynomials to multiply, k
// output:
// x4: the address of the results (i.e., first value in the left split of C)
	SUBI SP, SP, #120	// allocate stack frame
	STUR FP, [SP, #112]	// save FP of caller
	STUR LR, [SP, #104]	// save LR of caller
	ADDI FP, SP, #112	// update the FP

	// save the arguments of callee
	STUR X0, [SP, #96]	// save R
	STUR X1, [SP, #88]	// save C
	STUR X2, [SP, #80]	// save I
	STUR X3, [SP, #72]	// save k

	LSR X9, X3, #1		// X9: l = k/2
	STUR X9, [SP, #64]	// save l
	
	CMPI X3, #2	// is k == 2?
	B.EQ k_is_2
	// case k != 2
	LDUR X0, [SP, #96]	// load parameter R
	LDUR X1, [SP, #88]	// load parameter C
	LDUR X2, [SP, #80]	// load parameter I
	LDUR X3, [SP, #64]	// load parameter l
	BL BinaryPartitioning	// call BinaryPartitioning(R, C, I, l)
	// returns C1 in X4 upon returning
	STUR X4, [SP, #56]	// save address C1 in the stack

	LDUR X0, [SP, #96]	// load parameter R
	LDUR X1, [SP, #88]	// load parameter C
	LDUR X2, [SP, #80]	// load parameter I
	LDUR X3, [SP, #64]	// load parameter l
	LSL X12, X3, #3		// X12: 8*l
	ADD X2, X2, X12		// Load parameter address I+l
	BL BinaryPartitioning	// call BinaryPartitioning(R, C, I+l, l)
	STUR X4, [SP, #48]	// save address C2 in the stack
	B b_part_line9
	
	// case k==2
	k_is_2:
		LDUR X10, [X2, #0]	// X10: I[0]
		LSL X10, X10, #3	// X10: 8*I[0]
		ADD X11, X1, X10	// X11: C1 = address C + I[0]
		STUR X11, [SP, #56]	// save address C1 in stack
		
		LDUR X10, [X2, #8]	// X10: I[1]
		LSL X10, X10, #3	// X10: 8*I[1]
		ADD X11, X1, X10	// X11: address C + I[1]
		STUR X11, [SP, #48]	// save address C2 in stack

	// end of if-else
	b_part_line9:
	LDUR X12, [SP, #80]	// X12: addr. I
	LDUR X13, [X12, #8]	// X13: I[1]
	LDUR X14, [X12, #0]	// X14: I[0]
	SUB X13, X13, X14	// X13: I[1] - I[0]
	SUBI X13, X13, #1	// X13: I[1] - I[0] - 1
	LDUR X14, [SP, #64]	// X14: value of l
	MUL X13, X13, X14	// X13: dn = l * (I[1]-I[0]-1)
	STUR X13, [SP, #40]	// save dn on stack
	LSL X13, X13, #1	// X13: dr = 2*dn
	STUR X13, [SP, #32]	// save dr on stack

	LDUR X0, [SP, #96]	// load parameter R
	LDUR X1, [SP, #56]	// load parameter C1
	LDUR X2, [SP, #48]	// load parameter C2
	LDUR X3, [SP, #40]	// load parameter dn
	BL KaratsubaMult	// call KaratsubaMult(R, C1, C2, dn)
	
	LDUR X11, [SP, #32]	// X11: dr

	MOV X9, XZR		// X9: loop ctr (i = 0)
	LDUR X7, [SP, #96]	// X7: address R
	LDUR X8, [SP, #56]	// X8: address C1

	bp_loop:
		CMP X9, X11	// is i > dr?
		B.GT end_bp_loop 	// exit loop when i > dr
	
		LDUR X12, [X7, #0]	// X12: R[i]
		STUR X12, [X8, #0]	// C1[i] = R[i]
		ADDI X9, X9, #1		// i = i+1
		ADDI X7, X7, #8		// point to next R
		ADDI X8, X8, #8		// point to next C1
		B bp_loop
	end_bp_loop:
		LDUR X4, [SP, #56]	// X4 = address of C1 (returned)
		LDUR FP, [SP, #112]	// restore caller's FP
		LDUR LR, [SP, #104]	// restore caller's LR
		ADDI SP, SP, #120	// deallocate the stack
		BR LR	// return back


TestPrint:
	subi  sp, sp, #16
	stur  lr, [sp, #0]
	stur  fp, [sp, #8]
	addi  fp, sp, #8

	lda   x1, array_C
	lda  x2, array_D
	ldur x2, [x2, #0] // prints the first polynomial
	addi  x3, xzr, #44  // 44 is ASCII for ,
	bl PrintResult

	ldur  lr, [sp, #0]
	ldur  fp, [sp, #8]
	addi  sp, sp, #16
	br lr

PrintResult:
// input:
// x1: address to array to print
// x2: the degree of the result
// x3: ASCII delimiter character
	ldur  x11, [x1, #0]
	putint x11
	putchar x3
	addi  x1, x1, #8
	subis x2, x2, #1
	b.gt  PrintResult
	ldur  x11, [x1, #0]
	putint x11
	br lr
