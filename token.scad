// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Robert Drzyzgula

// Game Token 0.2
//
// This is some simple OpenSCAD code to generate a game token.
//
// The token may:
//
//  * be one color layer or two. Printing a two-color token should require only
//    a single filament change and is practical to do without an AMS.
//  * be any thickness or diameter, and have different diameters at base,
//    neck (at the color change), and top. The neck can be at any height.
//  * be any regular polygon in horizontal cross-section.
//    200 sides works well for a "round" token.
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
token_faces = 200; // [3:1:600]
// Diameter of token bottom. The token prints bottom-side up so that the magnet recess can print without supports, so the language can be confusing here. Also be careful not to slope the sides too steeply outward from the bottom (cantilevered), or you may need to use supports. For polygons, all diameters are those of the circle through the corners.
bottom_diameter = 20;
// Neck diameter, at the color change.
neck_diameter = 20;
// Top diameter
top_diameter = 20;
// Height of the neck (the color change), as a fraction of the token height measured from the top. Because the token prints top-side down, this is also the fraction of the print done in the first color.
neck_fraction = 0.5; // [0.05:0.05:0.95]
// Make a recess in the bottom of the token for a magnet. This is designed to print top-side down, so the recess will appear on the top in the preview. You can also use it to add a hole for e.g. a flag, in which case you'd use the "bottom" as the "top" in actual play.
make_recess = true;
// magnet diameter
magnet_diameter = 8;
// magnet height (thickness)
magnet_height = 2.5;
// How far should the magnet stick out (positive) or be recessed (negative)
magnet_extension = 0.2;
// play (extra diameter) in the magnet recess
recess_play = 0.4;
// Number of faces for the round recess
recess_faces = 200; // [24:1:600]
// Overlap of the top layer into the bottom layer, so the two parts fuse in the slicer. It does not change the token's height.
layer_overlap = 0.05;
// (optional) color for top. Note that the token prints topside-down, so this color will be on the bottom in the preview. Color names can be basic names like "red" or an rgb code like "#FF0000"; either must be in quotes. The colors you specify here are used to color the preview and are unimportant; you will set the actual filament at print time.
top_color = "red";
// (optional) color for bottom
bottom_color = "#00FFFF";

/* [Hidden] */

// Height of the color change above the build plate.
neck_z = token_height * neck_fraction;
// How deep the recess goes into the bottom face.
recess_depth = magnet_height - magnet_extension;
recess_d = magnet_diameter + recess_play;
recess_floor_z = token_height - recess_depth;

// Diameter (through the corners) of the token at height z.
function diameter_at(z) =
    z <= neck_z
        ? top_diameter + (neck_diameter - top_diameter) * z / neck_z
        : neck_diameter + (bottom_diameter - neck_diameter)
            * (z - neck_z) / (token_height - neck_z);

// Width across the flats at height z; the widest round hole that fits.
function inner_diameter_at(z) = diameter_at(z) * cos(180 / token_faces);

// Narrowest point of the token over the depth of the recess.
recess_min_wall_d = min([
    inner_diameter_at(token_height),
    inner_diameter_at(recess_floor_z),
    (neck_z > recess_floor_z) ? inner_diameter_at(neck_z) : inner_diameter_at(token_height)
]);

assert(token_height > 0, "token_height must be positive");
assert(token_faces >= 3, "token_faces must be at least 3");
assert(bottom_diameter >= 0 && neck_diameter >= 0 && top_diameter >= 0,
    "diameters cannot be negative");
assert(neck_fraction > 0 && neck_fraction < 1, "neck_fraction must be between 0 and 1");
assert(layer_overlap >= 0 && layer_overlap < token_height - neck_z,
    "layer_overlap must be at least 0 and less than the height of the bottom layer");
if (make_recess) {
    assert(recess_depth > 0,
        "magnet_extension must be less than magnet_height, or there is no recess");
    assert(recess_depth < token_height,
        "the recess is deeper than the token: reduce magnet_height or increase magnet_extension");
    assert(recess_d < recess_min_wall_d,
        str("the recess (", recess_d, " mm) is wider than the token where it is cut (",
            recess_min_wall_d, " mm across the flats)"));
}

// The recess, cut down from the bottom face; it extends past the face so the
// cut always opens to the surface.
module recess() {
    if (make_recess)
        translate([0, 0, recess_floor_z])
            cylinder(h = recess_depth + 1, d = recess_d, $fn = recess_faces);
}

// Each color is a separate top-level object, so that with lazy unions the
// 3MF export keeps them as separate parts.
color(top_color) difference() {
    union() {
        cylinder(h = neck_z, d1 = top_diameter, d2 = neck_diameter, $fn = token_faces);
        // The overlap continues the neck straight up, no wider than the
        // bottom layer, so it stays inside the token.
        if (layer_overlap > 0)
            translate([0, 0, neck_z])
                cylinder(h = layer_overlap,
                    d = min(neck_diameter, diameter_at(neck_z + layer_overlap)),
                    $fn = token_faces);
    }
    recess();
}

color(bottom_color) difference() {
    translate([0, 0, neck_z])
        cylinder(h = token_height - neck_z, d1 = neck_diameter, d2 = bottom_diameter,
            $fn = token_faces);
    recess();
}
