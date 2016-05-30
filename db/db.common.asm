.include "../common.asm"

.section .data

    # Name of the file to store records in
    FILENAME: .ascii "db\0"

    # Header size / offset of first record
    .set HEADER_LEN, 4

    # Bytes in each record
    .set RECORD_LEN, 68

    # First name max length
    .set RECORD_FIRST_NAME_LEN, 32

    # Last name max length
    .set RECORD_LAST_NAME_LEN, 32

    .set ASCII_LF, 10
