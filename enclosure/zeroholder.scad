include </Users/volzotan/GIT/timebox/eagle/controller10/controller10.scad>

crad = 5;
height = 4;

//% translate([2, 32, -20+2+.7+10]) pizero();
//% translate([170-2.5-20, 2.5, 5]) controller();

bottom();
translate([0, -2, 7]) rotate([180, 0, 0]) top();
translate([72, 0, 0]) controller_bottom();
translate([72, -2, 0]) rotate([0, 0, 0]) mirror([0, 1]) controller_top();

//%  translate([80, 0, 14]) rotate([180, 0, 0]) mirror([0, 1]) controller_top();
//%translate([0, 0, 24]) top();

% difference() {
translate([0, 0, 0]) {
    translate([65+5,    8,      22+2.5]) rotate([180, 0, 180]) top();
    translate([65+3-.5, 32+8,   45]) rotate([0, 180, 0]) pizero();
    translate([65+5,    8,      30-1]) rotate([180, 0, 180]) bottom();
    
    translate([0, 0, 30-1]) rotate([]) controller_bottom();
    translate([68-.5, 2.6, 33]) rotate([]) controller();
    translate([0, 0, 42.5]) rotate([180, 0, 0]) mirror([0, 1]) controller_top();
}
translate([-1, -100+0, 0]) cube([100, 100, 100]);
}

% translate([6, 6, 41.2]) rotate([180, 0, 0]) screw();
% translate([64, 6, 41.2]) rotate([180, 0, 0]) screw();

% translate([6, 14, 29.9]) rotate([180, 0, 0]) screw();
% translate([64, 14, 29.9]) rotate([180, 0, 0]) screw();

% translate([34, 45, 38]) rotate([180, 0, 0]) screw();

module controller_top() {
    height = 7.5+1.2;
    height_holder = height-0.75;
    
    //translate([0, 42, 0]) cube([1.7, 1, 3]);
    
