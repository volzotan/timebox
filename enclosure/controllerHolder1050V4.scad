
width = 160; // +2
depth = 95;  // -1
height = 1;
curvature_height = 3;
radius_t = 10;
radius_b = 10;


controllerHolder();
translate([0, depth/2-40/2, 4]) screwHolder();
translate([width, depth/2+40/2, 4]) rotate([0, 0, 180]) screwHolder();

translate([40-0.5, 80-1, 10]) piHolder();
translate([107.5, 80-1, 10]) piHolder();

translate([-3, depth/2, 9]) rotate([0, 90, 0]) cylinder(h=30, d=1);

module piHolder() {

    difference() {
        color("red") hull() {
            translate([]) cylinder($fn=32, h=3, d=9);
            translate([10, 0, 0]) cylinder($fn=32, h=3, d=9);
        }
        
        
        translate([0, 0, -1]) cylinder($fn=32, h=10, d=2.8);
        translate([0, 0, 2]) cylinder($fn=32, h=10, d=6.1);
        
        translate([10, 0, -1]) cylinder($fn=32, h=10, d=2.8);
        translate([10, 0, 1.5]) cylinder($fn=6, h=10, d=6.0);
    }
}

module screwHolder() {
    difference() {
        union() {
            points = [[0, 0], [30, 0], [30, 2], [20, 10], [10, 10], [0, 2]];
            translate([0, 5]) rotate([90, 0, 90]) linear_extrude(height=5) polygon(points);

            points2 = [[5, 0], [14, 0], [16, 5], [24, 5], [26, 0], [35, 0], [35, 10], [5, 10]];
            translate([10, 0]) rotate([0, 0, 90]) linear_extrude(height=5) polygon(points2);
            //translate([0, 0, 0]) cube([10, 40, 2]);
            
            translate([5, 5]) cylinder($fn=32, h=5, d=10);
            translate([5, 35]) cylinder($fn=32, h=5, d=10);
        }
        
        translate([5, 5]) {
            translate([0, 0, 1.8]) cylinder($fn=32, h=10, d=6.1); 
            translate([0, 0, -1]) cylinder($fn=32, h=10, d=3.3);
        }
        translate([5, 35]) {
            translate([0, 0, 1.8]) cylinder($fn=32, h=10, d=6.1); 
            translate([0, 0, -1]) cylinder($fn=32, h=10, d=3.3);
        }
         
        translate([0, 20, 5]) rotate([360/12, 0, 0]) rotate([0, 90, 0]) {
            translate([0, 0, 2]) cylinder($fn=6, h=10, d=6.6);
            translate([0, 0, -1]) cylinder($fn=32, h=10, d=3.3);
        }
    }
}

module controllerHolder() {
 
//    % translate([51+5, 20+60, -20]) rotate([90, 0, -90]) {
//        import(file = "RaspberryPiZero.STL");
//        translate([5, 20, -16]) cube([18, 5, 16]);
//    }
    % translate([46, 92-9.5, 6]) rotate([0, 0, -90]) {
        import(file = "controller10.dxf");
        translate([10, 65.5, 0]) cube([26.8, 25, 5]);
        translate([37.5, 0, 0]) cube([16, 18, 5]);
    }

