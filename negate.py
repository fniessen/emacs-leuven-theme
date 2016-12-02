#!/usr/bin/env python3

import colorsys, fileinput, re, sys

from colormath.color_objects import LabColor, AdobeRGBColor as RGBColor
from colormath.color_conversions import convert_color

emacs_colors = dict()

with open("emacs_colors.dat", 'r') as cdata:
    for color in cdata.readlines():
        names, rgb = color.split("\t")
        for name in names.split(","):
            emacs_colors["\"{0}\"".format(name)] = "\"{0}\"".format(rgb.strip())

hex = re.compile("^[a-fA-F0-9]+$")

for line in fileinput.input():
    out = ""

    # First replace color names with hex codes
    for name, rgb in emacs_colors.items():
        line = line.replace(name, rgb)

    l = len(line)
    skipTo = -1

    for i in range(0, l):
        if i < skipTo:
            continue
        if "#" == line[i] and i+6 < l:
            out += "#"
            bit = line[i+1:i+7]
            if hex.match(bit):
                r, g, b = [int(bit[j:j+2], 16) for j in range(0, 6, 2)]

                rgb = RGBColor(r, g, b)
                lab = convert_color(rgb, LabColor)
                lab.lab_l = 6733.2299-lab.lab_l
                r, g, b = [int(x) for x in convert_color(lab, RGBColor).get_value_tuple()]
                


                # h, s, v = colorsys.rgb_to_hsv(r, g, b)
                
                # Except when v=255, but h and s > 0: this is a color
                # there and not pure white, so should not become pure
                # black.
                # if True: #255 == v and h > 0:
                #    neg_v = int(255 - (0.21*r + 0.72*g + 0.07*b))
                #                    
                # r, g, b = [int(a) for a in colorsys.hsv_to_rgb(h, s, neg_v)]


                repr = "{:02x}{:02x}{:02x}".format(r,g,b)


                out += repr
                skipTo = i+7

                continue
        out+= line[i]
                
    print(out[:-1])



