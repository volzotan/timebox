crad = 5;
height = 4;

% translate([2, 32, -20+2+.7+10]) {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
    translate([7, 0, 21.1]) color("black") cube([13, 8, 5]);
}

% translate([170-2.5-20, 2.5, 10+5]) {
    rotate([0, 0, 90]) color("purple") import(file = "controller10.dxf");
    
    translate([-75+0.2, 13, 0]) color("yellow") cube([10, 5, 6]);
    translate([-75+0.2, 13+5+9, 0]) color("yellow") cube([10, 5, 6]);
    
    translate([-5, 9.5, 0]) color("grey") cube([5, 8, 3]);
    translate([0-22-8, 0, 0]) color("white") cube([22, 7.5, 3]);
   
    translate([0-14-7, 40-3, 1]) color("black") cube([14, 6, 5]);
    translate([0-10-6.5, 22, 1]) color("black") cube([10, 5, 9+1]);
    translate([-65+6.5, 40-3, 1]) color("black") cube([16, 5, 5]);
}

bottom();
%translate([0, 0, 24]) top();

translate([0, -10, 6]) rotate([180, 0, 0]) top();

translate([80, 0, 0]) controller_bottom();
translate([80, -5, 0]) rotate([0, 0, 0]) mirror([0, 1]) controller_top();
%  translate([80, 0, 24]) rotate([180, 0, 0]) mirror([0, 1]) controller_top();

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
        }
        
        // battery polarity hints
        translate([15, 14.2, -1]) linear_extrude(height=1.3) scale([1.5, 1.5]) rotate([0, 0, 90]) text("+");
        translate([13.6, 30, -1]) linear_extrude(height=1.3) scale([1.5, 1.5]) rotate([0, 0, 90]) text("-");
        
        // shutter cutout
        translate([1.7+6.8, 35, 2]) cube([17, 10, 10]);
        
        // connector cutout
        translate([68-17-6, 35, 2]) cube([17, 10, 10]);
        
        // usb cutout
        translate([65, 1.7+8.3, 6]) rotate([0, 90, 0]) hull() {
            translate([+1, +1, -1]) cylinder($fn=32, h=10, r=1);
            translate([+1, 12-1, -1]) cylinder($fn=32, h=10, r=1);
            translate([-10, 0, 0]) cube([10, 12, 10]);
        }
        
        // power cutout
        translate([-1, 15, 1.2]) cube([7, 6, 10]);
        translate([-1, 29, 1.2]) cube([7, 6, 10]);
        
        // screws
        translate([0, -.5, -1]) {
            translate([6, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([34, 45.5]) cylinder($fn=32, h=10, d=2.5+.3);
     
            translate([6, 6.5]) cylinder($fn=6, h=4, d=6.05);
            translate([6+58, 6.5]) cylinder($fn=6, h=4, d=6.05);
            translate([34, 45.5]) cylinder($fn=6, h=4, d=6.05);
        }
        
        // button cutout
        //translate([37.5, -1, -1]) cube([22, 12, 7]);
        translate([52, 5, -1]) cylinder($fn=32, h=10, d=5); // ? pos
        translate([45, 5, -1]) cylinder($fn=32, h=10, d=3.5); // ? pos
        
        // SPI cutout
        translate([50, 23.5, -1]) cube([12, 7, 7]);
    }
    
    // hole reinforcement
    translate([6-5/2, 6-5/2, 3])         cube([5, 5, .2]);
    translate([6+58-5/2, 6-5/2, 3])      cube([5, 5, .2]);
    
    // button walls
//    translate([36.25, 10, 0]) cube([24.45, 1.2, 5]);
//    translate([36.25, 0, 0]) cube([1.2, 10, 5]);
//    translate([60-.5, 0, 0]) cube([1.2, 10, 5]);
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
        }
        
        // shutter cutout
        translate([10, 35, height_holder+1]) cube([15, 10, 10]);
        
        // connector cutout
        translate([50, 35, height_holder+1]) cube([15, 10, 10]);
     
        // usb cutout
        translate([65, 1.7+8.3, 5]) rotate([0, 90, 0]) hull() {
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
     
            translate([6, 6.5]) cylinder($fn=32, h=3-.5, d=4.9);
            translate([6+58, 6.5]) cylinder($fn=32, h=3-.5, d=4.9);
            translate([34, 45.5]) cylinder($fn=32, h=3-.5, d=4.9);
           
        }
        
    }
    
    // hole reinforcementt
    translate([6-5/2, 6-5/2, 1.5])         cube([5, 5, .2]);
    translate([6+58-5/2, 6-5/2, 1.5])      cube([5, 5, .2]);
    translate([34-5/2, 45.5-5/2, 1.5])      cube([5, 5, .2]);
}

module top() {
    height = 6;
    