    difference() {
        union() {
            difference() {
                block(70, 42, height, crad=1);
                translate([0, 0, 2]) block(70, 42, height, crad=0.3, red=1.2);
            }
            
            // 3rd screw helper
            difference() {
                    translate([27, 42, 0]) {
                        points = [[0, 0], [14, 0], [14-3, 5], [3, 5]];
                        translate([]) linear_extrude(height=height) polygon(points);
                        translate([14/2, 3]) cylinder($fn=32, h=height, r=4.5);
                    }
                
                translate([0, 0, 1]) block(70, 42, height, crad=2, red=1);
            }
            
            intersection() {
                union() {
                    translate([6, 6]) cylinder($fn=32, h=height_holder, d=7);
                    translate([]) cube([9.5, 6.5, height_holder]);
                    translate([]) cube([5.5, 9.5, height_holder]);
                    
                    translate([6+58, 6]) cylinder($fn=32, h=height_holder, d=7);
                    translate([2.5+58, 0]) cube([9.5, 6.5, height_holder]);
                    translate([4.5+1.5+58, 0]) cube([6.5, 9.5, height_holder]);
                    
                    translate([1.2, 40]) cylinder($fn=32, h=height_holder, d=9);
                    translate([70-1.2, 40]) cylinder($fn=32, h=height_holder, d=9);
                }
                block(70, 42, height, crad=2);
            }
            
            // LED light tunnel
            translate([52+2.5, 7, 1]) cylinder($fn=32, h=3.5, d=5+1.2*2);
        }
        
        // battery polarity hints
        translate([15, 14.2, -1]) linear_extrude(height=1.3) scale([1.5, 1.5]) rotate([0, 0, 90]) text("+");
        translate([13.6, 30, -1]) linear_extrude(height=1.3) scale([1.5, 1.5]) rotate([0, 0, 90]) text("-");
        
        // shutter cutout
        translate([1.7+6.3, 35, 2]) cube([19, 10, 10]);
        
        // connector cutout
        translate([68-18-5, 35, 2]) cube([18, 10, 10]);
        translate([45+18/2-4.5/2, 37, 1]) cube([4.5, 7, 10])
        
        // usb cutout
        translate([65, 1.7+8.75, 6]) rotate([0, 90, 0]) hull() {
            translate([+1, +1, -1]) cylinder($fn=32, h=10, r=1);
            translate([+1, 12-1, -1]) cylinder($fn=32, h=10, r=1);
            translate([-10, 0, 0]) cube([10, 12, 10]);
        }
        
        // power cutout
        translate([-1, 14.75, 1.2]) cube([7, 6, 10]);
        translate([-1, 28.75, 1.2]) cube([7, 6, 10]);
        
        // screws
        translate([0, -.5, -1]) {
            translate([6, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([34, 45.5]) cylinder($fn=32, h=10, d=2.5+.3);
     
            translate([6, 6.5]) cylinder($fn=32, h=5, d=5.1);
            translate([6+58, 6.5]) cylinder($fn=32, h=5, d=5.1);
            translate([34, 45.5]) cylinder($fn=32, h=height-0.5, d=5.1);
        }
        
        // button cutout
        translate([52+2.5, 7, -1]) cylinder($fn=32, h=10, d=5); 
        translate([43.5, 7, -1]) cylinder($fn=32, h=10, d=5);
        
        // SPI cutout
        translate([50, 23.25, -1]) cube([12, 7, 7]);
        
        // force printer to do holes at once
        translate([0, 0, -0]) {
            translate([0, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([70-6, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([70-10, 30-3.25, -1]) cube([10, 0.1, 1.2]);
            translate([70-28, 6.7, -1]) cube([10, 0.1, 1.2]);
        }
    }
    
    // hole reinforcement
    translate([6-5/2, 6-5/2, 4])                cube([5, 5, .2]);
    translate([6+58-5/2, 6-5/2, 4])             cube([5, 5, .2]);
    translate([34-5/2, 45.5-5/2, height-1.5])   cube([5, 5, .2]);
    
}

module controller_bottom() {
    height = 4.5;
    height_holder = 3.5;
    
    difference() {
        union() {
            difference() {
                block(70, 42, height, crad=1);
                translate([0, 0, 1.2]) block(70, 42, height, crad=0.3, red=1.2);
            }
            
            // 3rd screw helper
            difference() {
                translate([27, 42, 0]) {
                    points = [[0, 0], [14, 0], [14-3, 5], [3, 5]];
                    translate([]) linear_extrude(height=height) polygon(points);
                    translate([14/2, 3]) cylinder($fn=32, h=height, r=4.5);
                }
                translate([0, 0, 1]) block(70, 42, height, crad=2, red=1);
            }
            
            intersection() {
                union() {
                    translate([6+0.5, 6]) cylinder($fn=32, h=height_holder, d=7);
                    translate([]) cube([10, 6.5, height_holder]);
                    translate([]) cube([6, 9.5, height_holder]);
                    
                    translate([6-0.5+58, 6]) cylinder($fn=32, h=height_holder, d=7);
                    translate([2+58, 0]) cube([10, 6.5, height_holder]);
                    translate([4+1.5+58, 0]) cube([7, 9.5, height_holder]);
                    
                    translate([1.2, 40]) cylinder($fn=32, h=height_holder, d=9);
                    translate([70-1.2, 40]) cylinder($fn=32, h=height_holder, d=9);
                    
                }
                block(70, 42, height, crad=2);
            }
        }
        
        // shutter cutout
        translate([10, 35, height_holder+1]) cube([15, 10, 10]);
        
        // connector cutout
        translate([45, 35, height_holder+1]) cube([18, 10, 10]);
        translate([45+18/2-4.5/2, 35, height_holder-0.5]) cube([4.5, 10, 10])
     
        // usb cutout
        translate([65, 1.7+8.75, 5]) rotate([0, 90, 0]) hull() {
            translate([+1, +1, -1]) cylinder($fn=32, h=10, r=1);
            translate([+1, 12-1, -1]) cylinder($fn=32, h=10, r=1);
            translate([-10, 0, 0]) cube([10, 12, 10]);
        }
        
        // power cutout
        translate([-1, 10, height_holder+1]) cube([10, 25, 10]);
        
        // screws
        translate([0, -.5, -1]) {
            translate([6, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([34, 45.5]) cylinder($fn=32, h=10, d=2.5+.3);
     
            translate([6, 6.5]) cylinder($fn=6, h=3, d=6.1);
            translate([6+58, 6.5]) cylinder($fn=6, h=3, d=6.1); 
  
            // zero screw holes
            translate([6, 6.5+30.5]) cylinder($fn=32, h=3, d=5.1);
            translate([6+58, 6.5+30.5]) cylinder($fn=32, h=3, d=5.1);  
            translate([6, 14]) cylinder($fn=32, h=3, d=5.1);
            translate([6+58, 14]) cylinder($fn=32, h=3, d=5.1);           
        }
        
        // force printer to do holes at once
        translate([0, 0, -0]) {
            translate([0, 6-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([0, 19-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([0, 42-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-7, 6-.1/2, -1]) cube([10, 0.1, 1.2]);
            translate([69-7, 19-5.5-.1/2, -1]) cube([10, 0.1, 1.2]);
            translate([69-7, 42-5.5-.1/2, -1]) cube([10, 0.1, 1.2]);
            translate([28, 45, -1]) cube([5, 0.1, 1.2]);
        }
    }
    
    // hole reinforcement
    translate([6-5/2, 6-5/2, 2])         cube([5, 5, .2]);
    translate([6+58-5/2, 6-5/2, 2])      cube([5, 5, .2]);
}

module top() {
    height = 7;
    
    difference() {
        intersection() {
            union() {
                difference() {               
                    block(70, 34, height, crad=3);
                    
                    // pi cutout
                    translate([0, 0, -3.2]) {
                        block(70, 34, height, crad=3, red=1.2);
                    } 
                }
                translate([]) cube([5.7, 7.5, 10]);
                translate([]) cube([8, 5.7, 10]);
                translate([6, 5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([70-5.7, 0]) cube([5.7, 7.5, 10]);
                translate([70-8, 0]) cube([7.5, 5.7, 10]);
                translate([70-6, 5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([70-5.7, 34-7.5]) cube([5.7, 7.5, 10]);
                translate([70-8, 34-5.7]) cube([7.5, 5.7, 10]);
                translate([70-6, 34-5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([0, 34-7.5]) cube([5.7, 7.5, 10]);
                translate([0, 34-5.7]) cube([8, 5.7, 10]);
                translate([6, 34-5.5]) cylinder($fn=32, h=10, d=4);
            }
            
            block(70, 34, height, crad=3);
        }
        
        // pi cutout
        translate([0, 0, -6.5]) {
            color("red")  block(70, 34, height, crad=3, red=1.2);
        } 
        
        // sd card connector cutout
        translate([-0.1, (34-18)/2, -0.1]) {
            //translate([0, 0, 3+3.0-0.3]) cube([0.1, 18, 0.1]);
            cube([3.1, 18, 3.5]);
            
            points = [[0, 0], [18.2, 0], [18.2-2, 3], [2, 3]];
            translate([-0.1, 18.1, 0]) rotate([0, 0, -90]) linear_extrude([]) polygon(points);
        }
       
        // connector cutout
        translate([9, 33-7, -.1]) cube([14, 12, height-1]);                   // pin
        translate([8+.5, -1, -.1]) cube([13, 10, height-2.2]);          // HDMI
        translate([38+.5, -1, -.1]) cube([23, 10, height-3.1]);         // USB
        translate([60, 8-.5, -.1]) cube([23, 19, 3.5]);                 // camera
        
        // screws
        translate([0, -.5, -1]) {
            translate([6, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6+58, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6+58, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            
    //        translate([6-.5, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5, 6+23]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6+23]) cylinder($fn=6, h=3-.5, d=6);
            
            translate([6, 6, height-1]) cylinder($fn=6, h=5, d=6.1);
            translate([6+58, 6, height-1]) cylinder($fn=6, h=5, d=6.1);
            translate([6, 6+23, height-1]) cylinder($fn=6, h=5, d=6.1);
            translate([6+58, 6+23, height-1]) cylinder($fn=6, h=5, d=6.1);
        }
        
        // LED hole
        translate([60, 9]) cylinder($fn=32, h=10, d=3);
    
        // force printer to do holes at once
        translate([0, 0, height]) {
            translate([0, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([0, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-7, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-7, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        }
    } 
    
    // hole reinforcements
    translate([6-5/2, 6-3, 4.8])         cube([5, 5, .2]);
    translate([6+58-5/2, 6-3, 4.8])      cube([5, 5, .2]);
    translate([6-5/2, 6+23-3, 4.8])      cube([5, 5, .2]);
    translate([6+58-5/2, 6+23-3, 4.8])   cube([5, 5, .2]);
}

module bottom() {
        
    difference() {
        union() {
            hull() {
                block(70, 34, height, crad=3);
            }
            
            // 3rd screw helper
            difference() {
                translate([29, 34, 0]) {
                    points = [[0, 0], [14, 0], [14-3, 5], [3, 5]];
                    translate([]) linear_extrude(height=height) polygon(points);
                    translate([14/2, 3]) cylinder($fn=32, h=height, r=4.5);
                }
                //translate([0, 0, 1]) block(70, 42, height, crad=2, red=1);
            }
        }
        
        // through hole pin cutout
        translate([(70-51)/2, 26-.25, 0.8]) color("yellow") cube([51, 5.5, 2]);
        
        // screws
        translate([0.5, -.5, -1]) {
            translate([6-.5, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            
            translate([6-.5, 6]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-.5+58, 6]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-.5, 6+23]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-.5+58, 6+23]) cylinder($fn=32, h=3-.2, d=4.9);
            
            // controller bottom screw top 
            translate([6-.5, -1.5]) cylinder($fn=6, h=3-.2, d=6.1);
            translate([6-.5+58, -1.5]) cylinder($fn=6, h=3-.2, d=6.1);
        }
        
        translate([36, 45.5-8.5, -1]) cylinder($fn=32, h=10, d=2.5+.3);
        translate([36, 45.5-8.5, 1.2]) cylinder($fn=6, h=10, d=6.1);
        
        // camera connector cutout
        translate([65, (34-19)/2, height-1]) cube([10, 19, 3]);
        
        // sd card connector cutout
        translate([-0.1, (34-18)/2, 0.5]) hull() {
            translate([0, 0, 2.2]) cube([2.61, 18, 3]);
            cube([0.1, 18, 0.1]);
        }

        // pi cutout
        translate([0, 0, height-1.3]) hull() {
            block(70, 34, height, crad=3.5, red=1.2);
        }    

        // force printer to do holes at once
        translate([0, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([0, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        
        translate([30, 37, -1]) cube([5, 0.1, 1.2]);
    }

    // hole reinforcements
    translate([6-.5-5/2, 6-3, 1.8])         cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6-3, 1.8])      cube([5, 5, .2]);
    translate([6-.5-5/2, 6+23-3, 1.8])      cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6+23-3, 1.8])   cube([5, 5, .2]);
}

module controller() {
    //rotate([0, 0, 90]) color("purple") import(file = "controller10.dxf");
    rotate([0, 0, 90]) controller10();
    
    translate([-75+0.2, 12.75, 0]) color("yellow") cube([10, 5, 6]);
    translate([-75+0.2, 12.75+14, 0]) color("yellow") cube([10, 5, 6]);
    
    translate([-5, 10, 0]) color("grey") cube([5, 8, 3]);
    //translate([0-22-8, 0, 0]) color("white") cube([22, 7.5, 3]);
   
    translate([0-14-6.5, 40-3, 1]) color("black") cube([14, 6, 5]);
    //translate([0-10-6.5, 22, 1]) color("black") cube([10, 5, 9+1]);
    translate([-65+6.5, 40-3, 1]) color("black") cube([16, 5, 5]);
}

module pizero() {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
    translate([7, 0, 21.1]) color("black") cube([13, 8, 5]);
}

module screw() { // M2.5 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2.5, d=4.5);
        translate([0, 0, 2.5]) cylinder($fn=32, h=10, d=2.5);
    }
}

module block(width, depth, height, crad=3, red=0) {
    hull() {    
        translate([crad+red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([width-crad-red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([crad+red, depth-crad-red]) cylinder($fn=32, h=height, r=crad);
        translate([width-crad-red, depth-crad-red]) cylinder($fn=32, h=height, r=crad);
    }
}
