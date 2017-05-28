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
    
    lensplate_trans = [88, 49, -1];
    
// front

    sfront          = [160, 98, 100]; 
    w               = 1.6;              // wall thickness
    bw              = 1.6;              // bottom thickness
    
    sback           = [sfront[0], sfront[1], 10];
    
 

//translate([10, 68, 17]) color("blue") camera(longlens=true);

translate([40, -1,  6]) rotate([90, 0, 0]) color("yellow") lensplate(); 

//translate([8, 8, 116]) rotate([0, 0, 0]) color("green") batteries();

translate([0, 0, sfront[1]]) rotate([-90, 0, 0]) front();
translate([48, 40, w]) clamp();
translate([0, -300, 0]) front();

//translate([-10 + 0, 180, 0]) rotate([90, 0, 90]) back();
translate([0, 111.5, 0]) rotate([90, 0, 0]) back();

//translate([0, 0, 0]) cube([160, 100, 80]);

translate([48, 50, -10]) socketplate(marker=false);

translate([0, 100.5, 0]) hinge_front(nuttop=true);
translate([0, 100.5, 52]) hinge_front(nutbottom=true);

translate([160, 80, sfront[2]/2+15]) rotate([0, 90, 0]) lock();

module lock() {
    points0 = [[0, 0], [0, 0.1], [0.1, 0.1]];   
    points1 = [[0, 0], [26, 0], [22, 10], [4, 10]];
    points2 = [[0, 0], [30, 0], [28, 10], [2, 10]];
    
