include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>

// TODO:
//
// - filter size - #
// - top height (cam + pi + controller)
// - imperial nut height - #




//% translate([0, 6, 0.1]) screw25(length=25);

// battery
//% translate([10+80.5, 3, 2]) color("lightblue") battery();

// camera
% translate([filter_x, -size[1]/2-1.5, 6+2.5]) rotate([-90, 0, 90]) color("grey") import("external_models/RasPi_Camera_v1.stl");

//% translate([25, -41.5, 06.7]) camholder();

// seal
//translate([80, 0, 26]) color([0.5, 0.5, 0.5]) seal();
//translate([0, 52]) camholder();

//translate([80, 0]) {

//   intersection() {
//        translate([0, 0, 0]) rotate([0, 0, 0]) bottom();
//        translate([-1, -1, 0]) cube([50, 50, 50]);
//    }
    
//   translate([2.1, -30, 15]) nutholder(); 
    
//   intersection() {
//        translate([0, -48, 0]) rotate([0, 0, 0]) top();
//        translate([5, -48-1, 0]) cube([50, 50, 50]);
//        translate([-1, -48-1+25-25, 0]) cube([200, 50, 50]);
//    }
    
//    % translate([0, -48, 28.1]) color("grey") seal();
    
//    % translate([30, -20]) screw25(length=10);
//    % translate([11.5, -42.5-29.5, 40+14+100]) translate([2, 32+0.5, -20.095]) rotate([180, 0]) pizero();
//}

// ------------------------------ SEAL

translate([0, 0, 0]) rotate([0, 0, 0]) seal1();
translate([0, -53, 0]) rotate([0, 0, 0]) seal2();
//
//% translate([0, -60, 3]) rotate([0, 0, 0]) color("red") seal();

// ------------------------------ PRINT

//translate([0, 0, 0]) rotate([0, 0, 0]) bottom();
//translate([0, -48, 0]) rotate([0, 0, 0]) top();
//translate([0, 52]) camholder();
//translate([-6, 0, 12]) rotate([180, 0]) nutholder(); 
//
//translate([size[0]/2, size[1]/2-60]) cylinder($fn=32, d=2, h=12);

// ------------------------------ FULL ASSEMBLY

//% translate([0, 0]) {
//    translate([0, 0, 0]) rotate([90, -90, 0]) bottom();
//    translate([0, -25.5-0.1, 0]) rotate([90, -90, 0]) seal();
//    
//    translate([-size[1], -52-1.5-.2, 0]) rotate([90, -90, 180]) top();
//    
//    translate([-60, 0, 00]) rotate([90, 0]) screw3(length=40);
//    translate([-60, 0, 07]) rotate([90, 0]) screw3(length=45);
//    translate([-60, 0, 14]) rotate([90, 0]) screw3(length=50);
//} 
    
// ------------------------------ EXPLOSION

//translate([size[1]/2, 50]) explosion();

size = [97, 47];
crad = 6;
crad2 = 3;
    
pixoffset = 15+2;
piyoffset = (size[1]-23)/2;

filter_x = 52.5;

hole_reinforcements = true;

module explosion() {

    translate([]) rotate([0, -90, 90]) bottom();
    
    translate([0, -50, 0]) rotate([0, -90, 90]) seal();
    
    translate([-38.5, -40, 13.5]) rotate([0, -90, 90]) pizero();
    
    translate([-size[1]/2, -110, 50]) rotate([0, 180, 180]) color("grey") import("external_models/RasPi_Camera_v1.stl");
    
    translate([-size[1], -120]) rotate([0, -90, -90]) top();
}

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

module nutholder() {
    s = [4.8, 11, 12]; 
    difference() {
        cube(s);
        translate([-1, s[1]/2, 0]) rotate([0, 90, 0]) cylinder($fn=6, h=10, d=13.00+.3);
    }
}

