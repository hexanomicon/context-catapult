# ------------------------------------------------------------------------------
# TOOL:    CTX (Context Catapult)
# REPO:    https://github.com/hexanomicon/context-catapult
# LICENSE: MIT
# ------------------------------------------------------------------------------

function ctx --description "Context Catapult: The Ultimate LLM Workflow Tool"
    # ==============================================================================
    # ⚙️  CONFIGURATION
    # ==============================================================================
    set -l allowed_exts txt md py js ts go rs c cpp h hpp sh fish json yaml toml sql java rb css html jinja dockerfile vue svelte jsx tsx
    set -l special_files README.md Dockerfile Containerfile Makefile Justfile Cargo.toml package.json go.mod requirements.txt
    
    # 🗑️ TRASH LIST (Ignored in Tree/Find)
    set -l trash_patterns '.git' '.svn' '.hg' '.DS_Store' \
                          'node_modules' 'bower_components' \
                          'venv' '.venv' 'env' '.env' \
                          '__pycache__' '.pytest_cache' '.mypy_cache' '.ruff_cache' \
                          'dist' 'build' 'target' 'bin' 'obj' 'vendor' \
                          '.idea' '.vscode' 'coverage' '.github' \
                          'uv.lock' 'package-lock.json' 'yarn.lock' \
                          '*.png' '*.jpg' '*.jpeg' '*.gif' '*.webp' '*.ico' '*.svg' '*.zip' '*.tar' '*.gz' '*.pdf'

    # Defaults
    set -l def_bytes  1048576  # 1 MB
    set -l def_lines  2000     # 2000 Lines
    set -l def_depth  3        # Default Depth
    set -l def_print  20       # Max lines to print to console
    set -l state_file /tmp/ctx_last_batch.txt

    # ==============================================================================
    # 🎨 THE PALETTE
    # ==============================================================================
    set -l c_title  (set_color -o af5fff)  # Purple
    set -l c_info   (set_color -o 00e5ff)  # Blue
    set -l c_succ   (set_color -o 00ff9d)  # Green
    set -l c_warn   (set_color -o ffaf00)  # Gold
    set -l c_err    (set_color -o ff0000)  # Red
    set -l c_dim    (set_color 585858)     # Grey
    set -l c_reset  (set_color normal)

    set -l tree_ignore (string join '|' $trash_patterns)

    # ==============================================================================
    # 🕹️ ARGUMENTS
    # ==============================================================================
    argparse 'h/help' 'l/llm' 'a/all' 't/tree' 's/spy=' 'r/retry' 'x/xml' 'f/force' \
             'd/depth=' 'M/max-size=' 'P/print-limit=' 'no-recursive' -- $argv
    or return 1

    set -l print_limit $def_print
    if set -q _flag_print_limit; set print_limit $_flag_print_limit; end

    # ==============================================================================
    # 📝 MANUALS & PROTOCOLS
    # ==============================================================================
    set -l help_manual "
TOOL: CTX (Context Catapult)
Usage: ctx [options] [targets...]

DEFAULTS & OVERRIDES:
   • Depth:       $def_depth levels   (Override: -d <N> | 0=Root Only | -1=Infinite)
   • Max Lines:   $def_lines lines    (Override: -f / --force to bypass)
   • Max Size:    1 MB            (Override: -M <bytes>)
   • Print Limit: $def_print lines      (Override: -P <lines>)
   • Ignores:     .gitignore respected automatically (via 'fd').

MODES:
   1. EXTRACT (Default)  : Deep scan & copy content.
   2. SCOUT   (--tree)   : Visual directory map only.
   3. SPY     (--spy <N>): Read top <N> lines only (Headers/Imports).

EXAMPLES:
   ctx .                 # Interactive scan (Starts empty)
   ctx -d -1 src/        # Infinite scan of src/
   ctx -t -P 100         # Tree view, print up to 100 lines
   ctx -l                # Generate LLM Kickstart Protocol
"

    set -l llm_preamble "
CTX PROTOCOL INITIATED
======================
I am using the 'ctx' tool to feed you context incrementally.

YOUR DIRECTIVE:
1. ADOPT A 'CONTEXT-FIRST' MINDSET. Do not rush to solution.
2. ANALYZE the Map below. Build a mental model of the structure first.
3. STRATEGY (Load Slowly):
   - Start by Scouting: Use 'ctx -t -d <N> <path>' to see deeper structure.
   - Then Spy: Use 'ctx -s 50 <path>' to check headers of files.
   - Finally Extract: Use 'ctx <path>' only when you know what you need.
