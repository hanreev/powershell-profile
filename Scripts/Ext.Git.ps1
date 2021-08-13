# Git
function git_current_branch() {
  $ref = git symbolic-ref --quiet HEAD 2> $null
  if ($LASTEXITCODE -ne 0) {
    if ($LASTEXITCODE -eq 128) { return }
    $ref = git rev-parse --short HEAD 2> $null
    if (!$ref) { return }
  }
  return $ref -replace 'refs/heads/'
}

function git_main_branch {
  git rev-parse --git-dir 2>&1> $null
  if ($LASTEXITCODE -ne 0) {
    return
  }
  $branch = 'master'
  foreach ($b in 'main', 'trunk') {
    git show-ref -q --verify refs/heads/$b
    if ($LASTEXITCODE -eq 0) {
      $branch = $b
      break
    }
  }
  return $branch
}

# Git shortcuts
function g { git $args }
function ga { git add $args }
function gaa { git add --all $args }
function gapa { git add --patch $args }
function gau { git add --update $args }
function gav { git add --verbose $args }
function gap { git apply $args }
function gapt { git apply --3way $args }
function gb { git branch $args }
function gba { git branch -a $args }
function gbd { git branch -d $args }
function gbD { git branch -D $args }
function gbl { git blame -b -w $args }
function gbnm { git branch --no-merged $args }
function gbr { git branch --remote $args }
function gbs { git bisect $args }
function gbsb { git bisect bad $args }
function gbsg { git bisect good $args }
function gbsr { git bisect reset $args }
function gbss { git bisect start $args }
function gc { git commit -v $args }
function gc! { git commit -v --amend $args }
function gcn! { git commit -v --no-edit --amend $args }
function gca { git commit -v -a $args }
function gca! { git commit -v -a --amend $args }
function gcan! { git commit -v -a --no-edit --amend $args }
function gcans! { git commit -v -a -s --no-edit --amend $args }
function gcam { git commit -a -m $args }
function gcsm { git commit -s -m $args }
function gcas { git commit -a -s $args }
function gcasm { git commit -a -s -m $args }
function gcb { git checkout -b $args }
function gcf { git config --list $args }
function gcl { git clone --recurse-submodules $args }
function gclean { git clean -id $args }
function gpristine {
  git reset --hard
  if ($LASTEXITCODE -eq 0) {
    git clean -dffx
  }
}
function gcom { git checkout $(git_main_branch) $args }
function gcd { git checkout develop $args }
function gcmsg { git commit -m $args }
function gco { git checkout $args }
function gcor { git checkout --recurse-submodules $args }
function gcount { git shortlog -sn $args }
function gcp { git cherry-pick $args }
function gcpa { git cherry-pick --abort $args }
function gcpc { git cherry-pick --continue $args }
function gcs { git commit -S $args }
function gcss { git commit -S -s $args }
function gcssm { git commit -S -s -m $args }
function gd { git diff $args }
function gdca { git diff --cached $args }
function gdcw { git diff --cached --word-diff $args }
function gdct { git describe --tags $(git rev-list --tags --max-count=1) }
function gds { git diff --staged $args }
function gdt { git diff-tree --no-commit-id --name-only -r $args }
function gdw { git diff --word-diff $args }
function gf { git fetch }
function gfa { git fetch --all --prune }
function gfo { git fetch origin }
function gpsup { git push --set-upstream origin $(git_current_branch) }
function ghh { git help }
function gignore { git update-index --assume-unchanged }
function gignored { git ls-files -v | grep "^[[:lower:]]" }
function git_svn_dcommit_push {
  git svn dcommit
  if ($LASTEXITCODE -eq 0) {
    git push github $(git_main_branch):svntrunk
  }
}
function glg { git log --stat }
function glgp { git log --stat -p }
function glgg { git log --graph }
function glgga { git log --graph --decorate --all }
function glgm { git log --graph --max-count=10 }
function glo { git log --oneline --decorate }
function glol { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' }
function glols { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat }
function glod { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' }
function glods { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short }
function glola { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all }
function glog { git log --oneline --decorate --graph }
function gloga { git log --oneline --decorate --graph --all }
function glp {
  param(
    [Parameter(Mandatory = $true)]
    $PrettyFormat
  )
  git log --pretty=$PrettyFormat
}
function gm { git merge }
function gmom { git merge origin/$(git_main_branch) }
function gmt { git mergetool --no-prompt }
function gmtvim { git mergetool --no-prompt --tool=vimdiff }
function gmum { git merge upstream/$(git_main_branch) }
function gma { git merge --abort }
function gp! { git push }
function gpd { git push --dry-run }
function gpf { git push --force-with-lease }
function gpf! { git push --force }
function gpl { git pull }
function gpoat {
  git push origin --all
  if ($LASTEXITCODE -eq 0) {
    git push origin --tags
  }
}
function gpr { git pull --rebase }
function gpu { git push upstream }
function gpv { git push -v }
function gr { git remote }
function gra { git remote add }
function grb { git rebase }
function grba { git rebase --abort }
function grbc { git rebase --continue }
function grbd { git rebase develop }
function grbi { git rebase -i }
function grbm { git rebase $(git_main_branch) }
function grbo { git rebase --onto }
function grbs { git rebase --skip }
function grev { git revert }
function grh { git reset }
function grhh { git reset --hard }
function groh { git reset origin/$(git_current_branch) --hard }
function grm { git rm }
function grmc { git rm --cached }
function grmv { git remote rename }
function grrm { git remote remove }
function grs { git restore }
function grset { git remote set-url }
function grss { git restore --source }
function grst { git restore --staged }
function grt { Set-Location "$(git rev-parse --show-toplevel)" }
function gru { git reset -- }
function grup { git remote update }
function grv { git remote -v }
function gsb { git status -sb }
function gsd { git svn dcommit }
function gsh { git show }
function gsi { git submodule init }
function gsps { git show --pretty=short --show-signature }
function gsr { git svn rebase }
function gss { git status -s }
function gst { git status }
function gsta { git stash push }
function gstaa { git stash apply }
function gstc { git stash clear }
function gstd { git stash drop }
function gstl { git stash list }
function gstp { git stash pop }
function gsts { git stash show --text }
function gstu { gsta --include-untracked }
function gstall { git stash --all }
function gsu { git submodule update }
function gsw { git switch }
function gswc { git switch -c }
function gts { git tag -s }
function gtv { git tag | Sort-Object -CaseSensitive }
function gtl { git tag --sort=-v:refname -n -l '${1}*' }
function gunignore { git update-index --no-assume-unchanged }
function gunwip {
  if (git log -n 1 | Where-Object { $_ -match '.*--wip--.*' }) {
    git reset HEAD~1
  }
}
function gup { git pull --rebase }
function gupv { git pull --rebase -v }
function gupa { git pull --rebase --autostash }
function gupav { git pull --rebase --autostash -v }
function glum { git pull upstream $(git_main_branch) }
function gwch { git whatchanged -p --abbrev-commit --pretty=medium }
function gwip {
  git add -A
  git rm $(git ls-files --deleted 2> $null)
  git commit --no-verify --no-gpg-sign -m '--wip-- [skip ci]'
}
function gam { git am }
function gamc { git am --continue }
function gams { git am --skip }
function gama { git am --abort }
function gamscp { git am --show-current-patch }
