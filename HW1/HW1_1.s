#----------------------------------------------------Do not modify below text----------------------------------------------------
.data
  str1: .string	"This is HW1_1:\nBefore sorting: \n"
  str2: .string	"\nAfter sorting:\n"
  str3: .string	"  "
  num: .dword  10, -2, 4, -7, 6, 9, 3, 1, -5, -8

.globl main

.text
main:
  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  
  # a2 stores the num address, a3 stores the length of  num
  la a2, num
  li a3, 10
  jal prints
  
  la a2, num
  li a3, 10
  jal sort
  
  # Print result
  li a7, 4
  la a0, str2
  ecall

  la a2, num
  li a3, 10
  jal prints
  
  # End the program
  li a7, 10
  ecall
#----------------------------------------------------Do not modify above text----------------------------------------------------
### Start your code here ###
swap:
  # v in a5, k in a6
  slli t1, a6, 3       # t1 = k * 8
  add t1, a5, t1       # t1 = v + ( k * 8 )
  ld t0, 0(t1)
  ld t2, 8(t1)
  sd t2, 0(t1)
  sd t0, 8(t1)
  jalr zero, 0(ra)
sort:
  addi sp, sp, -40
  sd ra, 32(sp)
  sd s6, 24(sp)
  sd s5, 16(sp)
  sd s4, 8(sp)
  sd s3, 0(sp)
  # i in s3, j in s4
  mv s5, a2            # let s5 store the num address
  mv s6, a3	       # let s6 store the length of  num
  li s3, 0             # i = 0
OL:
  bge s3, s6, exitO    # if ( i >= the length of  num ) jump to exitO
  addi s4, s3, -1      # j = i -1
IL:
  blt s4, zero, exitI  # if ( j < 0 ) jump to exitI
  slli t0, s4, 3
  add t0, s5, t0
  ld t1, 0(t0)         # t1 = num[j]
  ld t2, 8(t0)         # t2 = num[j + 1]
  ble t1, t2, exitI    # if ( num[j] < num[j + 1] ) jump to exitI
  mv a5, s5            # let a5 store the num address
  mv a6, s4            # let a6 store j
  jal ra, swap         # call swap
  addi s4, s4, -1      # j = j -1 
  j IL
exitI:
  addi s3, s3, 1       #i = i + 1
  j OL
exitO:
  ld s3, 0(sp)
  ld s4, 8(sp)
  ld s5, 16(sp)
  ld s6, 24(sp)
  ld ra, 32(sp)
  addi sp, sp, 40
  jalr zero, 0(ra)

  
#----------------------------------------------------Do not modify below text----------------------------------------------------
# Print function	
prints:
  mv t0, zero # for(i=0)
  # a2 stores the num address, a3 stores the length of  num
  mv t1, a2
  mv t2, a3
printloop:
  bge t0, t2, printexit # if ( i>=length of num ) jump to printexit 
  slli t4, t0, 3
  add t5, t1, t4
  lw t3, 0(t5)
  li a7, 1 # print_int
  mv a0, t3
  ecall
	
  li a7, 4
  la a0, str3
  ecall 
	
  addi t0, t0, 1 # i = i + 1
  j printloop
printexit:
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------
