    .text
    .balign 4
    .global sgemm_nn
# RV64IDV system
#
# void
# sgemm_nn(size_t n,
#          size_t m,
#          size_t k,
#          const int*a,   // m * k matrix
#          size_t lda,
#          const int*b,   // k * n matrix
#          size_t ldb,
#          int*c,         // m * n matrix
#          size_t ldc)
#
#  c += a*b (alpha=1, no transpose on input matrices)
#  matrices stored in C row-major order

#define n a0
#define m a1
#define k a2
#define ap a3
#define astride a4
#define bp a5
#define bstride a6
#define cp a7
#define cstride t0
#define kt t1
#define nt t2
#define bnp t3
#define cnp t4
#define akp t5
#define bkp s0
#define nvl s1
#define ccp s2
#define amp s3


# This version holds a 8*VLMAX block of C matrix in vector registers
# in inner loop, but otherwise does not cache or TLB tiling.

sgemm_nn:
	mv cstride, a0 # Get arg from stack frame
    addi sp, sp, -104
    sd s0, 96(sp)
    sd s1, 88(sp)
    sd s2, 80(sp)
    sd s3, 72(sp)
    sd s4, 64(sp)
    sd s5, 56(sp)
    sd s6, 48(sp)
    sd s7, 40(sp)
    sd s8, 32(sp)
    sd s9, 16(sp)
    sd s10, 8(sp)
    sd s11, 0(sp)

    # Check for zero size matrices        
    beqz n, exit
    beqz m, exit
    beqz k, exit

    # Convert elements strides to byte strides. (32 bit elements so element 0 starts at byte 0, element 1 at byte 4, element 2 at byte 8...)
    #ld cstride, 0(sp)   # Get arg from stack frame
    slli astride, astride, 2
    slli bstride, bstride, 2
    slli cstride, cstride, 2

    slti t6, m, 8
    bnez t6, end_rows

c_row_loop: # Loop across rows of C blocks

    mv nt, n  # Initialize n counter for next row of C blocks

    mv bnp, bp # Initialize B n-loop pointer to start
    mv cnp, cp # Initialize C n-loop pointer

c_col_loop: # Loop across one row of C blocks
    vsetvli nvl, nt, e32, m1, ta, ma  # 32-bit vectors, LMUL=1

    mv akp, ap   # reset pointer into A to beginning
    mv bkp, bnp # step to next column in B matrix

    # Initalize current C submatrix block from memory.
    vle32.v  v0, (cnp)
	add ccp, cnp, cstride
    vle32.v  v1, (ccp)
	add ccp, ccp, cstride
    vle32.v  v2, (ccp)
	add ccp, ccp, cstride
    vle32.v  v3, (ccp)
	add ccp, ccp, cstride
    vle32.v  v4, (ccp)
	add ccp, ccp, cstride
    vle32.v  v5, (ccp)
	add ccp, ccp, cstride
    vle32.v  v6, (ccp)
	add ccp, ccp, cstride
    vle32.v  v7, (ccp) 


    mv kt, k # Initialize inner loop counter

    # Inner loop scheduled assuming 4-clock occupancy of vfmacc instruction and single-issue pipeline
    # Software pipeline loads (NOT IMPLEMENTED FOR NOW)
    
    # lw s4, (akp); add amp, akp, astride;
    # lw s5, (amp); add amp, amp, astride;
    # lw s6, (amp); add amp, amp, astride;
    # lw s7, (amp); add amp, amp, astride;
    # lw s8, (amp); add amp, amp, astride;
    
    # Get vector from B matrix
    vlse32.v v16, (bkp), bstride

    # Loop on inner dimension for current C block (unscheduled)
 k_loop:
 	addi kt, kt, -1    # Decrement k counter
 	add bkp, bkp, bstride 		# address of next vector in B matrix
 	addi akp, akp, 4            # Move to next column of A
 	lw s4, (akp)
	add amp, akp, astride
    lw s5, (amp)
	add amp, amp, astride
    lw s6, (amp)
	add amp, amp, astride
    lw s7, (amp) 
	add amp, amp, astride
    lw s8, (amp)
	add amp, amp, astride
    lw s9, (amp)
	add amp, amp, astride
    lw s10, (amp)
	add amp, amp, astride
    lw s11, (amp)
	add amp, amp, astride
    vmacc.vx v0, s4, v16
	vmacc.vx v1, s5, v16
	vmacc.vx v2, s6, v16
	vmacc.vx v3, s7, v16
	vmacc.vx v4, s8, v16
	vmacc.vx v5, s9, v16
	vmacc.vx v6, s10, v16
	vmacc.vx v7, s11, v16
	
    beqz kt, 1f                 # Exit out of loop if k=0 (go forward to label '1') 
    
    vlse32.v v16, (bkp), bstride            # Get next vector from B matrix, overlap loads with jump stalls
    j k_loop

