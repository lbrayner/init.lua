if !exists(":Delete")
    finish
endif

" The Delete command is a noop and Remove, an alias to Delete

cnoreabbrev Delete echom "Oops! Not what I meant."
cnoreabbrev Remove Delete
