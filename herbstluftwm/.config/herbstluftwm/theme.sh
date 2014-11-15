# Get color from ~/.Xresources
get_x_color() {
    xresources=$(cat ~/.Xresources)
    color=$(echo $xresources | sed "s/.*\*color$1: \(#[0-9A-Fa-f]*\).*/\1/")
    echo $color
}

# Add alpha channel to a hexadecimal color
add_alpha_channel(){
    echo "$1" | \
    sed "s/.*#\([0-9a-fA-F]*\).*/#ff\1/"
}

# Wallpaper
wallpaper="/home/tom/Pictures/fall1.jpg"

# Padding
window_p=20

# Panel
panel_h=24
font="-*-fixed-medium-*-*-*-14-*-*-*-*-*-*-*"
font_sec="-*-stlarch-medium-*-*-*-10-*-*-*-*-*-*-*"

# Colors
color_fg=$(get_x_color 15)
color_accent=$(get_x_color 9)
color_bg=$(get_x_color 0)

# Alpha Colors for use with bar
acolor_fg=$(add_alpha_channel $color_fg)
acolor_accent=$(add_alpha_channel $color_accent)
acolor_bg=$(add_alpha_channel $color_bg)
