module threadhole(  screw_hole_diameter = 6.5, 
                    socket_diameter     = 24,
                    socket_height       = 8,
                    length              = 22,
                    height              = 18) {
                        
    // 1/4 inch = 0,635cm

    cube([screw_hole_diameter, length, height]);
    
    translate([screw_hole_diameter/2, 0, 0]) cylinder(h=height, d=screw_hole_diameter, $fn=64);
    translate([screw_hole_diameter/2, length, 0]) cylinder(h=height, d=screw_hole_diameter, $fn=64);
    translate([-(socket_diameter/2 - screw_hole_diameter/2), 0, 0]) cube([socket_diameter, length, socket_height]);
    translate([screw_hole_diameter/2, 0, 0]) cylinder(h=socket_height, d=socket_diameter, $fn=128);
    translate([screw_hole_diameter/2, length, 0]) cylinder(h=socket_height, d=socket_diameter, $fn=128);
}

module triangle(width, height) {
   
    // a^2 = c^2
    // a = sqrt ( c^2 / 2 )
                
    a = sqrt(pow(height, 2) / 2);
                
    translate([0, 0, -a]) {
        intersection() {
            rotate([45, 0, 0]) cube([width, height, height]);
            translate([0, -a, a]) cube([width, a, a]);
        }
    } 
}   