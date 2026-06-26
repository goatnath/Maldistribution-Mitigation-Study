// Dimensions in mm
plate_x = 200;   // Width (X-axis, spanwise)
plate_y = 1000;  // Length (Y-axis, flow direction)
plate_z = 3;     // Thickness of the sheet (Z-axis)

// Triangle dimensions
triangle_length = 200; // Length along Y
triangle_width = 120;  // Width along X (spreads flow towards sides)
triangle_h = 10;       // Protrusion height above plate

$fn = 50;

union() {
    // 1. Base metal sheet
    translate([-plate_x/2, -plate_y/2, 0])
        cube([plate_x, plate_y, plate_z]);

    // 2. Triangular protrusion pointing upstream (+Y direction)
    translate([0, 0, plate_z]) {
        linear_extrude(height = triangle_h) {
            polygon(points = [
                [0, triangle_length/2],                  // Apex pointing upstream (+Y)
                [triangle_width/2, -triangle_length/2],   // Back right
                [-triangle_width/2, -triangle_length/2]   // Back left
            ]);
        }
    }
}