4. ITERATE. If you need more info, provide the 'ctx' commands to get it.
5. DO NOT HALLUCINATE. Ask for the data.
"

    # ==============================================================================
    # 🚀 MODE 1: HUMAN HELP
    # ==============================================================================
    if set -q _flag_help
        echo -e "Copying manual to clipboard..."
        echo -e "I am using the 'ctx' tool. Here is the manual:\n$help_manual" | fish_clipboard_copy
        echo -e "$c_title🔮 CTX MANUAL$c_reset\n$help_manual\n$c_succ✅ Copied to clipboard!$c_reset"; return
    end

    # ==============================================================================
    # 🤖 MODE 2: THE KICKSTART
    # ==============================================================================
    if set -q _flag_llm
        if not type -q tree; echo "$c_err❌ 'tree' missing.$c_reset"; return 1; end
        
        set -l targets
        if test (count $argv) -eq 0; set targets "."; else; set targets $argv; end
        set -l depth $def_depth
        if set -q _flag_depth; set depth $_flag_depth; end
        if test "$depth" -eq 0; set depth 1; end
        if test "$depth" -eq -1; set depth 100; end 

        set -l tmp (mktemp)
        echo -e "$llm_preamble\n\n--- TOOL MANUAL ---\n$help_manual\n" > $tmp
        echo "--- PROJECT MAP ---" >> $tmp
        for item in $targets
            if test -d "$item"
                tree -a -L $depth -I "$tree_ignore" "$item" >> $tmp
            else; echo "File: $item" >> $tmp; end
        end
        cat $tmp | fish_clipboard_copy; rm $tmp
        echo "$c_succ🚀 Protocol & Map copied! Paste to LLM.$c_reset"; return
    end

    # ==============================================================================
    # 🌲 MODE 3: SCOUTING (Tree)
    # ==============================================================================
    if set -q _flag_tree
        set -l depth $def_depth
        if set -q _flag_depth; set depth $_flag_depth; end
        if test "$depth" -eq 0; set depth 1; end
        if test "$depth" -eq -1; set depth 100; end
        
        set -l t_out (mktemp)
        tree -a -L $depth -I "$tree_ignore" $argv > $t_out
        cat $t_out | fish_clipboard_copy
        
        echo "$c_title🌲 Tree Map:$c_reset"
        set -l total_lines (wc -l < $t_out)
        if test $total_lines -gt $print_limit
            head -n $print_limit $t_out
            set -l diff (math $total_lines - $print_limit)
            echo "$c_dim... [and $diff other items] ...$c_reset"
        else
            cat $t_out
        end
        rm $t_out
        echo; echo "$c_succ✅ Copied to clipboard!$c_reset"; return
    end

    # ==============================================================================
    # 🔎 MODE 4: DISCOVERY (Smart Files/Dirs Split)
    # ==============================================================================
    set -l files
    if set -q _flag_retry
        if test -f $state_file; set files (cat $state_file)
        else; echo "$c_warn❌ No cache found.$c_reset"; return 1; end
    else
        set -l targets
        if test (count $argv) -eq 0; set targets "."; else; set targets $argv; end

        # 1. Split Files vs Directories
        set -l explicit_files
        set -l dirs_to_scan
        set -l fzf_select_cmd "" 

        for item in $targets
            if test -f "$item"
                set explicit_files $explicit_files "$item"
            else if test -d "$item"
                set dirs_to_scan $dirs_to_scan "$item"
            end
        end

        # 2. Configure Selection Behavior
        if test (count $explicit_files) -gt 0; set fzf_select_cmd ",load:select-all"; end
        if test (count $explicit_files) -eq 0; and test (count $dirs_to_scan) -gt 0; set fzf_select_cmd ""; end

        set -l depth $def_depth
        if set -q _flag_depth; set depth $_flag_depth; end
        if set -q _flag_no_recursive; set depth 0; end

        set -l raw (mktemp)

        # 3. Add Explicit Files
        if test (count $explicit_files) -gt 0
            for f in $explicit_files; echo "$f" >> $raw; end
        end

        # 4. Search Engine
        if test (count $dirs_to_scan) -gt 0
            if type -q fd || type -q fdfind
                 set -l fd_bin fd; if type -q fdfind; set fd_bin fdfind; end
                 
                 # Prepare Regex
                 set -l ext_group (string join '|' $allowed_exts)
                 set -l file_group (string join '|' $special_files)
                 set -l final_regex ".*\.($ext_group)\$|($file_group)\$"

                 # FIX: Use List for depth args to avoid passing empty strings
                 set -l depth_args
                 if test "$depth" -eq 0
                     set depth_args --max-depth 1
                 else if test "$depth" -gt 0
                     set depth_args --max-depth $depth
                 end
                 
                 # IMPORTANT: Pass dirs_to_scan as individual arguments
                 command $fd_bin --type f $depth_args --regex "$final_regex" $dirs_to_scan >> $raw
            else
                echo "$c_dim""mode: 🐢 Legacy 'find' (Install 'fd' for .gitignore support)$c_reset"
                set -l find_depth
                if test "$depth" -ne -1; set find_depth "-maxdepth" "$depth"; end
                if test "$depth" -eq 0; set find_depth "-maxdepth" "1"; end
                set -l find_exclude
                for junk in $trash_patterns; set find_exclude $find_exclude -not -path "*/$junk/*" -not -path "*/$junk"; end
                set -l find_inc \(; set -l f 1
                for s in $special_files; if test $f -eq 1; set find_inc $find_inc -name "$s"; set f 0; else; set find_inc $find_inc -o -name "$s"; end; end
                for e in $allowed_exts; set find_inc $find_inc -o -name "*.$e"; end; set find_inc $find_inc \)
                
                for d in $dirs_to_scan
                    find "$d" $find_depth -type f $find_exclude $find_inc >> $raw
                end
            end
        end
        
        # 5. Deduplicate
        set -l clean (cat $raw | sed 's|^\./||' | sort | uniq); rm $raw
        if test -z "$clean"; echo "$c_warn❌ No valid files found.$c_reset"; return 1; end

        # 6. Selection
        if set -q _flag_all
            echo "$c_dim""mode: ⚡ Auto-Select ALL$c_reset"; set files $clean
        else
            echo "$c_dim""mode: 🕵️  Manual Selection$c_reset"
            if type -q fzf
                set -l prev "bat --style=numbers --color=always {} 2>/dev/null; or head -n 50 {}"
                set files (string join \n $clean | fzf -m --preview "$prev" --bind "ctrl-a:select-all$fzf_select_cmd")
            else
                echo "$c_warn⚠️ FZF missing. Selecting ALL.$c_reset"; set files $clean
            end
        end
        if test -z "$files"; echo "$c_warn🚫 Aborted.$c_reset"; return; end
        string join \n $files > $state_file
    end

    # ==============================================================================
    # 🚜 MODE 5: THE CATAPULT (Extraction)
    # ==============================================================================
    set -l out (mktemp)
    set -l max_s $def_bytes; if set -q _flag_max_size; set max_s $_flag_max_size; end
    set -l valid_files
    
    echo "CTX Extraction | Path: $(pwd)" > $out
    if set -q _flag_spy; echo "Mode: SPY (Top $_flag_spy)" >> $out; end
    echo "Files: " >> $out; for f in $files; echo "- $f" >> $out; end
    echo -e "\n---\n" >> $out

    set -l skip 0
    for f in $files
        set -l s (wc -c < "$f" 2>/dev/null)
        set -l l (wc -l < "$f" 2>/dev/null)

        if test "$s" -gt "$max_s"
            echo "--- File: $f [SKIPPED - SIZE $s > $max_s] ---" >> $out; echo "" >> $out
            echo "$c_warn⚠️ Skip Size: $f$c_reset"; set skip (math $skip + 1); continue
        end
        if not set -q _flag_force; and not set -q _flag_spy
            if test "$l" -gt "$def_lines"
                echo "--- File: $f [SKIPPED - LINES $l > $def_lines] ---" >> $out
                echo "[Hint: Use 'ctx -f $f']" >> $out; echo "" >> $out
                echo "$c_warn⚠️ Skip Lines: $f$c_reset"; set skip (math $skip + 1); continue
            end
        end

        set valid_files $valid_files $f
        if set -q _flag_xml; echo "<document path=\"$f\">" >> $out
        else; echo "--- File: $f ---" >> $out; end

        if set -q _flag_spy
            head -n $_flag_spy $f >> $out; echo -e "\n[Truncated]" >> $out
        else; cat $f >> $out; end

        if set -q _flag_xml; echo "</document>" >> $out; end; echo "" >> $out
    end

    set -l c (wc -m < $out | string trim); set -l t (math "round($c / 4)")
    cat $out | fish_clipboard_copy; rm $out
    
    # --- VISUAL SUMMARY ---
    echo
    echo "$c_info📂 Included Files ("(count $valid_files)"):$c_reset"
    set -l count 0
    for f in $valid_files
        if test $count -lt $print_limit; echo "   $c_dim- $f$c_reset"; end
        set count (math $count + 1)
    end
    if test $count -gt $print_limit
        set -l diff (math $count - $print_limit); echo "   $c_dim... [and $diff other files] ...$c_reset"
    end
    
    echo
    echo -n "✨ $c_succ""Ready!$c_reset Chars: $c | Tokens: ~$t"
    if set -q _flag_spy; echo " [🕵️ Spy Mode: $_flag_spy lines]"; else; echo ""; end
    if test $skip -gt 0; echo "$c_err""   Skipped: $skip (Too large/long)$c_reset"; end
end