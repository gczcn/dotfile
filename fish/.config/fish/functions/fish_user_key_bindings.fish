function fish_user_key_bindings
  fish_vi_key_bindings

  bind -s --preset -m insert k repaint-mode
  bind -s --preset -m insert K beginning-of-line repaint-mode

  bind -s --preset -M default n backward-char
  bind -s --preset -M default i forward-char
  bind -s --preset -M default N beginning-of-line
  bind -s --preset -M default I end-of-line

  bind -s --preset l undo

  bind -s --preset u up-or-search
  bind -s --preset e down-or-search
  bind -s --preset h forward-single-char forward-word backward-char
  bind -s --preset H forward-bigword backward-char

  bind -s --preset dkw forward-single-char forward-single-char backward-word kill-word
  bind -s --preset dkW forward-single-char forward-single-char backward-bigword kill-bigword
  bind -s --preset -m insert ckw forward-single-char forward-single-char backward-word kill-word repaint-mode
  bind -s --preset -m insert ckW forward-single-char forward-single-char backward-bigword kill-bigword repaint-mode
  bind -s --preset ykw forward-single-char forward-single-char backward-word kill-word yank
  bind -s --preset ykW forward-single-char forward-single-char backward-bigword kill-bigword yank

  # visual mode
  bind -s --preset -M visual n backward-char
  bind -s --preset -M visual i forward-char
  bind -s --preset -M visual u up-line
  bind -s --preset -M visual e down-line

  bind -s --preset -M visual h forward-word
  bind -s --preset -M visual H forward-bigword
end
