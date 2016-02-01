use <MCAD/shapes.scad>;
use <profiles.scad>;

height=1400;

bed_dia = 400;
bed_to_column_spacing=50;
extrusion_width=20;
extrusion_height=40;


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

module cap(profile_distance, angle=120, s=0, e=2) {
    
    w = profile_distance+extrusion_height/2;
    
    points = [for (i=[s:e], j=[-1,1]) let (x=w, y=j*extrusion_width/2, a=i*angle) [x*cos(a)-y*sin(a), x*sin(a) + y*cos(a)]];
        
    polygon(points);

/*    projection()
    rotate([0,0,30])
    hexagon(580, 3);*/
}


module heater() {
    color([0.4, 0.4, 0.4])
    cylinder(d=bed_dia, h=10);    
}

module frame6() {
    profile_distance = bed_dia/2 + extrusion_height/2 + bed_to_column_spacing;


    echo(profile_distance);

    echo(profile_distance*sin(60)*2);

    translate([0,0,5])
    heater();
    
    // columns
    for (i=[1:5]) {
        rotate([0,0,60*i])
        translate([profile_distance,0,0])
        linear_extrude(height)
        //rotate([0,0,90])
        profile_2040();
    }

    translate([0,0,height])
    linear_extrude(3)
    cap(profile_distance, 60, 0, 5);

    // bottom cap
    linear_extrude(3)
    cap(profile_distance, 60, 0, 5);
}



module frame3() {
    profile_distance = (bed_dia/2 + 20) / cos(60);

    echo(profile_distance);

    echo(profile_distance*sin(60)*2);

    translate([0,0,5])
    heater();
    
    // columns
    for (i=[0:2]) {
        rotate([0,0,120*i])
        translate([profile_distance,0,0])
        linear_extrude(height)
        //rotate([0,0,90])
        profile_2040();
    }

    translate([0,0,height])
    linear_extrude(3)
    cap(profile_distance);

    // bottom cap
    linear_extrude(3)
    cap(profile_distance);    
}


translate([0,-500,0])
frame3();

translate([0,500,0])
frame6();