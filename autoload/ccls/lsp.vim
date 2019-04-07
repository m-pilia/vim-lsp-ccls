" Handle a response from vim-lsp
function! s:vim_lsp_handler(handler, data) abort
    if lsp#client#is_error(a:data.response)
        echoerr 'LSP error'
        return
    endif
    call a:handler(a:data.response.result)
endfunction

" Make a request to the lsp server
" Try to automatically find an available LSP client
function! ccls#lsp#request(filetype, method, params, handler) abort
    if exists('*lsc#server#call')
        " Use vim-lsc
        call lsc#server#call(a:filetype, '$ccls/' . a:method, a:params, a:handler)
    elseif exists('*lsp#send_request')
        " Use vim-lsp
        let l:available_servers = lsp#get_server_names()
        if len(l:available_servers) == 0 || count(l:available_servers, 'ccls') == 0
            echoerr 'ccls language server unvailable'
            return
        endif

        let l:request = {
        \   'method': '$ccls/' . a:method,
        \   'params': a:params,
        \   'on_notification': function('s:vim_lsp_handler', [a:handler]),
        \ }

        call lsp#send_request('ccls', l:request)
    end
endfunction
