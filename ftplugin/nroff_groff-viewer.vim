" vim-groff-viewer: Displays groff files in document viewer
" Last Change:	2022 Sep 10
" Maintainer:	gene@preciouschicken.com
" License:	Apache-2.0
" URL: https://github.com/PreciousChicken/vim-groff-viewer


" TODO: From help:
" <		Can also be used as a |method|: >
" 			GetText()->writefile("thefile")

" Disabling option per :help write-filetype-plugin
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" Creates temp file for buffer
let b:tempName = tempname()

" If user has not specified groff viewer (e.g. Zathura) then uses xdg-open
if ! exists('g:groffviewer_default')
    let g:groffviewer_default = 'xdg-open'
endif

" If user has not specified groff options then sets nil
if ! exists('g:groffviewer_options')
    let g:groffviewer_options = ' '
endif

" function! s:GetText()
" 	echom "In get text"
" 	let text = "hello file"
" 	return text
" endfunction

" Runs groff to produce postscript temp file
function! s:SaveTempPS(options)
	let fullPath = expand('%:p')
	" reads macro package (e.g. ms, mom) from file extension
	let macro = expand('%:e')
	execute "silent !groff -m " . macro . " " . a:options . " '" . fullPath . "' > " . b:tempName
endfunction

" Opens viewer loads temp file
function! OpenViewer()
	call s:SaveTempPS(g:groffviewer_options)
	execute "silent !" . g:groffviewer_default . " " . b:tempName . " &"
	redraw
	echom "Opening " . expand('%:t') . " with " . g:groffviewer_default . " viewer."
endfunction

" Runs groff to produce ps on printer
function! PrintPS()
	call s:SaveTempPS(g:groffviewer_options)
	execute "silent !lp " . b:tempName
	redraw
	echom "Printing " . expand('%:t') . "."
endfunction

" Produces temp file with no options, presents word and line count to user
function! CountWords()
	" see :help getlines
	let start = line('.')
	let end = search("^$") - 1
	let lines = getline(start, end)
	echom lines
	" let blob = readfile("blob.txt")
	" let blob = 0z + "hi there"
	" call writefile(blob, "hello.txt")
	call s:SaveTempPS(" ")
	let l:words = split(system("! ps2ascii " . b:tempName . " | wc -l -w", " "))
	" let l:words2 = split(system("silent !groff -m " . macro . " -T utf8 '" . fullPath . "' | wc -l -w", " "))
	redraw
	" echom "Words: " . l:words[1] . ", Lines: " . l:words[0] . "Words2: " . l:words2[1] . ", Lines2: " . l:words2[0]
	echom "Words: " . l:words[1] . ", Lines: " . l:words[0]
	call s:SaveTempPS(g:groffviewer_options)
endfunction

nnoremap <Leader>o :call OpenViewer()<CR>
nnoremap <Leader>p :call PrintPS()<CR>
nnoremap <Leader>wc :call CountWords()<CR>

" Runs SaveTempPS on user :w command
augroup savetemp
	autocmd!
	autocmd BufWritePost <buffer> call s:SaveTempPS(g:groffviewer_options)
augroup end

