use <ujoint.scad>;

module effector(rod_spacing, effector_radius) {
    for (i=[0:2]) {
        rotate([0,0,i*120])
        translate([0,effector_radius,0])
        joint_mount(rod_spacing);
    }
}


effector(100, 40);

