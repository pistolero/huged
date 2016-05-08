use <MCAD/metric_fastners.scad>;

bearing_height=2.5;
bearing_od=6;
bearing_id=3;

//bearing_height=4;
//bearing_od=10;
bearing_id=3;


module mr63zz() {
    $fs=0.1;
    
    difference() {
        cylinder(d=6, h=2.5, center=true);
        cylinder(d=3, h=5, center=true);
        
        
        for (side=[-1,1]) {
            translate([0,0,side * (2.5-0.2)])
            difference() {
                cylinder(d=6-0.5, h=2.5, center=true);
                cylinder(d=3+0.5, h=5, center=true);
            }
        }
    }
}


$fs=0.1;

module joint_assembly(zangle=0, xangle=0, rod_spacing = 60) {
    xoffset = 8;
    for (side=[-1,1]) {
        translate([side*rod_spacing/2,0,0]) {
            
            // x bearing
            translate([side*xoffset,0,0])
            rotate([0,90,0])
            mr63zz();

            rotate([xangle, 0, 0]) {
                // z bearing
                mr63zz();   

                // rod_holder
                holder_cut_length = 12;
                holder_width = 10;
                holder_rod_clamp_length=20;
                
                rotate([0,0,zangle]) {
                    for (rod_holder_side=[0,1]) {
                        mirror([0,0,rod_holder_side])
                        difference() {
                            translate([0,0,7]) {
                                hull() {
                                    translate([0,-holder_cut_length/2,0])
                                    cube([holder_width, holder_cut_length, 2], true);
                                    
                                    cylinder(d=holder_width, h=2, center=true);
                                }
                                mirror([0,0,1])
                                cylinder(d=4.5, h=8-2);
                            }
                            
                            // shaft hole
                            cylinder(d=3, h=1000, center=true);                
                        }
                    }
                
                    difference() {
                        translate([0,-holder_cut_length-holder_rod_clamp_length/2,0])
                        cube([holder_width, holder_rod_clamp_length, 16], true);
                        
                        // rod hole
                        rotate([90,0,0])
                        cylinder(d=8, h=1000);
                        
                    }
                    // bolt
                    translate([0,0,6.2])
                    rotate([180,0,0])
                    cap_bolt(3, 15);
                }
                
            }
        }
    }


    // center bar
    rotate([xangle, 0, 0])
    difference() {
        cube([rod_spacing+xoffset*2-bearing_height, 10, 5], true);
        
        for (side=[-1,1]) {
            translate([side*rod_spacing/2,0,0]) {
                cylinder(d=6, h=100, center=true);
            }    
        }
    }

    // fixing
    for (side=[-1,1]) {
        translate([side*(rod_spacing/2+xoffset),0,0]) {
            rotate([0,90,0])
            difference() {
                hull() {
                    cylinder(d=bearing_od+2, h=bearing_height, center=true);
                    translate([0,5,0])
                    cube([bearing_od+2, 12, bearing_height], true);
                }
                cylinder(d=bearing_od, h=1000, center=true);
            }
            
        }
    }
    
    translate([0,12,0])
    cube([rod_spacing+xoffset*2+bearing_height, 2, bearing_od+2], true);
}


module joint_corss_shaft(holder_width) {
    difference() {
        union() {
            rotate([0,90,0])
            cylinder(d=bearing_od+2, h=holder_width, center=true);    

            cylinder(d=bearing_id+1, h=bearing_od+2+0.5, center=true);            
            
            cylinder(d=bearing_id, h=bearing_od+2+bearing_height*2+2, center=true);
        }
        
        translate([holder_width/2-bearing_height/2,0,0])
        rotate([0,90,0])
        cylinder(d=bearing_od, h=bearing_height+1, center=true);    

        translate([-holder_width/2+bearing_height/2,0,0])
        rotate([0,-90,0])
        cylinder(d=bearing_od, h=bearing_height+1, center=true);    
        
        rotate([0,90,0])
        cylinder(d=bearing_id+1, h=1000, center=true);
    }    
}


module joint_rod_coupler() {
    cutout_length=6+bearing_od;
    for (i=[0,1]) 
        mirror([0,0,i]) {
            translate([0,0,bearing_od/2+1+0.5+bearing_height/2]) {
                difference() {
                    union() {
                        cylinder(d=bearing_od+2, h=bearing_height, center=true);
                        
                        translate([0,cutout_length/2,0])
                        cube([bearing_od+2, cutout_length, bearing_height], center=true);
                        
                    }
                    cylinder(d=bearing_od, h=bearing_height*2, center=true);
                }
            }
        }
            
    // rod clamp
    rod_clamp_length=5+10;
    difference() {
        translate([0,cutout_length+rod_clamp_length/2,0])
        cube([bearing_od+2, rod_clamp_length, bearing_od+2+1+bearing_height*2], true);
        
        // fixing bolt hole
        translate([0,cutout_length+3,0])
        cylinder(d=3, h=1000, center=true);
        
        // rod hole
        translate([0,cutout_length+5,0])
        rotate([-90,0,0])
        cylinder(d=8.5, h=1000);
    }    
}

module joint_mount(rod_spacing, holder_width=bearing_od+2, clearance=0) {
    difference() {
        union() {
            rotate([0,90,0])
            cylinder(d=bearing_od+2, h=rod_spacing-holder_width-4, center=true);
                
            mount_len = bearing_od/2+1+clearance;
            translate([0,-mount_len/2,0])
            cube([rod_spacing-holder_width-4, mount_len, bearing_od+2], true);
            
            for (side=[0,1])
                mirror([side,0,0])
                translate([-rod_spacing/2+holder_width/2+0.1,0,0])
                rotate([0,90,0])
                cylinder(d1=bearing_id+2, d2=bearing_od+2,h=2);
        }

        rotate([0,90,0])
        cylinder(d=bearing_id, h=1000, center=true);
    }
    
}

module joint_assembly2(zangle=0, xangle=0, rod_spacing = 60) {
    holder_width = bearing_od+2;
    
    
    for (side=[-1,1]) {
        translate([side*rod_spacing/2,0,0])
        rotate([xangle,0,0]) {
            joint_corss_shaft(holder_width);
     
            rotate([0,0,zangle])
            joint_rod_coupler();
        }
    }
    
    
    // fixing to body
    joint_mount(rod_spacing, holder_width);
}

phase = $t<0.5 ? $t*2 : 2-$t*2;
xangle = 0;//phase*90;
zangle = 35;
joint_assembly2(zangle, xangle);