module camholder() {
    difference() {
        union() {
            color("darkgreen") {
                translate([5, -4]) block(10, 42, 1.2);
                translate([6+3, -4]) block(37, 8.5+4, 1.2, crad=1);
                translate([6+3, 25.5]) block(37, 8.5+4, 1.2, crad=1);
            }
            
            color("orange") {
                translate([21, 06.5]) cylinder($fn=32, d=1.6, h=4);
                translate([21, 06.5+21]) cylinder($fn=32, d=1.6, h=4);
                translate([21+12.5, 06.5]) cylinder($fn=32, d=1.6, h=4);
                translate([21+12.5, 06.5+21]) cylinder($fn=32, d=1.6, h=4);
                
                translate([21, 06.5]) cylinder($fn=32, d=3, h=2.5);
                translate([21, 06.5+21]) cylinder($fn=32, d=3, h=2.5);
                translate([21+12.5, 06.5]) cylinder($fn=32, d=3, h=2.5);
                translate([21+12.5, 06.5+21]) cylinder($fn=32, d=3, h=2.5);
            }
        }
        
        translate([0, 0, -1]) {
            height = 10;
            translate([10, 34-0.5]) cylinder($fn=32, d=2.5+.3, h=20);
            translate([10, 0.5]) cylinder($fn=32, d=2.5+.3, h=20);
        }
    }
}

module top() {
    
    height  = 27;
    height2 = 12.3+3;
    height3 = 5.5;
    
//    translate([pixoffset, piyoffset-6, height2]) color("orange") block(60, 35, 17);
    
    // gasket grip
//    translate([8+4, 1.7+1+1+0.2, height]) color("darkgreen") cube([74.5, 0.8, 1.2]);
//    translate([8+4, size[1]-(1.7+1+1+0.2)-0.8, height]) color("darkgreen") cube([74.5, 0.8, 1.2]);
    
    difference() {
        union() {
            
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);
                
                x=1.6+0.1;
                a=x+1;
                b=x;
                c=x+2+0.8;
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    block(size[0]-8, size[1], 0.1, crad=crad, red=a);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height-6.5, crad=crad, red=b);
                    translate([0, 0, height-4]) block(size[0]-8, size[1], 1, crad=crad, red=c);
                }    
                translate([8-2-0.8, 0, 1.7]) block(size[0]-(8-2-(0.8*2)), size[1], height, crad=crad, red=c);
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
                    
                    foo = size[0]-10;
                    translate([foo, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([foo, 0]) block(size[0], piyoffset+o+r, height, crad=2);
 
                    // screw head support
                    translate([pixoffset, piyoffset, -1]) {
                        translate([0, 0]) cylinder($fn=32, h=height3, d=r2);
                        translate([58, 0]) cylinder($fn=32, h=height3, d=r2);
                        translate([0, 23]) cylinder($fn=32, h=height3, d=r2);
                        translate([58, 23]) cylinder($fn=32, h=height3, d=r2);
                    }  
                }
                
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);        
            }
            
            // camholder reinforcement
