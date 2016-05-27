# Reads all records in the db file and writes them to the console

.include "db.common.asm"

.section .data

    LABEL_FIRST_NAME: .ascii "First: \0"
    .equ LABEL_FIRST_NAME_LEN, 7

    LABEL_LAST_NAME: .ascii "Last:  \0"
    .equ LABEL_LAST_NAME_LEN, 7

    LABEL_AGE: .ascii "Age:   \0"
    .equ LABEL_AGE_LEN, 7

    NEWLINE: .ascii "\n"

.section .bss

    .lcomm FIELD_FIRST_NAME, LABEL_FIRST_NAME_LEN + RECORD_FIRST_NAME_LEN + 1
    .lcomm FIELD_LAST_NAME, LABEL_LAST_NAME_LEN + RECORD_LAST_NAME_LEN + 1
    .lcomm FIELD_AGE, LABEL_AGE_LEN + 10 + 1

    .equ LOCAL_BYTES, 12
    .equ LOCAL_FILE, -4
    .equ LOCAL_AGE, -8
    .equ LOCAL_RECORD_COUNT, -12

.section .text

.globl _start
_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

# Write the first name label into the field buffer
    pushl $LABEL_FIRST_NAME
    pushl $FIELD_FIRST_NAME
    call strcpy
    addl $8, %esp

# Write the last name label into field buffer
    pushl $LABEL_LAST_NAME
    pushl $FIELD_LAST_NAME
    call strcpy
    addl $8, %esp

# Write the age label into field buffer
    pushl $LABEL_AGE
    pushl $FIELD_AGE
    call strcpy
    addl $8, %esp

# Open the db file for reading/writing
    movl $SYS_FILE_OPEN, %eax
    movl $FILENAME, %ebx
    movl $SYS_FILE_PERM_READWRITE, %ecx
    movl $0644, %edx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

# Store file pointer
    movl %eax, LOCAL_FILE(%ebp)

# Read record count
    movl $SYS_FILE_READ, %eax
    movl LOCAL_FILE(%ebp), %ebx
    leal LOCAL_RECORD_COUNT(%ebp), %ecx
    movl $4, %edx
    int $LINUX

# Check for error
    cmpl $0, %eax
    jl err

# Beginning of loop to read record
all_read_record:

# Make sure there are still records left to read, end loop if not
    movl LOCAL_RECORD_COUNT(%ebp), %ecx
    cmpl $0, %ecx
    jle all_done

# Read first name into buffer
    movl $SYS_FILE_READ, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $FIELD_FIRST_NAME, %ecx
    movl $LABEL_FIRST_NAME_LEN, %edx
    addl %edx, %ecx
    movl $RECORD_FIRST_NAME_LEN, %edx
    int $LINUX
    cmpl $0, %eax
    jl err

# Append newline
    addl %eax, %ecx
    movb $ASCII_LF, (, %ecx, 1)

# Write first name
    movl $FIELD_FIRST_NAME, %eax
    subl %eax, %ecx
    movl %ecx, %edx
    incl %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $FIELD_FIRST_NAME, %ecx
    int $LINUX
    cmpl $0, %eax
    jl err

# Read last name into buffer
    movl $SYS_FILE_READ, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $FIELD_LAST_NAME, %ecx
    movl $LABEL_LAST_NAME_LEN, %edx
    addl %edx, %ecx
    movl $RECORD_LAST_NAME_LEN, %edx
    int $LINUX
    cmpl $0, %eax
    jl err

# Append newline
    addl %eax, %ecx
    movb $ASCII_LF, (, %ecx, 1)

# Write last name
    movl $FIELD_LAST_NAME, %eax
    subl %eax, %ecx
    movl %ecx, %edx
    incl %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $FIELD_LAST_NAME, %ecx
    int $LINUX
    cmpl $0, %eax
    jl err

# Read age into local
    movl $SYS_FILE_READ, %eax
    movl LOCAL_FILE(%ebp), %ebx
    leal LOCAL_AGE(%ebp), %ecx
    movl $4, %edx
    int $LINUX
    cmpl $0, %eax
    jl err

# Convert age to string
    movl $FIELD_AGE, %eax
    movl $LABEL_AGE_LEN, %ebx
    addl %ebx, %eax
    pushl LOCAL_AGE(%ebp)
    pushl %eax
    call int_to_str
    cmpl $0, %eax
    jl err

# Append newline to age field
    movl %ebx, %edx
    movl $FIELD_AGE, %eax
    movl $LABEL_AGE_LEN, %ebx
    addl %ebx, %eax
    addl %edx, %eax
    movb $ASCII_LF, (, %eax, 1)

# Print age
    movl $FIELD_AGE, %ebx
    subl %ebx, %eax
    incl %eax
    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $FIELD_AGE, %ecx
    int $LINUX
    cmpl $0, %eax
    jl err

# Newline between records
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $NEWLINE, %ecx
    movl $1, %edx
    int $LINUX
    cmpl $0, %eax
    jl err

# Next record
    movl LOCAL_RECORD_COUNT(%ebp), %ecx
    decl %ecx
    movl %ecx, LOCAL_RECORD_COUNT(%ebp)
    jmp all_read_record

all_done:

# Close the db file
    movl $SYS_FILE_CLOSE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    int $LINUX
    cmpl $0, %eax
    jl err

    jmp exit_success

err:
    movl %eax, %ebx
    jmp exit

exit_success:
    movl $0, %ebx

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
