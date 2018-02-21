include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>

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

// --------------------------------------- ASSEMBLY 

% translate([0, 0, 0]) bottom_pi_new();
% translate([0, 0, 4.5]) translate([2.5, 33, -20.095]) pizero();
% translate([0, 0, 17.1]) translate([2.5, 36-3]) rotate([0, 0, 180]) controller();
% translate([0, 0, 18.4]) translate([0, 36, 9]) rotate([180, 0, 0]) color([0.6, 1, 0.6], 0.1) top_pi_new();

% translate([0, 6, 0.1]) screw(length=25);

// --------------------------------------- PRINT | PI

translate([80, 0]) {
    translate([0, 0, 0]) bottom_pi_new();
    translate([0, -36.5, 0]) rotate([0, 0, 0]) top_pi_new();
    
    translate([-4, 0, 0]) spacer();
    translate([-4, -7, 0]) spacer();
    
    
//% translate([0, 0, 4]) translate([2.5, 33, -20.095]) pizero();
}

// --------------------------------------- PRINT | STANDALONE

//translate([80, -75]) {
//    translate([0, 0, 0]) bottom_standalone();
//    translate([0, -36.5, 0]) rotate([0, 0, 0]) top_standalone();
//}

// --------------------------------------- TEST 

//intersection() {
//    union() {
//        translate([0, 0, 0]) bottom_pi_new();
//        translate([0, 0, 4.5]) translate([2.5, 33, -20.095]) pizero();
//        translate([0, 0, 17.1]) translate([2.5, 36-3]) rotate([0, 0, 180]) controller();
//        translate([0, 0, 18.4]) translate([0, 36, 9]) rotate([180, 0, 0]) color([0.6, 1, 0.6], 0.1) top_pi_new();
//    }
//    translate([30, -10, -10]) cube([200, 200, 200]);
//}

//translate([-80, 0]) grip_holder();

size = [70, 36];

pixoffset = 5;
piyoffset = 5.5;

hole_reinforcements = true;

module grip_holder() {
    
    size = [69, 35];
    
    difference() {
        intersection() {
            points = [[0, 0], [size[1], 0], [size[1], 10], [size[1]-5, 20], [size[1]/2, 5], [5, 20], [0, 10]];
            translate([]) rotate([90, 0, 90]) linear_extrude(height=69.8) polygon(points);
            
            translate([-0.4, -0.4]) block(69+0.8, 35+0.8, 50, crad=4);
        }
        
        // tripod leg
        translate([-1, size[1]/2, 16]) rotate([0, 90, 0]) cylinder($fn=32, h=80, d=25);
        
        // magnet cavity
        translate([0, 0, -0.1]) color("darkgreen") {
            translate([6, size[1]/2]) cylinder($fn=32, d=8.6, h=1.4);
            translate([size[0]/2, size[1]/2]) cylinder($fn=32, d=8.6, h=1.4);
            translate([size[0]-6, size[1]/2]) cylinder($fn=32, d=8.6, h=1.4);
        }
    }
}


module spacer() {
    difference() {
    cylinder($fn=32, d=3.5+(1.2*2)+0.1, h=10.8);
        translate([0, 0, -1]) cylinder($fn=32, d=3.5, h=20);
    }
}

module top_standalone() {
    
    size = [69, 35];
    
    height = 9;
    height2 = 8;
    
