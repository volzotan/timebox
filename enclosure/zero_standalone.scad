include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>

// TODO:
//
// - filter size - #
// - top height (cam + pi + controller)
// - imperial nut height - #




% translate([0, 6, 0.1]) screw25(length=25);

// battery
% translate([10+80.5, 2.5, 2]) color("lightblue") battery();

// camera
//% translate([filter_x+78, -size[1]/2-3, 6+2.5]) rotate([-90, 0, 90]) color("grey") import("external_models/RasPi_Camera_v1.stl");

translate([80, 0]) {

//   intersection() {
        translate([0, 0, 0]) rotate([0, 0, 0]) bottom();
//        translate([1, 0-1, 0]) cube([50, 50, 50]);
//    }
    
    translate([0, -48, 40]) color("grey") seal();
    
//   intersection() {
        translate([0, -48, 0]) rotate([0, 0, 0]) top();
//        translate([1, -48-1, 0]) cube([50, 50, 50]);
//    }
    
//    % translate([30, -20]) screw25(length=10);
    
//    % translate([09.5, -42.5-30, 40+14+100]) translate([2, 32+0.5, -20.095]) rotate([180, 0]) pizero();
}

% translate([0, 0]) {
    translate([0, 0, 0]) rotate([90, -90, 0]) bottom();
    translate([0, -25, 0]) rotate([90, -90, 0]) seal();
    
    translate([-size[1], -52-2.5, 0]) rotate([90, -90, 180]) top();
    
//    % translate([09.5, 1, 4]) translate([2, 32+0.5, -20.095]) pizero();
    
    translate([-60, 0, 00]) rotate([90, 0]) screw3(length=40);
    translate([-60, 0, 07]) rotate([90, 0]) screw3(length=45);
    translate([-60, 0, 14]) rotate([90, 0]) screw3(length=50);
}


// CHECK
// https://www.thingiverse.com/thing:2300226

size = [95+2, 37+9];
crad = 6;
    
pixoffset = 15+2;
piyoffset = (size[1]-23)/2;

filter_x = 50;

module battery() {
    difference() {
        block(76, 41, 20, crad=2);
        translate([0, 0, 1]) block(76, 41, 20, crad=2, red=1);
    }
}
    
module spacer() {
    difference() {
    cylinder($fn=32, d=6, h=10.8);
        translate([0, 0, -1]) cylinder($fn=32, d=3, h=20);
    }
}

module top() {
    
    height  = 27;
    height2 = 12.3+3;
    height3 = 5.5;
    
//    translate([pixoffset, piyoffset-6, height2]) color("orange") block(60, 35, 17);
    
