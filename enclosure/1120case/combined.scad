// global variables

filter_diameter = 77;

num_screws = 8;
deg = 360/num_screws;
off = deg/2;

q = 64; //256;

print_support = true;

include <../camera.scad>;
//% translate([78, 35, -32]) rotate([0, 0, 180]) camera(longlens=true);
//% translate([0, 0, 0]) rotate([0, 0, 180]) scale([10, 10, 10]) color("green") import("Peli1120.stl");
//% translate([-26, 10, -50]) color("grey") arca_clamp();

//translate([0, 65.9+0]) rotate([-90, 0, 0]) front();
translate([0, 65.9-5, 0]) rotate([90, 0, 0]) back();
//translate([0, 50-2, -50]) rotate([180, 0, 0]) bottom();
//translate([0, 10, -90]) socket();
//
//translate([-89, -7, 47]) rotate([-90, 0, 90]) controller_dock();
//translate([-89+0.5, -7, 47-36]) rotate([90, 0, 90]) import("../zeroholder11.stl");
//
//translate([0, 0, 0]) rotate([0, 0, 0]) bottom();
//
//translate([0, 0, 100]) M5Screw();

// --------------------------------------------------------------------------

//translate([300, -60]) drill_helper();
//translate([180, 0]) front();
//translate([180, 110]) back();
//translate([180, 110]) back2D();
//translate([180, -100, 40]) rotate([-90, 0, 0]) bottom();
//translate([180, -145]) socket();
//translate([240, 0]) controller_dock();

//translate([-300, 0]) hook();

//translate([0, 0, 0]) bottom();
//translate([0, 38, 20.61]) rotate([180, 0, 0]) socket();

module hook() {
//    points = [
//        [0, 0],
//        [15, 0],
//        [15+3, -3],
//        [15+3, -2], 
//        [15+3-2, -4],
//        [15, -4]
//    ];
//    
//    translate([]) rotate([]) linear_extrude(height=10) polygon(points);
    
    difference() {
        union() {
            translate([-1, 0]) hull() {
                translate([]) cylinder($fn=32, d=4, h=14);
                translate([1.5, 5]) cylinder($fn=32, d=1, h=14);
                translate([-1.5, 5]) cylinder($fn=32, d=1, h=14);
            }
            
            translate([-10, 1.5]) cube([10, 4, 14]);
            translate([-11, -34]) block(4, 39.5, 14, crad=1);
            translate([-11-14, -34]) block(16, 5, 14, crad=1);
        }
        
        translate([-17.5, -30, 14/2]) rotate([90, 0, 0]) cylinder($fn=32, d=6, h=14);
        translate([-17.5, -30+1.1, 14/2]) rotate([90, 0, 0]) cylinder($fn=32, d1=8, d2=6, h=2.1);
    }
    
//    translate([+7, -35]) cube([4, 36, 4]);
}

module back2D() {
    projection() back();  
    
//    width = 106.8;
//    translate([-width/2, -width/2]) color("red") cube([width, width, 0.5]);
}

module controller_dock() {
    size = [70, 36];
   
    difference() {
        intersection() {
            union() {
                block(size[0], size[1], 10, crad=4);
            }
            
            points = [[0, 0], [size[0], 0], [size[0], 0.6], [size[0]-1.4, 0.6+1], [7, 5.75], [0, 2]];
            translate([0, size[1]]) rotate([90, 0, 0]) linear_extrude(height=size[1]+2) polygon(points);
        }
        
        // screw
        translate([20, size[1]/2, -1]) rotate([0, 4, 0]) {
            cylinder($fn=32, d=3.3, h=100);
            cylinder($fn=6, d=6.7, h=4.5);
        }
        
        // magnet cavity
        translate([0, 0, -0.1]) color("darkgreen") {
            translate([10, size[1]/2]) cylinder($fn=32, d=8.5, h=1.4);
            translate([size[0]/2, size[1]/2]) cylinder($fn=32, d=8.5, h=1.4);
            translate([size[0]-10, size[1]/2]) cylinder($fn=32, d=8.5, h=1.4);
        }
    }
}

module socket() {
    
    size = [60, 38];
    screw_dist = 8;
    
//    translate([0, 0, 10]) color("red") cube([1, 9, 1]);
//    translate([0, -1, 10-6]) color("red") cube([1, 1, 6]);
    
