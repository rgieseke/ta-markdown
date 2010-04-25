-- Commands for the Markdown module.
module('_m.markdown.commands', package.seeall)

local textadept = _G.textadept
local b = buffer

-- Blockquotes
local m_editing = _m.textadept.editing
m_editing.comment_string.markdown = '> '

function underline(char)
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

function header(level)
  local pos = b.current_pos
  b:begin_undo_action()
  b:home()
  buffer:add_text(string.rep('#', level)..' ')
  b:goto_pos(pos + level + 1)
  b:end_undo_action()
end

function enclose(char)
  b:begin_undo_action()
  local txt = b:get_sel_text()
  if txt == '' then
    b:word_left_extend()
    txt = b:get_sel_text()
  end
  b:replace_sel(char..txt..char)
  b:end_undo_action()
end

-- Markdown-specific key commands.
local keys = _G.keys

if type(keys) == 'table' then
  keys.markdown = {
    al = {
      m = { textadept.io.open,
            textadept.iconv(_USERHOME..'/modules/markdown/init.lua',
                            'UTF-8', _CHARSET) },
    },
    ['a='] = { underline, '=' },
    ['a-'] = { underline, '-' },
    ['a1'] = { header, 1 },
    ['a2'] = { header, 2 },
    ['a3'] = { header, 3 },
    ['a4'] = { header, 4 },
    ['a5'] = { header, 5 },
    ['a6'] = { header, 6 },
    ac = {
      ['*'] = { enclose, '*' },
      ['_'] = { enclose, '_' }
    }
  }
end
