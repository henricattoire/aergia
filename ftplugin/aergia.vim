if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal noexpandtab
setlocal bufhidden=wipe " remove from bufferlist and <C-^>
