include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>

crad = 5;
height = 4;

// standalone
/*
% translate([0, 6, 0.1]) screw(length=12);
% translate([2, 35-2.5, 4.8]) rotate([0, 0, 180]) controller();
translate([0, 0, 0]) bottom_standalone();
% translate([0, 35, 14.7+0.1]) rotate([180, 0, 0]) color([0.6, 1, 0.6], 0.1) top_standalone();

translate([80, 0]) {
    translate([0, 0, 0]) bottom_standalone();
    translate([0, -36.5, 0]) rotate([0, 0, 0]) top_standalone();
}
*/

// standalone + pi

//translate([0, 0, 0]) bottom_pi_new();
//% translate([0, 0, 4]) translate([2, 32+0.5, -20.095]) pizero();
//% translate([0, 0, 17.9]) translate([0, 35, 9]) rotate([180, 0, 0]) color([0.6, 1, 0.6], 0.1) top_pi_new();

% translate([0, 6, 0.1]) screw(length=25);

translate([80, 0]) {
    translate([0, 0, 0]) bottom();
    translate([0, -40, 0]) rotate([0, 0, 0]) top();
    
    % translate([09.5, 1, 4]) translate([2, 32+0.5, -20.095]) pizero();
}

//% translate([2, 35-2.5, 35+1.2]) rotate([0, 0, -90]) color("purple") import(file = "controller11_2.dxf");
 
//spacer();

translate([5, 14, 20]) rotate([0, 90, 0]) cylinder($fn=32, d=18, h=65);
translate([filter_x+78, -21.5, 7.5]) rotate([-90, 0, 90]) color("grey") import("external_models/RasPi_Camera_v1.stl");




// CHECK
// https://www.thingiverse.com/thing:2300226

size = [85, 37];
    
pixoffset = 15;
piyoffset = (size[1]-23)/2;

filter_x = 50;

    
module spacer() {
    difference() {
    cylinder($fn=32, d=6, h=10.8);
        translate([0, 0, -1]) cylinder($fn=32, d=3, h=20);
    }
}


module top() {
    
    height  = 15;
    height2 = 10;
    height3 = 4;
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=4);
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=4, red=1.6+.1+1);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height, crad=4, red=1.6+.1);
                }    
            }
            
            // filter support
            translate([filter_x, size[1]/2, 1.7]) cylinder($fn=64, d1=25+6, d2=25+4, h=1);
            translate([filter_x, size[1]/2, 0]) cylinder($fn=64, d=25+4, h=7);
 
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    translate([0, 0]) cube([pixoffset+o, piyoffset+o+r, height2]);
                    translate([0, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height2]);
                    translate([58+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], 8.5, height2]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([0, 23+piyoffset-o-r]) cube([pixoffset+o, size[1], height2]);
                    translate([0, 23+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r); 
 
                    // screw head support
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);   
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=4);        
            }
            
            // camera reinforcement
            translate([filter_x-18.6, (size[1]-28)/2]) block(8, 28, 7);
        }
        
        // filter cutout
        translate([filter_x, size[1]/2, -1]) cylinder($fn=64, d=25, h=10);
               
        // socket
        translate([2, size[1]/2, 17]) rotate([0, 90, 0]) hull() {
            cylinder($fn=6, h=1+5, d=13.15); 
            translate([10, 0]) cylinder($fn=6, h=1+5, d=13.15); 
        }
        translate([-2, size[1]/2, 07]) rotate([0, 90]) cylinder($fn=32, h=10, d=7);
               
        // screws
        translate([pixoffset, piyoffset, -1]) {
            translate([0, 0]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([58, 0]) cylinder($fn=32, h=20, d=2.5+.3);
           
            translate([0, 0]) cylinder($fn=32, h=3.8, d=5);
            translate([58, 0]) cylinder($fn=32, h=3.8, d=5);
            
            translate([0, 23]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([58, 23]) cylinder($fn=32, h=20, d=2.5+.3);
           
            translate([0, 23]) cylinder($fn=32, h=3.8, d=5);
            translate([58, 23]) cylinder($fn=32, h=3.8, d=5);
        } 
        
        // camera screws
        translate([filter_x-14.5, 8, -1]) {
            translate([0, 21]) cylinder($fn=32, h=10, d=2.0+.3);
            translate([0, 0]) cylinder($fn=32, h=10, d=2.0+.3);
            
            translate([0, 21]) cylinder($fn=32, h=3.3, d=3.8+0.4); // ?
            translate([0, 0]) cylinder($fn=32, h=3.3, d=3.8+0.4); // ?
        }
        
        // force printer to do holes at once
        translate([0, 0, 0]) color("red") {
            translate([-1, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-6, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
            
            translate([39.35, -1, -1]) cube([0.1, 7, 1.2]);
            translate([24.8, 30, -1]) cube([0.1, 7, 1.2]);
        }        
    } 
    
    // hole reinforcements for printing
    translate([pixoffset, piyoffset, 2.8]) {
        translate([0, 0]) cylinder($fn=32, h=0.2, d=6);
        translate([58, 0]) cylinder($fn=32, h=0.2, d=6);
        translate([0, 23]) cylinder($fn=32, h=0.2, d=6);
        translate([58, 23]) cylinder($fn=32, h=0.2, d=6);
    } 
    
    // imperial nut
    % translate([2+0.5, size[1]/2, 7]) rotate([0, 90, 0]) color("grey") difference() {
        cylinder($fn=6, h=5, d=13.00); 
        translate([0, 0, -1]) cylinder($fn=32, h=10, d=6.9);
    }
}


module bottom() {
    
    height = 5;
    height2 = 5;
    height3 = 4;
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=4);
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=4, red=1.6+.1+1);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height, crad=4, red=1.6+.1);
                }    
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    translate([0, 0]) cube([pixoffset+o, piyoffset+o+r, height2]);
                    translate([0, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height2]);
                    translate([58+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], 8.5, height2]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([0, 23+piyoffset-o-r]) cube([pixoffset+o, size[1], height2]);
                    translate([0, 23+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r); 
 
                    // screw head support
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);   
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=4);        
            }
        }
        
        // screws
        translate([pixoffset, piyoffset, -1]) {
            translate([0, 0]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([58, 0]) cylinder($fn=32, h=10, d=2.5+.3);
           
            translate([0, 0]) cylinder($fn=32, h=3.8, d=5);
            translate([58, 0]) cylinder($fn=32, h=3.8, d=5);
            
            translate([0, 23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([58, 23]) cylinder($fn=32, h=10, d=2.5+.3);
           
            translate([0, 23]) cylinder($fn=32, h=3.8, d=5);
            translate([58, 23]) cylinder($fn=32, h=3.8, d=5);
        } 
        
        // force printer to do holes at once
        translate([0, 0, 0]) color("red") {
            translate([-1, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-6, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
            
            translate([39.35, -1, -1]) cube([0.1, 7, 1.2]);
            translate([24.8, 30, -1]) cube([0.1, 7, 1.2]);
        }        
    } 
    
    // hole reinforcements for printing
    translate([pixoffset, piyoffset, 2.8]) {
        translate([0, 0]) cylinder($fn=32, h=0.2, d=6);
        translate([58, 0]) cylinder($fn=32, h=0.2, d=6);
        translate([0, 23]) cylinder($fn=32, h=0.2, d=6);
        translate([58, 23]) cylinder($fn=32, h=0.2, d=6);
    } 
}



module pizero() {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
}

module screw(length=10) { // M2.5 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2.5, d=4.5);
        translate([0, 0, 2.5]) cylinder($fn=32, h=length, d=2.5);
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
