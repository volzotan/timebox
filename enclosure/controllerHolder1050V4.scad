
width = 160; // +2
depth = 95;  // -1
height = 1;
curvature_height = 3;
radius_t = 10;
radius_b = 10;


% controllerHolder();

% translate([40-0.5, 80-1, 10]) piHolder();
% translate([107.5, 80-1, 10]) piHolder();


// translate([0, 0, 0]) piHolder();
// translate([0, 10, 0]) piHolder();

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

module controllerHolder() {

    % translate([46, 92-9.5, 6]) rotate([0, 0, -90]) {
        import(file = "controller10.dxf");
        translate([10, 65.5, 0]) cube([26.8, 25, 5]);
        translate([37.5, 0, 0]) cube([16, 18, 5]);
    }
   

    difference() {
        translate([width, 0, height+curvature_height]) rotate([0, 180, 0]) baseplate(5, 10);
        
        difference() {
            union() {
                crad = 5;
                difference() {
                    translate([45, 34]) cube([67, 39+10, 10]);
                    translate([80, 34, 0]) cylinder($fn=32, d=12, h=10);
                } 

                hull() {
                    translate([45-30, 70]) cylinder($fn=32, h=10, r=crad);
                    translate([45-30, 20]) cylinder($fn=32, h=10, r=crad);
                    translate([69, 20]) cylinder($fn=32, h=10, r=crad);
                    translate([69, 70]) cylinder($fn=32, h=10, r=crad);
                }
                hull() {
                    translate([91, 20]) cylinder($fn=32, h=10, r=crad);
                    translate([91, 70]) cylinder($fn=32, h=10, r=crad);
                    translate([145, 20]) cylinder($fn=32, h=10, r=crad);
                    translate([145, 70]) cylinder($fn=32, h=10, r=crad);
                }
            }
        }
    

        // zero fastening screw
        translate([40-0.5, 80-1, -1]) {
            cylinder($fn=6, h=4, d=6.0);
            cylinder($fn=32, h=10, d=2.8);
        }
        
        translate([117.5, 80-1, -1]) {
            cylinder($fn=6, h=4, d=6.0);
            cylinder($fn=32, h=10, d=2.8);
        }        
        
        translate([80, 33, -1]) rotate([0, 0, 30]) cylinder($fn=32, h=5, d=5.3);
        translate([80, 33, 2]) rotate([0, 0, 30]) cylinder($fn=6, h=3, d=9.6);
    }
    
    // central drilling hole support
    translate([80, 33, 2-.2]) rotate([0, 0, 30]) cylinder($fn=6, h=.2, d=10);
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
