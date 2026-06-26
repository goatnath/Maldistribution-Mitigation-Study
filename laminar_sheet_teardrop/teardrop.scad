// Double sided teardrop on a plate
plate_x = 200;
plate_y = 1000;
plate_z = 3;
protrusion_h = 10;

$fn = 100;

scale([0.001, 0.001, 0.001]) union() {
    // Base plate
    translate([-plate_x/2, -plate_y/2, 0])
        cube([plate_x, plate_y, plate_z]);
        
    // Double-sided teardrop (biconvex lens shape)
    translate([0, 0, plate_z]) {
        linear_extrude(height = protrusion_h) {
            intersection() {
                translate([105, 0, 0]) circle(r=145);
                translate([-105, 0, 0]) circle(r=145);
            }
        }
    }
}
