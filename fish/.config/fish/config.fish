if status is-interactive
  # fish_vi_colemak_key_bindings

  # settings
  set fish_greeting
  set -gx EDITOR nvim

  # start
  zoxide init fish | source
end
