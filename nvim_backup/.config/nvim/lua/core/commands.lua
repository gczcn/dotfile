local create_command = vim.api.nvim_create_user_command

create_command('Wqa', 'wqa', {})
create_command('WQa', 'wqa', {})
create_command('WQA', 'wqa', {})
create_command('Wq', 'wq', {})
create_command('WQ', 'wq', {})
create_command('Q', 'q', {})
create_command('Q1', 'q!', {})

-- toggle background
create_command('TB', 'lua vim.o.background = vim.o.background == "dark" and "light" or "dark"', {})
