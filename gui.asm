.section .data

    GNOME_STOCK_BUTTON_YES: .ascii "Button_Yes\0"
    GNOME_STOCK_BUTTON_NO: .ascii "Button_No\0"

    GNOME_MESSAGE_BOX_QUESTION: .ascii "question\0"

    .equ NULL, 0

    signal_destroy: .ascii "destroy\0"
    signal_delete_event: .ascii "delete_event\0"
    signal_clicked: .ascii "clicked\0"

    app_id: .ascii "gnome-example\0"
    app_version: .ascii "1.000\0"
    app_title: .ascii "Gnome Example Program\0"

    button_quit_text: .ascii "Quit the program!\0"
    quit_question: .ascii "Are you sure you want to quit?\0"

.section .bss

    .equ WORD_SIZE, 4
    .lcomm app_ptr, WORD_SIZE
    .lcomm btn_quit, WORD_SIZE

.section .text

.globl main
.type main, @function
main:
    pushl %ebp
    movl %esp, %ebp

# Initialize GNOME libraries
    pushl 12(%ebp)          # argv
    pushl 8(%ebp)           # argc
    pushl $app_version
    pushl $app_id
    call gnome_init
    addl $16, %esp

# Create new application window
    pushl $app_title
    pushl $app_id
    call gnome_app_new
    addl $8, %esp
    movl %eax, app_ptr

# Create button
    pushl $button_quit_text
    call gtk_button_new_with_label
    addl $4, %esp
    movl %eax, btn_quit

# Put button inside window
    pushl btn_quit
    pushl app_ptr
    call gnome_app_set_contents
    addl $8, %esp

# Make button visible
    pushl btn_quit
    call gtk_widget_show
    addl $4, %esp

# Make app window visible
    pushl app_ptr
    call gtk_widget_show
    addl $4, %esp

# Wire up delete_handler function for "delete" event
    pushl $NULL                 # Extra data to pass with event
    pushl $delete_handler       # Callback
    pushl $signal_delete_event  # Signal type
    pushl app_ptr
    call gtk_signal_connect
    addl $16, %esp

# Wire up destroy_handler function for "destroy" event
    pushl $NULL
    pushl $destroy_handler
    pushl $signal_destroy
    pushl app_ptr
    call gtk_signal_connect
    addl $16, %esp

# Wire up click_handler function for "click" event on the button
    pushl $NULL
    pushl $click_handler
    pushl $signal_clicked
    pushl btn_quit
    call gtk_signal_connect
    addl $16, %esp

# Transfer control to GNOME
    call gtk_main

# Exit program
    movl $0, %eax
    leave
    ret


# This happens when the app window is destroyed
destroy_handler:
    pushl %ebp
    movl %esp, %ebp

# Tell GTK to exit event loop (end program)
    call gtk_main_quit

    movl $0, %eax
    leave
    ret


# This is called when the app window is closed
delete_handler:
    movl $1, %eax
    ret


# This is called when the button is clicked
click_handler:
    pushl %ebp
    movl %esp, %ebp

# Display the confirmation dialog
    pushl $NULL
    pushl $GNOME_STOCK_BUTTON_NO
    pushl $GNOME_STOCK_BUTTON_YES
    pushl $GNOME_MESSAGE_BOX_QUESTION
    pushl $quit_question
    call gnome_message_box_new
    addl $16, %esp

# (eax now holds the dialog's pointer)

# Make the dialog modal
    pushl $1
    pushl %eax
    call gtk_window_set_modal
    popl %eax
    addl $4, %esp

# Show dialog
    pushl %eax
    call gtk_widget_show
    popl %eax

# Run the dialog until it's closed
    pushl %eax
    call gnome_dialog_run_and_close
    addl $4, %esp

# Button 0 is yes. Quit in that case, otherwise do nothing.
    cmpl $0, %eax
    jne click_handler_end

    call gtk_main_quit

click_handler_end:
    leave
    ret