    difference() {
        translate([width, 0, height+curvature_height]) rotate([0, 180, 0]) baseplate(5, 10);
        
//        translate(pcb_offset) {
//            translate([0,   53.3, -10]) pug();
//            translate([33,  65,   -10]) pug();
//            translate([33,  10,   -10]) pug();
//            translate([66,  3.5,  -10]) pug();
//            translate([89,  3.5,  -10]) pug();
//            translate([66,  61.5, -10]) pug();
//            translate([89,  61.5, -10]) pug();
//        }
        
        
          translate() {
              crad = 5;
              translate([45, 44]) cube([67, 39, 10]);

              hull() {
                  translate([45-30, 70]) cylinder($fn=32, h=10, r=crad);
                  translate([45-30, 20]) cylinder($fn=32, h=10, r=crad);
                  translate([145, 20]) cylinder($fn=32, h=10, r=crad);
                  translate([145, 70]) cylinder($fn=32, h=10, r=crad);
              }
          }
          
//        // viewfinder cutout
//        translate([32, 7.5, -1]) {
//            hull() {
//                crad = 4;
//                translate([0, 35-1]) cube([41, 1, 10]);
//                translate([crad, crad]) cylinder($fn=32, h=10, r=crad);
//                translate([41-crad, crad]) cylinder($fn=32, h=10, r=crad);
//            }
//        }
//        
//        // board cutout
//        translate([100, 24, -1]) cube([51, 67, 10]); 
//        translate([87, 4, -1]) {
//            hull() {
//                crad = 4;
//                translate([crad, crad]) cylinder($fn=32, h=10, r=crad);
//                translate([crad, 87-crad]) cylinder($fn=32, h=10, r=crad);
//                translate([54-crad, crad]) cylinder($fn=32, h=10, r=crad);
//                translate([10, 10, 0]) cube([44, 77, 10]); 
//            }
//        }
//            
//        // fastening screw
//        translate([width/2, depth/2-13, 2]) cylinder($fn=6, h=10, d=6.6);
//        translate([width/2, depth/2-13, -1]) cylinder($fn=32, h=10, d=3.3);


        //translate([40, 80-6]) cube([8, 8, 8]);

        // zero fastening screw
        translate([40-0.5, 80-1, -1]) {
            cylinder($fn=6, h=4, d=6.0);
            cylinder($fn=32, h=10, d=2.8);
        }
        
        translate([117.5, 80-1, -1]) {
            cylinder($fn=6, h=4, d=6.0);
            cylinder($fn=32, h=10, d=2.8);
        }
   
        // screwholder screw
        translate([5, depth/2-15, -1]) cylinder($fn=6, h=4, d=6.6);
        translate([5, depth/2-15, -1]) cylinder($fn=32, h=10, d=3.3);
        translate([5, depth/2+15, -1]) cylinder($fn=6, h=4, d=6.6);
        translate([5, depth/2+15, -1]) cylinder($fn=32, h=10, d=3.3);
        
        translate([width-5, depth/2-15, -1]) cylinder($fn=6, h=4, d=6.6);
        translate([width-5, depth/2-15, -1]) cylinder($fn=32, h=10, d=3.3);
        translate([width-5, depth/2+15, -1]) cylinder($fn=6, h=4, d=6.6);
        translate([width-5, depth/2+15, -1]) cylinder($fn=32, h=10, d=3.3);
   
        // pi holder 1
//        tol = 0.4;
//        translate([66-tol, 54-tol, -1]) {
//            translate([0, 0, 0]) cube([19+2*tol, 12+2*tol, 4+tol]);
//            translate([14+tol, 6.5, -1]) cylinder($fn=32, h=10, d=3+.3);
//        }
        
    }
}
    
//    translate([48, 80, 3]) {
//        cylinder($fn=32, h=10, d=10);
//        translate([-5, 0]) cube([10, 10, 10]);
//        translate([-10, -5]) cube([10, 10, 10]);
//    }
//    translate([48+61, 80, -7.5]) {
//        cylinder($fn=32, h=10, d=10);
//        translate([-5, 0]) cube([10, 10, 10]);
//        translate([0, -5]) cube([10, 10, 10]);
//    }

    //% translate([66, 54]) piholder1();
                    

// modules                

module piholder1() {
    crad = 3;
    height = 3;
    
