// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Robert Drzyzgula

// Game Token 0.1
//
// This is some simple OpenSCAD code to generate a game token. This
// 
// The token may:
// 
//  * be one color layer or two. Printing a two-color token should require only
//    a single filament change and is practical to do without an AMS.
//  * be any thickness or diameter, and have different diameters at base,
//    middle (at the color change), and top.
//  * be any regular polygon in horizontal cross-section.
//    600 sides works well for a "round" token.
//  * optionally have a round recess on one side to hold a magnet
//    or other object such as a flag.
// 
// Note that all the color stuff is optional and can be ignored.
// If you export as an STL, you will have a single-color token regardless.
// 
// For the colors to work, you will need to (a) enable "lazy unions" in
// OpenSCAD, in "Preferences", under "Features", and (b) export as a
// generic 3MF. In your slicer, import geometry only, not as a project.
//
// Height of token
token_height = 10;
// Number of faces for token, three minimum. 200 faces make a good round token.
token_faces = 200;
// Diameter of token bottom. The token prints bottom-side up so that the magnet recess can brint without supports, so the language can be confusing here. Also be careful not to slope the sides too steeply outward from the bottom (cantalevered), or you may need to use supports.
bottom_diameter = 20;
// Neck diameter.
neck_diameter = 20;
// Top diameter
top_diameter = 20;
// Make a recess in the bottom of the token for a magnet. Set to 0 for no recess. This is designed to print top-side down, so the recess will appear on the top in the preview. You can also use it to add a hole for e.g. a flag, in which case you'd use the "bottom" as the "top" in actual play.
make_recess = 1;
// magnet diameter
magnet_diameter = 8;
// magnet_height
magnet_height = 2.5;
// How far should the magnet stick out (positive) or be recessed (negative)
magnet_extension = 0.2;
// Overlap for top and bottom;
layer_overlap = 0.05;
// play (extra diameter) in the magnet recess
recess_play = 0.4;
// (optional) color for top. Note that the token prints topside-down, so this color will be on the bottom in the preview. Color names can be basic names like "red" or an rgb code like "#FF0000"; either must be in quotes. The colors you specify here are used to color the preview and are unimportant; you will set the actual filament at print time.
top_color = "red";
// (optional) color for bottom
bottom_color = "#00FFFF";

difference() {
    union() {
        color(top_color) cylinder(h=token_height/2+layer_overlap,r1=top_diameter/2,r2=neck_diameter/2,$fn=token_faces);
        color (bottom_color) translate([0,0,token_height/2])cylinder(h=token_height/2+layer_overlap,r1=neck_diameter/2,r2=bottom_diameter/2,$fn=token_faces);
        }
        if(make_recess>0) {
            color(bottom_color) translate([0,0,token_height-magnet_height+magnet_extension]) cylinder(h=magnet_height+magnet_extension,r=(recess_play+magnet_diameter)/2,$fn=600);
            }
    }
