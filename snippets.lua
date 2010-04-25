-- Snippets for the Markdown module.
module('_m.markdown.snippets', package.seeall)

local snippets = _G.snippets

if type(snippets) == 'table' then
  snippets.markdown = {
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
