front = [120, 100, 10];
fdiam = 10;

lens_offset_y = 10;
lens_diameter_inner = 72;
lens_diameter_outer = [85, 80];

back = [40, 30, 5];

part1();
translate([150, 0, 0]) part2();

module part2() {
    union() {
        hull() {
            translate([fdiam/2, fdiam/2, 0]) cylinder($fn=32, h=back[2], d=fdiam);
            translate([back[0]-fdiam/2, fdiam/2, 0]) cylinder($fn=32, h=back[2], d=fdiam);
            
            translate([0, back[1], 0]) cube([back[0], 5, 5]);
        }
        
        translate([0, 35, 0]) cube([back[0], 5, 40]);
    }
}

module part1() {
    difference() {
        union() {
            hull() {
                translate([40, -15, 0]) cylinder($fn=32, h=front[2], d=fdiam);
                translate([front[0]-40, -15, 0]) cylinder($fn=32, h=front[2], d=fdiam);
                
                translate([fdiam/2, fdiam/2 + 25, 0]) cylinder($fn=32, h=front[2], d=fdiam);
                translate([front[0]-fdiam/2, fdiam/2 + 25, 0]) cylinder($fn=32, h=front[2], d=fdiam);
                translate([front[0]-fdiam/2, front[1]-fdiam/2, 0]) cylinder($fn=32, h=front[2], d=fdiam);
                translate([fdiam/2, front[1]-fdiam/2, 0]) cylinder($fn=32, h=front[2], d=fdiam);
            }
            
            translate([front[0]/2, lens_diameter_outer[0]/2 + lens_offset_y, front[2]]) cylinder($fn=256, h=10, d1=lens_diameter_outer[0], d2=lens_diameter_outer[1]);
            translate([front[0]/2, lens_diameter_outer[1]/2 + lens_offset_y + (lens_diameter_outer[0]-lens_diameter_outer[1])/2, front[2]]) cylinder($fn=256, h=50, d=lens_diameter_outer[1]);
        }

        // lens hole
        translate([front[0]/2, lens_diameter_outer[1]/2 + lens_offset_y + (lens_diameter_outer[0]-lens_diameter_outer[1])/2, -1]) cylinder($fn=256, h=62, d=lens_diameter_inner);

        // screw holes
        screw_distance = 10;
        translate([screw_distance, screw_distance+20, 5]) cylinder($fn=6, h=8, d=8.2);
        translate([front[0] - screw_distance, screw_distance+20, 5]) cylinder($fn=6, h=8, d=8.2);
        translate([front[0] - screw_distance, front[1]-screw_distance, 5]) cylinder($fn=6, h=8, d=8.2);
        translate([screw_distance, front[1]-screw_distance, 5]) cylinder($fn=6, h=8, d=8.2);

        translate([screw_distance, screw_distance+20, -1]) cylinder($fn=32, h=15, d=5.3);
        translate([front[0] - screw_distance, screw_distance+20, -1]) cylinder($fn=32, h=15, d=5.3);
        translate([front[0] - screw_distance, front[1]-screw_distance, -1]) cylinder($fn=32, h=15, d=5.3);
        translate([screw_distance, front[1]-screw_distance, -1]) cylinder($fn=32, h=15, d=5.3);

    }
}