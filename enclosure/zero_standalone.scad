include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>


% translate([0, 6, 0.1]) screw25(length=25);

// battery
translate([10+82, 18, 10]) {
    translate([0, 14]) rotate([0, 90, 0]) cylinder($fn=32, d=18, h=65);
    translate([0, -5.5]) rotate([0, 90, 0]) cylinder($fn=32, d=18, h=65);
}

// camera
translate([filter_x+78, -size[1]/2-3, 7.5]) rotate([-90, 0, 90]) color("grey") import("external_models/RasPi_Camera_v1.stl");

translate([80, 0]) {
    translate([0, 0, 0]) bottom();
    translate([0, -48, 0]) rotate([0, 0, 0]) top();
    
//    % translate([09.5, 1, 4]) translate([2, 32+0.5, -20.095]) pizero();
}

*% translate([0, 0]) {
    translate([0, 0, 0]) rotate([90, -90, 0]) bottom();
    translate([-size[1], -42.5, 0]) rotate([90, -90, 180]) top();
    
//    % translate([09.5, 1, 4]) translate([2, 32+0.5, -20.095]) pizero();
    
    translate([-60, 0, 00]) rotate([90, 0]) screw3(length=40);
    translate([-60, 0, 07]) rotate([90, 0]) screw3(length=45);
    translate([-60, 0, 14]) rotate([90, 0]) screw3(length=50);
}


// CHECK
// https://www.thingiverse.com/thing:2300226

size = [85+10, 37+9];
crad = 6;
    
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
    
    height  = 20;
    height2 = 10;
    height3 = 4;
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=crad);
                
                x=1.6+0.1;
                a=x+1;
                b=x;
                c=x+2;
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=crad, red=a);
                    translate([0, 0, 1]) block(size[0]-8, size[1], 14, crad=crad, red=b);
                    translate([0, 0, 16]) block(size[0]-8, size[1], 1, crad=crad, red=c);
                }    
                translate([8, 0, 1.7]) block(size[0]-8, size[1], height, crad=crad, red=c);
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
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], size[1], height2]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, size[1], height2]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([0, 23+piyoffset-o-r]) cube([pixoffset+o, size[1], height2]);
                    translate([0, 23+piyoffset-o]) cube([pixoffset+o+r, size[1], height2]);
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r); 
 
                    // screw head support
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);   
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([pixoffset+o, 23+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=crad);        
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
        
        // screws M3
        translate([0, 0, -1]) {
            translate([5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, 6]) cylinder($fn=32, d=6.1, h=5);
            
            translate([size[0]-5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, 6]) cylinder($fn=32, d=6.1, h=5);
                   
            translate([5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, size[1]-6]) cylinder($fn=32, d=6.1, h=5);
            
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=6.1, h=5);
        }
        
        // screws camera
        translate([filter_x-14.5, size[1]/2-10.3, -1]) {
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
    
    height = 22;
    height2 = height;
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=crad);
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=crad, red=1.6+.1+1);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height, crad=crad, red=1.6+.1);
                }    
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-16.5;
                    
                    translate([58+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height2]);
                    translate([58+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], size[1], height2]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, size[1], height2]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=crad);        
            }
        }
        
        // screws
//        translate([pixoffset, piyoffset, -1]) {
//            translate([0, 0]) cylinder($fn=32, h=10, d=2.5+.3);
//            translate([58, 0]) cylinder($fn=32, h=10, d=2.5+.3);
//           
//            translate([0, 0]) cylinder($fn=32, h=3.8, d=5);
//            translate([58, 0]) cylinder($fn=32, h=3.8, d=5);
//            
//            translate([0, 23]) cylinder($fn=32, h=10, d=2.5+.3);
//            translate([58, 23]) cylinder($fn=32, h=10, d=2.5+.3);
//           
//            translate([0, 23]) cylinder($fn=32, h=3.8, d=5);
//            translate([58, 23]) cylinder($fn=32, h=3.8, d=5);
//        } 
        
                
        // screws M3
        translate([0, 0, -1]) {
            translate([5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, 6]) cylinder($fn=6, d=6.7, h=4);
            
            translate([size[0]-5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, 6]) cylinder($fn=6, d=6.7, h=4);
                   
            translate([5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, size[1]-6]) cylinder($fn=6, d=6.7, h=4);
            
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, size[1]-6]) cylinder($fn=6, d=6.7, h=4);
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
//    translate([pixoffset, piyoffset, 2.8]) {
//        translate([0, 0]) cylinder($fn=32, h=0.2, d=6);
//        translate([58, 0]) cylinder($fn=32, h=0.2, d=6);
//        translate([0, 23]) cylinder($fn=32, h=0.2, d=6);
//        translate([58, 23]) cylinder($fn=32, h=0.2, d=6);
//    } 
}



module pizero() {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
}

module screw25(length=10) { // M2.5 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2.5, d=4.5);
        translate([0, 0, 2.5]) cylinder($fn=32, h=length, d=2.5);
    }
}

module screw3(length=10) { // M2.5 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2.86, d=5.32);
        translate([0, 0, 2.86]) cylinder($fn=32, h=length, d=3);
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
