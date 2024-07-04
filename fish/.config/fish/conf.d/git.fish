# This file uses code from the following repositories (all of which are MIT licensed)

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh 
# https://github.com/jhillyerd/plugin-git/tree/master/functions

# Because I don't want to use the extension manager, I didn't copy the code in the repository below

function __git_current_branch -d "Output git's current branch name"
  begin
    git symbolic-ref HEAD; or \
    git rev-parse --short HEAD; or return
  end 2>/dev/null | sed -e 's|^refs/heads/||'
end

function __git_default_branch -d "Use init.defaultBranch if it's set and exists, otherwise use main if it exists. Falls back to master"
  command git rev-parse --git-dir &>/dev/null; or return
  if set -l default_branch (command git config --get init.defaultBranch)
    and command git show-ref -q --verify refs/heads/{$default_branch}
    echo $default_branch
  else if command git show-ref -q --verify refs/heads/main
    echo main
  else
    echo master
  end
end

alias ggpur  'ggu'
alias g      'git'
alias ga     'git add'
alias gaa    'git add --all'
alias gapa   'git add --patch'
alias gau    'git add --update'
alias gav    'git add --verbose'
alias gam    'git am'
alias gama   'git am --abort'
alias gamc   'git am --continue'
alias gamscp 'git am --show-current-patch'
alias gams   'git am --skip'
alias gap    'git apply'
alias gapt   'git apply --3way'
alias gbs    'git bisect'
alias gbsb   'git bisect bad'
alias gbsg   'git bisect good'
alias gbsn   'git bisect new'
alias gbso   'git bisect old'
alias gbsr   'git bisect reset'
alias gbss   'git bisect start'
alias gbl    'git blame -w'
alias gb     'git branch'
alias gba    'git branch --all'
alias gbd    'git branch --delete'
alias gbD    'git branch --delete --force'

function gwip -d 'git commit a work-in-progress branch'
  git add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit -m "--wip--" --no-verify
end

function gbds -d "Delete all branches merged in current HEAD, including squashed"
  git branch --merged | \
    command grep -vE  '^\*|^\s*(master|main|develop)\s*$' | \
    command xargs -r -n 1 git branch -d

  set -l default_branch (__git_default_branch)
  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch
      set -l merge_base (git merge-base $default_branch $branch)
      if string match -q -- '-*' (git cherry $default_branch (git commit-tree (git rev-parse $branch\^{tree}) -p $merge_base -m _))
        git branch -D $branch
      end
    end
end

alias gbgd   'git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -d'
alias gbgD   'git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -D'
alias gbm    'git branch --move'
alias gbnm   'git branch --no-merged'
alias gbr    'git branch --remote'
alias ggsup  'git branch --set-upstream-to=origin/(__git_current_branch)'
alias gbg    'git branch -vv | grep ": gone\]"'
alias gco    'git checkout'
alias gcor   'git checkout --recurse-submodules'
alias gcb    'git checkout -b'
alias gcB    'git checkout -B'
alias gcd    'git checkout develop'
alias gcm    'git checkout (__git_default_branch)'
alias gcp    'git cherry-pick'
alias gcpa   'git cherry-pick --abort'
alias gcpc   'git cherry-pick --continue'
alias gclean 'git clean --interactive -d'
alias gcl    'git clone --recurse-submodules'
alias gclf   'git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'

alias gcam   'git commit --all --message'
alias gcas   'git commit --all --signoff'
alias gcasm  'git commit --all --signoff --message'
alias gcs    'git commit --gpg-sign'
alias gcss   'git commit --gpg-sign --signoff'
alias gcssm  'git commit --gpg-sign --signoff --message'
alias gcmsg  'git commit --message'
alias gcsm   'git commit --signoff --message'
alias gc     'git commit --verbose'
alias gca    'git commit --verbose --all'
alias gca!   'git commit --verbose --all --amend'
alias gcan!  'git commit --verbose --all --no-edit --amend'
alias gcans! 'git commit --verbose --all --signoff --no-edit --amend'
alias gcann! 'git commit --verbose --all --date=now --no-edit --amend'
alias gc!    'git commit --verbose --amend'
alias gcn!   'git commit --verbose --no-edit --amend'
alias gcf    'git config --list'
alias gdct   'git describe --tags (git rev-list --tags --max-count=1)'
alias gd     'git diff'
alias gdca   'git diff --cached'
alias gdcw   'git diff --cached --word-diff'
alias gds    'git diff --staged'
alias gdw    'git diff --word-diff'

function gdv
  git diff -w "$argv" | view -
end

function gdnl
  git diff "$argv" ":(exclude)package-lock.json" ":(exclude)*.lock"
end

alias gdt    'git diff-tree --no-commit-id --name-only -r'
alias gf     'git fetch'
alias gfa    'git fetch --all --prune'
alias gfo    'git fetch origin'
alias gg     'git gui citool'
alias gga    'git gui citool --amend'
alias ghh    'git help'
alias glgg   'git log --graph'
alias glgga  'git log --graph --decorate --all'
alias glgm   'git log --graph --max-count=10'
alias glods  'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glod   'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glola  'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols  'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias glol   'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glo    'git log --oneline --decorate'
alias glog   'git log --oneline --decorate --graph'
alias gloga  'git log --oneline --decorate --graph --all'

