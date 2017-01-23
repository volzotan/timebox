include <camera.scad>;
include <enclosure_util.scad>;

size_bottom = [160, 110, 80];
size_top = [160, 110, 5];

wall_thickness = 2;
screw_bar_width = 8;
pug_diameter_top = 2.8;
pug_diameter_btm = 5.5;
uv_filter_diameter = 77; // ?

oring_bottom = 0.8;
oring_bottom = 1.0;

// translate([12, 35, 10]) camera();

render_bottom   = true;
render_top      = true;

if (render_bottom) {
    translate([0, 0, 0]) {
        difference() {
            union() {
                difference() {
                    cube(size_bottom);
                    
                    translate([wall_thickness, wall_thickness, wall_thickness]) 
                        cube([size_bottom[0]-wall_thickness*2, size_bottom[1]-wall_thickness*2, 100]);
                    
                    // front hole
                    translate([90, 5, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=10, d=uv_filter_diameter, $fn=128);
                
                }
                
                oring(size_bottom, wall_thickness, screw_bar_width, oring_bottom);
                
                // screw bars
                translate([]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
                translate([size_bottom[0]-screw_bar_width, 0, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
                translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
                translate([0, size_bottom[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
            
                // socket
                translate([60, 25, 0]) {                    
                    translate([0, 0, 0]) cube([60, 46, 10]);    
                }
            }
            
            translate([]) pug(100, pug_diameter_top);
            translate([size_bottom[0]-screw_bar_width, 0, 0]) pug(100, pug_diameter_top);
            translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            translate([0, size_bottom[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            
            translate([86, 45, -1]) threadhole(length=10);
            
        }
    }
}

if (render_top) {
    translate([size_bottom[0] + 20, 0, 0]) {
        difference() {
            union() {
                difference() {
                    cube(size_top);
                    
                    translate([wall_thickness, wall_thickness, wall_thickness]) 
                        cube([size_top[0]-wall_thickness*2, size_top[1]-wall_thickness*2, 100]);
                }
                      
             
                translate([]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([size_top[0]-screw_bar_width, 0, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([size_top[0]-screw_bar_width, size_top[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([0, size_top[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
            }
            
            translate([]) pug(100, pug_diameter_top);
            translate([size_top[0]-screw_bar_width, 0, 0]) pug(100, pug_diameter_top);
            translate([size_top[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            translate([0, size_top[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            
            translate([]) pug(1, pug_diameter_btm);
            translate([size_bottom[0]-screw_bar_width, 0, 0]) pug(1, pug_diameter_btm);
            translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(1, pug_diameter_btm);
            translate([0, size_bottom[1]-screw_bar_width, 0]) pug(1, pug_diameter_btm);
            
            translate([0, 0, -oring_bottom+0.01]) oring(size_top, wall_thickness, screw_bar_width, oring_bottom);  
        }
    }
}

module oring(base, thickness, bar_width, ring_width) {
    translate([thickness-oring_bottom, bar_width-ring_width, base[2]]) cube([ring_width, base[1] - bar_width*2 + ring_width*2, ring_width]);
    translate([base[0]-thickness, bar_width-ring_width, base[2]]) cube([ring_width, base[1] - bar_width*2 + ring_width*2, ring_width]);
    translate([bar_width-ring_width, thickness-ring_width, base[2]]) cube([base[0] - bar_width*2 + ring_width*2, ring_width, ring_width]);
    translate([bar_width-ring_width, base[1]-thickness, base[2]]) cube([base[0] - bar_width*2 + ring_width*2, ring_width, ring_width]);
    
    translate([thickness-ring_width, bar_width-ring_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([bar_width-ring_width, thickness-ring_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
   
    translate([thickness-ring_width, base[1]-bar_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([bar_width-ring_width, base[1]-bar_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
      
    translate([base[0] - bar_width, bar_width-ring_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([base[0] - bar_width, thickness-ring_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
   
    translate([base[0] - bar_width, base[1]-bar_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([base[0] - bar_width, base[1]-bar_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
}

module pug(height, pug_diameter) {
    translate([screw_bar_width/2, screw_bar_width/2, -0.01]) cylinder(h=height, d=pug_diameter, $fn=32);
}