include <camera.scad>;
include <enclosure_util.scad>;

// lensplate

    baseplate       = [96, 86, 3];
    crad            = 3; 
    
    outer_diam = 82;
    inner_diam = 73 + 6;
    height = 50;
    
    scr             = 5; // screw distance
    
// front

    sfront          = [200, 95, 58]; 
    w               = 1.6;              // wall thickness
    bw               = 1.2;             // bottom thickness
    
 

//translate([12, 25, 22]) color("blue") camera(longlens=true);

translate([42, -10, 12]) rotate([90, 0, 0]) lensplate(); 

//translate([120, 60, 0]) rotate([0, 0, 180]) arcaclamp();

//translate([150, 65, 40]) color("green") batteries();

translate([0, 0, sfront[1]]) rotate([-90, 0, 0]) front();
//front();

translate([0, 120, 0]) back();

//translate([50, 6, -10]) socketplate();

module front() {
    points_ext = [  [  0,  10],
                    [ 10,   0],
                    [190,   0],
                    [sfront[0],  10],
                    [sfront[0],  85],
                    [190, sfront[1]],
                    [ 10, sfront[1]],
                    [  0,  85],
    ];
    
    points_int = [  [  w,  10+w],
                    [ 10+w, 0+w],
                    [190-w, 0+w],
                    [sfront[0]-w,  10+w],
                    [sfront[0]-w,  85-w],
                    [190-w, sfront[1]-w],
                    [ 10+w, sfront[1]-w],
                    [  0+w,  85-w],
    ];
    
    difference() {
        linear_extrude(height=sfront[2]) polygon(points_ext);
        
        translate([0, 0, bw]) difference() {
            linear_extrude(height=sfront[2]) polygon(points_int);
   
            frontpoints = [ [0, 0], [0, 10], [-10, 0]];
            translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        }
        
       frontpoints = [ [0, 0], [0, 10], [-10, 0]];
       translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
      
    }
    
    //translate([190, 40, 40]) cube([10, 20, 40]);
}

module back() {
    cube([190, 5, 106]);
}

module socketplate() {
        cube([80, 40, 8]);
}

module lensplate() {
    
    difference() {
        union() {
            
            // baseplate
            hull() {
                translate([crad/2, crad/2, 0]) cylinder($fn=32, h=3, d=3);
                translate([baseplate[0] - crad/2, crad/2, 0]) cylinder($fn=32, h=3, d=3);
                translate([baseplate[0] - crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=3, d=3);
                translate([crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=3, d=3);
            }
            
            // cylinder
            translate([baseplate[0]/2, baseplate[1]/2, 3]) cylinder($fn=128, h=3, d1=outer_diam+2, d2=outer_diam);
            translate([baseplate[0]/2, baseplate[1]/2, 0]) cylinder($fn=128, h=height, d=outer_diam);
        
            // reinforcement for screwholes
            translate([scr, scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([baseplate[0]-scr, scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([baseplate[0]-scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=2, d=10);
        }
        translate([baseplate[0]/2, baseplate[1]/2, -1]) cylinder($fn=128, h=height+2, d=inner_diam);
    
        // screwholes
        translate([scr, scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([baseplate[0]-scr, scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([scr, baseplate[1]-scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([baseplate[0]-scr, baseplate[1]-scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        
        // screwhole nuttraps
        translate([scr, scr, 3]) cylinder($fn=32, h=3, d=6);
        translate([baseplate[0]-scr, scr, 3]) cylinder($fn=32, h=3, d=6);
        translate([scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=3, d=6);
        translate([baseplate[0]-scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=3, d=6);
    }
    
    difference() {
        translate([baseplate[0]/2, baseplate[1]/2, height-4]) cylinder($fn=128, h=2, d=inner_diam);    
        translate([baseplate[0]/2, baseplate[1]/2, height-4-0.1]) cylinder($fn=128, h=2.2, d1=inner_diam, d2=inner_diam-2);    
    }
}

// utilities 

module batteries() {
    translate([9, 9, 0]) cylinder($fn=32, h=65, d=18);
    translate([18+9+2, 9, 0]) cylinder($fn=32, h=65, d=18);
    translate([9, 18+9+2, 0]) cylinder($fn=32, h=65, d=18);
    translate([18+9+2, 18+9+2, 0]) cylinder($fn=32, h=65, d=18);
}

module arcaclamp() {
    
    translate([20, 0, 0]) cube([53, 39, 15]);
    
    translate([0, 39/2, 5]) rotate([0, 90, 0]) cylinder($fn=32, h=20, d=20);
    
}