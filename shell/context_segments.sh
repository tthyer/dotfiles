# Cheap context lookups for prompts/statuslines.
#
# These read config files directly instead of spawning `az`/`kubectl`, which
# take ~0.7-1.4s each. File reads are ~5-8ms, so they're safe to call on every
# prompt render. Each function prints its value (or nothing) and never errors.

amp_az() {
  jq -r '.subscriptions[] | select(.isDefault == true) | .name' \
    "$HOME/.azure/azureProfile.json" 2>/dev/null
}

amp_k8s() {
  local ctx ns
  ctx=$(yq -r '.current-context // ""' "$HOME/.kube/config" 2>/dev/null) || return 0
  [[ -z "$ctx" ]] && return 0
  ns=$(yq -r ".contexts[] | select(.name == \"$ctx\") | .context.namespace // \"\"" \
    "$HOME/.kube/config" 2>/dev/null)
  if [[ -n "$ns" ]]; then
    printf '%s/%s' "$ctx" "$ns"
  else
    printf '%s' "$ctx"
  fi
}

amp_env() {
  printf '%s' "${AMPERON_ENV:-}"
}
