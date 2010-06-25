-- Commands for the Markdown module.
module('_m.markdown.commands', package.seeall)

-- Blockquotes
local m_editing = _m.textadept.editing
m_editing.comment_string.markdown = '> '

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

local function header(level)
  local b = buffer
  local pos = b.current_pos
  b:begin_undo_action()
  _m.textadept.editing.select_line()
  sel = b:get_sel_text()
  sel, count = sel:gsub('#+', string.rep('#', level))
  if count == 0 then
    b:home()
    b:add_text(string.rep('#', level)..' ')
    b:goto_pos(pos + level + 1)
  else
    b:replace_sel(sel)
  end
  b:end_undo_action()
end

local m_editing = _m.textadept.editing

m_editing.enclosure.star = { left = '*', right = '*' }
m_editing.enclosure.underline = { left = "_", right = "_" }

local function word_count()
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

-- Markdown-specific key commands.
local keys = _G.keys

if type(keys) == 'table' then
  keys.markdown = {
    al = {
      m = { io.open_file,
          (_USERHOME..'/modules/markdown/init.lua'):iconv('UTF-8', _CHARSET) },
      i = { word_count },
    },
    ['a='] = { underline, '=' },
    ['a-'] = { underline, '-' },
    ['a1'] = { header, 1 },
    ['a2'] = { header, 2 },
    ['a3'] = { header, 3 },
    ['a4'] = { header, 4 },
    ['a5'] = { header, 5 },
    ['a6'] = { header, 6 },
    ac = { -- enclose in
    ['*'] = { m_editing.enclose, 'star' },
    ["_"] = { m_editing.enclose, 'underline' },
    },
  }
end
