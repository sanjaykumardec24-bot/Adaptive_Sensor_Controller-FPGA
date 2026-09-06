module adaptive_sensor_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] sensor_data,

    output reg        sample_enable,
    output reg [1:0]  activity_level
);

    reg [7:0] previous_data;
    reg [7:0] difference;
    reg [1:0] counter;
    reg       first_sample;

    localparam LOW    = 2'b00;
    localparam MEDIUM = 2'b01;
    localparam HIGH   = 2'b10;

    wire [7:0] current_difference;

    assign current_difference =
        (sensor_data >= previous_data) ?
        (sensor_data - previous_data) :
        (previous_data - sensor_data);

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            previous_data  <= 8'd0;
            difference     <= 8'd0;
            counter        <= 2'd0;
            activity_level <= LOW;
            sample_enable  <= 1'b0;
            first_sample   <= 1'b1;
        end

        else begin

            // First sensor reading becomes the reference
            if (first_sample) begin
                previous_data  <= sensor_data;
                difference     <= 8'd0;
                counter        <= 2'd0;
                activity_level <= LOW;
                sample_enable  <= 1'b0;
                first_sample   <= 1'b0;
            end

            else begin

                // Calculate sensor data change
                difference <= current_difference;

                // LOW activity
                if (current_difference <= 8'd5) begin

                    activity_level <= LOW;

                    if (counter == 2'd3) begin
                        sample_enable <= 1'b1;
                        counter <= 2'd0;
                    end
                    else begin
                        sample_enable <= 1'b0;
                        counter <= counter + 1'b1;
                    end

                end

                // MEDIUM activity
                else if (current_difference <= 8'd20) begin

                    activity_level <= MEDIUM;

                    if (counter == 2'd1) begin
                        sample_enable <= 1'b1;
                        counter <= 2'd0;
                    end
                    else begin
                        sample_enable <= 1'b0;
                        counter <= counter + 1'b1;
                    end

                end

                // HIGH activity
                else begin

                    activity_level <= HIGH;
                    sample_enable  <= 1'b1;
                    counter        <= 2'd0;

                end

                // Update reference value
                previous_data <= sensor_data;

            end
        end
    end

endmodule