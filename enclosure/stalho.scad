include <camera.scad>;
include <enclosure_util.scad>;
//include <socketplate.scad>;
include <clamptest.scad>;


// lensplate

    baseplate       = [96, 86, 3];
    crad            = 6; 
    
    outer_diam = 79 + 0.3; // upper part of the filter
    inner_diam = 77 + 0.3; // screw part of the filter
    height = 6;
    
    // filter height: 6.6
    // upper part height: 4.4
    
    scr             = 5; // screw distance
    
    lensplate_trans = [88, 48, -1];
    
// front

    sfront          = [160, 94, 100]; 
    w               = 1.6;              // wall thickness
    bw              = 1.6;              // bottom thickness
    
    sback           = [sfront[0], sfront[1], 10];
    
//%translate([10, 69, 12+w]) color("blue") %camera(longlens=true);
%translate([8, 8, 116]) rotate([0, 0, 0]) color("green") batteries();
//%translate([0, 0, 200]) pcb();

%translate([40, -1-10,  3]) rotate([90, 0, 0]) color("yellow") lensplate();
//%translate([40, -1-10,  3]) rotate([90, 0, 0]) color("yellow") lensplate2(); 

translate([0, 0, sfront[1]]) rotate([-90, 0, 0]) front();

%translate([123, 90, w]) rotate([0, 0, 180]) clamp();
%translate([123-70, 90, -0.2]) rotate([180, 0, 0]) plate();

//translate([0, 100.5, 0-0.1]) hinge_front(nuttop=true);
//translate([0, 100.5, 52-0.1]) hinge_front(nutbottom=true);

%translate([-17 + 0, 130, 0]) rotate([90, 0, 90]) back();

//translate([0, 111.5, 0]) rotate([90, 0, 0]) back();
%translate([0, -300, 0]) rotate([0, 0, 0]) back();


//translate([200, 0, 0]) lock3();
//translate([160, 100, 76]) rotate([0, 0, 180])lock3();
//translate([220, 0, 0]) rotate([0, 0, 0])lock4();


module lock() {
    points0 = [[0, 0], [0, 0.1], [0.1, 0.1]];   
    points1 = [[0, 0], [26, 0], [22, 11], [4, 11]];
    points2 = [[0, 0], [30, 0], [28, 11], [2, 11]];
    
