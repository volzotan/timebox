include <camera.scad>;
include <enclosure_util.scad>;

size_btm    = [157, 91];
size_top    = [165, 98];
height      = 47;

wall_thickness      = 2;
bottom_thickness    = 1;

nose_depth  = 66;

lenshole_diameter   = 80;

quality = 64;

mat_saving_holes = true;

// -----------------------

base4();

//translate([8, 27, 12]) color("blue") camera();

// include <socketplate.scad>;


// ------------------------------------------------------------------

module pressureNose() {
    
    nose_width = 20;
    curvature  = 5;
    
    depth = nose_depth - 5;

    translate([0, 5, 0]) difference() {
        union() {           
            translate([nose_width/2, 0, -2]) {
                translate([0, 0, 4]) rotate([270, 0, 0]) scale([1, 0.5, 1]) cylinder(h=depth, d=nose_width, $fn=64);
                translate([0, depth-4+2, 2]) rotate([0, 180, 180]) prism(2,2,2);
                    
            }     
        } 
        difference() {
            offset = 0;
            
            translate([0, depth-curvature/2, offset]) cube([nose_width, 10, 10]);
            translate([0, depth-curvature/2, offset]) rotate([0, 90, 0]) cylinder(h=nose_width, d=curvature, $fn=32);
        }
  
        translate([0, depth-20, wall_thickness]) cube([nose_width, 20, 10]);
    }
    
}

module prism(l, w, h){
    polyhedron(points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]], faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
}

// ------------------------------------------------------------------

module base4() {
    difference() {
    union() {
        difference() {
            translate([size_top[0], 0, 0]) rotate([90, 0, 180]) base3();

            // strap holder opening
            translate([0, 31, 64]) {
                translate([-1, 6, 6]) rotate([0, 90, 0]) cylinder($fn=quality, h=10, d=12);
                translate([-1, 6, 0]) cube([10, 15, 12]);
            }
        }

        // socket triangle
        translate([39, 11, 0]) {
            rotate([0, 0, 0]) triangle(88, 17);
        }

        // socket block
        translate([39, 11, 0]) {
            difference() {  
                cube([88, 46, 12]);    
                translate([-10, 42, 4]) {
                    rotate([0, 90, 0]) {
                        difference() {
                            cube([12, 12, 100]);
                            translate([0, 0, -10]) {
                                cylinder(h = 120, d = 8, $fn=64); 
                            }
                        }
                    }
                }
            }
        }
        
        // pressure noses            
        translate([size_top[0]/2 - 20/2, 0, size_top[1]-wall_thickness]) pressureNose();
        translate([size_top[0]- wall_thickness, 0, 40]) rotate([0, 90, 0]) pressureNose();
        translate([wall_thickness, 0, 40-20]) rotate([0, -90, 0]) pressureNose();
        
    }

    // negative outer shell
    translate([size_top[0], 0, 0]) rotate([90, 0, 180]) {
        difference() {
            translate([-20, -20, -20]) cube([size_top[0]+40, size_top[1]+40, height+20]);
            base1(size_top, size_btm, height);
        }
    }

    // threadhole
    translate([82, 28, -1]) {
        threadhole();
    }
    
    // screw tunnels
    tunnel_height = 6;
     

    translate([43, 13, 0]) {
        cube([13, 100, tunnel_height]);
        translate([6.5, 0, 0]) cylinder(h=tunnel_height, d=13, $fn=32);
    }
    
    translate([110, 13, 0]) {
        cube([13, 100, tunnel_height]);
        translate([6.5, 0, 0]) cylinder(h=tunnel_height, d=13, $fn=32);
    }    
    
    translate([43, 40, -0.01]) cube([12, 20, tunnel_height]);
    translate([111, 40, -0.01]) cube([12, 20, tunnel_height]);

    }
}

