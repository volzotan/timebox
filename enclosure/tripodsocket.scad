cube([200, 100, 10]);

translate([0, 110, 0]) difference() {
    cube([72, 25, 80]);
    translate([11+1, 11+1, 2]) cylinder($fn=32, h=100, d=22);
    translate([22+2+11, 11+1, 2]) cylinder($fn=32, h=100, d=22);
    translate([2*(22+2)+11, 11+1, 2]) cylinder($fn=32, h=100, d=22);
}