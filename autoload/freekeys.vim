" TODO: {{{
"
" Add `c-g` as a prefix with warning; same thing for `+` and `-`
"
" ---
"
" Look  at all  the 'default_mappings'  mappings, and  see if  some of  them are
" useless, or only useful with a count.
" If there are, add them as free keys (with warnings).
" Example: `go`, useful with a count, useless without
"
" I've removed `go` from the default keys (inside `s:default_mappings()`), but
" I haven't added a warning for it.  To do.
"
" ---
"
" Improve help:
"
"    - readibility
"    - sections by mode
"    - integrate most of the comments which are in this file, and in our notes
"
" ---
"
" Add `op+*`, `op+#` but with warning.
"
" Although  these syntaxes  are valid,  I'm not  sure one  would use  them often
" because `*` and `#` are much more unpredictable than `2j` or `3k` for example.
" We don't systematically see all the text between current position and the next
" occurrence of the current word.
"
" Check if there are other  unpredictable `operator + motions` combinations like
" `c*`, `!*`, which would be rarely used; add them with warnings
"
" Also, I think, ` `, `CR`, `BS` could be used after an op.
" We wouldn't lose anything.  There must be synonym syntaxes.  To be verified.
"
" ---
"
" Add `<+char`, `>+char` in visual mode.
"
" ---
"
" Add other  control characters in  normal mode `C-k` is  not the only  one, for
" example `C-j` is a synonym for `j`.
"
" ---
"
" Find invalid syntaxes for insert/visual/Ex/operator-pending mode.
"
" ---
"
" After executing  `:FK -nomapcheck`, if  we hit `gh`  twice, a `Leader`  is added.
" Specifically, `CTRL-Space` becomes `CTRL-Leader`.
"
" ---
"
" Can we use the  same command (`x`, `a`, `i`, `m`, `o`, ...)  as a suffix for a
" normal command, and as a prefix for an object?
"
" The {lhs} in normal mode can be used as an operator or not.
" It can be prefixed by an operator or not.
" 2 * 2 possibilities = 4
"
"     Zi is a cmd    o_iw = pb?   NO, because `Ziw` has no meaning; neither Z nor Zi are ops
"     Zi "  an op    o_iw "       NO, because `Ziw` and `Ziiw` both work
"
"     cX "  a cmd    o_Xw "       YES, we can't type `cXw`, the command `cX`
"                                 shadows the operator `c` + the object `Xw`
"
"     cx "  an op    o_xw "       YES, we can't type `c`+`xw` because `cx`  shadows `c`
"                                 and we can't type `cx`+`xw` because `cxx` shadows `cxxw`
"
"                                 The 2 last problems are the consequence of how
"                                 Vim process the typed keys.
"                                 It doesn't invoke an operator until there's no
"                                 ambiguity anymore regarding the operator.
"                                 And as soon as it recognizes an operator without
"                                 ambiguity, it invokes it.
"
" ---
"
" The previous section  is to be reviewed further.  In  particular, I'm not sure
" of what the rules are regarding the processing of typed keys.
" For example, forget the meaning of the keys, and suppose we have:
"
"    ab   = op
"    cdef = object
"
"    abcd = op
"    ef   = object
"
" When we type `abcdef`, what happens?
"
"     ab   + cdef
" OR
"     abcd + ef
"
" Answer:
"
" Vim  processes  `abcd`  as  the  operator  iff  the  keys  are  pressed  under
" `&timeoutlen` ms.
" Otherwise,  it processes  `ab`  as the  operator iff  the  keys pressed  under
" `&timeoutlen` ms.
"
" MWE:
"
"     set showcmd
"
"     nno ab <cmd>set opfunc=FuncA<cr>g@
"     fu FuncA(_)
"         echo 'ab'
"     endfu
"     ono cdef <cmd>norm V<cr>
"
"     nno abcd <cmd>set opfunc=FuncB<cr>g@
"     fu FuncB(_)
"         echo 'abcd'
"     endfu
"     ono ef <cmd>norm V<cr>
"
" ---
"
" All in all, the syntax for operator-pending mode seems very tricky.
" It's probably  best to use  only `i` and  `a` as prefixes  in operator-pending
" mode.  And maybe even remove `prefix + i/a` (better be safe than sorry).
" Or not.  Vim uses `zi` by default, so `prefix + i/a` should be safe to keep.
"
" ---
"
" In the help, remove the color names,  replace them with some text colored with
" the proper HG; because the names don't match what we've written.
"  For example, the "red" mappings are not red when my colorscheme is dark, they
"  are orange.
"
" ---
"
" We've omitted one syntax:
"
"     command which expects an argument (like `q`, `r`, ...) + invalid argument
"
" For example, `q C-a` is an invalid key sequence, thus free.
"
" ---
"
" `:FreeKeys` ignores free sequences beginning with `m`, `'` and `@`.
" This is because it thinks it would introduce a timeout with some of our custom
" mappings.
" In reality, there would  be no timeout, because `m`, `'`  and `@` mappings are
" special: they ask for an argument.
" Check whether we have other similar special mappings causing `:Freekeys` to ignore
" whole families of mappings:
"
"     verb filter /^.$/ map
"     g/last set from/d_
"     g/^<plug>/d_
"
" How to handle the issue?
" Maybe we  should take  the habit of  executing `:Freekeys  -nomapcheck` (we've
" added a `-K` mapping for that).
"}}}
" The algorithm deliberately omits special keys: {{{
"
"     <F1> ... <F9>
"     <BS>
"     <Del>
"     <Home>
"     <End>
"     <Left>
"     <Right>
"     <Down>
"     <Up>
"     <PageDown>
"     <PageUp>
"     <LeftMouse>
"     <RightMouse>
"     <MiddleMouse>
"     <ScrollWheelDown>
"     <ScrollWheelUp>
"     <ScrollWheelLeft>
"     <ScrollWheelRight>
"     ...
"
" If we wanted to add these, to find the syntaxes leading to meaningless
" sequences, we would have to consider 2 cases:
"
"   - the special key is mapped by default to a command:
"
"         prefix + special key
"         op     + special key
"
"   - it isn't mapped to anything:
"
"         special key + anything (including nothing)
"
" We also omit the digits.
" If we wanted to include them, there would be only two possible syntaxes:
"
"     prefix + digit
"     digit  + prefix + digit
"
" `g8` and `8g8` are 2 default examples of these syntaxes.
"
" Finally, if we break a default motion/command/operator, it also creates
" new free keys.
" For example, if we use `Space` as the Leader key, then we should consider
" it as a prefix.
" In normal mode, a prefix can be used to produce meaningless sequences, in 2 syntaxes:
"
"     pfx + char    obvious, that's why we chose a Leader key in the first place
"     op  + pfx     NEW
"
" So, now we can use `d Space`, `y Space`, `c Space` ...
"}}}