module base3() {
    difference() {
        union() {
            base2();
            
            // increase wall to ground connection
            translate([(size_top[0] - size_btm[0])/2, (size_top[1] - size_btm[1])/2, 0]) base2reinforcement();
        }

        // base corner rounding
        translate([0, 0, -0.1]) base2cutter();

        // lens hole
        translate([size_top[0]/2, size_top[1]/2, -1]) cylinder($fn=128, h=3, d=lenshole_diameter);
    
        // material saving holes
        if (mat_saving_holes) {
            distance = 27;
            translate([ distance,
                        distance,
                        -1]) cylinder(h=10, d=30, $fn=32);
            
            translate([ distance,
                        size_top[1]-distance,
                        -1]) cylinder(h=10, d=30, $fn=32);
            
            translate([ size_top[0]-distance,
                        distance,
                        -1]) cylinder(h=10, d=30, $fn=32);
            
            translate([ size_top[0]-distance,
                        size_top[1]-distance,
                        -1]) cylinder(h=10, d=30, $fn=32);
        }
    }
}

module base2reinforcement() {

    addx = 10;
    addy = 10;

    wall_thickness = 1;

    size_top_interior = [size_btm[0]-wall_thickness*2, size_btm[1]-wall_thickness*2];
    size_btm_interior = [size_btm[0]-addx-wall_thickness*2, size_btm[1]-addy-wall_thickness*2];

    difference() {
        base1(size_btm, size_btm, 3, r1=6, r2=6, rd1=6, rd2=6);
        translate([wall_thickness, wall_thickness, -0.01]) base1(size_top_interior, size_btm_interior, 3.03, r1=6, r2=6, rd1=6, rd2=6);   
    }
}

module base2cutter() {

    height = 3;

    addx = 2;
    addy = 2;

    movex = 3;
    movey = 3;

    wall_thickness = 1;

    size_top_exterior = [size_top[0]-movex*2, size_top[1]-movey*2];
    size_btm_exterior = size_top_exterior;

    size_top_interior = [size_top[0]-movex*2, size_top[1]-movey*2];
    size_btm_interior = [size_btm[0]-addx-movex, size_btm[1]-addy-movey];

    translate([movex, movey, 0]) difference() {
        base1(size_top_exterior, size_btm_exterior, height, r1=6, r2=6, rd1=6, rd2=6);
        translate([0, 0, -0.01]) base1(size_top_interior, size_btm_interior, height+0.03, r1=6, r2=6, rd1=6, rd2=6); 
    }
}

module base2() {
    r1_ext = 6;
    r2_ext = 10;

    r1_int = r1_ext - wall_thickness;
    r2_int = r2_ext - wall_thickness;

    difference() {
        base1(size_top, size_btm, height, r1_ext, r2_ext);
        translate([0, 0, 1]) color("green") base1(size_top, size_btm, height, r1_int, r2_int, r1_ext, r2_ext);
    }
}

module base1(top, bottom, h, r1=6, r2=10, rd1=6, rd2=10) { 

    // r1  radius of corner circle
    // rd1 distance of corner circle

    quality = 64;

    diffx = (top[0] - bottom[0])/2;
    diffy = (top[1] - bottom[1])/2;

    hull() {
        linear_extrude(height=0.1) hull() {
            translate([rd1 + diffx, rd1 + diffy, 0])                      circle($fn=quality, r=r1);
            translate([bottom[0]-rd1 + diffx, rd1 + diffy, 0])            circle($fn=quality, r=r1);
            translate([bottom[0]-rd1 + diffx, bottom[1]-rd1 + diffy, 0])  circle($fn=quality, r=r1);
            translate([rd1 + diffx, bottom[1]-rd1 + diffy, 0])            circle($fn=quality, r=r1);
        }
        translate([0, 0, h]) linear_extrude(height=0.1) hull() {   
            translate([rd2, rd2, 0])                                      circle($fn=quality, r=r2);
            translate([top[0]-rd2, rd2, 0])                               circle($fn=quality, r=r2);
            translate([top[0]-rd2, top[1]-rd2, 0])                        circle($fn=quality, r=r2);
            translate([rd2, top[1]-rd2, 0])                               circle($fn=quality, r=r2);
        }
    }
}