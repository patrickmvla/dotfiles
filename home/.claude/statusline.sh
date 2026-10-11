#!/usr/bin/env bash
# Claude Code status line: Catppuccin Mocha powerline segments, matching ~/.config/starship.toml.
input=$(cat)

IFS=$'\t' read -r model dir ctx cost < <(jq -r '[
  .model.display_name // "claude",
  .workspace.current_dir // .cwd // "",
  (.context_window.used_percentage // "" | if . == "" then "" else (. | floor | tostring) end),
  (.cost.total_cost_usd // "" | if . == "" then "" else (. * 100 | round / 100 | tostring) end)
] | @tsv' <<<"$input")

branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null)

crust='17;17;27'
mauve='203;166;247' peach='250;179;135' yellow='249;226;175' green='166;227;161' sapphire='116;199;236'

segments=() colors=()
add() { colors+=("$1"); segments+=("$2"); }
add "$mauve" $'\U000f06a9'" $model"
add "$peach" $'\uf07c'" ${dir/#$HOME/\~}"
[[ -n $branch ]] && add "$yellow" $'\ue0a0'" $branch"
[[ -n $ctx ]] && add "$green" $'\U000f035b'" ${ctx}%"
[[ -n $cost ]] && add "$sapphire" "\$${cost}"

out=$'\e[38;2;'"${colors[0]}"$'m\ue0b6'
for i in "${!segments[@]}"; do
  out+=$'\e[48;2;'"${colors[i]}"$'m\e[38;2;'"$crust"'m '"${segments[i]}"' '
  if [[ -n ${colors[i+1]} ]]; then
    out+=$'\e[38;2;'"${colors[i]}"$'m\e[48;2;'"${colors[i+1]}"$'m\ue0b0'
  else
    out+=$'\e[0m\e[38;2;'"${colors[i]}"$'m\ue0b4\e[0m'
  fi
done
printf '%s\n' "$out"
