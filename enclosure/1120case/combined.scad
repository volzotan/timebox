// global variables

filter_diameter = 77;

num_screws = 8;
deg = 360/num_screws;
off = deg/2;

q = 64;

include <../camera.scad>;
//% translate([78, 35, -32]) rotate([0, 0, 180]) camera(longlens=true);
% translate([0, 0, 0]) rotate([0, 0, 180]) scale([10, 10, 10]) color("green") import("Peli1120.stl");
% translate([-30, 10, -50]) color("grey") arca_clamp();

translate([0, 65.9+0]) rotate([-90, 0, 0]) front();
translate([0, 65.9-5, 0]) rotate([90, 0, 0]) back();
translate([0, 50, -50]) rotate([180, 0, 0]) bottom();
translate([0, 10, -90]) socket();

translate([0, -90, 0]) rotate([0, 0, 0]) bottom();

translate([0, 0, 100]) M5Screw();

module socket() {
        intersection() {
        difference() {
            union() {
                translate([-30, 0]) block(60, 40, 10);
            } 
            
            // arca screw
            translate([0, 20, -1]) cylinder($fn=32, d=10, h=50); // ?
            translate([0, 20, 2]) cylinder($fn=6, d=15, h=10); // ?

            // screws
            translate([-20, 10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 40-10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 40-10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 10, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9, h=7);
            translate([-20, 40-10, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9, h=7);
            translate([20, 10, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9, h=7);
            translate([20, 40-10, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9, h=7);
        }
        
        // top surface
        a = 10.0;
        b = a-1.4;
        points = [[0, 0], [40, 0], [40, a], [0, b]];
        translate([-30, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=60) polygon(points);
    }
}

module bottom() {
    intersection() {
        difference() {
            union() {
                translate([-30, 0]) block(60, 40, 10);
                
                translate([-30, 0]) block(20, 40, 14);
                translate([10, 0]) block(20, 40, 14);
            } 
            
            // arca screw
            translate([0, 20, -1]) cylinder($fn=32, d=10, h=50); // ?
            translate([0, 20, 10-5]) cylinder($fn=32, d=15, h=10); // ?
            
            // knob cavity
            translate([-47, 20, 0]) rotate([0, 90, 0]) cylinder($fn=64, d=20, h=20);
            
            // screws
            translate([-20, 10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 40-10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 40-10, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 10, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=7);
            translate([-20, 40-10, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=7);
            translate([20, 10, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=7);
            translate([20, 40-10, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=7);
        }
        
        // top surface
        a = 14.0;
        b = a-1.4;
        points = [[0, 0], [40, 0], [40, a], [0, b]];
        translate([-30, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=60) polygon(points);
    }
}

module back() {
//    x = 35.35;
//    
//    difference() {
//        union() {
//            translate([x, 10, 0]) cylinder($fn=32, d=14, h=10);
//            translate([-x, 10, 0]) cylinder($fn=32, d=14, h=10);
//        }
//        
//        translate([x, 10, -1]) cylinder($fn=32, d=5.3, h=20);
//        translate([-x, 10, -1]) cylinder($fn=32, d=5.3, h=20);
//        
//        translate([x, 10, 5]) cylinder($fn=6, d=9.6, h=20);
//        translate([-x, 10, 5]) cylinder($fn=6, d=9.6, h=20);
//    }
    
    difference() {
        union() {
            cylinder($fn=64, d=90+14, h=4);
            
            // screw support
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, 0]) cylinder($fn=32, d=14, h=7);
                
            // base angle
            points = [  [-50, 15], [-50, 30], [0, 5], [50, 30], [50, 15], 
                        [20, -12], [-20, -12]
            ];
            
            // translate([0, -50, 0]) linear_extrude(height=5) polygon(points);
        }
        
        // main hole
        translate([0, 0, -1]) cylinder($fn=64, d=filter_diameter, h=100);
    
        // screw holes
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, -1]) cylinder($fn=32, d=5.3, h=50);
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, 3]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=50);
    }
    
    * difference() {
        union() {
            translate([-20, -52, 0]) rotate([90, 0, 0]) block(40, 60, 10);
        }
        translate([0, 0, 40]) rotate([90, 0, 0]) cylinder($fn=32, d=10, h=100);
        translate([0, -60, 40]) rotate([90, 0, 0]) cylinder($fn=32, d=14, h=10);
    }
}

module front() {
    
    height = 40;
    
    difference() {
        union() {
                                        cylinder($fn=q, d=90+14, h=6);
            translate([0, 0, 6])        cylinder($fn=q, d1=90+14, d2=90+14-2, h=2);
            translate([0, 0, 8])        cylinder($fn=q, d1=90+8, d2=90, h=8);
                                        cylinder($fn=q, d=90, h=height-2);
            translate([0, 0, height-2]) cylinder($fn=q, d1=90, d2=90-2, h=2);
            
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, 0]) cylinder($fn=32, d=14, h=8);
        }
        
        // main hole
        translate([0, 0, -1]) cylinder($fn=q, d=filter_diameter, h=100);
    
        // filter second stage
        translate([0, 0, height-3]) color("red") cylinder($fn=64, d=filter_diameter+3, h=100);
    
        // o-ring cavity

            difference() {
                hull() {
                    translate([0, 0, -.1]) cylinder($fn=q, d=88, h=0.75);
                    translate([0, 0, 0.75+0.5]) cylinder($fn=q, d1=88-1, h=0.1);
                }
                union() {
                    translate([0, 0, -1]) cylinder($fn=q, d=88-2*2.0, h=2);
                    translate([0, 0, 0.75]) cylinder($fn=q, d1=88-2*2.0, d2=88-2*2.0+1, h=0.5);
                    translate([0, 0, 1.5]) cylinder($fn=q, d=88-2*2.0+1, h=1);
                }
            }
        
        
        // screw holes
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, -1]) cylinder($fn=32, d=5.3, h=50);
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, 6]) cylinder($fn=32, d=9, h=50);
    }
    
    // screws 
    for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([50, 0, 06]) M5Screw(length=18);
       
}

module arca_clamp() {
    block(60, 40, 10, crad=1);
    translate([-20, 20, 5]) rotate([0, 90, 0]) cylinder(d=15, h=10);
}

module M5Screw(length=10) {
    rotate([180, 0, 0]) color("grey") {
        translate([]) cylinder(d=5, h=length);
        difference() {
            translate([0, 0, -4.8]) cylinder(d=8.2, h=4.8);
            translate([0, 0, -6]) cylinder($fn=6, d=5, h=4);
        }
    }
}

module block(width, depth, height, crad=3, red=0) {
    hull() {    
        translate([crad, crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([width-crad, crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([crad, depth-crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([width-crad, depth-crad]) cylinder($fn=32, h=height, r=crad-red);
    }
}