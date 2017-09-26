module controller11(){
	board_thickness = 1.600000;
	eta = 0.1;
	board_size = [29.972000,65.024000,board_thickness];
	fn = 18;
	board_origin = [0.000000,0.000000];
	union(){
		color("red")difference(){
			translate(board_origin)cube(board_size); //Board
			translate([26.467,3.505,-eta])cylinder(r=1.400000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([26.480,61.506,-eta])cylinder(r=1.400000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([14.611,1.905,-eta])cylinder(r=0.450000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([21.711,1.905,-eta])cylinder(r=0.450000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([26.772,53.106,-eta])cylinder(r=0.850000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([26.772,55.606,-eta])cylinder(r=0.850000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([26.772,43.962,-eta])cylinder(r=0.850000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([26.772,46.462,-eta])cylinder(r=0.850000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([27.746,34.004,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([27.746,30.004,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([2.261,18.491,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 1
			translate([4.801,18.491,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 2
			translate([2.261,15.951,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 3
			translate([4.801,15.951,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 4
			translate([2.261,13.411,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 5
			translate([4.801,13.411,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 6
			translate([2.261,10.871,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 7
			translate([4.801,10.871,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 8
			translate([2.261,8.331,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 9
			translate([4.801,8.331,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 10
			translate([26.924,20.320,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 1
			translate([24.384,20.320,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 2
			translate([27.178,22.860,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 3
			translate([24.638,22.860,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 4
			translate([26.924,25.400,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 5
			translate([24.384,25.400,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3_LOCK 6
			translate([17.094,61.468,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 1
			translate([19.990,61.468,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 2
			translate([19.592,53.056,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //NANOFIT2 P$1
			translate([19.592,55.656,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //NANOFIT2 P$2
			translate([19.592,43.912,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //NANOFIT2 P$1
			translate([19.592,46.512,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //NANOFIT2 P$2
			translate([7.620,52.832,-eta])cylinder(r=0.400000, h=board_thickness+eta*2,$fn=fn); //SO08 P$1
			translate([22.996,33.904,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 1
			translate([19.996,32.004,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 2
			translate([22.996,30.104,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 3
			translate([27.822,16.427,-eta])cylinder(r=0.750000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S1
			translate([27.822,9.227,-eta])cylinder(r=0.750000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S2
			translate([24.922,10.402,-eta])cylinder(r=0.350000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S3
			translate([24.922,15.252,-eta])cylinder(r=0.350000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S4
		}
	}
}

//controller11(); //Show module
//Created by generate-scad.ulp version 0.1