    difference() {
        intersection() {
            union() {
                difference() {               
                    block(69, 34, height, crad=crad);
                    
                    // pi cutout
                    translate([2, 2, -2.2]) {
                        block(65, 30, height, crad=3, red=0.5);
                    } 
                }
                translate([]) cube([5.7, 7.5, 10]);
                translate([]) cube([7.5, 5.7, 10]);
                translate([5.5, 5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([69-5.7, 0]) cube([5.7, 7.5, 10]);
                translate([69-7.5, 0]) cube([7.5, 5.7, 10]);
                translate([69-5.5, 5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([69-5.7, 34-7.5]) cube([5.7, 7.5, 10]);
                translate([69-7.5, 34-5.7]) cube([7.5, 5.7, 10]);
                translate([69-5.5, 34-5.5]) cylinder($fn=32, h=10, d=4);
                
                translate([0, 34-7.5]) cube([5.7, 7.5, 10]);
                translate([0, 34-5.7]) cube([7.5, 5.7, 10]);
                translate([5.5, 34-5.5]) cylinder($fn=32, h=10, d=4);
            }
            
            block(69, 34, height, crad=crad);
        }
        
        // pi cutout
        translate([2, 2, -5.5]) {
            block(65, 30, height, crad=3, red=0.5);
        } 
        
        // sd card connector cutout
        translate([-0.1, (34-18)/2, -0.1]) hull() {
            translate([0, 0, 3+3.0-0.3]) cube([0.1, 18, 0.1]);
            cube([3.1, 18, 3.5]);
        }
        
        
        // connector cutout
        translate([9-.5, 33-7, -.1]) cube([14, 12, 10]);                // pin
        translate([8-.5, -1, -.1]) cube([14, 10, height-1.2]);          // HDMI
        translate([38-.5, -1, -.1]) cube([24, 10, height-2.1]);         // USB
        translate([60, 8-.5, -.1]) cube([23, 19, 3.5]);                 // camera
        
        
        // screws
        translate([0, -.5, -1]) {
            translate([6-.5, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            
    //        translate([6-.5, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5, 6+23]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6+23]) cylinder($fn=6, h=3-.5, d=6);
            
            translate([6-.5, 6, height]) cylinder($fn=6, h=5, d=6);
            translate([6-.5+58, 6, height]) cylinder($fn=6, h=5, d=6);
            translate([6-.5, 6+23, height]) cylinder($fn=6, h=5, d=6);
            translate([6-.5+58, 6+23, height]) cylinder($fn=6, h=5, d=6);
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
    translate([6-.5-5/2, 6-3, 4.8])         cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6-3, 4.8])      cube([5, 5, .2]);
    translate([6-.5-5/2, 6+23-3, 4.8])      cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6+23-3, 4.8])   cube([5, 5, .2]);
}

module bottom() {
        
    difference() {
        hull() {
            block(69, 34, height, crad=crad);
        }
        
        // through hole pin cutout
        translate([(69-51)/2, 26-.25, 0.8]) color("yellow") cube([51, 5.5, 2]);
        
        translate([0, -.5, -1]) {
            translate([6-.5, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-.5+58, 6+23]) cylinder($fn=32, h=10, d=2.5+.3);
            
            translate([6-.5, 6]) cylinder($fn=32, h=3-.5, d=4.9);
            translate([6-.5+58, 6]) cylinder($fn=32, h=3-.5, d=4.9);
            translate([6-.5, 6+23]) cylinder($fn=32, h=3-.5, d=4.9);
            translate([6-.5+58, 6+23]) cylinder($fn=32, h=3-.5, d=4.9);
        }
        
        // camera connector cutout
        translate([65, (34-18)/2, height-1]) cube([10, 18, 3]);
        
        // sd card connector cutout
        translate([-0.1, (34-18)/2, 0.5]) hull() {
            translate([0, 0, 2.2]) cube([2.61, 18, 3]);
            cube([0.1, 18, 0.1]);
        }

        // pi cutout
        translate([2, 2, height-1.3]) hull() {
            block(65, 30, height, crad=3, red=0.5);
        }    

        // force printer to do holes at once
        translate([0, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([0, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
    }

    // hole reinforcements
    translate([6-.5-5/2, 6-3, 1.5])         cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6-3, 1.5])      cube([5, 5, .2]);
    translate([6-.5-5/2, 6+23-3, 1.5])      cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6+23-3, 1.5])   cube([5, 5, .2]);
}

module block(width, depth, height, crad=3, red=0) {
    hull() {    
        translate([crad+red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([width-crad-red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([crad+red, depth-crad-red]) cylinder($fn=32, h=height, r=crad);
        translate([width-crad-red, depth-crad-red]) cylinder($fn=32, h=height, r=crad);
    }
}
