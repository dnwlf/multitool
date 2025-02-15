# ~/.zshrc

setopt prompt_subst

ASYNC_PROC=0

precmd() {
  function async() {
    # save to temp file
    printf "%s" "$(git_prompt_string) $(kube_context_string)" > "/tmp/zsh_prompt_$$"

    # signal parent
    kill -s USR1 $$
  }

  # do not clear RPROMPT, let it persist

  # kill child if necessary
  if [[ "${ASYNC_PROC}" != 0 ]]; then
    kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
  fi

  # start background computation
  async &!
  ASYNC_PROC=$!
}

function TRAPUSR1() {
  # read from temp file
  RPROMPT="$(cat /tmp/zsh_prompt_$$)"

  # reset proc number
  ASYNC_PROC=0

  # redisplay
  zle && zle reset-prompt
}

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

function parse_git_detached() {
  if ! git symbolic-ref HEAD >/dev/null 2>&1; then
    echo "!"
  fi
}

# Show different symbols as appropriate for various Git repository states
function parse_git_state() {
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local GIT_PROMPT_AHEAD="+NUM"
  local GIT_PROMPT_BEHIND="-NUM"

  # commits ahead
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  # commits behind
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    if [[ -n $GIT_STATE ]]; then
      GIT_STATE="$GIT_STATE "
    fi
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  # merging
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    if [[ -n $GIT_STATE ]]; then
      GIT_STATE="$GIT_STATE "
    fi
    GIT_STATE=$GIT_STATE"x"
  fi

  # untracked
  if [[ -n $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]]; then
    GIT_DIFF="u"
  fi

  # modified
  if ! git diff --quiet 2> /dev/null; then
    GIT_DIFF=$GIT_DIFF"m"
  fi

  # staged
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_DIFF=$GIT_DIFF"s"
  fi

  if [[ -n $GIT_STATE && -n $GIT_DIFF ]]; then
    GIT_STATE="$GIT_STATE "
  fi
  GIT_STATE="$GIT_STATE$GIT_DIFF"

  if [[ -n $GIT_STATE ]]; then
    echo "($GIT_STATE)"
  fi
}

# if inside a git repository, print its branch and state
function git_prompt_string() {
  if [[ -n $ZSH_PROMPT_DISABLE_GIT_INFO ]]; then
    return
  fi

  local git_where="$(parse_git_branch)"
  local git_detached="$(parse_git_detached)"
  [ -n "$git_where" ] && echo "%F{magenta}${git_where#(refs/heads/|tags/)}$git_detached%F{cyan}$(parse_git_state)%f"
}

# gets current kubectl context
function kube_context_string() {
  if [[ -n $ZSH_PROMPT_DISABLE_KUBE_INFO ]]; then
    return
  fi

  # use yq instead of kubectl, if possible
  if [[ "$(which yq)" == "" ]]; then
    kube_context=$(yq -e '.current-context' ${KUBECONFIG:-$HOME/.kube/config})
  else
    kube_context=$(kubectl config current-context 2>/dev/null)
  fi



  # shorten the gke cluster contexts to the last segment
  if [[ $kube_context =~ ^gke ]]; then
    kube_context="${kube_context##*_}"
  fi

  echo "%F{blue}${kube_context}%f"
}

PROMPT='%F{8}%2~ %(?.%F{green}.%F{red})%#%f '
RPROMPT='' # set asynchronously and dynamically

# load exports and aliases
for file in ~/.{exports,aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