//            translate([filter_x-18.6-9, (size[1]-28-6)/2]) block(8+1, 28+6, 6.5);
            translate([filter_x-18.6-4, 0]) block(25, 11, 6.5, crad=3);
            translate([filter_x-18.6-4, size[1]-11]) block(25, 11, 6.5, crad=3);
            
            // socket nut reinforcement
            translate([9.7, size[1]/2+10/2]) rotate([0, 0, -90]) linear_extrude(height=height) polygon([[0, 0], [10, 0], [10-1, 1], [1, 1]]);
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
        translate([filter_x-17.5, 0, -1]) {
            height = 1+2.5+0.5;
            translate([0, size[1]-7]) cylinder($fn=32, d=2.5+.3, h=20);
            translate([0, size[1]-7]) cylinder($fn=32, d=5, h=height);
            translate([0, 7]) cylinder($fn=32, d=2.5+.3, h=20);
            translate([0, 7]) cylinder($fn=32, d=5, h=height);
        }
        
        // force printer to do holes at once
        translate([0, 0, -1]) color("red") {
            translate([-1, 6-.1/2]) cube([7, 0.1, 1.2]);
            translate([-1, size[1]-(6+.1/2)]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, 6-.1/2]) cube([7, 0.1, 1.2]);
            translate([size[0]-7, size[1]-(6+.1/2)]) cube([7, 0.1, 1.2]);
            
            translate([pixoffset, -1]) cube([0.1, 10, 1.2]);
            translate([filter_x-17.5, -1]) cube([0.1, 10, 1.2]);
            translate([filter_x, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+58, -1]) cube([0.1, 10, 1.2]);
            
            translate([0, size[1]-08]) {
            translate([pixoffset, -1]) cube([0.1, 10, 1.2]);
            translate([filter_x-17.5, -1]) cube([0.1, 10, 1.2]);
            translate([pixoffset+58, -1]) cube([0.1, 10, 1.2]);
            }
        }        
    } 
    
    // hole reinforcements for printing
    if (hole_reinforcements) {
        translate([pixoffset, piyoffset, 3]) { // raspberry pi
            translate([0, 0]) cylinder($fn=32, d=6, h=0.3);
            translate([58, 0]) cylinder($fn=32, d=6, h=0.3);
            translate([0, 23]) cylinder($fn=32, d=6, h=0.3);
            translate([58, 23]) cylinder($fn=32, d=6, h=0.3);
        } 
        translate([filter_x-17.5, 0, 3]) { // camera
                translate([0, size[1]-7]) cylinder($fn=32, d=5, h=0.3);
                translate([0, 7]) cylinder($fn=32, d=5, h=0.3);
        }
        translate([0, 0, 3.5]) { // enclosure
            translate([5, 6]) cylinder($fn=32, d=6.1, h=0.3);   
            translate([size[0]-5, 6]) cylinder($fn=32, d=6.1, h=0.3);
            translate([5, size[1]-6]) cylinder($fn=32, d=6.1, h=0.3);
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=6.1, h=0.3);
        }
    }
    
    // imperial nut
    % translate([2, size[1]/2, 15]) rotate([0, 90, 0]) color("grey") difference() {
        cylinder($fn=6, h=5, d=13.00); 
        translate([0, 0, -1]) cylinder($fn=32, h=10, d=6.9);
    }
}


module seal() {
    
    height = 1;
    
    difference() {
        union() {
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);
                
                // cutout
                translate([8, 0, -1]) block(size[0]-8, size[1], height+2, crad=crad, red=1.6+.1+2);
                translate([8-2, 0, -1]) block(size[0]-6, size[1], height+2, crad=crad, red=1.6+.1+2);
            }
            