    intersection() {
        difference() {
            union() {
                translate([-size[0]/2, 0]) block2(size[0], size[1], 10);
            } 
            
            // arca screw
            translate([0, size[1]/2, -1]) cylinder($fn=32, d=6.3+0.5, h=50); 
            translate([0, size[1]/2, 1.6]) cylinder($fn=6, d=13.2, h=10); 

            // screws
            translate([-20, screw_dist, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, size[1]-screw_dist, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([ 20, screw_dist, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([ 20, size[1]-screw_dist, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, screw_dist, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9.1, h=5);
            translate([-20, size[1]-screw_dist, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9.1, h=5);
            translate([ 20, screw_dist, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9.1, h=5);
            translate([ 20, size[1]-screw_dist, -1]) rotate([0, 0, 30]) cylinder($fn=32, d=9.1, h=5);
                
            // center nudge
            translate([0, -2.5, 3]) rotate([-45-15, 0]) hull() {
                cylinder($fn=32, d=3, h=30);
                translate([-4/2, -5]) cube([4, 1, 30]);
            }
        }
        
        // top surface
        a = 10.0;
        b = a-1.5;
        points = [[0, 0], [41, 0], [41, a], [0, b]];
        translate([-30, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=60) polygon(points);
    }
    
    if (print_support) color("orange") {
        translate([-20, screw_dist, 6-2]) cylinder($fn=32, d=6, h=0.2);
        translate([-20, size[1]-screw_dist, 6-2]) cylinder($fn=32, d=6, h=0.2);
        translate([20, screw_dist, 6-2]) cylinder($fn=32, d=6, h=0.2);
        translate([20, size[1]-screw_dist, 6-2]) cylinder($fn=32, d=6, h=0.2);
    }
}

module bottom() {
    
    size = [60, 41];
    
    intersection() {
        difference() {
            union() {
                translate([-size[0]/2, 0]) block2(size[0], size[1], 09);
                
                translate([-size[0]/2, 0]) block2(24, size[1], 14);
                translate([size[0]/2-24, 0]) block2(24, size[1], 14);
            } 
            
            // arca screw
            translate([0, 19+3, -1]) cylinder($fn=32, d=6.3+0.5, h=50); 
            
            // if a Mengs DC-38 arca swiss clamp is used, there are four options:
            // * mounting a 3/8 screw with the head in the plastic part and screw
            //   it directly into the clamp (only accessible from below)
            // * mounting a 1/4 screw with the head in the plastic part and screw a
            //   3/8 to 1/4 adapter into the clamp (only accessible from below)
            // * putting a cone head screw with the head into the clamp and fasten
            //   it with a 1/4 nut in the plastic part 
            // * putting a ISO 10642 / DIN 7991 M6 16mm metric cone head screw into  
            //   the clamp and use a M6 nut in the plastic part
            
            // 1/4 screw head cavity
//            translate([0, size[1]/2, 3]) cylinder($fn=32, d=10, h=10); 
            // 1/4 nut cavity
//            translate([0, size[1]/2, 3]) rotate([0, 0, 30]) cylinder($fn=6, d=13.2, h=10); 
            // M6 nut cavity
            translate([0, 19+3, .4*4+.1]) rotate([0, 0, 30]) cylinder($fn=6, d=11.6, h=10); 
            
            // knob cavity
            translate([-47+10.5, 19+3, -5]) rotate([0, 90, 0]) cylinder($fn=64, d1=45, d2=15, h=10);
            
            // screws
            translate([-20, 8, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 30, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 8, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([20, 30, -1]) cylinder($fn=32, d=5.3, h=30);
            translate([-20, 8, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=8);
            translate([-20, 30, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=8);
            translate([20, 8, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=8);
            translate([20, 30, -1]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=8);
        }
        
        // top surface
        a = 13.0;
        b = a-1.5;
        points = [[0, 0], [41, 0], [41, a], [0, b]];
        translate([-30, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=60) polygon(points);
    }
    
    difference() {  
        translate([size[0]/2-10, 0, -3]) block2(10, size[1], 3);
        translate([0, -1, -3-1]) cube([size[0]/2-5, size[1]+2, 10]);
    }
    
//    if (print_support) color("orange") {
//        translate([-20, screw_dist, 6]) cylinder($fn=32, d=6, h=0.2);
//        translate([-20, size[1]-screw_dist, 6]) cylinder($fn=32, d=6, h=0.2);
//        translate([20, screw_dist, 6]) cylinder($fn=32, d=6, h=0.2);
//        translate([20, size[1]-screw_dist, 6]) cylinder($fn=32, d=6, h=0.2);
//    }
}

module drill_helper() {
    
    screw_dist = 50.2;
    
    intersection() {
        difference() {
            union() {
                cylinder($fn=64, d=90+14, h=4);
                
                // screw support
                for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 0]) {
                    cylinder($fn=32, d=14, h=6);
                    translate([0, 0, 6]) cylinder($fn=32, d1=14, d2=14-2, h=1);
                }
                
                translate([-screw_dist-3.2, -39/2]) cube([10, 39, 4]);
                translate([+screw_dist+3.2-10, -39/2]) cube([10, 39, 4]);
                
                cylinder($fn=32, d1=14, d2=10, h=10);
            }
            
            // main hole
            translate([0, 0, -1]) cylinder($fn=64, d=6.5+0.3, h=100);
        
            // screw holes
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, -1]) cylinder($fn=32, d=5.3, h=50);
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 6]) cylinder($fn=32, d=9, h=50);
        }
    
        union() {
            points = [[-60, -26.15], [-40, -26.15], [-25, -15], [00, -15], [0, 0], [-60, 0]];
            translate([]) linear_extrude(height=100) polygon(points);
            translate([]) mirror([0, 1]) linear_extrude(height=100) polygon(points);
            translate([]) mirror([1, 0]) linear_extrude(height=100) polygon(points);
            translate([]) mirror([0, 1]) mirror([1, 0]) linear_extrude(height=100) polygon(points);
        }
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
    
    screw_dist = 50.2;
    
    difference() {
        union() {
            cylinder($fn=q, d=88+14, h=3);
            translate([0, 0, 3]) cylinder($fn=q, d1=88+14, d2=88+14-2, h=1);
            
            // screw support
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 0]) {
                cylinder($fn=32, d=14, h=6);
                translate([0, 0, 6]) cylinder($fn=32, d1=14, d2=14-2, h=1);
            }
                
            // base angle
            points = [  [-50, 15], [-50, 30], [0, 5], [50, 30], [50, 15], 
                        [20, -12], [-20, -12]
            ];
            
            // translate([0, -50, 0]) linear_extrude(height=5) polygon(points);
            
            // side reinforcements
            translate([-screw_dist-3.2, -39/2]) hull() {
                cube([10, 39, 3]);
                translate([1, 0, 3]) cube([10, 39, 1]);
            }
            translate([+screw_dist+3.2-10, -39/2]) hull() {
                cube([10, 39, 3]);
                translate([-1, 0, 3]) cube([10, 39, 1]);
            }
            
            // extension hole reinforcement
            translate([-screw_dist-3.2, -39/2]) hull() {
                cube([13, 39, 4]);
                translate([1, 0, 4]) cube([11, 39, 1]);
            }
        }
        
        // main hole
        translate([0, 0, -1]) cylinder($fn=64, d=filter_diameter, h=10);
        translate([0, 0, 3]) cylinder($fn=64, d1=filter_diameter, d2=filter_diameter+2, h=1+.1);
    
        // screw holes
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, -1]) cylinder($fn=32, d=5.3, h=50);
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 2]) rotate([0, 0, 30]) cylinder($fn=6, d=9.6, h=50);
    
        // nudge for case curvature
        translate([50, 53.375+.1, -.1]) rotate([90, 0, -90]) linear_extrude(height=100) polygon([[0, 0], [2, 0], [1, 1], [0, 3]]);
        
        // extension hole
        translate([-47,  7, -1]) cylinder($fn=32, d=3.3, h=10);
        translate([-47, -7, -1]) cylinder($fn=32, d=3.3, h=10);
        translate([-47,  7, -1]) cylinder($fn=6, d=6, h=1+3);
        translate([-47, -7, -1]) cylinder($fn=6, d=6, h=1+3);
    }
    
    // hole reinforcements
    translate([-47,  7, 3]) color("orange") cylinder($fn=6, d=6, h=0.2);
    translate([-47, -7, 3]) color("orange") cylinder($fn=6, d=6, h=0.2);
    
    * difference() {
        union() {
            translate([-20, -52, 0]) rotate([90, 0, 0]) block(40, 60, 10);
        }
        translate([0, 0, 40]) rotate([90, 0, 0]) cylinder($fn=32, d=10, h=100);
        translate([0, -60, 40]) rotate([90, 0, 0]) cylinder($fn=32, d=14, h=10);
    }
}

module front() {
    
    height = 42; //13; //42;
    
    // 76mm / 86mm drill
    
    // filter sizes:
    // 67 72 77 82 86 95 112
    //       --    --
    
    // drill: 86 | filter: 86
//    outer_diam = 96;
//    screw_dist = 53;
//    hole_diam = 86;
//    filter_diam = 86;
    
    // drill: 76 | filter: 77
    outer_diam = 88;
    screw_dist = 50.2;
    hole_diam = 76;
    filter_diam = 77;
    
    // filter dimensions 77mm:
    // 79.2 thick ring diameter
    // 76.8 thread diameter
    // 4.5  thick ring height
    // 6.8  total height
    
    difference() {
        union() {
                                        cylinder($fn=q, d=88+14, h=6);
            translate([0, 0, 6])        cylinder($fn=q, d1=88+14, d2=outer_diam+14-2, h=2);
            
            if (height >= 18) {
                translate([0, 0, 8])    cylinder($fn=q, d1=outer_diam+8, d2=outer_diam, h=8);
            } else {
                translate([0, 0, 8])    cylinder($fn=q, d1=outer_diam+8, d2=outer_diam, h=3);
            }
            
                                        cylinder($fn=q, d=outer_diam, h=height-2);
            translate([0, 0, height-2]) cylinder($fn=q, d1=outer_diam, d2=outer_diam-2, h=2);
            
            for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 0]) cylinder($fn=32, d=14, h=8);
        
            translate([-screw_dist-3.2, -39/2]) hull() {
                cube([10, 39, 3]);
                translate([1, 0, 3]) cube([10, 39, 1]);
            }
            
            translate([+screw_dist+3.2-10, -39/2]) hull() {
                cube([10, 39, 3]);
                translate([-1, 0, 3]) cube([10, 39, 1]);
            }
        }
        
        // main hole
        translate([0, 0, -1]) cylinder($fn=q, d=hole_diam, h=100);
    
        // filter cavity
        translate([0, 0, height-(4.5+1.0)]) color("red") cylinder($fn=q, d=79.2+0.5, h=10);
        translate([0, 0, height-(6.8+1.0)]) color("red") cylinder($fn=q, d=76.8+0.5, h=10);
    
        // o-ring cavity
        * difference() {
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
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, -1]) cylinder($fn=32, d=5.3, h=50);
        for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 6]) cylinder($fn=32, d=9, h=50);
    }
    
    // filter ring support
    filter_ring_thread_hole = 76.8+0.5;
    translate([0, 0, height-(6.8+0.5)-5.5]) difference() {
        cylinder($fn=q, d=80, h=5);
        translate([0, 0, -.1]) cylinder($fn=q, d1=filter_ring_thread_hole, d2=filter_ring_thread_hole-2, h=4+.2);
        translate([0, 0, -.1]) cylinder($fn=q, d=filter_ring_thread_hole-2, h=10);
    }
    
    // screws 
    % for(i = [0 : num_screws]) rotate([0, 0, off+deg*i]) translate([screw_dist, 0, 06]) M5Screw(length=18);
}

module arca_clamp() {
    difference() {
        block(51.5, 38, 15, crad=1);
        translate([11, -1, 10]) cube([51.5-11-8, 40, 10]);
        translate([26, 38/2, -1]) cylinder($fn=32, d=10, h=20);
        translate([26, 0, -1]) cylinder($fn=32, d=1, h=20);
    }
    translate([-7, 20, 6]) rotate([0, 90, 0]) cylinder($fn=32, d2=9, d1=20, h=7);
    translate([-20, 20, 6]) rotate([0, 90, 0]) cylinder(d=20, h=13);
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

module block2(width, depth, height, crad=3, red=0) {
    
    // pythagorean theorem
    redp = sqrt(red*red + red*red) - red;
    
    points = [  [0+red, crad+redp], [crad+redp, 0+red],
                [width-crad-redp, 0+red], [width-red, crad+redp],
                [width-red, depth-crad-redp], [width-crad-redp, depth-red],
                [crad+redp, depth-red], [0+red, depth-crad-redp]];
    
    linear_extrude(height=height) polygon(points);
}