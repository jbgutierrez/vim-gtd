if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn match gtdImportant "important"
syn match gtdUrgent "urgent"
syn region gtdDone start='\v^\s+\d{8}' end="$"

hi def link gtdDone Comment
hi def link gtdImportant Todo
hi def link gtdUrgent Type

let b:current_syntax = "gtd"
