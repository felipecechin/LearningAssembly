    .data
first:      .asciiz     "First string: "
last:       .asciiz     "Second string: "
full:       .asciiz     "Full string: "
newline:    .asciiz     "\n"

string1:    .space      256             # buffer for first string
string2:    .space      256             # buffer for second string
string3:    .space      512             # combined output buffer

    .text

main:
    # prompt and read first string
    la      $a0,first               # prompt string
    la      $a1,string1             # buffer address
    jal     prompt
    move    $s0,$v0                 # save string length

    # prompt and read second string
    la      $a0,last                # prompt string
    la      $a1,string2             # buffer address
    jal     prompt
    move    $s1,$v0                 # save string length

    # point to combined string buffer
    # NOTE: this gets updated across strcat calls (which is what we _want_)
    la      $a0,string3

    # decide which string is shorter based on lengths
    blt     $s0,$s1,string1_short

    # string 1 is longer -- append to output
    la      $a1,string1
    jal     strcat