1: 
    # Save C matrix block back to memory
    vse32.v  v0, (cnp)
	add ccp, cnp, cstride
    vse32.v  v1, (ccp)
	add ccp, ccp, cstride
    vse32.v  v2, (ccp)
	add ccp, ccp, cstride
    vse32.v  v3, (ccp)
	add ccp, ccp, cstride
    vse32.v  v4, (ccp)
	add ccp, ccp, cstride
    vse32.v  v5, (ccp)
	add ccp, ccp, cstride
    vse32.v  v6, (ccp)
	add ccp, ccp, cstride
    vse32.v  v7, (ccp)

    # Following tail instructions should be scheduled earlier in free slots during C block save.
    # Leaving here for clarity.

    # Bump pointers for loop across blocks in one row
    slli t6, nvl, 2
    add cnp, cnp, t6                         # Move C block pointer over
    add bnp, bnp, t6                         # Move B block pointer over
    sub nt, nt, nvl                          # Decrement element count in n dimension
    bnez nt, c_col_loop                      # Any more to do?

    # Move to next set of rows
    addi m, m, -8  # Did 8 rows above
    slli t6, astride, 3  # Multiply astride by 8
    add ap, ap, t6         # Move A matrix pointer down 8 rows
    slli t6, cstride, 3  # Multiply cstride by 8
    add cp, cp, t6         # Move C matrix pointer down 8 rows
    
    slti t6, m, 8
    beqz t6, c_row_loop

    # Handle end of matrix with fewer than 8 rows.
    # Can use smaller versions of above decreasing in powers-of-2 depending on code-size concerns.
end_rows: # Need to do rows 1 by 1

end_c_row_loop: # Loop across rows of C blocks

    mv nt, n  # Initialize n counter for next row of C blocks

    mv bnp, bp # Initialize B n-loop pointer to start
    mv cnp, cp # Initialize C n-loop pointer

end_c_col_loop: # Loop across one row of C blocks
    vsetvli nvl, nt, e32, m1, ta, ma  # 32-bit vectors, LMUL=1

    mv akp, ap   # reset pointer into A to beginning
    mv bkp, bnp # step to next column in B matrix

    # Initalize current C submatrix block from memory.
    vle32.v  v0, (cnp);

    mv kt, k # Initialize inner loop counter
    
    # Get vector from B matrix
    vlse32.v v16, (bkp), bstride

    # Loop on inner dimension for current C block (unscheduled)
end_k_loop:
 	addi kt, kt, -1    # Decrement k counter
 	add bkp, bkp, bstride 		# address of next vector in B matrix
 	lw s4, (akp)
	addi akp, akp, 4            # Move to next column of A
    vmacc.vx v0, s4, v16
	
    beqz kt, 1f                 # Exit out of loop if k=0 (go forward to label '1') 
    
    vlse32.v v16, (bkp), bstride            # Get next vector from B matrix, overlap loads with jump stalls
    j end_k_loop

1: 
    # Save C matrix block back to memory
    vse32.v  v0, (cnp);

    # Bump pointers for loop across blocks in one row
    slli t6, nvl, 2
    add cnp, cnp, t6                         # Move C block pointer over
    add bnp, bnp, t6                         # Move B block pointer over
    sub nt, nt, nvl                          # Decrement element count in n dimension
    bnez nt, end_c_col_loop                      # Any more to do?

    # Move to next row
    addi m, m, -1
    add ap, ap, astride         # Move A matrix pointer down 1 row
    add cp, cp, astride         # Move C matrix pointer down 1 row
    
    bnez m, end_c_row_loop

exit:
    ld s0, 96(sp)
    ld s1, 88(sp)
    ld s2, 80(sp)
    ld s3, 72(sp)
    ld s4, 64(sp)
    ld s5, 56(sp)
    ld s6, 48(sp)
    ld s7, 40(sp)
    ld s8, 32(sp)
    ld s9, 16(sp)
    ld s10, 8(sp)
    ld s11, 0(sp)
    addi sp, sp, 104
    ret