    difference() {
        color("green") hull() {
            translate([15, 0, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points0);
            translate([2, 10, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points1);
            translate([0, 20, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points2);    
        
        }     
        
        translate([15, 28.5, 5]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=5.3);
    }
}

module lock2() {  
    points1 = [[0, 0], [26, 0], [22, 10], [4, 10]];
    points2 = [[0, 0], [30, 0], [28, 10], [2, 10]];
    
    difference() {
        color("green") hull() {
            translate([0, 0, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points2);
            translate([2, 10, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points1); 
        
        }     
        
        translate([15, 30, 5]) rotate([90, 0, 0]) cylinder($fn=32, h=100, d=5.3);
        translate([15, 28, 5]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=8.2);
    }
}

module hinge_front(nuttop=false, nutbottom=false) {
    tol     = 1; // tolerance
    hingew  = 5; // width of the single element
    
    nutheight = 2;
    
    difference() {
        union() {
            if (nutbottom) {
                translate([-7, 0, 10-tol-nutheight]) cylinder($fn=32, h=hingew+nutheight, d=12);
            } else {
                translate([-7, 0, 10-tol]) cylinder($fn=32, h=hingew, d=12);
            }
                
            translate([-7, 0, 10+2*hingew]) cylinder($fn=32, h=hingew, d=12);
            
            if (nuttop) {
                translate([-7, 0, 10+4*hingew+tol]) cylinder($fn=32, h=hingew+nutheight, d=12);
            } else {
              translate([-7, 0, 10+4*hingew+tol]) cylinder($fn=32, h=hingew, d=12);       
            }
            
            points = [[0, -0.5], [-6, 6], [-10.5, -3.9], [0, -15], [0, 0]];
            
            if (nuttop) {
                translate([0, 0, 10-tol]) color("green") linear_extrude(height=5*hingew+2*tol+nutheight) polygon(points);
            }
            if (nutbottom) {
                translate([0, 0, 10-tol-nutheight]) color("green") linear_extrude(height=5*hingew+2*tol+nutheight) polygon(points);
            } 
            if (!nuttop && !nutbottom) {
                translate([0, 0, 10-tol]) color("green") linear_extrude(height=5*hingew+2*tol) polygon(points);                
            }
        }
        
        translate([-7, 0, 0]) cylinder($fn=32, h=50, d=5.3);
        
        if (nuttop) {
            translate([-7, 0, 35]) cylinder($fn=6, h=10, d=9); //?
        } 
        if (nutbottom) {
            translate([-7, 0, 0]) cylinder($fn=6, h=9, d=9); //?
        }  
        
        translate([-7, 0, 10+1*hingew-tol]) cylinder($fn=32, h=hingew+tol, d=12.5);
        translate([-7, 0, 10+3*hingew]) cylinder($fn=32, h=hingew+tol, d=12.5);
    }
}

module hinge_back() {
    tol     = 1; // tolerance
    hingew  = 5;   // width of the single element
    
    difference() {
        union() {
            translate([-7, 0, 10-tol]) cylinder($fn=32, h=hingew, d=12);
            translate([-7, 0, 10+2*hingew]) cylinder($fn=32, h=hingew, d=12);
            
            points = [[0, 0], [-1.5, 2.5], [-12.2, -3], [-7, -10], [0, -10], [0, 0]];
            translate([0, 0, 10-tol]) color("green") linear_extrude(height=3*hingew+1*tol) polygon(points);
            
        }
        
        translate([-7, 0, -1]) cylinder($fn=32, h=50, d=5.3);

        translate([-7, 0, 10+1*hingew-tol]) cylinder($fn=32, h=hingew+tol, d=12.5);
    }
}

module front() {
    corn            = 5; 
    corn2           = 5;
    
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
    
    union() {
    difference() {
        
        frontpoints = [ [0, 0], [0, corn2], [-corn2, 0]];
        
        union() { 
            // outer hull
            linear_extrude(height=sfront[2]) polygon(points_ext);
            
        }
        
        // inner hull
        translate([0, 0, bw]) difference() {
            linear_extrude(height=sfront[2]) polygon(points_int);
   
            translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([sfront[0], sfront[1]-0.01, -0.01]) rotate([180, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([-0.01, sfront[1], -0.01]) rotate([90, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
            translate([sfront[0]-0.01, sfront[1], -0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);          
        }
       
        // lens hole
        translate(lensplate_trans) {
            translate()cylinder($fn=128, h=10, d=79);
            
            // screws
            distx = 43;
            disty = 38;
            translate([-distx, -disty])   cylinder($fn=32, h=10, d=3.3);
            translate([distx, -disty])    cylinder($fn=32, h=10, d=3.3);
            translate([-distx, disty])    cylinder($fn=32, h=10, d=3.3);
            translate([distx, disty])     cylinder($fn=32, h=10, d=3.3);
        }
        
        // top
        translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        //translate([141, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=40) polygon(frontpoints);
        
        frontpoints2 = [ [0, 0], [0, 1], [-1, 0]];
        translate([-1, -0.01, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints2);
      
        // bottom 
        translate([sfront[0], sfront[1]+0.01, -0.01]) rotate([180, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        
        // left/right 
        translate([-0.01, 100, -0.01]) rotate([90, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
        translate([sfront[0]+0.01, sfront[1], -0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
    }
    
    //translate([190, 40, 40]) cube([10, 20, 40]);
    
        // lensplate
        translate(lensplate_trans) {
            distx = 43;
            disty = 38;
            difference() {
                translate([0, 0, 1]) union() {
                    translate([-distx, -disty])   cylinder($fn=32, h=4, d=9);
                    translate([distx, -disty])    cylinder($fn=32, h=4, d=9);
                    translate([-distx, disty])    cylinder($fn=32, h=4, d=9);
                    translate([distx, disty])     cylinder($fn=32, h=4, d=9);
                }
                translate([-distx, -disty])   cylinder($fn=6, h=6, d=6); // ?
                translate([distx, -disty])    cylinder($fn=6, h=6, d=6);
                translate([-distx, disty])    cylinder($fn=6, h=6, d=6);
                translate([distx, disty])     cylinder($fn=6, h=6, d=6);
            }    
        }   
    }
}

module back() {
    
    corn            = 5; 
    corn2           = 5;
    
    w1 = w+0.1;
    w2 = w1+1.2;
    lid_height = 13;
    
    points_ext = [  [0              , corn],
                    [corn           ,   0],
                    [sback[0]-corn  ,   0],
                    [sback[0]       , corn],
                    [sback[0]       , sback[1]-corn],
                    [sback[0]-corn  , sback[1]],
                    [corn           , sback[1]],
                    [0              , sback[1]-corn],
    ];
    
    points_int1 = [  [w1              , corn+w1],
                    [corn+w1         , 0+w1],
                    [sback[0]-corn-w1, 0+w1],
                    [sback[0]-w1     , corn+w1],
                    [sback[0]-w1     , sback[1]-corn-w1],
                    [sback[0]-corn-w1, sback[1]-w1],
                    [corn+w1         , sback[1]-w1],
                    [0+w1            , sback[1]-corn-w1],
    ];
    
    points_int2 = [  [w2              , corn+w2],
                    [corn+w2         , 0+w2],
                    [sback[0]-corn-w2, 0+w2],
                    [sback[0]-w2     , corn+w2],
                    [sback[0]-w2     , sback[1]-corn-w2],
                    [sback[0]-corn-w2, sback[1]-w2],
                    [corn+w2         , sback[1]-w2],
                    [0+w2            , sback[1]-corn-w2],
    ];
    
    difference() {
        frontpoints = [ [0, 0], [0, corn2], [-corn2, 0]];
        
        union() { 
            // outer hull
            linear_extrude(height=sback[2]) polygon(points_ext);
            linear_extrude(height=lid_height) polygon(points_int1);
        }
        
        // inner hull
        translate([0, 0, bw]) difference() {
            linear_extrude(height=sfront[2]) polygon(points_int2);
   
        }
    }
    
    // - tolerance / 2
    translate([0, 40-1/2, 10]) rotate([90, 0, 0]) hinge_back();
    translate([0, 92-1/2, 10]) rotate([90, 0, 0]) hinge_back();
    
    translate([160, 65, 10]) rotate([-90, 0, -90]) lock2();
}

module clamp() {
    difference() {
        union() {
            points = [[0, 0], [8, 0], [0, 8]];
            translate([0, 0, 0]) rotate([0, -90, -180]) linear_extrude(height=80) polygon(points);
            
            difference() {
                translate([]) cube([80, 50, 8]);
                translate([20, 10, 2]) cube([38, 60, 10]);
            }
            translate([58, 30, 0]) intersection() {
                rotate([0, 90, 0]) cylinder($fn=32, h=22, d=20);
                translate([0, -10, 0]) cube([22, 20, 20]);
            }
        }
        
        translate([50+2, 30, 4.6]) rotate([0, 90, 0]) cylinder($fn=32, h=30, d=5.3);
    
        translate([0, 10, -1]) {
            dist = 7;
            
            translate([dist, dist])         cylinder($fn=32, h=10, d=8.3);
            translate([80-dist, dist])      cylinder($fn=32, h=10, d=8.3);
            translate([80-dist, 40-dist])   cylinder($fn=32, h=10, d=8.3);
            translate([dist, 40-dist])      cylinder($fn=32, h=10, d=8.3);
        }
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