#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-

s!\r$!!
s!\s*=\s*! = !

/^[a-z]+linear_filter = false$/b
/^autojump /b
/^autosave_/b
/^aux1_descends /b
/^connected_glass /b
/^creative_mode /b
/^doubletap_/b
/^enable_3d_clouds /b
/^enable_client_modding /b
/^enable_damage /b
/^enable_waving_leaves /b
/^enable_waving_plants /b
/^enable_waving_water /b
/^fast_move /b
/^fixed_map_seed /b
/^free_move /b
/^fsaa = 0$/b
/^keymap_/b
/^keymap_decrease_viewing_range_min /b
/^mainmenu_last_/b
/^maintab_LAST /b
/^menu_last_/b
/^mgv?[0-9]*_/b
/^name /b
/^noclip /b
/^node_highlighting /b
/^opaque_water /b
/^screen_[wh] /b
/^selected_world_/b
/^server_announce /b
/^wieldview_/b
/^world_config_selected_mod /b



s!^viewing_range = !a .view=!p

/^texture_path = /{
  s!/+$!!
  s!^.*/!!
  s!^pixelperfection$!pxperf!
  s!^!a .txpk=!p
}
s!^(bilin)ear_filter = true$!f .flt=\1!p
s!^(trilin)ear_filter = true$!f .flt=\1!p

s!^(aniso)tropic_filter = !\1:!
s!^(fsaa) = !\1:!
s!^(leaves)_style = !\1:!
s!^(mip)_map = !\1:!
s!^(tone)_mapping = !\1:!
s!^enable_(bump)mapping = !\1:!
s!^enable_(par)allax_(occ)lusion = !\1\2:!

/\r/b
s!^(\S+):true$!g +\1!p
s!^(\S+):false$!g -\1!p
s! = !\t\t\t\t\t\t= !p