    difference() {
        color("green") hull() {
            translate([15, 0, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points0);
            translate([2, 10, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points1);
            translate([0, 20, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points2);    
        
        }     
        
        translate([15, 28.5, 4]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=5.3);
    }
    
    // M5 nut cavity hole support
    translate([10, 16.2, 0]) color("red") cube([10, 0.3, 10]);
}

module lock2() {  
    points1 = [[0, 0], [26, 0], [22, 11], [4, 11]];
    points2 = [[0, 0], [30, 0], [28, 11], [2, 11]];
    
    difference() {
        color("green") hull() {
            translate([0, 0, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points2);
            translate([2, 10, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points1); 
        
        }     
        
        translate([15, 30, 4]) rotate([90, 0, 0]) cylinder($fn=32, h=100, d=5.3);
        translate([15, 28, 4]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=8.2);
    }
}

//module lock3() {
//    
//    corn = 3;
//    height = 18;
//    
//    points1 = [[0, 0], [11-corn, 0], [11, corn], [11, height], [corn, height], [0, height-corn]];
//    points2 = [[0, 0], [0.1, 0], [corn, height], [0, height-corn]];
//    
//    difference() {
//        color("green") hull() {
//            translate([0, 14, 0]) rotate([90, 0, 0]) linear_extrude(height=0.1) polygon(points2);
//            translate([0, 9, 0]) rotate([90, 0, 0]) linear_extrude(height=9) polygon(points1); 
//        
//        }
//     
//        translate([2, 2.4, height-9-8.3/2]) cube([10, 4.2+0.3, 8.3]); // some extra clearing vertically, because nut should fit despite overhang (test...?) 
//        translate([11/2, 10, height-9]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=5.3);
//    }
//}
//
//module lock4() {
//    
//    corn = 3;
//    height = 18;
//    
//    points1 = [[0, 0], [11-corn, 0], [11, corn], [11, height], [corn, height], [0, height-corn]];
//
//    difference() {
//        translate([0, 8, 0]) rotate([90, 0, 0]) linear_extrude(height=8) polygon(points1);     
//
//        translate([11/2, 10, height-9]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=5.3);
//        translate([11/2, 6, height-9]) rotate([90, 0, 0]) cylinder($fn=32, h=20, d=9);
//    }
//}

module box(red=0, w=0, height=1) {
    corn1            = 9;
    corn2            = 3;
    corn3            = 3;
    corn4            = 9;
    
    points_int = [  [w              , corn1+w],
                    [corn1+w         , 0+w],
                    [sfront[0]-red-corn2-w, 0+w],
                    [sfront[0]-red-w    , corn2+w],
                    [sfront[0]-red-w    , sfront[1]-corn3-w],
                    [sfront[0]-red-corn3-w, sfront[1]-w],
                    [corn4+w         , sfront[1]-w],
                    [0+w            , sfront[1]-corn4-w],
    ];
    
    linear_extrude(height=height) polygon(points_int);
}

module front() {
    
    corn2   = 3;
    red     = 30; // reduction for right cavity
    
    // height of the 3 segments
    l1_height       = 45; 
    l2_height       = 78; 
    l3_height       = sfront[2]-(l2_height);
    
    frontpoints     = [ [0, 0], [0, corn2], [-corn2, 0]];
    
    difference() {
        union() {
            difference() {
                union() { 
                    // outer hull
                    box(height=l1_height, red=20);
                    hull() {
                        translate([0, 0, l1_height]) box(height=0.1, red=20);
                        translate([0, 0, l2_height]) box(height=0.1);
                    }
                    translate([0, 0, l2_height]) box(height=l3_height);
                    
                    // lock
                    translate([160, 33, sfront[2]-20]) rotate([90, 0, 90]) lock();
                    translate([0, 33, sfront[2]-20]) rotate([90, 0, 90]) mirror([0, 0, 1]) lock();
                }
                
                // inner hull
                translate([0, 0, bw]) difference() {
                    //box(height=sfront[2], w=w);
                    
                    union() {
                        box(w=w, height=l1_height, red=20);
                        hull() {
                            translate([0, 0, l1_height-0.01]) box(w=w, height=0.1, red=20);
                            translate([0, 0, l2_height+0.01]) box(w=w, height=0.1);
                        }
                        translate([0, 0, l2_height]) box(w=w, height=l3_height);
                    }
           
                    translate([-1, -0.01+w, -0.01]) rotate([0, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints); 
                    translate([sfront[0], sfront[1]-0.01-w, -0.01]) rotate([180, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
                    translate([-0.01+w, sfront[1], -0.01]) rotate([90, 90, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);
                    translate([sfront[0]-red+10-0.01-w, sfront[1], 0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);          
                }
            }
            
            // lensplate hole reinforcement
            intersection() {
                translate([0, 0, 1]) translate(lensplate_trans) {
                    distx = 43;
                    disty = 38; 
                    translate([-distx-5, -disty-10])        cube([10, 10, 5]);
                    translate([-distx, -disty])             cylinder($fn=6, h=5, d=10);
                    
                    translate([distx-5, -disty-10, 1])      cube([12.5, 10, 5]);
                    translate([distx, -disty-5.7])          cube([9, 10, 5]);
                    translate([distx, -disty])              cylinder($fn=6, h=5, d=10);
                    
                    translate([-distx-5, disty])            cube([10, 8, 5]);
                    translate([-distx, disty])              cylinder($fn=6, h=5, d=10);
                    
                    translate([distx-5, disty])             cube([12, 8, 5]);
                    translate([distx, disty-4.3])           cube([9, 10, 5]);
                    translate([distx, disty])               cylinder($fn=6, h=5, d=10);
                }
                
                box(height=l1_height, red=20);
            }
            
            translate([50, sfront[1]-0.01+0, 43]) color("orange") {
                difference() {
                    hull() {
                        cube([70+6, 0.1, 44+6]);
                        translate([1.5, 0.5, 1.5]) cube([70+3, 0.1, 44+3]);
                    }
                    translate([3-0.2, -1, 3-0.2]) cube([70+2*0.2, 6, 44+2*0.2+0.4]);
                }
            }
            
            // lid
            
            translate([0, 0, sfront[2]-3.2]) color("green") difference() {
                translate([0, 0, 0]) box(height=2+1.2);
                
                hull() {
                translate([0, 0, 0-0.01]) box(height=.01, w=w);
                translate([0, 0, 1.2+0.02]) box(height=.01, w=2.4);
                }
                
                translate([0, 0, 1.2]) box(height=2+.1, w=2.4);
            }
        }
       
        // lens hole
        translate(lensplate_trans) {
            translate() cylinder($fn=128, h=10, d=79);
            
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
        translate([sfront[0]-red+10+0.01, sfront[1], -0.01]) rotate([90, 0, 0]) linear_extrude(height=sfront[0]+2) polygon(frontpoints);

        // lock nut trap
        translate([148.2, 44-0.2, 92]) cube([20, 8.3, 4.3]);
        translate([-8.2, 44-0.2, 92]) cube([20, 8.3, 4.3]);
        
        // clamp screw holes
        translate([53, sfront[2], 46]) rotate([90, 0, 0]) color("purple") {
            dist = 7;
            translate([dist, dist]) cylinder($fn=32, h=10, d=5.3);
            translate([70-dist, dist]) cylinder($fn=32, h=10, d=5.3);
            translate([dist, 44-dist]) cylinder($fn=32, h=10, d=5.3);
            translate([70-dist, 44-dist]) cylinder($fn=32, h=10, d=5.3);
        }    
 
        // lensplate nut cavity
        translate(lensplate_trans) translate([0, 0, 3]) { // ? hight correct?
            distx = 43;
            disty = 38;
                translate([-distx, -disty])   cylinder($fn=6, h=6, d=6.6);
                translate([distx, -disty])    cylinder($fn=6, h=6, d=6.6);
                translate([-distx, disty])    cylinder($fn=6, h=6, d=6.6);
                translate([distx, disty])     cylinder($fn=6, h=6, d=6.6);
        }
    }
}

module back() {
    
    corn            = 3; 
    corn2           = 3;
    
    tol = 0.2;
    w1 = w+tol;
    w2 = w1+1.2;
    lid_height = 13;
    
    c_w = 11;
    c_h = 18;
    
//    points_int1 = [ [w1                 , corn+w1],
//                    [corn+w1            , 0+w1],
//                    [sback[0]-corn-w1   , 0+w1],
//                    [sback[0]-w1        , corn+w1],
//                    [sback[0]-w1        , sback[1]-c_h-tol],
//                    [sback[0]-c_w+corn-tol  , sback[1]-c_h-tol],
//                    [sback[0]-c_w-tol   , sback[1]-c_h+corn-tol],
//                    [sback[0]-c_w-tol   , sback[1]-w1],
//                    [corn+w1            , sback[1]-w1],
//                    [0+w1               , sback[1]-corn-w1],
//    ];


//    points_int2 = [ [w2                 , corn+w2],
//                    [corn+w2            , 0+w2],
//                    [sback[0]-corn-w2   , 0+w2],
//                    [sback[0]-w2        , corn+w2],
//                    [sback[0]-w2        , sback[1]-c_h-tol-w2+w1],
//                    [sback[0]-c_w+corn-2*tol  , sback[1]-c_h-w2+w1-tol],
//                    [sback[0]-c_w-tol-w2+w1   , sback[1]-c_h+corn-2*tol],
//                    [sback[0]-c_w-tol-w2+w1   , sback[1]-w2],
//                    [corn+w2            , sback[1]-w2],
//                    [0+w2               , sback[1]-corn-w2],
//   ];
    
    difference() {
        frontpoints = [ [0, 0], [0, corn2], [-corn2, 0]];
        
        union() { 
            // outer hull
            color("green") box(height=sback[2]);
            translate([0,0,0.1]) color("red") box(height=lid_height, w=w1);
        }
        
        // inner hull
        translate([0, 0, bw]) difference() {
            //linear_extrude(height=20) polygon(points_int2);
            box(height=20, w=w2);
        }
    }
    
    // - tolerance / 2
    //translate([0, 40-1/2, 10]) rotate([90, 0, 0]) hinge_back();
    //translate([0, 92-1/2, 10]) rotate([90, 0, 0]) hinge_back();
    
    translate([160, 61, 10]) rotate([-90, 0, -90]) lock2();
    translate([0, 61, 10]) rotate([-90, 0, -90]) mirror([0, 0, 1]) lock2();
    //translate([160-11, 94, 2]) rotate([90, 0, 0]) lock4();
    
    translate([90, 6, 5]) rotate([0, 0, 90]) pcb();
    translate([100, 80, 5]) rotate([0, 0, -90]) zero();
}

module lensplate() {
    
    difference() {
        union() {
            
            // baseplate
            hull() {
                translate([crad/2, crad/2, 0]) cylinder($fn=32, h=3, d=crad);
                translate([baseplate[0] - crad/2, crad/2, 0]) cylinder($fn=32, h=3, d=crad);
                translate([baseplate[0] - crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=3, d=crad);
                translate([crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=3, d=crad);
            }
            
            // cylinder
            translate([baseplate[0]/2, baseplate[1]/2, 3]) cylinder($fn=128, h=3, d1=85, d2=outer_diam+2);
            
            // reinforcement for screwholes
            translate([scr, scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([baseplate[0]-scr, scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=2, d=10);
            translate([baseplate[0]-scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=2, d=10);
        }
        
        // lens hole cutter
        translate([baseplate[0]/2, baseplate[1]/2, -1]) cylinder($fn=128, h=height+2, d=outer_diam);
    
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
        translate([baseplate[0]/2, baseplate[1]/2, 0]) cylinder($fn=128, h=2, d=outer_diam);    
        translate([baseplate[0]/2, baseplate[1]/2, 0-0.01]) cylinder($fn=128, h=2.2, d1=outer_diam, d2=inner_diam);    
    }
}

module lensplate2() {
    
    difference() {
        union() {
            
            // baseplate
            translate([0,0,0]) hull() {
                translate([crad/2, crad/2, 0]) cylinder($fn=32, h=6, d=crad);
                translate([baseplate[0] - crad/2, crad/2, 0]) cylinder($fn=32, h=6, d=crad);
                translate([baseplate[0] - crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=6, d=crad);
                translate([crad/2, baseplate[1] - crad/2, 0]) cylinder($fn=32, h=6, d=crad);
            }
        }
        
        // lens hole cutter
        translate([baseplate[0]/2, baseplate[1]/2, -1]) cylinder($fn=128, h=height+2, d=outer_diam);
    
        // screwholes
        translate([scr, scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([baseplate[0]-scr, scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([scr, baseplate[1]-scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        translate([baseplate[0]-scr, baseplate[1]-scr, -0.1]) cylinder($fn=32, h=10, d=3.3);
        
        // screwhole nuttraps
        translate([scr, scr, 3]) cylinder($fn=32, h=5, d=6);
        translate([baseplate[0]-scr, scr, 3]) cylinder($fn=32, h=5, d=6);
        translate([scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=5, d=6);
        translate([baseplate[0]-scr, baseplate[1]-scr, 3]) cylinder($fn=32, h=5, d=6);
    }
    
    translate([0, 0, 1]) difference() {
        translate([baseplate[0]/2, baseplate[1]/2, 0]) cylinder($fn=128, h=1, d=outer_diam);    
        translate([baseplate[0]/2, baseplate[1]/2, 0-0.01]) cylinder($fn=128, h=1.2, d2=outer_diam, d1=inner_diam);    
    }
    
    // hole print support
    translate([-3, -3, 3]) { 
    translate([scr, scr, -0.1])                           cube([5, 5, 0.2]);
    translate([baseplate[0]-scr, scr, -0.1])              cube([5, 5, 0.2]);
    translate([scr, baseplate[1]-scr, -0.1])              cube([5, 5, 0.2]);
    translate([baseplate[0]-scr, baseplate[1]-scr, -0.1]) cube([5, 5, 0.2]);
    }
}

// utilities 

module pcb() {
    translate([0, 0, 0]) color("purple") import("/Users/volzotan/GIT/timebox/eagle/controller10/controller10.dxf");
}

module zero() {
    translate([0, 0, 0]) {
        difference() {
            color("green") cube([65, 30, 2]);
            
            translate([3.5, 3.5, -1]) cylinder($fn=32, h=10, d=2.75);
            translate([65-3.5, 3.5, -1]) cylinder($fn=32, h=10, d=2.75);
            translate([3.5, 30-3.5, -1]) cylinder($fn=32, h=10, d=2.75);
            translate([65-3.5, 30-3.5, -1]) cylinder($fn=32, h=10, d=2.75);  
        }
        translate([7, 0.5, 0]) color("black") cube([51, 6, 5]);
        translate([7, 30-6-0.5, 0]) color("silver") cube([10, 6, 5]);
    }
    
}

module batteries() {
    translate([9, 9, 0]) cylinder($fn=32, h=65, d=18);
    translate([18+9+2, 9, 0]) cylinder($fn=32, h=65, d=18);
    translate([9, 18+9+2, 0]) cylinder($fn=32, h=65, d=18);
    translate([18+9+2, 18+9+2, 0]) cylinder($fn=32, h=65, d=18);
}