    // gasket grip
    translate([8+4, 1.7+1+1+0.2, height]) color("darkgreen") cube([74.5, 0.8, 1.2]);
    translate([8+4, size[1]-(1.7+1+1+0.2)-0.8, height]) color("darkgreen") cube([74.5, 0.8, 1.2]);
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);
                
                x=1.6+0.1;
                a=x+1;
                b=x;
                c=x+2+0.8;
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=crad, red=a);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height-6, crad=crad, red=b);
                    translate([0, 0, height-4]) block(size[0]-8, size[1], 1, crad=crad, red=c);
                }    
                translate([8-2, 0, 1.7]) block(size[0]-6, size[1], height, crad=crad, red=c);
            }
            
            // filter support
            translate([filter_x, size[1]/2, 1.7]) cylinder($fn=64, d1=40+6.2, d2=25+4, h=1);
            translate([filter_x, size[1]/2, 0]) cylinder($fn=64, d=40+4.2, h=6.5);
 
            // pcb feet
            intersection() {
                union() {
                    r=1;
                    o=1;
                    r2=7;
                    
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
                    
                    foo = size[1]-16;
                    translate([58+foo-o, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([58+foo-o, 0]) block(size[0], piyoffset+o+r, height, crad=2);
 
                    // screw head support
                    translate([pixoffset, piyoffset, -1]) {
                        translate([0, 0]) cylinder($fn=32, h=height3, d=r2);
                        translate([58, 0]) cylinder($fn=32, h=height3, d=r2);
                        translate([0, 23]) cylinder($fn=32, h=height3, d=r2);
                        translate([58, 23]) cylinder($fn=32, h=height3, d=r2);
                    }  
                }
                
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);        
            }
            
            // camera reinforcement
            translate([filter_x-18.6-9, (size[1]-28-6)/2]) block(8+1, 28+6, 6.5);
        }
        
        // filter cutout        
        translate([filter_x, size[1]/2, -1]) {
            down = 39.4+0.7-.1;
            up   = 36.9+0.5;
            cylinder($fn=64, h=1+3.60+0.3, d=down);
            translate([0, 0, 1+3.60+0.3-0.1]) cylinder($fn=64, h=2, d1=down, d=up);
            translate([0, 0, 6-.3]) cylinder($fn=64, h=2, d=up);
            translate([0, 0, 6+2-.3-.1]) cylinder($fn=64, h=3, d1=up, d2=34);
        }
               
        // socket
        translate([2, size[1]/2, 25-0.25]) rotate([0, 90, 0]) hull() {
            depth = 4.7+0.3;
            cylinder($fn=6, h=depth, d=13.2); 
            translate([10, 0]) cylinder($fn=6, h=depth, d=13.2); 
        }
        translate([-2, size[1]/2, 15]) rotate([0, 90]) cylinder($fn=32, h=10, d=7);
               
        // screws M2.5 | raspberry pi
        translate([pixoffset, piyoffset, -1]) {
            height = 1+2.5+0.5;
            translate([0, 0]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([58, 0]) cylinder($fn=32, h=20, d=2.5+.3);
           
            translate([0, 0]) cylinder($fn=32, h=height, d=5);
            translate([58, 0]) cylinder($fn=32, h=height, d=5);
            
            translate([0, 23]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([58, 23]) cylinder($fn=32, h=20, d=2.5+.3);
           
            translate([0, 23]) cylinder($fn=32, h=height, d=5);
            translate([58, 23]) cylinder($fn=32, h=height, d=5);
        } 
        
        // screws M3 | enclosure
        translate([0, 0, -1]) {
            height = 1+3+0.5;
            translate([5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, 6]) cylinder($fn=32, d=6.1, h=height);
            
            translate([size[0]-5, 6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, 6]) cylinder($fn=32, d=6.1, h=height);
                   
            translate([5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([5, size[1]-6]) cylinder($fn=32, d=6.1, h=height);
            
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=3.3, h=30);
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=6.1, h=height);
        }
        
//        // screws camera
//        translate([filter_x-14.5, size[1]/2-10.3, -1]) {
//            translate([0, 21]) cylinder($fn=32, h=10, d=2.0+.3);
//            translate([0, 0]) cylinder($fn=32, h=10, d=2.0+.3);
//            
//            translate([0, 21]) cylinder($fn=32, h=3.3, d=3.8+0.4); // ?
//            translate([0, 0]) cylinder($fn=32, h=3.3, d=3.8+0.4); // ?
//        }
        
        // screws M2.5 | camera
        translate([0, 0, -1]) {
            height = 1+2.5+0.5;
            translate([27, size[1]-10]) cylinder($fn=32, d=2.5+.3, h=20);
            translate([27, size[1]-10]) cylinder($fn=32, d=5, h=height);
            translate([27, 10]) cylinder($fn=32, d=2.5+.3, h=20);
            translate([27, 10]) cylinder($fn=32, d=5, h=height);
        }
        
        // force printer to do holes at once
        translate([0, 0, -1]) color("red") {
            translate([-1, 6-.1/2]) cube([7, 0.1, 1.2]);
            translate([-1, size[1]-(6+.1/2)]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, 6-.1/2]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, size[1]-(6+.1/2)]) cube([7, 0.1, 1.2]);
            
            translate([pixoffset, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+10, -1]) cube([0.1, 10, 1.2]);
            translate([27, -1]) cube([0.1, 10, 1.2]);
            translate([filter_x, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+58, -1]) cube([0.1, 10, 1.2]);
            
            translate([0, size[1]-08]) {
            translate([pixoffset, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+10, -1]) cube([0.1, 10, 1.2]);
            translate([27, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+58, -1]) cube([0.1, 10, 1.2]);
            }
        }        
    } 
    
    // hole reinforcements for printing
    translate([pixoffset, piyoffset, 3]) { // raspberry pi
        translate([0, 0]) cylinder($fn=32, d=6, h=0.3);
        translate([58, 0]) cylinder($fn=32, d=6, h=0.3);
        translate([0, 23]) cylinder($fn=32, d=6, h=0.3);
        translate([58, 23]) cylinder($fn=32, d=6, h=0.3);
    } 
    translate([0, 0, 3]) { // camera
            translate([27, size[1]-10]) cylinder($fn=32, d=5, h=0.3);
            translate([27, 10]) cylinder($fn=32, d=5, h=0.3);
    }
    translate([0, 0, 3.5]) { // enclosure
        translate([5, 6]) cylinder($fn=32, d=6.1, h=0.3);   
        translate([size[0]-5, 6]) cylinder($fn=32, d=6.1, h=0.3);
        translate([5, size[1]-6]) cylinder($fn=32, d=6.1, h=0.3);
        translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=6.1, h=0.3);
    }
    
    // imperial nut
    % translate([2+0.5, size[1]/2, 15]) rotate([0, 90, 0]) color("grey") difference() {
        cylinder($fn=6, h=5, d=13.00); 
        translate([0, 0, -1]) cylinder($fn=32, h=10, d=6.9);
    }
}