" Interface {{{1
fu freekeys#main(args = '') abort "{{{2
    let args = split(a:args)
    let s:options = {
        \ 'mode': matchstr(a:args, '-mode\s\+\zs\%(\w\|-\)\+'),
        \ 'nospecial': index(args, '-nospecial') >= 0,
        \ 'nomapcheck': index(args, '-nomapcheck') >= 0,
        \ 'noleader': index(args, '-noleader') >= 0,
        \ }

    if empty(s:options.mode)
        let s:options.mode = 'normal'
    endif

    let categories = s:categories()
    let candidates = s:candidates(categories)
    let default_mappings = s:default_mappings(categories)
    let free = s:is_unmapped(candidates, default_mappings)

    call s:display(free)
endfu

fu freekeys#complete(arglead, cmdline, pos) abort "{{{2
    let from_dash_to_cursor = matchstr(a:cmdline, '.*\s\zs-.*\%' .. (a:pos + 1) .. 'c')

    if from_dash_to_cursor =~# '^-mode\s*'
        let modes =<< trim END
            normal
            visual
            operator-pending
            insert
            command-line
        END
        return join(modes, "\n")

    elseif empty(a:arglead) || a:arglead[0] is# '-'
        let options =<< trim END
            -noleader
            -nomapcheck
            -nospecial
            -mode
        END
        return join(options, "\n")
    endif

    return ''
