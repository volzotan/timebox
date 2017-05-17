include <camera.scad>;
include <enclosure_util.scad>;
include <socketplate.scad>;

// lensplate

    baseplate       = [96, 86, 3];
    crad            = 3; 
    
    outer_diam = 82;
    inner_diam = 73 + 6;
    height = 6;
    
    scr             = 5; // screw distance
    
// front

    sfront          = [160, 98, 100]; 
    w               = 1.6;              // wall thickness
    bw               = 1.2;             // bottom thickness
    
 

translate([12, 68, 17]) color("blue") camera(longlens=true);

translate([42, -1,  6]) rotate([90, 0, 0]) color("yellow") lensplate(); 

//translate([120, 60, 0]) rotate([0, 0, 180]) arcaclamp();

//translate([8, 8, 16]) rotate([0, 0, 0]) color("green") batteries();

translate([0, 0, sfront[1]]) rotate([-90, 0, 0]) front();
translate([38, 20, w]) clamp();
//front();

//translate([0, 120, 0]) back();

//translate([0, 0, 0]) cube([160, 100, 80]);

translate([38, 28, -10]) socketplate(marker=true);

translate([0, 100.5, 0]) hinge();
translate([0, 100.5, 60]) hinge();

module hinge() {
    tol = 0.1; // tolerance
    
    difference() {
        union() {
            translate([-6, 0, 10-tol]) cylinder($fn=32, h=3, d=12);
            translate([-6, 0, 16]) cylinder($fn=32, h=3, d=12);
            translate([-6, 0, 22+tol]) cylinder($fn=32, h=3, d=12);
            
            points = [[0, -0.5], [-6, 6], [-10.5, -3.9], [0, -15], [0, 0]];
            translate([0, 0, 10-tol]) color("green") linear_extrude(height=15+2*tol) polygon(points);
            
        }
        
        translate([-6, 0, 9]) cylinder($fn=32, h=30, d=5.3);

        translate([-6, 0, 13-tol]) cylinder($fn=32, h=3+tol, d=12.5);
        translate([-6, 0, 19]) cylinder($fn=32, h=3+tol, d=12.5);
    }
}

module front() {
    corn            = 5; 
    
    points_ext = [  [0              , corn],
                    [corn           ,   0],
                    [sfront[0]-corn ,   0],
                    [sfront[0]      , corn],
                    [sfront[0]      , sfront[1]-corn],
                    [sfront[0]-corn , sfront[1]],
                    [corn           , sfront[1]],
                    [0              , sfront[1]-corn],
    ];
    
    points_int = [  [w              , corn+w],
                    [corn+w         , 0+w],
                    [sfront[0]-corn-w, 0+w],
                    [sfront[0]-w    , corn+w],
                    [sfront[0]-w    , sfront[1]-corn-w],
                    [sfront[0]-corn-w, sfront[1]-w],
                    [corn+w         , sfront[1]-w],
                    [0+w            , sfront[1]-corn-w],
    ];
    
    difference() {
        
        frontpoints = [ [0, 0], [0, 5], [-5, 0]];
        
        // outer hull
        linear_extrude(height=sfront[2]) polygon(points_ext);
        
        translate([0, 0, bw]) difference() {
            linear_extrude(height=sfront[2]) polygon(points_int);
   
            translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([160, 100-0.01, -0.01]) rotate([180, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([-0.01, 100, -0.01]) rotate([90, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([sfront[0]-0.01, sfront[1], -0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);          
        }
       
        // lens hole
        translate([90, 51, -1]) cylinder($fn=128, h=10, d=79);
        
        // top
        translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        //translate([141, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=40) polygon(frontpoints);
        
        frontpoints2 = [ [0, 0], [0, 1], [-1, 0]];
        translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints2);
      
        // bottom 
        translate([160, 100+0.01, -0.01]) rotate([180, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        
        // left/right 
        translate([-0.01, 100, -0.01]) rotate([90, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        translate([sfront[0]+0.01, sfront[1], -0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
    }
    
    //translate([190, 40, 40]) cube([10, 20, 40]);
}

module back() {
    cube([190, 5, 106]);
}

module clamp() {
    difference() {
        union() {
            difference() {
                translate([]) cube([80, 50, 8]);
                translate([20, 10, 2]) cube([38, 60, 10]);
            }
            
            translate([58, 30, 0]) rotate([0, 90, 0]) cylinder(h=22, d=20);
        }
        
        translate([50, 30, 4.6]) rotate([0, 90, 0]) cylinder(h=30, d=5.3);
    }
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