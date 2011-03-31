-- Robert Gieseke, robert.gieseke@gmail.com
-- freely distributable under the same license as Textadept (MIT)

---
-- Markdown module.
module('_m.markdown', package.seeall)

-- Markdown:
-- ## Key Commands
--
-- + `Alt+L, M`: Open this module for editing.
-- + `Alt+L, I`: Display char and word count.

local m_editing, m_run = _m.textadept.editing, _m.textadept.run
-- Blockquotes
m_editing.comment_string.markdown = '> '
-- Run command
m_run.md = 'markdown %(filename)'
-- Match < for embedded HTML, don't match '
m_editing.char_matches.markdown = {
  [40] = ')', [91] = ']', [123] = '}', [34] = '"', [60] = '>'
}

---
-- Sets default buffer properties for Markdown files.
function set_buffer_properties()
  if not buffer.use_tabs then
    buffer.indent = 4
  end
end

---
-- Underlines the current line.
-- @param char "=" or "-".
local function underline(char)
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

---
-- Sets the current line's header level.
-- @param level Header level 1-6
function header(level)
  local b = buffer
  local pos = b.current_pos
  b:begin_undo_action()
  _m.textadept.editing.select_line()
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

---
-- Remove header symbols.
function remove_header()
  local b = buffer
  local pos = b.current_pos
  b:begin_undo_action()
  _m.textadept.editing.select_line()
  sel = b:get_sel_text()
  sel = sel:gsub('#+ ', '')
  b:replace_sel(sel)
  b:line_end()
  b:end_undo_action()
end

---
-- Allow selected text to be enclosed
--@param left Char to enclose.
--@param right Char to enclose.
function enclose_selection(left, right)
  if buffer:get_sel_text() == '' then
    return
  else
    m_editing.enclose(left, right)
  end
end

---
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
  gui.statusbar_text = status:format(count, buffer.length)
end

---
-- Container for Markdown-specific key commands.
-- @class table
-- @name keys.markdown
_G.keys.markdown = {
  al = {
    m = { io.open_file,
        (_USERHOME..'/modules/markdown/init.lua'):iconv('UTF-8', _CHARSET) },
    i = { word_count },
  },
  ['a='] = { underline, '=' },
  ['a-'] = { underline, '-' },
  ['a0'] = { remove_header },
  ['a1'] = { header, 1 },
  ['a2'] = { header, 2 },
  ['a3'] = { header, 3 },
  ['a4'] = { header, 4 },
  ['a5'] = { header, 5 },
  ['a6'] = { header, 6 },
  ac = { -- enclose in
    ['*'] = { m_editing.enclose, '*', '*' },
    ["_"] = { m_editing.enclose, '_', '_' },
  },
  ["*"] = { enclose_selection, "*", "*" },
  ['_'] = { enclose_selection, '_', '_' },
}

-- Snippets.

if type(_G.snippets) == 'table' then
---
-- Container for MarkdownLua-specific snippets.
-- @class table
-- @name _G.snippets.markdown
  _G.snippets.markdown = {
    h1 = '# ',
    h2 = '## ',
    h3 = '### ',
    h4 = '#### ',
    h5 = '##### ',
    h6 = '###### ',
    -- link
    l = '[%1(Link)](%2(http://example.net/))',
    -- clickable link
    cl = '<%1(http://example.com/)>',
    --  reference-style link
    rl = '[%1(example)][%2(ref)]',
    id = '[%1(ref)]: %2(http://example.com/)',
    -- code
    c = '%`%0%`',
    -- image
    i = '![%1(Alt text)](%2(/path/to/img.jpg "Optional title"))',
  }
end
