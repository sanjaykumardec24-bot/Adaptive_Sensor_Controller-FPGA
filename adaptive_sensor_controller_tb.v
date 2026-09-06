`timescale 1ns/1ps

module adaptive_sensor_controller_tb;

    reg clk;
    reg reset;
    reg [7:0] sensor_data;

    wire sample_enable;
    wire [1:0] activity_level;

    // DUT - Device Under Test
    adaptive_sensor_controller DUT (
        .clk(clk),
        .reset(reset),
        .sensor_data(sensor_data),
        .sample_enable(sample_enable),
        .activity_level(activity_level)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Waveform
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, adaptive_sensor_controller_tb);
    end

    // Test
    initial begin

        clk = 0;
        reset = 1;
        sensor_data = 8'd100;

        #10;
        reset = 0;

        // LOW activity
        #10 sensor_data = 8'd101;
        #10 sensor_data = 8'd102;
        #10 sensor_data = 8'd103;

        // MEDIUM activity
        #10 sensor_data = 8'd115;
        #10 sensor_data = 8'd125;

        // HIGH activity
        #10 sensor_data = 8'd160;
        #10 sensor_data = 8'd210;
        #10 sensor_data = 8'd250;

        #20;

        $finish;
    end

    // Display output
    initial begin
        $monitor("Time=%0t | Sensor=%d | Activity=%b | Sample_Enable=%b",
                 $time, sensor_data, activity_level, sample_enable);
    end

endmodule