    difference() {
        hull() {
            translate([crad, crad]) cylinder($fn=32, h=height, r=crad);
            translate([0, 6]) cube([19, 6, height]);
            translate([6, 0]) cube([19-6, 6, height]);
        } 
    
        // pi cutout
        translate([4.5, 5.5, -.1]) cylinder($fn=32, h=2, d=5);
        translate([0, -2.1, -.1]) cube([7, 7.5, 2]);
        translate([0, 0.2, -.1]) cube([4.5, 7.8, 2]);
        
        // screw holes
        translate([2.5, 2.5, -1]) cylinder($fn=32, h=10, d=2.5+.3);
        translate([14, 6, -1]) cylinder($fn=32, h=10, d=3+.3);
    }
}

// ---

module baseplate(rounding_diameter, rounding_diameter2) {       
    difference() {
        union() {
            xy_off = 0;
            
            intersection() {
                diameter = 772;
                offset = -diameter/2 + height + curvature_height;
                  
                
                translate([xy_off/2, xy_off/2, height]) 
                    block([width-0, depth-0, 0.1], [width-xy_off, depth-xy_off, 0.1], curvature_height);
                
                translate([0, depth/2, offset]) rotate([0, 90, 0]) {
                    cylinder(h=width, d=diameter, $fn=512);
                }
            }   
            
           
            
            block([width-xy_off, depth-xy_off, 0.1], [width, depth, 0.1], height);
        }
    
        translate([-0.01, -0.01, 0]) difference() {
            cube([width+0.02, rounding_diameter/2, rounding_diameter/2]);
            translate([0, rounding_diameter/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter, $fn=128);
        }
        translate([width-0.01, depth-0.01, 0]) rotate([180, 180, 0]) difference() {
            cube([width+0.02, rounding_diameter/2, rounding_diameter/2]);
            translate([0, rounding_diameter/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter, $fn=128);
        }
        translate([width+0.01, 0.01, 0]) rotate([0, 0, 90]) difference() {
            cube([depth+0.02, rounding_diameter2/2, rounding_diameter2/2]);
            translate([0, rounding_diameter2/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter2, $fn=128);
        }
        translate([-0.01, depth-0.01, 0]) rotate([0, 0, 270]) difference() {
            cube([depth+0.02, rounding_diameter2/2, rounding_diameter2/2]);
            translate([0, rounding_diameter2/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter2, $fn=128);
        }
    }          
}

module pug() {
    cylinder(h=20, d=2.8, $fn=32);
}

module cornercutter_vert(r, h) {    
    translate([0, 0, -0.01]) {
        difference() {
        cube([r, r, h+1]);
        translate([r, r, 0])
            cylinder(h=h+1, r=r, $fn=65);
        }
    }    
}

module block(top, bottom, h) {    
    hull() {
        translate([ (top[0]-bottom[0])/2, 
                    (top[1]-bottom[1])/2, 
                    0]) {
            
            difference() {
                cube(bottom);
                
                translate([0, 0, 0]) rotate([0, 0, 0]) cornercutter_vert(radius_b, 1);
                translate([bottom[0]+0.01, -0.01, 0]) rotate([0, 0, 90]) cornercutter_vert(radius_b, 1);
                translate([bottom[0]+0.01, bottom[1]+0.01, 0]) rotate([0, 0, 180]) cornercutter_vert(radius_b, 1);
                translate([-0.01, bottom[1]+0.01, 0]) rotate([0, 0, 270]) cornercutter_vert(radius_b, 1);
            }
        }
        translate([0, 0, h]) {
            difference() {
                cube(top);
                
                translate([0, 0, 0]) rotate([0, 0, 0]) cornercutter_vert(radius_t, 1);
                translate([top[0]+0.01, -0.01, 0]) rotate([0, 0, 90]) cornercutter_vert(radius_t, 1);
                translate([top[0]+0.01, top[1]+0.01, 0]) rotate([0, 0, 180]) cornercutter_vert(radius_t, 1);
                translate([-0.01, top[1]+0.01, 0]) rotate([0, 0, 270]) cornercutter_vert(radius_t, 1);
            }
        }
    }
}
