controllerHolder();

module controllerHolder() {

    width = 160; // +2
    depth = 95;  // -1
    height = 2;
    curvature_height = 3;
    radius_t = 10;
    radius_b = 10;
    
    draw_pcb = true;
    
    pcb_offset = [55, 17, 5];
    
    translate(pcb_offset) {
        if (draw_pcb) {
        color([0.7, 0.7, 0.7]) translate([0, 0, 3]) import(file = "controller4.dxf");
        }
    }

    difference() {
        translate([width, 0, height+curvature_height]) rotate([0, 180, 0]) baseplate(5, 10);
        
        translate(pcb_offset) {
            translate([0,   53.3, -10]) pug();
            translate([33,  65,   -10]) pug();
            translate([33,  10,   -10]) pug();
            translate([66,  3.5,  -10]) pug();
            translate([89,  3.5,  -10]) pug();
            translate([66,  61.5, -10]) pug();
            translate([89,  61.5, -10]) pug();
        }
        
        // viewfinder cutout
        translate([32, 7.5, -1]) cube([41, 25, 10]);
    
        // pi cutout
        translate([114, 16, -1]) cube([35, 70, 10]); 
        
        // board cutout
        translate([72, 16, -1]) cube([43, 67, 10]); 
        translate([32, 32, -1]) cube([41, 51, 10]); 
   
    }
    
                    

    // modules                
    
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
}