module seal() {
    
    height = 2;
    
    difference() {
        union() {
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);
                
                // cutout
                translate([8, 0, -1]) block(size[0]-8, size[1], height+2, crad=crad, red=1.6+.1+2);
                translate([8-2, 0, -1]) block(size[0]-6, size[1], height+2, crad=crad, red=1.6+.1+2);
          
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-14;
                    
                    translate([58+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height]);
                    translate([58+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height]);
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height, r=r);
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], size[1], height]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, size[1], height]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height, r=r);             
                }
                
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);        
            }
        }
        
        // screws M3
        translate([0, 0, -1]) {
            translate([5, 6]) cylinder($fn=32, d=3.3+.3, h=30);       
            translate([size[0]-5, 6]) cylinder($fn=32, d=3.3+.3, h=30);            
            translate([5, size[1]-6]) cylinder($fn=32, d=3.3+.3, h=30);
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=3.3+.3, h=30);
        }
    }
}


module bottom() {
    
    height = 24.5;
    height2 = height;
    
    // nodge
    translate([0, 0, height]) color("orange") difference() {
        block(size[0], size[1], 0.3*2, crad=crad, red=1.2); 
        translate([0, 0, -1]) block(size[0], size[1], height, crad=crad, red=1.2+0.8); 
    }
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);
                
                // pi cutout
//                translate([8, 0, 1.7]) hull() {
//                    block(size[0]-8, size[1], 0.1, crad=4, red=2.0+.1+1);
//                    translate([0, 0, 1]) block(size[0]-8, size[1], height, crad=4, red=2.0+.1);
//                }   
               
                x=2+0.1;
                a=x+1;
                b=x;
                c=x+2;
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=crad, red=a);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height-6, crad=crad, red=b);
                    translate([0, 0, height-4]) block(size[0]-8, size[1], 1, crad=crad, red=c);
                }    
                translate([8-2, 0, 1.7]) block(size[0]-6, size[1], height, crad=crad, red=c);
             
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-14;
                    
                    translate([58+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height2]);
                    translate([58+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([58+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([58+pixoffset-o, 23+piyoffset-o-r]) cube([size[0], size[1], height2]);
                    translate([58+pixoffset-o-r, 23+piyoffset-o]) cube([pixoffset+o+r, size[1], height2]);
                    translate([58+pixoffset-o, 23+piyoffset-o]) cylinder($fn=32, h=height2, r=r);             
                }
                
                translate([0, 0]) block2(size[0], size[1], height, crad=crad-2);        
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
            translate([-1, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([-1, size[1]-(6+.1/2), -1]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, size[1]-(6+.1/2), -1]) cube([7, 0.1, 1.2]);
        }        
    } 
    
    // hole reinforcements for printing
    translate([0, 0, 3]) {
        translate([5, 6]) cylinder($fn=32, d=6, h=0.3);
        translate([size[0]-5, 6]) cylinder($fn=32, d=6, h=0.3);
        translate([5, size[1]-6]) cylinder($fn=32, d=6, h=0.3);
        translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=6, h=0.3);
    } 
}



module pizero() {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
}

module screw2(length=10) { // M2 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2, d=4);
        translate([0, 0, 2]) cylinder($fn=32, h=length, d=2.5);
    }
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

module block2(width, depth, height, crad=3) {
    points = [  [0, crad], [crad, 0],
                [width-crad, 0], [width, crad],
                [width, depth-crad], [width-crad, depth],
                [crad, depth], [0, depth-crad]];
    
    linear_extrude(height=height) polygon(points);
}
