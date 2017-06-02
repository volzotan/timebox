//difference() {
//    cube([52, 40, 2]);
//
//    translate([0, 5, -1]) {
//        for (i=[0:4]) {
//            translate([5+i*10.1, -1, 0]) cylinder($fn=6, h=4, d=4+i*0.2);
//        }
//        
//        for (i=[0:4]) {
//            translate([5+i*10.1, 5, 0]) cylinder($fn=6, h=4, d=5+i*0.2);
//        }
//        
//        for (i=[0:4]) {
//            translate([5+i*10.1, 12, 0]) cylinder($fn=6, h=4, d=6+i*0.2);
//        }
//        
//        for (i=[0:4]) {
//            translate([5+i*10.1, 20, 0]) cylinder($fn=6, h=4, d=7+i*0.2);
//        }
//        
//        for (i=[0:4]) {
//            translate([5+i*10.1, 29, 0]) cylinder($fn=6, h=4, d=8+i*0.2);
//        }
//    }
//}

difference() {
    cube([80, 68, 2]);

    translate([0, 5, -1]) {
        for (i=[0:4]) {
            translate([9+i*15.2, 2, 0]) cylinder($fn=6, h=4, d=9+i*0.2);
        }
        
        for (i=[0:4]) {
            translate([9+i*15.2, 14, 0]) cylinder($fn=6, h=4, d=10+i*0.2);
        }
        
        for (i=[0:4]) {
            translate([9+i*15.2, 26.5, 0]) cylinder($fn=6, h=4, d=11+i*0.2);
        }
        
        for (i=[0:4]) {
            translate([9+i*15.2, 40, 0]) cylinder($fn=6, h=4, d=12+i*0.2);
        }
        
        for (i=[0:4]) {
            translate([9+i*15.2, 54, 0]) cylinder($fn=6, h=4, d=13+i*0.2);
        }
    }
}