    difference() {
        union() {
            intersection() {
                union() {
                    difference() {               
                        translate([-0.4, -0.4]) block(size[0]+0.8, size[1]+0.8, height, crad=4);        

                        // pi cutout
                        hull() {
                            translate([0, 0, 1.5]) {
                                block(size[0], size[1], 0.1, crad=4, red=1.2+.1+1);
                            }
                            translate([0, 0, 1.5+1]) {
                                block(size[0], size[1], height, crad=4, red=1.2+.1);
                            } 
                        }
                    }
 
                    translate([size[0]-5.7, size[1]-8.5]) cube([5.7, 8.5, height2]);
                    translate([size[0]-8, size[1]-6.5]) cube([7.5, 6.5, height2]);
                    translate([size[0]-6, size[1]-6.5]) cylinder($fn=32, h=height2, d=4);
                    
                    translate([0, size[1]-8.5]) cube([5.7, 8.5, height2]);
                    translate([0, size[1]-6.5]) cube([8, 5.7, height2]);
                    translate([6, size[1]-6.5]) cylinder($fn=32, h=height2, d=4);                    
                }
                
                translate([-0.4, -0.4]) block(size[0]+0.8, size[1]+0.8, height, crad=4);        
            }
          
            // hole reinforcements 
            translate([0, -.5, 1.5]) {
                translate([5.5, 5.5+24, 0]) cylinder($fn=32, h=1, d=7.3);
                translate([5.5+58, 5.5+24, 0]) cylinder($fn=32, h=1, d=7.3);
                translate([5.5, 5.5+24, 1]) cylinder($fn=32, h=2, d1=7.3, d2=5);
                translate([5.5+58, 5.5+24, 1]) cylinder($fn=32, h=2, d1=7.3, d2=5);
            }  
        }
                       
        // connector cutout
        translate([size[0]-16.5-8-1.25, size[1]-8.25, -1]) block(16.5, 10, 20, crad=1); // power
        translate([size[0]-8-30.75, size[1]-4.5, 5.5]) {                            // audio jack
            cube([7, 5, 6]);
            translate([7/2, 5, 0]) rotate([90, 0, 0]) cylinder($fn=32, d=7, h=2.8);
        }     
        translate([8.0+1.5, size[1]-4.5+5, 3]) rotate([90, 0, 0]) block(11, 10, 3, crad=1); // cube([11, 5, height]);         // USB        
        translate([-1, 14.5, 8]) rotate([90, 0, 90]) block(12, 5, 3, crad=1);       // power switch
        translate([20, 24.5, -1]) block(9.5, 7, 10, crad=1);                        // SPI
        translate([40.7, 27, -1]) cylinder($fn=32, h=10, d=3);                      // LED hole
        translate([39.4, 6, -1]) cylinder($fn=32, h=10, d=3);                       // button hole
        
        // screws
        translate([0, -.5, -1]) {
            translate([5.5, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([5.5+58, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            
            translate([5.5, 5.5+24]) rotate([0, 0, 30]) cylinder($fn=6, h=3.5, d=6.1);
            translate([5.5+58, 5.5+24]) rotate([0, 0, 30]) cylinder($fn=6, h=3.5, d=6.1);
        }
        
        // force printer to do holes at once
        translate([0, 0, 0]) {
            translate([-1, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-6, 35-6-.1/2, -1]) cube([7, 0.1, 1.2]);
        }        
    } 
    
    // hole reinforcements for printing
    translate([5.5, 5+24, 2.5]) cylinder(h=0.2, d=5);
    translate([5.5+58, 5+24, 2.5]) cylinder(h=0.2, d=5);
    
}

module top_pi_new() {
    
    height = 14.5;
    height2 = 8.5;
    height3 = 4.5;
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=4);
                
                // pi cutout
                translate([0, 0, 1.7]) hull() {
                    block(size[0], size[1], 0.1, crad=4, red=1.6+.1+1);
                    translate([0, 0, 1]) block(size[0], size[1], height, crad=4, red=1.6+.1);
                }    
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3.7;
                    
                    translate([60+pixoffset-o, 25+piyoffset-o-r]) cube([size[0], 8.5, height2]);
                    translate([60+pixoffset-o-r, 25+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([60+pixoffset-o, 25+piyoffset-o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([0, 25+piyoffset-o-r]) cube([pixoffset+o, size[1], height2]);
                    translate([0, 25+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([pixoffset+o, 25+piyoffset-o]) cylinder($fn=32, h=height2, r=r); 
 
                    // screw head support
                    translate([60+pixoffset-o, 25+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([pixoffset+o, 25+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=4);        
            }
        }
                       
        // connector cutout
        translate([size[0]-16.5-8-1.25-.1-1, size[1]-8.75, -1]) block(17.5, 10, 10, crad=1);    // power
        translate([size[0]-8-31.25, size[1]-4.5, 5.5]) {                                        // audio jack
            cube([7, 5, 3.5]);
            translate([7/2, 5, 0]) rotate([90, 0, 0]) cylinder($fn=32, d=7, h=2.8);
        }     
        translate([8.0+1.5, size[1]-4.5+5, 3.5]) rotate([90, 0, 0]) block(11, 6, 3, crad=1);    // USB        
        translate([-1, 15, 8]) rotate([90, 0, 90]) block(12, 8, 3, crad=1);                     // power switch
        translate([20.5, 25, -1]) block(9.5, 7, 10, crad=1);                                    // SPI
        translate([40.7, 28, -1]) cylinder($fn=32, h=10, d=3);                                  // LED hole
        translate([39.9, 6.5, -1]) cylinder($fn=32, h=10, d=3);                                 // button hole
        
        // screws
        translate([0, 0, -1]) {
            translate([6, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([6+58, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            
            translate([6, 5.5+24]) rotate([0, 0, 30]) cylinder($fn=6, h=3.7, d=6.1);
            translate([6+58, 5.5+24]) rotate([0, 0, 30]) cylinder($fn=6, h=3.7, d=6.1);
        }
        
        // force printer to do holes at once
        color("darkred") {
            translate([-1, 5.5+24-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-6, 5.5+24-.1/2, -1]) cube([7, 0.1, 1.2]);
            
            translate([41.2-1.5+.1, -1, -1]) cube([0.1, 7, 1.2]);
            translate([20.5+9.5/2, 30, -1]) cube([0.1, 7, 1.2]);
            
            translate([41, 27.75, -1]) cube([4, 0.1, 1.2]);
        }   
   
        // input|output signs
        translate([56.8-9.25, 22-1.25, -1]) cube([0.1, 4, 1.2]);
        translate([56.8-9.2, 22.5+2.3, -1]) rotate([0, 0, 90]) cylinder($fn=3, d=5, h=1.2);
        
        translate([56.8-0.05, 22+2, -1]) cube([0.1, 4, 1.2]);
        translate([56.8, 23.5, -1]) rotate([0, 0, -90]) cylinder($fn=3, d=5, h=1.2);
    } 
    
    // hole reinforcements for printing
    if (hole_reinforcements) {
        color("orange") {
            translate([6, 5.5+24, 2.7]) cylinder(h=0.2, d=5);
            translate([6+58, 5.5+24, 2.7]) cylinder(h=0.2, d=5);
        }
    }
}

module bottom_standalone() {
    
    size = [69, 35];
    
    height = 5.6;
    height2 = 1.2+3+0.4;
        
    difference() {
        union() {
            difference() {
                translate([-0.4, -0.4]) block(69+0.8, 35+0.8, height, crad=4);
                
                // pi cutout
                translate([0, 0, 1.2]) hull() {
                    block(69, 35, height, crad=4, red=1.2+.1);
                }    
            }
            
            // holder
            intersection() {
                union() {
                    translate([size[0]-5.7, 0]) cube([5.7, 8.5, height2]);
                    translate([size[0]-8, 0]) cube([7.5, 6.5, height2]);
                    translate([size[0]-6, 6.5]) cylinder($fn=32, h=height2, d=4);
                            
                    translate([0, 0]) cube([5.7, 8.5, height2]);
                    translate([0, 0]) cube([8, 6.5, height2]);
                    translate([6, 6.5]) cylinder($fn=32, h=height2, d=4); 
                }
                translate([-0.4, -0.4]) block(69+0.8, 35+0.8, height, crad=4);
            }
            
            // hole reinforcements 
            translate([0, 0, 1.2]) {
                translate([5.5, 6]) cylinder($fn=32, h=1, d=7);
                translate([5.5, 6, 1]) cylinder($fn=32, h=1, d1=7, d2=5);
                translate([5.5+58, 6]) cylinder($fn=32, h=1, d=7);
                translate([5.5+58, 6, 1]) cylinder($fn=32, h=1, d1=7, d2=5);
            }
        }
        
        // through hole pin cutout
        translate([(70-51)/2-0.8, 26-.25, -1]) color("yellow") block(13.5, 6.5, 10, crad=1);
        
        // screws
        translate([0.5, -.5, -1]) {
            translate([6-1, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
           
            translate([6-1, 6.5]) cylinder($fn=32, h=3.8, d=5);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=3.8, d=5);
        }    
       
        // power switch cutout
        translate([9, 8.5, 1.2]) rotate([0, -90, 0]) block(12, 12, 10, crad=1);
        
        // force printer to do holes at once
        translate([-1, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-6, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
        
        translate([30, 37, -1]) cube([5, 0.1, 1.2]);
    }
    
    // hole reinforcements for printer
    if (hole_reinforcements) {
        translate([0, 0, 3.8-1]) {
            translate([5.5, 6]) cylinder($fn=32, d=5, h=0.2);
            translate([5.5+58, 6]) cylinder($fn=32, d=5, h=0.2);
        }
    }
}


module bottom_pi_new() {
    
    height = 12.8;
    height2 = 1.7+2.8;
    height3 = 4.5;
        
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block(size[0], size[1], height, crad=4);
                
                // pi cutout
                translate([0, 0, 1.7]) hull() {
                    block(size[0], size[1], 0.1, crad=4, red=1.2+.1+1);
                    translate([0, 0, 1]) block(size[0], size[1], height, crad=4, red=1.6+.1);
                }    
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=2;
                    o=1;
                    r2=3;
                    
                    x=60;
                    y=25;
                    
                    translate([0, 0]) cube([pixoffset+o, piyoffset+o+r, height2]);
                    translate([0, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([x+pixoffset-o, 0]) cube([size[0], piyoffset+o+r, height2]);
                    translate([x+pixoffset-o-r, 0]) cube([pixoffset+o+r, piyoffset+o, height2]);
                    translate([x+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([x+pixoffset-o, y+piyoffset-o-r]) cube([size[0], 8.5, height2]);
                    translate([x+pixoffset-o-r, y+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([x+pixoffset-o, y+piyoffset-o]) cylinder($fn=32, h=height2, r=r);
                    
                    translate([0, y+piyoffset-o-r]) cube([pixoffset+o, size[1], height2]);
                    translate([0, y+piyoffset-o]) cube([pixoffset+o+r, 10, height2]);
                    translate([pixoffset+o, y+piyoffset-o]) cylinder($fn=32, h=height2, r=r); 
 
                    // screw head support
                    translate([0+pixoffset+o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);   
                    translate([x+pixoffset-o, 0+piyoffset+o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([x+pixoffset-o, y+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);  
                    translate([pixoffset+o, y+piyoffset-o]) cylinder($fn=32, h=height3, r=r2);             
                }
                
                translate([0, 0]) block(size[0], size[1], height, crad=4);        
            }
        }
        
        // through hole pin cutout
        translate([(size[0]-51)/2-0.25, 26.25, 1.7]) color("yellow") block(51.5, 6.5, 10, crad=1);
        
        // screws
        translate([1, 0, -1]) {
            translate([6-1, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
           
            translate([6-1, 6.5]) cylinder($fn=32, h=3.8, d=5);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=3.8, d=5);
            
            translate([6-1, 6.5+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1+58, 6.5+23]) cylinder($fn=32, h=10, d=2.5+.3);
           
            translate([6-1, 6.5+23]) cylinder($fn=32, h=3.8, d=5);
            translate([6-1+58, 6.5+23]) cylinder($fn=32, h=3.8, d=5);
        }    
       
        // sd card cutout
        translate([-2, 10, 9.5+2]) rotate([0, 90, 0]) hull() {
            block(9, 19, .1, crad=1);
            translate([2, 2, 4]) block(9-4, 19-4, .1, crad=1);
        }
        
        // USB cutout
        translate([37.5, 0, 4.5]) hull() {
            translate([0, 2]) cube([24, 0.1, 6]);
            translate([-3/2, -2]) cube([24+3, 0.1, 6]);
        }
        
        // magnet cavity
        translate([0, 0, -0.1]) color("darkgreen") {
            translate([10, size[1]/2]) cylinder($fn=32, d=8.5, h=1.5);
            translate([size[0]/2, size[1]/2]) cylinder($fn=32, d=8.5, h=1.5);
            translate([size[0]-10, size[1]/2]) cylinder($fn=32, d=8.5, h=1.5);
        }
        
        // pi-camera connector
        translate([size[0]+5, (size[1]-19)/2, 5]) rotate([0, -90, 0]) block(4, 19, 10, crad=1);
        
        // force printer to do holes at once
        color("darkred") {
            translate([5.5+0.45, -1, -1]) cube([0.1, 7, 1.2]);
            translate([69-5.5+0.45, -1, -1]) cube([0.1, 7, 1.2]);
            translate([5.5+0.45, 30, -1]) cube([0.1, 7, 1.2]);
            translate([69-5.5+0.45, 30, -1]) cube([0.1, 7, 1.2]);
           
            translate([-1, size[1]/2, -1]) cube([size[0]/2, 0.1, 1.2]);
            translate([size[0]-10, size[1]/2, -1]) cube([10, 0.1, 1.2]);
        }
    }
    
    // magnet reinforcement
    color() {
        translate([10, size[1]/2, 1.5]) cylinder($fn=32, d=8.5+3*.4+.1, h=0.8);
        translate([size[0]/2, size[1]/2, 1.5]) cylinder($fn=32, d=8.5+3*.4+.1, h=0.8);
        translate([size[0]-10, size[1]/2, 1.5]) cylinder($fn=32, d=8.5+3*.4+.1, h=0.8);
    }
    
    // screw hole reinforcements for printer
    if (hole_reinforcements) {
        translate([0, 0, 3.8-1]) color("orange") {
            translate([6, 6.5]) cylinder($fn=32, d=5, h=0.2);
            translate([6+58, 6.5]) cylinder($fn=32, d=5, h=0.2);
            translate([6, 35-5.5]) cylinder($fn=32, d=5, h=0.2);
            translate([6+58, 35-5.5]) cylinder($fn=32, d=5, h=0.2);
        }
    }
}

module controller() {
    //rotate([0, 0, 90]) color("purple") import(file = "controller10.dxf");
    rotate([0, 0, 90]) controller11();
    
//    translate([-75+0.2, 12.75, 0]) color("yellow") cube([10, 5, 6]);
//    translate([-75+0.2, 12.75+14, 0]) color("yellow") cube([10, 5, 6]);
//    
//    translate([-5, 10, 0]) color("grey") cube([5, 8, 3]);
//    //translate([0-22-8, 0, 0]) color("white") cube([22, 7.5, 3]);
//   
//    translate([0-14-6.5, 40-3, 1]) color("black") cube([14, 6, 5]);
//    //translate([0-10-6.5, 22, 1]) color("black") cube([10, 5, 9+1]);
//    translate([-65+6.5, 40-3, 1]) color("black") cube([16, 5, 5]);
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
