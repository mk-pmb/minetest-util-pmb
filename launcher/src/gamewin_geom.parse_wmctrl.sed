#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-
/^0x/!b
s!^(([A-Za-z0-9-]+ +){7})MineTest\.MineTest +\S+ +! \1\f!i
/^ /!b
s!\t! !g
s!\x5C|\x27!!g
s!^ !id\t!
s! +!\nwsp\t!
s! +!\npid\t!
s! +!\nx\t!
s! +!\ny\t!
s! +!\nw\t!
s! +!\nh\t!
s! +(\f)!\1!g
s!\f(Minetest) ([0-9.]+) \[!\nver:\L\1\E\t\2&!
s!\f!\ntitle\t\x27!
s!$!\x27!
# s~\n~¶&~g
p
