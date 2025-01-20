return {
  'mg979/vim-visual-multi',
  event = 'VeryLazy',
  init = function()
    vim.cmd([[
let g:VM_leader = {'default': ',', 'visual': ',', 'buffer': ','}
let g:VM_maps = {}
let g:VM_custom_motions = {'n': 'h', 'i': 'l', 'u': 'k', 'e': 'j', 'N': '0', 'I': '$', 'h': 'e'}
let g:VM_maps['i'] = 'k'
let g:VM_maps['I'] = 'K'
let g:VM_maps['Find Under'] = '<C-k>'
let g:VM_maps['Find Subword Under'] = '<C-k>'
let g:VM_maps['Add Cursor Down'] = '<M-down>'
let g:VM_maps['Add Cursor Up'] = '<M-up>'
]])
  end,
}
