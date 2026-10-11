#!/usr/bin/env bash
# Claude Code subagent rows: Catppuccin Mocha, matching ~/.claude/statusline.sh.
# Reads the visible rows as JSON on stdin and writes one {"id","content"} line per row.
exec jq -c --argjson now "$(date +%s)" '
  def fg(c): "\u001b[38;2;\(c)m";
  def bg(c): "\u001b[48;2;\(c)m";
  def rst: "\u001b[0m";
  def seg(c; s): {plain: s, ansi: (fg(c) + s + rst)};
  def tokens: if . >= 1000000 then "\(. / 100000 | floor / 10)M" elif . >= 1000 then "\(. / 100 | floor / 10)k" else tostring end;
  def elapsed: if . >= 3600 then "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m" elif . >= 60 then "\(. / 60 | floor)m\(. % 60)s" else "\(.)s" end;
  def spark: min as $lo | max as $hi | map(if $hi == $lo then 0 else (. - $lo) * 7 / ($hi - $lo) | floor end | [9601 + .] | implode) | join("");
  def truncate(n): if n < 1 then "" elif length > n then .[:n - 1] + "…" else . end;

  "17;17;27" as $crust | "205;214;244" as $text | "108;112;134" as $overlay
  | "203;166;247" as $mauve | "250;179;135" as $peach | "249;226;175" as $yellow
  | "166;227;161" as $green | "116;199;236" as $sapphire | "243;139;168" as $red
  | (.columns // 100) as $columns
  | .tasks[]
  | (.name // .agentType // "agent") as $name
  | (if .status == "running" then seg($sapphire; ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"][$now % 10])
     elif .status == "completed" then seg($green; "")
     elif .status == "failed" then seg($red; "")
     else seg($peach; "") end) as $status
  | {plain: " \($name) ", ansi: (bg($mauve) + fg($crust) + " \($name) " + rst)} as $pill
  | (if .contextWindowSize then (.tokenCount * 100 / .contextWindowSize | floor) else null end) as $pct
  | [ (.model // empty | seg($overlay; sub("^claude-"; "") | sub("-[0-9]{8}$"; ""))),
      seg(if $pct == null or $pct < 50 then $green elif $pct < 80 then $yellow else $red end;
          "󰍛 \(.tokenCount | tokens)" + (if $pct == null then "" else " \($pct)%" end)),
      ((.tokenSamples // []) | select(length > 1) | seg($sapphire; .[-8:] | spark)),
      (select(.status == "running") | seg($peach; " \($now - (.startTime / 1000 | floor) | elapsed)"))
    ] as $right
  | ($status.plain | length) + 1 + ($pill.plain | length) + 1 + ($right | map(2 + (.plain | length)) | add) as $fixed
  | {id, content: ([$status.ansi, " ", $pill.ansi, " ", fg($text), ((.label // .description // "") | truncate($columns - $fixed)), rst]
                   + ($right | map("  " + .ansi)) | join(""))}
'
