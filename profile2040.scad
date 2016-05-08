use <profiles.scad>;

module profile_2040() {
    difference() {
    union() {
        translate([-10,0,0])
        profile_tslot_generic (pitch = 20, slot = 6, lip = 2, web = 2.6, core = 9, hole = 5.5);
        translate([10,0,0])
        profile_tslot_generic (pitch = 20, slot = 6, lip = 2, web = 2.6, core = 9, hole = 5.5);
    }
    square([4,16], true);
    }
}