endfu
"}}}1
fu s:categories() abort "{{{1
    let mode = s:options.mode
    let noleader = s:options.noleader

    let categories = {
        \ 'prefixes': ['"', '@', 'm', "'", '`', '[', ']', 'Z', '\', 'g', 'z', '|'],
        \ 'commands': !&tildeop ? ['~'] : [],
        \ 'operators': ['!', '<', '=', '>', 'c', 'd', 'y'] + (&tildeop ? ['~'] : []),
        \ 'operators_linewise': ['!', '<', '=', '>'],
        \ }

    " we add `U` as a prefix in normal mode
    " `u` and `C-r` could be used to handle undo operations
    "
    " we also add `Leader` as a prefix, unless the `-noleader` argument was
    " passed to `:FK`
    let categories.prefixes += (mode is# 'normal' ? ['U'] : [])
        \ + (!noleader ? ['Leader'] : [])

    let categories.motions =<< trim END
        *
        #
        $
        %
        (
        )
        +
        -
        ,
        ;
        /
        ?
        B
        E
        F
        G
        H
        L
        M
        N
        T
        W
        ^
        _
        b
        e
        f
        h
        j
        k
        l
        n
        t
        w
        {
        }
        BS
        CR
    END
    let categories.motions += [' ']

    " The 14 following motions stay on the line most of the time.{{{
    " The last 11 can move across different lines, but very limitedly.
    " So it doesn't make a lot of sense to use any of them after an operator
    " which acts upon a set of lines.
    " For example:
    "
    "     >h    ✘   works but not intuitive
    "     >>    ✔   better
    "
    "     =b    ✘   the cursor being at the beginning of a line
    "     =k    ✔
    "
    "     !w    ✘   the cursor being at the end of a line
    "     !j    ✔
    "
    " Thus, the syntax:
    "
    "     linewise operator + motion which stays on current line
    "
    " ... although valid, is unintuitive and useless.
    "
    " This creates new free key sequences.
    "}}}
    let categories.motions_limited =<< trim END
        $
        ^
        |
        w
        B
        E
        W
        b
        e
        h
        l
        BS
        CR
    END
    let categories.motions_limited += [' ']

    " We don't consider Tab as a motion, because even though `C-i` jumps forward
    " in the jumplist, by default, `operator + Tab` doesn't do anything.
    " So, we could consider it as a command, which gives us the free key sequences:
    "
    "     operator + Tab

    let l =<< trim END
        &
        .
        :
        A
        C
        D
        I
        J
        K
        O
        P
        Q
        R
        S
        V
        X
        Y
        a
        i
        o
        p
        q
        r
        s
        u
        v
        x
        Tab
    END
    let categories.commands += l

    " If the `-noleader` argument wasn't provided,  it means we want the algo to
    " consider the usage of a Leader  key.  So, we remove `g:mapleader` from all
    " the categories.
    " Indeed, the key stored in `g:mapleader`  should be considered as a prefix,
    " and nothing else.
    if !noleader
        for [category, keys] in items(categories)
            call filter(keys, {_, v -> v isnot# g:mapleader})
        endfor
    endif
    return categories
endfu

fu s:candidates(categories) abort "{{{1
    let categories = a:categories
    let syntaxes = s:syntaxes(categories)
    let candidates = []

    for [left_key_category, right_key_category] in values(syntaxes)
        for key1 in left_key_category
            for key2 in right_key_category
                let candidates += [join([key1,key2], '')]
            endfor
        endfor
    endfor
    return candidates
endfu

fu s:default_mappings(categories) abort "{{{1
    let mode = s:options.mode
    let default_mappings = []
    let prefixes = a:categories.prefixes
    let operators = a:categories.operators

    " NOTE:{{{
    "
    " Why can we copy something in the pseudo-register `~`?
    "
    "     "~yy
    "
    " And why can't we paste it?
    "
    "     "~p
    "
    " ---
    "
    " What do `@_` and `@~`?
    " They don't raise the error:
    "
    "     E354: Invalid register name:~
    "
    " ---
    "
    " We don't remove `m(` and `m(`,  because you can't really change them.  Vim
    " constantly updates them automatically, so  that they match the beginning /
    " end of the current sentence.
    "
    " Same thing for `m{` and `m}`.
    " They match the beginning / end of the current paragraph.
    "
    " Same thing for `m.`, and `m^`.
    " It doesn't seem possible to manually set those marks.
    " They match the last position where resp. a change was made, and
    " insertion mode was stopped.
    "}}}
    let default_mappings = {
        \   'command-line': {},
        \   'insert': {},
        \   'operator-pending': {},
        \ }

    let default_mappings.normal = {
        \   'prefix + letter': s:prefix_plus_letter(),
        \   'double prefix': s:double_prefix(prefixes),
        \   'op + forbidden cmd': s:op_plus_forbidden_cmd(operators),
        \
        \   'mark': ['m"', "m'", 'm<', 'm>', 'm[', 'm]', 'm`'],
        \   'double operator': ['!!', '==', '<<', '>>', 'cc', 'dd', 'yy'],
        \   'at': ['@"', '@*', '@+', '@-', '@.', '@/', '@:', '@='],
        \
        \   'backtick': ['`"', '`.', '`(', '`)', '`<', '`>',
        \                '`[', '`]', '`^', '``', '`{', '`}'],
        \
        \   'double quote': ['"+', '"-', '"*', '"/', '"=', '"%', '"#',
        \                    '":', '".', '"_'],
        \
        \   'single quote': ['''"', "'.", "'(", "')", "'<", "'>",
        \                    "'[", "']", "'^", "'`", "'{", "'}"],
        \ }

    let default_mappings.normal.various =<< trim END
        [*
        ]*
        [#
        ]#
        ['
        ]'
        [(
        ])
        [{
        ]}
        []
        ][
        [`
        ]`
        [/
        ]/
        [D
        ]D
        [I
        ]I
        [M
        ]M
        [P
        ]P
        [S
        ]S
        [c
        ]c
        [d
        ]d
        [f
        ]f
        [i
        ]i
        [m
        ]m
        [p
        ]p
        [s
        ]s
        [z
        ]z
        g#
        g*
        g$
        g&
        g'
        g+
        g,
        g-
        g;
        g<
        g?
        g@
        gD
        gE
        gF
        gH
        gI
        gJ
        gN
        gP
        gQ
        gR
        gT
        gU
        g]
        g^
        g_
        g`
        gd
        ge
        gf
        gh
        gi
        gj
        gk
        gm
        gn
        gp
        gq
        gr
        gs
        gt
        gu
        gv
        gw
        g~
        ZQ
        z#
        z+
        z-
        z.
        z=
        zCR
        zA
        zC
        zD
        zE
        zF
        zG
        zH
        zL
        zM
        zN
        zO
        zR
        zW
        zX
        z^
        za
        zb
        zc
        zd
        ze
        zf
        zg
        zh
        zi
        zj
        zk
        zl
        zm
        zn
        zo
        zr
        zs
        zt
        zv
        zw
        zx
    END

    let default_mappings.visual = {'prefix + letter' : s:prefix_plus_letter()}

    let default_mappings.visual.various =<< trim END
        a(
        a)
        a<
        a>
        aB
        aW
        a[
        a]
        a`
        ab
        ap
        as
        at
        aw
        a{
        a}
        g?
        gF
        gN
        g]
        gf
        gn
        gv
        i(
        i)
        i<
        i>
        iB
        iW
        i[
        i]
        i`
        ib
        ip
        is
        it
        iw
        i{
        i}
        i'
        a'
    END

    let result = []
    for a_list in values(default_mappings[mode])
        let result += a_list
    endfor

    return result
endfu

fu s:is_unmapped(candidates, default_mappings) abort "{{{1
    let candidates = a:candidates
    let default_mappings = a:default_mappings
    let nomapcheck = s:options.nomapcheck
    let nospecial = s:options.nospecial
    let mode = s:options.mode

    " `"`, `@`, `m`, `'`, ```, `[` and `]` are special motions, commands,{{{
    " because contrary to the other ones, they wait for an argument.
    " This creates a new free key sequence, each time they don't understand an
    " argument.
    " That's why we put them in the prefixes category.
    "
    " This choice of categorization has a consequence: we'll have to REMOVE
    " all the "mapped_to_sth" key sequences generated by our algorithm.
    " If instead we had chosen to categorize them as motions or commands, we
    " would have to do the opposite: ADD the unmapped key sequences forgotten by
    " the algorithm.
    "
    " Why this choice?
    " The "mapped_to_sth" sequences seem to be more structured than the unmapped
    " ones.  You can express a large chunk of them with a simple syntax:
    "
    "         prefix + letter
    "
    " So, it's easier to REMOVE MAPPED sequences, than to ADD UNMAPPED sequences.
    "
    " "}}}

    " If a sequence shadows another one, or it overrides a default action,
    " remove it.

    let condition_to_be_free = 'index(default_mappings, key) == -1'

    if nospecial
        let condition_to_be_free ..= ' && key !~ "[[:punct:]]"'
    endif

    if !nomapcheck
        let condition_to_be_free ..= '&& s:translate_special_key(key)'
            \ ..'->mapcheck(' .. string(mode[0]) .. ')->empty()'
    endif

    for key in candidates
        if !eval(condition_to_be_free)
            call remove(candidates, index(candidates, key))
        endif
    endfor

    " Now, we can be sure everything in `candidates` is free.
    return candidates
endfu

fu s:display(free) abort "{{{1
    " Get the unique id of the window we're coming from.
    " Necessary to restore the focus correctly when we'll close the FK window.
    let id_orig_window = win_getid()

    let tempfile = tempname() .. '/FreeKeys'
    exe 'to ' .. (&columns/6) .. 'vnew ' .. tempfile
    let b:_fk = extend(s:options, {'id_orig_window': id_orig_window, 'leader_key': 'shown',})

    setl bh=delete bt=nofile nobl noswf nowrap wfw

    sil 0put =a:free
    sil keepj $d_
    sort

    " Make the space key more visible.
    sil keepj keepp %s/ /Space/e

    " Add spaces around special keys:   BS, CR, CTRL-, Leader, Space, Tab
    " to make them more readable
    sil keepj keepp %s/^Leader\zs\ze\S/ /e
    sil keepj keepp %s/\%(CTRL-\)\@5<!\%(BS\|CR\|CTRL-\|Leader\|Space\|Tab\)$/ &/e
    sil keepj keepp %s/  / /e

    " If there're double sequences, like `operator + space`:
    "
    "     Leader = Space
    "     op_l + motion_s
    "     op   + leader
    "
    " ... remove them.
    sil keepj keepp %s/^\(.*\)\n\1$/\1/e

    " Trim whitespace.  There shouldn't be any, but better be safe than sorry.
    sil keepj keepp %s/\s*$//e

    call append(0, [substitute(s:options.mode, '.', '\U&', 'g') .. ' MODE', ''])
    call cursor(1, 1)

    nno <buffer><nowait> <cr> <cmd>call <sid>show_help()<cr>
    nno <buffer><nowait> q <cmd>call <sid>close_window()<cr>
    nno <buffer><nowait> g? <cmd>help freekeys-mappings<cr>
    nno <buffer><nowait> gc <cmd>call <sid>similar_tags()<cr>

    exe 'nno <buffer><nowait> gl <cmd>call <sid>toggle_leader_key(' .. s:options.noleader .. ')<cr>'
endfu

fu s:syntaxes(categories) abort "{{{1
    let mode = s:options.mode
    let categories = a:categories

    let prefixes = categories.prefixes
    let motions = categories.motions
    let motions_limited = categories.motions_limited
    let commands = categories.commands
    let operators = categories.operators
    let operators_linewise = categories.operators_linewise

    let chars = prefixes + motions + commands + operators

    let syntaxes = {
        \ 'insert': {'ctrl + char': [['CTRL-'], chars]},
        \ 'command-line': {'ctrl + char': [['CTRL-'], chars]},
        \ 'operator-pending': {'adverb + char': [['i', 'a'], chars]},
        \ }

    " In visual mode, we don't put `i`, `a` inside the commands category
    " because of the convention which uses them as prefix to build
    " text-objects.

    let syntaxes.visual = {
        \   'pfx + char': [prefixes, chars],
        \   'pfx + CTRL': [prefixes, ['CTRL-']],
        \   'CTRL + char': [['CTRL-'], chars],
        \   'cmd + char': [['&', '.', 'Q', 'Tab'], chars],
        \ }

    " Most of the meaningless sequences need at least 2 keys.
    " But one of them need at least 3 keys:    digit + prefix + digit

    let syntaxes.normal = {
        \   'pfx + char':      [prefixes, chars],
        \   'op + cmd':        [operators, commands],
        \   'op1 + op2':       [operators, operators],
        \   'op + pfx':        [operators, prefixes],
        \   'op_l + motion_s': [operators_linewise, motions_limited],
        \   'CTRL + char':     [['CTRL-'], ['K', 'Space', '\', '_', '@']],
        \   'op + CTRL':       [operators, ['CTRL-']],
        \   'pfx + CTRL':      [prefixes, ['CTRL-']],
        \ }

    " These 8 syntaxes should produce all 2-key meaningless sequences.
    " For n-key meaningless sequences (n>2), there's only 1 possible syntax:
    "
    "    - 2-key meaningless + any (n-2)-key sequence

    " CTRL is treated as a special prefix.
    " Indeed, there are very few USABLE unmapped key sequences with `CTRL-`.
    "
    " Beginning with `CTRL-`, I only found 4:
    "
    "     CTRL-K
    "     CTRL-\
    "     CTRL-_
    "     CTRL-Space or CTRL-@
    "
    " Ending with `CTRL-`, I only found 2:
    "
    "     op     + CTRL-
    "     prefix + CTRL-    with some exceptions like g C-G

    return syntaxes[mode]
endfu

fu s:prefix_plus_letter() abort "{{{1
    let prefix_plus_letter = []

    for prefix in ['"', '@', 'm', "'", '`']
        let prefix_plus_letter += (range(char2nr('a'), char2nr('z'))
            \ + range(char2nr('A'), char2nr('Z')))
            \ ->map({_, v -> prefix .. nr2char(v)})
    endfor
    return prefix_plus_letter
endfu

fu s:double_prefix(prefixes) abort "{{{1
    let double_prefix = []

    for prefix in a:prefixes
        let double_prefix += [prefix .. prefix]
    endfor

    return double_prefix
endfu

fu s:op_plus_forbidden_cmd(operators) abort "{{{1
    let op_plus_forbidden_cmd = []

    for operator in a:operators
        for command in ['a', 'i']
            let op_plus_forbidden_cmd += [operator .. command]
        endfor
    endfor

    for operator in ['c', 'd', 'y'] + (&tildeop ? ['~'] : [])
        for command in ['v', 'V']
            let op_plus_forbidden_cmd += [operator .. command]
        endfor
    endfor

    return op_plus_forbidden_cmd
endfu

fu s:translate_special_key(key) abort "{{{1
    let key = a:key
    if key =~# 'CTRL-$'
        return ''
    endif
    let key = substitute(key, 'Leader', g:mapleader, 'g')
    let key = substitute(key, 'Tab', '<Tab>', 'g')
    let key = substitute(key, 'CR', '<CR>', 'g')
    let key = substitute(key, 'BS', '<BS>', 'g')
    return key
endfu

fu s:show_help() abort "{{{1
    " All tags  from the plugin begin  with the prefix `fk_`  to avoid conflicts
    " with default ones.  Add it to the key sequence under the cursor.

    let topic = 'fk_' .. getline('.')->matchstr('\S.*\S')->escape('\')
    let topic = substitute(topic, ' ', '_', 'g')

    let substitutions = {
        \ 'U':         ['U\zs.*', ''],
        \ 'Bar':       ['\zs|.*', 'Bar'],
        \ '[] ctrl-':  ['[[\]]_CTRL-', 'fk_[]_CTRL-'],
        \ '[] "':      ['[[\]]"', 'fk_[]_double_quote'],
        \ 'op ctrl-':  ['[cdy]_CTRL-', 'fk_operator_and_CTRL-V'],
        \ 'op prefix': ['[!<>=cdy]g', 'fk_operator_and_prefix_g'],
        \ }

    for [pat, rep] in values(substitutions)
        let topic = substitute(topic, '^\C\Vfk_\m' .. pat .. '$', rep, '')
    endfor

    sil! exe 'help ' .. topic
endfu

fu s:close_window() abort "{{{1
    if reg_recording() != ''
        return feedkeys('q', 'in')[-1]
    endif
    let id_orig_window = b:_fk.id_orig_window
    q
    call win_gotoid(id_orig_window)
endfu

fu s:similar_tags() abort "{{{1
    let mode = b:_fk.mode
    let mode_tag = mode isnot# 'normal' ? mode[0] .. '_' : ''
    let lines = getline(1, '$')

    call remove(lines, index(lines, 'g:'))

    let tempfile = tempname() .. '/similar tags'
    exe 'to ' .. (&columns/6) .. 'vnew ' .. tempfile
    setl bh=delete bt=nofile nobl noswf nowrap wfw

    call setline(1, lines)

    for idx in range(line('$'), 1, -1)
        let key = getline(idx)->substitute(' ', '_', 'g')
        let taglist = taglist('^\C\V' .. mode_tag .. escape(key, '\'))
        let tagnames = map(taglist, {_, v -> '    ' .. escape(v['name'], '/')})

        if empty(tagnames)
            sil exe 'keepj ' .. idx .. 'd_'
        else
            sil exe 'keepj keepp ' .. idx .. 's/$/\=[""]+tagnames'
        endif
    endfor

    nno <buffer><expr><nowait><silent> q reg_recording() != '' ? 'q' : ':<c-u>q<cr>'
endfu

fu s:toggle_leader_key(noleader) abort "{{{1
    if a:noleader
        return ''
    endif

    let cur_pos = getcurpos()

    if b:_fk.leader_key is# 'shown'
        sil exe 'keepj keepp %s/Leader/' .. substitute(g:mapleader, ' ', 'Space', '') .. '/e' .. (&gd ? '' : 'g')
    else
        sil exe 'keepj keepp %s/' .. substitute(g:mapleader, ' ', 'Space', '') .. '/Leader/e' .. (&gd ? '' : 'g')
    endif

    call setpos('.', pos)

    let b:_fk.leader_key = filter(['shown', 'replaced'], {_, v -> v isnot# b:_fk.leader_key})[0]
endfu

