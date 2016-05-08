use <MCAD/metric_fastners.scad>;
use <ujoint.scad>;

module gt2_clamp(width) {
    tooth_to_hold = 5;
    length = tooth_to_hold * 2 * 2 + 3;
    
    difference() {
        // main body
        cube([8, width, length], true);
        
        // belt cutout
        cube([1.4, width*2, length*2], true);
        
        // clamping bolt hole
        rotate([0,90,0])
        cylinder(d=3.8, h=100, center=true);
        
        translate([-2.5,0,0])
        rotate([0,-90,0])
        flat_nut(3.2);
    }
    
    // teeth
    for (i=[0:tooth_to_hold-1]) {
        for (side=[0, 1]) {
                mirror([0,0,side])

                translate([-0.55,0,length/2-2*i-0.55])
                rotate([90,0,0])
                cylinder(r=0.55, h=width, center=true, $fn=10);
        }
    }
    
}


module rope_clamp(dia=3, length=15, bolt_dia=3.1) {
    $fn=40;
    width = dia + 5 + bolt_dia;
    thickness = dia + 3;
    cutout_thickness = 1;
    
    difference() {
        translate([0,-bolt_dia/2,0])
        cube([length, width, thickness], true); 
        
        // rope channel
        rotate([0,90,0])
        cylinder(d=dia, h=length*2, center=true);
        
        // cutcout
        translate([0,-width/2,0])
        cube([length*2, width, cutout_thickness], true);
        
        for (x=[-1,1]) {
            translate([x*(length/2-bolt_dia),-dia/2-bolt_dia/2-3/4,0])
            cylinder(d=bolt_dia, h=thickness*2, center=true);
        }
    }
}



module carriage(hspacing=32.1, vspacing=20, thickness=5, gt2_width=9) {
    y_spacing = 8;
    for (i=[-1,1]) {
        for (j=[-1,1]) {
            translate([hspacing*j,0,vspacing*i]) {
                
                // wheel
                rotate([90,0,0])
                v_wheel();                
            
                // shaft
                translate([-0,-y_spacing-7.5,0])
                rotate([-90,0,0])
                cap_bolt(5, 25);
                
                // spacer
                translate([0,-y_spacing+thickness-1,0])
                rotate([90,0,0])
                cylinder(d=10, h=6.35);
                
                // nut
                translate([0,8,0])
                rotate([90,0,0])
                flat_nut(5);
                
            }
        }
    }
    
    // body
    hoffset = 10;
    voffset = 10;
    
    carriage_width = (hspacing+hoffset)*2;
    carriage_height = (vspacing+voffset)*2;
    
    //echo("carriage size", carriage_width, carriage_height);

    difference() {
        // main body
        color([0.5,0.5,0.5])
        translate([0, -y_spacing-thickness-2.5, 0])
        hull() {
            for (i=[-1,1]) {
                for (j=[-1,1]) {
                    translate([hspacing*j,0,vspacing*i]) {
                        rotate([-90,0,0])
                        cylinder(r=10, h=thickness, center=false);
                    }
                }
            }        
        }

        // wheel holes
        for (i=[-1,1]) {
            for (j=[-1,1]) {
                translate([hspacing*j,0,vspacing*i]) {
                    rotate([90,0,0])
                    cylinder(d=(j==-1 ? 7.12 : 5)+0.4, h=1000, center=true);
                }
            }
        }        
    }

    // gt2 belt clamp    
    translate([5,-10.5-thickness-gt2_width/2-0.1,18])
    gt2_clamp(gt2_width);    
    
    // rope clamp
    translate([0,-10.5-12,-5])
    rotate([-90,0,90])
    rope_clamp();
    
    translate([0,-10.5-thickness-6-2.9+2.8,0])
    mirror([0,1,0])
    difference() {
    //joint_mount(80);
    joint_assembly2(rod_spacing=80+20, xangle=-90+75, zangle=0);
        
        // cut in center
        cube([70, 100, 100], true);
        
    }
}


use <openrail.scad>

carriage(32.1, gt2_width=9);
