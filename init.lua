-- A markdown module for the
-- [Textadept](http://foicica.com/textadept/) editor.
-- It provides utilities for writing
-- [Markdown](http://daringfireball.net/projects/markdown/).<br>
--
-- Installation:<br>
-- Download an
-- [archived](https://github.com/rgieseke/ta-markdown/archives/master)
-- version or clone the git repository into your `.textadept` directory:
--     cd ~/.textadept/modules
--     git clone https://github.com/rgieseke/ta-markdown.git \
--         markdown
--
--
-- The source is on [GitHub](https://github.com/rgieseke/ta-markdown),
-- released under the
-- [MIT license](http://www.opensource.org/licenses/mit-license.php).

local M = {}


-- ## Settings

-- Local variables.
local m_editing, m_run = textadept.editing, textadept.run
-- Blockquotes.
m_editing.comment_string.markdown = '> '
-- Run command (using file extension).
m_run.md = 'markdown %(filename)'
-- Auto-matching chars.<br>
-- Match `<` for embedded HTML, don't match `'`.
m_editing.char_matches.markdown = {
  [40] = ')', [91] = ']', [123] = '}', [34] = '"', [60] = '>'
}

-- Sets default buffer properties for Markdown files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'markdown' then
    buffer.tab_width = 4
  end
end)


-- ## Commands

-- Underlines the current line.<br>
-- Parameter:<br>
-- _char_: "=" or "-".
function M.underline(char)
  local b = buffer
  b:begin_undo_action()
  b:line_end()
  caret = b.current_pos
  b:home()
  start = b.current_pos
  b:line_end()
  b:new_line()
  b:add_text(string.rep(char, caret - start))
  b:new_line()
  b:end_undo_action()
end

-- Sets the current line's header level.<br>
-- Parameter:<br>
-- _level_: 1 - 6
function M.header(level)
  local b = buffer
  local pos = b.current_pos
  b:begin_undo_action()
  m_editing.select_line()
  sel = b:get_sel_text()
  sel, count = sel:gsub('#+', string.rep('#', level))
  if count == 0 then
    b:home()
    b:add_text(string.rep('#', level)..' ')
    b:line_end()
  else
    b:replace_sel(sel)
    b:line_end()
  end
  b:end_undo_action()
end

-- Remove header symbols.
function M.remove_header()
  local b = buffer
  local pos = b.current_pos
  b:begin_undo_action()
  m_editing.select_line()
  sel = b:get_sel_text()
  sel = sel:gsub('#+ ', '')
  b:replace_sel(sel)
  b:line_end()
  b:end_undo_action()
end

-- Enclose selected text or insert char.
-- Parameter:<br>
-- _left_: Char to insert on the left.<br>
-- _right_: Char to insert on the right.
function M.enclose_selection(left, right)
  if buffer:get_sel_text() == '' then
    return false
  else
    m_editing.enclose(left, right)
  end
end

-- Display word and char count in status bar.
function word_count()
  local buffer = buffer
  local text, length = buffer:get_text(buffer.get_length)
  if #text > 0 then text = text.." " end
  text = string.gsub(text, "^%s+", "")
  seps = string.gmatch(text, "%s+")
  local count = 0
  for i in seps do
    count = count + 1
  end
  status = 'Words: %d - Chars: %d'
  ui.statusbar_text = status:format(count, buffer.length)
end


-- ## Key Commands

-- Markdown-specific key commands.
keys.markdown = {
  al = {
    -- __Alt-L, M__: Open this module for editing.
    m = { io.open_file,
        (_USERHOME..'/modules/markdown/init.lua'):iconv('UTF-8', _CHARSET) },
    -- __Alt-L, I__: Display char and word count.
    i = { word_count },
  },
  -- Underline current line: `Alt/⌘`+'='
  [OSX and 'm=' or 'a='] = { M.underline, '=' },
  -- Underline current line: `Alt/⌘`+'-'
  [OSX and 'm-' or 'a-'] = { M.underline, '-' },
  -- __Alt-0 - 6__: Change header level.
  [OSX and 'm0' or 'a0'] = { M.remove_header },
  [OSX and 'm1' or 'a1'] = { M.header, 1 },
  [OSX and 'm2' or 'a2'] = { M.header, 2 },
  [OSX and 'm3' or 'a3'] = { M.header, 3 },
  [OSX and 'm4' or 'a4'] = { M.header, 4 },
  [OSX and 'm5' or 'a5'] = { M.header, 5 },
  [OSX and 'm6' or 'a6'] = { M.header, 6 },
  -- __Alt-C, *__: Enclose in *.<br>
  -- **Alt-C, _**: Enclose in _.
  ac = { -- enclose in
    ['*'] = { m_editing.enclose, '*', '*' },
    ["_"] = { m_editing.enclose, '_', '_' },
  },
  -- Enclose selected text.
  ["*"] = { M.enclose_selection, "*", "*" },
  ['_'] = { M.enclose_selection, '_', '_' },
  ['`'] = { M.enclose_selection, '`', '`' },
}

-- ## Snippets.

-- Markdown-specific snippets.
snippets.markdown = {
  -- Headers.
  ['1'] = '# ',
  ['2'] = '## ',
  ['3'] = '### ',
  ['4'] = '#### ',
  ['5'] = '##### ',
  ['6'] = '###### ',
  -- Link.
  l = '[%1(Link)](%2(http://example.net/))',
  -- Clickable link.
  cl = '<%1(http://example.com/)>',
  --  Reference-style link.
  rl = '[%1(example)][%2(ref)]',
  id = '[%1(ref)]: %2(http://example.com/)',
  -- Code.
  c = '`%0`',
  -- Image.
  i = '![%1(Alt text)](%2(/path/to/img.jpg "Optional title"))',
}

return M