# Pretty log messages
function _git_log_prettily
  if not test -z $argv[1]
    git log --pretty=$argv[1]
  end
end

alias glp    '_git_log_prettily'
alias glg    'git log --stat'
alias glgp   'git log --stat --patch'
alias gign   'git ls-files -v | grep "^[[:lower:]]"'
alias gfg    'git ls-files | grep'
alias gm     'git merge'
alias gma    'git merge --abort'
alias gmc    'git merge --continue'
alias gms    'git merge --squash'
alias gmom   'git merge origin/(__git_default_branch)'
alias gmum   'git merge upstream/(__git_default_branch)'
alias gmtl   'git mergetool --no-prompt'
alias gmtlvi 'git mergetool --no-prompt --tool=vimdiff'

alias gl     'git pull'
alias gpr    'git pull --rebase'
alias gprv   'git pull --rebase -v'
alias gpra   'git pull --rebase --autostash'
alias gprav  'git pull --rebase --autostash -v'
alias gll    'git pull origin'
alias ggl    'git pull origin (__git_current_branch)'

alias gprom  'git pull --rebase origin (__git_default_branch)'
alias gpromi 'git pull --rebase=interactive origin (__git_default_branch)'
alias ggpull 'git pull origin (__git_default_branch)'

alias gluc   'git pull upstream (__git_current_branch)'
alias glum   'git pull upstream (__git_default_branch)'
alias gp     'git push'
alias gpd    'git push --dry-run'
alias ggp    'git push origin (__git_current_branch)'
alias ggp!   'git push origin (__git_current_branch) --force-with-lease'

alias gpf!   'git push --force'
alias gpf    'git push --force-with-lease --force-if-includes'

alias gpsup  'git push --set-upstream origin (__git_current_branch)'
alias gpsupf 'git push --set-upstream origin (__git_current_branch) --force-with-lease --force-if-includes'
alias gpv    'git push --verbose'
alias gpoat  'git push origin --all && git push origin --tags'
alias gpod   'git push origin --delete'
alias ggpush 'git push origin (__git_current_branch)'

alias gpu       'git push upstream'
alias grb       'git rebase'
alias grba      'git rebase --abort'
alias grbc      'git rebase --continue'
alias grbi      'git rebase --interactive'
alias grbo      'git rebase --onto'
alias grbs      'git rebase --skip'
alias grbd      'git rebase develop'
alias grbm      'git rebase (__git_default_branch)'
alias grbom     'git rebase origin/(__git_default_branch)'
alias grf       'git reflog'
alias gr        'git remote'
alias grv       'git remote --verbose'
alias gra       'git remote add'
alias grrm      'git remote remove'
alias grmv      'git remote rename'
alias grset     'git remote set-url'
alias grup      'git remote update'
alias grh       'git reset'
alias gru       'git reset --'
alias grhh      'git reset --hard'
alias grhk      'git reset --keep'
alias grhs      'git reset --soft'
alias gpristine 'git reset --hard && git clean --force -dfx'
alias gwipe     'git reset --hard && git clean --force -df'
alias groh      'git reset origin/(__git_current_branch) --hard'
alias grs       'git restore'
alias grss      'git restore --source'
alias grst      'git restore --staged'
alias gunwip    'git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias grev      'git revert'
alias greva     'git revert --abort'
alias grevc     'git revert --continue'
alias grm       'git rm'
alias grmc      'git rm --cached'
alias gcount    'git shortlog --summary --numbered'
alias gsh       'git show'
alias gsps      'git show --pretty=short --show-signature'
alias gstall    'git stash --all'
alias gstaa     'git stash apply'
alias gstc      'git stash clear'
alias gstd      'git stash drop'
alias gstl      'git stash list'
alias gstp      'git stash pop'
alias gsta      'git stash push'
alias gsts      'git stash show --patch'
alias gst       'git status'
alias gss       'git status --short'
alias gsb       'git status --short --branch'
alias gsi       'git submodule init'
alias gsu       'git submodule update'
alias gsd       'git svn dcommit'
alias gsdp      'git svn dcommit && git push github (__git_default_branch):svntrunk'
alias gsr       'git svn rebase'
alias gsw       'git switch'
alias gswc      'git switch --create'
alias gswd      'git switch develop'
alias gswm      'git switch (__git_default_branch)'
alias gtam      'git tag --annotate'
alias gtsm      'git tag --sign'
alias gtvm      'git tag | sort -V'
alias gignore   'git update-index --assume-unchanged'
alias gunignore 'git update-index --no-assume-unchanged'
alias gwch      'git whatchanged -p --abbrev-commit --pretty=medium'
alias gwt       'git worktree'
alias gwta      'git worktree add'
alias gwtls     'git worktree list'
alias gwtmv     'git worktree move'
alias gwtrm     'git worktree remove'
alias gstu      'gsta --include-untracked'
alias gk        '\gitk --all --branches &!'
alias gke       '\gitk --all $(git log --walk-reflogs --pretty=%h) &!'

function gtl -d "List tags matching prefix" -a prefix
  git tag --sort=-v:refname -n -l $prefix\*
end