            // pcb feet
            intersection() {
                union() {
                    r=1;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-14;
 
                    foo = size[0]-10;
                    translate([foo, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([foo, 0]) block(size[0], piyoffset+o+r, height, crad=2);
                }
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);        
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

module seal1() {
    
    height = 1;
    
    difference() {
        union() {
            translate([0, 0]) block2(size[0], size[1], height, crad=crad2);
            translate([0, 0]) block2(size[0], size[1], height+1, crad=crad2, red=2);
            
            // pcb feet
            intersection() {
                union() {
                    r=1;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-14;
 
                    foo = size[0]-10;
                    translate([foo, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([foo, 0]) block(size[0], piyoffset+o+r, height, crad=2);
                }
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);        
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

module seal2() {
    
    height = 1+1.2;
    
    difference() {
        union() {
            difference() {
                translate([-4, -4]) block2(size[0]+8, size[1]+8, height, crad=crad2);
                
                // cutout
                translate([8, 0, -1]) block(size[0]-8, size[1], height+2, crad=crad, red=1.6+.1+2);
                translate([8-2, 0, -1]) block(size[0]-6, size[1], height+2, crad=crad, red=1.6+.1+2);
                
                // cavity
                translate([-0.25, -0.25, 1]) block2(size[0]+0.5, size[1]+0.5, height, crad=crad2);
            }
            
            // pcb feet
            intersection() {
                height=1;
                union() {
                    r=1;
                    o=1;
                    r2=3;
                    
                    pixoffset = size[1]-14;
 
                    foo = size[0]-10;
                    translate([foo, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([foo, 0]) block(size[0], piyoffset+o+r, height, crad=2);
                }
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);        
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
    
    height = 25.5;
    height2 = height;
    
    // nodge
//    translate([0, 0, height]) color("orange") difference() {
//        nodge_height = 0.3*2;
//        width = 0.4+0.1;
//        block(size[0], size[1], nodge_height, crad=crad, red=1.2); 
//        translate([0, 0, -1]) block(size[0], size[1], height, crad=crad, red=1.2+width); 
//    }
    
    difference() {
        union() {
            difference() {
                translate([0, 0]) block2(size[0], size[1], height, crad=crad2);
                                
                x=1.6+0.1;
                a=x+1;
                b=x+1;
                
                // pi cutout
                translate([8, 0, 1.7]) hull() {
                    translate([0, 0, 0]) block(size[0]-8, size[1], 0.1, crad=crad, red=a);
                    translate([0, 0, 1]) block(size[0]-8, size[1], height-6, crad=crad, red=x);
                    translate([0, 0, height-4]) block(size[0]-8-0.8, size[1], 0.1, crad=crad, red=b);
                } 
                translate([8-1, 0, 1.7+1]) block(size[0]-8, size[1], height, crad=crad, red=b);
            }
            
            // wall reinforcement
            points_r = [[0, 0], [5, 0], [4, 1], [1, 1]];
            translate([20+17*0, 1.7]) rotate([0, 0, 000]) linear_extrude(height=height) polygon(points_r);
            translate([20+17*1, 1.7]) rotate([0, 0, 000]) linear_extrude(height=height) polygon(points_r);
            translate([20+17*2, 1.7]) rotate([0, 0, 000]) linear_extrude(height=height) polygon(points_r);
            translate([20+17*3, 1.7]) rotate([0, 0, 000]) linear_extrude(height=height) polygon(points_r);
            
            translate([25+17*0, size[1]-1.7]) rotate([0, 0, 180]) linear_extrude(height=height) polygon(points_r);
            translate([25+17*1, size[1]-1.7]) rotate([0, 0, 180]) linear_extrude(height=height) polygon(points_r);
            translate([25+17*2, size[1]-1.7]) rotate([0, 0, 180]) linear_extrude(height=height) polygon(points_r);
            translate([25+17*3, size[1]-1.7]) rotate([0, 0, 180]) linear_extrude(height=height) polygon(points_r);
            
            translate([22.5, 1.7+1, 1.7+15]) {
                translate([17*0, 0]) rotate([-90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*1, 0]) rotate([-90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*2, 0]) rotate([-90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*3, 0]) rotate([-90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
            }
            translate([22.5, size[1]-1.7-1, 1.7+15]) {
                translate([17*0, 0]) rotate([+90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*1, 0]) rotate([+90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*2, 0]) rotate([+90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
                translate([17*3, 0]) rotate([+90, 0, 0]) cylinder($fn=32, d1=3, d2=2, h=0.5);
            }
            // pcb feet
            intersection() {
                union() {
                    r=1;
                    o=1;
                    r2=3;
                    
                    foo = size[0]-10;
                    translate([foo, 23+piyoffset-o-r]) block(size[0], size[1], height, crad=2);
                    translate([foo, 0]) block(size[0], piyoffset+o+r, height, crad=2);       
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
            
            // screw holes in the top section can be normally sized (3.0+.3)
            // but holes in the bottom section should be slightly wider to 
            // allow the screw to slip right through for easy opening and closing.
            // The bottom holes should be post-processed with a 3.5mm drill.
            
            translate([5, 6]) cylinder($fn=32, d=3.6, h=30);
            translate([5, 6]) cylinder($fn=6, d=6.7, h=4);
            
            translate([size[0]-5, 6]) cylinder($fn=32, d=3.6, h=30);
            translate([size[0]-5, 6]) cylinder($fn=6, d=6.7, h=4);
                   
            translate([5, size[1]-6]) cylinder($fn=32, d=3.6, h=30);
            translate([5, size[1]-6]) cylinder($fn=6, d=6.7, h=4);
            
            translate([size[0]-5, size[1]-6]) cylinder($fn=32, d=3.6, h=30);
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
    if (hole_reinforcements) translate([0, 0, 3]) {
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

module block2(width, depth, height, crad=3, red=0) {
    
    // pythagorean theorem
    redp = sqrt((red*red)/2);
    
    points = [  [0+red, crad+redp], [crad+redp, 0+red],
                [width-crad-redp, 0+red], [width-red, crad+redp],
                [width-red, depth-crad-redp], [width-crad-redp, depth-red],
                [crad+redp, depth-red], [0+red, depth-crad-redp]];
    
    linear_extrude(height=height) polygon(points);
}
