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
    b:line_end()
  else
    b:replace_sel(sel)
    b:line_end()
  end
  b:end_undo_action()
end

local function remove_header()
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


local function enclose_selection(left, right)
  if buffer.get_sel_text() == '' then
    return
  else
    m_editing.enclose(left, right)
  end
end

local function paste_or_grow_enclose (left, right)
  if buffer:get_sel_text() == '' then
    buffer:add_text(left)
    return
  else
    start = buffer.anchor
    stop = buffer.current_pos
    if start > stop then
      start, stop = stop, start
    end
    add_start = #left
    add_stop = #right
    m_editing.enclose(left, right)
    buffer:set_sel(start, stop + add_start + add_stop)
  end
end

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
--      ["`"] = { m_editing.enclose, '`', '`'}
    },
    ["*"] = { enclose_selection, "*", "*" },
    ['_'] = { enclose_selection, '_', '_' },
    ['`'] = { enclose_selection, '`', '`' },
    ["c*"] = { paste_or_grow_enclose, "*", "*" },
    ['c_'] = { paste_or_grow_enclose, '_', '_' },
--    [''] = { paste_or_grow_enclose, '`', '`' },
  }
end
